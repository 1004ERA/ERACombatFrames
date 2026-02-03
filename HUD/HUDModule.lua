---@class (exact) HUDModule : ERACombatModule
---@field private __index HUDModule
---@field options ERACombatSpecOptions
---@field private allFrames Frame[]
---@field private data HUDDataItem[]
---@field private dataActive HUDDataItem[]
---@field private displayActive HUDDisplay[]
---@field essentialsFrame Frame
---@field private essentialsIcons HUDEssentialsPlacement[]
---@field private essentialsIconsActive HUDEssentialsPlacement[]
---@field private updateLayout fun(self:HUDModule)
---@field private updateData fun(self:HUDModule, t:number)
---@field private baseGCD number
---@field private healthBar ERAStatusBar
---@field private healthData HUDHealth
---@field private resourceBeforeHealth HUDResourceDisplay[]
---@field private resourceAfterHealth HUDResourceDisplay[]
---@field private resourceActive HUDResourceDisplay[]
---@field curveHide96pctFull LuaCurveObject
---@field curveHide4pctEmpty LuaCurveObject
---@field curveHideNoDuration LuaCurveObject
HUDModule = {}
HUDModule.__index = HUDModule
setmetatable(HUDModule, { __index = ERACombatModule })

---comment
---@param cFrame ERACombatMainFrame
---@param baseGCD number
---@param spec number
---@return HUDModule
function HUDModule:Create(cFrame, baseGCD, spec)
    local x = {}
    setmetatable(x, HUDModule)
    ---@cast x HUDModule
    x:constructModule(cFrame, 0.1, 0.02, spec)

    x.options = ERACombatOptions_getForSpec(spec)

    x.data = {}
    x.essentialsFrame = CreateFrame("Frame", nil, UIParent)
    x.essentialsIcons = {}
    x.essentialsIconsActive = {}

    x.baseGCD = baseGCD

    x.resourceBeforeHealth = {}
    x.resourceAfterHealth = {}
    x.resourceActive = {}
    x.healthData = HUDHealth:Create(x, "player")
    x.healthBar = HUDHealthDisplay:Create(x, x.healthData, false)

    x.curveHide96pctFull = C_CurveUtil:CreateCurve()
    x.curveHide96pctFull:SetType(Enum.LuaCurveType.Step)
    x.curveHide96pctFull:AddPoint(0, 1)
    x.curveHide96pctFull:AddPoint(0.98, 1)
    x.curveHide96pctFull:AddPoint(0.981, 0)
    x.curveHide96pctFull:AddPoint(1, 0)

    x.curveHide4pctEmpty = C_CurveUtil:CreateCurve()
    x.curveHide4pctEmpty:SetType(Enum.LuaCurveType.Step)
    x.curveHide4pctEmpty:AddPoint(0, 0)
    x.curveHide4pctEmpty:AddPoint(0.04, 0)
    x.curveHide4pctEmpty:AddPoint(0.041, 1)
    x.curveHide4pctEmpty:AddPoint(1, 1)

    x.curveHideNoDuration = C_CurveUtil:CreateCurve()
    x.curveHideNoDuration:SetType(Enum.LuaCurveType.Step)
    x.curveHideNoDuration:AddPoint(0, 0)
    x.curveHideNoDuration:AddPoint(0.01, 0)
    x.curveHideNoDuration:AddPoint(0.011, 1)
    x.curveHideNoDuration:AddPoint(1, 1)

    x.allFrames = { x.essentialsFrame }

    return x
end

--------------------------------------------------------------------------------------------------------------------------------
---- ACTIVATION ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function HUDModule:SpecInactive()
    for _, f in ipairs(self.allFrames) do
        f:Hide()
    end
end
function HUDModule:SpecActive()
    for _, f in ipairs(self.allFrames) do
        f:Show()
    end
end
function HUDModule:ResetToIdle()
    for _, f in ipairs(self.allFrames) do
        f:Show()
    end
end

function HUDModule:CheckTalents()
    self.dataActive = {}
    for _, d in ipairs(self.data) do
        if (d:computeTalentActive()) then
            table.insert(self.dataActive, d)
        end
    end

    self.displayActive = {}

    self.essentialsIconsActive = {}
    for _, x in ipairs(self.essentialsIcons) do
        if (x.icon:computeActive()) then
            table.insert(self.essentialsIconsActive, x)
            table.insert(self.displayActive, x.icon)
        end
    end

    self.resourceActive = {}
    for _, x in ipairs(self.resourceBeforeHealth) do
        if (x:computeActive()) then
            table.insert(self.resourceActive, x)
            table.insert(self.displayActive, x)
        end
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        if (x:computeActive()) then
            table.insert(self.resourceActive, x)
            table.insert(self.displayActive, x)
        end
    end

    self:updateLayout()
end

function HUDModule:EnterVehicle()
    for _, f in ipairs(self.allFrames) do
        f:Hide()
    end
end
function HUDModule:ExitVehicle()
    for _, f in ipairs(self.allFrames) do
        f:Show()
    end
end

function HUDModule:updateLayout()
    self.essentialsFrame:SetPoint("CENTER", UIParent, "CENTER", self.options.essentialsX, self.options.essentialsY)
    self.essentialsFrame:SetSize(self.options.essentialsIconSize * #self.essentialsIconsActive, 2048)
    for i, x in ipairs(self.essentialsIconsActive) do
        x:setPlacement(self.options.essentialsIconSize * (i - (#self.essentialsIconsActive)) / 2, self.essentialsFrame)
    end
    local resourceWidth = self.options.essentialsIconSize * self.options.essentialsIconCount
    local y = -self.options.essentialsIconSize - self.options.resourcePadding
    for _, x in ipairs(self.resourceActive) do
        y = y - x:updateLayout_returnHeight(y, resourceWidth) - self.options.resourcePadding
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- CONTENT -------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---comment
---@param d HUDDataItem
function HUDModule:addData(d)
    table.insert(self.data, d)
end

---comment
---@param d HUDResourceDisplay
---@param beforeHealth boolean
function HUDModule:addResource(d, beforeHealth)
    if (beforeHealth) then
        table.insert(self.resourceBeforeHealth, d)
    else
        table.insert(self.resourceAfterHealth, d)
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- UPDATE --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---comment
---@param t number
function HUDModule:UpdateCombat(t)
    self:updateData(t)
    for _, d in ipairs(self.displayActive) do
        d:Update(t, true)
    end
end

---comment
---@param t number
function HUDModule:UpdateIdle(t)
    self:updateData(t)
    for _, d in ipairs(self.displayActive) do
        d:Update(t, false)
    end
end

---comment
---@param t number
function HUDModule:updateData(t)
    for _, d in ipairs(self.dataActive) do
        d:Update(t)
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- CONSTRUCTORS --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---comment
---@param spellID number
---@param talent ERALIBTalent|nil
---@return HUDCooldown
function HUDModule:AddCooldown(spellID, talent)
    return HUDCooldown:Create(spellID, self, talent)
end

---comment
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddEssentialsCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    local placement = HUDEssentialsPlacement:Create(icon)
    table.insert(self.essentialsIcons, placement)
    return icon
end

---comment
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerLowIdle
function HUDModule:AddPowerLowIdle(powerType, talent)
    return HUDPowerLowIdle:Create(self, powerType, talent)
end
---comment
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerHighIdle
function HUDModule:AddPowerHighIdle(powerType, talent)
    return HUDPowerHighIdle:Create(self, powerType, talent)
end
---comment
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@param targetPercent fun(): number
---@return HUDPowerTargetIdle
function HUDModule:AddPowerTargetIdle(powerType, talent, targetPercent)
    return HUDPowerTargetIdle:Create(self, powerType, talent, targetPercent)
end
---comment
---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return HUDPowerBarValueDisplay
function HUDModule:AddPowerBarValueDisplay(data, r, g, b, talent)
    return HUDPowerBarValueDisplay:Create(self, data, r, g, b, talent)
end

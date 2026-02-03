ERA_HUDModule_TimerHeight = 1024

---@class (exact) HUDModule : ERACombatModule
---@field private __index HUDModule
---@field options ERACombatSpecOptions
---@field private rootFrames Frame[]
---@field private data HUDDataItem[]
---@field private dataActive HUDDataItem[]
---@field private displayActive HUDDisplay[]
---@field essentialsFrame Frame
---@field timerFrame Frame
---@field private essentialsIcons HUDEssentialsPlacement[]
---@field private essentialsIconsActive HUDEssentialsPlacement[]
---@field private timerBars HUDTimerBar[]
---@field private timerBarsActive HUDTimerBar[]
---@field private updateLayout fun(self:HUDModule)
---@field private updateData fun(self:HUDModule, t:number, combat:boolean)
---@field private healthBar ERAStatusBar
---@field private healthData HUDHealth
---@field private resourceBeforeHealth HUDResourceDisplay[]
---@field private resourceAfterHealth HUDResourceDisplay[]
---@field private resourceActive HUDResourceDisplay[]
---@field private baseGCD number
---@field private totGCD number
---@field private gcdBar StatusBar
---@field private gcdLines Line[]
---@field private baseLine Line
---@field private createGCDLine fun(self:HUDModule): Line
---@field duration0 LuaDurationObject
---@field curveHide96pctFull LuaCurveObject
---@field curveHide4pctEmpty LuaCurveObject
---@field curveHideNoDuration LuaCurveObject
---@field curveTimer LuaCurveObject
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
    x.timerBars = {}
    x.timerBarsActive = {}

    x.timerFrame = CreateFrame("Frame", nil, x.essentialsFrame)
    x.timerFrame:SetPoint("BOTTOM", x.essentialsFrame, "CENTER", 0, 0)
    x.baseGCD = baseGCD
    x.gcdLines = {}
    x.baseLine = x:createGCDLine()
    x.baseLine:SetStartPoint("BOTTOMLEFT", x.timerFrame, 0, 1)
    x.baseLine:SetEndPoint("BOTTOMRIGHT", x.timerFrame, 0, 1)
    x.gcdBar = CreateFrame("StatusBar", nil, x.timerFrame)
    x.gcdBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    x.gcdBar:SetStatusBarColor(1.0, 1.0, 1.0, 0.77)
    x.gcdBar:SetFrameLevel(1)
    x.gcdBar:SetAllPoints()
    x.gcdBar:SetOrientation("VERTICAL")
    x.gcdBar:SetMinMaxValues(0, 10)
    x.gcdBar:SetValue(0)

    x.resourceBeforeHealth = {}
    x.resourceAfterHealth = {}
    x.resourceActive = {}
    x.healthData = HUDHealth:Create(x, "player")
    x.healthBar = HUDHealthDisplay:Create(x, x.healthData, false)

    x.duration0 = C_DurationUtil.CreateDuration()

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

    x.curveTimer = C_CurveUtil:CreateCurve()
    x.curveTimer:SetType(Enum.LuaCurveType.Linear)

    x.rootFrames = { x.essentialsFrame }

    return x
end

--------------------------------------------------------------------------------------------------------------------------------
---- ACTIVATION ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function HUDModule:SpecInactive()
    for _, f in ipairs(self.rootFrames) do
        f:Hide()
    end
end
function HUDModule:SpecActive()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
end
function HUDModule:ResetToIdle()
    self.timerFrame:Hide()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
end
function HUDModule:EnterCombat()
    self.timerFrame:Show()
end
function HUDModule:ExitCombat()
    self.timerFrame:Hide()
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

    self.timerBarsActive = {}
    for _, tb in ipairs(self.timerBars) do
        if (tb:computeActive()) then
            table.insert(self.timerBarsActive, tb)
            table.insert(self.displayActive, tb)
        end
    end

    self:updateLayout()
end

function HUDModule:EnterVehicle()
    for _, f in ipairs(self.rootFrames) do
        f:Hide()
    end
end
function HUDModule:ExitVehicle()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
end

function HUDModule:updateLayout()
    local iconSize = self.options.essentialsIconSize

    self.essentialsFrame:SetPoint("CENTER", UIParent, "CENTER", self.options.essentialsX, self.options.essentialsY)
    self.essentialsFrame:SetSize(iconSize * #self.essentialsIconsActive, 2 * ERA_HUDModule_TimerHeight)
    for i, x in ipairs(self.essentialsIconsActive) do
        x:setPlacement(iconSize * (i - (#self.essentialsIconsActive) / 2 - 0.5), iconSize)
    end
    local resourceWidth = iconSize * self.options.essentialsIconCount
    local y = -iconSize - self.options.resourcePadding
    for _, x in ipairs(self.resourceActive) do
        y = y - x:updateLayout_returnHeight(y, resourceWidth) - self.options.resourcePadding
    end

    self.timerFrame:SetSize(iconSize * #self.essentialsIconsActive, ERA_HUDModule_TimerHeight)
    if (self.options.gcdCount < #self.gcdLines) then
        repeat
            local removedLine = table.remove(self.gcdLines)
            removedLine:Hide()
        until self.options.gcdCount == #self.gcdLines
    else
        while (self.options.gcdCount > #self.gcdLines) do
            local newLine = self:createGCDLine()
            table.insert(self.gcdLines, newLine)
        end
    end
    for i, l in ipairs(self.gcdLines) do
        y = i * self.options.gcdHeight
        l:SetStartPoint("BOTTOMLEFT", self.timerFrame, 0, y)
        l:SetEndPoint("BOTTOMRIGHT", self.timerFrame, 0, y)
    end
    self.curveTimer:ClearPoints()
    self.curveTimer:AddPoint(0, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD, self.options.gcdCount * self.baseGCD)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 0.1, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 1, 0)
end
function HUDModule:createGCDLine()
    local l = self.timerFrame:CreateLine(nil, "BORDER", nil, 1)
    l:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    l:SetThickness(1)
    return l
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

---comment
---@param tb HUDTimerBar
function HUDModule:addTimerBar(tb)
    table.insert(self.timerBars, tb)
end

--------------------------------------------------------------------------------------------------------------------------------
---- UPDATE --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---comment
---@param t number
function HUDModule:UpdateCombat(t)
    self:updateData(t, true)

    local gcdDuration = self.baseGCD / (1 + GetHaste() / 100)
    if (gcdDuration ~= self.totGCD) then
        self.totGCD = gcdDuration
        local maxTimer = gcdDuration * ERA_HUDModule_TimerHeight / self.options.gcdHeight
        self.gcdBar:SetMinMaxValues(0, maxTimer)
        for _, tb in ipairs(self.timerBarsActive) do
            tb:updateMaxDuration(maxTimer)
        end
    end
    local currentGCD = C_Spell.GetSpellCooldownDuration(61304)
    ---@diagnostic disable-next-line: missing-parameter
    self.gcdBar:SetValue(currentGCD:EvaluateRemainingDuration(self.curveTimer))

    for _, d in ipairs(self.displayActive) do
        d:Update(t, true)
    end
end

---comment
---@param t number
function HUDModule:UpdateIdle(t)
    self:updateData(t, false)
    for _, d in ipairs(self.displayActive) do
        d:Update(t, false)
    end
end

---comment
---@param t number
---@param combat boolean
function HUDModule:updateData(t, combat)
    self.duration0:Reset()
    for _, d in ipairs(self.dataActive) do
        d:Update(t, combat)
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
---@param r number
---@param g number
---@param b number
---@return HUDCooldownIcon
function HUDModule:AddEssentialsCooldown(data, iconID, talent, r, g, b)
    local icon = HUDCooldownIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    icon:SetBorderColor(r, g, b)
    local placement = HUDEssentialsPlacement:Create(icon, self)
    table.insert(self.essentialsIcons, placement)
    local bar = HUDTimerBar:Create(placement, 0.5, data, talent, r, g, b)
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

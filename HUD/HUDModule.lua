ERA_HUDModule_TimerHeight = 1004

--------------------------------------------------------------------------------------------------------------------------------
--#region CSTR -----------------------------------------------------------------------------------------------------------------

---@class (exact) HUDModule : ERACombatModule
---@field private __index HUDModule
---@field options ERACombatSpecOptions
---@field private rootFrames Frame[]
---@field private data HUDDataItem[]
---@field private dataActive HUDDataItem[]
---@field private displayActive HUDDisplay[]
---@field private essentialsFrame Frame
---@field private timerFrameBack Frame
---@field private timerFrameFront Frame
---@field private resourceFrame Frame
---@field private defensiveFrame Frame
---@field private controlFrame Frame
---@field private powerboostFrame Frame
---@field private controlIcons HUDIcon[]
---@field private powerboostIcons HUDIcon[]
---@field private defensiveIcons HUDIcon[]
---@field private defensiveIconsActiveCount number
---@field private essentialsIconsActiveCount number
---@field private essentialsIcons HUDEssentialsSlot[]
---@field private essentialsLeftSideIcons HUDIcon[]
---@field private essentialsRightSideIcons HUDIcon[]
---@field private timerBars HUDTimerBar[]
---@field private timerBarsActive HUDTimerBar[]
---@field private healthBar ERAStatusBar
---@field private healthData HUDHealth
---@field private resourceBeforeHealth HUDResourceSlot[]
---@field private resourceAfterHealth HUDResourceSlot[]
---@field private baseGCD number
---@field private totalGCD number
---@field private gcdBar StatusBar
---@field private gcdLines Line[]
---@field private baseLine Line
---@field private createGCDLine fun(self:HUDModule): Line
---@field private castBarStrong StatusBar
---@field private castBarTransparent StatusBar
---@field private channelTicks Line[]
---@field private channelInfo { [number]: ChannelTickInfo }
---@field private isCasting boolean
---@field private targetCasting boolean
---@field private targetCasBar StatusBar
---@field private kicks HUDCooldown[]
---@field playerAuraFetcher { [number]: HUDAura }
---@field targetAuraFetcher { [number]: HUDAura }
---@field allAuraFetcher { [number]: HUDAura }
---@field private cdmParsed boolean
---@field duration0 LuaDurationObject
---@field curveHide96pctFull LuaCurveObject
---@field curveHide4pctEmpty LuaCurveObject
---@field curveHideNoDuration LuaCurveObject
---@field curveTimer LuaCurveObject
---@field curveAlphaSoon0 LuaCurveObject
---@field curveHideLessThanOnePointFive LuaCurveObject
---@field curveTrue0 LuaCurveObject
---@field curveFalse0 LuaCurveObject
---@field curveRedIf0 LuaColorCurveObject
HUDModule = {}
HUDModule.__index = HUDModule
setmetatable(HUDModule, { __index = ERACombatModule })

HUDModule.curveHide96pctFull = C_CurveUtil:CreateCurve()
HUDModule.curveHide96pctFull:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHide96pctFull:AddPoint(0, 1)
HUDModule.curveHide96pctFull:AddPoint(0.98, 1)
HUDModule.curveHide96pctFull:AddPoint(0.981, 0)
HUDModule.curveHide96pctFull:AddPoint(1, 0)

HUDModule.curveHide4pctEmpty = C_CurveUtil:CreateCurve()
HUDModule.curveHide4pctEmpty:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHide4pctEmpty:AddPoint(0, 0)
HUDModule.curveHide4pctEmpty:AddPoint(0.04, 0)
HUDModule.curveHide4pctEmpty:AddPoint(0.041, 1)
HUDModule.curveHide4pctEmpty:AddPoint(1, 1)

HUDModule.curveHideNoDuration = C_CurveUtil:CreateCurve()
HUDModule.curveHideNoDuration:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideNoDuration:AddPoint(0, 0)
HUDModule.curveHideNoDuration:AddPoint(0.01, 0)
HUDModule.curveHideNoDuration:AddPoint(0.011, 1)
HUDModule.curveHideNoDuration:AddPoint(1, 1)

HUDModule.curveAlphaSoon0 = C_CurveUtil:CreateCurve()
HUDModule.curveAlphaSoon0:SetType(Enum.LuaCurveType.Linear)
HUDModule.curveAlphaSoon0:AddPoint(0, 1)
HUDModule.curveAlphaSoon0:AddPoint(0.1618, 1)
HUDModule.curveAlphaSoon0:AddPoint(0.24, 0.8)
HUDModule.curveAlphaSoon0:AddPoint(0.3, 0.7)
HUDModule.curveAlphaSoon0:AddPoint(0.5, 0)
HUDModule.curveAlphaSoon0:AddPoint(1, 0)

HUDModule.curveHideLessThanOnePointFive = C_CurveUtil:CreateCurve()
HUDModule.curveHideLessThanOnePointFive:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideLessThanOnePointFive:AddPoint(0, 0)
HUDModule.curveHideLessThanOnePointFive:AddPoint(1.49, 0)
HUDModule.curveHideLessThanOnePointFive:AddPoint(1.5, 1)

HUDModule.curveTrue0 = C_CurveUtil:CreateCurve()
HUDModule.curveTrue0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveTrue0:AddPoint(0, 1)
HUDModule.curveTrue0:AddPoint(0.001, 1)
HUDModule.curveTrue0:AddPoint(0.002, 0)
HUDModule.curveTrue0:AddPoint(1, 0)

HUDModule.curveFalse0 = C_CurveUtil:CreateCurve()
HUDModule.curveFalse0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveFalse0:AddPoint(0, 0)
HUDModule.curveFalse0:AddPoint(0.001, 0)
HUDModule.curveFalse0:AddPoint(0.002, 1)
HUDModule.curveFalse0:AddPoint(1, 1)

HUDModule.curveRedIf0 = C_CurveUtil:CreateColorCurve()
HUDModule.curveRedIf0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveRedIf0:AddPoint(0, CreateColor(1.0, 0.0, 0.0, 1.0))
HUDModule.curveRedIf0:AddPoint(0.01, CreateColor(1.0, 1.0, 1.0, 1.0))

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
    x.essentialsIconsActiveCount = 0
    x.essentialsLeftSideIcons = {}
    x.essentialsRightSideIcons = {}
    x.timerBars = {}
    x.timerBarsActive = {}

    x.timerFrameBack = CreateFrame("Frame", nil, x.essentialsFrame)
    x.timerFrameBack:SetPoint("BOTTOM", x.essentialsFrame, "CENTER", 0, 0)
    x.timerFrameFront = CreateFrame("Frame", nil, x.essentialsFrame)
    x.timerFrameFront:SetPoint("BOTTOM", x.essentialsFrame, "CENTER", 0, 0)
    x.baseGCD = baseGCD
    x.gcdLines = {}
    x.baseLine = x:createGCDLine()
    x.baseLine:SetStartPoint("BOTTOMLEFT", x.timerFrameFront, 0, 1)
    x.baseLine:SetEndPoint("BOTTOMRIGHT", x.timerFrameFront, 0, 1)
    x.gcdBar = x:createGCCBar(2, 1.0, 1.0, 1.0, 0.64)
    x:setupMiddleGCCBar(x.gcdBar)
    x.castBarTransparent = x:createGCCBar(1, 0.2, 0.7, 0.2, 0.32)
    x:setupMiddleGCCBar(x.castBarTransparent)
    x.castBarStrong = x:createGCCBar(1, 0.2, 0.7, 0.2, 1.0)
    x.castBarStrong:SetSize(x.options.castBarWidth, ERA_HUDModule_TimerHeight)
    x.castBarStrong:SetPoint("BOTTOMLEFT", x.timerFrameBack, "BOTTOMLEFT", 0, 0)
    x.isCasting = false
    x.castBarTransparent:Hide()
    x.castBarStrong:Hide()
    x.channelInfo = {}
    x.channelTicks = {}
    x.kicks = {}
    x.targetCasBar = x:createGCCBar(1, 1.0, 1.0, 1.0, 1.0)
    x.targetCasBar:SetStatusBarTexture("Interface\\FontStyles\\FontStyleLegion")
    x.targetCasBar:SetRotatesTexture(true)
    x.targetCasBar:SetPoint("BOTTOMRIGHT", x.timerFrameBack, "BOTTOMRIGHT", 0, 0)
    x.targetCasBar:SetSize(x.options.castBarWidth, ERA_HUDModule_TimerHeight)
    x.targetCasBar:Hide()
    x.targetCasting = false

    x.playerAuraFetcher = {}
    x.targetAuraFetcher = {}
    x.allAuraFetcher = {}
    x.cdmParsed = false

    x.resourceFrame = CreateFrame("Frame", nil, UIParent)
    x.resourceBeforeHealth = {}
    x.resourceAfterHealth = {}
    x.healthData = HUDHealth:Create(x, "player")

    local healthSlot = HUDResourceSlot:create(x)
    table.insert(x.resourceAfterHealth, healthSlot)
    x.healthBar = healthSlot:AddHealth(x.healthData, false)

    x.controlFrame = CreateFrame("Frame", nil, UIParent)
    x.powerboostFrame = CreateFrame("Frame", nil, UIParent)
    x.defensiveFrame = CreateFrame("Frame", nil, UIParent)
    x.controlIcons = {}
    x.powerboostIcons = {}
    x.defensiveIcons = {}
    x.defensiveIconsActiveCount = 0

    x.duration0 = C_DurationUtil.CreateDuration()

    x.curveTimer = C_CurveUtil:CreateCurve()
    x.curveTimer:SetType(Enum.LuaCurveType.Linear)

    x.rootFrames = { x.essentialsFrame, x.resourceFrame, x.defensiveFrame, x.controlFrame, x.powerboostFrame }

    return x
end

---@private
---@return StatusBar
function HUDModule:createGCCBar(frameLevel, r, g, b, a)
    local bar = CreateFrame("StatusBar", nil, self.timerFrameBack)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetStatusBarColor(r, g, b, a)
    bar:SetFrameLevel(frameLevel)
    bar:SetOrientation("VERTICAL")
    bar:SetMinMaxValues(0, 10)
    bar:SetValue(0)
    return bar
end
---@private
---@param bar StatusBar
function HUDModule:setupMiddleGCCBar(bar)
    bar:SetPoint("TOPLEFT", self.timerFrameBack, "TOPLEFT", self.options.castBarWidth, 0)
    bar:SetPoint("TOPRIGHT", self.timerFrameBack, "TOPRIGHT", -self.options.castBarWidth, 0)
    bar:SetPoint("BOTTOMRIGHT", self.timerFrameBack, "BOTTOMRIGHT", -self.options.castBarWidth, 0)
    bar:SetPoint("BOTTOMLEFT", self.timerFrameBack, "BOTTOMLEFT", self.options.castBarWidth, 0)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region ACTIVATION & LAYOUT --------------------------------------------------------------------------------------------------

function HUDModule:SpecInactive()
    for _, f in ipairs(self.rootFrames) do
        f:Hide()
    end
    self.cdmParsed = false
end
function HUDModule:SpecActive()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
    self.cdmParsed = false
end
function HUDModule:ResetToIdle()
    self.timerFrameBack:Hide()
    self.timerFrameFront:Hide()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
    BuffIconCooldownViewer:SetAlpha(0)
    BuffBarCooldownViewer:SetAlpha(0)
    EssentialCooldownViewer:SetAlpha(0)
    UtilityCooldownViewer:SetAlpha(0)
end
function HUDModule:EnterCombat()
    self.timerFrameBack:Show()
    self.timerFrameFront:Show()
end
function HUDModule:ExitCombat()
    self.timerFrameBack:Hide()
    self.timerFrameFront:Hide()
end

function HUDModule:CheckTalents()
    self.cdmParsed = false

    self.dataActive = {}
    self.playerAuraFetcher = {}
    self.targetAuraFetcher = {}
    self.allAuraFetcher = {}
    for _, d in ipairs(self.data) do
        if (d:computeTalentActive()) then
            table.insert(self.dataActive, d)
        end
    end

    self.displayActive = {}

    self.essentialsIconsActiveCount = 0
    for _, x in ipairs(self.essentialsIcons) do
        if (x.icon:computeActive()) then
            table.insert(self.displayActive, x.icon)
            self.essentialsIconsActiveCount = self.essentialsIconsActiveCount + 1
        end
    end
    self:checkTalentsIconsList(self.essentialsLeftSideIcons)
    self:checkTalentsIconsList(self.essentialsRightSideIcons)
    self.defensiveIconsActiveCount = self:checkTalentsIconsList(self.defensiveIcons)
    self:checkTalentsIconsList(self.controlIcons)
    self:checkTalentsIconsList(self.powerboostIcons)

    for _, x in ipairs(self.resourceBeforeHealth) do
        x:computeTalents()
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        x:computeTalents()
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

---@private
---@param list HUDIcon[]
---@return number
function HUDModule:checkTalentsIconsList(list)
    local cpt = 0
    for _, icon in ipairs(list) do
        if (icon:computeActive()) then
            table.insert(self.displayActive, icon)
            cpt = cpt + 1
        end
    end
    return cpt
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

---@private
function HUDModule:updateLayout()
    local iCount = 0

    -- essentials & timer
    local iconSize = self.options.essentialsIconSize
    self.essentialsFrame:SetPoint("CENTER", UIParent, "CENTER", self.options.essentialsX, self.options.essentialsY)
    self.essentialsFrame:SetSize(iconSize * self.essentialsIconsActiveCount, 2 * ERA_HUDModule_TimerHeight)
    for _, x in ipairs(self.essentialsIcons) do
        if (x.icon.talentActive) then
            iCount = iCount + 1
            x:setPosition(iconSize * (iCount - self.essentialsIconsActiveCount / 2 - 0.5), iconSize, self.timerFrameBack)
        end
    end

    self.timerFrameBack:SetSize(iconSize * self.essentialsIconsActiveCount + 2 * self.options.castBarWidth, ERA_HUDModule_TimerHeight)
    self.timerFrameFront:SetSize(iconSize * self.essentialsIconsActiveCount + 2 * self.options.castBarWidth, ERA_HUDModule_TimerHeight)
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
        local yGCD = i * self.options.gcdHeight
        l:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, yGCD)
        l:SetEndPoint("BOTTOMRIGHT", self.timerFrameFront, 0, yGCD)
    end
    self.curveTimer:ClearPoints()
    self.curveTimer:AddPoint(0, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD, self.options.gcdCount * self.baseGCD)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 0.1, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 1, 0)

    -- resource
    local topResource = self.options.essentialsY - iconSize - self.options.resourcePadding
    local resourceWidth = iconSize * max(self.options.essentialsMinColumns, self.essentialsIconsActiveCount)
    self.resourceFrame:SetSize(iconSize * self.options.essentialsMinColumns - 2, 4 * (self.options.healthHeight + self.options.powerHeight))
    self.resourceFrame:SetPoint("TOP", UIParent, "CENTER", self.options.essentialsX, topResource)
    local yResource = 0
    for _, x in ipairs(self.resourceBeforeHealth) do
        local rh = x:updateLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        local rh = x:updateLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end

    -- side of essentials
    local sideColumns
    if (self.options.essentialsMinColumns == self.essentialsIconsActiveCount) then
        sideColumns = 1
    else
        sideColumns = 1 + math.ceil(((resourceWidth - iconSize * self.essentialsIconsActiveCount) / iconSize) / 2)
    end
    local xSide = (-self.essentialsIconsActiveCount / 2 + 0.5) * iconSize
    local ySide = 0
    iCount = 0
    for _, s in ipairs(self.essentialsLeftSideIcons) do
        if (s.talentActive) then
            iCount = iCount + 1
            if (iCount > sideColumns) then
                ySide = ySide - iconSize
            else
                xSide = xSide - iconSize
            end
        end
        s:setPosition(xSide, ySide)
    end
    xSide = (self.essentialsIconsActiveCount / 2 - 0.5) * iconSize
    ySide = 0
    iCount = 0
    for _, s in ipairs(self.essentialsRightSideIcons) do
        if (s.talentActive) then
            iCount = iCount + 1
            if (iCount > sideColumns) then
                ySide = ySide + iconSize
            else
                xSide = xSide + iconSize
            end
        end
        s:setPosition(xSide, ySide)
    end

    -- defensive
    iconSize = self.options.defensiveIconSize + self.options.utilityIconPadding
    self.defensiveFrame:SetPoint("TOP", UIParent, "CENTER", self.options.essentialsX, topResource + yResource - self.options.defensivePadding)
    iCount = 0
    for _, icon in ipairs(self.defensiveIcons) do
        if (icon.talentActive) then
            iCount = iCount + 1
            icon:setPosition(iconSize * (iCount - self.defensiveIconsActiveCount / 2 - 0.5), -self.options.utilityIconPadding)
        end
    end
    self.defensiveFrame:SetSize(iCount * iconSize + self.options.utilityIconPadding, iconSize + self.options.utilityIconPadding)

    -- utility
    self:utilityLayout(self.controlIcons, 1, self.options.controlIconSize, self.options.utilityIconPadding, self.controlFrame)
    self.controlFrame:SetPoint("TOPLEFT", UIParent, "CENTER", self.options.controlX, self.options.controlY)
    self:utilityLayout(self.powerboostIcons, -1, self.options.powerboostIconSize, self.options.utilityIconPadding, self.powerboostFrame)
    self.powerboostFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", self.options.powerboostX, self.options.powerboostY)
end

---@private
---@param list HUDIcon[]
---@param direction number
---@param iconSize number
---@param padding number
---@param frame Frame
function HUDModule:utilityLayout(list, direction, iconSize, padding, frame)
    local x = direction * padding
    local yTop = -padding
    local yBot = -padding - (iconSize + padding) * math.sqrt(3) / 2
    local dX = direction * (iconSize + padding) / 2
    local first_row = true
    local first_row_count = 0
    local has_second_row = false
    local last_is_second_row = false

    for _, icon in ipairs(list) do
        if (icon.talentActive) then
            local y
            if (first_row) then
                first_row_count = first_row_count + 1
                y = yTop
                first_row = false
            else
                last_is_second_row = true
                y = yBot
                first_row = true
            end
            icon:setPosition(x, y)
            x = x + dX
        end
    end

    local fWidth, fHeight
    if (last_is_second_row) then
        fWidth = padding + (first_row_count + 0.5) * (iconSize + padding)
    else
        fWidth = padding + first_row_count * (iconSize + padding)
    end
    if (has_second_row) then
        fHeight = padding + (iconSize + padding) * (1 + math.sqrt(3) / 2)
    else
        fHeight = iconSize + 2 * padding
    end
    frame:SetSize(fWidth, fHeight)
end

---@private
---@return Line
function HUDModule:createGCDLine()
    local l = self.timerFrameFront:CreateLine(nil, "BORDER", nil, 1)
    l:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    l:SetThickness(1)
    return l
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region CONTENT --------------------------------------------------------------------------------------------------------------

---@return Frame
function HUDModule:getTimerBarFrame()
    return self.timerFrameBack
end
---@return Frame
function HUDModule:getResourceFrame()
    return self.resourceFrame
end

---@param a HUDAura
---@param isTarget boolean
function HUDModule:addActiveAura(a, isTarget)
    if (isTarget) then
        self.targetAuraFetcher[a.spellID] = a
    else
        self.playerAuraFetcher[a.spellID] = a
    end
    self.allAuraFetcher[a.spellID] = a
end

---@param r HUDResourceDisplay
function HUDModule:addActiveResource(r)
    table.insert(self.displayActive, r)
end

---@param d HUDDataItem
function HUDModule:addData(d)
    table.insert(self.data, d)
end

---@param tb HUDTimerBar
function HUDModule:addTimerBar(tb)
    table.insert(self.timerBars, tb)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region UPDATE ---------------------------------------------------------------------------------------------------------------

---@private
function HUDModule:createTickLine()
    local l = self.timerFrameFront:CreateLine(nil, "BORDER", nil, 2)
    l:SetColorTexture(1.0, 0.0, 0.0, 1.0)
    l:SetThickness(1)
    return l
end

---@param t number
function HUDModule:UpdateCombat(t)
    self:updateData(t, true)

    local gcdDuration
    local pixelPerSecondWithoutHaste
    if (self.baseGCD == 1) then
        gcdDuration = 1
        pixelPerSecondWithoutHaste = self.options.gcdHeight
    else
        gcdDuration = self.baseGCD / (1 + GetHaste() / 100)
        pixelPerSecondWithoutHaste = self.options.gcdHeight / self.baseGCD
    end
    local pixelPerSecond = self.options.gcdHeight / gcdDuration
    if (gcdDuration ~= self.totalGCD) then
        self.totalGCD = gcdDuration
        local maxTimer = ERA_HUDModule_TimerHeight / pixelPerSecond
        self.gcdBar:SetMinMaxValues(0, maxTimer)
        self.castBarStrong:SetMinMaxValues(0, maxTimer)
        self.castBarTransparent:SetMinMaxValues(0, maxTimer)
        for _, tb in ipairs(self.timerBarsActive) do
            tb:updateMaxDuration(maxTimer)
        end
    end
    local currentGCD = C_Spell.GetSpellCooldownDuration(61304)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.gcdBar:SetValue(currentGCD:EvaluateRemainingDuration(self.curveTimer))

    --#region CASTING

    local _, _, _, _, _, _, _, channelID, isEmpowered, numEmpowerStages = UnitChannelInfo("player")
    if (channelID) then
        local dur = UnitChannelDuration("player")
        self.castBarStrong:SetValue(dur:GetRemainingDuration())
        ---@diagnostic disable-next-line: param-type-mismatch
        self.castBarTransparent:SetValue(dur:EvaluateRemainingDuration(self.curveTimer))
        if (not self.isCasting) then
            self.isCasting = true
            self.castBarStrong:Show()
            self.castBarTransparent:Show()
        end
        local ci = self.channelInfo[channelID]
        if (ci) then
            for i = 1, ci.tickCount - 1 do
                local line
                if (i > #self.channelTicks) then
                    line = self:createTickLine()
                    table.insert(self.channelTicks, line)
                else
                    line = self.channelTicks[i]
                    line:Show()
                end
                local yTick = i * ci.tickDelta * pixelPerSecondWithoutHaste
                line:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, yTick)
                line:SetEndPoint("BOTTOMLEFT", self.timerFrameFront, self.options.castBarWidth, yTick)
            end
            for i = ci.tickCount, #self.channelTicks do
                self.channelTicks[i]:Hide()
            end
        else
            for _, ct in ipairs(self.channelTicks) do
                ct:Hide()
            end
        end
    else
        local _, _, _, _, _, _, _, _, castID = UnitCastingInfo("player")
        if (castID) then
            local dur = UnitCastingDuration("player")
            self.castBarStrong:SetValue(dur:GetRemainingDuration())
            ---@diagnostic disable-next-line: param-type-mismatch
            self.castBarTransparent:SetValue(dur:EvaluateRemainingDuration(self.curveTimer))
            if (self.isCasting) then
                for _, ct in ipairs(self.channelTicks) do
                    ct:Hide()
                end
            else
                self.isCasting = true
                self.castBarStrong:Show()
                self.castBarTransparent:Show()
            end
        else
            if (self.isCasting) then
                self.isCasting = false
                self.castBarStrong:Hide()
                self.castBarTransparent:Hide()
                for _, ct in ipairs(self.channelTicks) do
                    ct:Hide()
                end
            end
        end
    end

    --#endregion

    --#region TARGET CASTING

    local targetCastDuration = nil
    ---@type HUDCooldown
    local foundKick = nil
    for _, k in ipairs(self.kicks) do
        if (k.talentActive) then
            foundKick = k
            break
        end
    end
    if (foundKick) then
        _, _, _, _, _, _, _, channelID = UnitChannelInfo("target")
        if (channelID) then
            targetCastDuration = UnitChannelDuration("target")
        else
            local _, _, _, _, _, _, _, _, castID = UnitCastingInfo("target")
            if (castID) then
                targetCastDuration = UnitCastingDuration("target")
            end
        end
    end
    if (targetCastDuration) then
        self.targetCasBar:SetValue(targetCastDuration:GetRemainingDuration())
        ---@diagnostic disable-next-line: param-type-mismatch
        self.targetCasBar:SetAlpha(foundKick.cooldownDuration:EvaluateRemainingDuration(self.curveTrue0))
        if (not self.targetCasting) then
            self.targetCasting = true
            self.targetCasBar:Show()
        end
    else
        if (self.targetCasting) then
            self.targetCasting = false
            self.targetCasBar:Hide()
        end
    end

    --#endregion

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

---@private
---@param t number
---@param combat boolean
function HUDModule:updateData(t, combat)
    self.duration0:Reset()

    --#region AURAS

    if (not self.cdmParsed) then
        self.cdmParsed = true
        for _, aura in pairs(self.allAuraFetcher) do
            aura:prepareParseCDM()
        end
        self:parseCDMBuff(BuffBarCooldownViewer)
        self:parseCDMBuff(BuffIconCooldownViewer)
    end
    --[[
    for i = 1, 1000 do
        local auraData = C_UnitAuras.GetBuffDataByIndex("player", i, "PLAYER")
        if (auraData) then
            if (issecretvalue(auraData.spellId)) then
                --that hack doesnt work anymore
                local hackID = 0
                for j = 1, auraData.spellId do
                    hackID = hackID + 1
                end
            else
                local timer = self.playerAuraFetcher[auraData.spellId]
                if (timer) then
                    timer:auraFound(C_UnitAuras.GetAuraDuration("player", auraData.auraInstanceID), auraData)
                end
            end
        else
            break
        end
    end
    ]]
    --#endregion

    for _, d in ipairs(self.dataActive) do
        d:Update(t, combat)
    end
end

---@private
function HUDModule:parseCDMBuff(frame)
    local buffFrames = { frame:GetChildren() }
    for _, c in ipairs(buffFrames) do
        if (c.cooldownInfo and c.cooldownInfo.spellID) then
            local aura = self.allAuraFetcher[c.cooldownInfo.spellID]
            if (aura) then
                aura:setCDM(c)
            end
        end
    end
end

---@class CDMAuraFrame
---@field auraInstanceID number|nil

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region CONSTRUCTORS ---------------------------------------------------------------------------------------------------------

---@class ChannelTickInfo
---@field tickCount number
---@field tickDelta number

---@param tickCount number
---@param tickDelta number
function HUDModule:AddChannelInfo(spellID, tickCount, tickDelta)
    local info = {}
    info.tickCount = tickCount
    info.tickDelta = tickDelta
    self.channelInfo[spellID] = info
end

---@param cd HUDCooldown
function HUDModule:AddKickInfo(cd)
    table.insert(self.kicks, cd)
end

---@param spellID number
---@param talent ERALIBTalent|nil
---@return HUDCooldown
function HUDModule:AddCooldown(spellID, talent)
    return HUDCooldown:Create(spellID, self, talent)
end

---@param spellID number
---@param isTarget boolean
---@param talent ERALIBTalent|nil
---@return HUDAura
function HUDModule:AddAuraByPlayer(spellID, isTarget, talent)
    return HUDAura:createAura(spellID, self, talent, isTarget)
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@return HUDCooldownIcon, HUDEssentialsSlot
function HUDModule:AddEssentialsCooldown(data, iconID, talent, r, g, b)
    local icon = HUDCooldownIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    icon:SetBorderColor(r, g, b)
    local placement = HUDEssentialsSlot:create(icon, self)
    table.insert(self.essentialsIcons, placement)
    local bar = HUDTimerBar:Create(placement, 0.5, data, talent, r, g, b, self.timerFrameBack)
    return icon, placement
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon, HUDEssentialsSlot
function HUDModule:AddEssentialsAura(data, iconID, talent)
    local icon = HUDAuraIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    local placement = HUDEssentialsSlot:create(icon, self)
    table.insert(self.essentialsIcons, placement)
    return icon, placement
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddEssentialsLeftCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsLeftSideIcons, icon)
    return icon
end
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddEssentialsRightCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsRightSideIcons, icon)
    return icon
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon
function HUDModule:AddEssentialsLeftAura(data, iconID, talent)
    local icon = HUDAuraIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsLeftSideIcons, icon)
    return icon
end
---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon
function HUDModule:AddEssentialsRightAura(data, iconID, talent)
    local icon = HUDAuraIcon:Create(self.essentialsFrame, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsRightSideIcons, icon)
    return icon
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddDefensiveCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.defensiveFrame, "TOP", "TOP", self.options.defensiveIconSize, data, iconID, talent)
    table.insert(self.defensiveIcons, icon)
    return icon
end
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddControlCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.controlFrame, "TOPLEFT", "TOPLEFT", self.options.controlIconSize, data, iconID, talent)
    table.insert(self.controlIcons, icon)
    return icon
end
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddPowerboostCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:Create(self.powerboostFrame, "TOPRIGHT", "TOPRIGHT", self.options.powerboostIconSize, data, iconID, talent)
    table.insert(self.powerboostIcons, icon)
    return icon
end

---@param afterHealth boolean
---@return HUDResourceSlot
function HUDModule:AddResourceSlot(afterHealth)
    local slot = HUDResourceSlot:create(self)
    if (afterHealth) then
        table.insert(self.resourceAfterHealth, slot)
    else
        table.insert(self.resourceBeforeHealth, slot)
    end
    return slot
end

---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerLowIdle
function HUDModule:AddPowerLowIdle(powerType, talent)
    return HUDPowerLowIdle:Create(self, powerType, talent)
end
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerHighIdle
function HUDModule:AddPowerHighIdle(powerType, talent)
    return HUDPowerHighIdle:Create(self, powerType, talent)
end
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@param targetPercent fun(): number
---@return HUDPowerTargetIdle
function HUDModule:AddPowerTargetIdle(powerType, talent, targetPercent)
    return HUDPowerTargetIdle:Create(self, powerType, talent, targetPercent)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
--#region ESSENTIALS PLACEMENT ---------------------------------
----------------------------------------------------------------

---@class (exact) HUDEssentialsPlacement
---@field private __index HUDEssentialsPlacement
---@field icon HUDIcon
---@field hud HUDModule
---@field private bars HUDTimerBar[]
HUDEssentialsPlacement = {}
HUDEssentialsPlacement.__index = HUDEssentialsPlacement

---comment
---@param icon HUDIcon
---@param hud HUDModule
---@return HUDEssentialsPlacement
function HUDEssentialsPlacement:Create(icon, hud)
    local x = {}
    setmetatable(x, HUDEssentialsPlacement)
    ---@cast x HUDEssentialsPlacement
    x.icon = icon
    x.hud = hud
    x.bars = {}
    return x
end

---comment
---@param xMid number
---@param iconSize number
function HUDEssentialsPlacement:setPlacement(xMid, iconSize)
    self.icon:setPosition(xMid, 0)
    for _, tb in ipairs(self.bars) do
        if (tb.talentActive) then
            tb:updateLayout(xMid, iconSize)
        end
    end
end

---comment
---@param bar HUDTimerBar
function HUDEssentialsPlacement:addBar(bar)
    table.insert(self.bars, bar)
end

---@param position number
---@param timer HUDTimer
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@return HUDTimerBar
function HUDEssentialsPlacement:AddTimerBar(position, timer, talent, r, g, b)
    return HUDTimerBar:Create(self, position, timer, talent, r, g, b)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region GENERIC DISPLAY --------------------------------------
----------------------------------------------------------------

---@class (exact) HUDDisplay
---@field private __index HUDDisplay
---@field protected constructDisplay fun(self:HUDDisplay, hud:HUDModule, talent:ERALIBTalent|nil)
---@field hud HUDModule
---@field private talent ERALIBTalent|nil
---@field talentActive boolean
---@field protected talentIsActive fun(self:HUDDisplay)
---@field protected Activate fun(self:HUDDisplay)
---@field protected Deactivate fun(self:HUDDisplay)
---@field Update fun(self:HUDDisplay, t:number, combat:boolean)
HUDDisplay = {}
HUDDisplay.__index = HUDDisplay

function HUDDisplay:constructDisplay(hud, talent)
    self.hud = hud
    self.talentActive = nil
    self.talent = talent
end

---comment
---@return boolean
function HUDDisplay:computeActive()
    local active = (not self.talent) or self.talent:PlayerHasTalent()
    if (self.talentActive == nil) then
        if (active) then
            self.talentActive = true
            self:Activate()
        else
            self.talentActive = false
            self:Deactivate()
        end
    else
        if (self.talentActive) then
            if (not active) then
                self.talentActive = true
                self:Activate()
            end
        else
            if (active) then
                self.talentActive = false
                self:Deactivate()
            end
        end
    end
    if (active) then
        self:talentIsActive()
        return true
    else
        return false
    end
end
function HUDDisplay:talentIsActive()
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region RESOURCE ---------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDResourceDisplay : HUDDisplay
---@field private __index HUDResourceDisplay
---@field protected constructResource fun(self:HUDResourceDisplay, hud:HUDModule, beforeHealth:boolean, talent:ERALIBTalent|nil)
---@field height number
---@field updateLayout_returnHeight fun(self:HUDResourceDisplay, y:number, width:number): number
HUDResourceDisplay = {}
HUDResourceDisplay.__index = HUDResourceDisplay
setmetatable(HUDResourceDisplay, { __index = HUDDisplay })

---comment
---@param hud HUDModule
---@param beforeHealth boolean
---@param talent ERALIBTalent|nil
function HUDResourceDisplay:constructResource(hud, beforeHealth, talent)
    self:constructDisplay(hud, talent)
    hud:addResource(self, beforeHealth)
end

------------------------
--#region HEALTH -------
------------------------

---@class (exact) HUDHealthDisplay : HUDResourceDisplay
---@field private __index HUDHealthDisplay
---@field private data HUDHealth
---@field private bar ERAStatusBar
HUDHealthDisplay = {}
HUDHealthDisplay.__index = HUDHealthDisplay
setmetatable(HUDHealthDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param data HUDHealth
---@param isPet boolean
---@return HUDHealthDisplay
function HUDHealthDisplay:Create(hud, data, isPet)
    local x = {}
    setmetatable(x, HUDHealthDisplay)
    ---@cast x HUDHealthDisplay
    x:constructResource(hud, false)

    x.data = data
    x.bar = ERAStatusBar:Create(hud.essentialsFrame, "TOP", "CENTER")
    if (isPet) then
        x.height = 2 * hud.options.healthHeight / 3
        x.bar:SetBarColor(0.0, 0.8, 0.0, false)
        x.bar:SetBorderColor(0.0, 0.8, 0.0, false)
    else
        x.height = hud.options.healthHeight
        x.bar:SetBarColor(0.0, 1.0, 0.0, false)
        x.bar:SetBorderColor(0.0, 1.0, 0.0, false)
    end

    return x
end

function HUDHealthDisplay:Activate()
    self.bar:SetActiveShown(true)
end
function HUDHealthDisplay:Deactivate()
    self.bar:SetActiveShown(false)
end

---comment
---@param y number
---@param width number
---@return number
function HUDHealthDisplay:updateLayout_returnHeight(y, width)
    self.bar:UpdateLayout(0, y, width, self.height)
    return self.height
end

---comment
---@param t number
---@param combat boolean
function HUDHealthDisplay:Update(t, combat)
    if (combat) then
        self.bar:SetVisibilityAlpha(1.0, false)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        self.bar:SetVisibilityAlpha(UnitHealthPercent(self.data.unit, true, self.hud.curveHide96pctFull), true)
    end
    self.bar:SetMinMax(0, self.data.maxHealth)
    self.bar:SetValue(self.data.health)
    self.bar:SetExcessMax(self.data.badAbsorb)
    self.bar:SetExcessMin(self.data.goodAbsorb)
    self.bar:SetRightText(string.format("%i", self.data.healthPercent100), true)
end

--#endregion
------------------------

------------------------
--#region POWER --------
------------------------

--#region BAR

---@class (exact) HUDPowerBarDisplay : HUDResourceDisplay
---@field private __index HUDPowerBarDisplay
---@field data HUDPower
---@field protected bar ERAStatusBar
---@field private height number -- inherited
---@field protected displayTexts fun(self:HUDPowerBarDisplay)
---@field private ticks HUDPowerBarTick[]
---@field private ticksActive HUDPowerBarTick[]
HUDPowerBarDisplay = {}
HUDPowerBarDisplay.__index = HUDPowerBarDisplay
setmetatable(HUDPowerBarDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
function HUDPowerBarDisplay:constructPower(hud, data, r, g, b, talent)
    self:constructResource(hud, true, ERALIBTalent_CombineMakeAnd(talent, data.talent))

    self.ticks = {}
    self.ticksActive = {}

    self.data = data
    self.bar = ERAStatusBar:Create(hud.essentialsFrame, "TOP", "CENTER")
    self.height = hud.options.powerHeight
    self.bar:SetBarColor(r, g, b, false)
    self.bar:SetBorderColor(r, g, b, false)
end

function HUDPowerBarDisplay:Activate()
    self.bar:SetActiveShown(true)
end
function HUDPowerBarDisplay:Deactivate()
    self.bar:SetActiveShown(false)
end

---comment
---@param y number
---@param width number
---@return number
function HUDPowerBarDisplay:updateLayout_returnHeight(y, width)
    self.bar:UpdateLayout(0, y, width, self.height)

    self.ticksActive = {}
    local bThick = self.bar:GetBorderThickness()
    for _, t in ipairs(self.ticks) do
        if (t:checkTalentAndHideOrLayout(width, self.height, bThick)) then
            table.insert(self.ticksActive, t)
        end
    end

    return self.height
end

---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(): number
---@return HUDPowerBarTick
function HUDPowerBarDisplay:AddTick(iconID, talent, tickValue)
    local t = HUDPowerBarTick:create(self, iconID, talent, tickValue, self.bar)
    table.insert(self.ticks, t)
    return t
end

---comment
---@param t number
---@param combat boolean
function HUDPowerBarDisplay:Update(t, combat)
    if (combat) then
        self.bar:SetVisibilityAlpha(1.0, false)
    else
        self.bar:SetVisibilityAlpha(self.data.idleAlphaOOC, true)
    end
    self.bar:SetMinMax(0, self.data.max)
    self.bar:SetValue(self.data.current)
    self:displayTexts()
    for _, tk in ipairs(self.ticksActive) do
        tk:update(t, combat)
    end
end

--#region DISPLAY KINDS

---@class (exact) HUDPowerBarPercentDisplay : HUDPowerBarDisplay
---@field private __index HUDPowerBarPercentDisplay
HUDPowerBarPercentDisplay = {}
HUDPowerBarPercentDisplay.__index = HUDPowerBarPercentDisplay
setmetatable(HUDPowerBarPercentDisplay, { __index = HUDPowerBarDisplay })

---comment
---@param hud HUDModule
---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return HUDPowerBarPercentDisplay
function HUDPowerBarPercentDisplay:Create(hud, data, r, g, b, talent)
    local x = {}
    setmetatable(x, HUDPowerBarPercentDisplay)
    ---@cast x HUDPowerBarPercentDisplay
    x:constructPower(hud, data, r, g, b, talent)
    return x
end

function HUDPowerBarPercentDisplay:displayTexts()
    self.bar:SetRightText(string.format("%i", self.data.percent100), true)
end

---@class (exact) HUDPowerBarValueDisplay : HUDPowerBarDisplay
---@field private __index HUDPowerBarPercentDisplay
HUDPowerBarValueDisplay = {}
HUDPowerBarValueDisplay.__index = HUDPowerBarValueDisplay
setmetatable(HUDPowerBarValueDisplay, { __index = HUDPowerBarDisplay })

---comment
---@param hud HUDModule
---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return HUDPowerBarValueDisplay
function HUDPowerBarValueDisplay:Create(hud, data, r, g, b, talent)
    local x = {}
    setmetatable(x, HUDPowerBarValueDisplay)
    ---@cast x HUDPowerBarValueDisplay
    x:constructPower(hud, data, r, g, b, talent)
    return x
end

function HUDPowerBarValueDisplay:displayTexts()
    self.bar:SetLeftText(string.format("%i", self.data.current), true)
end

--#endregion

--#endregion

--#region TICKS

---@class (exact) HUDPowerBarTick
---@field private __index HUDPowerBarTick
---@field private owner HUDPowerBarDisplay
---@field private parentFrame Frame
---@field private talent ERALIBTalent|nil
---@field private icon Texture
---@field private tick Line
---@field private tickValueGetter fun(): number
---@field private tickValue number
---@field private curve LuaColorCurveObject
---@field OverrideAlpha nil|fun(self:HUDPowerBarTick): number
---@field OverrideDesaturated nil|fun(self:HUDPowerBarTick): number
HUDPowerBarTick = {}
HUDPowerBarTick.__index = HUDPowerBarTick

---comment
---@param owner HUDPowerBarDisplay
---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(): number
---@param sBar ERAStatusBar
---@return HUDPowerBarTick
function HUDPowerBarTick:create(owner, iconID, talent, tickValue, sBar)
    local x = {}
    setmetatable(x, HUDPowerBarTick)
    ---@cast x HUDPowerBarTick
    x.owner = owner
    x.talent = talent
    x.tickValueGetter = tickValue
    x.tickValue = 0

    x.parentFrame = sBar:GetDrawFrame()
    local drawLevel = sBar:GetDrawFrameLevel()
    x.tick = x.parentFrame:CreateLine(nil, "OVERLAY", nil, drawLevel)
    x.tick:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    x.tick:SetThickness(1)
    x.icon = x.parentFrame:CreateTexture(nil, "OVERLAY")
    x.icon:SetTexture(iconID)

    x.curve = C_CurveUtil.CreateColorCurve()
    x.curve:SetType(Enum.LuaCurveType.Step)

    return x
end

---@param barWidth number
---@param height number
---@param borderThickness number
---@return boolean
function HUDPowerBarTick:checkTalentAndHideOrLayout(barWidth, height, borderThickness)
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.tick:Hide()
        self.icon:Hide()
        return false
    else
        self.tickValue = self.tickValueGetter()
        local pct1 = self.tickValue / self.owner.data.maxNotSecret
        self.curve:ClearPoints()
        self.curve:AddPoint(0, CreateColor(0.8, 0.1, 0.1, 1.0))
        --self.curve:AddPoint(pct1 - 0.01, CreateColor(0.8, 0.1, 0.1, 1.0))
        self.curve:AddPoint(pct1, CreateColor(0.0, 1.0, 0.0, 1.0))
        --self.curve:AddPoint(1, CreateColor(0.0, 1.0, 0.0, 1.0))

        local x = (barWidth - 2 * borderThickness) * pct1
        local y = -height * 0.5
        self.tick:SetStartPoint("TOPLEFT", self.parentFrame, x, 0)
        self.tick:SetEndPoint("TOPLEFT", self.parentFrame, x, y)
        self.icon:SetSize(height / 2, height / 2)
        self.icon:SetPoint("TOP", self.parentFrame, "TOPLEFT", x, y)

        self.tick:Show()
        self.icon:Show()

        return true
    end
end

---@param t number
---@param combat boolean
function HUDPowerBarTick:update(t, combat)
    local alpha
    if (self.OverrideAlpha) then
        alpha = self.OverrideAlpha(self)
        self.icon:SetAlpha(alpha)
    else
        alpha = 1.0
        self.icon:SetAlpha(1.0)
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local tickColor = UnitPowerPercent("player", self.owner.data.powerType, false, self.curve)
    ---@diagnostic disable-next-line: undefined-field
    self.tick:SetColorTexture(tickColor.r, tickColor.g, tickColor.b, alpha)

    if (self.OverrideDesaturated) then
        self.icon:SetDesaturation(self.OverrideDesaturated(self))
    end
end

--#endregion

--#endregion
------------------------

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region GENERIC ICON -----------------------------------------
----------------------------------------------------------------

---@class (exact) HUDIcon : HUDDisplay
---@field private __index HUDIcon
---@field protected constructIcon fun(self:HUDIcon, hud:HUDModule, icon:ERAIcon, talent:ERALIBTalent|nil)
---@field private icon ERAIcon
HUDIcon = {}
HUDIcon.__index = HUDIcon
setmetatable(HUDIcon, { __index = HUDDisplay })

function HUDIcon:constructIcon(hud, icon, talent)
    self:constructDisplay(hud, talent)
    self.icon = icon
end

---comment
---@param x number
---@param y number
function HUDIcon:setPosition(x, y)
    self.icon:SetPosition(x, y)
end

function HUDIcon:Activate()
    self.icon:SetActiveShown(true)
end
function HUDIcon:Deactivate()
    self.icon:SetActiveShown(false)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region PIE ICON ---------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDPieIcon : HUDIcon
---@field private __index HUDPieIcon
---@field protected constructPie fun(self:HUDPieIcon, hud:HUDModule, frame:Frame, point:"TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER", relativePoint:"TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER", size:number, iconID:number, talent:ERALIBTalent|nil)
---@field protected icon ERAPieIcon
HUDPieIcon = {}
HUDPieIcon.__index = HUDPieIcon
setmetatable(HUDPieIcon, { __index = HUDIcon })

function HUDPieIcon:constructPie(hud, frame, point, relativePoint, size, iconID, talent)
    self.icon = ERAPieIcon:create(frame, point, relativePoint, size, iconID)
    self:constructIcon(hud, self.icon, talent)
end

---comment
---@param r number
---@param g number
---@param b number
function HUDPieIcon:SetBorderColor(r, g, b)
    self.icon:SetBorderColor(r, g, b)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region COOLDOWN ICON ----------------------------------------
----------------------------------------------------------------

---@class (exact) HUDCooldownIcon : HUDPieIcon
---@field private __index HUDCooldownIcon
---@field private data HUDCooldown
---@field OverrideSecondaryText nil|fun(self:HUDCooldownIcon): string
---@field OverrideDesaturation nil|fun(self:HUDCooldownIcon): number
---@field watchIconChange boolean
---@field watchAdditionalOverlay number
HUDCooldownIcon = {}
HUDCooldownIcon.__index = HUDCooldownIcon
setmetatable(HUDCooldownIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param size number
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDCooldownIcon:Create(frame, point, relativePoint, size, data, iconID, talent)
    local x = {}
    setmetatable(x, HUDCooldownIcon)
    ---@cast x HUDCooldownIcon
    if (not iconID) then
        local info = C_Spell.GetSpellInfo(data.spellID)
        iconID = info.originalIconID
    end
    x:constructPie(data.hud, frame, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data

    return x
end

---comment
---@param t number
---@param combat boolean
function HUDCooldownIcon:Update(t, combat)
    if (combat) then
        self.icon:SetVisibilityAlpha(1.0, false)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        self.icon:SetVisibilityAlpha(self.data.swipeDuration:EvaluateRemainingDuration(self.hud.curveHideNoDuration), true)
    end
    self.icon:SetValue(self.data.swipeDuration:GetStartTime(), self.data.swipeDuration:GetTotalDuration())

    if (self.watchAdditionalOverlay) then
        self.icon:SetHighlight(C_SpellActivationOverlay.IsSpellOverlayed(self.data.spellID) or C_SpellActivationOverlay.IsSpellOverlayed(self.watchAdditionalOverlay))
    else
        self.icon:SetHighlight(C_SpellActivationOverlay.IsSpellOverlayed(self.data.spellID))
    end

    --self.icon:SetMainText(string.format("%i", self.data.swipeDuration:GetRemainingDuration()), true)

    if (self.OverrideSecondaryText) then
        self.icon:SetSecondaryText(self.OverrideSecondaryText(self), false)
    else
        if (self.data.hasCharges) then
            self.icon:SetSecondaryText(self.data.currentCharges, true)
        else
            self.icon:SetSecondaryText(nil, false)
        end
    end
    if (self.OverrideDesaturation) then
        self.icon:SetDesaturation(self:OverrideDesaturation(), true)
    else
        if (self.data.hasCharges) then
            ---@diagnostic disable-next-line: param-type-mismatch
            self.icon:SetDesaturation(self.data.cooldownDuration:EvaluateRemainingDuration(self.hud.curveFalse0), true)
        else
            self.icon:SetDesaturated(false)
        end
    end

    if (self.watchIconChange) then
        local info = C_Spell.GetSpellInfo(self.data.spellID)
        self.icon:SetIconTexture(info.iconID, false)
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region AURA ICON --------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDAuraIcon : HUDPieIcon
---@field private __index HUDAuraIcon
---@field private data HUDAura
---@field private stackMode boolean
---@field showRedIfMissingInCombat boolean
HUDAuraIcon = {}
HUDAuraIcon.__index = HUDAuraIcon
setmetatable(HUDAuraIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param size number
---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon
function HUDAuraIcon:Create(frame, point, relativePoint, size, data, iconID, talent)
    local x = {}
    setmetatable(x, HUDAuraIcon)
    ---@cast x HUDAuraIcon
    if (not iconID) then
        local info = C_Spell.GetSpellInfo(data.spellID)
        iconID = info.originalIconID
    end
    x:constructPie(data.hud, frame, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data
    x.icon:SetupAura()

    return x
end

function HUDAuraIcon:ShowStacksRatherThanDuration()
    self.icon:HideDefaultCountdown()
    self.stackMode = true
end

---comment
---@param t number
---@param combat boolean
function HUDAuraIcon:Update(t, combat)
    if (self.showRedIfMissingInCombat and combat) then
        local color = self.data.timerDuration:EvaluateRemainingDuration(self.hud.curveRedIf0)
        ---@diagnostic disable-next-line: undefined-field
        self.icon:SetTint(color.r, color.g, color.b, true)
        self.icon:SetVisibilityAlpha(1.0, false)
    else
        self.icon:SetTint(1.0, 1.0, 1.0, false)
        local alpha = self.data.timerDuration:EvaluateRemainingDuration(self.hud.curveFalse0)
        ---@cast alpha number
        self.icon:SetVisibilityAlpha(alpha, true)
    end
    if (self.stackMode) then
        self.icon:SetMainText(self.data.stacksDisplay, true)
    else
        self.icon:SetSecondaryText(self.data.stacksDisplay, true)
    end
    self.icon:SetValue(self.data.timerDuration:GetStartTime(), self.data.timerDuration:GetTotalDuration())
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region TIMER BAR --------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDTimerBar : HUDDisplay
---@field private __index HUDTimerBar
---@field private position number
---@field private timer HUDTimer
---@field private bar StatusBar
---@field doNotCutLongDuration boolean
HUDTimerBar = {}
HUDTimerBar.__index = HUDTimerBar
setmetatable(HUDTimerBar, { __index = HUDDisplay })

---@param placement HUDEssentialsPlacement
---@param position number
---@param timer HUDTimer
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@return HUDTimerBar
function HUDTimerBar:Create(placement, position, timer, talent, r, g, b)
    local x = {}
    setmetatable(x, HUDTimerBar)
    ---@cast x HUDTimerBar
    x:constructDisplay(placement.hud, talent)
    x.timer = timer
    x.position = position
    placement.hud:addTimerBar(x)
    placement:addBar(x)

    x.bar = CreateFrame("StatusBar", nil, placement.hud.timerFrameBack)
    x.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar-Glow")
    x.bar:SetRotatesTexture(true)
    x.bar:SetStatusBarColor(r, g, b, 1.0)
    x.bar:SetHeight(ERA_HUDModule_TimerHeight)
    x.bar:SetFrameLevel(2)
    x.bar:SetOrientation("VERTICAL")

    return x
end

function HUDTimerBar:Activate()
    self.bar:Show()
end

function HUDTimerBar:Deactivate()
    self.bar:Hide()
end

---comment
---@param xMid number
---@param iconWidth number
function HUDTimerBar:updateLayout(xMid, iconWidth)
    self.bar:SetWidth(self.hud.options.essentialsBarSize)
    self.bar:SetPoint("BOTTOM", self.hud.timerFrameBack, "BOTTOM", xMid + (self.position - 0.5) * iconWidth, 0)
end

---comment
---@param maxTimer number
function HUDTimerBar:updateMaxDuration(maxTimer)
    self.bar:SetMinMaxValues(0, maxTimer)
end

---comment
---@param t number
---@param combat boolean
function HUDTimerBar:Update(t, combat)
    if (combat) then
        if (self.doNotCutLongDuration) then
            self.bar:SetValue(self.timer.timerDuration:GetRemainingDuration())
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            self.bar:SetValue(self.timer.timerDuration:EvaluateRemainingDuration(self.hud.curveTimer))
        end
    end
end

--#endregion
----------------------------------------------------------------

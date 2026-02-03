----------------------------------------------------------------
--- ESSENTIALS PLACEMENT ---------------------------------------
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

----------------------------------------------------------------
--- GENERIC DISPLAY --------------------------------------------
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

----------------------------------------------------------------
--- RESOURCE ---------------------------------------------------
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

------------
-- HEALTH --
------------

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

-----------
-- POWER --
-----------

---@class (exact) HUDPowerBarDisplay : HUDResourceDisplay
---@field private __index HUDPowerBarDisplay
---@field protected data HUDPower
---@field protected bar ERAStatusBar
---@field private height number -- inherited
---@field protected displayTexts fun(self:HUDPowerBarDisplay)
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
    if (talent) then
        if (data.talent) then
            talent = ERALIBTalent:CreateAnd(talent, data.talent)
        end
    else
        talent = data.talent
    end
    self:constructResource(hud, true, talent)

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
    return self.height
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
end

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
    self.bar:SetMiddleText(string.format("%i", self.data.current), true)
end

----------------------------------------------------------------
--- GENERIC ICON -----------------------------------------------
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

----------------------------------------------------------------
--- PIE ICON ---------------------------------------------------
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

----------------------------------------------------------------
--- COOLDOWN ICON ----------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDCooldownIcon : HUDPieIcon
---@field private __index HUDCooldownIcon
---@field private cd HUDCooldown
HUDCooldownIcon = {}
HUDCooldownIcon.__index = HUDCooldownIcon
setmetatable(HUDCooldownIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param size number
---@param cd HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDCooldownIcon:Create(frame, point, relativePoint, size, cd, iconID, talent)
    local x = {}
    setmetatable(x, HUDCooldownIcon)
    ---@cast x HUDCooldownIcon
    if (not iconID) then
        local info = C_Spell.GetSpellInfo(cd.spellID)
        iconID = info.originalIconID
    end
    if (talent) then
        if (cd.talent) then
            talent = ERALIBTalent:CreateAnd(cd.talent, talent)
        end
    else
        talent = cd.talent
    end
    x:constructPie(cd.hud, frame, point, relativePoint, size, iconID, talent)
    x.cd = cd

    return x
end

---comment
---@param t number
---@param combat boolean
function HUDCooldownIcon:Update(t, combat)
    if (combat) then
        self.icon:SetVisibilityAlpha(1.0, false)
    else
        self.icon:SetVisibilityAlpha(self.cd.swipeDuration:EvaluateRemainingDuration(self.hud.curveHideNoDuration), true)
    end
    self.icon:SetValue(self.cd.swipeDuration:GetStartTime(), self.cd.swipeDuration:GetTotalDuration())
    self.icon:SetHighlight(C_SpellActivationOverlay.IsSpellOverlayed(self.cd.spellID))
end

----------------------------------------------------------------
--- TIMER BAR --------------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDTimerBar : HUDDisplay
---@field private __index HUDTimerBar
---@field private position number
---@field private timer HUDTimer
---@field private bar StatusBar
HUDTimerBar = {}
HUDTimerBar.__index = HUDTimerBar
setmetatable(HUDTimerBar, { __index = HUDDisplay })

---comment
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

    x.bar = CreateFrame("StatusBar", nil, placement.hud.timerFrame)
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
    self.bar:SetPoint("BOTTOM", self.hud.timerFrame, "BOTTOM", xMid + (self.position - 0.5) * iconWidth, 0)
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
        ---@diagnostic disable-next-line: missing-parameter
        self.bar:SetValue(self.timer.timerDuration:EvaluateRemainingDuration(self.hud.curveTimer))
    end
end

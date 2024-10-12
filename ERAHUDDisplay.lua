------------
--- BARS ---
------------

--#region BARS

---@class (exact) ERAHUDBar
---@field private __index unknown
---@field protected constructBar fun(this:ERAHUDBar, hud:ERAHUD, iconID:integer|nil, r:number, g:number, b:number, texture:string|integer|Texture, frameLevel:integer|nil)
---@field hud ERAHUD
---@field remDuration number
---@field private parentFrame Frame
---@field protected display StatusBar
---@field private iconID integer|nil
---@field private icon Texture
---@field private iconDesat boolean
---@field private iconAlpha number
---@field protected text FontString
---@field private textValue string|nil
---@field private r number
---@field private g number
---@field private b number
---@field private size number
---@field private y number
---@field private anim AnimationGroup
---@field private translation Translation
---@field private visible boolean
---@field private iconVisible boolean
---@field private endAnimate fun(this:ERAHUDBar)
---@field updateIconTexture fun(this:ERAHUDBar, iconID:integer|nil)
---@field protected checkTalentsOverride fun(this:ERAHUDBar): boolean
---@field protected computeDuration fun(this:ERAHUDBar, t:number)
---@field private hide fun(this:ERAHUDBar)
ERAHUDBar = {}
ERAHUDBar.__index = ERAHUDBar

--#region GENERIC BAR

---@param hud ERAHUD
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param texture string|integer|Texture
---@param frameLevel integer|nil
function ERAHUDBar:constructBar(hud, iconID, r, g, b, texture, frameLevel)
    self.hud = hud
    self.remDuration = 0
    self.parentFrame = hud:addBar(self)

    local bar = CreateFrame("StatusBar", nil, self.parentFrame, "ERAHUDTimerBar")
    local icon = bar.Icon
    local text = bar.Text
    local anim = bar.Anim
    local translation = anim.Translation
    ---@cast icon Texture
    ---@cast text FontString
    ---@cast anim AnimationGroup
    ---@cast translation Translation
    ---@cast bar StatusBar
    self.display = bar
    if frameLevel then
        self.display:SetFrameLevel(frameLevel)
    end
    self.anim = anim
    self.translation = translation
    local ea = self.endAnimate
    local this = self
    translation:SetScript(
        "OnFinished",
        function()
            ea(this)
        end
    )
    self.text = text
    self.textValue = nil
    self.icon = icon
    self.iconDesat = false
    self.iconAlpha = 1.0
    self.iconVisible = true
    self:updateIconTexture(iconID)
    self.y = 0
    self.size = 1
    self:SetSize(ERAHUD_TimerBarDefaultSize)
    self.r = r
    self.g = g
    self.b = b
    bar:SetStatusBarTexture(texture)
    bar:SetStatusBarColor(r, g, b, 1)
    bar:SetWidth(1.5 * ERAHUD_TimerWidth)
    self.visible = false
    bar:Hide()
end

---@param iconID integer|nil
function ERAHUDBar:updateIconTexture(iconID)
    if (self.iconID ~= iconID) then
        self.iconID = iconID
        self.icon:SetTexture(iconID)
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDBar:SetColor(r, g, b)
    if (self.r ~= r or self.g ~= g or self.b ~= b) then
        self.r = r
        self.g = g
        self.b = b
        self.display:SetStatusBarColor(r, g, b, 1)
    end
end

---@param desat boolean
function ERAHUDBar:SetIconDesaturated(desat)
    if (desat) then
        if (not self.iconDesat) then
            self.iconDesat = true
            self.icon:SetDesaturated(true)
        end
    else
        if (self.iconDesat) then
            self.iconDesat = false
            self.icon:SetDesaturated(false)
        end
    end
end

---@param alpha number
function ERAHUDBar:SetIconAlpha(alpha)
    if (self.iconAlpha ~= alpha) then
        self.iconAlpha = alpha
        self.icon:SetAlpha(alpha)
    end
end

---@param s number
function ERAHUDBar:SetSize(s)
    if s ~= self.size then
        self.size = s
        self.icon:SetSize(s, s)
        self.display:SetHeight(s)
        self.text:SetHeight(s)
        ERALIB_SetFont(self.text, s * 0.8)
    end
end

---@param txt string|nil
function ERAHUDBar:SetText(txt)
    if txt ~= self.textValue then
        self.textValue = txt
        self.text:SetText(txt)
    end
end

function ERAHUDBar:endAnimate()
    if (self.hud.topdown) then
        self.display:SetPoint("TOPRIGHT", self.parentFrame, "RIGHT", 0, self.y)
    else
        self.display:SetPoint("BOTTOMRIGHT", self.parentFrame, "RIGHT", 0, self.y)
    end
end

---@param y number
---@return number
function ERAHUDBar:draw(y)
    local max = self.hud.timerDuration
    local wasVisible = self.visible
    if (not self.visible) then
        self.visible = true
        self.display:Show()
    end
    self.display:SetMinMaxValues(0, 1.5 * max)
    if (self.remDuration > max) then
        self.display:SetValue(max * (1 + 0.5 * (1 - math.exp(-0.2 * (self.remDuration - max)))))
    else
        self.display:SetValue(self.remDuration)
    end
    if (wasVisible) then
        if (self.y ~= y) then
            self.translation:SetOffset(0, y - self.y)
            self.anim:Play()
        end
    else
        if (self.hud.topdown) then
            self.display:SetPoint("TOPRIGHT", self.parentFrame, "RIGHT", 0, y)
        else
            self.display:SetPoint("BOTTOMRIGHT", self.parentFrame, "RIGHT", 0, y)
        end
    end
    self.y = y
    return self.size
end

function ERAHUDBar:hide()
    if (self.visible) then
        self.visible = false
        self.display:Hide()
    end
end

---@param t number
---@return boolean
function ERAHUDBar:computeDurationAndHideIf0_return_visible(t)
    self.remDuration = self:computeDuration(t)
    if self.remDuration > 0 then
        return true
    else
        self:hide()
        return false
    end
end

function ERAHUDBar:checkTalentsOrHide()
    if self:checkTalentsOverride() then
        return true
    else
        self:hide()
        return false
    end
end

---@param b1 ERAHUDBar
---@param b2 ERAHUDBar
---@return boolean
function ERAHUDBar_compare(b1, b2)
    return b1.remDuration < b2.remDuration
end

---@class ERAHUDGenericBar : ERAHUDBar
---@field private __index unknown
---@field timer ERATimer
---@field talent ERALIBTalent|nil
---@field ConfirmDurationOverride nil|fun(this:ERAHUDGenericBar, t:number, duration:number): number
ERAHUDGenericBar = {}
ERAHUDGenericBar.__index = ERAHUDGenericBar
setmetatable(ERAHUDGenericBar, { __index = ERAHUDBar })

---@param timer ERATimer
---@param iconID integer
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDGenericBar
function ERAHUDGenericBar:create(timer, iconID, r, g, b, talent)
    local bar = {}
    setmetatable(bar, ERAHUDGenericBar)
    ---@cast bar ERAHUDGenericBar
    bar:constructBar(timer.hud, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    bar.timer = timer
    bar.talent = talent
    return bar
end

function ERAHUDGenericBar:checkTalentsOverride()
    return self.timer.talentActive and not (self.talent and not self.talent:PlayerHasTalent())
end

function ERAHUDGenericBar:computeDuration(t)
    local dur = self.timer.remDuration
    if self.ConfirmDurationOverride then
        dur = self:ConfirmDurationOverride(t, dur)
    end
    return dur
end

--#endregion

-----------------------
--- TARGET CAST BAR ---
-----------------------

--#region TARGET CAST BAR

---@class (exact) ERAHUDTargetCastBar : ERAHUDBar
---@field private __index unknown
---@field private computeDuration fun(this:ERAHUDSpellIDBar, t:number): number
---@field private kick_is_available boolean
---@field private kick_will_be_available boolean
ERAHUDTargetCastBar = {}
ERAHUDTargetCastBar.__index = ERAHUDTargetCastBar
setmetatable(ERAHUDTargetCastBar, { __index = ERAHUDBar })

---@param hud ERAHUD
---@return ERAHUDTargetCastBar
function ERAHUDTargetCastBar:create(hud)
    local x = {}
    setmetatable(x, ERAHUDTargetCastBar)
    ---@cast x ERAHUDTargetCastBar
    x:constructBar(hud, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleLegion", 3)
    ERALIB_SetFont(x.text, ERAHUD_TimerBarDefaultSize * 0.5)
    return x
end

function ERAHUDTargetCastBar:checkTalentsOverride()
    return true
end

function ERAHUDTargetCastBar:kickIsAvailable()
    self.kick_is_available = true
end
function ERAHUDTargetCastBar:kickWillBeAvailable()
    self.kick_will_be_available = true
end

---@param t number
---@return number
function ERAHUDTargetCastBar:computeDuration(t)
    if self.kick_is_available then
        self.kick_is_available = false
        self.kick_will_be_available = false
        self.display:SetStatusBarColor(1.0, 1.0, 1.0, 1.0)
        return self.hud.targetCast
    elseif self.kick_will_be_available then
        self.kick_will_be_available = false
        self.display:SetStatusBarColor(0.8, 0.0, 0.0, 1.0)
        return self.hud.targetCast
    else
        return 0
    end
end

--#endregion

---------------
--- LOC BAR ---
---------------

--#region LOC BAR

---@class (exact) ERAHUDLOCBar : ERAHUDBar
---@field private __index unknown
---@field private foundDuration number
---@field private computeDuration fun(this:ERAHUDSpellIDBar, t:number): number
---@field found fun(this:ERAHUDLOCBar, locTypeDescription:string|nil, remDuration:number, icon:integer|nil)
ERAHUDLOCBar = {}
ERAHUDLOCBar.__index = ERAHUDLOCBar
setmetatable(ERAHUDLOCBar, { __index = ERAHUDBar })

---@param hud ERAHUD
---@return ERAHUDLOCBar
function ERAHUDLOCBar:create(hud)
    local x = {}
    setmetatable(x, ERAHUDLOCBar)
    ---@cast x ERAHUDLOCBar
    x:constructBar(hud, nil, 1.0, 1.0, 1.0, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    x.foundDuration = -1
    return x
end

function ERAHUDLOCBar:checkTalentsOverride()
    return true
end

---@param locTypeDescription string|nil
---@param remDuration number
---@param icon integer|nil
function ERAHUDLOCBar:found(locTypeDescription, remDuration, icon)
    self:SetText(locTypeDescription)
    self.foundDuration = remDuration
end

---@param t number
---@return number
function ERAHUDLOCBar:computeDuration(t)
    if self.foundDuration > 0 then
        local result = self.foundDuration
        self.foundDuration = -1
        return result
    else
        return 0
    end
end

--#endregion

-------------------
--- SPELLID BAR ---
-------------------

--#region SPELLID BAR

---@class ERAHUDSpellIDBar : ERAHUDBar
---@field private __index unknown
---@field private talent ERALIBTalent|nil
---@field timer ERATimerWithID
---@field private computeDuration fun(this:ERAHUDSpellIDBar, t:number): number
---@field ComputeDurationOverride fun(this:ERAHUDSpellIDBar, t:number): number
ERAHUDSpellIDBar = {}
ERAHUDSpellIDBar.__index = ERAHUDSpellIDBar
setmetatable(ERAHUDSpellIDBar, { __index = ERAHUDBar })

---@param timer ERATimerWithID
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDSpellIDBar
function ERAHUDSpellIDBar:create(timer, iconID, r, g, b, talent)
    local x = {}
    setmetatable(x, ERAHUDSpellIDBar)
    ---@cast x ERAHUDSpellIDBar
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(timer.spellID)
        iconID = spellInfo.iconID
    end
    x:constructBar(timer.hud, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    x.talent = talent
    x.timer = timer
    return x
end

function ERAHUDSpellIDBar:checkTalentsOverride()
    if not self.timer.talentActive then
        return false
    end
    if self.talent and not self.talent:PlayerHasTalent() then
        return false
    else
        return true
    end
end

---@param t number
---@return number
function ERAHUDSpellIDBar:computeDuration(t)
    return self:ComputeDurationOverride(t)
end
---@param t number
---@return number
function ERAHUDSpellIDBar:ComputeDurationOverride(t)
    return self.timer.remDuration
end

---@class ERAHUDAuraBar : ERAHUDSpellIDBar
---@field private __index unknown
---@field aura ERAAura
---@field overrideShowStacks boolean
---@field private computeDuration fun(this:ERAHUDAuraBar, t:number): number
---@field ComputeDurationOverride fun(this:ERAHUDAuraBar, t:number): number
ERAHUDAuraBar = {}
ERAHUDAuraBar.__index = ERAHUDAuraBar
setmetatable(ERAHUDAuraBar, { __index = ERAHUDSpellIDBar })

---@param aura ERAAura
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDAuraBar
function ERAHUDAuraBar:create(aura, iconID, r, g, b, talent)
    local x = ERAHUDSpellIDBar:create(aura, iconID, r, g, b, talent)
    setmetatable(x, ERAHUDAuraBar)
    ---@cast x ERAHUDAuraBar
    x.aura = aura
    return x
end

---@param t number
---@return number
function ERAHUDAuraBar:computeDuration(t)
    if not self.overrideShowStacks then
        if self.aura.stacks > 1 then
            self:SetText(tostring(self.aura.stacks))
        else
            self:SetText(nil)
        end
    end
    return self:ComputeDurationOverride(t)
end

--#endregion

--#endregion BARS

------------------
--- TIMER ITEM ---
------------------

--#region TIMER ITEM

---@class (exact) ERAHUDTimerItem
---@field private __index unknown
---@field protected constructItem fun(this:ERAHUDTimerItem, hud:ERAHUD, iconID:integer, forcedIcon:boolean, talent:ERALIBTalent|nil)
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDTimerItem, t:number): number
---@field protected checkAdditionalTalent fun(this:ERAHUDTimerItem): boolean
---@field protected updateIconID fun(this:ERAHUDTimerItem, currentIconID:integer): integer
---@field protected overlayConstructed fun(this:ERAHUDTimerItem)
---@field ComputeDurationOverride fun(this:ERAHUDTimerItem, t:number): number
---@field private hide fun(this:ERAHUDTimerItem)
---@field hud ERAHUD
---@field icon ERASquareIcon
---@field pixel number
---@field priority number
---@field private line Line
---@field private lineVisible boolean
---@field private talent ERALIBTalent|nil
---@field private iconID integer
---@field private forcedIcon boolean
---@field preventVisible boolean
ERAHUDTimerItem = {}
ERAHUDTimerItem.__index = ERAHUDTimerItem

---@param hud ERAHUD
---@param iconID integer
---@param forcedIcon boolean
---@param talent ERALIBTalent|nil
function ERAHUDTimerItem:constructItem(hud, iconID, forcedIcon, talent)
    self.hud = hud
    self.talent = talent
    self.iconID = iconID
    self.forcedIcon = forcedIcon
    self.preventVisible = false
    hud:addTimerItem(self)
end

---@param frame Frame
function ERAHUDTimerItem:constructOverlay(frame)
    self.icon = ERASquareIcon:Create(frame, "RIGHT", ERAHUD_TimerIconSize, self.iconID)
    self.line = frame:CreateLine(nil, "OVERLAY", "ERAHUDVerticalTick")
    self.lineVisible = true
    self:hide()
    self:overlayConstructed()
end
function ERAHUDTimerItem:overlayConstructed()
end

function ERAHUDTimerItem:hide()
    if self.lineVisible then
        self.lineVisible = false
        self.line:Hide()
    end
    self.icon:Hide()
end

function ERAHUDTimerItem:checkTalentOrHide()
    if (self.talent and not self.talent:PlayerHasTalent()) or not self:checkAdditionalTalent() then
        self:hide()
        return false
    else
        if not self.forcedIcon then
            local i = self:updateIconID(self.iconID)
            if self.iconID ~= i then
                self.iconID = i
                self.icon:SetIconTexture(i, true)
            end
        end
        self.icon:Show()
        return true
    end
end
---@return boolean
function ERAHUDTimerItem:checkAdditionalTalent()
    return true
end

---@param currentIconID integer
---@return integer
function ERAHUDTimerItem:updateIconID(currentIconID)
    return currentIconID
end

---@param t number
function ERAHUDTimerItem:update(t)
    if self.preventVisible then
        self.pixel = 1
        self.priority = 0
        self:hide()
    else
        local duration = self:ComputeDurationOverride(t)
        if self.hud.timerDuration < duration or duration < 0 then
            self.pixel = 1
            self:hide()
            self.priority = 0
        elseif duration == 0 then
            self.pixel = 0
            if self.lineVisible then
                self.lineVisible = false
                self.line:Hide()
            end
            self.priority = self:ComputeAvailablePriorityOverride(t)
            if self.priority > 0 then
                self.icon:Show()
            else
                self.icon:Hide()
            end
        else
            self.pixel = self.hud:calcTimerPixel(duration)
            if not self.lineVisible then
                self.lineVisible = true
                self.line:Show()
            end
            self.icon:Show()
            self.priority = 0
        end
    end
end

---@param yBase number
---@param yMax number
---@param frame Frame
function ERAHUDTimerItem:drawOnTimer(yBase, yMax, frame)
    self.line:SetStartPoint("RIGHT", frame, self.pixel, yBase)
    self.line:SetEndPoint("RIGHT", frame, self.pixel, yMax)
    self.icon:Draw(self.pixel, yBase, false)
end

---@param y number
function ERAHUDTimerItem:drawPriority(y)
    self.icon:Draw(0, y, true)
end

---@param ti1 ERAHUDTimerItem
---@param ti2 ERAHUDTimerItem
---@return boolean
function ERAHUDTimerItem_comparePixel(ti1, ti2)
    return ti1.pixel < ti2.pixel
end

---@param ti1 ERAHUDTimerItem
---@param ti2 ERAHUDTimerItem
---@return boolean
function ERAHUDTimerItem_comparePriority(ti1, ti2)
    return ti1.priority < ti2.priority
end

---@class (exact) ERAHUDRawPriority : ERAHUDTimerItem
---@field ComputeDurationOverride fun(this:ERAHUDRawPriority, t:number): number
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDRawPriority, t:number): number
---@field private __index unknown
ERAHUDRawPriority = {}
ERAHUDRawPriority.__index = ERAHUDRawPriority
setmetatable(ERAHUDRawPriority, { __index = ERAHUDTimerItem })

---@param hud ERAHUD
---@param iconID integer
---@param talent ERALIBTalent|nil
function ERAHUDRawPriority:create(hud, iconID, talent)
    local p = {}
    setmetatable(p, ERAHUDRawPriority)
    ---@cast p ERAHUDRawPriority
    p:constructItem(hud, iconID, true, talent)
    return p
end

---@param t number
---@return number
function ERAHUDRawPriority:ComputeDurationOverride(t)
    return 0
end
---@param t number
---@return number
function ERAHUDRawPriority:ComputeAvailablePriorityOverride(t)
    return 0
end

---@class (exact) ERAHUDCooldownTimerItem : ERAHUDTimerItem
---@field private __index unknown
---@field cd ERACooldownBase
---@field ConfirmVisibleOverride nil|fun(cd:ERACooldownBase, t:number): boolean
ERAHUDCooldownTimerItem = {}
ERAHUDCooldownTimerItem.__index = ERAHUDCooldownTimerItem
setmetatable(ERAHUDCooldownTimerItem, { __index = ERAHUDTimerItem })

---@param cd ERACooldownBase
---@param iconID integer|nil
---@return ERAHUDCooldownTimerItem
function ERAHUDCooldownTimerItem:Create(cd, iconID)
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(cd.spellID)
        iconID = spellInfo.iconID
    end
    local x = {}
    setmetatable(x, ERAHUDCooldownTimerItem)
    ---@cast x ERAHUDCooldownTimerItem
    x:constructItem(cd.hud, iconID, forcedIcon, nil)
    x.cd = cd
    return x
end

---@return boolean
function ERAHUDCooldownTimerItem:checkAdditionalTalent()
    return self.cd.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDCooldownTimerItem:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.cd.spellID)
    return spellInfo.iconID
end

---@param t number
---@return number
function ERAHUDCooldownTimerItem:ComputeAvailablePriorityOverride(t)
    return 0
end

---@param t number
function ERAHUDCooldownTimerItem:ComputeDurationOverride(t)
    if self.ConfirmVisibleOverride and not self.ConfirmVisibleOverride(self.cd, t) then
        return -1
    end
    if self.cd.hasCharges then
        if self.cd.currentCharges > 0 then
            if self.cd.currentCharges + 1 >= self.cd.maxCharges then
                self.icon:SetDesaturated(false)
                return self.cd.remDuration
            else
                return -1
            end
        else
            self.icon:SetDesaturated(true)
            return self.cd.remDuration
        end
    else
        self.icon:SetDesaturated(false)
        return self.cd.remDuration
    end
end

--#endregion TIMER ITEM

-------------
--- ICONS ---
-------------

--#region ICONS

---@class (exact) ERAHUDIcon
---@field private __index unknown
---@field protected constructIcon fun(this:ERAHUDIcon, hud:ERAHUD, iconID:integer, forcedIcon:boolean, iconSize:number, frame:Frame, talent:ERALIBTalent|nil)
---@field protected checkIconTalent fun(this:ERAHUDIcon): boolean
---@field protected updateIconID fun(this:ERAHUDIcon, currentIconID:integer): integer
---@field protected refreshIconID fun(this:ERAHUDIcon)
---@field talent ERALIBTalent|nil
---@field talentActive boolean
---@field hud ERAHUD
---@field iconID integer
---@field icon ERAPieIcon
---@field forcedIcon boolean
ERAHUDIcon = {}
ERAHUDIcon.__index = ERAHUDIcon

---@param hud ERAHUD
---@param iconID integer
---@param forcedIcon boolean
---@param iconSize number
---@param frame Frame
---@param talent ERALIBTalent|nil
function ERAHUDIcon:constructIcon(hud, iconID, forcedIcon, iconSize, frame, talent)
    self.hud = hud
    self.talent = talent
    self.icon = ERAPieIcon:Create(frame, "CENTER", iconSize, iconID)
    self.iconID = iconID
    self.forcedIcon = forcedIcon
end

function ERAHUDIcon:checkTalentOrHide()
    if (self.talent and not self.talent:PlayerHasTalent()) or not self:checkIconTalent() then
        self.icon:Hide()
        self.talentActive = false
        return false
    else
        self:refreshIconID()
        --self.icon:Show()
        self.talentActive = true
        return true
    end
end
function ERAHUDIcon:refreshIconID()
    if not self.forcedIcon then
        local i = self:updateIconID(self.iconID)
        if self.iconID ~= i then
            self.iconID = i
            self.icon:SetIconTexture(i, true)
        end
    end
end

---@param currentIconID integer
---@return integer
function ERAHUDIcon:updateIconID(currentIconID)
    return currentIconID
end

---@param icon ERAPieIcon
---@param data ERACooldownBase
---@param currentCharges integer
---@param maxCharges integer
---@param remdurDesat number
---@param checkUsable boolean
---@param hideIfAvailable boolean
---@param forceHighlight boolean
---@param forceHighlightValue boolean
---@param t number
function ERAHUDIcon_updateStandard(icon, data, currentCharges, maxCharges, remdurDesat, checkUsable, hideIfAvailable, forceHighlight, forceHighlightValue, t)
    if data.isKnown then
        local available
        if data.hasCharges then
            local currentDisplayed = math.min(4, data.currentCharges)
            local maxDisplayed = math.min(5, data.maxCharges)
            currentCharges = math.min(4, currentCharges)
            maxCharges = math.min(5, maxCharges)
            if currentDisplayed ~= currentCharges or maxDisplayed ~= maxCharges then
                local txt = ""
                for i = 1, currentDisplayed do
                    txt = txt .. "¤"
                end
                for i = currentDisplayed + 1, maxDisplayed do
                    txt = txt .. "."
                end
                icon:SetSecondaryText(txt)
            end
            available = data.currentCharges >= data.maxCharges
            icon:SetDesaturated(data.currentCharges == 0 or (checkUsable and not C_Spell.IsSpellUsable(data.spellID)))
        else
            icon:SetSecondaryText(nil)
            icon:SetDesaturated(data.remDuration >= remdurDesat or (checkUsable and not C_Spell.IsSpellUsable(data.spellID)))
            available = data.remDuration <= 0
        end
        if available and hideIfAvailable then
            icon:Hide()
            icon:SetMainText(nil)
            icon:SetOverlayValue(0)
        else
            icon:SetOverlayValue(data.remDuration / data.totDuration)
            if data.remDuration > 0 then
                icon:SetMainText(tostring(math.floor(data.remDuration)))
            else
                icon:SetMainText(nil)
            end
            if forceHighlight then
                if forceHighlightValue then
                    icon:Highlight()
                else
                    icon:StopHighlight()
                end
            else
                if IsSpellOverlayed(data.spellID) then
                    icon:Highlight()
                else
                    icon:StopHighlight()
                end
            end
            icon:Show()
        end
    else
        icon:Hide()
    end
end

----------------
--- ROTATION ---
----------------

--#region ROTATION

---@class (exact) ERAHUDRotationIcon : ERAHUDIcon
---@field private __index unknown
---@field protected constructRotationIcon fun(this:ERAHUDIcon, hud:ERAHUD, iconID:integer, forcedIcon:boolean, talent:ERALIBTalent|nil)
---@field protected checkAdditionalTalent fun(this:ERAHUDRotationIcon): boolean
---@field update fun(this:ERAHUDRotationIcon, t:number, combat:boolean)
---@field specialPosition boolean
---@field overlapsPrevious ERAHUDRotationIcon|nil
ERAHUDRotationIcon = {}
ERAHUDRotationIcon.__index = ERAHUDRotationIcon
setmetatable(ERAHUDRotationIcon, { __index = ERAHUDIcon })

---@param hud ERAHUD
---@param iconID integer
---@param forcedIcon boolean
---@param talent ERALIBTalent|nil
function ERAHUDRotationIcon:constructRotationIcon(hud, iconID, forcedIcon, talent)
    local frame = hud:addRotation(self)
    self:constructIcon(hud, iconID, forcedIcon, ERAHUD_RotationIconSize, frame, talent)
    self.specialPosition = false
end

---@return boolean
function ERAHUDRotationIcon:checkIconTalent()
    return self:checkAdditionalTalent()
end
---@return boolean
function ERAHUDRotationIcon:checkAdditionalTalent()
    return true
end

----------------
--- COOLDOWN ---
----------------

--#region COOLDOWN

--#region BASE

---@class (exact) ERAHUDRotationCooldownIcon : ERAHUDRotationIcon
---@field private __index unknown
---@field private currentCharges integer
---@field private maxCharges integer
---@field data ERACooldownBase
---@field checkUsable boolean
---@field onTimer ERAHUDRotationCooldownIconPriority
---@field availableChargePriority ERAHUDRotationCooldownIconChargedPriority
---@field HighlightOverride fun(this:ERAHUDRotationCooldownIcon, t:number, combat:boolean): boolean
---@field UpdatedOverride fun(this:ERAHUDRotationCooldownIcon, t:number, combat:boolean)
ERAHUDRotationCooldownIcon = {}
ERAHUDRotationCooldownIcon.__index = ERAHUDRotationCooldownIcon
setmetatable(ERAHUDRotationCooldownIcon, { __index = ERAHUDRotationIcon })

---@param data ERACooldownBase
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationCooldownIcon
function ERAHUDRotationCooldownIcon:create(data, iconID, talent)
    local cd = {}
    setmetatable(cd, ERAHUDRotationCooldownIcon)
    ---@cast cd ERAHUDRotationCooldownIcon
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    cd:constructRotationIcon(data.hud, iconID, forcedIcon, talent)
    cd.data = data
    cd.currentCharges = -1
    cd.maxCharges = -1
    cd.onTimer = ERAHUDRotationCooldownIconPriority:create(cd)
    cd.availableChargePriority = ERAHUDRotationCooldownIconChargedPriority:create(cd)
    return cd
end

---@return boolean
function ERAHUDRotationCooldownIcon:checkAdditionalTalent()
    return self.data.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDRotationCooldownIcon:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.data.spellID)
    return spellInfo.iconID
end

---@param combat boolean
---@param t number
function ERAHUDRotationCooldownIcon:update(t, combat)
    local forceHighlight
    local forceHighlightValue = false
    if self.HighlightOverride then
        forceHighlight = true
        forceHighlightValue = self:HighlightOverride(t, combat)
    else
        forceHighlight = false
        forceHighlightValue = false
    end
    ERAHUDIcon_updateStandard(self.icon, self.data, self.currentCharges, self.maxCharges, 1004, self.checkUsable, not combat, forceHighlight, forceHighlightValue, t)
    self.currentCharges = self.data.currentCharges
    self.maxCharges = self.data.maxCharges
    if self.data.isKnown then
        self:UpdatedOverride(t, combat)
    end
end
---@param t number
---@param combat boolean
function ERAHUDRotationCooldownIcon:UpdatedOverride(t, combat)
end

---@class (exact) ERAHUDRotationCooldownTimerItem : ERAHUDTimerItem
---@field private __index unknown
---@field cd ERAHUDRotationCooldownIcon
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDRotationCooldownTimerItem, t:number): number
ERAHUDRotationCooldownTimerItem = {}
ERAHUDRotationCooldownTimerItem.__index = ERAHUDRotationCooldownTimerItem
setmetatable(ERAHUDRotationCooldownTimerItem, { __index = ERAHUDTimerItem })

---@param cd ERAHUDRotationCooldownIcon
function ERAHUDRotationCooldownTimerItem:constructCooldown(cd)
    self:constructItem(cd.hud, cd.iconID, cd.forcedIcon, cd.talent)
    self.cd = cd
end

---@return boolean
function ERAHUDRotationCooldownTimerItem:checkAdditionalTalent()
    return self.cd.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDRotationCooldownTimerItem:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.cd.data.spellID)
    return spellInfo.iconID
end

---@param t number
---@return number
function ERAHUDRotationCooldownTimerItem:ComputeAvailablePriorityOverride(t)
    return 0
end

---@class (exact) ERAHUDRotationCooldownIconPriority : ERAHUDRotationCooldownTimerItem
---@field private __index unknown
---@field ComputeDurationOverride fun(this:ERAHUDRotationCooldownIconPriority, t:number): number
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDRotationCooldownIconPriority, t:number): number
ERAHUDRotationCooldownIconPriority = {}
ERAHUDRotationCooldownIconPriority.__index = ERAHUDRotationCooldownIconPriority
setmetatable(ERAHUDRotationCooldownIconPriority, { __index = ERAHUDRotationCooldownTimerItem })

---@param cd ERAHUDRotationCooldownIcon
---@return ERAHUDRotationCooldownIconPriority
function ERAHUDRotationCooldownIconPriority:create(cd)
    local p = {}
    setmetatable(p, ERAHUDRotationCooldownIconPriority)
    ---@cast p ERAHUDRotationCooldownIconPriority
    p:constructCooldown(cd)
    return p
end

---@param t number
function ERAHUDRotationCooldownIconPriority:ComputeDurationOverride(t)
    if self.cd.data.hasCharges then
        if self.cd.data.currentCharges > 0 then
            self.icon:SetDesaturated(false)
            if self.cd.data.currentCharges >= self.cd.data.maxCharges then
                return 0
            elseif self.cd.data.currentCharges + 1 == self.cd.data.maxCharges and self.cd.data.remDuration > 0 then
                return self.cd.data.remDuration
            else
                return -1
            end
        else
            self.icon:SetDesaturated(true)
            return self.cd.data.remDuration
        end
    else
        self.icon:SetDesaturated(false)
        return self.cd.data.remDuration
    end
end

---@class (exact) ERAHUDRotationCooldownIconChargedPriority : ERAHUDRotationCooldownTimerItem
---@field private __index unknown
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDRotationCooldownIconChargedPriority, t:number): number
ERAHUDRotationCooldownIconChargedPriority = {}
ERAHUDRotationCooldownIconChargedPriority.__index = ERAHUDRotationCooldownIconChargedPriority
setmetatable(ERAHUDRotationCooldownIconChargedPriority, { __index = ERAHUDRotationCooldownTimerItem })

---@param cd ERAHUDRotationCooldownIcon
---@return ERAHUDRotationCooldownIconChargedPriority
function ERAHUDRotationCooldownIconChargedPriority:create(cd)
    local p = {}
    setmetatable(p, ERAHUDRotationCooldownIconChargedPriority)
    ---@cast p ERAHUDRotationCooldownIconChargedPriority
    p:constructCooldown(cd)
    return p
end

function ERAHUDRotationCooldownIconChargedPriority:overlayConstructed()
    self.icon:SetDesaturated(true)
end

---@param t number
function ERAHUDRotationCooldownIconChargedPriority:ComputeDurationOverride(t)
    if self.cd.data.hasCharges then
        if self.cd.data.currentCharges > 0 and self.cd.data.currentCharges < self.cd.data.maxCharges then
            return 0
        else
            return -1
        end
    else
        return -1
    end
end

---@param t number
---@return number
function ERAHUDRotationCooldownIconChargedPriority:ComputeAvailablePriorityOverride(t)
    return self.cd.onTimer:ComputeAvailablePriorityOverride(t)
end

--#endregion

--#region DISPELL

---@class (exact) ERAHUDRotationOffensiveDispellIcon : ERAHUDRotationCooldownIcon
---@field private __index unknown
---@field private magic boolean
---@field private enrage boolean
ERAHUDRotationOffensiveDispellIcon = {}
ERAHUDRotationOffensiveDispellIcon.__index = ERAHUDRotationOffensiveDispellIcon
setmetatable(ERAHUDRotationOffensiveDispellIcon, { __index = ERAHUDRotationCooldownIcon })

---@param data ERACooldownBase
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param enrage boolean
---@return ERAHUDRotationOffensiveDispellIcon
function ERAHUDRotationOffensiveDispellIcon:create(data, iconID, talent, magic, enrage)
    local cd = ERAHUDRotationCooldownIcon:create(data, iconID, talent)
    setmetatable(cd, ERAHUDRotationOffensiveDispellIcon)
    ---@cast cd ERAHUDRotationOffensiveDispellIcon
    cd.specialPosition = true
    cd.magic = magic
    cd.enrage = enrage
    return cd
end

---@param combat boolean
---@param t number
function ERAHUDRotationOffensiveDispellIcon:UpdatedOverride(t, combat)
    if
        (self.magic and self.hud.targetDispellableMagic)
        or
        (self.enrage and self.hud.targetDispellableEnrage)
    then
        if self.data.remDuration > 0 then
            self.icon:StopHighlight()
        else
            self.icon:Highlight()
        end
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

--#endregion

--#region KICK

---@class (exact) ERAHUDRotationKickIcon : ERAHUDRotationCooldownIcon
---@field private __index unknown
ERAHUDRotationKickIcon = {}
ERAHUDRotationKickIcon.__index = ERAHUDRotationKickIcon
setmetatable(ERAHUDRotationKickIcon, { __index = ERAHUDRotationCooldownIcon })

---@param data ERACooldownBase
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationKickIcon
function ERAHUDRotationKickIcon:create(data, iconID, talent)
    local cd = ERAHUDRotationCooldownIcon:create(data, iconID, talent)
    setmetatable(cd, ERAHUDRotationKickIcon)
    ---@cast cd ERAHUDRotationKickIcon
    cd.specialPosition = true
    return cd
end

---@param combat boolean
---@param t number
function ERAHUDRotationKickIcon:UpdatedOverride(t, combat)
    if self.hud.targetCast > self.data.remDuration then
        if self.data.remDuration <= 0 then
            self.hud.targetCastBar:kickIsAvailable()
        else
            self.hud.targetCastBar:kickWillBeAvailable()
        end
        self.icon:SetAlpha(1.0)
        self.icon:Show()
        self.onTimer.preventVisible = false
        self.availableChargePriority.preventVisible = false
    elseif self.data.remDuration > 0 then
        self.icon:SetAlpha(0.5)
        self.icon:Show()
        self.onTimer.preventVisible = true
        self.availableChargePriority.preventVisible = true
    else
        self.icon:Hide()
        self.onTimer.preventVisible = true
        self.availableChargePriority.preventVisible = true
    end
end

--#endregion

--#endregion

-------------
--- AURAS ---
-------------

--#region AURAS

------------
--- AURA ---
------------

---@class (exact) ERAHUDRotationAuraIcon : ERAHUDRotationIcon
---@field private __index unknown
---@field data ERAAura
---@field private currentStacks integer
---@field ShowWhenMissing fun(this:ERAHUDRotationAuraIcon, t:number, combat:boolean): boolean
---@field ShowOutOfCombat fun(this:ERAHUDRotationAuraIcon, t:number): boolean
ERAHUDRotationAuraIcon = {}
ERAHUDRotationAuraIcon.__index = ERAHUDRotationAuraIcon
setmetatable(ERAHUDRotationAuraIcon, { __index = ERAHUDRotationIcon })

---@param data ERAAura
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationAuraIcon
function ERAHUDRotationAuraIcon:create(data, iconID, talent)
    local buff = {}
    setmetatable(buff, ERAHUDRotationAuraIcon)
    ---@cast buff ERAHUDRotationAuraIcon
    buff.data = data
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    buff:constructRotationIcon(data.hud, iconID, forcedIcon, talent)
    buff.currentStacks = -1
    return buff
end

---@return boolean
function ERAHUDRotationAuraIcon:checkAdditionalTalent()
    return self.data.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDRotationAuraIcon:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.data.spellID)
    return spellInfo.iconID
end

---@param combat boolean
---@param t number
function ERAHUDRotationAuraIcon:update(t, combat)
    if self.data.stacks > 0 then
        if combat or self:ShowOutOfCombat(t) then
            if self.currentStacks ~= self.data.stacks then
                self.currentStacks = self.data.stacks
                self.icon:SetDesaturated(false)
                if self.currentStacks == 1 then
                    self.icon:SetMainText(nil)
                else
                    self.icon:SetMainTextColor(1.0, 1.0, 1.0, 1.0)
                    self.icon:SetMainText(tostring(self.currentStacks))
                end
            end
            self.icon:SetOverlayValue((self.data.totDuration - self.data.remDuration) / self.data.totDuration)
            self.icon:Show()
        else
            self.icon:Hide()
        end
    else
        if self:ShowWhenMissing(t, combat) then
            if self.currentStacks ~= 0 then
                self.icon:SetDesaturated(true)
                self.icon:SetOverlayValue(0)
                self.icon:SetMainText("X")
                self.icon:SetMainTextColor(1.0, 0.0, 0.0, 1.0)
                self.currentStacks = 0
            end
            self.icon:Show()
        else
            self.icon:Hide()
        end
    end
end
---@param t number
---@param combat boolean
---@return boolean
function ERAHUDRotationAuraIcon:ShowWhenMissing(t, combat)
    return combat
end
---@param t number
---@return boolean
function ERAHUDRotationAuraIcon:ShowOutOfCombat(t)
    return true
end

--------------
--- STACKS ---
--------------

---@class (exact) ERAHUDRotationStacksIcon : ERAHUDRotationIcon
---@field private __index unknown
---@field data ERAStacks
---@field maxStacks integer
---@field highlightAt integer
---@field soundOnHighlight number
---@field minStacksToShowOutOfCombat integer
---@field ShowCombatMissing fun(this:ERAHUDRotationStacksIcon, t): boolean
---@field private currentStacks integer
ERAHUDRotationStacksIcon = {}
ERAHUDRotationStacksIcon.__index = ERAHUDRotationStacksIcon
setmetatable(ERAHUDRotationStacksIcon, { __index = ERAHUDRotationIcon })

---@param data ERAStacks
---@param maxStacks integer
---@param highlightAt integer
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationStacksIcon
function ERAHUDRotationStacksIcon:create(data, maxStacks, highlightAt, iconID, talent)
    local buff = {}
    setmetatable(buff, ERAHUDRotationStacksIcon)
    ---@cast buff ERAHUDRotationStacksIcon
    buff.data = data
    buff.maxStacks = maxStacks
    buff.highlightAt = highlightAt
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    buff:constructRotationIcon(data.hud, iconID, forcedIcon, talent)
    buff.currentStacks = -1
    buff.minStacksToShowOutOfCombat = 1
    return buff
end

---@return boolean
function ERAHUDRotationStacksIcon:checkAdditionalTalent()
    return self.data.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDRotationStacksIcon:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.data.spellID)
    return spellInfo.iconID
end

---@param combat boolean
---@param t number
function ERAHUDRotationStacksIcon:update(t, combat)
    if self.data.stacks > 0 then
        if self.data.stacks < self.minStacksToShowOutOfCombat and not combat then
            self.icon:Hide()
            return
        end
        if self.currentStacks ~= self.data.stacks then
            self.currentStacks = self.data.stacks
            self.icon:SetDesaturated(false)
            self.icon:SetMainTextColor(1.0, 1.0, 1.0, 1.0)
            self.icon:SetMainText(tostring(self.currentStacks))
            self.icon:SetOverlayValue((self.maxStacks - self.currentStacks) / self.maxStacks)
        end
        if combat and self.currentStacks >= self.highlightAt then
            if self.soundOnHighlight and self.soundOnHighlight > 0 then
                self.icon:Highlight(self.soundOnHighlight);
            else
                self.icon:Highlight();
            end
        else
            self.icon:StopHighlight();
        end
        self.icon:Show()
    else
        if combat and self:ShowCombatMissing(t) then
            if self.currentStacks ~= 0 then
                self.icon:SetMainTextColor(1.0, 0.0, 0.0, 1.0)
                self.icon:SetMainText("X")
                self.icon:SetDesaturated(true)
            end
            self.icon:Show()
        else
            self.icon:Hide()
        end
        self.currentStacks = 0
    end
end
function ERAHUDRotationStacksIcon:ShowCombatMissing(t)
    return false
end

--#endregion

--#endregion ROTATION

---------------
--- UTILITY ---
---------------

--#region UTILITY

---@class (exact) ERAHUDUtilityIcon : ERAHUDIcon
---@field private __index unknown
---@field protected constructUtilityIcon fun(this:ERAHUDUtilityIcon, hud:ERAHUD, iconID:integer, forcedIcon:boolean, talent:ERALIBTalent|nil)
---@field protected checkAdditionalTalent fun(this:ERAHUDUtilityIcon): boolean
---@field update fun(this:ERAHUDUtilityIcon, t:number, combat:boolean)
ERAHUDUtilityIcon = {}
ERAHUDUtilityIcon.__index = ERAHUDUtilityIcon
setmetatable(ERAHUDUtilityIcon, { __index = ERAHUDIcon })

---@param hud ERAHUD
---@param iconID integer
---@param forcedIcon boolean
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIcon:constructUtilityIcon(hud, iconID, forcedIcon, talent)
    local parentFrame = hud:addUtilityIcon(self)
    self:constructIcon(hud, iconID, forcedIcon, ERAHUD_UtilityIconSize, parentFrame, talent)
end

---@return boolean
function ERAHUDUtilityIcon:checkIconTalent()
    return self.hud.showUtility and self:checkAdditionalTalent()
end
---@return boolean
function ERAHUDUtilityIcon:checkAdditionalTalent()
    return true
end

--#region IN GROUP

---@class (exact) ERAHUDUtilityIconInGroup : ERAHUDUtilityIcon
---@field private __index unknown
---@field protected constructUtilityIconInGroup fun(this:ERAHUDIcon, group:ERAHUDUtilityGroup, iconID:integer, forcedIcon:boolean, displayOrder:number|nil, talent:ERALIBTalent|nil)
---@field update fun(this:ERAHUDUtilityIconInGroup, t:number, combat:boolean)
---@field private group ERAHUDUtilityGroup
---@field displayOrder number
ERAHUDUtilityIconInGroup = {}
ERAHUDUtilityIconInGroup.__index = ERAHUDUtilityIconInGroup
setmetatable(ERAHUDUtilityIconInGroup, { __index = ERAHUDUtilityIcon })

---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param forcedIcon boolean
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIconInGroup:constructUtilityIconInGroup(group, iconID, forcedIcon, displayOrder, talent)
    self:constructUtilityIcon(group.hud, iconID, forcedIcon, talent)
    self.displayOrder = group:addIcon(self, displayOrder)
    self.group = group
end

---@param i1 ERAHUDUtilityIconInGroup
---@param i2 ERAHUDUtilityIconInGroup
---@return boolean
function ERAHUDUtilityIconInGroup_compareDisplayOrder(i1, i2)
    return i1.displayOrder < i2.displayOrder
end

--#region GENERIC

---@class ERAHUDUtilityGenericTimerInGroup : ERAHUDUtilityIconInGroup
---@field private __index unknown
---@field timer ERATimer
---@field private timerActive boolean
---@field protected timerActive_returnIconID fun(this:ERAHUDUtilityGenericTimerInGroup): integer
---@field protected SetIconVisibilityOverride fun(this:ERAHUDUtilityGenericTimerInGroup, t:number, combat:boolean)
ERAHUDUtilityGenericTimerInGroup = {}
ERAHUDUtilityGenericTimerInGroup.__index = ERAHUDUtilityGenericTimerInGroup
setmetatable(ERAHUDUtilityGenericTimerInGroup, { __index = ERAHUDUtilityIconInGroup })

---@param group ERAHUDUtilityGroup
---@param timer ERATimer
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityGenericTimerInGroup
function ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, talent)
    local g = {}
    setmetatable(g, ERAHUDUtilityGenericTimerInGroup)
    ---@cast g ERAHUDUtilityGenericTimerInGroup
    g:constructUtilityIconInGroup(group, iconID, true, displayOrder, talent)
    g.timer = timer
    g.timerActive = false
    return g
end

---@return boolean
function ERAHUDUtilityGenericTimerInGroup:checkAdditionalTalent()
    return self.timer.talentActive
end

---@param combat boolean
---@param t number
function ERAHUDUtilityGenericTimerInGroup:update(t, combat)
    if self.timer.talentActive then
        if not self.timerActive then
            self.timerActive = true
            local iconID = self:timerActive_returnIconID()
            if iconID ~= self.iconID then
                self.iconID = iconID
                self.icon:SetIconTexture(iconID, true)
            end
            self.hud:mustUpdateUtilityLayout()
        end
        self.icon:SetOverlayValue(self.timer.remDuration / self.timer.totDuration)
        if self.timer.remDuration <= 0 then
            self.icon:SetMainText(nil)
        else
            self.icon:SetMainText(tostring(math.floor(self.timer.remDuration)))
        end
        self:SetIconVisibilityOverride(t, combat)
    else
        if self.timerActive then
            self.icon:SetOverlayValue(0)
            self.icon:SetMainText(nil)
            self.timerActive = false
            self.icon:Hide()
            self.hud:mustUpdateUtilityLayout()
        end
    end
end
---@return integer
function ERAHUDUtilityGenericTimerInGroup:timerActive_returnIconID()
    return self.iconID
end
---@param combat boolean
---@param t number
function ERAHUDUtilityGenericTimerInGroup:SetIconVisibilityOverride(t, combat)
    if self.timer.remDuration <= 0 and not combat then
        self.icon:Hide()
    else
        self.icon:Show()
    end
end

--#endregion

----------------
--- COOLDOWN ---
----------------

---@class (exact) ERAHUDUtilityCooldownInGroup : ERAHUDUtilityIconInGroup
---@field private __index unknown
---@field update fun(this:ERAHUDUtilityCooldownInGroup, t:number, combat:boolean)
---@field HighlightOverride fun(this:ERAHUDUtilityCooldownInGroup, t:number, combat:boolean): boolean
---@field UpdatedOverride fun(this:ERAHUDUtilityCooldownInGroup, t:number, combat:boolean)
---@field data ERACooldownBase
---@field ConfirmShowOverride nil|fun(this:ERAHUDUtilityCooldownInGroup): boolean
---@field private currentCharges integer
---@field private maxCharges integer
ERAHUDUtilityCooldownInGroup = {}
ERAHUDUtilityCooldownInGroup.__index = ERAHUDUtilityCooldownInGroup
setmetatable(ERAHUDUtilityCooldownInGroup, { __index = ERAHUDUtilityIconInGroup })

---@param group ERAHUDUtilityGroup
---@param data ERACooldownBase
---@param iconID integer|nil
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@param showOnTimer boolean|nil|fun(cd:ERACooldownBase, t:number): boolean
function ERAHUDUtilityCooldownInGroup:create(group, data, iconID, displayOrder, talent, showOnTimer)
    local cd = {}
    setmetatable(cd, ERAHUDUtilityCooldownInGroup)
    ---@cast cd ERAHUDUtilityCooldownInGroup
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    cd:constructUtilityIconInGroup(group, iconID, forcedIcon, displayOrder, talent)
    cd.data = data
    cd.currentCharges = -1
    cd.maxCharges = -1
    if showOnTimer then
        local onTimer = ERAHUDCooldownTimerItem:Create(data, iconID)
        if showOnTimer ~= true then
            onTimer.ConfirmVisibleOverride = showOnTimer
        end
    end
    return cd
end

---@return boolean
function ERAHUDUtilityCooldownInGroup:checkAdditionalTalent()
    return self.data.talentActive and self.data.isKnown and ((not self.ConfirmShowOverride) or self:ConfirmShowOverride())
end

---@param currentIconID integer
---@return integer
function ERAHUDUtilityCooldownInGroup:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.data.spellID)
    return spellInfo.iconID
end

---@param combat boolean
---@param t number
function ERAHUDUtilityCooldownInGroup:update(t, combat)
    if self.ConfirmShowOverride and not self:ConfirmShowOverride() then
        self.hud:mustUpdateUtilityLayout()
        return
    end
    local forceHighlight
    local forceHighlightValue = false
    if self.HighlightOverride then
        forceHighlight = true
        forceHighlightValue = self:HighlightOverride(t, combat)
    else
        forceHighlight = false
        forceHighlightValue = false
    end
    ERAHUDIcon_updateStandard(self.icon, self.data, self.currentCharges, self.maxCharges, 30, false, not combat, forceHighlight, forceHighlightValue, t)
    self.currentCharges = self.data.currentCharges
    self.maxCharges = self.data.maxCharges
    self:UpdatedOverride(t, combat)
end
---@param combat boolean
---@param t number
function ERAHUDUtilityCooldownInGroup:UpdatedOverride(t, combat)
end

---------------
--- SPECIAL ---
---------------

--#region DISPELL

---@class (exact) ERAHUDUtilityDispellInGroup : ERAHUDUtilityCooldownInGroup
---@field private __index unknown
---@field private UpdatedOverride fun(this:ERAHUDUtilityDispellInGroup, t:number, combat:boolean)
---@field private magic boolean
---@field private disease boolean
---@field private poison boolean
---@field private curse boolean
---@field private bleed boolean
---@field alwaysShow boolean
ERAHUDUtilityDispellInGroup = {}
ERAHUDUtilityDispellInGroup.__index = ERAHUDUtilityDispellInGroup
setmetatable(ERAHUDUtilityDispellInGroup, { __index = ERAHUDUtilityCooldownInGroup })

---@param group ERAHUDUtilityGroup
---@param data ERACooldownBase
---@param iconID integer|nil
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param poison boolean
---@param disease boolean
---@param curse boolean
---@param bleed boolean
---@return ERAHUDUtilityDispellInGroup
function ERAHUDUtilityDispellInGroup:create(group, data, iconID, displayOrder, talent, magic, poison, disease, curse, bleed)
    local cd = ERAHUDUtilityCooldownInGroup:create(group, data, iconID, displayOrder, talent)
    setmetatable(cd, ERAHUDUtilityDispellInGroup)
    ---@cast cd ERAHUDUtilityDispellInGroup
    cd.magic = magic
    cd.poison = poison
    cd.disease = disease
    cd.curse = curse
    cd.bleed = bleed
    return cd
end

---@param combat boolean
---@param t number
function ERAHUDUtilityDispellInGroup:UpdatedOverride(t, combat)
    if
        (self.hud.selfDispellableMagic and self.magic)
        or
        (self.hud.selfDispellablePoison and self.poison)
        or
        (self.hud.selfDispellableDisease and self.disease)
        or
        (self.hud.selfDispellableCurse and self.curse)
        or
        (self.hud.selfDispellableBleed and self.bleed)
    then
        if self.data.remDuration > 0 then
            self.icon:StopBeam()
        else
            self.icon:Beam()
        end
        self.icon:Show()
    else
        if self.data.remDuration > 0 then
            self.icon:StopBeam()
        else
            if self.alwaysShow then
                self.icon:StopBeam()
            else
                self.icon:Hide()
            end
        end
    end
end

--#endregion

--#region EQUIPMENT

---@class ERAHUDUtilityEquipmentInGroup : ERAHUDUtilityGenericTimerInGroup
---@field private __index unknown
---@field private equipment ERACooldownEquipment
---@field private lastUpdateEquipmentIcon number
ERAHUDUtilityEquipmentInGroup = {}
ERAHUDUtilityEquipmentInGroup.__index = ERAHUDUtilityEquipmentInGroup
setmetatable(ERAHUDUtilityEquipmentInGroup, { __index = ERAHUDUtilityGenericTimerInGroup })

---@param group ERAHUDUtilityGroup
---@param timer ERACooldownEquipment
---@param iconID integer
---@param displayOrder number|nil
---@param showOnTimer boolean
---@return ERAHUDUtilityEquipmentInGroup
function ERAHUDUtilityEquipmentInGroup:create(group, timer, iconID, displayOrder, showOnTimer)
    local c = ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, nil)
    setmetatable(c, ERAHUDUtilityEquipmentInGroup)
    ---@cast c ERAHUDUtilityEquipmentInGroup
    c.equipment = timer
    c.lastUpdateEquipmentIcon = 0
    if showOnTimer then
        ERAHUDEquipmentCooldownTimerItem:Create(timer, iconID)
    end
    return c
end

---@return integer
function ERAHUDUtilityEquipmentInGroup:timerActive_returnIconID()
    local fileID = GetInventoryItemTexture("player", self.equipment.slotID)
    if fileID then
        return fileID
    else
        return self.iconID
    end
end

---@param currentIconID integer
---@return integer
function ERAHUDUtilityEquipmentInGroup:updateIconID(currentIconID)
    return self:timerActive_returnIconID()
end

---@param combat boolean
---@param t number
function ERAHUDUtilityEquipmentInGroup:SetIconVisibilityOverride(t, combat)
    if self.timer.remDuration <= 0 and not combat then
        self.icon:Hide()
    else
        self.icon:Show()
    end
    if t - self.lastUpdateEquipmentIcon > 5 then
        self.lastUpdateEquipmentIcon = t
        self:refreshIconID()
    end
end

---@class (exact) ERAHUDEquipmentCooldownTimerItem : ERAHUDTimerItem
---@field private __index unknown
---@field cd ERACooldownEquipment
---@field private getEqTimIconID fun(this:ERAHUDEquipmentCooldownTimerItem): integer|nil
---@field private lastUpdateIcon number
ERAHUDEquipmentCooldownTimerItem = {}
ERAHUDEquipmentCooldownTimerItem.__index = ERAHUDEquipmentCooldownTimerItem
setmetatable(ERAHUDEquipmentCooldownTimerItem, { __index = ERAHUDTimerItem })

---@param cd ERACooldownEquipment
---@param iconID integer
---@return ERAHUDEquipmentCooldownTimerItem
function ERAHUDEquipmentCooldownTimerItem:Create(cd, iconID)
    local x = {}
    setmetatable(x, ERAHUDEquipmentCooldownTimerItem)
    ---@cast x ERAHUDEquipmentCooldownTimerItem
    x:constructItem(cd.hud, iconID, false, nil)
    x.cd = cd
    x.lastUpdateIcon = 0
    return x
end

---@return boolean
function ERAHUDEquipmentCooldownTimerItem:checkAdditionalTalent()
    return true
end

function ERAHUDEquipmentCooldownTimerItem:getEqTimIconID()
    return GetInventoryItemTexture("player", self.cd.slotID)
end

---@param currentIconID integer
---@return integer
function ERAHUDEquipmentCooldownTimerItem:updateIconID(currentIconID)
    local fileID = self:getEqTimIconID()
    if fileID then
        return fileID
    else
        return currentIconID
    end
end

---@param t number
---@return number
function ERAHUDEquipmentCooldownTimerItem:ComputeAvailablePriorityOverride(t)
    return 0
end

---@param t number
function ERAHUDEquipmentCooldownTimerItem:ComputeDurationOverride(t)
    if not self.cd.hasCooldown then return -1 end
    if t - self.lastUpdateIcon > 4 then
        self.lastUpdateIcon = t
        local fileID = self:getEqTimIconID()
        if fileID then
            self.icon:SetIconTexture(fileID)
        end
    end
    return self.cd.remDuration
end

--#endregion

--#region BAG ITEM

---@class ERAHUDUtilityBagItemInGroup : ERAHUDUtilityGenericTimerInGroup
---@field private __index unknown
---@field private bagItem ERACooldownBagItem
---@field private warningIfMissing boolean
ERAHUDUtilityBagItemInGroup = {}
ERAHUDUtilityBagItemInGroup.__index = ERAHUDUtilityBagItemInGroup
setmetatable(ERAHUDUtilityBagItemInGroup, { __index = ERAHUDUtilityGenericTimerInGroup })

---@param group ERAHUDUtilityGroup
---@param timer ERACooldownBagItem
---@param iconID integer
---@param displayOrder number|nil
---@param warningIfMissing boolean
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityBagItemInGroup
function ERAHUDUtilityBagItemInGroup:create(group, timer, iconID, displayOrder, warningIfMissing, talent)
    local c = ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, talent)
    setmetatable(c, ERAHUDUtilityBagItemInGroup)
    ---@cast c ERAHUDUtilityBagItemInGroup
    c.bagItem = timer
    c.warningIfMissing = warningIfMissing
    return c
end

---@return boolean
function ERAHUDUtilityBagItemInGroup:checkAdditionalTalent()
    return self.timer.talentActive and (self.bagItem.hasItem or self.warningIfMissing)
end

---@param combat boolean
---@param t number
function ERAHUDUtilityBagItemInGroup:SetIconVisibilityOverride(t, combat)
    if self.bagItem.hasItem then
        self.icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        self.icon:SetSecondaryText(tostring(self.bagItem.stacks))
        if self.timer.remDuration <= 0 and not combat then
            self.icon:Hide()
        else
            self.icon:Show()
        end
    else
        if self.warningIfMissing then
            self.icon:SetVertexColor(1.0, 0.0, 0.0, 1.0)
            self.icon:SetSecondaryText("0")
            self.icon:Show()
        else
            --- pas important, va être géré par hud:mustUpdateUtilityLayout()
            self.icon:Hide()
        end
    end
end

--#endregion

--#region EXTERNAL TIMER

---@class ERAHUDUtilityExternalTimerInGroup : ERAHUDUtilityIconInGroup
---@field private __index unknown
---@field timer ERATimer
---@field private timerActive boolean
ERAHUDUtilityExternalTimerInGroup = {}
ERAHUDUtilityExternalTimerInGroup.__index = ERAHUDUtilityExternalTimerInGroup
setmetatable(ERAHUDUtilityExternalTimerInGroup, { __index = ERAHUDUtilityIconInGroup })

---@param group ERAHUDUtilityGroup
---@param timer ERATimer
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityExternalTimerInGroup
function ERAHUDUtilityExternalTimerInGroup:create(group, timer, iconID, displayOrder, talent)
    local g = {}
    setmetatable(g, ERAHUDUtilityExternalTimerInGroup)
    ---@cast g ERAHUDUtilityExternalTimerInGroup
    g:constructUtilityIconInGroup(group, iconID, true, displayOrder, talent)
    g.timer = timer
    return g
end

---@return boolean
function ERAHUDUtilityExternalTimerInGroup:checkAdditionalTalent()
    return self.timer.talentActive and self.timer.remDuration > 0
end

---@param combat boolean
---@param t number
function ERAHUDUtilityExternalTimerInGroup:update(t, combat)
    self.icon:SetOverlayValue(self.timer.remDuration / self.timer.totDuration)
    if self.timer.remDuration <= 0 then
        self.icon:SetMainText(nil)
    else
        self.icon:SetMainText(tostring(math.floor(self.timer.remDuration)))
    end
    self.icon:Show()
end

--#endregion

--#endregion

--#region OUT OF COMBAT

---@class (exact) ERAHUDUtilityIconOutOfCombat : ERAHUDUtilityIcon
---@field private __index unknown
---@field protected constructUtilityIconOutOfCombat fun(this:ERAHUDUtilityIconOutOfCombat, hud:ERAHUD, iconID:integer, forcedIcon:boolean, talent:ERALIBTalent|nil)
---@field private update fun(this:ERAHUDUtilityIconOutOfCombat, t:number, combat:boolean)
---@field protected updateOutOfCombat fun(this:ERAHUDUtilityIconOutOfCombat, t:number)
ERAHUDUtilityIconOutOfCombat = {}
ERAHUDUtilityIconOutOfCombat.__index = ERAHUDUtilityIconOutOfCombat
setmetatable(ERAHUDUtilityIconOutOfCombat, { __index = ERAHUDUtilityIcon })

---@param iconID integer
---@param forcedIcon boolean
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIconOutOfCombat:constructUtilityIconOutOfCombat(hud, iconID, forcedIcon, talent)
    self:constructUtilityIcon(hud, iconID, forcedIcon, talent)
end

---@param combat boolean
---@param t number
function ERAHUDUtilityIconOutOfCombat:update(t, combat)
    if combat then
        self.icon:Hide()
    else
        self:updateOutOfCombat(t)
    end
end

---@class (exact) ERAHUDUtilityAuraOutOfCombat : ERAHUDUtilityIconOutOfCombat
---@field private __index unknown
---@field aura ERAAura
ERAHUDUtilityAuraOutOfCombat = {}
ERAHUDUtilityAuraOutOfCombat.__index = ERAHUDUtilityAuraOutOfCombat
setmetatable(ERAHUDUtilityAuraOutOfCombat, { __index = ERAHUDUtilityIconOutOfCombat })

---@param aura ERAAura
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityAuraOutOfCombat
function ERAHUDUtilityAuraOutOfCombat:create(aura, iconID, talent)
    local a = {}
    setmetatable(a, ERAHUDUtilityAuraOutOfCombat)
    ---@cast a ERAHUDUtilityAuraOutOfCombat
    a.aura = aura
    local forcedIcon
    if iconID then
        forcedIcon = true
    else
        forcedIcon = false
        local spellInfo = C_Spell.GetSpellInfo(aura.spellID)
        iconID = spellInfo.iconID
    end
    a:constructUtilityIconOutOfCombat(aura.hud, iconID, forcedIcon, talent)
    aura.hud:addOutOfCombat(a)
    return a
end

---@return boolean
function ERAHUDUtilityAuraOutOfCombat:checkAdditionalTalent()
    return self.aura.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDUtilityAuraOutOfCombat:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.aura.spellID)
    return spellInfo.iconID
end

---@param t number
function ERAHUDUtilityAuraOutOfCombat:updateOutOfCombat(t)
    if self.aura.remDuration > 0 then
        if self.aura.stacks > 1 then
            self.icon:SetMainText(tostring(self.aura.stacks))
        else
            self.icon:SetMainText(nil)
        end
        self.icon:SetOverlayValue((self.aura.totDuration - self.aura.remDuration) / self.aura.totDuration)
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

--#endregion

--#region MISSING

---@class (exact) ERAHUDEmptyTimer : ERAHUDUtilityIcon
---@field private __index unknown
---@field timer ERATimer
---@field private update fun(this:ERAHUDEmptyTimer, t:number, combat:boolean)
---@field onlyIfPartyHasAnotherHealer boolean
---@field fadeAfterSeconds number
---@field private lastAppeared number
ERAHUDEmptyTimer = {}
ERAHUDEmptyTimer.__index = ERAHUDEmptyTimer
setmetatable(ERAHUDEmptyTimer, { __index = ERAHUDUtilityIcon })

---@param timer ERATimer
---@param fadeAfterSeconds number
---@param iconID integer
---@param talent ERALIBTalent|nil
---@return ERAHUDEmptyTimer
function ERAHUDEmptyTimer:create(timer, fadeAfterSeconds, iconID, talent)
    local et = {}
    setmetatable(et, ERAHUDEmptyTimer)
    ---@cast et ERAHUDEmptyTimer
    et.timer = timer
    et:constructUtilityIcon(timer.hud, iconID, true, talent)
    et.lastAppeared = 0
    et.fadeAfterSeconds = fadeAfterSeconds
    timer.hud:addEmpty(et)
    return et
end

---@param combat boolean
---@param t number
function ERAHUDEmptyTimer:update(t, combat)
    if self.timer.remDuration <= 0 and (self.hud.otherHealersInGroup > 0 or not self.onlyIfPartyHasAnotherHealer) then
        if self.lastAppeared > 0 and t - self.lastAppeared > self.fadeAfterSeconds then
            self.icon:Hide()
        else
            if self.lastAppeared <= 0 then
                self.lastAppeared = t
            end
            self.icon:Beam()
            self.icon:Show()
        end
    else
        self.lastAppeared = 0
        self.icon:Hide()
    end
end

--#endregion

--#endregion UTILITY

--#endregion ICONS

--------------------------------
--- SPELL ACTIVATION OVERLAY ---
--------------------------------

--#region SAO

---@alias ERASAOPosition "MIDDLE" | "LEFT" | "TOP" | "RIGHT" | "BOTTOM"

---@class (exact) ERASAO
---@field private __index unknown
---@field private talent ERALIBTalent|nil
---@field protected checkTalentSAO fun(this:ERASAO): boolean
---@field protected getIsActive fun(this:ERASAO, t:number, combat:boolean): boolean
---@field ConfirmIsActiveOverride fun(this:ERASAO, t:number, combat:boolean): boolean
---@field DeactivatedOverride nil|fun(this:ERASAO, t:number, combat:boolean)
---@field talentActive boolean
---@field hud ERAHUD
---@field private display Texture
---@field private isActive boolean
---@field private dataActive boolean
---@field private animGroup AnimationGroup
---@field private baseWidth number
---@field private baseHeight number
ERASAO = {}
ERASAO.__index = ERASAO

---@param hud ERAHUD
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@param offsetX number
---@param offsetY number
function ERASAO:constructSAO(hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    self.hud = hud
    local parentFrame = hud:addSAO(self)
    self.display = parentFrame:CreateTexture(nil, "OVERLAY")
    if isAtlas then
        ---@cast texture string
        self.display:SetAtlas(texture)
    else
        self.display:SetTexture(texture)
    end

    if flipH or flipV then
        local texLeft, texRight, texTop, texBottom = 0, 1, 0, 1
        if flipH then
            texLeft, texRight = 1, 0
        end
        if flipV then
            texTop, texBottom = 1, 0
        end
        self.display:SetTexCoord(texLeft, texRight, texTop, texBottom)
    end

    ---@type number, number
    local width, height
    local widthSides = math.min(128, math.max(1, math.min(-offsetX, hud.UtilityMinRightX) / 2))
    local heightSides = 2 * widthSides
    local heightTopDown = math.min(128, math.max(1, (-offsetY - hud.UtilityMinBottomY) / 2))
    local widthTopDown = 2 * heightTopDown
    if position == "LEFT" then
        width = widthSides
        height = heightSides
        self.display:SetPoint("CENTER", parentFrame, "CENTER", -1.5 * width - offsetX, -offsetY)
    elseif position == "RIGHT" then
        width = widthSides
        height = heightSides
        self.display:SetPoint("CENTER", parentFrame, "CENTER", 1.5 * width - offsetX, -offsetY)
    elseif position == "TOP" then
        width = widthTopDown
        height = heightTopDown
        self.display:SetPoint("CENTER", parentFrame, "CENTER", -offsetX, 1.5 * height - offsetY)
    elseif position == "BOTTOM" then
        width = widthTopDown
        height = heightTopDown
        self.display:SetPoint("CENTER", parentFrame, "CENTER", -offsetX, -1.5 * height - offsetY)
    else -- MIDDLE
        width = math.min(heightSides, widthTopDown, 181)
        height = width
        self.display:SetPoint("CENTER", parentFrame, "CENTER", -offsetX, -offsetY)
    end

    if rotateLeft then
        self.display:SetSize(height, width)
        self.display:SetRotation(math.rad(90))
        self.baseWidth = height
        self.baseHeight = width
    elseif rotateRight then
        self.display:SetSize(height, width)
        self.display:SetRotation(math.rad(-90))
        self.baseWidth = height
        self.baseHeight = width
    else
        self.display:SetSize(width, height)
        self.baseWidth = width
        self.baseHeight = height
    end

    self.animGroup = self.display:CreateAnimationGroup()
    local animPulseBig = self.animGroup:CreateAnimation("Scale")
    ---@cast animPulseBig Scale
    animPulseBig:SetDuration(0.5)
    animPulseBig:SetScale(1.25, 1.25)
    animPulseBig:SetSmoothing("IN_OUT")
    animPulseBig:SetOrder(1)
    local animPulseSmall = self.animGroup:CreateAnimation("Scale")
    ---@cast animPulseSmall Scale
    animPulseSmall:SetDuration(0.5)
    animPulseSmall:SetScale(0.8, 0.8)
    animPulseSmall:SetSmoothing("IN_OUT")
    animPulseSmall:SetOrder(2)
    self.animGroup:SetLooping("REPEAT")

    self.display:Hide()
    self.isActive = false
    self.talent = talent

    if widthSides <= 10 or heightTopDown <= 1 then
        hud.showSAO = false
    end
end

---@param r number
---@param g number
---@param b number
function ERASAO:SetVertexColor(r, g, b)
    self.display:SetVertexColor(r, g, b)
end

---@param w number
---@param h number
function ERASAO:SetMaxSize(w, h)
    self.display:SetSize(math.min(self.baseWidth, w), math.min(self.baseHeight, h))
end

---@return boolean
function ERASAO:checkTalentOrHide()
    if self.hud.showSAO and ((not self.talent) or self.talent:PlayerHasTalent()) and self:checkTalentSAO() then
        return true
    else
        self.display:Hide()
        return false
    end
end

---@param combat boolean
---@param t number
function ERASAO:update(t, combat)
    local da = self:getIsActive(t, combat)
    if self.DeactivatedOverride then
        if da then
            self.dataActive = true
        else
            if self.dataActive then
                self.dataActive = false
                self:DeactivatedOverride(t, combat)
            end
        end
    end
    if self.hud.showUtility and da and self:ConfirmIsActiveOverride(t, combat) then
        if not self.isActive then
            self.isActive = true
            self.display:Show()
            self.animGroup:Play()
        end
    else
        if self.isActive then
            self.isActive = false
            self.display:Hide()
            self.animGroup:Stop()
        end
    end
end
---@param combat boolean
---@param t number
---@return boolean
function ERASAO:ConfirmIsActiveOverride(t, combat)
    return true
end

--- BASED ON AURA ---

---@class (exact) ERASAOAura : ERASAO
---@field private __index unknown
---@field private aura ERAAura
---@field private minStacks integer
ERASAOAura = {}
ERASAOAura.__index = ERASAOAura
setmetatable(ERASAOAura, { __index = ERASAO })

---@param aura ERAAura
---@param minStacks integer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@param offsetX number
---@param offsetY number
---@return ERASAOAura
function ERASAOAura:create(aura, minStacks, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    local a = {}
    setmetatable(a, ERASAOAura)
    ---@cast a ERASAOAura
    a.aura = aura
    a.minStacks = minStacks
    a:constructSAO(aura.hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    return a
end

---@return boolean
function ERASAOAura:checkTalentSAO()
    return self.aura.talentActive
end

---@param combat boolean
---@param t number
function ERASAOAura:getIsActive(t, combat)
    return self.aura.stacks >= self.minStacks
end

---@class (exact) ERASAOMissingTimer : ERASAO
---@field private __index unknown
---@field private timer ERATimer
---@field private onlyIfHasTarget boolean
ERASAOMissingTimer = {}
ERASAOMissingTimer.__index = ERASAOMissingTimer
setmetatable(ERASAOMissingTimer, { __index = ERASAO })

--- BASED ON ANY TIMER ---

---@class (exact) ERASAOTimer : ERASAO
---@field private __index unknown
---@field private timer ERATimer
ERASAOTimer = {}
ERASAOTimer.__index = ERASAOTimer
setmetatable(ERASAOTimer, { __index = ERASAO })

---@param timer ERATimer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@param offsetX number
---@param offsetY number
---@return ERASAOTimer
function ERASAOTimer:create(timer, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    local a = {}
    setmetatable(a, ERASAOTimer)
    ---@cast a ERASAOTimer
    a.timer = timer
    a:constructSAO(timer.hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    return a
end

---@return boolean
function ERASAOTimer:checkTalentSAO()
    return self.timer.talentActive
end

---@param combat boolean
---@param t number
function ERASAOTimer:getIsActive(t, combat)
    return self.timer.remDuration > 0
end

---@param timer ERATimer
---@param onlyIfHasTarget boolean
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@param offsetX number
---@param offsetY number
---@return ERASAOMissingTimer
function ERASAOMissingTimer:create(timer, onlyIfHasTarget, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    local a = {}
    setmetatable(a, ERASAOMissingTimer)
    ---@cast a ERASAOMissingTimer
    a.timer = timer
    a.onlyIfHasTarget = onlyIfHasTarget
    a:constructSAO(timer.hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    return a
end

---@return boolean
function ERASAOMissingTimer:checkTalentSAO()
    return self.timer.talentActive
end

---@param combat boolean
---@param t number
function ERASAOMissingTimer:getIsActive(t, combat)
    return self.timer.remDuration <= 0 and ((not self.onlyIfHasTarget) or (combat and UnitCanAttack("player", "target")))
end

--- BASED ON ACTIVATION ---

---@class (exact) ERASAOActivation : ERASAO
---@field private __index unknown
---@field private spellID integer
ERASAOActivation = {}
ERASAOActivation.__index = ERASAOActivation
setmetatable(ERASAOActivation, { __index = ERASAO })

---@param spellID integer
---@param hud ERAHUD
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@param offsetX number
---@param offsetY number
---@return ERASAOActivation
function ERASAOActivation:create(spellID, hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    local a = {}
    setmetatable(a, ERASAOActivation)
    ---@cast a ERASAOActivation
    a.spellID = spellID
    a:constructSAO(hud, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, offsetX, offsetY)
    return a
end

---@return boolean
function ERASAOActivation:checkTalentSAO()
    return true
end

---@param combat boolean
---@param t number
function ERASAOActivation:getIsActive(t, combat)
    return IsSpellOverlayed(self.spellID)
end

--#endregion

------------
--- MISC ---
------------

--#region MISC

--#region MARKERS

---@class (exact) ERAHUDTimerMarker
---@field private __index unknown
---@field hud ERAHUD
---@field private r number
---@field private g number
---@field private b number
---@field private talent ERALIBTalent|nil
---@field private pixel number
---@field private timerMaxY number
---@field private visible boolean
---@field private line Line
---@field ComputeTimeOr0IfInvisibleOverride fun(this:ERAHUDTimerMarker, t:number): number
---@field SetColor fun(this:ERAHUDTimerMarker, r:number, g:number, b:number)
---@field createDisplay fun(this:ERAHUDTimerMarker, frameOverlay:Frame)
---@field private show fun(this:ERAHUDTimerMarker)
---@field private hide fun(this:ERAHUDTimerMarker)
ERAHUDTimerMarker = {}
ERAHUDTimerMarker.__index = ERAHUDTimerMarker

---@param hud ERAHUD
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDTimerMarker
function ERAHUDTimerMarker:create(hud, r, g, b, talent)
    local m = {}
    setmetatable(m, ERAHUDTimerMarker)
    ---@cast m ERAHUDTimerMarker
    m.hud = hud
    m.r = r
    m.g = g
    m.b = b
    m.talent = talent
    m.pixel = 1
    m.timerMaxY = 0
    return m
end

---@param frameOverlay Frame
function ERAHUDTimerMarker:createDisplay(frameOverlay)
    self.line = frameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDVerticalTick")
    self.line:SetVertexColor(self.r, self.g, self.b, 1)
    self.visible = true
end

function ERAHUDTimerMarker:show()
    if (not self.visible) then
        self.visible = true
        self.line:Show()
    end
end
function ERAHUDTimerMarker:hide()
    if (self.visible) then
        self.visible = false
        self.line:Hide()
    end
end

function ERAHUDTimerMarker:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        return true
    else
        self:hide()
        return false
    end
end

---@param timerMaxY number
---@param t number
---@param frameOverlay Frame
function ERAHUDTimerMarker:update(timerMaxY, t, frameOverlay)
    local xTime = self:ComputeTimeOr0IfInvisibleOverride(t)
    if (xTime > 0) then
        local px = self.hud:calcTimerPixel(xTime)
        if (px ~= self.pixel or timerMaxY ~= self.timerMaxY) then
            self.pixel = px
            self.timerMaxY = timerMaxY
            if (self.hud.topdown) then
                self.line:SetStartPoint("RIGHT", frameOverlay, px, ERAHUD_TimerIconSize / 2)
            else
                self.line:SetStartPoint("RIGHT", frameOverlay, px, -ERAHUD_TimerIconSize / 2)
            end
            self.line:SetEndPoint("RIGHT", frameOverlay, px, timerMaxY)
        end
        self:show()
    else
        self:hide()
    end
end

function ERAHUDTimerMarker:ComputeTimeOr0IfInvisibleOverride(haste)
    return 0
end

---@param r number
---@param g number
---@param b number
function ERAHUDTimerMarker:SetColor(r, g, b)
    if (self.r ~= r or self.g ~= g or self.b ~= b) then
        self.r = r
        self.g = g
        self.b = b
        self.line:SetVertexColor(r, g, b, 1)
    end
end

--#endregion

--#region EMPOWER

---@class (exact) ERAHUDEmpowerLevel
---@field private __index unknown
---@field private hud ERAHUD
---@field private tick Line
---@field private text FontString
---@field private visible boolean
---@field private isUsed boolean
---@field private isPast boolean
---@field private isCurrent boolean
---@field private isFuture boolean
---@field private wasCurrent boolean
---@field private wasFuture boolean
---@field private startsIn number
---@field private endsIn number
ERAHUDEmpowerLevel = {}
ERAHUDEmpowerLevel.__index = ERAHUDEmpowerLevel

---@param hud ERAHUD
---@param frameOverlay Frame
---@param lvlValue integer
---@return ERAHUDEmpowerLevel
function ERAHUDEmpowerLevel:create(hud, frameOverlay, lvlValue)
    local lvl = {}
    setmetatable(lvl, ERAHUDEmpowerLevel)
    ---@cast lvl ERAHUDEmpowerLevel
    lvl.hud = hud

    lvl.tick = frameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDEmpowerTick")
    lvl.text = frameOverlay:CreateFontString(nil, "OVERLAY", "ERAHUDEmpowerText")
    ERALIB_SetFont(lvl.text, 16)
    if (lvlValue == 1) then
        lvl.text:SetText("I")
    elseif (lvlValue == 2) then
        lvl.text:SetText("II")
    elseif (lvlValue == 3) then
        lvl.text:SetText("III")
    elseif (lvlValue == 4) then
        lvl.text:SetText("IV")
    else
        lvl.text:SetText(tostring(lvlValue))
    end
    lvl.tick:Hide()
    lvl.text:Hide()
    lvl.visible = false

    lvl.isUsed = false
    lvl.isPast = false
    lvl.isCurrent = false
    lvl.isFuture = true
    lvl.wasCurrent = false
    lvl.wasFuture = false

    lvl.startsIn = 0
    lvl.endsIn = 0

    return lvl
end

function ERAHUDEmpowerLevel:hide()
    if (self.visible) then
        self.visible = false
        self.tick:Hide()
        self.text:Hide()
    end
end
function ERAHUDEmpowerLevel:show()
    if (not self.visible) then
        self.visible = true
        self.tick:Show()
        self.text:Show()
    end
end

function ERAHUDEmpowerLevel:setPast()
    self.isPast = true
    self.isUsed = true
end

---@param endsIn number
function ERAHUDEmpowerLevel:setCurrent(endsIn)
    self.isCurrent = true
    self.isUsed = true
    self.endsIn = endsIn
end

---@param startsIn number
---@param endsIn number
function ERAHUDEmpowerLevel:setFuture(startsIn, endsIn)
    self.isFuture = true
    self.isUsed = true
    self.startsIn = startsIn
    self.endsIn = endsIn
end

function ERAHUDEmpowerLevel:setNotUsed()
    self.isUsed = false
end

---@param frameOverlay Frame
---@param timerY number
function ERAHUDEmpowerLevel:drawOrHideIfUnused(frameOverlay, timerY)
    if (self.isUsed) then
        self.isUsed = false
        if (self.isPast) then
            self.isPast = false
            self:hide()
        elseif (self.isCurrent) then
            self.isCurrent = false
            self.wasCurrent = true
            if (self.wasFuture) then
                self.wasFuture = false
                self.text:ClearAllPoints()
                ERALIB_SetFont(self.text, 32)
                self.text:SetTextColor(1, 1, 0, 1)
            end
            local endPixel = self.hud:calcTimerPixel(self.endsIn)
            self.text:SetPoint("LEFT", frameOverlay, "CENTER", 8, 0)
            if (self.hud.topdown) then
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerY)
            else
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, -ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerY)
            end
            self:show()
        elseif (self.isFuture) then
            self.isFuture = false
            self.wasFuture = true
            if (self.wasCurrent) then
                self.wasCurrent = false
                self.text:ClearAllPoints()
                ERALIB_SetFont(self.text, 16)
                self.text:SetTextColor(1, 1, 1, 1)
            end
            local startPixel = self.hud:calcTimerPixel(self.startsIn)
            local endPixel = self.hud:calcTimerPixel(self.endsIn)
            if (self.hud.topdown) then
                self.text:SetPoint("CENTER", frameOverlay, "RIGHT", (startPixel + endPixel) / 2, ERAHUD_TimerIconSize / 2)
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerY)
            else
                self.text:SetPoint("CENTER", frameOverlay, "RIGHT", (startPixel + endPixel) / 2, -ERAHUD_TimerIconSize / 2)
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, -ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerY)
            end
            self:show()
        end
    else
        self:hide()
    end
end

--#endregion

--#endregion

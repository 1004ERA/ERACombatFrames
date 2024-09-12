------------
--- BARS ---
------------

--#region BARS

---@class (exact) ERAHUDBar
---@field private __index unknown
---@field protected constructBar fun(this:ERAHUDBar, hud:ERAHUD, iconID:integer|nil, r:number, g:number, b:number, texture:string|integer|Texture)
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
---@field SetColor fun(this:ERAHUDBar, r:number, g:number, b:number)
---@field SetIconDesaturated fun(this:ERAHUDBar, desat:boolean)
---@field SetIconAlpha fun(this:ERAHUDBar, alpha:number)
---@field SetSize fun(this:ERAHUDBar, s:number)
---@field SetText fun(this:ERAHUDBar, txt:string|nil)
---@field protected checkTalentsOverride fun(this:ERAHUDBar): boolean
---@field protected ComputeDurationOverride fun(this:ERAHUDBar, t:number)
---@field private hide fun(this:ERAHUDBar)
---@field draw fun(this:ERAHUDBar, y:number): number
ERAHUDBar = {}
ERAHUDBar.__index = ERAHUDBar

--#region GENERIC BAR

---@param hud ERAHUD
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param texture string|integer|Texture
function ERAHUDBar:constructBar(hud, iconID, r, g, b, texture)
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
    bar:SetStatusBarColor(r, g, b, 1)
    bar:SetStatusBarTexture(texture)
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
        self.display:SetPoint("TOPRIGHT", self.parentFrame, "RIGHT", 0, -self.y)
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
            if (self.hud.topdown) then
                self.translation:SetOffset(0, self.y - y)
            else
                self.translation:SetOffset(0, y - self.y)
            end
            self.anim:Play()
        end
    else
        if (self.hud.topdown) then
            self.display:SetPoint("TOPRIGHT", self.parentFrame, "RIGHT", 0, -y)
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
    self.remDuration = self:ComputeDurationOverride(t)
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

--#endregion

-----------------------
--- TARGET CAST BAR ---
-----------------------

--#region TARGET CAST BAR

---@class (exact) ERAHUDTargetCastBar : ERAHUDBar
---@field private __index unknown
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
    x:constructBar(hud, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleLegion")
    ERALIB_SetFont(x.text, ERACombat_TimerBarDefaultSize * 0.5)
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
function ERAHUDTargetCastBar:ComputeDurationOverride(t)
    if self.kick_is_available then
        self.kick_is_available = false
        self.kick_will_be_available = false
        self.display:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        return self.hud.targetCast
    elseif self.kick_will_be_available then
        self.kick_will_be_available = false
        self.display:SetVertexColor(0.8, 0.0, 0.0, 1.0)
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
function ERAHUDLOCBar:ComputeDurationOverride(t)
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
function ERAHUDSpellIDBar:ComputeDurationOverride(t)
    return self.timer.remDuration
end

--#endregion

--#endregion BARS

------------------
--- TIMER ITEM ---
------------------

--#region TIMER ITEM

---@class (exact) ERAHUDTimerItem
---@field private __index unknown
---@field protected constructItem fun(this:ERAHUDTimerItem, hud:ERAHUD, iconID:integer, talent:ERALIBTalent|nil)
---@field ComputeAvailablePriorityOverride fun(this:ERAHUDTimerItem, t:number)
---@field protected checkAdditionalTalent fun(this:ERAHUDTimerItem): boolean
---@field protected updateIconID fun(this:ERAHUDTimerItem, currentIconID:integer): integer
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
ERAHUDTimerItem = {}
ERAHUDTimerItem.__index = ERAHUDTimerItem

---@param hud ERAHUD
---@param iconID integer
---@param talent ERALIBTalent|nil
function ERAHUDTimerItem:constructItem(hud, iconID, talent)
    self.hud = hud
    self.talent = talent
    self.iconID = iconID
    hud:addTimerItem(self)
end

---@param frame Frame
function ERAHUDTimerItem:constructOverlay(frame)
    self.icon = ERASquareIcon:Create(frame, "RIGHT", ERAHUD_TimerIconSize, self.iconID)
    self.line = frame:CreateLine(nil, "OVERLAY", "ERAHUDVerticalTick")
    self.lineVisible = true
    self:hide()
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
        local i = self:updateIconID(self.iconID)
        if self.iconID ~= i then
            self.iconID = i
            self.icon:SetIconTexture(i, true)
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
        self.priority = 0
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
    p:constructItem(hud, iconID, talent)
    return p
end

---@param t number
function ERAHUDRawPriority:ComputeDurationOverride(t)
    return 0
end

--#endregion TIMER ITEM

-------------
--- ICONS ---
-------------

--#region ICONS

---@class (exact) ERAHUDIcon
---@field private __index unknown
---@field protected constructIcon fun(this:ERAHUDIcon, hud:ERAHUD, iconID:integer, iconSize:number, frame:Frame, talent:ERALIBTalent|nil)
---@field protected checkAdditionalTalent fun(this:ERAHUDIcon): boolean
---@field protected updateIconID fun(this:ERAHUDIcon, currentIconID:integer): integer
---@field talent ERALIBTalent|nil
---@field talentActive boolean
---@field hud ERAHUD
---@field iconID integer
---@field icon ERAPieIcon
ERAHUDIcon = {}
ERAHUDIcon.__index = ERAHUDIcon

---@param hud ERAHUD
---@param iconID integer
---@param iconSize number
---@param frame Frame
---@param talent ERALIBTalent|nil
function ERAHUDIcon:constructIcon(hud, iconID, iconSize, frame, talent)
    self.hud = hud
    self.talent = talent
    self.icon = ERAPieIcon:Create(frame, "CENTER", iconSize, iconID)
    self.iconID = iconID
end

function ERAHUDIcon:checkTalentOrHide()
    if (self.talent and not self.talent:PlayerHasTalent()) or not self:checkAdditionalTalent() then
        self.icon:Hide()
        self.talentActive = false
        return false
    else
        local i = self:updateIconID(self.iconID)
        if self.iconID ~= i then
            self.iconID = i
            self.icon:SetIconTexture(i, true)
        end
        self.icon:Show()
        self.talentActive = true
        return true
    end
end

---@return boolean
function ERAHUDIcon:checkAdditionalTalent()
    return true
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
---@param hideIfAvailable boolean
---@param t number
function ERAHUDIcon_updateStandard(icon, data, currentCharges, maxCharges, remdurDesat, hideIfAvailable, t)
    if data.isKnown then
        local available
        if data.hasCharges then
            if data.currentCharges ~= currentCharges or data.maxCharges ~= maxCharges then
                local txt = ""
                for i = 1, data.currentCharges do
                    txt = txt .. "¤"
                end
                for i = data.currentCharges + 1, data.maxCharges do
                    txt = txt .. "."
                end
                icon:SetSecondaryText(txt)
            end
            available = data.currentCharges >= data.maxCharges
            icon:SetDesaturated(data.currentCharges == 0)
        else
            icon:SetSecondaryText(nil)
            icon:SetDesaturated(data.remDuration >= remdurDesat)
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
            if IsSpellOverlayed(data.spellID) then
                icon:Highlight()
            else
                icon:StopHighlight()
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
---@field protected constructRotationIcon fun(this:ERAHUDIcon, hud:ERAHUD, iconID:integer, talent:ERALIBTalent|nil)
---@field update fun(this:ERAHUDRotationIcon, combat:boolean, t:number)
---@field specialPosition boolean
ERAHUDRotationIcon = {}
ERAHUDRotationIcon.__index = ERAHUDRotationIcon
setmetatable(ERAHUDRotationIcon, { __index = ERAHUDIcon })

---@param hud ERAHUD
---@param iconID integer
---@param talent ERALIBTalent|nil
function ERAHUDRotationIcon:constructRotationIcon(hud, iconID, talent)
    local frame = hud:addRotation(self)
    self:constructIcon(hud, iconID, ERAHUD_RotationIconSize, frame, talent)
    self.specialPosition = false
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
---@field onTimer ERAHUDRotationCooldownIconPriority
---@field availableChargePriority ERAHUDRotationCooldownIconChargedPriority
---@field protected UpdatedOverride fun(this:ERAHUDRotationCooldownIcon, combat:boolean, t:number)
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
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    cd:constructRotationIcon(data.hud, iconID, talent)
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
function ERAHUDRotationCooldownIcon:update(combat, t)
    ERAHUDIcon_updateStandard(self.icon, self.data, self.currentCharges, self.maxCharges, 1004, not combat, t)
    self.currentCharges = self.data.currentCharges
    self.maxCharges = self.data.maxCharges
end
---@param combat boolean
---@param t number
function ERAHUDRotationCooldownIcon:UpdatedOverride(combat, t)
end

---@class (exact) ERAHUDRotationCooldownIconPriority : ERAHUDTimerItem
---@field private __index unknown
---@field cd ERAHUDRotationCooldownIcon
ERAHUDRotationCooldownIconPriority = {}
ERAHUDRotationCooldownIconPriority.__index = ERAHUDRotationCooldownIconPriority
setmetatable(ERAHUDRotationCooldownIconPriority, { __index = ERAHUDTimerItem })

---@param cd ERAHUDRotationCooldownIcon
---@return ERAHUDRotationCooldownIconPriority
function ERAHUDRotationCooldownIconPriority:create(cd)
    local p = {}
    setmetatable(p, ERAHUDRotationCooldownIconPriority)
    ---@cast p ERAHUDRotationCooldownIconPriority
    p:constructItem(cd.hud, cd.iconID, cd.talent)
    p.cd = cd
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

---@param t number
function ERAHUDRotationCooldownIconPriority:ComputeAvailablePriorityOverride(t)
    return 1
end

---@class (exact) ERAHUDRotationCooldownIconChargedPriority : ERAHUDTimerItem
---@field private __index unknown
---@field cd ERAHUDRotationCooldownIcon
ERAHUDRotationCooldownIconChargedPriority = {}
ERAHUDRotationCooldownIconChargedPriority.__index = ERAHUDRotationCooldownIconChargedPriority
setmetatable(ERAHUDRotationCooldownIconChargedPriority, { __index = ERAHUDTimerItem })

---@param cd ERAHUDRotationCooldownIcon
---@return ERAHUDRotationCooldownIconChargedPriority
function ERAHUDRotationCooldownIconChargedPriority:create(cd)
    local p = {}
    setmetatable(p, ERAHUDRotationCooldownIconChargedPriority)
    ---@cast p ERAHUDRotationCooldownIconChargedPriority
    p:constructItem(cd.hud, cd.iconID, cd.talent)
    p.cd = cd
    return p
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
function ERAHUDRotationCooldownIconChargedPriority:ComputeAvailablePriorityOverride(t)
    return 0
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
function ERAHUDRotationOffensiveDispellIcon:UpdatedOverride(combat, t)
    if
        (self.magic and self.hud.targetDispellableMagic)
        or
        (self.enrage and self.hud.targetDispellableEnrage)
    then
        self.icon:Show()
        if self.data.remDuration > 0 then
            self.icon:StopHighlight()
        else
            self.icon:Highlight()
        end
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
function ERAHUDRotationKickIcon:UpdatedOverride(combat, t)
    if self.hud.targetCast > self.data.remDuration then
        if self.data.remDuration <= 0 then
            self.hud.targetCastBar:kickIsAvailable()
        else
            self.hud.targetCastBar:kickWillBeAvailable()
        end
        self.icon:Show()
    else
        self.icon:Hide()
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
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    buff:constructRotationIcon(data.hud, iconID, talent)
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

---@param t number
function ERAHUDRotationAuraIcon:update(t)
    if self.data.stacks > 0 then
        if self.currentStacks == 0 then
            self.icon:SetDesaturated(false)
            self.icon:SetMainTextColor(1.0, 1.0, 1.0, 1.0)
        end
        if self.currentStacks ~= self.data.stacks then
            self.currentStacks = self.data.stacks
            self.icon:SetMainText(tostring(self.currentStacks))
        end
        self.icon:SetOverlayValue(self.data.remDuration / self.data.totDuration)
    else
        if self.currentStacks ~= 0 then
            self.currentStacks = 0
            self.icon:SetDesaturated(true)
            self.icon:SetOverlayValue(0)
            self.icon:SetMainText("X")
            self.icon:SetMainTextColor(1.0, 0.0, 0.0, 1.0)
        end
    end
end

--------------
--- STACKS ---
--------------

---@class (exact) ERAHUDRotationStacksIcon : ERAHUDRotationIcon
---@field private __index unknown
---@field data ERAStacks
---@field maxStacks integer
---@field private currentStacks integer
ERAHUDRotationStacksIcon = {}
ERAHUDRotationStacksIcon.__index = ERAHUDRotationStacksIcon
setmetatable(ERAHUDRotationStacksIcon, { __index = ERAHUDRotationIcon })

---@param data ERAStacks
---@param maxStacks integer
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationStacksIcon
function ERAHUDRotationStacksIcon:create(data, maxStacks, iconID, talent)
    local buff = {}
    setmetatable(buff, ERAHUDRotationStacksIcon)
    ---@cast buff ERAHUDRotationStacksIcon
    buff.data = data
    buff.maxStacks = maxStacks
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    buff:constructRotationIcon(data.hud, iconID, talent)
    buff.currentStacks = -1
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

---@param t number
function ERAHUDRotationStacksIcon:update(t)
    if self.data.stacks > 0 then
        if self.currentStacks ~= self.data.stacks then
            self.currentStacks = self.data.stacks
            self.icon:SetMainText(tostring(self.currentStacks))
            self.icon:SetOverlayValue(self.currentStacks / self.maxStacks)
        end
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

--#endregion

--#endregion ROTATION

---------------
--- UTILITY ---
---------------

--#region UTILITY

---@class (exact) ERAHUDUtilityIcon : ERAHUDIcon
---@field private __index unknown
---@field protected constructUtilityIcon fun(this:ERAHUDUtilityIcon, hud:ERAHUD, iconID:integer, talent:ERALIBTalent|nil)
---@field update fun(this:ERAHUDUtilityIcon, combat:boolean, t:number)
ERAHUDUtilityIcon = {}
ERAHUDUtilityIcon.__index = ERAHUDUtilityIcon
setmetatable(ERAHUDUtilityIcon, { __index = ERAHUDIcon })

---@param hud ERAHUD
---@param iconID integer
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIcon:constructUtilityIcon(hud, iconID, talent)
    local parentFrame = hud:addUtilityIcon(self)
    self:constructIcon(hud, iconID, ERAHUD_UtilityIconSize, parentFrame, talent)
end

--#region IN GROUP

---@class (exact) ERAHUDUtilityIconInGroup : ERAHUDUtilityIcon
---@field private __index unknown
---@field protected constructUtilityIconInGroup fun(this:ERAHUDIcon, group:ERAHUDUtilityGroup, iconID:integer, displayOrder:number|nil, talent:ERALIBTalent|nil)
---@field update fun(this:ERAHUDUtilityIconInGroup, combat:boolean, t:number)
---@field private group ERAHUDUtilityGroup
---@field displayOrder number
ERAHUDUtilityIconInGroup = {}
ERAHUDUtilityIconInGroup.__index = ERAHUDUtilityIconInGroup
setmetatable(ERAHUDUtilityIconInGroup, { __index = ERAHUDUtilityIcon })

---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIconInGroup:constructUtilityIconInGroup(group, iconID, displayOrder, talent)
    self:constructUtilityIcon(group.hud, iconID, talent)
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
---@field protected mustStillShowIfTimerTalentInactive fun(this:ERAHUDUtilityGenericTimerInGroup): boolean
---@field protected GenericUpdatedOverride fun(this:ERAHUDUtilityGenericTimerInGroup, combat:boolean, t:number)
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
    g:constructUtilityIconInGroup(group, iconID, displayOrder, talent)
    g.timer = timer
    g.timerActive = false
    return g
end

---@return boolean
function ERAHUDUtilityGenericTimerInGroup:checkAdditionalTalent()
    return self.timer.talentActive or self:mustStillShowIfTimerTalentInactive()
end

---@param combat boolean
---@param t number
function ERAHUDUtilityGenericTimerInGroup:update(combat, t)
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
            self.icon:SetMainText(tostring(self.timer.remDuration))
        end
        if self.timer.remDuration <= 0 and not combat then
            self.icon:Hide()
        else
            self.icon:Show()
        end
    else
        if self.timerActive then
            self.icon:SetOverlayValue(0)
            self.icon:SetMainText(nil)
            self.timerActive = false
            if not self:mustStillShowIfTimerTalentInactive() then
                self.icon:Hide()
            end
            self.hud:mustUpdateUtilityLayout()
        end
    end
    self:GenericUpdatedOverride(combat, t)
end
---@return integer
function ERAHUDUtilityGenericTimerInGroup:timerActive_returnIconID()
    return self.iconID
end
---@return boolean
function ERAHUDUtilityGenericTimerInGroup:mustStillShowIfTimerTalentInactive()
    return false
end
---@param combat boolean
---@param t number
function ERAHUDUtilityGenericTimerInGroup:GenericUpdatedOverride(combat, t)
end

--#endregion

----------------
--- COOLDOWN ---
----------------

---@class (exact) ERAHUDUtilityCooldownInGroup : ERAHUDUtilityIconInGroup
---@field private __index unknown
---@field update fun(this:ERAHUDUtilityCooldownInGroup, combat:boolean, t:number)
---@field protected UpdatedOverride fun(this:ERAHUDUtilityCooldownInGroup, combat:boolean, t:number)
---@field data ERACooldownBase
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
function ERAHUDUtilityCooldownInGroup:create(group, data, iconID, displayOrder, talent)
    local cd = {}
    setmetatable(cd, ERAHUDUtilityCooldownInGroup)
    ---@cast cd ERAHUDUtilityCooldownInGroup
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)
        iconID = spellInfo.iconID
    end
    cd:constructUtilityIconInGroup(group, iconID, displayOrder, talent)
    cd.data = data
    cd.currentCharges = -1
    cd.maxCharges = -1
    return cd
end

---@return boolean
function ERAHUDUtilityCooldownInGroup:checkAdditionalTalent()
    return self.data.talentActive
end

---@param currentIconID integer
---@return integer
function ERAHUDUtilityCooldownInGroup:updateIconID(currentIconID)
    local spellInfo = C_Spell.GetSpellInfo(self.data.spellID)
    return spellInfo.iconID
end

---@param combat boolean
---@param t number
function ERAHUDUtilityCooldownInGroup:update(combat, t)
    ERAHUDIcon_updateStandard(self.icon, self.data, self.currentCharges, self.maxCharges, 30, not combat, t)
    self.currentCharges = self.data.currentCharges
    self.maxCharges = self.data.maxCharges
    self:UpdatedOverride(combat, t)
end
---@param combat boolean
---@param t number
function ERAHUDUtilityCooldownInGroup:UpdatedOverride(combat, t)
end

---------------
--- SPECIAL ---
---------------

--#region DISPELL

---@class (exact) ERAHUDUtilityDispellInGroup : ERAHUDUtilityCooldownInGroup
---@field private __index unknown
---@field private UpdatedOverride fun(this:ERAHUDUtilityDispellInGroup, combat:boolean, t:number)
---@field private magic boolean
---@field private disease boolean
---@field private poison boolean
---@field private curse boolean
---@field private bleed boolean
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
function ERAHUDUtilityDispellInGroup:UpdatedOverride(combat, t)
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
        self.icon:Beam()
        self.icon:Show()
    else
        if self.data.remDuration > 0 then
            self.icon:StopBeam()
        else
            self.icon:Hide()
        end
    end
end

--#endregion

--#region EQUIPMENT

---@class ERAHUDUtilityEquipmentInGroup : ERAHUDUtilityGenericTimerInGroup
---@field private __index unknown
---@field private equipment ERACooldownEquipment
ERAHUDUtilityEquipmentInGroup = {}
ERAHUDUtilityEquipmentInGroup.__index = ERAHUDUtilityEquipmentInGroup
setmetatable(ERAHUDUtilityEquipmentInGroup, { __index = ERAHUDUtilityGenericTimerInGroup })

---@param group ERAHUDUtilityGroup
---@param timer ERACooldownEquipment
---@param iconID integer
---@param displayOrder number|nil
---@return ERAHUDUtilityEquipmentInGroup
function ERAHUDUtilityEquipmentInGroup:create(group, timer, iconID, displayOrder)
    local c = ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, nil)
    setmetatable(c, ERAHUDUtilityEquipmentInGroup)
    ---@cast c ERAHUDUtilityEquipmentInGroup
    c.equipment = timer
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
---@return ERAHUDUtilityBagItemInGroup
function ERAHUDUtilityBagItemInGroup:create(group, timer, iconID, displayOrder, warningIfMissing)
    local c = ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, nil)
    setmetatable(c, ERAHUDUtilityBagItemInGroup)
    ---@cast c ERAHUDUtilityBagItemInGroup
    c.bagItem = timer
    c.warningIfMissing = warningIfMissing
    return c
end

---@return boolean
function ERAHUDUtilityBagItemInGroup:mustStillShowIfTimerTalentInactive()
    return self.warningIfMissing
end

---@param combat boolean
---@param t number
function ERAHUDUtilityBagItemInGroup:GenericUpdatedOverride(combat, t)
    if self.bagItem.hasItem then
        self.icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        self.icon:SetSecondaryText(tostring(self.bagItem.stacks))
    else
        if self.warningIfMissing then
            self.icon:SetVertexColor(1.0, 0.0, 0.0, 1.0)
            self.icon:SetSecondaryText("0")
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
    g:constructUtilityIconInGroup(group, iconID, displayOrder, talent)
    g.timer = timer
    g.timerActive = false
    return g
end

---@return boolean
function ERAHUDUtilityExternalTimerInGroup:checkAdditionalTalent()
    return self.timer.talentActive and self.timer.remDuration > 0
end

---@param combat boolean
---@param t number
function ERAHUDUtilityExternalTimerInGroup:update(combat, t)
    if self.timer.talentActive and self.timer.remDuration > 0 then
        if not self.timerActive then
            self.timerActive = true
            self.hud:mustUpdateUtilityLayout()
        end
        self.icon:SetOverlayValue(self.timer.remDuration / self.timer.totDuration)
        if self.timer.remDuration <= 0 then
            self.icon:SetMainText(nil)
        else
            self.icon:SetMainText(tostring(self.timer.remDuration))
        end
    else
        if self.timerActive then
            self.icon:SetOverlayValue(0)
            self.icon:SetMainText(nil)
            self.timerActive = false
            self.hud:mustUpdateUtilityLayout()
        end
    end
end

--#endregion

--#endregion

--#region OUT OF COMBAT

---@class (exact) ERAHUDUtilityIconOutOfCombat : ERAHUDUtilityIcon
---@field private __index unknown
---@field protected constructUtilityIconOutOfCombat fun(this:ERAHUDUtilityIconOutOfCombat, hud:ERAHUD, iconID:integer, talent:ERALIBTalent|nil)
---@field private update fun(this:ERAHUDUtilityIconOutOfCombat, combat:boolean, t:number)
---@field protected updateOutOfCombat fun(this:ERAHUDUtilityIconOutOfCombat, t:number)
ERAHUDUtilityIconOutOfCombat = {}
ERAHUDUtilityIconOutOfCombat.__index = ERAHUDUtilityIconOutOfCombat
setmetatable(ERAHUDUtilityIconOutOfCombat, { __index = ERAHUDUtilityIcon })

---@param iconID integer
---@param talent ERALIBTalent|nil
function ERAHUDUtilityIconOutOfCombat:constructUtilityIconOutOfCombat(hud, iconID, talent)
    self:constructUtilityIcon(hud, iconID, talent)
end

---@param combat boolean
---@param t number
function ERAHUDUtilityIconOutOfCombat:update(combat, t)
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
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(aura.spellID)
        iconID = spellInfo.iconID
    end
    a:constructUtilityIconOutOfCombat(aura.hud, iconID, talent)
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
        if self.aura.stacks > 0 then
            self.icon:SetMainText(tostring(self.aura.stacks))
        else
            self.icon:SetMainText(nil)
        end
        self.icon:SetOverlayAlpha(self.aura.remDuration / self.aura.totDuration)
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

--#endregion

--#endregion UTILITY

--#endregion ICONS

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
    hud:addMarker(m)
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
                self.line:SetStartPoint("RIGHT", frameOverlay, px, ERACombat_TimerIconCooldownSize / 2)
            else
                self.line:SetStartPoint("RIGHT", frameOverlay, px, -ERACombat_TimerIconCooldownSize / 2)
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
---@param timerHeight number
function ERAHUDEmpowerLevel:drawOrHideIfUnused(frameOverlay, timerHeight)
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
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, -timerHeight)
            else
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, -ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerHeight)
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
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, -timerHeight)
            else
                self.text:SetPoint("CENTER", frameOverlay, "RIGHT", (startPixel + endPixel) / 2, -ERAHUD_TimerIconSize / 2)
                self.tick:SetStartPoint("RIGHT", frameOverlay, endPixel, -ERAHUD_TimerIconSize)
                self.tick:SetEndPoint("RIGHT", frameOverlay, endPixel, timerHeight)
            end
            self:show()
        end
    else
        self:hide()
    end
end

--#endregion

--#endregion

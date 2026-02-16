----------------------------------------------------------------
--#region GENERIC ICON -----------------------------------------

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

---comment
---@param size number
function HUDIcon:setSize(size)
    self.icon:SetSize(size)
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

---@class (exact) HUDPieIcon : HUDIcon
---@field private __index HUDPieIcon
---@field protected constructPie fun(self:HUDPieIcon, hud:HUDModule, frame:Frame, frameLevel:number, point:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", relativePoint:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", size:number, iconID:number, talent:ERALIBTalent|nil)
---@field protected icon ERAPieIcon
---@field IconUpdated nil|fun(self:HUDPieIcon, t:number, combat:boolean, icon:ERAPieIcon)
HUDPieIcon = {}
HUDPieIcon.__index = HUDPieIcon
setmetatable(HUDPieIcon, { __index = HUDIcon })

function HUDPieIcon:constructPie(hud, frame, frameLevel, point, relativePoint, size, iconID, talent)
    self.icon = ERAPieIcon:create(frame, point, relativePoint, size, iconID)
    self.icon:SetFrameLevel(frameLevel)
    self:constructIcon(hud, self.icon, talent)
end

---@param r number
---@param g number
---@param b number
function HUDPieIcon:SetBorderColor(r, g, b)
    self.icon:SetBorderColor(r, g, b)
end

---@param r number
---@param g number
---@param b number
function HUDPieIcon:SetMainTextColor(r, g, b)
    self.icon:SetMainTextColor(r, g, b, 1.0)
end

function HUDPieIcon:DisplayUpdated(t, combat)
    if (self.IconUpdated) then
        self:IconUpdated(t, combat, self.icon)
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region COOLDOWN ICON ----------------------------------------

---@class (exact) HUDCooldownIcon : HUDPieIcon
---@field private __index HUDCooldownIcon
---@field private data HUDCooldown
---@field private forcedIcon boolean
---@field OverrideCombatVisibilityAlpha nil|fun(self:HUDCooldownIcon): number
---@field OverrideSecondaryText nil|fun(self:HUDCooldownIcon): string
---@field OverrideDesaturation nil|fun(self:HUDCooldownIcon): number
---@field GetMainText nil|fun(self:HUDCooldownIcon): string|nil
---@field saturateWhenUsable boolean
---@field watchIconChange boolean
---@field watchAdditionalOverlay number
---@field showOnlyWhenUsableOrOverlay boolean
---@field preventDefaultOverlay boolean
---@field showOnlyIf HUDPublicBoolean|nil
HUDCooldownIcon = {}
HUDCooldownIcon.__index = HUDCooldownIcon
setmetatable(HUDCooldownIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param frameLevel number
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDCooldownIcon:create(frame, frameLevel, point, relativePoint, size, data, iconID, talent)
    local x = {}
    setmetatable(x, HUDCooldownIcon)
    ---@cast x HUDCooldownIcon
    if (iconID) then
        x.forcedIcon = true
    else
        x.forcedIcon = false
        local info = C_Spell.GetSpellInfo(data.spellID)
        if (info) then
            iconID = info.originalIconID
        else
            --print("unknown icon for " .. data.spellID)
            iconID = 134400 -- question mark
        end
    end
    x:constructPie(data.hud, frame, frameLevel, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data

    return x
end

function HUDCooldownIcon:HideCountdown()
    self.icon:HideDefaultCountdown()
end

function HUDCooldownIcon:talentIsActive()
    if (not self.forcedIcon) then
        local info = C_Spell.GetSpellInfo(self.data.spellID)
        if (info) then
            self.icon:SetIconTexture(info.iconID, false, false)
        end
    end
end

---comment
---@param t number
---@param combat boolean
function HUDCooldownIcon:Update(t, combat)
    if (self.showOnlyIf and not self.showOnlyIf.value) then
        self.icon:SetVisibilityAlpha(0.0, false)
        return
    end

    local usable = C_Spell.IsSpellUsable(self.data.spellID)

    local overlay
    if (self.preventDefaultOverlay) then
        overlay = false
    else
        if (self.watchAdditionalOverlay) then
            overlay = C_SpellActivationOverlay.IsSpellOverlayed(self.data.spellID) or C_SpellActivationOverlay.IsSpellOverlayed(self.watchAdditionalOverlay)
        else
            overlay = C_SpellActivationOverlay.IsSpellOverlayed(self.data.spellID)
        end
    end
    self.icon:SetHighlight(overlay)

    if (self.showOnlyWhenUsableOrOverlay and not (overlay or usable)) then
        self.icon:SetVisibilityAlpha(0.0, false)
        return
    end

    if (combat) then
        if (self.OverrideCombatVisibilityAlpha) then
            self.icon:SetVisibilityAlpha(self:OverrideCombatVisibilityAlpha(), true)
        else
            self.icon:SetVisibilityAlpha(1.0, false)
        end
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        self.icon:SetVisibilityAlpha(self.data.swipeDuration:EvaluateRemainingDuration(self.hud.curveHideLessThanOnePointFive), true)
    end
    self.icon:SetValue(self.data.swipeDuration:GetStartTime(), self.data.swipeDuration:GetTotalDuration())

    --self.icon:SetMainText(string.format("%i", self.data.swipeDuration:GetRemainingDuration()), true)
    if (self.GetMainText) then
        self.icon:SetMainText(self:GetMainText(), true)
    end

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
        if (self.saturateWhenUsable) then
            if (usable) then
                self.icon:SetDesaturation(0.0, false)
            else
                self.icon:SetDesaturation(1.0, false)
            end
        else
            if (self.data.hasCharges) then
                ---@diagnostic disable-next-line: param-type-mismatch
                self.icon:SetDesaturation(self.data.cooldownDuration:EvaluateRemainingDuration(self.hud.curveFalse0), true)
            else
                ---@diagnostic disable-next-line: param-type-mismatch
                self.icon:SetDesaturation(self.data.cooldownDuration:EvaluateRemainingDuration(self.hud.curveHideLessThanTen), true)
            end
        end
    end

    if (self.watchIconChange) then
        local info = C_Spell.GetSpellInfo(self.data.spellID)
        self.icon:SetIconTexture(info.iconID, false, false)
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region EQUIPMENT COOLDOWN ICON ------------------------------

---@class (exact) HUDEquipmentIcon : HUDPieIcon
---@field private __index HUDEquipmentIcon
---@field private data HUDEquipmentCooldown
HUDEquipmentIcon = {}
HUDEquipmentIcon.__index = HUDEquipmentIcon
setmetatable(HUDEquipmentIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param frameLevel number
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param data HUDEquipmentCooldown
---@param initIconID number
---@return HUDEquipmentIcon
function HUDEquipmentIcon:Create(frame, frameLevel, point, relativePoint, size, data, initIconID)
    local x = {}
    setmetatable(x, HUDEquipmentIcon)
    ---@cast x HUDEquipmentIcon
    x:constructPie(data.hud, frame, frameLevel, point, relativePoint, size, initIconID, data.talent)
    x.data = data
    return x
end

function HUDEquipmentIcon:talentIsActive()
    --[[
    local itemID = GetInventoryItemID("player", self.data.slot)
    if (itemID) then
    end
    self:actuallyDeactivate()
    ]]
    local location = ItemLocation:CreateFromEquipmentSlot(self.data.slot)
    if (location) then
        local success, icon = pcall(function() return C_Item.GetItemIcon(location) end)
        if (success and icon) then
            self.icon:SetIconTexture(icon, false, false)
        end
    end
end

---comment
---@param t number
---@param combat boolean
function HUDEquipmentIcon:Update(t, combat)
    self.icon:SetValue(self.data.start, self.data.duration)
    local alpha
    if (combat) then
        alpha = 1.0
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        if (issecretvalue(self.data.start) or issecretvalue(self.data.duration)) then
            alpha = 1.0
        else
            if (self.data.start and self.data.start > 0) then
                alpha = 1.0
            else
                alpha = 0.0
            end
        end
    end
    self.icon:SetVisibilityAlpha(alpha, false)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region AURA ICON --------------------------------------------

---@class (exact) HUDAuraIcon : HUDPieIcon
---@field private __index HUDAuraIcon
---@field private data HUDAura
---@field private stackMode boolean
---@field private forcedIcon boolean
---@field private displayAsCooldown boolean
---@field showOnlyIf HUDPublicBoolean|nil
---@field showRedIfMissingInCombat boolean
---@field alwaysHideOutOfCombat boolean
---@field watchIconChange boolean
---@field GetMainText nil|fun(self:HUDAuraIcon): string|nil
HUDAuraIcon = {}
HUDAuraIcon.__index = HUDAuraIcon
setmetatable(HUDAuraIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param frameLevel number
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param displayAsCooldown boolean|nil
---@return HUDAuraIcon
function HUDAuraIcon:create(frame, frameLevel, point, relativePoint, size, data, iconID, talent, displayAsCooldown)
    local x = {}
    setmetatable(x, HUDAuraIcon)
    ---@cast x HUDAuraIcon
    if (iconID) then
        x.forcedIcon = true
    else
        x.forcedIcon = false
        local info = C_Spell.GetSpellInfo(data.spellID)
        if (info) then
            iconID = info.originalIconID
        else
            iconID = 134400 -- queston mark
        end
    end
    x:constructPie(data.hud, frame, frameLevel, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data
    if (displayAsCooldown) then
        x.displayAsCooldown = true
    else
        x.icon:SetupAura()
    end
    return x
end

function HUDAuraIcon:ShowStacksRatherThanDuration()
    self.icon:HideDefaultCountdown()
    self.stackMode = true
end
function HUDAuraIcon:HideCountdown()
    self.icon:HideDefaultCountdown()
end

---comment
---@param t number
---@param combat boolean
function HUDAuraIcon:Update(t, combat)
    if (self.showOnlyIf and not self.showOnlyIf.value) then
        self.icon:SetVisibilityAlpha(0.0, false)
        return
    end
    if (self.alwaysHideOutOfCombat and not combat) then
        self.icon:SetVisibilityAlpha(0.0, false)
        return
    end
    if (self.data.auraIsPresent) then
        self.icon:SetVisibilityAlpha(1.0, false)
        self.icon:SetTint(1.0, 1.0, 1.0, false)
    else
        if (combat) then
            if (self.showRedIfMissingInCombat) then
                self.icon:SetTint(1.0, 0.0, 0.0, false)
                self.icon:SetVisibilityAlpha(1.0, false)
            elseif (self.displayAsCooldown) then
                self.icon:SetVisibilityAlpha(1.0, false)
            else
                self.icon:SetVisibilityAlpha(0.0, false)
                return
            end
        else
            self.icon:SetVisibilityAlpha(0.0, false)
            return
        end
    end
    if (self.stackMode) then
        self.icon:SetMainText(self.data.stacksDisplay, true)
    else
        self.icon:SetSecondaryText(self.data.stacksDisplay, true)
        if (self.GetMainText) then
            self.icon:SetMainText(self:GetMainText(), true)
        end
    end
    self.icon:SetValue(self.data.timerDuration:GetStartTime(), self.data.timerDuration:GetTotalDuration())

    if (self.watchIconChange and self.data.icon) then
        self.icon:SetIconTexture(self.data.icon, false, true)
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region BAG ITEM ICON ----------------------------------------

---@class (exact) HUDBagItemIcon : HUDPieIcon
---@field private __index HUDBagItemIcon
---@field private data HUDBagItem
---@field private rTintIfMissing number
---@field private gTintIfMissing number
---@field private bTintIfMissing number
HUDBagItemIcon = {}
HUDBagItemIcon.__index = HUDBagItemIcon
setmetatable(HUDBagItemIcon, { __index = HUDPieIcon })

---comment
---@param frame Frame
---@param frameLevel number
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param data HUDBagItem
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return HUDBagItemIcon
function HUDBagItemIcon:create(frame, frameLevel, point, relativePoint, size, data, iconID, talent)
    local x = {}
    setmetatable(x, HUDBagItemIcon)
    ---@cast x HUDBagItemIcon
    if (not iconID) then
        _, _, _, _, _, _, _, _, _, iconID = C_Item.GetItemInfo(data.itemID)
        if (not iconID) then
            local asyncItem = Item:CreateFromItemID(data.itemID)
            asyncItem:ContinueOnItemLoad(function()
                local asyncIcon = asyncItem:GetItemIcon()
                if (asyncIcon) then
                    ---@diagnostic disable-next-line: invisible
                    x.icon:SetIconTexture(asyncIcon, false, false)
                end
            end)
            iconID = 134400 -- queston mark
        end
    end
    x:constructPie(data.hud, frame, frameLevel, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data
    x.rTintIfMissing = 1.0
    x.gTintIfMissing = 0.0
    x.bTintIfMissing = 0.0

    return x
end

---@param r number
---@param g number
---@param b number
function HUDBagItemIcon:SetTintWhenMissing(r, g, b)
    self.rTintIfMissing = r
    self.gTintIfMissing = g
    self.bTintIfMissing = b
end

---comment
---@param t number
---@param combat boolean
function HUDBagItemIcon:Update(t, combat)
    if (self.data.hasItem) then
        if (combat) then
            self.icon:SetVisibilityAlpha(1.0, false)
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            self.icon:SetVisibilityAlpha(self.data.timerDuration:EvaluateRemainingDuration(self.hud.curveHideLessThanOnePointFive), true)
        end
        self.icon:SetValue(self.data.timerDuration:GetStartTime(), self.data.timerDuration:GetTotalDuration())
        self.icon:SetSecondaryText(self.data.stacks, true)
        self.icon:SetTint(1.0, 1.0, 1.0, false)
    else
        self.icon:SetVisibilityAlpha(1.0, false)
        self.icon:SetSecondaryText(nil, false)
        self.icon:SetValue(0, 1)
        self.icon:SetTint(self.rTintIfMissing, self.gTintIfMissing, self.bTintIfMissing, false)
    end
end

--#endregion
----------------------------------------------------------------

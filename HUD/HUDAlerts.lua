---@class (exact) HUDAlert : HUDDisplay
---@field private __index HUDAlert
---@field protected constructAlert fun(self:HUDAlert, hud:HUDModule, talent:ERALIBTalent|nil)
---@field updateLayout fun(self:HUDAlert, options:ERACombatSpecOptions)
HUDAlert = {}
HUDAlert.__index = HUDAlert
setmetatable(HUDAlert, { __index = HUDDisplay })

function HUDAlert:constructAlert(hud, talent)
    self:constructDisplay(hud, talent)
    hud:addAlert(self)
end

----------------------------------------------------------------
--#region SAO --------------------------------------------------

---@alias SAOTransform "NONE"|"ROTATE_LEFT"|"ROTATE_RIGHT"|"MIRROR_H"|"MIRROR_V"
---@alias SAOPosition "LEFT"|"TOP"|"RIGHT"|"BOTTOM"|"CENTER"
---@alias SAOShape "V"|"H"|"C"

---@class (exact) HUDSAOAlert : HUDAlert
---@field private __index HUDSAOAlert
---@field private anim AnimationGroup
---@field private position SAOPosition
---@field private shape SAOShape
---@field private anchor "LEFT"|"TOP"|"BOTTOM"|"RIGHT"|"CENTER"
---@field private directX number
---@field private directY number
---@field private flipWH boolean
---@field protected frame Frame
---@field protected constructSAO fun(self:HUDSAOAlert, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean, transform:SAOTransform, position:SAOPosition)
---@field protected deactivated nil|fun(self:HUDSAOAlert)
---@field protected playBeam fun(self:HUDSAOAlert)
---@field protected stopBeam fun(self:HUDSAOAlert)
HUDSAOAlert = {}
HUDSAOAlert.__index = HUDSAOAlert
setmetatable(HUDSAOAlert, { __index = HUDAlert })

function HUDSAOAlert:constructSAO(hud, talent, texture, isAtlas, transform, position)
    self:constructAlert(hud, talent)
    self.frame = CreateFrame("Frame", nil, UIParent)
    self.frame:Hide()
    local t = self.frame:CreateTexture(nil, "ARTWORK")
    t:SetAllPoints()
    if (isAtlas) then
        ---@diagnostic disable-next-line: param-type-mismatch
        t:SetAtlas(texture)
    else
        t:SetTexture(texture)
    end

    if (transform == "MIRROR_H" or transform == "MIRROR_V") then
        local texLeft, texRight, texTop, texBottom = 0, 1, 0, 1
        if transform == "MIRROR_H" then
            texLeft, texRight = 1, 0
        end
        if transform == "MIRROR_V" then
            texTop, texBottom = 1, 0
        end
        t:SetTexCoord(texLeft, texRight, texTop, texBottom)
    elseif (transform == "ROTATE_LEFT") then
        t:SetRotation(math.rad(90))
        self.flipWH = true
    elseif (transform == "ROTATE_RIGHT") then
        t:SetRotation(math.rad(-90))
        self.flipWH = true
    end
    self.position = position
    if (position == "LEFT") then
        self.shape = "V"
        self.anchor = "RIGHT"
        self.directX = -1
        self.directY = 0
    elseif (position == "TOP") then
        self.shape = "H"
        self.anchor = "BOTTOM"
        self.directX = 0
        self.directY = 1
    elseif (position == "RIGHT") then
        self.shape = "V"
        self.anchor = "LEFT"
        self.directX = 1
        self.directY = 0
    elseif (position == "BOTTOM") then
        self.shape = "H"
        self.anchor = "TOP"
        self.directX = 0
        self.directY = -1
    else
        self.shape = "C"
        self.anchor = "CENTER"
        self.directX = 0
        self.directY = 0
    end

    self.anim = self.frame:CreateAnimationGroup()
    local animPulseBig = self.anim:CreateAnimation("Scale")
    ---@cast animPulseBig Scale
    animPulseBig:SetDuration(0.5)
    animPulseBig:SetScale(1.25, 1.25)
    animPulseBig:SetSmoothing("IN_OUT")
    animPulseBig:SetOrder(1)
    local animPulseSmall = self.anim:CreateAnimation("Scale")
    ---@cast animPulseSmall Scale
    animPulseSmall:SetDuration(0.5)
    animPulseSmall:SetScale(0.8, 0.8)
    animPulseSmall:SetSmoothing("IN_OUT")
    animPulseSmall:SetOrder(2)
    self.anim:SetLooping("REPEAT")
end

function HUDSAOAlert:Deactivate()
    self.frame:Hide()
    self:stopBeam()
    if (self.deactivated) then
        self:deactivated()
    end
end

function HUDSAOAlert:playBeam()
    self.anim:Play()
end
function HUDSAOAlert:stopBeam()
    self.anim:Stop()
end

---@param options ERACombatSpecOptions
function HUDSAOAlert:updateLayout(options)
    self.frame:SetPoint(self.anchor, UIParent, "CENTER", options.alertOffset * self.directX, options.alertOffset * self.directY)
    if (self.shape == "V") then
        if (self.flipWH) then
            self.frame:SetSize(2 * options.alertSize, options.alertSize)
        else
            self.frame:SetSize(options.alertSize, 2 * options.alertSize)
        end
    elseif (self.shape == "H") then
        if (self.flipWH) then
            self.frame:SetSize(options.alertSize, 2 * options.alertSize)
        else
            self.frame:SetSize(2 * options.alertSize, options.alertSize)
        end
    else
        self.frame:SetSize(0.88 * options.alertSize, 0.88 * options.alertSize)
    end
end

---@class (exact) HUDSAOAlertBasicBoolean : HUDSAOAlert
---@field private __index HUDSAOAlertBasicBoolean
---@field protected constructBooleanSAO fun(self:HUDSAOAlertBasicBoolean, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean, transform:SAOTransform, position:SAOPosition)
---@field private visible boolean
---@field protected getIsVisible fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean): boolean
---@field protected appears nil|fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean)
---@field protected disappears nil|fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean)
---@field showOnlyWhenInCombatWithEnemyTarget boolean
---@field playSoundWhenApperars nil|number
HUDSAOAlertBasicBoolean = {}
HUDSAOAlertBasicBoolean.__index = HUDSAOAlertBasicBoolean
setmetatable(HUDSAOAlertBasicBoolean, { __index = HUDSAOAlert })

function HUDSAOAlertBasicBoolean:constructBooleanSAO(hud, talent, texture, isAtlas, transform, position)
    self:constructSAO(hud, talent, texture, isAtlas, transform, position)
    self.visible = false
    self.frame:Hide()
end

function HUDSAOAlertBasicBoolean:deactivated()
    self.visible = false
end
function HUDSAOAlertBasicBoolean:Activate()
    if (self.visible) then
        self.visible = false
        self.frame:Hide()
    end
end

---@param t number
---@param combat boolean
function HUDSAOAlertBasicBoolean:Update(t, combat)
    local visible
    if (self.showOnlyWhenInCombatWithEnemyTarget and not (combat and self.hud.hasEnemyTarget)) then
        visible = false
    else
        visible = self:getIsVisible(t, combat)
    end
    if (visible) then
        if (not self.visible) then
            self.visible = true
            self.frame:Show()
            self:playBeam()
            if (self.appears) then
                self:appears(t, combat)
            end
            if (self.playSoundWhenApperars) then
                ---@diagnostic disable-next-line: param-type-mismatch
                C_Sound.PlaySound(self.playSoundWhenApperars, "SFX", true)
            end
        end
    else
        if (self.visible) then
            self.visible = false
            self.frame:Hide()
            self:stopBeam()
            if (self.disappears) then
                self:disappears(t, combat)
            end
        end
    end
end

---@class (exact) HUDSAOAlertAura : HUDSAOAlertBasicBoolean
---@field private __index HUDSAOAlertAura
---@field private data HUDAura
HUDSAOAlertAura = {}
HUDSAOAlertAura.__index = HUDSAOAlertAura
setmetatable(HUDSAOAlertAura, { __index = HUDSAOAlertBasicBoolean })

---@param hud HUDModule
---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertAura
function HUDSAOAlertAura:create(hud, data, talent, texture, isAtlas, transform, position)
    local x = {}
    setmetatable(x, HUDSAOAlertAura)
    ---@cast x HUDSAOAlertAura
    x:constructBooleanSAO(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas, transform, position)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertAura:getIsVisible(t, combat)
    return self.data.auraIsActive
end

---@class (exact) HUDSAOAlertBasicBooleanDelay : HUDSAOAlertBasicBoolean
---@field private __index HUDSAOAlertBasicBooleanDelay
---@field private showOutOfCombat boolean
---@field private delay number
---@field private start_active number
---@field protected getIsVisibleRegardlessOfDelay fun(self:HUDSAOAlertBasicBooleanDelay, t:number, combat:boolean): boolean
---@field protected constructAlertBooleanDelay fun(self:HUDSAOAlertBasicBooleanDelay, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean, transform:SAOTransform, position:SAOPosition, delay:number, showOutOfCombat:boolean)
HUDSAOAlertBasicBooleanDelay = {}
HUDSAOAlertBasicBooleanDelay.__index = HUDSAOAlertBasicBooleanDelay
setmetatable(HUDSAOAlertBasicBooleanDelay, { __index = HUDSAOAlertBasicBoolean })

---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param transform SAOTransform
---@param position SAOPosition
---@param delay number
---@param showOutOfCombat boolean
function HUDSAOAlertBasicBooleanDelay:constructAlertBooleanDelay(hud, talent, texture, isAtlas, transform, position, delay, showOutOfCombat)
    self:constructBooleanSAO(hud, talent, texture, isAtlas, transform, position)
    self.delay = delay
    self.showOutOfCombat = showOutOfCombat
    self.start_active = -1
end

---@param t number
---@param combat boolean
function HUDSAOAlertBasicBooleanDelay:getIsVisible(t, combat)
    if (self:getIsVisibleRegardlessOfDelay(t, combat)) then
        if ((not combat) and not self.showOutOfCombat) then
            self.start_active = -1
            return false
        end
        if (self.start_active < 0) then
            self.start_active = t
            return false
        else
            return t - self.start_active > self.delay
        end
    else
        self.start_active = -1
        return false
    end
end

---@class (exact) HUDSAOAlertMissingAura : HUDSAOAlertBasicBooleanDelay
---@field private __index HUDSAOAlertMissingAura
---@field private data HUDAura
HUDSAOAlertMissingAura = {}
HUDSAOAlertMissingAura.__index = HUDSAOAlertMissingAura
setmetatable(HUDSAOAlertMissingAura, { __index = HUDSAOAlertBasicBooleanDelay })

---@param hud HUDModule
---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param showOutOfCombat boolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertMissingAura
function HUDSAOAlertMissingAura:create(hud, data, talent, texture, isAtlas, showOutOfCombat, transform, position)
    local x = {}
    setmetatable(x, HUDSAOAlertMissingAura)
    ---@cast x HUDSAOAlertMissingAura
    x:constructAlertBooleanDelay(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas, transform, position, 0.42, showOutOfCombat)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertMissingAura:getIsVisibleRegardlessOfDelay(t, combat)
    return not self.data.auraIsActive
end

---@class (exact) HUDSAOAlertPublicBoolean : HUDSAOAlertBasicBooleanDelay
---@field private __index HUDSAOAlertPublicBoolean
---@field private data HUDPublicBoolean
HUDSAOAlertPublicBoolean = {}
HUDSAOAlertPublicBoolean.__index = HUDSAOAlertPublicBoolean
setmetatable(HUDSAOAlertPublicBoolean, { __index = HUDSAOAlertBasicBooleanDelay })

---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param data HUDPublicBoolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertPublicBoolean
function HUDSAOAlertPublicBoolean:create(hud, talent, texture, isAtlas, data, transform, position)
    local x = {}
    setmetatable(x, HUDSAOAlertPublicBoolean)
    ---@cast x HUDSAOAlertPublicBoolean
    x:constructAlertBooleanDelay(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas, transform, position, 0.16, true)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertPublicBoolean:getIsVisibleRegardlessOfDelay(t, combat)
    return self.data.value
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region ICON -------------------------------------------------

---@class (exact) HUDIconAlert : HUDIcon
---@field private __index HUDIconAlert
---@field protected icon ERASquareIcon
---@field protected constructIconAlert fun(self:HUDIconAlert, hud:HUDModule, parentFrame:Frame, frameLevel:number, point:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", relativePoint:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", size:number, iconID:number, talent:ERALIBTalent|nil)
---@field protected getIsVisible fun(self:HUDIconAlert, t:number, combat:boolean): boolean
HUDIconAlert = {}
HUDIconAlert.__index = HUDIconAlert
setmetatable(HUDIconAlert, { __index = HUDIcon })

function HUDIconAlert:constructIconAlert(hud, parentFrame, frameLevel, point, relativePoint, size, iconID, talent)
    self.icon = ERASquareIcon:create(parentFrame, point, relativePoint, size, iconID)
    self.icon:SetFrameLevel(frameLevel)
    self.icon:SetActiveShown(false)
    self.icon:Beam()
    self:constructIcon(hud, self.icon, talent)
end

---comment
---@param t number
---@param combat boolean
function HUDIconAlert:Update(t, combat)
    self.icon:SetActiveShown(self:getIsVisible(t, combat))
end

---@class (exact) HUDIconMissingAuraAlert : HUDIconAlert
---@field private __index HUDIconMissingAuraAlert
---@field private data HUDAura
HUDIconMissingAuraAlert = {}
HUDIconMissingAuraAlert.__index = HUDIconMissingAuraAlert
setmetatable(HUDIconMissingAuraAlert, { __index = HUDIconAlert })

---@param parentFrame Frame
---@param frameLevel integer
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param talent ERALIBTalent|nil
---@param iconID integer|nil
---@param data HUDAura
---@return HUDIconMissingAuraAlert
function HUDIconMissingAuraAlert:create(parentFrame, frameLevel, point, relativePoint, size, talent, iconID, data)
    local x = {}
    setmetatable(x, HUDIconMissingAuraAlert)
    ---@cast x HUDIconMissingAuraAlert
    if (not iconID) then
        local info = C_Spell.GetSpellInfo(data.spellID)
        if (info) then
            iconID = info.originalIconID
        else
            iconID = 134400 -- queston mark
        end
    end
    x:constructIconAlert(data.hud, parentFrame, frameLevel, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data
    return x
end

---comment
---@param t number
---@param combat boolean
---@return boolean
function HUDIconMissingAuraAlert:getIsVisible(t, combat)
    if (self.data.auraIsActive) then
        return false
    else
        if (combat) then
            self.icon:Beam()
        else
            self.icon:StopBeam()
        end
    end
    return true
end

---@class (exact) HUDIconBooleanAlert : HUDIconAlert
---@field private __index HUDIconBooleanAlert
---@field private data HUDPublicBoolean
HUDIconBooleanAlert = {}
HUDIconBooleanAlert.__index = HUDIconBooleanAlert
setmetatable(HUDIconBooleanAlert, { __index = HUDIconAlert })

---@param parentFrame Frame
---@param frameLevel integer
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param talent ERALIBTalent|nil
---@param iconID integer
---@param data HUDPublicBoolean
---@return HUDIconBooleanAlert
function HUDIconBooleanAlert:create(parentFrame, frameLevel, point, relativePoint, size, talent, iconID, data)
    local x = {}
    setmetatable(x, HUDIconBooleanAlert)
    ---@cast x HUDIconBooleanAlert
    x:constructIconAlert(data.hud, parentFrame, frameLevel, point, relativePoint, size, iconID, ERALIBTalent_CombineMakeAnd(talent, data.talent))
    x.data = data
    return x
end

---comment
---@param t number
---@param combat boolean
---@return boolean
function HUDIconBooleanAlert:getIsVisible(t, combat)
    if (self.data.value) then
        if (combat) then
            self.icon:Beam()
        else
            self.icon:StopBeam()
        end
    else
        return false
    end
    return true
end

--#endregion
----------------------------------------------------------------

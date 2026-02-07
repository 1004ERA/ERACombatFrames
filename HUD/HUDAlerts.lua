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

---@class (exact) HUDSAOAlert : HUDAlert
---@field private __index HUDSAOAlert
---@field private anim AnimationGroup
---@field protected frame Frame
---@field protected constructSAO fun(self:HUDSAOAlert, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean)
---@field protected deactivated nil|fun(self:HUDSAOAlert)
---@field protected playBeam fun(self:HUDSAOAlert)
---@field protected stopBeam fun(self:HUDSAOAlert)
HUDSAOAlert = {}
HUDSAOAlert.__index = HUDSAOAlert
setmetatable(HUDSAOAlert, { __index = HUDAlert })

function HUDSAOAlert:constructSAO(hud, talent, texture, isAtlas)
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
    self.frame:SetPoint("CENTER", UIParent, "CENTER", options.alertX, options.alertY)
    self.frame:SetSize(options.alertWidth, options.alertHeight)
end

---@class (exact) HUDSAOAlertPublicBoolean : HUDSAOAlert
---@field private __index HUDSAOAlertPublicBoolean
---@field protected constructBooleanSAO fun(self:HUDSAOAlertPublicBoolean, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean)
---@field private visible boolean
---@field protected getIsVisible fun(self:HUDSAOAlertPublicBoolean, t:number, combat:boolean): boolean
---@field protected appears nil|fun(self:HUDSAOAlertPublicBoolean, t:number, combat:boolean)
---@field protected disappears nil|fun(self:HUDSAOAlertPublicBoolean, t:number, combat:boolean)
---@field playSoundWhenApperars nil|number
HUDSAOAlertPublicBoolean = {}
HUDSAOAlertPublicBoolean.__index = HUDSAOAlertPublicBoolean
setmetatable(HUDSAOAlertPublicBoolean, { __index = HUDSAOAlert })

function HUDSAOAlertPublicBoolean:constructBooleanSAO(hud, talent, texture, isAtlas)
    self:constructSAO(hud, talent, texture, isAtlas)
    self.visible = false
    self.frame:Hide()
end

function HUDSAOAlertPublicBoolean:deactivated()
    self.visible = false
end
function HUDSAOAlertPublicBoolean:Activate()
    if (self.visible) then
        self.visible = false
        self.frame:Hide()
    end
end

---@param t number
---@param combat boolean
function HUDSAOAlertPublicBoolean:Update(t, combat)
    local visible = self:getIsVisible(t, combat)
    if (visible) then
        if (not self.visible) then
            self.visible = true
            self.frame:Show()
            self:playBeam()
            if (self.appears) then
                self:appears(t, combat)
            end
            if (self.playSoundWhenApperars) then
                C_Sound.PlaySound(self.playSoundWhenApperars)
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

---@class (exact) HUDSAOAlertAura : HUDSAOAlertPublicBoolean
---@field private __index HUDSAOAlertAura
---@field private data HUDAura
HUDSAOAlertAura = {}
HUDSAOAlertAura.__index = HUDSAOAlertAura
setmetatable(HUDSAOAlertAura, { __index = HUDSAOAlertPublicBoolean })

---@param hud HUDModule
---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@return HUDSAOAlertAura
function HUDSAOAlertAura:create(hud, data, talent, texture, isAtlas)
    local x = {}
    setmetatable(x, HUDSAOAlertAura)
    ---@cast x HUDSAOAlertAura
    x:constructBooleanSAO(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertAura:getIsVisible(t, combat)
    return self.data.auraIsPresent
end

---@class (exact) HUDSAOAlertMissingAura : HUDSAOAlertPublicBoolean
---@field private __index HUDSAOAlertMissingAura
---@field private data HUDAura
---@field showOutOfCombat boolean
HUDSAOAlertMissingAura = {}
HUDSAOAlertMissingAura.__index = HUDSAOAlertMissingAura
setmetatable(HUDSAOAlertMissingAura, { __index = HUDSAOAlertPublicBoolean })

---@param hud HUDModule
---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param showOutOfCombat boolean
---@return HUDSAOAlertMissingAura
function HUDSAOAlertMissingAura:create(hud, data, talent, texture, isAtlas, showOutOfCombat)
    local x = {}
    setmetatable(x, HUDSAOAlertMissingAura)
    ---@cast x HUDSAOAlertMissingAura
    x:constructBooleanSAO(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas)
    x.data = data
    x.showOutOfCombat = showOutOfCombat
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertMissingAura:getIsVisible(t, combat)
    if (self.showOutOfCombat or combat) then
        return not self.data.auraIsPresent
    else
        return false
    end
end

---@class (exact) HUDSAOAlertSpellOverlay : HUDSAOAlertPublicBoolean
---@field private __index HUDSAOAlertSpellOverlay
---@field private mainSpellID number
HUDSAOAlertSpellOverlay = {}
HUDSAOAlertSpellOverlay.__index = HUDSAOAlertSpellOverlay
setmetatable(HUDSAOAlertSpellOverlay, { __index = HUDSAOAlertPublicBoolean })

---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param mainSpellID number
---@return HUDSAOAlertSpellOverlay
function HUDSAOAlertSpellOverlay:create(hud, talent, texture, isAtlas, mainSpellID)
    local x = {}
    setmetatable(x, HUDSAOAlertSpellOverlay)
    ---@cast x HUDSAOAlertSpellOverlay
    x:constructBooleanSAO(hud, talent, texture, isAtlas)
    x.mainSpellID = mainSpellID
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertSpellOverlay:getIsVisible(t, combat)
    return C_SpellActivationOverlay.IsSpellOverlayed(self.mainSpellID)
end

---@class (exact) HUDSAOAlertSpellIcon : HUDSAOAlertPublicBoolean
---@field private __index HUDSAOAlertSpellIcon
---@field private spellID number
---@field private iconID number
HUDSAOAlertSpellIcon = {}
HUDSAOAlertSpellIcon.__index = HUDSAOAlertSpellIcon
setmetatable(HUDSAOAlertSpellIcon, { __index = HUDSAOAlertPublicBoolean })

---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param spellID number
---@param iconID number
---@return HUDSAOAlertSpellIcon
function HUDSAOAlertSpellIcon:create(hud, talent, texture, isAtlas, spellID, iconID)
    local x = {}
    setmetatable(x, HUDSAOAlertSpellIcon)
    ---@cast x HUDSAOAlertSpellIcon
    x:constructBooleanSAO(hud, talent, texture, isAtlas)
    x.spellID = spellID
    x.iconID = iconID
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertSpellIcon:getIsVisible(t, combat)
    local info = C_Spell.GetSpellInfo(self.spellID)
    if (info) then
        return info.iconID == self.iconID
    else
        return false
    end
end

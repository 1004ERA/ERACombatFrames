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

---@class (exact) HUDSAOAlertBasicBoolean : HUDSAOAlert
---@field private __index HUDSAOAlertBasicBoolean
---@field protected constructBooleanSAO fun(self:HUDSAOAlertBasicBoolean, hud:HUDModule, talent:ERALIBTalent|nil, texture:number|string, isAtlas:boolean)
---@field private visible boolean
---@field protected getIsVisible fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean): boolean
---@field protected appears nil|fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean)
---@field protected disappears nil|fun(self:HUDSAOAlertBasicBoolean, t:number, combat:boolean)
---@field playSoundWhenApperars nil|number
HUDSAOAlertBasicBoolean = {}
HUDSAOAlertBasicBoolean.__index = HUDSAOAlertBasicBoolean
setmetatable(HUDSAOAlertBasicBoolean, { __index = HUDSAOAlert })

function HUDSAOAlertBasicBoolean:constructBooleanSAO(hud, talent, texture, isAtlas)
    self:constructSAO(hud, talent, texture, isAtlas)
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

---@class (exact) HUDSAOAlertMissingAura : HUDSAOAlertBasicBoolean
---@field private __index HUDSAOAlertMissingAura
---@field private data HUDAura
---@field showOutOfCombat boolean
HUDSAOAlertMissingAura = {}
HUDSAOAlertMissingAura.__index = HUDSAOAlertMissingAura
setmetatable(HUDSAOAlertMissingAura, { __index = HUDSAOAlertBasicBoolean })

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

---@class (exact) HUDSAOAlertPublicBoolean : HUDSAOAlertBasicBoolean
---@field private __index HUDSAOAlertPublicBoolean
---@field private data HUDPublicBoolean
HUDSAOAlertPublicBoolean = {}
HUDSAOAlertPublicBoolean.__index = HUDSAOAlertPublicBoolean
setmetatable(HUDSAOAlertPublicBoolean, { __index = HUDSAOAlertBasicBoolean })

---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param data HUDPublicBoolean
---@return HUDSAOAlertPublicBoolean
function HUDSAOAlertPublicBoolean:create(hud, talent, texture, isAtlas, data)
    local x = {}
    setmetatable(x, HUDSAOAlertPublicBoolean)
    ---@cast x HUDSAOAlertPublicBoolean
    x:constructBooleanSAO(hud, talent, texture, isAtlas)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertPublicBoolean:getIsVisible(t, combat)
    return self.data.value
end

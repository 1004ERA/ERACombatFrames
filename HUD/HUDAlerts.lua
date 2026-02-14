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
    return self.data.auraIsPresent
end

---@class (exact) HUDSAOAlertMissingAura : HUDSAOAlertBasicBoolean
---@field private __index HUDSAOAlertMissingAura
---@field private data HUDAura
---@field private start_active number
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
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertMissingAura
function HUDSAOAlertMissingAura:create(hud, data, talent, texture, isAtlas, showOutOfCombat, transform, position)
    local x = {}
    setmetatable(x, HUDSAOAlertMissingAura)
    ---@cast x HUDSAOAlertMissingAura
    x:constructBooleanSAO(hud, ERALIBTalent_CombineMakeAnd(talent, data.talent), texture, isAtlas, transform, position)
    x.data = data
    x.showOutOfCombat = showOutOfCombat
    x.start_active = -1
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertMissingAura:getIsVisible(t, combat)
    if (self.data.auraIsPresent) then
        self.start_active = -1
        return false
    else
        if ((not combat) and not self.showOutOfCombat) then
            return false
        end
        if (self.start_active < 0) then
            self.start_active = t
            return false
        else
            return t - self.start_active > 0.13
        end
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
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertPublicBoolean
function HUDSAOAlertPublicBoolean:create(hud, talent, texture, isAtlas, data, transform, position)
    local x = {}
    setmetatable(x, HUDSAOAlertPublicBoolean)
    ---@cast x HUDSAOAlertPublicBoolean
    x:constructBooleanSAO(hud, talent, texture, isAtlas, transform, position)
    x.data = data
    return x
end

---@param t number
---@param combat boolean
function HUDSAOAlertPublicBoolean:getIsVisible(t, combat)
    return self.data.value
end

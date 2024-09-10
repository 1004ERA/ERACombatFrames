---@class (exact) ERATimer
---@field private __index unknown
---@field remDuration number
---@field totDuration number
---@field hud ERAHUD
---@field talentActive boolean
---@field checkTalent fun(this:ERATimer): boolean
---@field protected checkTimerTalent fun(this:ERATimer): boolean
---@field updateData fun(this:ERATimer, t:number)
ERATimer = {}
ERATimer.__index = ERATimer

---@param hud ERAHUD
function ERATimer:constructTimer(hud)
    self.hud = hud
    self.remDuration = 0
    self.totDuration = 1
    hud:addTimer(self)
end

function ERATimer:checkTalent()
    if (self:checkTimerTalent()) then
        self.talentActive = true
        return true
    else
        self.talentActive = false
        self.remDuration = 0
        return false
    end
end

---@class (exact) ERACooldownAdditionalID
---@field spellID integer
---@field talent ERALIBTalent

---@class (exact) ERATimerWithID : ERATimer
---@field private __index unknown
---@field spellID integer
---@field private mainSpellID integer
---@field private talent ERALIBTalent | nil
---@field private mainTalent ERALIBTalent | nil
---@field private additionalSpellIDs ERACooldownAdditionalID[]
ERATimerWithID = {}
ERATimerWithID.__index = ERATimerWithID
setmetatable(ERATimerWithID, { __index = ERATimer })

---@param hud ERAHUD
---@param spellID integer
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERATimerWithID:constructID(hud, spellID, talent, ...)
    self:constructTimer(hud)
    self.spellID = spellID
    self.mainSpellID = spellID
    self.talent = talent
    self.mainTalent = talent
    self.additionalSpellIDs = { ... }
end

function ERATimerWithID:checkTimerTalent()
    self.talent = self.mainTalent
    self.spellID = self.mainSpellID
    for _, info in ipairs(self.additionalSpellIDs) do
        if (info.talent:PlayerHasTalent()) then
            self.talent = info.talent
            self.spellID = info.spellID
            break
        end
    end
    return not (self.talent and not self.talent:PlayerHasTalent())
end

----------------
--- COOLDOWN ---
----------------

---@class (exact) ERACooldownBase : ERATimerWithID
---@field private __index unknown
---@field hasCharges boolean
---@field maxCharges integer
---@field currentCharges integer
---@field isAvailable boolean
---@field isKnown boolean
---@field isPetSpell boolean
---@field protected constructCooldownBase fun(this:ERACooldownBase, hud:ERAHUD, spellID:number, talent:ERALIBTalent|nil, ...:ERACooldownAdditionalID)
---@field protected updateCooldownData fun(this:ERACooldownBase, t:number)
ERACooldownBase = {}
ERACooldownBase.__index = ERACooldownBase
setmetatable(ERACooldownBase, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERACooldownBase:constructCooldownBase(hud, spellID, talent, ...)
    self:constructID(hud, spellID, talent, ...)
    self.hasCharges = false
    self.maxCharges = 1
    self.currentCharges = 0
    self.isAvailable = false
    self.isKnown = false
    self.isPetSpell = false
end

---@param t number
function ERACooldownBase:updateData(t)
    if self.isPetSpell then
        if IsSpellKnown(self.spellID, true) then
            self.isKnown = true
        else
            self.isKnown = false
            return
        end
    else
        self.isKnown = true
    end
    self:updateCooldownData(t)
end

---@class ERACooldown : ERACooldownBase
---@field private __index unknown
---@field private lastGoodUpdate number
---@field private lastGoodRemdur number
ERACooldown = {}
ERACooldown.__index = ERACooldown
setmetatable(ERACooldown, { __index = ERACooldownBase })

---@param hud ERAHUD
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
---@return ERACooldown
function ERACooldown:create(hud, spellID, talent, ...)
    local cd = {}
    setmetatable(cd, ERACooldown)
    ---@cast cd ERACooldown
    cd:constructCooldownBase(hud, spellID, talent, ...)
    cd.lastGoodRemdur = 0
    cd.lastGoodUpdate = 0
    return cd
end

---@param t number
function ERACooldown:updateCooldownData(t)
    local chargesInfo = C_Spell.GetSpellCharges(self.spellID)
    if chargesInfo then
        self.hasCharges = true
        self.maxCharges = chargesInfo.maxCharges
        self.currentCharges = chargesInfo.currentCharges
        self.totDuration = chargesInfo.cooldownDuration
        if chargesInfo.currentCharges >= chargesInfo.maxCharges then
            self.remDuration = 0
            self.isAvailable = true
        else
            self.remDuration = chargesInfo.cooldownDuration - (t - chargesInfo.cooldownStartTime)
            self.isAvailable = chargesInfo.currentCharges > 0
        end
    else
        self.hasCharges = false
        self.maxCharges = 1
        local cdInfo = C_Spell.GetSpellCooldown(self.spellID)
        if cdInfo and cdInfo.startTime and cdInfo.startTime > 0 then
            local remDur = cdInfo.duration - (t - cdInfo.startTime)
            if cdInfo.duration <= self.hud.remGCD + 0.1 and self.lastGoodUpdate > 0 then
                self.isAvailable = true
                self.currentCharges = 1
                -- totDuration reste inchangé
                self.remDuration = self.lastGoodRemdur - (t - self.lastGoodUpdate)
                if self.remDuration < 0 then
                    self.remDuration = 0
                elseif self.remDuration > remDur then
                    self.remDuration = remDur
                end
            else
                self.isAvailable = false
                self.currentCharges = 0
                self.totDuration = cdInfo.duration
                self.remDuration = remDur
                self.lastGoodRemdur = remDur
                self.lastGoodUpdate = t
            end
        else
            self.isAvailable = true
            if cdInfo then
                self.totDuration = cdInfo.duration or 1
            else
                self.totDuration = 1
            end
            self.remDuration = 1
            self.currentCharges = 1
            self.lastGoodRemdur = 0
            self.lastGoodUpdate = t
        end
    end
end

------------
--- AURA ---
------------

---@class ERAAura : ERATimerWithID
---@field private __index unknown
---@field isBuff boolean
---@field stacks integer
---@field auraFound fun(this:ERAAura, t:number, data:AuraData)
---@field private found boolean
ERAAura = {}
ERAAura.__index = ERAAura
setmetatable(ERAAura, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param isBuff boolean
---@param spellID integer
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAAura:create(hud, isBuff, spellID, talent, ...)
    local a = {}
    setmetatable(a, ERAAura)
    ---@cast a ERAAura
    a:constructID(hud, spellID, talent, ...)
    a.isBuff = isBuff
    a.found = false
    if isBuff then
        hud:addBuff(self)
    else
        hud:addDebuff(self)
    end
    return a
end

---@param t number
---@param data AuraData
function ERAAura:auraFound(t, data)
    self.found = true
    self.remDuration = data.expirationTime - t
    self.totDuration = data.duration
    self.stacks = data.applications
end

---@param t number
function ERAAura:updateData(t)
    if self.found then
        self.found = false
    else
        self.remDuration = 0
        self.stacks = 0
    end
end

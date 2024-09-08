---@class ERATimer
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
    local t = {}
    ---@cast t ERACooldownBase
    t.hud = hud
    t.remDuration = 0
    t.totDuration = 1
    hud:addTimer(self)
end

function ERATimer:checkTalent()
    if (self:checkTimerTalent()) then
        self.talentActive = false
        return false
    else
        self.talentActive = true
        return true
    end
end

---@class ERACooldownAdditionalID
---@field spellID number
---@field talent ERALIBTalent

---@class ERATimerWithID : ERATimer
---@field spellID number
---@field private mainSpellID number
---@field private talent ERALIBTalent | nil
---@field private mainTalent ERALIBTalent | nil
ERATimerWithID = {}
ERATimerWithID.__index = ERATimerWithID
setmetatable(ERATimerWithID, { __index = ERATimer })

---@param hud ERAHUD
---@param spellID number
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

---@class ERACooldownBase : ERATimerWithID
---@field hasCharges boolean
---@field maxCharges number
---@field currentCharges number
---@field isAvailable boolean
---@field protected constructCooldownBase fun(this:ERACooldownBase, hud:ERAHUD, spellID:number, talent:ERALIBTalent|nil, ...:ERACooldownAdditionalID)
---@field protected updateKind fun(this)

ERACooldownBase = {}
ERACooldownBase.__index = ERACooldownBase
setmetatable(ERACooldownBase, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERACooldownBase:constructCooldownBase(hud, spellID, talent, ...)
    local cd = {}
    ---@cast cd ERACooldownBase
    cd:constructID(hud, spellID, talent, ...)
    cd.hasCharges = false
    cd.maxCharges = 1
    cd.currentCharges = 0
    cd.isAvailable = false
end

---@class ERACooldown : ERACooldownBase
---@field private lastGoodUpdate number
---@field private lastGoodRemdur number
ERACooldown = {}
ERACooldown.__index = ERACooldown
setmetatable(ERACooldown, { __index = ERACooldownBase })

---@param hud ERAHUD
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERACooldown:constructCooldown(hud, spellID, talent, ...)
    local cd = {}
    setmetatable(cd, ERACooldown)
    ---@cast cd ERACooldown
    cd:constructCooldownBase(hud, spellID, talent, ...)
    cd.lastGoodRemdur = 0
    cd.lastGoodUpdate = 0
end

---@param t number
function ERACooldown:updateData(t)
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

---@class ERAAURA : ERATimerWithID
---@field isBuff boolean
---@field auraFound fun(this:ERAAURA, t:number, data:AuraData)
---@field private found boolean
ERAAura = {}
ERAAura.__index = ERAAura
setmetatable(ERAAura, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param isBuff boolean
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERAAura:constructAura(hud, isBuff, spellID, talent, ...)
    local a = {}
    setmetatable(a, ERAAura)
    ---@cast a ERAAURA
    a:constructID(hud, spellID, talent, ...)
    a.isBuff = isBuff
    a.found = false
    if isBuff then
        hud:addBuff(self)
    else
        hud:addDebuff(self)
    end
end

---@param t number
---@param data AuraData
function ERAAura:auraFound(t, data)
    self.found = true
    self.remDuration = data.expirationTime - t
    self.totDuration = data.duration
end

---@param t number
function ERAAura:updateData(t)
    if self.found then
        self.found = false
    else
        self.remDuration = 0
    end
end

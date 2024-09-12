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
        if cdInfo and cdInfo.startTime and cdInfo.startTime > 0 and cdInfo.duration and cdInfo.duration > 0 then
            local remDur = cdInfo.duration - (t - cdInfo.startTime)
            if remDur <= self.hud.remGCD + 0.1 and self.lastGoodUpdate > 0 then
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
            self.currentCharges = 1
            self.remDuration = 0
            if cdInfo.duration and cdInfo.duration > 0 then
                self.totDuration = cdInfo.duration
            end
            self.lastGoodRemdur = 0
            self.lastGoodUpdate = t
        end
    end
end

--#region EQUIPMENT

---@class ERACooldownEquipment : ERATimer
---@field private __index unknown
---@field slotID integer
---@field private hasCooldown boolean
ERACooldownEquipment = {}
ERACooldownEquipment.__index = ERACooldownEquipment
setmetatable(ERACooldownEquipment, { __index = ERATimer })

---@param hud ERAHUD
---@param slotID integer
---@return ERACooldownEquipment
function ERACooldownEquipment:create(hud, slotID)
    local cd = {}
    setmetatable(cd, ERACooldown)
    ---@cast cd ERACooldownEquipment
    cd:constructTimer(hud)
    cd.slotID = slotID
    cd.hasCooldown = false
    return cd
end

---@return boolean
function ERACooldownEquipment:checkTimerTalent()
    return self.hasCooldown
end

function ERACooldownEquipment:updateData(t)
    local start, duration, enable = GetInventoryItemCooldown("player", self.slotID)
    if enable and enable ~= 0 then
        if not self.hasCooldown then
            self.hasCooldown = true
            self.hud:mustUpdateUtilityLayout()
        end
        if duration and duration > 0 then
            self.totDuration = duration
            self.remDuration = duration - (t - start)
        else
            self.remDuration = 0
        end
    else
        if self.hasCooldown then
            self.hasCooldown = false
            self.hud:mustUpdateUtilityLayout()
        end
    end
end

--#endregion

--#region BAG ITEM

---@class ERACooldownBagItem : ERATimer
---@field private __index unknown
---@field itemID integer
---@field hasItem boolean
---@field stacks integer
---@field private talent ERALIBTalent|nil
---@field private bagID integer
---@field private slot integer
ERACooldownBagItem = {}
ERACooldownBagItem.__index = ERACooldownBagItem
setmetatable(ERACooldownBagItem, { __index = ERATimer })

---@param hud ERAHUD
---@param itemID integer
---@param talent ERALIBTalent|nil
---@return ERACooldownBagItem
function ERACooldownBagItem:create(hud, itemID, talent)
    local cd = {}
    setmetatable(cd, ERACooldownBagItem)
    ---@cast cd ERACooldownBagItem
    cd:constructTimer(hud)
    cd.itemID = itemID
    cd.hasItem = false
    cd.talent = talent
    cd.bagID = -1
    cd.slot = -1
    hud:addBagItem(cd)
    return cd
end

---@return boolean
function ERACooldownBagItem:checkTimerTalent()
    return self.talent:PlayerHasTalent()
end

function ERACooldownBagItem:bagUpdateOrReset()
    self.bagID = -1
    self.slot = -1
    for i = 0, NUM_BAG_SLOTS do
        local cpt = C_Container.GetContainerNumSlots(i)
        for j = 1, cpt do
            local id = C_Container.GetContainerItemID(i, j)
            if (id == self.itemID) then
                self.bagID = i
                self.slot = j
                break
            end
        end
        if (self.bagID >= 0) then
            break
        end
    end
    if self.hasItem then
        if self.bagID < 0 then
            self.hasItem = false
            self.hud:mustUpdateUtilityLayout()
        end
    else
        if self.bagID >= 0 then
            self.hasItem = true
            self.hud:mustUpdateUtilityLayout()
        end
    end
end

function ERACooldownBagItem:updateData(t)
    if (self.bagID >= 0) then
        local start, duration = C_Container.GetContainerItemCooldown(self.bagID, self.slot)
        if (start and start > 0) then
            self.remDuration = (start + duration) - t
            self.totDuration = duration
        else
            self.remDuration = 0
            self.totDuration = duration
        end
        self.stacks = C_Item.GetItemCount(self.itemID, false, true) -- CHANGE 11 GetItemCount(self.itemID, false, true)
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
    end
end

--#endregion

------------
--- AURA ---
------------

---@class ERAAura : ERATimerWithID
---@field private __index unknown
---@field stacks integer
---@field auraFound fun(this:ERAAura, t:number, data:AuraData)
---@field private foundDuration number
---@field private foundStacks integer
ERAAura = {}
ERAAura.__index = ERAAura
setmetatable(ERAAura, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param spellID integer
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAAura:create(hud, spellID, talent, ...)
    local a = {}
    setmetatable(a, ERAAura)
    ---@cast a ERAAura
    a:constructID(hud, spellID, talent, ...)
    a.foundDuration = -1
    a.foundStacks = 0
    return a
end

---@param t number
---@param data AuraData
function ERAAura:auraFound(t, data)
    local remDur = data.expirationTime - t
    if remDur > self.foundDuration then
        self.foundDuration = remDur
        self.totDuration = data.duration
    end
    self.foundStacks = math.max(self.foundStacks, data.applications, 1)
end

---@param t number
function ERAAura:updateData(t)
    if self.foundDuration > 0 then
        self.remDuration = self.foundDuration
        self.stacks = self.foundStacks
        self.foundDuration = -1
        self.foundStacks = 0
    else
        self.remDuration = 0
        self.stacks = 0
        self.foundStacks = 0
    end
end

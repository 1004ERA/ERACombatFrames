---@class (exact) ERADataItem
---@field private __index unknown
---@field protected constructItem fun(this:ERADataItem, hud:ERAHUD)
---@field hud ERAHUD
---@field talentActive boolean
---@field checkTalent fun(this:ERADataItem): boolean
---@field protected checkDataItemTalent fun(this:ERADataItem): boolean
---@field protected clear fun(this:ERADataItem)
---@field updateData fun(this:ERADataItem, t:number)
ERADataItem = {}
ERADataItem.__index = ERADataItem

---@param hud ERAHUD
function ERADataItem:constructItem(hud)
    self.hud = hud
    hud:addDataItem(self)
end

function ERADataItem:checkTalent()
    if (self:checkDataItemTalent()) then
        self.talentActive = true
        return true
    else
        self.talentActive = false
        self:clear()
        return false
    end
end

---@class (exact) ERATimer : ERADataItem
---@field private __index unknown
---@field protected constructTimer fun(this:ERATimer, hud:ERAHUD)
---@field remDuration number
---@field totDuration number
---@field private clear fun(this:ERADataItem)
---@field protected clearTimer fun(this:ERATimer)
ERATimer = {}
ERATimer.__index = ERATimer
setmetatable(ERATimer, { __index = ERADataItem })

---@param hud ERAHUD
function ERATimer:constructTimer(hud)
    self.remDuration = 0
    self.totDuration = 1
    self:constructItem(hud)
end

function ERATimer:clear()
    self.remDuration = 0
    self:clearTimer()
end
function ERATimer:clearTimer()
end

---@class (exact) ERACooldownAdditionalID
---@field spellID integer
---@field talent ERALIBTalent

---@class (exact) ERATimerWithID : ERATimer
---@field private __index unknown
---@field protected constructID fun(this:ERATimer, hud:ERAHUD, spellID:integer, talent:ERALIBTalent|nil, ...:ERACooldownAdditionalID)
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

function ERATimerWithID:checkDataItemTalent()
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

--#region GENERIC

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
---@field private clearTimer fun(this:ERACooldownBase)
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

function ERACooldownBase:clearTimer()
    self.isAvailable = false
    self.currentCharges = 0
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
    if chargesInfo and chargesInfo.maxCharges > 1 then
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
            if remDur <= self.hud.remGCD + 0.1 then
                self.isAvailable = true
                self.currentCharges = 1
                -- totDuration reste inchangé
                if self.lastGoodUpdate > 0 then
                    self.remDuration = self.lastGoodRemdur - (t - self.lastGoodUpdate)
                    if self.remDuration < 0 then
                        self.remDuration = 0
                    elseif self.remDuration > self.hud.remGCD - 0.1 then
                        self.remDuration = 0
                    elseif self.remDuration > remDur then
                        self.remDuration = remDur
                    end
                else
                    self.remDuration = 0
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

--#endregion

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
    setmetatable(cd, ERACooldownEquipment)
    ---@cast cd ERACooldownEquipment
    cd:constructTimer(hud)
    cd.slotID = slotID
    cd.hasCooldown = false
    return cd
end

---@return boolean
function ERACooldownEquipment:checkDataItemTalent()
    local _, _, enable = GetInventoryItemCooldown("player", self.slotID)
    self.hasCooldown = enable and enable ~= 0
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
function ERACooldownBagItem:checkDataItemTalent()
    return self.hasItem and ((not self.talent) or self.talent:PlayerHasTalent())
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

--------------
--- STACKS ---
--------------

---@class ERAStacks : ERADataItem
---@field stacks integer
---@field spellID integer

--#region SPELL STACKS

---@class ERASpellStacks : ERAStacks
---@field private __index unknown
---@field private talent ERALIBTalent|nil
---@field private slot integer
---@field lastStackGain number
ERASpellStacks = {}
ERASpellStacks.__index = ERASpellStacks
setmetatable(ERASpellStacks, { __index = ERADataItem })

---@param hud ERAHUD
---@param spellID integer
---@param talent ERALIBTalent|nil
---@return ERASpellStacks
function ERASpellStacks:create(hud, spellID, talent)
    local s = {}
    setmetatable(s, ERASpellStacks)
    ---@cast s ERASpellStacks
    s:constructItem(hud)
    s.spellID = spellID
    s.talent = talent
    s.stacks = 0
    s.lastStackGain = 0
    return s
end

function ERASpellStacks:clear()
    self.stacks = 0
end

function ERASpellStacks:checkDataItemTalent()
    if self.talent and not self.talent:PlayerHasTalent() then
        return false
    else
        self.slot = ERALIB_GetSpellSlot(self.spellID)
        return self.slot >= 0
    end
end

---@param t number
function ERASpellStacks:updateData(t)
    if self.slot >= 0 then
        local stacks = GetActionCount(self.slot)
        if self.stacks < stacks then
            self.lastStackGain = t
        end
        self.stacks = stacks
    else
        self.stacks = 0
    end
end

--#endregion

------------
--- AURA ---
------------

--#region AURA

---@class ERAAura : ERATimerWithID, ERAStacks
---@field private __index unknown
---@field private clearTimer fun(this:ERAAura)
---@field stacks integer
---@field private foundDuration number
---@field private foundStacks integer
---@field private foundCount integer
---@field private requiredCount integer
---@field private last_checked number
---@field private not_checked boolean
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
    a.not_checked = false
    a.last_checked = 0
    a.foundCount = 0
    a.requiredCount = 0
    return a
end

function ERAAura:clearTimer()
    self.stacks = 0
end

---@param t number
---@param data AuraData
function ERAAura:auraFound(t, data)
    if data.expirationTime and data.expirationTime > 0 then
        local remDur = data.expirationTime - t
        if remDur > self.foundDuration then
            self.foundDuration = remDur
            self.totDuration = data.duration
        end
    else
        self.foundDuration = 1004
        self.totDuration = 1004
    end
    self.foundCount = self.foundCount + 1
    self.foundStacks = math.max(self.foundStacks, data.applications, 1)
end

function ERAAura:notChecked()
    self.not_checked = true
end

---@param cpt integer
function ERAAura:requireCount(cpt)
    self.requiredCount = cpt
end

---@param t number
function ERAAura:updateData(t)
    if self.requiredCount <= self.foundCount and self.foundDuration > 0 then
        self.remDuration = self.foundDuration
        self.stacks = self.foundStacks
        self.foundDuration = -1
        self.foundStacks = 0
        self.last_checked = t
    else
        if self.not_checked then
            self.not_checked = false
            if self.remDuration > 0 then
                self.remDuration = self.remDuration - (t - self.last_checked)
                if self.remDuration <= 0 then
                    self.remDuration = 0.1
                end
            end
        else
            self.remDuration = 0
            self.stacks = 0
            self.foundStacks = 0
            self.last_checked = t
        end
    end
end

--#endregion

-----------------
--- AGGREGATE ---
-----------------

--#region AGGREGATE

---@class (exact) ERAAggregateTimer : ERATimer
---@field private __index unknown
---@field protected timers ERATimer[]
---@field shortest boolean
ERAAggregateTimer = {}
ERAAggregateTimer.__index = ERAAggregateTimer
setmetatable(ERAAggregateTimer, { __index = ERATimer })

---@param shortest boolean
---@param ... ERATimer
function ERAAggregateTimer:constructAggregate(shortest, ...)
    self.shortest = shortest
    self.timers = { ... }
end

---@class ERATimerOr : ERAAggregateTimer
---@field private __index unknown
ERATimerOr = {}
ERATimerOr.__index = ERATimerOr
setmetatable(ERATimerOr, { __index = ERAAggregateTimer })

---@param shortest boolean
---@param ... ERATimer
---@return ERATimerOr
function ERATimerOr:create(shortest, ...)
    local o = {}
    setmetatable(o, ERATimerOr)
    ---@cast o ERATimerOr
    o:constructAggregate(shortest, ...)
    return o
end

function ERATimerOr:checkDataItemTalent()
    for _, t in ipairs(self.timers) do
        if t.talentActive then
            return true
        end
    end
    return false
end

---@param t number
function ERATimerOr:updateData(t)
    local foundDuration = 0
    local foundTotDuration = 0
    for _, tim in ipairs(self.timers) do
        if tim.talentActive and tim.remDuration > 0 then
            if self.shortest then
                if foundDuration <= 0 or foundDuration > tim.remDuration then
                    foundDuration = tim.remDuration
                    foundTotDuration = tim.totDuration
                end
            else
                if foundDuration < tim.remDuration then
                    foundDuration = tim.remDuration
                    foundTotDuration = tim.totDuration
                end
            end
        end
    end
    self.remDuration = foundDuration
    self.totDuration = foundTotDuration
end

--#endregion

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
---@field CustomCheckIsKnown nil|fun(this:ERACooldownBase): boolean
---@field isKnown boolean
---@field isPetSpell boolean
---@field mustRedrawUtilityLayoutIfChangedStatus boolean
---@field private wasKnown boolean
---@field protected constructCooldownBase fun(this:ERACooldownBase, hud:ERAHUD, spellID:number, talent:ERALIBTalent|nil, ...:ERACooldownAdditionalID)
---@field protected updateCooldownData fun(this:ERACooldownBase, t:number)
---@field private clearTimer fun(this:ERACooldownBase)
ERACooldownBase = {}
ERACooldownBase.__index = ERACooldownBase
setmetatable(ERACooldownBase, { __index = ERATimerWithID })

---@param hud ERAHUD
---@param spellID integer
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
function ERACooldownBase:constructCooldownBase(hud, spellID, talent, ...)
    self:constructID(hud, spellID, talent, ...)
    self.hasCharges = false
    self.maxCharges = 1
    self.currentCharges = 0
    self.isAvailable = false
    self.isKnown = true
    self.wasKnown = true
    self.isPetSpell = false
end

function ERACooldownBase:clearTimer()
    self.isAvailable = false
    self.currentCharges = 0
end

---@param t number
function ERACooldownBase:updateData(t)
    if self.isPetSpell then
        self.isKnown = self.hud.hasPet and IsSpellKnown(self.spellID, true)
    elseif self.CustomCheckIsKnown then
        self.isKnown = self:CustomCheckIsKnown()
    else
        self.isKnown = true
    end
    if self.isKnown then
        if not self.wasKnown then
            self.wasKnown = true
            self.hud:mustUpdateUtilityLayout()
        end
    else
        if self.wasKnown then
            self.wasKnown = false
            self.hud:mustUpdateUtilityLayout()
        end
        self:clearTimer()
        return
    end
    local wasAvailable = self.isAvailable
    self:updateCooldownData(t)
    if self.mustRedrawUtilityLayoutIfChangedStatus and self.isAvailable ~= wasAvailable then
        self.hud:mustUpdateUtilityLayout()
    end
end

---@class ERACooldown : ERACooldownBase
---@field private __index unknown
---@field private lastGoodUpdate number
---@field private lastGoodRemdur number
ERACooldown = {}
ERACooldown.__index = ERACooldown
setmetatable(ERACooldown, { __index = ERACooldownBase })

---@param hud ERAHUD
---@param spellID integer
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
            if self.remDuration <= self.hud.remGCD + 0.1 then
                self.remDuration = 0
            end
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
    cd.stacks = 0
    hud:addBagItem(cd)
    return cd
end

---@return boolean
function ERACooldownBagItem:checkDataItemTalent()
    return (not self.talent) or self.talent:PlayerHasTalent()
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
        self.stacks = C_Item.GetItemCount(self.itemID, false, true)
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
---@field protected foundDuration number
---@field protected foundStacks integer
---@field protected foundBySelf boolean
---@field updateUtilityLayoutIfChanged boolean
---@field acceptAnyCaster boolean
---@field appliedBySelf boolean
---@field auraFound fun(this:ERAAura, t:number, data:AuraData, checkSourceUnit:boolean)
---@field updateData fun(this:ERAAura, t:number)
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
    a.foundBySelf = false
    return a
end

function ERAAura:clearTimer()
    self.stacks = 0
    self.appliedBySelf = false
end

---@param t number
---@param data AuraData
---@param checkSourceUnit boolean
function ERAAura:auraFound(t, data, checkSourceUnit)
    if self.acceptAnyCaster or data.sourceUnit == "player" then
        if data.expirationTime and data.expirationTime > 0 then
            local remDur = data.expirationTime - t
            if remDur > self.foundDuration then
                self.foundDuration = remDur
                self.totDuration = data.duration
                self.foundStacks = math.max(self.foundStacks, data.applications, 1)
            end
        else
            self.foundDuration = 1004
            self.totDuration = 1004
            self.foundStacks = math.max(self.foundStacks, data.applications, 1)
        end
        if data.sourceUnit == "player" then
            self.foundBySelf = true
        end
    end
end

---@param t number
function ERAAura:updateData(t)
    if self.foundDuration > 0 then
        if self.remDuration <= 0 and self.updateUtilityLayoutIfChanged then
            self.hud:mustUpdateUtilityLayout()
        end
        self.remDuration = self.foundDuration
        self.stacks = self.foundStacks
        self.foundDuration = -1
        self.appliedBySelf = self.foundBySelf
    else
        if self.remDuration > 0 and self.updateUtilityLayoutIfChanged then
            self.hud:mustUpdateUtilityLayout()
        end
        self.remDuration = 0
        self.stacks = 0
        self.appliedBySelf = false
    end
    self.foundStacks = 0
    self.foundBySelf = false
end

---@class ERAAuraOnGroupMembers : ERAAura
---@field private __index unknown
---@field protected constructOnGroupMembers fun(this:ERAAuraOnGroupMembers, ...:integer)
---@field private totalCount integer
---@field private numberOfGroupMembersIncludingSelf integer
---@field private last_checked number
---@field private not_checked boolean
---@field private found_on_current_member boolean
---@field alternativeIDAuraIDs integer[]
---@field protected computeParty fun(this:ERAAuraOnGroupMembers, groupMembersCountExcludingSelf: integer, totalCount:integer, numberOfGroupMembersIncludingSelf:number, foundBySelf:boolean)
---@field private computed boolean
ERAAuraOnGroupMembers = {}
ERAAuraOnGroupMembers.__index = ERAAuraOnGroupMembers
setmetatable(ERAAuraOnGroupMembers, { __index = ERAAura })

---@param ... integer
function ERAAuraOnGroupMembers:constructOnGroupMembers(...)
    self.not_checked = false
    self.last_checked = 0
    self.totalCount = 0
    self.numberOfGroupMembersIncludingSelf = 0
    self.alternativeIDAuraIDs = { ... }
    self.acceptAnyCaster = true
end

function ERAAuraOnGroupMembers:notChecked()
    self.not_checked = true
    self.totalCount = 0
    self.numberOfGroupMembersIncludingSelf = 0
end

---@param t number
---@param data AuraData
---@param checkSourceUnit boolean
function ERAAuraOnGroupMembers:auraFound(t, data, checkSourceUnit)
    if data.expirationTime and data.expirationTime > 0 then
        local remDur = data.expirationTime - t
        if remDur > self.foundDuration then
            self.foundDuration = remDur
            self.totDuration = data.duration
            self.foundStacks = math.max(self.foundStacks, data.applications, 1)
        end
    else
        self.foundDuration = 1004
        self.totDuration = 1004
        self.foundStacks = math.max(self.foundStacks, data.applications, 1)
    end
    self.found_on_current_member = true
    self.totalCount = self.totalCount + 1
    if data.sourceUnit == "player" then
        self.foundBySelf = true
    end
end

function ERAAuraOnGroupMembers:memberParsed()
    if self.found_on_current_member then
        self.found_on_current_member = false
        self.numberOfGroupMembersIncludingSelf = self.numberOfGroupMembersIncludingSelf + 1
    end
end

function ERAAuraOnGroupMembers:parsingParty()
    self.computed = false
end

---@param groupMembersCountExcludingSelf integer
---@param t number
function ERAAuraOnGroupMembers:partyParsed(groupMembersCountExcludingSelf, t)
    if not self.computed then
        self.computed = true
        self.last_checked = t
        self.appliedBySelf = self.foundBySelf
        self:computeParty(groupMembersCountExcludingSelf, self.totalCount, self.numberOfGroupMembersIncludingSelf, self.foundBySelf)
        self.foundCount = 0
        self.foundDuration = 0
        self.foundStacks = 0
        self.foundBySelf = false
        self.totalCount = 0
        self.numberOfGroupMembersIncludingSelf = 0
    end
end

---@param t number
function ERAAuraOnGroupMembers:updateData(t)
    if self.not_checked then
        self.not_checked = false
        if self.remDuration > 0 then
            self.remDuration = self.remDuration - (t - self.last_checked)
            if self.remDuration <= 0 then
                self.remDuration = 0.1
            end
        end
    end
end

---@class ERAAuraOnAllGroupMembers : ERAAuraOnGroupMembers
---@field private __index unknown
ERAAuraOnAllGroupMembers = {}
ERAAuraOnAllGroupMembers.__index = ERAAuraOnAllGroupMembers
setmetatable(ERAAuraOnAllGroupMembers, { __index = ERAAuraOnGroupMembers })

---@param hud ERAHUD
---@param talent ERALIBTalent|nil
---@param mainSpellID integer
---@param ... integer
---@return ERAAuraOnAllGroupMembers
function ERAAuraOnAllGroupMembers:create(hud, talent, mainSpellID, ...)
    local a = ERAAura:create(hud, mainSpellID, talent)
    setmetatable(a, ERAAuraOnAllGroupMembers)
    ---@cast a ERAAuraOnAllGroupMembers
    a:constructOnGroupMembers(...)
    return a
end

---@param groupMembersCountExcludingSelf integer
---@param totalCount integer
---@param numberOfGroupMembersIncludingSelf integer
---@param foundBySelf boolean
function ERAAuraOnAllGroupMembers:computeParty(groupMembersCountExcludingSelf, totalCount, numberOfGroupMembersIncludingSelf, foundBySelf)
    if numberOfGroupMembersIncludingSelf <= groupMembersCountExcludingSelf then
        self.remDuration = 0
        self.stacks = 0
    else
        self.remDuration = self.foundDuration
        self.stacks = self.foundStacks
    end
end

---@class ERAAuraOnFriendlyHealer : ERAAuraOnGroupMembers
---@field private __index unknown
ERAAuraOnFriendlyHealer = {}
ERAAuraOnFriendlyHealer.__index = ERAAuraOnFriendlyHealer
setmetatable(ERAAuraOnFriendlyHealer, { __index = ERAAuraOnGroupMembers })

---@param hud ERAHUD
---@param talent ERALIBTalent|nil
---@param mainSpellID integer
---@param ... integer
---@return ERAAuraOnFriendlyHealer
function ERAAuraOnFriendlyHealer:create(hud, talent, mainSpellID, ...)
    local a = ERAAura:create(hud, mainSpellID, talent)
    setmetatable(a, ERAAuraOnFriendlyHealer)
    ---@cast a ERAAuraOnFriendlyHealer
    a:constructOnGroupMembers(...)
    return a
end

---@param groupMembersCountExcludingSelf integer
---@param totalCount integer
---@param numberOfGroupMembersIncludingSelf integer
---@param foundBySelf boolean
function ERAAuraOnFriendlyHealer:computeParty(groupMembersCountExcludingSelf, totalCount, numberOfGroupMembersIncludingSelf, foundBySelf)
    if totalCount < self.hud.otherHealersInGroup and not foundBySelf then
        self.remDuration = 0
        self.stacks = 0
    else
        self.remDuration = math.max(0.01, self.foundDuration)
        self.stacks = math.max(1, self.foundStacks)
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

---@param hud ERAHUD
---@param shortest boolean
---@param ... ERATimer
function ERAAggregateTimer:constructAggregate(hud, shortest, ...)
    self:constructTimer(hud)
    self.shortest = shortest
    self.timers = { ... }
end

---@class ERATimerOr : ERAAggregateTimer
---@field private __index unknown
ERATimerOr = {}
ERATimerOr.__index = ERATimerOr
setmetatable(ERATimerOr, { __index = ERAAggregateTimer })

---@param hud ERAHUD
---@param shortest boolean
---@param ... ERATimer
---@return ERATimerOr
function ERATimerOr:create(hud, shortest, ...)
    local o = {}
    setmetatable(o, ERATimerOr)
    ---@cast o ERATimerOr
    o:constructAggregate(hud, shortest, ...)
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

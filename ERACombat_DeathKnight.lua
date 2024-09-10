--[[

------------
--- TODO ---
------------

* COMMON *
- (test) cleaving strikes (cleave dnd)
- (test) lichborne buff

* BLOOD *
- (test) drw duration
- (test) voracious (death strike +15% heal)
- (test) sanguine ground (+5% heal)

* FROST *
- (test) cold heart (damaging ice chains)
- (test) enduring strength (extended pof)
- (test) bonegrinder buff

* UNHOLY *
- (test) transfo duration only if "eternal agony" is chosen
- (test) festering scythe proc
- (test) ebon fever (refresh plague time)

]]

---@class (exact) DKCommonTalents
---@field kick ERALIBTalent
---@field soulreaper ERALIBTalent
---@field wraithwalk ERALIBTalent
---@field pact ERALIBTalent
---@field fortitude ERALIBTalent
---@field raisedead ERALIBTalent
---@field blinding ERALIBTalent
---@field vader ERALIBTalent
---@field necrolimb ERALIBTalent
---@field sacrifice ERALIBTalent
---@field deathstrike ERALIBTalent
---@field improved_deathstrike ERALIBTalent
---@field amz ERALIBTalent
---@field blooddraw ERALIBTalent
---@field rootchains ERALIBTalent
---@field cleavednd ERALIBTalent
---@field deathcharger ERALIBTalent
---@field not_deathcharger ERALIBTalent
---@field reapermark ERALIBTalent
---@field reapermark1rune ERALIBTalent
---@field reapermark2rune ERALIBTalent

---comment
---@param cFrame ERACombatFrame
function ERACombatFrames_DeathKnightSetup(cFrame)
    ERADK_RuneSize = 24
    ERADK_BarsHeight = 36
    ERADK_BarsWidth = 6 * ERADK_RuneSize
    ERADK_BarsX = -151
    ERADK_BarsTopY = -36
    ERADK_RunesTopY = ERADK_BarsTopY - ERADK_BarsHeight - 4
    ERADK_TimersX = -60
    ERADK_TimersY = -12
    ERADK_TimersSpecialX0 = 2
    ERADK_TimersSpecialY0 = 4
    ERADK_UtilityBaseX = -4.4
    ERADK_UtilityBaseY = 2.1
    ERADK_SuccorR = 0.8
    ERADK_SuccorG = 0.7
    ERADK_SuccorB = 0.5

    local bloodActive = 1  --ERACombatOptions_IsSpecActive(1)
    local frostActive = 2  --ERACombatOptions_IsSpecActive(2)
    local unholyActive = 3 --ERACombatOptions_IsSpecActive(3)

    ---@type DKCommonTalents
    local talents = {
        kick = ERALIBTalent:Create(96213),
        soulreaper = ERALIBTalent:Create(96192),
        wraithwalk = ERALIBTalent:Create(96206),
        pact = ERALIBTalent:Create(96204),
        fortitude = ERALIBTalent:Create(96210),
        raisedead = ERALIBTalent:Create(96201),
        blinding = ERALIBTalent:Create(96172),
        vader = ERALIBTalent:Create(96193),
        necrolimb = ERALIBTalent:Create(96177),
        sacrifice = ERALIBTalent:Create(125608),
        deathstrike = ERALIBTalent:Create(96200),
        improved_deathstrike = ERALIBTalent:Create(96196),
        amz = ERALIBTalent:Create(96194),
        blooddraw = ERALIBTalent:Create(96184),
        rootchains = ERALIBTalent:Create(96215),
        cleavednd = ERALIBTalent:Create(96202),
        deathcharger = ERALIBTalent:Create(123412),
        not_deathcharger = ERALIBTalent:CreateNotTalent(123412),
        reapermark = ERALIBTalent:Create(117659),
        reapermark2rune = ERALIBTalent:CreateAnd(ERALIBTalent:Create(117659), ERALIBTalent:CreateNotTalent(117629)),
        reapermark1rune = ERALIBTalent:Create(117629),
    }

    ERAOutOfCombatStatusBars:Create(cFrame, ERADK_BarsX, ERADK_BarsTopY, ERADK_BarsWidth, 2 * ERADK_BarsHeight / 3, ERADK_BarsHeight / 3, 6, false, 0.2, 0.7, 1.0, 0, bloodActive, frostActive)
    local runes = ERARunes:Create(cFrame, bloodActive, frostActive, unholyActive)

    if (bloodActive) then
        ERACombatFrames_DeathKnightBloodSetup(cFrame, runes, talents)
    end
    if (frostActive) then
        ERACombatFrames_DeathKnightFrostSetup(cFrame, runes, talents)
    end
    if (unholyActive) then
        ERACombatFrames_DeathKnightUnholySetup(cFrame, runes, talents)
    end
end

---@class ERACombat_DeathKnight
---@field timers ERACombatTimers
---@field utility ERACombatUtilityFrame
---@field damageTaken ERACombatDamageTaken
---@field enemies ERACombatEnemiesCount
---@field soulreaper ERACombat_DK_SoulReaperIcon
---@field combatHealth ERACombatHealth
---@field combatPower ERACombatPower
---@field blooddraw ERACombatTimersAura
---@field succor ERACombatTimersAura

---@class ERACombat_DK_SoulReaperIcon : ERACombatTimersCooldownIcon
---@field ComputeLowHealthPrioOverride fun(this:ERACombat_DK_SoulReaperIcon): number

---comment
---@param cFrame ERACombatFrame
---@param runes ERACombatRunes
---@param soulReaperBasePrio number
---@param talents DKCommonTalents
---@param healthHeight number
---@param petHeight number
---@param powerHeight number
---@param spec number
---@return ERACombat_DeathKnight
function ERACombat_CommonDK(cFrame, runes, soulReaperBasePrio, talents, healthHeight, petHeight, powerHeight, spec)
    local combatHealth = ERACombatHealth:Create(cFrame, ERADK_BarsX, ERADK_BarsTopY, ERADK_BarsWidth, healthHeight, spec)
    if (petHeight > 0) then
        local pet = ERACombatHealth:Create(cFrame, ERADK_BarsX, ERADK_BarsTopY - healthHeight, ERADK_BarsWidth, petHeight, spec)
        pet:SetUnitID("pet")
    end
    local combatPower = ERACombatPower:Create(cFrame, ERADK_BarsX, ERADK_BarsTopY - healthHeight - petHeight, ERADK_BarsWidth, powerHeight, 6, true, 0.2, 0.7, 1.0, spec)

    local damageTaken = ERACombatDamageTaken:Create(cFrame, 5, spec)


    local timers = ERACombatTimersGroup:Create(cFrame, ERADK_TimersX, ERADK_TimersY, 1.5, false, false, spec)
    function timers:PreUpdateCombatOverride(t)
        runes:updateCombatBeforeTimers(t)
    end
    timers.offsetIconsX = -80
    timers.offsetIconsY = -55

    timers:AddKick(47528, ERADK_TimersSpecialX0, ERADK_TimersSpecialY0, talents.kick)

    local soulreaper = ERACombatCooldownIgnoringRunes:Create(timers, runes, 1, 343294, talents.soulreaper)
    local soulreaperIcon = timers:AddCooldownIcon(soulreaper, nil, 0.9, 0.5, true, true)
    ---@cast soulreaperIcon ERACombat_DK_SoulReaperIcon
    function soulreaperIcon:TimerVisibilityOverride(t)
        return UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") <= 0.35
    end
    function soulreaperIcon:ComputeLowHealthPrioOverride()
        return soulReaperBasePrio
    end
    function soulreaperIcon:ComputeAvailablePriorityOverride()
        if UnitExists("target") then
            if UnitHealth("target") / UnitHealthMax("target") <= 0.35 then
                return self:ComputeLowHealthPrioOverride()
            else
                return 0
            end
        else
            return 0
        end
    end

    local blooddraw = timers:AddTrackedBuff(454871, talents.blooddraw)
    timers:AddAuraBar(blooddraw, nil, 0.8, 0.4, 0.5)

    local succor = timers:AddTrackedBuff(101568)
    timers:AddAuraBar(succor, nil, ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)

    timers:AddAuraBar(timers:AddTrackedBuff(48792, talents.fortitude), nil, 0.2, 0.0, 0.8)

    timers:AddAuraBar(timers:AddTrackedBuff(49039), nil, 0.4, 0.4, 0.4)     -- lichborne

    timers:AddAuraBar(timers:AddTrackedBuff(188290), 136144, 0.8, 0.5, 0.0) -- cleave dnd

    timers:AddAuraBar(timers:AddTrackedBuff(444347, talents.deathcharger), nil, 0.8, 1.0, 0.9)

    timers:AddAuraBar(timers:AddTrackedDebuff(434765, talents.reapermark), nil, 0.6, 0.2, 0.4)

    local utility = ERACombatUtilityFrame:Create(cFrame, 0, -181, spec)

    utility:AddTrinket1Cooldown(-1, -2)
    utility:AddTrinket2Cooldown(-1, -1)
    utility:AddCooldown(0, 0, 48707, nil, true) -- ams
    utility:AddCooldown(0, -1, 51052, nil, true, talents.amz)
    utility:AddCooldown(1, 0, 48792, nil, true, talents.fortitude)
    utility:AddCooldown(1, -1, 48743, nil, true, talents.pact)
    utility:AddCooldown(2, 0, 49039, nil, true)  -- lichborne

    utility:AddCooldown(4, -1, 61999, nil, true) -- raise dead
    utility:AddRacial(4, 0)
    utility:AddWarlockHealthStone(3, -1)

    utility:AddCooldown(1, 1, 45524, nil, true, talents.rootchains)
    utility:AddCooldown(3, 0, 207167, nil, true, talents.blinding)

    utility:AddCooldown(3, 1, 49576, nil, true)                           -- grip
    utility:AddCooldown(4, 1, 221562, nil, true, talents.vader)
    utility:AddCooldown(3, 2, 48265, nil, true, talents.not_deathcharger) -- advance
    utility:AddCooldown(3, 2, 444347, nil, true, talents.deathcharger)
    utility:AddCooldown(4, 2, 212552, nil, true, talents.wraithwalk)
    utility:AddWarlockPortal(5, 2)
    utility:AddCooldown(2.5, 2.9, 56222, nil, true).alphaWhenOffCooldown = 0.1 -- taunt
    utility:AddCooldown(3.5, 2.9, 383269, nil, true, talents.necrolimb)

    ---@type ERACombat_DeathKnight
    return {
        timers = timers,
        utility = utility,
        soulreaper = soulreaperIcon,
        combatHealth = combatHealth,
        combatPower = combatPower,
        damageTaken = damageTaken,
        enemies = ERACombatEnemies:Create(cFrame, spec),
        blooddraw = blooddraw,
        succor = succor
    }
end

---@param combatHealth ERACombatHealth
---@param combatPower ERACombatPower
---@param damageTaken ERACombatDamageTaken
---@param succor ERACombatTimersAura
---@param blooddraw ERACombatTimersAura
---@param talents DKCommonTalents
function ERACombat_DPSDK(combatHealth, combatPower, damageTaken, succor, blooddraw, talents)
    function damageTaken:DamageUpdatedOverride(t)
        local strikeCost
        local additionalH
        if succor.remDuration > succor.group.occupied + 0.1 then
            strikeCost = 0
            combatHealth:SetHealingColor(ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)
            additionalH = 0.1 * combatHealth.maxHealth
        else
            if talents.improved_deathstrike:PlayerHasTalent() then
                strikeCost = 40
            else
                strikeCost = 45
            end
            if blooddraw.remDuration > blooddraw.group.occupied + 0.1 then
                strikeCost = strikeCost - 10
            end
            combatHealth:SetHealingColor(0.5, 0.5, 1.0)
            additionalH = 0
        end
        if combatPower.currentPower >= strikeCost then
            local baseH = combatHealth.maxHealth * 0.07
            local dmgH = 0.25 * self.currentDamage
            if (dmgH > baseH or additionalH > 0) then
                local healing = math.max(baseH, dmgH)
                if (talents.improved_deathstrike:PlayerHasTalent()) then
                    healing = healing * 1.6
                end
                combatHealth:SetHealing(healing + additionalH)
            else
                combatHealth:SetHealing(0)
            end
        else
            combatHealth:SetHealing(0)
        end
    end
end

-------------
--- RUNES ---
-------------

ERARunes = {}
ERARunes.__index = ERARunes
setmetatable(ERARunes, { __index = ERACombatModule })

---@class ERACombatRunes
---@field availableRunes number
---@field nextRuneDuration number
---@field secondNextRuneDuration number
---@field updateCombatBeforeTimers fun(this:ERACombatRunes, t:number))

---comment
---@param cFrame ERACombatFrame
---@param ... number specializations
---@return ERACombatRunes
function ERARunes:Create(cFrame, ...)
    local ru = {}
    setmetatable(ru, ERARunes)

    -- frame
    ru.frame = CreateFrame("Frame", nil, UIParent, nil)
    ru.frame:SetSize(ERADK_RuneSize * 6, ERADK_RuneSize)
    ru.frame:SetPoint("TOP", UIParent, "CENTER", ERADK_BarsX, ERADK_RunesTopY)

    ru.icons = {}
    ru.infos = {}
    for i = 1, 6 do
        -- rune : 1121021
        -- rune violette forte : 252272
        -- rune violette faible : 1323037
        local icon = ERAPieIcon:Create(ru.frame, "TOPRIGHT", ERADK_RuneSize, 252272)
        icon:SetOverlayAlpha(0.95)
        icon:Draw(-(i - 0.5) * ERADK_RuneSize, -ERADK_RuneSize / 2, false)
        table.insert(ru.icons, icon)
        local info = {}
        info.remDur = 0
        info.totDur = 10
        table.insert(ru.infos, info)
    end

    ru.nextRuneDuration = 0
    ru.secondNextRuneDuration = 0
    ru.availableRunes = 0

    ru:construct(cFrame, 0.5, -1, false, ...)
    return ru
end

function ERARunes:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERARunes:ResetToIdle()
    self.frame:Show()
end
function ERARunes:EnterIdle(fromCombat)
    if (not fromCombat) then
        self.frame:Show()
    end
end
function ERARunes:ExitIdle(toCombat)
    if (not toCombat) then
        self.frame:Hide()
    end
end
function ERARunes:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERARunes:ExitCombat(toIdle)
    if (not toIdle) then
        self.frame:Hide()
    end
end

function ERARunes:UpdateIdle(t)
    self:updateData(t)
    if (self.availableRunes < 6) then
        self:updateDisplay()
        self.frame:Show()
    else
        self.frame:Hide()
    end
end
function ERARunes:updateCombatBeforeTimers(t)
    self:updateData(t)
    self:updateDisplay()
end
function ERARunes:updateData(t)
    for i, info in ipairs(self.infos) do
        local start, duration, runeReady = GetRuneCooldown(i)
        if (start and start > 0 and not runeReady) then
            info.remDur = duration - (t - start)
            info.totDur = duration
        else
            info.remDur = 0
        end
    end
    table.sort(self.infos, ERARunes_sort)
    self.nextRuneDuration = self.infos[1].remDur
    self.secondNextRuneDuration = self.infos[2].remDur
    self.availableRunes = 0
    for i, info in ipairs(self.infos) do
        if (info.remDur <= 0) then
            self.availableRunes = self.availableRunes + 1
        else
            break
        end
    end
end
function ERARunes_sort(r1, r2)
    return r1.remDur < r2.remDur
end
function ERARunes:updateDisplay()
    for i, info in ipairs(self.infos) do
        local icon = self.icons[i]
        if (info.remDur <= 0) then
            icon:SetIconTexture(1121021)
            icon:SetOverlayValue(0)
        else
            icon:SetIconTexture(1323037)
            icon:SetOverlayValue(info.remDur / info.totDur)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- fucking blizzard API considering spells are on cooldown when runes are not available --------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatCooldownIgnoringRunes = {}
ERACombatCooldownIgnoringRunes.__index = ERACombatCooldownIgnoringRunes
setmetatable(ERACombatCooldownIgnoringRunes, { __index = ERACombatTimer })


---@class ERACombatTimersCooldownIgnoringRunes : ERACombatTimersCooldown
---@field runeCost number
---@field PreUpdateOverride fun(this:ERACombatTimersCooldownIgnoringRunes, t:number)

---comment
---@param group ERACombatTimers
---@param runes ERACombatRunes
---@param runeCost number
---@param spellID number
---@param talent ERALIBTalent | nil
---@param ... ERACombatTimersAdditionalID
---@return ERACombatTimersCooldownIgnoringRunes
function ERACombatCooldownIgnoringRunes:Create(group, runes, runeCost, spellID, talent, ...)
    local t = {}
    setmetatable(t, ERACombatCooldownIgnoringRunes)
    t:constructTimer(group, talent)
    t.mainSpellID = spellID
    t.spellID = spellID
    t.additionalIDs = { ... }
    t.runes = runes
    t.runeCost = runeCost
    ERACombatCooldown_UpdateKind(t)
    return t
end

function ERACombatCooldownIgnoringRunes:TalentCheck()
    ERACombatCooldown_UpdateKind(self)
    if (not self.talentActive) then
        self.currentCharges = 0
    end
end

function ERACombatCooldownIgnoringRunes:updateAfterReset(t)
    ERACombatCooldown_UpdateKind(self)
end

function ERACombatCooldownIgnoringRunes:PreUpdateOverride(t)
end

function ERACombatCooldownIgnoringRunes:updateDurations(t)
    self:PreUpdateOverride(t)
    ERACooldownIgnoringRunes_updateDurations(self, self.runes, self.runeCost, t, self.group.totGCD)
end

---comment
---@param cd any
---@param runes ERACombatRunes
---@param runeCost number
---@param t number
---@param totGCD number
function ERACooldownIgnoringRunes_updateDurations(cd, runes, runeCost, t, totGCD)
    if (cd.hasCharges) then
        local chargesInfo = C_Spell.GetSpellCharges(cd.spellID)
        if (chargesInfo) then
            cd.currentCharges = chargesInfo.currentCharges
            cd.maxCharges = chargesInfo.maxCharges
            cd.totDuration = chargesInfo.cooldownDuration
            if (cd.currentCharges >= cd.maxCharges) then
                cd.remDuration = 0
                cd.isAvailable = true
            else
                cd.remDuration = chargesInfo.cooldownDuration - (t - chargesInfo.cooldownStartTime)
                cd.isAvailable = cd.currentCharges > 0
            end
            cd.lastGoodUpdate = t
            cd.lastGoodDuration = cd.remDuration
            return
        end
    end
    local cdInfo = C_Spell.GetSpellCooldown(cd.spellID)
    if (cdInfo and cdInfo.startTime and cdInfo.startTime > 0) then
        local remDur = cdInfo.duration - (t - cdInfo.startTime)
        local hasRunes = runes.availableRunes >= runeCost
        local durDiff
        if (not hasRunes) then
            if runeCost == 1 then
                durDiff = math.abs(remDur - runes.nextRuneDuration)
            else
                durDiff = math.abs(remDur - runes.secondNextRuneDuration)
            end
        end
        if (hasRunes or (not (cd.lastGoodUpdate)) or durDiff > 0.1) then
            if (cdInfo.duration <= totGCD + 0.2 and cd.lastGoodUpdate) then
                cd.isAvailable = true
                cd.currentCharges = 1
                -- cd.totDuration reste inchangé
                cd.remDuration = cd.lastGoodDuration - (t - cd.lastGoodUpdate)
                if (cd.remDuration < 0) then
                    cd.remDuration = 0
                elseif (cd.remDuration > remDur) then
                    cd.remDuration = remDur
                end
                return
            end
            cd.currentCharges = 0
            cd.isAvailable = false
            cd.totDuration = cdInfo.duration
            cd.remDuration = remDur
            cd.lastGoodDuration = remDur
            cd.lastGoodUpdate = t
        else
            -- cd.totDuration reste inchangé
            cd.remDuration = cd.lastGoodDuration - (t - cd.lastGoodUpdate)
            if (cd.remDuration < 0) then
                cd.remDuration = 0
                cd.currentCharges = 1
                cd.isAvailable = true
                return
            end
            if (cd.remDuration > remDur) then
                cd.remDuration = remDur
            end
            cd.currentCharges = 0
            cd.isAvailable = false
        end
    else
        cd.isAvailable = true
        if (cdInfo) then
            cd.totDuration = cdInfo.duration or 1
        else
            cd.totDuration = 1
        end
        cd.remDuration = 0
        cd.currentCharges = 1
        cd.lastGoodUpdate = t
        cd.lastGoodDuration = 0
    end
end

---@class ERACombatUtilityCooldownIgnoringRunes : ERACombatUtilityCooldown
---@field private runes ERACombatRunes
---@field private runeCost number

---@class ERACombatUtilityCooldownIgnoringRunes
ERACombatUtilityCooldownIgnoringRunes = {}
ERACombatUtilityCooldownIgnoringRunes.__index = ERACombatUtilityCooldownIgnoringRunes
setmetatable(ERACombatUtilityCooldownIgnoringRunes, { __index = ERACombatUtilityCooldown })

---comment
---@param owner ERACombatUtilityFrame
---@param x number
---@param y number
---@param spellID number
---@param iconID number|nil
---@param showInCombat boolean
---@param runes ERACombatRunes
---@param runeCost number
---@param talent ERALIBTalent | nil
---@param ... ERACombatTimersAdditionalID
---@return ERACombatUtilityCooldownIgnoringRunes
function ERACombatUtilityCooldownIgnoringRunes:Create(owner, x, y, spellID, iconID, showInCombat, runes, runeCost, talent, ...)
    local c = ERACombatUtilityCooldown:create(owner, x, y, spellID, iconID, showInCombat, talent, ...)
    setmetatable(c, ERACombatUtilityCooldownIgnoringRunes)
    ---@cast c ERACombatUtilityCooldownIgnoringRunes
    c.runes = runes
    c.runeCost = runeCost
    return c
end

function ERACombatUtilityCooldownIgnoringRunes:specialUpdate(t, totGCD)
    ERACooldownIgnoringRunes_updateDurations(self, self.runes, self.runeCost, t, totGCD)
end

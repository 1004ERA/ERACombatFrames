---@class ERACombatTimers_DK_Blood : ERACombatTimers
---@field strikeCost number

---@param cFrame ERACombatFrame
---@param runes ERACombatRunes
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightBloodSetup(cFrame, runes, talents)
    local talent_ossuary = ERALIBTalent:Create(96277)
    local talent_bloodmark = ERALIBTalent:Create(96271)
    local talent_tombstone = ERALIBTalent:Create(96270)
    local talent_bonestorm = ERALIBTalent:Create(96258)
    local talent_gorefiend = ERALIBTalent:Create(96170)
    local talent_vblood = ERALIBTalent:Create(96308)
    local talent_improved_vblood = ERALIBTalent:Create(96272)
    local talent_drw = ERALIBTalent:Create(96269)
    local talent_runetap = ERALIBTalent:Create(96301)
    local talent_bloodtap = ERALIBTalent:Create(96167)
    local talent_consumption = ERALIBTalent:Create(126299)
    local talent_drinker = ERALIBTalent:Create(126300)
    local talent_voracious = ERALIBTalent:Create(96171)
    local talent_sanground = ERALIBTalent:Create(96169)

    local dk = ERACombat_CommonDK(cFrame, runes, 1, talents, 2 * ERADK_BarsHeight / 3, 0, ERADK_BarsHeight / 3, 1)

    local timers = dk.timers
    ---@cast timers ERACombatTimers_DK_Blood
    timers.strikeCost = 40

    local boneshield = timers:AddTrackedBuff(195181)

    local vblood = timers:AddTrackedBuff(55233, talent_vblood)
    local sanground = timers:AddTrackedBuff(391459, talent_sanground)

    function timers:DataUpdatedOverride(t)
        local cost = 45
        if talents.improved_deathstrike:PlayerHasTalent() then
            cost = cost - 5
        end
        if dk.blooddraw.remDuration > self.occupied + 0.1 then
            cost = cost - 10
        end
        if (talent_ossuary:PlayerHasTalent() and boneshield.stacks >= 5) then
            cost = cost - 5
        end
        self.strikeCost = cost
    end

    function dk.damageTaken:DamageUpdatedOverride(t)
        local additionalH
        local strikeCost
        if dk.succor.remDuration > dk.succor.group.occupied + 0.1 then
            strikeCost = 0
            dk.combatHealth:SetHealingColor(ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)
            additionalH = 0.1 * dk.combatHealth.maxHealth
        else
            strikeCost = timers.strikeCost
            dk.combatHealth:SetHealingColor(0.5, 0.5, 1.0)
            additionalH = 0
        end
        if dk.combatPower.currentPower >= strikeCost or additionalH > 0 then
            local baseH = dk.combatHealth.maxHealth * 0.07
            local dmgH = 0.25 * self.currentDamage
            if (dmgH > baseH) then
                local healing = math.max(baseH, dmgH)
                if (talents.improved_deathstrike:PlayerHasTalent()) then
                    healing = healing * 1.6
                end
                if (talent_voracious:PlayerHasTalent()) then
                    healing = healing * 1.15
                end
                if (sanground.remDuration > dk.timers.occupied + 0.1) then
                    healing = healing * 1.05
                end
                if (vblood.remDuration > dk.timers.occupied + 0.1) then
                    healing = healing * (1 + (0.3 + talent_improved_vblood.rank * 0.05))
                end
                dk.combatHealth:SetHealing(healing + additionalH)
            else
                dk.combatHealth:SetHealing(0)
            end
        else
            dk.combatHealth:SetHealing(0)
        end
    end

    local strikeConsumer = dk.combatPower:AddConsumer(35, nil, nil)
    strikeConsumer.requireContinuousUpdate = true
    function strikeConsumer:ComputeValueOverride(t)
        return timers.strikeCost
    end
    dk.combatPower:AddThreashold(20, nil, nil)

    local window = ERACombatDamageTakenWindow:Create(timers, dk.damageTaken, 222, 333, 1)

    timers:AddAuraIcon(boneshield, 0, 0)
    --timers:AddMissingAura(boneshield, nil, 0, 0, false)

    local bloodboil = timers:AddTrackedCooldown(50842)
    local bloodboilIcon = timers:AddCooldownIcon(bloodboil, nil, -1, 0, true, true)

    local dnd = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 43265)
    local dndIcon = dk.timers:AddCooldownIcon(dnd, nil, -2, 0, true, true)

    local drinker = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 206931, talent_drinker)
    local drinkerIcon = dk.timers:AddCooldownIcon(drinker, nil, -0.5, -0.9, true, true)
    local consumption = timers:AddTrackedCooldown(274156, talent_consumption)
    local consumptionIcon = dk.timers:AddCooldownIcon(consumption, nil, -0.5, -0.9, true, true)

    local runetap = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 194679, talent_runetap)
    local runetapIcon = dk.timers:AddCooldownIcon(runetap, nil, -2.5, -0.9, true, true)

    local caress = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 195292)
    local caressIcon = dk.timers:AddCooldownIcon(caress, nil, -1, -1.8, true, true)

    local tombstone = timers:AddTrackedCooldown(219809, talent_tombstone)
    local tombstoneIcon = dk.timers:AddCooldownIcon(tombstone, nil, -1.5, -0.9, true, true)

    local bloodmarkDebuff = timers:AddTrackedDebuff(206940, talent_bloodmark)
    timers:AddAuraBar(bloodmarkDebuff, nil, 0.9, 0.3, 0.3)
    local bloodmarkCooldown = timers:AddTrackedCooldown(206940, talent_bloodmark)
    local bloodmarkIcon = timers:AddCooldownIcon(bloodmarkCooldown, nil, -1.5, -0.9, true, true)

    local bonestorm = timers:AddTrackedCooldown(194844, talent_bonestorm)
    local bonestormIcon = dk.timers:AddCooldownIcon(bonestorm, nil, -2, -1.8, true, true)

    local bloodtap = timers:AddTrackedCooldown(221699, talent_bloodtap)
    local bloodtapIcon = dk.timers:AddCooldownIcon(bonestorm, nil, 1.9, 0.5, true, true)

    local crimson = timers:AddTrackedBuff(81141)
    timers:AddAuraBar(crimson, nil, 0.5, 1.0, 0.1)

    local drw = timers:AddTrackedBuff(81256, talent_drw)
    timers:AddAuraBar(drw, nil, 1.0, 0.8, 0.6)

    timers:AddAuraBar(vblood, nil, 1.0, 0.0, 0.0)

    --------------
    -- priority --
    --------------

    --[[

    1 - soul reaper
    2 - bloodmark
    3 - boil
    4 - dnd proc
    5 - bloodtap
    6 - dnd
    7 - consumption
    8 - drinker
    9 - runetap
    10 - bloodmark refresh

    ]]

    function bloodmarkIcon:ComputeAvailablePriorityOverride()
        if bloodmarkDebuff.remDuration <= self.group.occupied then
            return 2
        elseif bloodmarkDebuff.remDuration <= 4 then
            return 10
        else
            return 0
        end
    end

    function bloodboilIcon:ComputeAvailablePriorityOverride()
        if self.cd.currentCharges == self.cd.maxCharges or self.cd.currentCharges + 1 == self.cd.maxCharges and self.cd.remDuration <= self.group.occupied + 0.1 then
            return 3
        else
            return 0
        end
    end

    function dndIcon:ComputeAvailablePriorityOverride()
        if crimson.remDuration > self.group.occupied + 0.1 then
            return 4
        else
            return 6
        end
    end

    function bloodtapIcon:ComputeAvailablePriorityOverride()
        if runes.availableRunes == 0 and runes.nextRuneDuration > self.group.occupied then
            return 5
        else
            return 0
        end
    end

    function consumptionIcon:ComputeAvailablePriorityOverride()
        return 7
    end

    function drinkerIcon:ComputeAvailablePriorityOverride()
        return 8
    end

    function runetapIcon:ComputeAvailablePriorityOverride()
        return 9
    end

    -------------
    -- utility --
    -------------

    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY, 55233, nil, true, talent_vblood)
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY - 1, 49028, nil, true, talent_drw)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY, 46585, nil, true, talents.raisedead)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY - 1, 327574, nil, true, talents.sacrifice)
    dk.utility:AddCooldown(2, 1, 108199, nil, true, talent_gorefiend)
    -- out of combat
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX + 1, ERADK_UtilityBaseY + 1, 195292, nil, false, runes, 1) -- caress
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY + 1, 50842, nil, false)                                                  -- boil
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 1, 43265, nil, false, runes, 1)  -- dnd
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 2, 194844, nil, false, talent_bonestorm)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX, ERADK_UtilityBaseY + 2, 206931, nil, false, runes, 1, talent_drinker)
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY + 2, 274156, nil, false, talent_consumption)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX + 1, ERADK_UtilityBaseY + 2, 194679, nil, false, runes, 1, talent_runetap)
end

---comment
---@param timers ERACombatTimers
---@param talent_short_eruption ERALIBTalent
---@param talent_burst_eruption ERALIBTalent
---@param burstTimer ERACombatTimersAura
---@return number
function ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
    local mult
    if (talent_burst_eruption:PlayerHasTalent() and burstTimer.remDuration > timers.occupied) then
        mult = 0.6
    else
        mult = 1
    end
    if (talent_short_eruption:PlayerHasTalent()) then
        mult = mult * 0.8
    end
    return mult * 2.5 / timers.haste
end

---comment
---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param essence ERACombat_EvokerEssence
---@param combatHealth ERACombatHealth
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerAugmentationSetup_OLD(cFrame, enemies, essence, combatHealth, talents)
    local talent_eons = ERALIBTalent:Create(115536)
    local talent_big_empower = ERALIBTalent:Create(115532)
    local talent_prescience = ERALIBTalent:Create(115675)
    local talent_blistering = ERALIBTalent:Create(115508)
    local talent_blossom_cooldown = ERALIBTalent:CreateNotTalent(115881)
    local talent_blossom_essence = ERALIBTalent:Create(115881)
    local talent_skip = ERALIBTalent:CreateAnd(ERALIBTalent:Create(115533), ERALIBTalent:CreateNotTalent(115686))
    local talent_short_eruption = ERALIBTalent:Create(115621)
    local talent_burst_eruption = ERALIBTalent:Create(115531)
    local talent_more_burst = ERALIBTalent:Create(115519)
    local talent_cheap_eruption = ERALIBTalent:Create(115505)
    local talent_attunement = ERALIBTalent:Create(115518)

    local firstColumnX = 0.9

    local timers = ERACombat_EvokerDPS(cFrame, talents, talent_big_empower, 3)
    ---@type ERACombat_EvokerTimerParams
    local tParams = {
        quellX = firstColumnX,
        quellY = 3,
        unravelX = firstColumnX,
        unravelY = 2,
        unravelPrio = 8
    }
    local utility = ERACombat_EvokerSetup(cFrame, timers, tParams, talents, 3)
    ERACombat_EvokerDPS_Utility(utility, talents)

    local burstTimer = timers:AddTrackedBuff(392268)
    local eonsCooldown = timers:AddTrackedCooldown(403631, talent_eons)

    local prescience_ID = 409311
    local prescience = timers:AddTrackedCooldown(prescience_ID, talent_prescience)
    local prescienceIcon = timers:AddCooldownIcon(prescience, nil, 0, 0, true, true)

    local might_ID = 395152
    local might = timers:AddTrackedCooldown(might_ID)
    local mightIcon = timers:AddCooldownIcon(might, nil, -1, 0, true, true)

    local uph_alternative = {
        id = 408092,
        talent = talent_big_empower
    }
    local uph_ID = 396286
    local uph = timers:AddTrackedCooldown(uph_ID, nil, uph_alternative)
    local uphIcon = timers:AddCooldownIcon(uph, nil, -2, 0, true, true)

    local firebreathIcon = timers:AddCooldownIcon(timers.evoker_firebreathCooldown, nil, -3, 0, true, true)

    local blistering_ID = 360827
    local blistering = timers:AddTrackedCooldown(blistering_ID, talent_blistering)
    local blisteringIcon = timers:AddCooldownIcon(blistering, nil, -1.5, -0.9, true, true)

    local blossom_ID = 355913
    local blossom = timers:AddTrackedCooldown(blossom_ID, talent_blossom_cooldown)
    local blossomIcon = timers:AddCooldownIcon(blossom, nil, -2.5, -0.9, true, true)

    local eruptionMarker = timers:AddMarker(0.9, 0.6, 0.5)
    function eruptionMarker:ComputeTimeOr0IfInvisibleOverride(haste)
        return ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
    end

    local might_buff_ID = 395296
    local mightTimer = timers:AddTrackedBuff(might_buff_ID)
    local mightLongBar = timers:AddAuraBar(mightTimer, nil, 0.7, 0.6, 0.2)
    function mightLongBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (self.aura.remDuration > 0.05 + self.group.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.group, talent_short_eruption, talent_burst_eruption, burstTimer)) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local mightShortBar = timers:AddAuraBar(mightTimer, nil, 0.4, 0.4, 0.4)
    function mightShortBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (self.aura.remDuration <= 0.05 + self.group.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.group, talent_short_eruption, talent_burst_eruption, burstTimer)) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    ------------
    --- prio ---
    ------------

    --[[

    1 - might
    2 - eruption refresh (overflow)
    3 - uph refresh
    4 - firebreath refresh
    5 - living flame multiflame fading soon
    6 - prescience
    7 - eruption refresh
    8 - unravel
    9 - blistering
    10 - blossom
    11 - eons

    ]]

    function mightIcon:ComputeAvailablePriorityOverride()
        return 1
    end

    local eruptionPrio = timers:AddPriority(5199630)
    function eruptionPrio:ComputePriority(t)
        local castTime = ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
        if (mightTimer.remDuration > timers.occupied + castTime + 0.1) then
            if (
                    (burstTimer.stacks > 1 or (burstTimer.stacks == 1 and not talent_more_burst:PlayerHasTalent()))
                    or
                    (essence.currentPoints >= essence.maxPoints or (essence.currentPoints + 1 >= essence.maxPoints and essence.nextAvailable < 2))
                ) then
                return 2
            elseif (essence.currentPoints >= 3 or (essence.currentPoints >= 2 and talent_cheap_eruption:PlayerHasTalent())) then
                return 7
            else
                return 0
            end
        else
            return 0
        end
    end

    function uphIcon:ComputeAvailablePriorityOverride()
        if (mightTimer.remDuration > timers.occupied + 2.5 * timers.haste + 0.1) then
            return 3
        else
            return 0
        end
    end

    function firebreathIcon:ComputeAvailablePriorityOverride()
        if (mightTimer.remDuration > timers.occupied + 2.5 * timers.haste + 0.1) then
            return 4
        else
            return 0
        end
    end

    local livingPrio = timers:AddPriority(4622464)
    function livingPrio:ComputePriority(t)
        local dur = timers.evoker_leapingBuff.remDuration
        if (timers.occupied < dur and dur < 4) then
            return 5
        else
            return 0
        end
    end

    function prescienceIcon:ComputeAvailablePriorityOverride()
        return 6
    end

    function blisteringIcon:ComputeAvailablePriorityOverride()
        return 9
    end

    function blossomIcon:ComputeAvailablePriorityOverride()
        if (talents.fast_blossom:PlayerHasTalent()) then
            return 10
        else
            return 0
        end
    end

    local eonsPrio = timers:AddPriority(5199622)
    function eonsPrio:ComputePriority(t)
        if (talent_eons:PlayerHasTalent() and eonsCooldown.remDuration <= timers.occupied) then
            return 11
        else
            return 0
        end
    end

    ---------------
    --- utility ---
    ---------------

    utility:AddMissingBuffAnyCaster(5199623, -1, -1.5, talent_attunement, 403264, 403265)

    utility:AddCooldown(-1.5, 0.9, 403631, nil, true, talents.not_maneuverability) -- breath of eons
    utility:AddCooldown(-1.5, 0.9, 442204, nil, true, talents.maneuverability)     -- breath of eons
    utility:AddCooldown(-4, 0, 404977, 5201905, true, talent_skip)

    -- out of combat

    utility:AddBuffIcon(utility:AddTrackedBuff(might_buff_ID), 5199624, -1.2, 3.5, false)
    utility:AddCooldown(-2, 3, might_ID, nil, false)
    utility:AddCooldown(-3, 3, uph_ID, nil, false)
    utility:AddCooldown(-3, 3, uph_ID, nil, false)
    utility:AddCooldown(-4, 3, 382266, nil, false, talent_big_empower)
    utility:AddCooldown(-4, 3, 357208, nil, false, ERALIBTalent:CreateNot(talent_big_empower))
    utility:AddCooldown(-2, 4, prescience_ID, nil, false, talent_prescience)
    utility:AddCooldown(-3, 4, blistering_ID, nil, false, talent_blistering)
    utility:AddCooldown(-4, 4, blossom_ID, nil, false, talent_blossom_cooldown)
end

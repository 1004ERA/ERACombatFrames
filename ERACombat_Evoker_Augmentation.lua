---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerAugmentationSetup(cFrame, enemies, talents)
    local talent_eons = ERALIBTalent:Create(115536)
    local talent_big_empower = ERALIBTalent:Create(115532)
    local talent_prescience = ERALIBTalent:Create(115675)
    local talent_uph = ERALIBTalent:Create(115502)
    local talent_blistering = ERALIBTalent:Create(115508)
    local talent_blossom_cooldown = ERALIBTalent:CreateNotTalent(115881)
    local talent_blossom_rotation = ERALIBTalent:CreateAnd(talent_blossom_cooldown, talents.fast_blossom)
    local talent_blossom_utility = ERALIBTalent:CreateAnd(talent_blossom_cooldown, ERALIBTalent:CreateNot(talents.fast_blossom))
    local talent_skip = ERALIBTalent:CreateAnd(ERALIBTalent:Create(115533), ERALIBTalent:CreateNotTalent(115686))
    local talent_short_eruption = ERALIBTalent:Create(115621)
    local talent_burst_eruption = ERALIBTalent:Create(115531)
    local talent_more_burst = ERALIBTalent:Create(115519)
    local talent_cheap_eruption = ERALIBTalent:Create(115505)
    local talent_attunement = ERALIBTalent:Create(115518)

    local hud = ERAEvokerCommonSetup(cFrame, 10, "TO_LEFT", 392268, 8, talents, talent_big_empower, 3)

    local mightBuff = hud:AddTrackedBuff(395296)

    --- rotation ---

    local prescienceCooldown = hud:AddTrackedCooldown(409311, talent_prescience)
    local prescienceIcon = hud:AddRotationCooldown(prescienceCooldown)

    local mighCooldown = hud:AddTrackedCooldown(395152)
    local mightIcon = hud:AddRotationCooldown(mighCooldown)

    ---@type ERACooldownAdditionalID
    local uph_alternative = {
        spellID = 408092,
        talent = talent_big_empower
    }
    local uphCooldown = hud:AddTrackedCooldown(396286, talent_uph, uph_alternative)
    local uphIcon = hud:AddRotationCooldown(uphCooldown)

    local firebreathIcon = hud:AddRotationCooldown(hud.evoker_firebreathCooldown)

    local blisteringIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(360827, talent_blistering))

    local blossomCooldown = hud:AddTrackedCooldown(355913, talent_blossom_cooldown)
    local blossomIcon = hud:AddRotationCooldown(blossomCooldown, nil, talent_blossom_rotation)

    local eruptionMarker = hud:AddMarker(0.9, 0.6, 0.5)
    function eruptionMarker:ComputeTimeOr0IfInvisibleOverride(t)
        return ERACombatFrames_EvokerAugmentation_EruptionCastTime(hud, talent_short_eruption, talent_burst_eruption, hud.evoker_essenceBurst)
    end

    --[[

    PRIO

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

    function mightIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    local eruptionPrio = hud:AddPriority(5199630)
    function eruptionPrio:ComputeAvailablePriorityOverride(t)
        local castTime = ERACombatFrames_EvokerAugmentation_EruptionCastTime(hud, talent_short_eruption, talent_burst_eruption, hud.evoker_essenceBurst)
        if (mightBuff.remDuration > hud.occupied + castTime + 0.1) then
            if (
                    (hud.evoker_essenceBurst.stacks > 1 or (hud.evoker_essenceBurst.stacks == 1 and not talent_more_burst:PlayerHasTalent()))
                    or
                    (hud.evoker_essence.currentPoints >= hud.evoker_essence.maxPoints or (hud.evoker_essence.currentPoints + 1 >= hud.evoker_essence.maxPoints and hud.evoker_essence.nextAvailable < 2))
                ) then
                return 2
            elseif (hud.evoker_essence.currentPoints >= 3 or (hud.evoker_essence.currentPoints >= 2 and talent_cheap_eruption:PlayerHasTalent())) then
                return 7
            else
                return 0
            end
        else
            return 0
        end
    end

    function uphIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if (mightBuff.remDuration > hud.occupied + 2.5 * hud.hasteMultiplier + 0.1) then
            return 3
        else
            return 0
        end
    end

    function firebreathIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if (mightBuff.remDuration > hud.occupied + 2.5 * hud.hasteMultiplier + 0.1) then
            return 4
        else
            return 0
        end
    end

    local livingPrio = hud:AddPriority(4622464)
    function livingPrio:ComputeAvailablePriorityOverride(t)
        local dur = hud.evoker_leapingBuff.remDuration
        if self.hud.occupied < dur and dur < 4 then
            return 5
        else
            return 0
        end
    end

    function prescienceIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function blisteringIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function blossomIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if (talents.fast_blossom:PlayerHasTalent()) then
            return 10
        else
            return 0
        end
    end

    --- bars ---

    hud:AddAuraBar(hud:AddTrackedBuff(406732, talents.paradox), nil, 1, 0.9, 0.7)

    local mightLongBar = hud:AddAuraBar(mightBuff, nil, 0.7, 0.6, 0.2)
    function mightLongBar:ComputeDurationOverride(t)
        if (self.aura.remDuration > 0.1 + self.hud.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.hud, talent_short_eruption, talent_burst_eruption, hud.evoker_essenceBurst)) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local mightShortBar = hud:AddAuraBar(mightBuff, nil, 0.4, 0.4, 0.4)
    function mightShortBar:ComputeDurationOverride(t)
        if (self.aura.remDuration > 0.1 + self.hud.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.hud, talent_short_eruption, talent_burst_eruption, hud.evoker_essenceBurst)) then
            return 0
        else
            return self.aura.remDuration
        end
    end

    --- utility ---

    hud:AddEmptyTimer(hud:AddOrTimer(true, hud:AddTrackedBuff(403264, talent_attunement), hud:AddTrackedBuff(403265, talent_attunement)), 12, 5199623, talent_attunement)

    hud:AddUtilityCooldown(blossomCooldown, hud.healGroup, nil, nil, talent_blossom_utility, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(403631, ERALIBTalent:CreateAnd(talent_eons, talents.not_maneuverability)), hud.powerUpGroup, nil, -2, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(442204, ERALIBTalent:CreateAnd(talent_eons, talents.maneuverability)), hud.powerUpGroup, nil, -2, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(404977, talent_skip), hud.powerUpGroup, 5201905, -1, nil, true)

    hud:AddUtilityAuraOutOfCombat(mightBuff)
end

---@param hud ERAHUD
---@param talent_short_eruption ERALIBTalent
---@param talent_burst_eruption ERALIBTalent
---@param burstTimer ERAAura
---@return number
function ERACombatFrames_EvokerAugmentation_EruptionCastTime(hud, talent_short_eruption, talent_burst_eruption, burstTimer)
    local mult
    if (talent_burst_eruption:PlayerHasTalent() and burstTimer.remDuration > hud.occupied) then
        mult = 0.6
    else
        mult = 1
    end
    if (talent_short_eruption:PlayerHasTalent()) then
        mult = mult * 0.8
    end
    return mult * 2.5 * hud.hasteMultiplier
end

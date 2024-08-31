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
function ERACombatFrames_EvokerAugmentationSetup(cFrame, enemies, essence, combatHealth, talents)
    local talent_big_empower = ERALIBTalent:Create(115532)
    local talent_prescience = ERALIBTalent:Create(115675)
    local talent_blistering = ERALIBTalent:Create(115508)
    local talent_blossom_cooldown = ERALIBTalent:CreateNotTalent(115881)
    local talent_blossom_essence = ERALIBTalent:Create(115881)
    local talent_skip = ERALIBTalent:CreateAnd(ERALIBTalent:Create(115533), ERALIBTalent:CreateNotTalent(115686))
    local talent_short_eruption = ERALIBTalent:Create(115621)
    local talent_burst_eruption = ERALIBTalent:Create(115531)

    local firstColumnX = 0.9

    local dps = ERACombat_EvokerDPS(cFrame, talents, talent_big_empower, 3)
    local timers = dps.timers
    ---@cast timers ERACombatTimers_EvokerDevastation
    ---@type ERACombat_EvokerTimerParams
    local tParams = {
        quellX = firstColumnX,
        quellY = 3,
        unravelX = firstColumnX,
        unravelY = 2,
        unravelPrio = 2
    }
    local utility = ERACombat_EvokerSetup(cFrame, dps.timers, tParams, talents, 3)

    local burstTimer = dps.timers:AddTrackedBuff(392268)

    local prescience = timers:AddTrackedCooldown(409311, talent_prescience)
    local prescienceIcon = timers:AddCooldownIcon(prescience, nil, 0, 0, true, true)

    local might = timers:AddTrackedCooldown(395152)
    local mightIcon = timers:AddCooldownIcon(might, nil, -1, 0, true, true)

    local uph_alternative = {
        id = 408092,
        talent = talent_big_empower
    }
    local uph = timers:AddTrackedCooldown(396286, nil, uph_alternative)
    local uphIcon = timers:AddCooldownIcon(uph, nil, -2, 0, true, true)

    local firebreathIcon = dps.timers:AddCooldownIcon(dps.firebreathCooldown, nil, -3, 0, true, true)

    local blistering = timers:AddTrackedCooldown(360827)
    local blisteringIcon = timers:AddCooldownIcon(blistering, nil, -1.5, -0.9, true, true)

    local blossom = timers:AddTrackedCooldown(355913, talent_blossom_cooldown)
    local blossomIcon = timers:AddCooldownIcon(blossom, nil, -2.5, -0.9, true, true)

    local eruptionMarker = timers:AddMarker(0.9, 0.6, 0.5)
    function eruptionMarker:ComputeTimeOr0IfInvisibleOverride(haste)
        return ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
    end

    local mightTimer = timers:AddTrackedBuff(395296)
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

    ---------------
    --- utility ---
    ---------------

    utility:AddMissingBuffAnyCaster(5199623, -1, -1.5, ERALIBTalent:Create(115518), 403264, 403265) -- attunement

    utility:AddCooldown(-0.5, 0.9, 403631, nil, true)                                               -- breath of eons
    utility:AddCooldown(-4, 0, 404977, 5201905, true, talent_skip)                                  -- skip
end

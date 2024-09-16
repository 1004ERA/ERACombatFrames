---@class (exact) ERAEvokerDevastationHUD : ERAEvokerHUD
---@field evoker_goodSpells number

---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, talents)
    local talent_big_empower = ERALIBTalent:Create(115586)
    local talent_surge = ERALIBTalent:Create(115581)
    local talent_firestorm = ERALIBTalent:Create(115585)
    local talent_instastorm = ERALIBTalent:Create(115584)
    local talent_shatter = ERALIBTalent:Create(115627)
    local talent_iridescence = ERALIBTalent:Create(115633)
    local talent_dragonrage = ERALIBTalent:Create(115643)
    local talent_massdisintegrate = ERALIBTalent:Create(117536)
    local talent_charged_blast = ERALIBTalent:Create(115628)
    local talent_imminent_destruction = ERALIBTalent:Create(115638)

    local hud = ERAHUD:Create(cFrame, 1.5, false, false, 0, 0.0, 0.0, 1.0, false, 1)
    ---@cast hud ERAEvokerDevastationHUD
    hud.power.hideFullOutOfCombat = true
    hud.powerHeight = 10
    function hud:IsCombatPowerVisibleOverride(t)
        return self.power.currentPower / self.power.maxPower <= 0.75
    end

    ERAEvokerCommonSetup(hud, "TO_LEFT", 359618, 2, talents, talent_big_empower, 1)

    --- rotation ---

    local shatterIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(370452, talent_shatter))

    local surge_alternative = {
        id = 382411,
        talent = talent_big_empower,
    }
    local surgeCooldown = hud:AddTrackedCooldown(359073, talent_surge, surge_alternative)
    local surgeIcon = hud:AddRotationCooldown(surgeCooldown)

    local firebreathIcon = hud:AddRotationCooldown(hud.evoker_firebreathCooldown)

    local firestormIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(368847, talent_firestorm))

    local engulfIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(443328, talents.engulf))

    hud:AddRotationStacks(hud:AddTrackedBuff(370454, talent_charged_blast), 20, 18).soundOnHighlight = SOUNDKIT.UI_VOID_STORAGE_UNLOCK

    --[[

    PRIO

    1 - shatter (good spells available)
    2 - unravel
    3 - flame tempo
    4 - strike tempo
    5 - shatter (good spells soon available)
    6 - breath
    7 - surge
    8 - engulf
    9 - storm
    10 - shatter

    ]]

    function hud:PreUpdateDisplayOverride(t)
        local goodSpells = 1024
        if (talent_surge:PlayerHasTalent()) then
            goodSpells = math.min(goodSpells, surgeCooldown.remDuration)
        end
        if (hud.evoker_unravelUsable or hud.evoker_unravelAbsorbValue > 0) then
            goodSpells = math.min(goodSpells, hud.evoker_unravelIcon.data.remDuration)
        end
        hud.evoker_goodSpells = goodSpells
    end

    function shatterIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if hud.evoker_goodSpells <= self.hud.occupied then
            return 1
        elseif hud.evoker_goodSpells <= 3 then
            return 5
        else
            return 10
        end
    end

    local livingPrio = hud:AddPriority(4622464)
    function livingPrio:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() < 3 and 0 < hud.evoker_goodSpells and hud.evoker_goodSpells <= 3 then
            return 3
        else
            return 0
        end
    end
    local strikePrio = hud:AddPriority(4622447)
    function strikePrio:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() >= 3 and 0 < hud.evoker_goodSpells and hud.evoker_goodSpells <= 3 then
            return 3
        else
            return 0
        end
    end

    function firebreathIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function surgeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    function engulfIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function firestormIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if (enemies:GetCount() > 1) then
            return 9
        else
            return 0
        end
    end

    --- SAO ---

    local instastorm = hud:AddTrackedBuff(370818, talent_instastorm)
    hud:AddAuraOverlay(instastorm, 1, 4699057, false, "TOP", false, false, false, false)

    --- bars ---

    hud:AddAuraBar(hud:AddTrackedBuff(406732, talents.paradox), nil, 1, 0.9, 0.7)

    local instastormBar = hud:AddAuraBar(instastorm, nil, 0.6, 0.0, 0.0)
    function instastormBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(386353, talent_iridescence), nil, 1.0, 0.0, 0.0)
    hud:AddAuraBar(hud:AddTrackedBuff(386399, talent_iridescence), nil, 0.0, 0.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(370452, talent_shatter), nil, 1.0, 0.3, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(375087, talent_dragonrage), nil, 1.0, 0.3, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(411055, talent_imminent_destruction), nil, 0.2, 1.0, 0.5)

    hud:AddAuraBar(hud:AddTrackedBuff(436336, talent_massdisintegrate), nil, 0.8, 0.2, 1.0)

    local fireDOT = hud:AddTrackedDebuffOnTarget(357209)
    local fireDOTBar = hud:AddAuraBar(fireDOT, nil, 1.0, 1.0, 0.0)
    function fireDOTBar:ComputeDurationOverride(t)
        if (talents.engulf:PlayerHasTalent() and engulfIcon.data.remDuration <= self.hud.timerDuration) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(355913), hud.healGroup) -- emerald blossom

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(375087, talent_dragonrage), hud.powerUpGroup, nil, -2)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(357210, talents.not_maneuverability), hud.powerUpGroup, nil, -1)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(433874, talents.maneuverability), hud.powerUpGroup, nil, -1)
end

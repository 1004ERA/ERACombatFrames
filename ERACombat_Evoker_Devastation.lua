---@class ERACombatTimers_EvokerDevastation : ERACombatTimers_Evoker
---@field evoker_goodSpells number

---comment
---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param essence ERACombat_EvokerEssence
---@param combatHealth ERACombatHealth
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, essence, combatHealth, talents)
    local talent_big_empower = ERALIBTalent:Create(115586)
    local talent_surge = ERALIBTalent:Create(115581)
    local talent_not_surge = ERALIBTalent:CreateNotTalent(115581)
    local talent_firestorm = ERALIBTalent:Create(115585)
    local talent_not_firestorm = ERALIBTalent:CreateNotTalent(115585)
    local talent_instastorm = ERALIBTalent:Create(115584)
    local talent_shatter = ERALIBTalent:Create(115627)
    local talent_iridescence = ERALIBTalent:Create(115633)
    local talent_dragonrage = ERALIBTalent:Create(115643)

    local firstColumnX = 0.9

    local dps = ERACombat_EvokerDPS(cFrame, talents, talent_big_empower, 1)
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
    local utility = ERACombat_EvokerSetup(cFrame, dps.timers, tParams, talents, 1)

    local shatter = dps.timers:AddTrackedCooldown(370452, talent_shatter)
    local shatterIcon = dps.timers:AddCooldownIcon(shatter, nil, 0, 0, true, true)

    local surge_alternative = {
        id = 382411,
        talent = talent_big_empower,
    }
    local surge = dps.timers:AddTrackedCooldown(359073, talent_surge, surge_alternative)
    local surgeIcon = dps.timers:AddCooldownIcon(surge, nil, -1, 0, true, true)

    local firebreathIcons = {}
    table.insert(firebreathIcons, dps.timers:AddCooldownIcon(dps.firebreathCooldown, nil, -1, 0, true, true, talent_not_surge))
    table.insert(firebreathIcons, dps.timers:AddCooldownIcon(dps.firebreathCooldown, nil, -2, 0, true, true, talent_surge))

    local firestorm = dps.timers:AddTrackedCooldown(368847, talent_firestorm)
    local firestormIcons = {}
    table.insert(firestormIcons, dps.timers:AddCooldownIcon(firestorm, nil, -2, 0, true, true, talent_not_surge))
    table.insert(firestormIcons, dps.timers:AddCooldownIcon(firestorm, nil, -3, 0, true, true, talent_surge))
    local instaStorm = dps.timers:AddTrackedBuff(370818, talent_instastorm)
    dps.timers:AddAuraBar(instaStorm, nil, 0.6, 0.0, 0.0)

    local burstTimer = dps.timers:AddTrackedBuff(359618)

    local instaflameTimer = dps.timers:AddTrackedBuff(375802, ERALIBTalent:Create(115624))
    local instaflameBar = dps.timers:AddAuraBar(instaflameTimer, nil, 0, 1, 0)

    local chargedBlastTimer = dps.timers:AddTrackedBuff(370454, ERALIBTalent:Create(115628))
    dps.timers:AddStacksProgressIcon(chargedBlastTimer, nil, -1.5, -0.9, 20, ERALIBTalent:CreateAnd(talent_firestorm, talent_not_surge))
    dps.timers:AddStacksProgressIcon(chargedBlastTimer, nil, -2.5, -0.9, 20, ERALIBTalent:CreateAnd(talent_firestorm, talent_surge))
    dps.timers:AddStacksProgressIcon(chargedBlastTimer, nil, -2, 0, 20, ERALIBTalent:CreateAnd(talent_not_firestorm, talent_not_surge))
    dps.timers:AddStacksProgressIcon(chargedBlastTimer, nil, -3, 0, 20, ERALIBTalent:CreateAnd(talent_not_firestorm, talent_surge))

    local iriRedTimer = dps.timers:AddTrackedBuff(386353, talent_iridescence)
    dps.timers:AddAuraBar(iriRedTimer, nil, 1, 0, 0)
    local iriBlueTimer = dps.timers:AddTrackedBuff(386399, talent_iridescence)
    dps.timers:AddAuraBar(iriBlueTimer, nil, 0, 0, 1)

    local shatterTimer = dps.timers:AddTrackedDebuff(370452, talent_shatter)
    dps.timers:AddAuraBar(shatterTimer, nil, 1, 0.3, 1)

    local rageTimer = dps.timers:AddTrackedBuff(375087, talent_dragonrage)
    dps.timers:AddAuraBar(rageTimer, nil, 1, 0.5, 0.1, talent_dragonrage)

    ------------
    --- prio ---
    ------------

    --[[

    1 - shatter (good spells available)
    2 - unravel
    3 - flame tempo
    4 - strike tempo
    5 - shatter (good spells soon available)
    6 - breath
    7 - surge
    8 - storm
    9 - shatter

    ]]

    timers.evoker_additionalPreupdate = function(t)
        local goodSpells = 1024
        if (talent_surge:PlayerHasTalent()) then
            goodSpells = math.min(goodSpells, surge.remDuration)
        end
        if (talents.unravel:PlayerHasTalent() and dps.timers.evoker_unravel.absorbValue > 0) then
            goodSpells = math.min(goodSpells, dps.timers.evoker_unravel.remDuration)
        end
        timers.evoker_goodSpells = goodSpells
    end

    function shatterIcon:ComputeAvailablePriorityOverride()
        local goodSpells = timers.evoker_goodSpells
        if (goodSpells <= self.group.occupied) then
            return 1
        else
            if (goodSpells <= 3) then
                return 5
            else
                return 9
            end
        end
    end

    function dps.timers.evoker_unravelIcon:ComputeAvailablePriorityOverride()
        local cd = self.cd
        ---@cast cd ERACombat_EvokerUnravelCooldown
        if cd.useable then
            return 2
        else
            return 0
        end
    end

    local livingPrio = dps.timers:AddPriority(4622464)
    function livingPrio:ComputePriority(t)
        if (enemies:GetCount() < 3 and 0 < timers.evoker_goodSpells and timers.evoker_goodSpells <= 3) then
            return 3
        else
            return 0
        end
    end

    local strikePrio = dps.timers:AddPriority(4622447)
    function strikePrio:ComputePriority(t)
        if (enemies:GetCount() >= 3 and 0 < timers.evoker_goodSpells and timers.evoker_goodSpells <= 3) then
            return 3
        else
            return 0
        end
    end

    for _, icon in ipairs(firebreathIcons) do
        function icon:ComputeAvailablePriorityOverride()
            return 6
        end
    end

    function surgeIcon:ComputeAvailablePriorityOverride()
        return 7
    end

    for _, icon in ipairs(firestormIcons) do
        function icon:ComputeAvailablePriorityOverride()
            return 8
        end
    end

    ---------------
    --- utility ---
    ---------------

    utility:AddCooldown(-2.5, 0.9, 375087, nil, true, talent_dragonrage)
    utility:AddCooldown(-3.5, 0.9, 357210, nil, true) -- deep breath
    utility:AddCooldown(-4, 0, 355913, nil, true)     -- emerald blossom
    -- out of combat
    utility:AddCooldown(-2, 3, 382266, nil, false, talent_big_empower)
    utility:AddCooldown(-2, 3, 357208, nil, false, ERALIBTalent:CreateNot(talent_big_empower))
    utility:AddCooldown(-3, 3, 368847, nil, false, talent_firestorm)
    utility:AddCooldown(-2, 4, 359073, nil, false, talent_surge)
    utility:AddCooldown(-3, 4, 370452, nil, false, talent_shatter)
end
---comment
---@param cFrame ERACombatFrame
---@param runes ERACombatRunes
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightUnholySetup_OLD(cFrame, runes, talents)
    local talent_transfo = ERALIBTalent:Create(96324)
    local talent_apo = ERALIBTalent:Create(96322)
    local talent_contagion = ERALIBTalent:Create(96293)
    local talent_defile = ERALIBTalent:Create(96295)
    local talent_dnd = ERALIBTalent:CreateNotTalent(96295)
    local talent_gargoyle = ERALIBTalent:Create(96311)
    local talent_frenzy = ERALIBTalent:Create(96285)
    local talent_abomination = ERALIBTalent:Create(96287)
    local talent_army = ERALIBTalent:CreateAnd(ERALIBTalent:Create(96333), ERALIBTalent:CreateNot(talent_abomination))
    local talent_clawing = ERALIBTalent:Create(96320)
    local talent_scourge = ERALIBTalent:CreateNotTalent(96320)
    local talent_eternal_agony = ERALIBTalent:Create(96318)
    local talent_scythe = ERALIBTalent:Create(96330)
    local talent_ebon_fever = ERALIBTalent:Create(96294)

    ERAOutOfCombatStatusBars:Create(cFrame, ERADK_BarsX, ERADK_BarsTopY, ERADK_BarsWidth, 4 * ERADK_BarsHeight / 9, 3 * ERADK_BarsHeight / 9, 6, false, 0.2, 0.7, 1.0, 2 * ERADK_BarsHeight / 9, 3)

    local dk = ERACombat_CommonDK(cFrame, runes, 1, talents, 4 * ERADK_BarsHeight / 9, 2 * ERADK_BarsHeight / 9, 3 * ERADK_BarsHeight / 9, 3)
    ERACombat_DPSDK(dk.combatHealth, dk.combatPower, dk.damageTaken, dk.succor, dk.blooddraw, talents)

    local doom = dk.timers:AddTrackedBuff(81340)

    local plague = dk.timers:AddTrackedDebuff(191587)
    local missingPlague = dk.timers:AddMissingAura(plague, nil, ERADK_TimersSpecialX0, ERADK_TimersSpecialY0 - 1.5, false)
    missingPlague.icon:SetVertexColor(1.0, 0.2, 0.2, 1.0)
    local plagueLongBar = dk.timers:AddAuraBar(plague, nil, 0.3, 0.4, 0.1)
    function plagueLongBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (plague.remDuration <= 8 or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent())) then
            return plague.remDuration
        else
            return 0
        end
    end
    local plagueShortBar = dk.timers:AddAuraBar(plague, nil, 0.7, 1.0, 0.0)
    function plagueShortBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (plague.remDuration <= 8 or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent())) then
            return 0
        else
            return plague.remDuration
        end
    end

    local coilConsumer = dk.combatPower:AddConsumer(30, nil, nil)
    coilConsumer.requireContinuousUpdate = true
    function coilConsumer:ComputeValueOverride(t)
        if doom.remDuration > dk.timers.occupied + 0.1 then
            return 20
        else
            return 30
        end
    end
    dk.combatPower:AddThreashold(20, nil, nil)

    local festering = dk.timers:AddTrackedDebuff(194310)
    dk.timers:AddAuraIcon(festering, 0, 0)

    local transfoCooldown = dk.timers:AddTrackedCooldown(63560, talent_transfo)
    local transfoIcon = dk.timers:AddCooldownIcon(transfoCooldown, nil, -1, 0, true, true)
    local transfoBuff = dk.timers:AddTrackedBuffOnPet(63560, talent_transfo)
    dk.timers:AddAuraBar(transfoBuff, nil, 0.4, 0.6, 0.4, talent_eternal_agony)

    local dnd = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 43265, talent_dnd)
    local dndIcon = dk.timers:AddCooldownIcon(dnd, nil, -2, 0, true, true)
    local defile = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 152280, talent_defile)
    local defileIcon = dk.timers:AddCooldownIcon(defile, nil, -2, 0, true, true)

    local apo = dk.timers:AddTrackedCooldown(275699, talent_apo)
    local apoIcon = dk.timers:AddCooldownIcon(apo, nil, -0.5, -0.9, true, true)

    local contagion = dk.timers:AddTrackedCooldown(390279, talent_contagion)
    local contagionIcon = dk.timers:AddCooldownIcon(contagion, nil, -1.5, -0.9, true, true)

    local abo = dk.timers:AddTrackedCooldown(455395, talent_abomination)
    local aboIcon = dk.timers:AddCooldownIcon(abo, nil, -1, -1.8, true, true)

    local frenzyBuff = dk.timers:AddTrackedBuff(207289, talent_frenzy)
    dk.timers:AddAuraBar(frenzyBuff, nil, 1.0, 0.8, 0.8)

    local scythe = dk.timers:AddTrackedBuff(459238, talent_scythe)
    dk.timers:AddAuraBar(scythe, nil, 0.0, 0.7, 0.6)

    --------------
    -- priority --
    --------------

    --[[

    1 - soul reaper
    2 - outbreak now
    3 - dnd / defile
    4 - contagion many ememies
    5 - outbreak soon
    6 - transfo
    7 - apo
    8 - abo
    9 - contagion few ememies
    10 - festering or scourge / clawing

    ]]

    local outbreakPrio = dk.timers:AddPriority(348565)
    function outbreakPrio:ComputePriority(t)
        if plague.remDuration <= dk.timers.occupied + 0.1 then
            return 2
        elseif plague.remDuration <= 8 or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent()) then
            return 5
        else
            return 0
        end
    end

    function dndIcon:ComputeAvailablePriorityOverride()
        return 3
    end
    function defileIcon:ComputeAvailablePriorityOverride()
        return 3
    end

    function contagionIcon:ComputeAvailablePriorityOverride()
        local count = dk.enemies:GetCount()
        if count > 3 then
            return 4
        elseif count > 1 then
            return 9
        else
            return 0
        end
    end

    function transfoIcon:ComputeAvailablePriorityOverride()
        return 6
    end

    function apoIcon:ComputeAvailablePriorityOverride()
        return 7
    end

    function aboIcon:ComputeAvailablePriorityOverride()
        return 8
    end

    local scourgePrio = dk.timers:AddPriority(237530)
    function scourgePrio:ComputePriority(t)
        if talent_scourge:PlayerHasTalent() and festering.stacks > 2 then
            return 10
        else
            return 0
        end
    end
    local clawPrio = dk.timers:AddPriority(615099)
    function clawPrio:ComputePriority(t)
        if talent_clawing:PlayerHasTalent() and festering.stacks > 2 then
            return 10
        else
            return 0
        end
    end

    local festeringPrio = dk.timers:AddPriority(879926)
    function festeringPrio:ComputePriority(t)
        if festering.stacks <= 2 then
            return 10
        else
            return 0
        end
    end

    -------------
    -- utility --
    -------------

    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY, 49206, nil, true, talent_gargoyle)
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY - 1, 207289, nil, true, talent_frenzy)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 2, ERADK_UtilityBaseY, 47481, nil, true, talents.raisedead).showOnlyIfPetSpellKnown = true
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY, 46585, nil, true, talents.raisedead)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY - 1, 327574, nil, true, talents.sacrifice)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX - 1.8, ERADK_UtilityBaseY - 0.5, 42560, nil, true, runes, 1, talent_army)
    -- out of combat
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX - 1.8, ERADK_UtilityBaseY - 0.5, 455395, nil, false, runes, 1, talent_abomination)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX, ERADK_UtilityBaseY + 2, 152280, nil, false, runes, 1, talent_defile)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX, ERADK_UtilityBaseY + 2, 43265, nil, false, runes, 1, talent_dnd)
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY + 1, 63560, nil, false, talent_transfo)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 1, 275699, nil, false, talent_apo)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 2, 390279, nil, false, talent_contagion)
end

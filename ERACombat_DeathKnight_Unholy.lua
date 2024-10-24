---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightUnholySetup(cFrame, enemies, talents)
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
    local talent_rotten_touch = ERALIBTalent:Create(96310)

    local hud = ERACombatFrames_DKCommonSetup(cFrame, enemies, talents, 3)

    ERACombatFrames_DK_DPS(hud, talents)

    local plague = hud:AddTrackedDebuffOnTarget(191587)
    local doom = hud:AddTrackedBuff(81340)

    hud.runicPower.bar:AddMarkingFromMax(20)
    local coilConsumer = hud.runicPower.bar:AddMarkingFrom0(30)
    function coilConsumer:ComputeValueOverride(t)
        if doom.remDuration > hud.occupied + 0.1 then
            return 20
        else
            return 30
        end
    end

    --- bars ---

    local plagueLongBar = hud:AddAuraBar(plague, nil, 0.3, 0.4, 0.1)
    function plagueLongBar:ComputeDurationOverride(t)
        if (plague.remDuration <= 8 and not talent_ebon_fever:PlayerHasTalent()) or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent()) then
            return 0
        else
            return plague.remDuration
        end
    end
    local plagueShortBar = hud:AddAuraBar(plague, nil, 0.7, 1.0, 0.0)
    function plagueShortBar:ComputeDurationOverride(t)
        if (plague.remDuration <= 8 and not talent_ebon_fever:PlayerHasTalent()) or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent()) then
            return plague.remDuration
        else
            return 0
        end
    end

    local transfoDuration = hud:AddTrackedBuffOnPet(63560, talent_transfo)
    hud:AddAuraBar(transfoDuration, nil, 0.8, 0.0, 0.2, ERALIBTalent:CreateOr(talent_eternal_agony, talents.h_sanlayn_gift))

    hud:AddAuraBar(hud:AddTrackedBuff(207289, talent_frenzy), nil, 1.0, 0.8, 0.8)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(390276, talent_rotten_touch), nil, 0.7, 0.3, 0.5)

    local scytheBuff = hud:AddTrackedBuff(458123, talent_scythe)
    local scytheBar = hud:AddAuraBar(scytheBuff, nil, 0.0, 0.7, 0.6)

    --- SAO ---

    hud:AddAuraOverlay(scytheBuff, 1, 1518303, false, "TOP", false, false, false, false)

    hud:AddAuraOverlay(doom, 1, 450932, false, "LEFT", false, false, false, false)
    hud:AddAuraOverlay(doom, 2, 450932, false, "RIGHT", true, false, false, false)

    local vampStrike = hud:AddOverlayBasedOnSpellIcon(55090, 5927645, "CovenantChoice-Celebration-Venthyr-DetailLine", true, "BOTTOM", false, false, false, false, talents.h_sanlayn)
    function vampStrike:ConfirmIsActiveOverride(t, combat)
        return combat and transfoDuration.remDuration <= 0
    end

    ERACombatFrames_DK_MissingDisease(hud, plague)

    --- rotation ---

    local festering = hud:AddTrackedDebuffOnTarget(194310)
    local festeringIcon = hud:AddRotationStacks(festering, 6, 5)
    function festeringIcon:ShowCombatMissing(t)
        return true
    end

    local transfoIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(63560, talent_transfo))

    local dndIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 43265, 1, talent_dnd))
    local defileIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 152280, 1, talent_defile), 136144)

    local apoIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(275699, talent_apo))

    local contagionIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(390279, talent_contagion))

    ERACombatFrames_DKSoulReaper(hud, 1, talents)

    local aboIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(455395, talent_abomination))

    hud:AddRotationStacks(hud:AddTrackedBuff(459238, talent_scythe), 20, 18).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --[[

    PRIO

    1 - soul reaper
    2 - outbreak now
    3 - dnd (many enemies) / defile
    4 - contagion many ememies
    5 - outbreak soon
    6 - transfo
    7 - apo
    8 - abo
    9 - contagion few ememies
    10 - festering or scourge / clawing

    ]]

    local outbreakPrio = hud:AddPriority(348565)
    function outbreakPrio:ComputeAvailablePriorityOverride(t)
        if plague.remDuration <= hud.occupied + 0.1 then
            return 2
        elseif (plague.remDuration <= 8 and not talent_ebon_fever:PlayerHasTalent()) or (plague.remDuration <= 4 and talent_ebon_fever:PlayerHasTalent()) then
            return 5
        else
            return 0
        end
    end

    function dndIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() > 1 then
            return 3
        else
            return 0
        end
    end
    function defileIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function contagionIcon.onTimer:ComputeAvailablePriorityOverride(t)
        local count = hud.enemies:GetCount()
        if count > 3 then
            return 4
        elseif count > 1 then
            return 9
        else
            return 0
        end
    end

    function transfoIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function apoIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    function aboIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    local scourgePrio = hud:AddPriority(237530, talent_scourge)
    function scourgePrio:ComputeAvailablePriorityOverride(t)
        if festering.stacks > 2 then
            return 10
        else
            return 0
        end
    end
    local clawPrio = hud:AddPriority(615099, talent_clawing)
    function clawPrio:ComputeAvailablePriorityOverride(t)
        if festering.stacks > 2 then
            return 10
        else
            return 0
        end
    end

    local festeringPrio = hud:AddPriority(879926)
    function festeringPrio:ComputeAvailablePriorityOverride(t)
        if festering.stacks <= 2 then
            return 10
        else
            return 0
        end
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(207289, talent_frenzy), hud.powerUpGroup, nil, -4, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(49206, talent_gargoyle), hud.powerUpGroup, nil, -3, nil, true)
    hud:AddUtilityCooldown(ERACooldownIgnoringRunes:Create(hud, 42650, 1, talent_army), hud.powerUpGroup, nil, -2, nil, true)

    local gnaw = hud:AddTrackedCooldown(49206, talents.raisedead)
    gnaw.isPetSpell = true
    hud:AddUtilityCooldown(gnaw, hud.controlGroup)
end

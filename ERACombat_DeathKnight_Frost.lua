---comment
---@param cFrame ERACombatFrame
---@param runes ERACombatRunes
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightFrostSetup(cFrame, runes, talents)
    local talent_pof = ERALIBTalent:Create(125874)
    local talent_scythe = ERALIBTalent:Create(96225)
    local talent_horn = ERALIBTalent:Create(96218)
    local talent_remorseless_important = ERALIBTalent:Create(96229)
    local talent_chillstreak = ERALIBTalent:Create(96228)
    local talent_frostwyrm = ERALIBTalent:Create(125876)
    local talent_sindragosa = ERALIBTalent:Create(96222)
    local talent_empower = ERALIBTalent:Create(96240)
    local talent_coldheart = ERALIBTalent:Create(96163)
    local talent_enduring_pof = ERALIBTalent:Create(96230)
    local talent_bonegrinder = ERALIBTalent:Create(96253)

    local dk = ERACombat_CommonDK(cFrame, runes, 1, talents, 2 * ERADK_BarsHeight / 3, 0, ERADK_BarsHeight / 3, 2)
    ERACombat_DPSDK(dk.combatHealth, dk.combatPower, dk.damageTaken, dk.succor, dk.blooddraw, talents)

    dk.combatPower:AddConsumer(30, nil, nil)
    dk.combatPower:AddThreashold(20, nil, nil)

    local fever = dk.timers:AddTrackedDebuff(55095)
    local missingFever = dk.timers:AddMissingAura(fever, nil, ERADK_TimersSpecialX0, ERADK_TimersSpecialY0 - 1.5, false)
    missingFever.icon:SetVertexColor(1.0, 0.2, 0.2, 1.0)
    local feverShortBar = dk.timers:AddAuraBar(fever, nil, 1.0, 0.0, 1.0)
    function feverShortBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (fever.remDuration <= 6) then
            return 0
        else
            return fever.remDuration
        end
    end

    local dnd = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 43265)
    local dndIcon = dk.timers:AddCooldownIcon(dnd, nil, 0, 0, true, true)

    local remorseless = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 196770)
    local remorselessIcon = dk.timers:AddCooldownIcon(remorseless, nil, -1, 0, true, true)
    local remorselessBuff = dk.timers:AddTrackedBuff(196770)
    dk.timers:AddAuraBar(remorselessBuff, nil, 0.5, 0.8, 1.0, talent_remorseless_important)

    local scythe = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 2, 207230, talent_scythe)
    local scytheIcon = dk.timers:AddCooldownIcon(scythe, nil, -2, 0, true, true)

    local chillstreak = ERACombatCooldownIgnoringRunes:Create(dk.timers, runes, 1, 305392, talent_chillstreak)
    local chillstreakIcon = dk.timers:AddCooldownIcon(chillstreak, nil, -1, -1.8, true, true)

    local pof = dk.timers:AddTrackedCooldown(51271, talent_pof)
    local pofIcon = dk.timers:AddCooldownIcon(pof, nil, -0.5, -0.9, true, true)
    local pofbuff = dk.timers:AddTrackedBuff(51271, talent_pof)
    dk.timers:AddAuraBar(pofbuff, nil, 0.8, 0.8, 1.0)

    local horn = dk.timers:AddTrackedCooldown(57330, talent_horn)
    local hornIcon = dk.timers:AddCooldownIcon(horn, nil, -1.5, -0.9, true, true)

    local coldheart = dk.timers:AddTrackedBuff(281209, talent_coldheart)
    dk.timers:AddStacksProgressIcon(coldheart, nil, 1.9, 0.5, 20)

    dk.timers:AddAuraBar(dk.timers:AddTrackedBuff(377192, talent_enduring_pof), 136213, 0.6, 0.6, 0.8)
    dk.timers:AddAuraBar(dk.timers:AddTrackedBuff(377103, talent_bonegrinder), nil, 0.0, 0.0, 1.0)

    --------------
    -- priority --
    --------------

    --[[

    1 - soul reaper
    2 - pof
    3 - remorseless
    4 - scythe
    5 - streak
    6 - chains of ice all stacks
    7 - dnd
    8 - chains of ice most stacks
    9 - horn

    ]]

    function pofIcon:ComputeAvailablePriorityOverride()
        return 2
    end
    function remorselessIcon:ComputeAvailablePriorityOverride()
        return 3
    end
    function scytheIcon:ComputeAvailablePriorityOverride()
        return 4
    end
    function chillstreakIcon:ComputeAvailablePriorityOverride()
        return 5
    end
    function dndIcon:ComputeAvailablePriorityOverride()
        return 7
    end
    function hornIcon:ComputeAvailablePriorityOverride()
        if (runes.availableRunes <= 1 and dk.combatPower.maxPower - dk.combatPower.currentPower > 30) then
            return 9
        else
            return 0
        end
    end

    local coldheartPrio = dk.timers:AddPriority(135834)
    function coldheartPrio:ComputePriority(t)
        if coldheart.stacks >= 19 then
            return 6
        elseif coldheart.stacks >= 16 then
            return 8
        else
            return 0
        end
    end

    -------------
    -- utility --
    -------------

    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY, 279302, nil, true, talent_frostwyrm)
    dk.utility:AddCooldown(ERADK_UtilityBaseX, ERADK_UtilityBaseY - 1, 47568, nil, true, talent_empower)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY, 152279, nil, true, talent_sindragosa)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY - 1, 46585, nil, true, talents.raisedead)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1.9, ERADK_UtilityBaseY - 0.5, 327574, nil, true, talents.sacrifice)
    -- out of combat
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX, ERADK_UtilityBaseY + 1, 305392, nil, false, runes, 1, talent_chillstreak)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 1, 51271, nil, false, talent_pof)
    dk.utility:AddCooldown(ERADK_UtilityBaseX - 2, ERADK_UtilityBaseY + 1, 57330, nil, false, talent_horn)
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX, ERADK_UtilityBaseY + 2, 43265, nil, false, runes, 1)      -- dnd
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX - 1, ERADK_UtilityBaseY + 2, 196770, nil, false, runes, 1) -- remorseless
    ERACombatUtilityCooldownIgnoringRunes:Create(dk.utility, ERADK_UtilityBaseX - 2, ERADK_UtilityBaseY + 2, 207230, nil, false, runes, 2, talent_scythe)
end

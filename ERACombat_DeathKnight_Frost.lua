---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightFrostSetup(cFrame, enemies, talents)
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

    local hud = ERACombatFrames_DKCommonSetup(cFrame, enemies, talents, 2)

    hud.power.bar:AddMarkingFrom0(30)
    hud.power.bar:AddMarkingFromMax(20)

    ERACombatFrames_DK_DPS(hud, talents)

    local fever = hud:AddTrackedDebuffOnTarget(55095)

    --- bars ---

    local feverShortBar = hud:AddAuraBar(fever, nil, 1.0, 0.0, 1.0)
    function feverShortBar:ComputeDurationOverride(t)
        if (fever.remDuration > 6) then
            return 0
        else
            return fever.remDuration
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(51271, talent_pof), nil, 0.8, 0.8, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(377192, talent_enduring_pof), 136213, 0.6, 0.6, 0.8)

    hud:AddAuraBar(hud:AddTrackedBuff(377103, talent_bonegrinder), nil, 0.0, 0.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(196770, talent_remorseless_important), nil, 0.5, 0.8, 1.0)

    --- SAO ---

    local killingMachine = hud:AddTrackedBuff(51124)
    hud:AddAuraOverlay(killingMachine, 1, 458740, false, "LEFT", false, false, false, false)
    hud:AddAuraOverlay(killingMachine, 2, 458740, false, "RIGHT", true, false, false, false)

    local rime = hud:AddTrackedBuff(59052)
    hud:AddAuraOverlay(rime, 1, 450930, false, "TOP", false, false, false, false)

    ERACombatFrames_DK_MissingDisease(hud, fever)

    --- rotation ---

    local remorselessIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 196770, 1))

    local dndIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 43265, 1))

    local scytheIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 207230, 2, talent_scythe))

    local streakIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 305392, 2, talent_chillstreak))

    ERACombatFrames_DKSoulReaper(hud, 1)

    ERACombatFrames_DK_ReaperMark(hud, talents, 3)

    local pofIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(51271, talent_pof))

    local hornIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(57330, talent_horn))

    local coldheart = hud:AddTrackedBuff(281209, talent_coldheart)
    hud:AddRotationStacks(coldheart, 20, 18).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --[[

    PRIO

    1 - soul reaper
    2 - pof
    3 - reapermark
    4 - remorseless
    5 - scythe
    6 - streak
    7 - chains of ice all stacks
    8 - dnd
    9 - chains of ice most stacks
    10 - horn

    ]]

    function pofIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end
    function remorselessIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end
    function scytheIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end
    function streakIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end
    function dndIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end
    function hornIcon.onTimer:ComputeAvailablePriorityOverride(t)
        local hud = self.hud
        ---@cast hud ERADKHUD
        if (hud.runes.availableRunes <= 1 and hud.power.maxPower - hud.power.currentPower > 30) then
            return 10
        else
            return 0
        end
    end

    local coldheartPrio = hud:AddPriority(135834)
    function coldheartPrio:ComputeAvailablePriorityOverride(t)
        if coldheart.stacks >= 19 then
            return 7
        elseif coldheart.stacks >= 16 then
            return 9
        else
            return 0
        end
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(279302, talent_frostwyrm), hud.powerUpGroup, -3)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(47568, talent_empower), hud.powerUpGroup, -2)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(152279, talent_sindragosa), hud.powerUpGroup, -1)
end

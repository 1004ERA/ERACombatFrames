---@param cFrame ERACombatFrame
---@param talents WarlockCommonTalents
function ERACombatFrames_WarlockAfflictionSetup(cFrame, talents)
    local talent_sacrifice = ERALIBTalent:Create(124691)
    local talent_not_sacrifice = ERALIBTalent:CreateNotTalent(124691)
    local talent_finite_corruption = ERALIBTalent:CreateAnd(talents.not_wither, ERALIBTalent:CreateNotTalent(91572))
    local talent_finite_wither = ERALIBTalent:CreateAnd(talents.wither, ERALIBTalent:CreateNotTalent(91572))
    local talent_infinite_any = ERALIBTalent:Create(91572)
    local talent_infinite_corruption = ERALIBTalent:CreateAnd(talents.not_wither, talent_infinite_any)
    local talent_infinite_wither = ERALIBTalent:CreateAnd(talents.wither, talent_infinite_any)
    local talent_nightfall = ERALIBTalent:Create(91568)
    local talent_crescendo = ERALIBTalent:CreateOr(ERALIBTalent:Create(91551), ERALIBTalent:Create(117426))
    local talent_haunt = ERALIBTalent:Create(91552)
    local talent_oblivion = ERALIBTalent:Create(91503)
    local talent_taint = ERALIBTalent:Create(91556)
    local talent_singularity = ERALIBTalent:Create(126061)
    local talent_soulrot = ERALIBTalent:Create(91578)
    local talent_darkglare = ERALIBTalent:Create(91554)
    local talent_omen = ERALIBTalent:Create(91579)

    local hud, succulent = ERACombatFrames_WarlockWholeShards(cFrame, 1, talent_not_sacrifice, talent_sacrifice, talents)

    hud:AddChannelInfo(198590, 1)

    local dots = ERAHUDDOT:Create(hud)

    local unstable = dots:AddDOT(316099, nil, 0.0, 0.7, 1.0, nil, 1.5, 21)
    unstable.singleInstance = true
    local agony = dots:AddDOT(980, nil, 1.0, 0.7, 0.0, nil, 0, 18)
    local corruption = dots:AddDOT(146739, nil, 1.0, 0.3, 0.3, talent_finite_corruption, 0, 14)
    local wither = dots:AddDOT(445474, nil, 1.0, 0.3, 1.0, talent_finite_wither, 0, 18)
    function wither:ComputeRefreshDurationOverride(t)
        if talents.short_wither:PlayerHasTalent() then
            return 0.3 * 15.3
        else
            return 0.3 * 18
        end
    end

    --- SAO ---

    local timersForMissingCorruption = hud:AddOrTimer(false, hud:AddTrackedDebuffOnTarget(146739, talent_infinite_corruption), hud:AddTrackedDebuffOnTarget(445474, talent_infinite_wither))
    hud:AddMissingTimerOverlay(timersForMissingCorruption, true, "Relic-Shadow-TraitBG", true, "MIDDLE", false, false, false, false, talent_infinite_any)

    local nightfall = hud:AddTrackedBuff(264571, talent_nightfall)
    hud:AddAuraOverlay(nightfall, 1, 449492, false, "LEFT", false, false, false, false, nil)
    hud:AddAuraOverlay(nightfall, 2, 449492, false, "RIGHT", true, false, false, false, nil)

    function hud.shards:PreUpdateDisplayOverride(t, combat)
        if succulent.remDuration > 0 then
            self:SetBorderColor(1.0, 1.0, 1.0)
        else
            self:SetBorderColor(1.0, 0.0, 0.0)
        end
    end

    --- bars ---

    local instaRapture = hud:AddTrackedBuff(387079, talent_crescendo)
    hud:AddAuraBar(instaRapture, 236296, 1.0, 0.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(386997, talent_soulrot), nil, 0.0, 0.0, 1.0)

    --- rotation ---

    local haunt = hud:AddRotationCooldown(hud:AddTrackedCooldown(48181, talent_haunt))

    local oblivion = hud:AddRotationCooldown(hud:AddTrackedCooldown(417537, talent_oblivion))

    local taint = hud:AddRotationCooldown(hud:AddTrackedCooldown(278350, talent_taint))
    local singularity = hud:AddRotationCooldown(hud:AddTrackedCooldown(205179, talent_singularity))

    ERACombatFrames_WarlockMalevolence(hud, talents, 5)

    local soulrot = hud:AddRotationCooldown(hud:AddTrackedCooldown(386997, talent_soulrot))

    hud:AddRotationStacks(hud:AddTrackedBuff(458043, talent_omen), 3, 4)

    --[[

    prio
    - 1 haunt
    - 2 oblivion
    - 3 taint
    - 4 singularity
    - 5 malevolence
    - 6 soulrot

    ]]

    function haunt.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    function oblivion.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function taint.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end
    function singularity.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function soulrot.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(205180, talent_darkglare), hud.powerUpGroup)
end

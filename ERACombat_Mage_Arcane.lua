---@param cFrame ERACombatFrame
---@param talents ERACombat_MageCommonTalents
function ERACombatFrames_MageArcaneSetup(cFrame, talents)
    local talent_aethervision = ERALIBTalent:Create(126518)
    local talent_surge = ERALIBTalent:Create(126519)
    local talent_tempo = ERALIBTalent:Create(126506)
    local talent_familiar = ERALIBTalent:Create(126509)
    local talent_leydrinker = ERALIBTalent:Create(126544)
    local talent_pom = ERALIBTalent:Create(126530)
    local talent_impetus = ERALIBTalent:Create(126550)
    local talent_touch = ERALIBTalent:Create(126538)
    local talent_evocation = ERALIBTalent:Create(126529)
    local talent_debilitation = ERALIBTalent:Create(126533)
    local talent_attunement = ERALIBTalent:Create(126546)
    local talent_enlightened = ERALIBTalent:Create(126540)
    local talent_harmony = ERALIBTalent:Create(126517)
    local talent_spark = ERALIBTalent:Create(126505)

    local hud = ERACombatFrames_MageCommonSetup(cFrame, talents, 1, 235450)
    hud.mage_mana = ERAHUDPowerBarModule:Create(hud, 0, 16, 0.0, 0.0, 1.0)
    hud.mage_mana.hideFullOutOfCombat = true

    local aPoints = ERAHUDModulePointsUnitPower:Create(hud, Enum.PowerType.ArcaneCharges, 1.0, 0.0, 1.0, 0.5, 0.0, 1.0)
    local buildingSunfurySphere = hud:AddTrackedBuff(449400, talents.h_sunfury)
    --ERAHUDModulePointsStacks:Create(hud, buildingSunfurySphere, 5, 0.8, 0.5, 0.0, 0.9, 0.4, 0.3, talents.h_sunfury, 16)
    ERACombatFrames_MageSpellsinger(hud, talents)

    local enlightenedMark = hud.mage_mana.bar:AddMarkingFrom0(-1, talent_enlightened)
    function enlightenedMark:ComputeValueOverride(t)
        return 0.7 * self.bar.max
    end

    --- SAO ---

    local clearcast = hud:AddTrackedBuff(263725)
    hud:AddAuraOverlay(clearcast, 1, 1027131, false, "LEFT", false, false, false, false).maxStacks = 1
    hud:AddAuraOverlay(clearcast, 2, 1027132, false, "LEFT", false, false, false, false).maxStacks = 2
    hud:AddAuraOverlay(clearcast, 3, 1027133, false, "LEFT", false, false, false, false)
    --[[
    hud:AddAuraOverlay(clearcast, 1, 449486, false, "LEFT", false, false, false, false)
    hud:AddAuraOverlay(clearcast, 2, 449486, false, "RIGHT", true, false, false, false)
    hud:AddAuraOverlay(clearcast, 3, 449486, false, "TOP", false, false, false, true)
    hud:AddAuraOverlay(attunement, 1, "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)
    ]] --

    local attunement = hud:AddTrackedBuff(453601, talent_attunement)
    hud:AddAuraOverlay(attunement, 1, 449486, false, "RIGHT", true, false, false, false)

    local leydrinker = hud:AddAuraOverlay(hud:AddTrackedBuff(453758, talent_leydrinker), 1, 450918, false, "BOTTOM", false, false, true, false)
    leydrinker:SetVertexColor(1.0, 0.0, 1.0)

    --[[
    local sunsphere_minus2 = hud:AddAuraOverlay(buildingSunfurySphere, 4, 450922, false, "TOP", false, false, false, true)
    sunsphere_minus2.maxStacks = 4
    sunsphere_minus2:SetVertexColor(0.0, 0.0, 1.0)
    hud:AddAuraOverlay(buildingSunfurySphere, 5, 450921, false, "TOP", false, false, false, true):SetVertexColor(0.0, 0.0, 1.0)
    ]]
    hud:AddAuraOverlay(hud:AddTrackedBuff(451049, talents.h_sunfury), 1, 450923, false, "TOP", false, false, false, false):SetVertexColor(1.0, 1.0, 0.0) -- burden of power
    hud:AddAuraOverlay(hud:AddTrackedBuff(451073, talents.h_sunfury), 1, 449490, false, "TOP", true, false, true, false)                                 -- glorious incandescence

    --- bars ---

    local clearBar = hud:AddAuraBar(clearcast, nil, 0.0, 1.0, 0.5)
    function clearBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration - 1 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    --hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(453599, talent_debilitation), nil, 0.2, 0.0, 0.6)
    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(210824, talent_touch), nil, 1.0, 0.0, 0.0)
    hud:AddAuraBar(hud:AddTrackedBuff(365362, talent_surge), nil, 1.0, 0.0, 1.0)
    hud:AddAuraBar(hud:AddTrackedBuff(383997, talent_tempo), nil, 0.8, 0.9, 0.0)
    hud:AddAuraBar(hud:AddTrackedBuff(467634, talent_aethervision), nil, 0.6, 0.0, 0.3)
    --hud:AddAuraBar(hud:AddTrackedBuff(393939, talent_impetus), nil, 0.4, 0.0, 0.8) -- finalement pas la peine
    hud:AddAuraBar(hud:AddTrackedBuff(383783), nil, 1.0, 0.7, 1.0) -- nether precision

    local fadingAttunement = hud:AddAuraBar(attunement, nil, 0.0, 0.6, 0.4)
    function fadingAttunement:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration - 1 and clearcast.remDuration > self.hud.occupied then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(451038, talents.h_sunfury), nil, 0.0, 1.0, 0.0)

    --- rotation ---

    local touch = hud:AddRotationCooldown(hud:AddTrackedCooldown(321507, talent_touch))
    local surge = hud:AddRotationCooldown(hud:AddTrackedCooldown(365350, talent_surge))

    local pom = hud:AddRotationCooldown(hud:AddTrackedCooldown(205025, talent_pom))
    local pomStacks = hud:AddRotationStacks(hud:AddTrackedBuff(205025, talent_pom), 2, 3, 135735)
    pomStacks.overlapsPrevious = pom
    function pom:ShowHideOverride(t, combat)
        return pomStacks.data.stacks == 0 and (combat or self.data.remDuration > 0)
    end

    ERACombatFrames_MageFae(hud, talents, 7)

    local orb = hud:AddRotationCooldown(hud:AddTrackedCooldown(153626))

    local attunementBuild = hud:AddRotationStacks(hud:AddTrackedBuff(458388, talent_attunement), 3, 3)
    function attunementBuild:ShowCombatMissing()
        return false
    end
    local attunedIcon = hud:AddRotationBuff(attunement)
    attunedIcon.overlapsPrevious = attunementBuild
    function attunedIcon:ShowWhenMissing(t, combat)
        return false
    end

    hud:AddRotationStacks(hud:AddTrackedBuff(384455, talent_harmony), 20, 17)

    ERACombatFrames_MageSpellsingerSupernova(hud, talents, 5)

    --[[

    prio

    - 1 touch
    - 2 surge
    - 3 pom
    - 4 orb
    - 5 supernoval spellslinger
    - 6 evo
    - 7 fae
    - 8 orb charged

    ]]

    function touch.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    function surge.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function pom.onTimer:ComputeAvailablePriorityOverride(t)
        if pomStacks.data.stacks > 0 then
            return 0
        else
            return 3
        end
    end

    function orb.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end
    function orb.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 8
    end

    local evoCooldown = hud:AddTrackedCooldown(12051, talent_evocation)
    local evoPrio = hud:AddPriority(136075, talent_evocation)
    function evoPrio:ComputeDurationOverride(t)
        return evoCooldown.remDuration
    end
    function evoPrio:ComputeAvailablePriorityOverride(t)
        return 6
    end

    --- utility ---

    hud:AddUtilityAuraOutOfCombat(clearcast)

    hud:AddUtilityCooldown(evoCooldown, hud.powerUpGroup)

    hud:AddMissingUtility(hud:AddTrackedBuff(210126, talent_familiar), 10, 5, 1041232)
end

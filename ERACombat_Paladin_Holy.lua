---@alias HolySeasonType "SUMMER" | "AUTUMN" | "WINTER" | "SPRING"

---@class PalaHolyHUD : PaladinHUD

---@param cFrame ERACombatFrame
---@param talents PaladinCommonTalents
function ERACombatFrames_PaladinHolySetup(cFrame, talents)
    local talent_normal_cleanse = ERALIBTalent:CreateNotTalent(102477)
    local talent_better_cleanse = ERALIBTalent:Create(102477)
    local talent_auramastery = ERALIBTalent:Create(102548)
    --local talent_stacking_wog = ERALIBTalent:Create(102558)
    local talent_prism = ERALIBTalent:Create(102561)
    local talent_barrier = ERALIBTalent:Create(102560)
    local talent_divinity = ERALIBTalent:Create(115876)
    --local talent_martyr = ERALIBTalent:Create(102540)
    --local talent_improved_martyr = ERALIBTalent:Create(102539)
    local talent_beacon_virtue = ERALIBTalent:Create(102532)
    local talent_beacon = ERALIBTalent:CreateNot(talent_beacon_virtue)
    local talent_beacon2 = ERALIBTalent:Create(102533)
    local talent_bonus_dawn = ERALIBTalent:Create(102576)
    local talent_how_proc = ERALIBTalent:Create(102565)
    local talent_crusader = ERALIBTalent:Create(102568)
    local talent_avenging_might = ERALIBTalent:Create(102569)
    local talent_avenging_sanctified = ERALIBTalent:Create(102578)
    local talent_any_avenging = ERALIBTalent:CreateAnd(ERALIBTalent:CreateOr(talent_avenging_might, talent_avenging_sanctified, talents.avenging), ERALIBTalent:CreateNot(talent_crusader))
    local talent_avenging_proc = ERALIBTalent:Create(116205)
    --local talent_avenging_buff = ERALIBTalent:CreateOr(talent_any_avenging, talent_avenging_proc)
    local talent_silver = ERALIBTalent:Create(102574)
    local talent_tyr = ERALIBTalent:Create(102573)
    local talent_sotr = ERALIBTalent:Create(102541)
    local talent_seasons = ERALIBTalent:Create(116183)

    local hud = ERACombatFrames_PaladinCommonSetup(cFrame, 1, 223819, ERALIBTalent:Create(115489), true, 386730, ERALIBTalent:Create(115466), talents)
    ---@cast hud PalaHolyHUD

    ERACombatFrames_PaladinConsecration(hud, 5, 10, nil)

    local barrierR = 0.2
    local barrierG = 0.5
    local barrierB = 1.0

    local summerR = 0.9
    local summerG = 0.5
    local summerB = 1.0
    local springR = 0.5
    local springG = 1.0
    local springB = 0.5

    local dispellCooldown = hud:AddTrackedCooldown(4987)

    local hOptions = ERACombatOptions_getOptionsForSpec(nil, 1).healerOptions
    ---@cast hOptions ERACombatGroupFrameOptions
    if not hOptions.disabled then
        local groupFrame = ERAGroupFrame:Create(cFrame, hud, hOptions, 1)
        groupFrame:AddDisplay(groupFrame:AddBuff(53563, false, talent_beacon), 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        groupFrame:AddDisplay(groupFrame:AddBuff(156910, false, talent_beacon2), 0, 2, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        groupFrame:AddDisplay(groupFrame:AddBuff(200025, false, talent_beacon_virtue), 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        groupFrame:AddDisplay(groupFrame:AddBuff(148039, false, talent_barrier), 1, 1, barrierR, barrierG, barrierB, barrierR, barrierG, barrierB, talent_barrier)
        groupFrame:AddDisplay(groupFrame:AddBuff(200654, false, talent_tyr), 2, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0)
        groupFrame:AddDisplay(groupFrame:AddBuff(388007, false, talent_seasons), 3, 1, summerR, summerG, summerB, summerR, summerG, summerB, talent_seasons)
        groupFrame:AddDisplay(groupFrame:AddBuff(388013, false, talent_seasons), 3, 2, springR, springG, springB, springR, springG, springB, talent_seasons)

        groupFrame:AddDisplay(groupFrame:AddDebuff(25771, true), -2, 2, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0)

        groupFrame:AddDispell(dispellCooldown, talent_normal_cleanse, true, false, false, false, false)
        groupFrame:AddDispell(dispellCooldown, talent_better_cleanse, true, true, true, false, false)
    end

    --- SAO ---

    local infusionBuff = hud:AddTrackedBuff(54149)
    hud:AddAuraOverlay(infusionBuff, 1, 459313, false, "RIGHT", true, false, false, false)

    local howProc = hud:AddTrackedBuff(392939, talent_how_proc)
    hud:AddAuraOverlay(howProc, 1, "talents-animations-class-paladin", true, "MIDDLE", false, false, false, false, nil)

    local freeFromSOTR = hud:AddTrackedBuff(414445, talent_sotr)
    hud:AddAuraOverlay(freeFromSOTR, 1, 459314, false, "BOTTOM", false, true, false, false)

    local bonusDawn = hud:AddTrackedBuff(387178, talent_bonus_dawn)
    hud:AddAuraOverlay(bonusDawn, 1, "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)

    --- bars ---

    hud:AddAuraBar(hud:AddTrackedBuff(31821, talent_auramastery), nil, 1.0, 0.2, 0.2)
    hud:AddAuraBar(hud:AddTrackedBuff(148039, talent_barrier), nil, barrierR, barrierG, barrierB)

    hud:AddAuraBar(hud:AddTrackedBuff(388007, talent_seasons), nil, summerR, summerG, summerB)
    hud:AddAuraBar(hud:AddTrackedBuff(388013, talent_seasons), nil, springR, springG, springB)

    hud:AddAuraBar(hud:AddTrackedBuff(414273, talent_divinity), nil, 0.0, 1.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(200656, talent_silver), nil, 0.7, 0.7, 0.6)

    local avengingDuration = hud:AddTrackedBuff(31884, talent_any_avenging)
    hud:AddAuraBar(avengingDuration, nil, 1.0, 0.0, 1.0)
    local crusaderDuration = hud:AddTrackedBuff(216331, talent_crusader)
    hud:AddAuraBar(crusaderDuration, nil, 1.0, 0.0, 1.0)
    local avengingOrCrusade = hud:AddOrTimer(false, avengingDuration, crusaderDuration)

    --- rotation ---

    local crustrike = hud:AddRotationCooldown(hud:AddTrackedCooldown(35395))
    local shock = hud:AddRotationCooldown(hud:AddTrackedCooldown(20473))
    local judgment = hud:AddRotationCooldown(hud:AddTrackedCooldown(20271))
    local how = hud:AddRotationCooldown(hud:AddTrackedCooldown(24275, talents.how))
    how.checkUsable = true

    local prism = hud:AddRotationCooldown(hud:AddTrackedCooldown(114165, talent_prism))
    local barrier = hud:AddRotationCooldown(hud:AddTrackedCooldown(148039, talent_barrier))
    local beaconVirtue = hud:AddRotationCooldown(hud:AddTrackedCooldown(200025, talent_beacon_virtue))
    local toll = hud:AddRotationCooldown(hud.pala_tollCooldown)
    ERACombatFrames_PaladinLightSmith(hud, talents, 7, 17)

    ---@class PalaSeasonsCooldown : ERAHUDRotationCooldownIcon
    ---@field pala_currentSeason HolySeasonType
    local seasons = hud:AddRotationCooldown(hud:AddTrackedCooldown(388007, talent_seasons))
    seasons.pala_currentSeason = "SUMMER"
    function seasons:UpdatedOverride(t, combat)
        local requiredIconID = C_Spell.GetSpellInfo(388007).iconID
        ---@type HolySeasonType
        local seasonType
        if requiredIconID == 3636843 then
            seasonType = "AUTUMN"
        elseif requiredIconID == 3636846 then
            seasonType = "WINTER"
        elseif requiredIconID == 3636844 then
            seasonType = "SPRING"
        else
            -- 3636845
            seasonType = "SUMMER"
        end
        self.pala_currentSeason = seasonType
        self:setIconID(requiredIconID)
    end

    local awakening = hud:AddRotationStacks(hud:AddTrackedBuff(414196, talent_avenging_proc), 15, 14)
    awakening.soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2
    local awakened = hud:AddRotationBuff(hud:AddTrackedBuff(414193, talent_avenging_proc))
    awakened.overlapsPrevious = awakening
    function awakened.ShowWhenMissing()
        return false
    end

    local stackingSOTR = hud:AddRotationStacks(hud:AddTrackedBuff(414444, talent_sotr), 5, 4)
    stackingSOTR.soundOnHighlight = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_NIGHTFAE
    local freeFromSOTR_icon = hud:AddRotationBuff(freeFromSOTR)
    freeFromSOTR_icon.overlapsPrevious = stackingSOTR
    function freeFromSOTR_icon.ShowWhenMissing()
        return false
    end

    --[[

    prio

    1 - how
    2 - shock
    3 - judgment
    4 - crustrike
    5 - consecr refresh
    6 - shock charged
    7 - armaments
    8 - prism
    9 - barrier
    10 - consecr pretty soon
    11 - seasons
    12 - crustrike charged
    13 - toll
    14 - divinity
    15 - judgment charged
    17 - armaments charged
    18 - tyr

    ]]

    function how.onTimer:ComputeDurationOverride(t)
        local dur = self.cd.data.remDuration
        if dur <= 0 then return 0 end
        if dur < avengingOrCrusade.remDuration or dur < howProc.remDuration then
            return dur
        end
        if UnitExists("target") and 5 * UnitHealth("target") < UnitHealthMax("target") then
            return dur
        end
        return -1
    end
    function how.onTimer:ComputeAvailablePriorityOverride(t)
        if C_Spell.IsSpellUsable(24275) then
            return 1
        else
            return 0
        end
    end

    function shock.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end
    function shock.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 6
    end

    local bonusDawnCooldown = hud:AddTrackedDebuffOnSelf(387441, talent_bonus_dawn)
    local bonusDawnCooldownTimer = hud:AddPriority(1519263, talent_bonus_dawn)
    function bonusDawnCooldownTimer:ComputeDurationOverride(t)
        if bonusDawnCooldown.remDuration > 0 then
            local judgeDur
            if judgment.data.currentCharges == 0 then
                judgeDur = judgment.data.remDuration
            else
                judgeDur = 0
            end
            return math.max(judgeDur, bonusDawnCooldown.remDuration)
        else
            return 0
        end
    end
    function bonusDawnCooldownTimer:ComputeAvailablePriorityOverride(t)
        if judgment.data.currentCharges > 0 then
            return 3
        else
            return 0
        end
    end
    function judgment.onTimer:ComputeAvailablePriorityOverride(t)
        if bonusDawnCooldown.remDuration > 2 or not talent_bonus_dawn:PlayerHasTalent() then
            return 3
        else
            return 0
        end
    end
    function judgment.availableChargePriority:ComputeAvailablePriorityOverride(t)
        if bonusDawnCooldown.remDuration > 2 or not talent_bonus_dawn:PlayerHasTalent() then
            return 15
        else
            return 0
        end
    end

    function crustrike.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end
    function crustrike.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 12
    end

    function prism.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function seasons.onTimer:ComputeAvailablePriorityOverride(t)
        return 11
    end

    --[[
    function barrier.onTimer:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function toll.onTimer:ComputeAvailablePriorityOverride(t)
        return 13
    end
    ]] --

    local divinityCooldown = hud:AddTrackedCooldown(414273, talent_divinity)
    local divinityPrio = hud:AddPriority(135985, talent_divinity)
    function divinityPrio:ComputeDurationOverride(t)
        return divinityCooldown.remDuration
    end
    function divinityPrio:ComputeAvailablePriorityOverride(t)
        return 14
    end

    local tyrCooldown = hud:AddTrackedCooldown(200652, talent_tyr)
    local tyrPrio = hud:AddPriority(1122562, talent_tyr)
    function tyrPrio:ComputeDurationOverride(t)
        return tyrCooldown.remDuration
    end
    function tyrPrio:ComputeAvailablePriorityOverride(t)
        return 18
    end

    --- utility ---

    hud:AddUtilityCooldown(tyrCooldown, hud.healGroup)

    hud:AddUtilityCooldown(divinityCooldown, hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31884, talent_any_avenging), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(216331, talent_crusader), hud.powerUpGroup, nil, nil, nil, true)

    ERACombatFrames_PaladinDivProt(hud, 498, -2, 26)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31821, talent_auramastery), hud.defenseGroup, nil, -1)

    hud:AddUtilityDispell(dispellCooldown, hud.specialGroup, nil, nil, talent_normal_cleanse, true, false, false, false, false)
    hud:AddUtilityDispell(dispellCooldown, hud.specialGroup, nil, nil, talent_better_cleanse, true, true, true, false, false)
end

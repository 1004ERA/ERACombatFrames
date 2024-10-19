---@class ERADKBloodHUD : ERADKHUD
---@field strikeCost number

---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents DKCommonTalents
function ERACombatFrames_DeathKnightBloodSetup(cFrame, enemies, talents)
    local talent_ossuary = ERALIBTalent:Create(96277)
    local talent_bloodmark = ERALIBTalent:Create(96271)
    local talent_tombstone = ERALIBTalent:Create(96270)
    local talent_bonestorm = ERALIBTalent:Create(96258)
    local talent_gorefiend = ERALIBTalent:Create(96170)
    local talent_vblood = ERALIBTalent:Create(96308)
    local talent_improved_vblood = ERALIBTalent:Create(96272)
    local talent_drw = ERALIBTalent:Create(96269)
    local talent_runetap = ERALIBTalent:Create(96301)
    local talent_bloodtap = ERALIBTalent:Create(96167)
    local talent_consumption = ERALIBTalent:Create(126299)
    local talent_drinker = ERALIBTalent:Create(126300)
    local talent_voracious = ERALIBTalent:Create(96171)
    local talent_sanground = ERALIBTalent:Create(96169)

    local hud = ERACombatFrames_DKCommonSetup(cFrame, enemies, talents, 1)
    ---@cast hud ERADKBloodHUD
    hud.strikeCost = 0

    if ERACombatOptions_getOptionsForSpec(nil, 1).damageTakenWindow then
        local damageTaken = ERAHUDDamageTakenWindow:Create(hud, hud.damageTaken, 222, 333)
    end

    local plague = hud:AddTrackedDebuffOnTarget(55078)

    local boneshield = hud:AddTrackedBuff(195181)
    local vblood = hud:AddTrackedBuff(55233, talent_vblood)
    local sanground = hud:AddTrackedBuff(391459, talent_sanground)

    --- death strike ---

    function hud:DataUpdatedOverride(t)
        local cost = 45
        if talents.improved_deathstrike:PlayerHasTalent() then
            cost = cost - 5
        end
        if self.blooddrawBuff.remDuration > self.occupied + 0.1 then
            cost = cost - 10
        end
        if (talent_ossuary:PlayerHasTalent() and boneshield.stacks >= 5) then
            cost = cost - 5
        end
        self.strikeCost = cost
    end

    hud.runicPower.bar:AddMarkingFromMax(20)
    local strikeConsumer = hud.runicPower.bar:AddMarkingFrom0(40)
    function strikeConsumer:ComputeValueOverride(t)
        return hud.strikeCost
    end

    function hud:PreUpdateDisplayOverride(t)
        local additionalH
        local strikeCost
        if hud.succor.remDuration > hud.occupied + 0.1 then
            strikeCost = 0
            hud.health.bar:SetPrevisionColor(ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)
            additionalH = 0.1 * hud.health.maxHealth
        else
            strikeCost = hud.strikeCost
            hud.health.bar:SetPrevisionColor(0.5, 0.5, 1.0)
            additionalH = 0
        end
        if hud.runicPower.currentPower >= strikeCost or additionalH > 0 then
            local baseH = hud.health.maxHealth * 0.07
            local dmgH = 0.25 * hud.damageTaken.currentDamage
            if (dmgH > baseH) then
                local healing = math.max(baseH, dmgH)
                if (talents.improved_deathstrike:PlayerHasTalent()) then
                    healing = healing * 1.6
                end
                if (talent_voracious:PlayerHasTalent()) then
                    healing = healing * 1.15
                end
                if (sanground.remDuration > hud.occupied + 0.1) then
                    healing = healing * 1.05
                end
                if (vblood.remDuration > hud.occupied + 0.1) then
                    healing = healing * (1 + (0.3 + talent_improved_vblood.rank * 0.05))
                end
                hud.health.bar:SetForecast(healing + additionalH)
            else
                hud.health.bar:SetForecast(0)
            end
        else
            hud.health.bar:SetForecast(0)
        end
    end

    -- bars ---

    local bloodmark = hud:AddTrackedDebuffOnTarget(206940, talent_bloodmark)
    hud:AddAuraBar(bloodmark, nil, 0.9, 0.3, 0.3)

    local drw = hud:AddAuraBar(hud:AddTrackedBuff(81256, talent_drw), nil, 1.0, 0.8, 0.6)

    hud:AddAuraBar(vblood, nil, 1.0, 0.0, 0.0)

    hud:AddAuraBar(hud:AddTrackedBuff(194679, talent_runetap), nil, 0.6, 0.3, 0.3)

    --- SAO ---

    local crimson = hud:AddTrackedBuff(81141)
    hud:AddAuraOverlay(crimson, 1, 511104, false, "LEFT", false, false, false, false)

    local vampStrike = hud:AddOverlayBasedOnSpellIcon(206930, 5927645, "CovenantChoice-Celebration-Venthyr-DetailLine", true, "BOTTOM", false, false, false, false, talents.h_sanlayn)
    function vampStrike:ConfirmIsActiveOverride(t, combat)
        return combat and vblood.remDuration <= 0
    end

    ERACombatFrames_DK_MissingDisease(hud, plague)

    --- rotation ---

    hud:AddRotationBuff(boneshield)

    local boilIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(50842))

    local dndIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 43265, 1))

    local drinkerIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 206931, 1, talent_drinker))
    local consumptionIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(274156, talent_consumption))

    ERACombatFrames_DKSoulReaper(hud, 1)

    ERACombatFrames_DK_ReaperMark(hud, talents, 6)

    local runetapIcon = hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 194679, 1, talent_runetap))

    hud:AddRotationCooldown(hud:AddTrackedCooldown(219809, talent_tombstone))

    local bloodmarkIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(206940, talent_bloodmark))

    local bonestormIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(194844, talent_bonestorm))

    local bloodtapIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(221699, talent_bloodtap))

    hud:AddRotationCooldown(ERACooldownIgnoringRunes:Create(hud, 195292, 1)) -- caress

    --[[

    PRIO

    1 - soul reaper
    2 - bloodmark
    3 - boil
    4 - dnd proc
    5 - bloodtap
    6 - reapermark
    7 - dnd
    8 - consumption
    9 - drinker
    10 - boil charged
    11 - bloodmark refresh
    12 - runetap

    ]]

    function bloodmarkIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if bloodmark.remDuration <= self.hud.occupied then
            return 2
        elseif bloodmark.remDuration <= 2 then
            return 11
        else
            return 0
        end
    end

    function boilIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end
    function boilIcon.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 10
    end

    function dndIcon.onTimer:ComputeAvailablePriorityOverride()
        if crimson.remDuration > self.hud.occupied + 0.1 then
            return 4
        else
            return 7
        end
    end

    function bloodtapIcon.onTimer:ComputeAvailablePriorityOverride()
        if hud.runes.availableRunes == 0 and hud.runes.nextRuneDuration > self.hud.occupied then
            return 5
        else
            return 0
        end
    end

    function consumptionIcon.onTimer:ComputeAvailablePriorityOverride()
        return 8
    end

    function drinkerIcon.onTimer:ComputeAvailablePriorityOverride()
        return 9
    end

    function runetapIcon.onTimer:ComputeAvailablePriorityOverride()
        return 10
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(55233, talent_vblood), hud.healGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(49028, talent_drw), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108199, talent_gorefiend), hud.controlGroup)
end

---@class PalaRetHUD : PaladinHUD
---@field pala_lastTemplarStrike number

---@param cFrame ERACombatFrame
---@param talents PaladinCommonTalents
function ERACombatFrames_PaladinRetributionSetup(cFrame, talents)
    local talent_final_verdict = ERALIBTalent:Create(102504)
    local talent_crusade = ERALIBTalent:Create(125129)
    local talent_avenging_might = ERALIBTalent:Create(102519)
    local talent_any_avenging = ERALIBTalent:CreateAnd(ERALIBTalent:CreateOr(talents.avenging, talent_avenging_might), ERALIBTalent:CreateNot(talent_crusade))
    local talent_instaflash = ERALIBTalent:Create(102503)
    local talent_not_autostrike = ERALIBTalent:CreateNotTalent(115474)
    local talent_templar_strike = ERALIBTalent:Create(115473)
    local talent_crusader_strike = ERALIBTalent:CreateAnd(ERALIBTalent:CreateNot(talent_templar_strike), talent_not_autostrike)
    local talent_hammernado = ERALIBTalent:Create(115016)
    local talent_bonus_storm = ERALIBTalent:Create(115453)
    local talent_free_storm = ERALIBTalent:Create(115051)
    local talent_ashes = ERALIBTalent:Create(102497)
    local talent_arbiter = ERALIBTalent:Create(102514)
    local talent_shield_of_vengeance = ERALIBTalent:Create(125130)
    local talent_orbital_strike = ERALIBTalent:Create(102513)
    local talent_execution = ERALIBTalent:Create(115435)
    local talent_avenging_proc = ERALIBTalent:Create(102525)
    local talent_not_avenging_proc = ERALIBTalent:CreateNotTalent(102525)
    local talent_avenging_spell = ERALIBTalent:CreateAnd(talent_any_avenging, talent_not_avenging_proc)
    local talent_avenging_proc = ERALIBTalent:CreateAnd(talent_any_avenging, talent_avenging_proc)
    local talent_crusade_spell = ERALIBTalent:CreateAnd(talent_crusade, talent_not_avenging_proc)
    local talent_crusade_proc = ERALIBTalent:CreateAnd(talent_crusade, talent_avenging_proc)

    local hud = ERACombatFrames_PaladinCommonSetup(cFrame, 3, 408458, ERALIBTalent:Create(102608), true, 384029, ERALIBTalent:Create(115468), talents)
    ---@cast hud PalaRetHUD
    hud.pala_lastTemplarStrike = 0

    ERACombatFrames_PaladinNonHealerCleanse(hud, talents)

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if sourceGUID == self.cFrame.playerGUID and evt == "SPELL_CAST_SUCCESS" and spellID == 407480 then
            self.pala_lastTemplarStrike = t
        end
    end

    --- SAO ---

    local howProc = hud:AddTrackedBuff(383329, talent_final_verdict)
    hud:AddAuraOverlay(howProc, 1, "talents-animations-class-paladin", true, "MIDDLE", false, false, false, false, nil)

    hud:AddOverlayBasedOnSpellActivation(184575, 450913, false, "LEFT", false, false, false, false, nil)

    local freeStorm = hud:AddTrackedBuff(326733, talent_free_storm)
    hud:AddAuraOverlay(freeStorm, 1, 459314, false, "RIGHT", false, false, false, true)

    local bonusStorm = hud:AddTrackedBuff(387178, talent_bonus_storm)
    hud:AddAuraOverlay(bonusStorm, 1, "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)

    --- bars ---

    local slashBar = hud:AddGenericBar(PaladinTemplarSlashTimer:create(hud, talent_templar_strike), 1112940, 1.0, 1.0, 0.0)

    local avengingAndCrusadeDurations = {}
    local avengingDuration = hud:AddTrackedBuff(31884, talent_avenging_spell)
    local avengingProcDuration = hud:AddTrackedBuff(454351, talent_avenging_proc)
    local crusadeDuration = hud:AddTrackedBuff(231895, talent_crusade_spell)
    local crusadeProcDuration = hud:AddTrackedBuff(454373, talent_crusade_proc)
    local avengingOrCrusade = hud:AddOrTimer(false, avengingDuration, avengingProcDuration, crusadeDuration, crusadeProcDuration)
    table.insert(avengingAndCrusadeDurations, avengingDuration)
    table.insert(avengingAndCrusadeDurations, avengingProcDuration)
    table.insert(avengingAndCrusadeDurations, crusadeDuration)
    table.insert(avengingAndCrusadeDurations, crusadeProcDuration)
    for _, aura in ipairs(avengingAndCrusadeDurations) do
        hud:AddAuraBar(aura, nil, 1.0, 0.0, 1.0)
    end

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(343527, talent_execution), nil, 1.0, 0.0, 0.0)

    local freeStormBar = hud:AddAuraBar(freeStorm, 236250, 0.5, 1.0, 0.0)
    local bonusStormBar = hud:AddAuraBar(bonusStorm, 461860, 0.0, 1.0, 0.5)
    local stormBarsArray = {}
    table.insert(stormBarsArray, freeStormBar)
    table.insert(stormBarsArray, bonusStormBar)
    for _, bar in ipairs(stormBarsArray) do
        function bar:ComputeDurationOverride(t)
            if self.aura.remDuration < 6 then
                return self.aura.remDuration
            else
                return 0
            end
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(184662, talent_shield_of_vengeance), nil, 0.7, 0.0, 0.4)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(343721, talent_orbital_strike), nil, 0.9, 0.0, 0.4)

    --- rotation ---

    local boj = hud:AddRotationCooldown(hud:AddTrackedCooldown(184575))
    local crusaderStrike = hud:AddRotationCooldown(hud:AddTrackedCooldown(35395, talent_crusader_strike))
    local templarStrike = hud:AddRotationCooldown(hud:AddTrackedCooldown(407480, talent_templar_strike))
    local judgment = hud:AddRotationCooldown(hud:AddTrackedCooldown(20271))
    local how = hud:AddRotationCooldown(hud:AddTrackedCooldown(24275, talents.how))
    how.checkUsable = true
    local ashes = hud:AddRotationCooldown(hud:AddTrackedCooldown(255937, talent_ashes))
    local execution = hud:AddRotationCooldown(hud:AddTrackedCooldown(343527, talent_execution))
    local orbital = hud:AddRotationCooldown(hud:AddTrackedCooldown(343721, talent_orbital_strike))
    local toll = hud:AddRotationCooldown(hud.pala_tollCooldown)

    hud:AddRotationStacks(hud:AddTrackedBuff(406975, talent_arbiter), 25, 25).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --[[

    prio

    1 - how
    2 - boj
    3 - crusader
    4 - templar strike
    5 - templar slash if short duration
    6 - judgment
    7 - templar slash if long duration
    8 - ashes
    9 - crusader charged
    10 - judgment charged
    11 - execution
    12 - orbital strike
    13 - toll

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

    function boj.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function crusaderStrike.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end
    function crusaderStrike.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function templarStrike.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    local slashPrio = hud:AddPriority(1112940, talent_templar_strike)
    function slashPrio:ComputeAvailablePriorityOverride(t)
        local dur = slashBar.timer.remDuration
        if dur > self.hud.occupied then
            if dur <= self.hud.occupied + 1.5 * self.hud.hasteMultiplier then
                return 5
            else
                return 7
            end
        else
            return 0
        end
    end

    function judgment.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end
    function judgment.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 10
    end

    function ashes.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function execution.onTimer:ComputeAvailablePriorityOverride(t)
        return 11
    end

    function orbital.onTimer:ComputeAvailablePriorityOverride(t)
        return 12
    end

    function toll.onTimer:ComputeAvailablePriorityOverride(t)
        return 13
    end

    local instaflashCooldown = hud:AddTrackedCooldown(19750, talent_instaflash)
    local instaflashPrio = hud:AddPriority(135907, talent_instaflash)
    function instaflashPrio:ComputeDurationOverride(t)
        if instaflashCooldown.remDuration > 0 then
            return instaflashCooldown.remDuration
        elseif self.hud.health.currentHealth / self.hud.health.maxHealth < 0.8 then
            return 0
        else
            return -1
        end
    end
    function instaflashPrio:ComputeAvailablePriorityOverride(t)
        return 16 * (1 - self.hud.health.currentHealth / self.hud.health.maxHealth)
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(198034, talent_hammernado), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31884, talent_avenging_spell), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(231895, talent_crusade_spell), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(184662, talent_shield_of_vengeance), hud.defenseGroup, nil, -2, nil, true)
    ERACombatFrames_PaladinDivProt(hud, -1)
end

---@class PaladinTemplarSlashTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private phud PalaRetHUD
PaladinTemplarSlashTimer = {}
PaladinTemplarSlashTimer.__index = PaladinTemplarSlashTimer
setmetatable(PaladinTemplarSlashTimer, { __index = ERATimer })

---@param hud PalaRetHUD
---@param talent ERALIBTalent
---@return PaladinTemplarSlashTimer
function PaladinTemplarSlashTimer:create(hud, talent)
    local x = {}
    setmetatable(x, PaladinTemplarSlashTimer)
    ---@cast x PaladinTemplarSlashTimer
    x:constructTimer(hud)
    x.talent = talent
    x.phud = hud
    return x
end

function PaladinTemplarSlashTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PaladinTemplarSlashTimer:updateData(t)
    if IsSpellOverlayed(407480) then
        local remDur = 5 - (t - self.phud.pala_lastTemplarStrike)
        if remDur > 0 then
            self.remDuration = remDur
        else
            self.remDuration = 0
        end
    else
        self.remDuration = 0
    end
end

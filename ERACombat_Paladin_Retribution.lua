---@class PalaRetHUD : PaladinHUD
---@field pala_lastTemplarStrike number
---@field pala_lastCrusadingStrike number
---@field pala_lastAshes number
---@field pala_lastHammerTemplar number

---@param cFrame ERACombatFrame
---@param talents PaladinCommonTalents
function ERACombatFrames_PaladinRetributionSetup(cFrame, talents)
    local talent_final_verdict = ERALIBTalent:Create(102504)
    local talent_instaflash = ERALIBTalent:Create(102503)
    local talent_fast_auto = ERALIBTalent:Create(115165)
    local talent_autostrike = ERALIBTalent:Create(115474)
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
    local talent_avenging = ERALIBTalent:Create(102519)
    local talent_crusade = ERALIBTalent:Create(125129)
    local talent_avencrus_proc = ERALIBTalent:Create(102525)
    local talent_not_avencrus_proc = ERALIBTalent:CreateNotTalent(102525)
    local talent_avenging_spell = ERALIBTalent:CreateAnd(talent_avenging, talent_not_avencrus_proc)
    local talent_avenging_proc = ERALIBTalent:CreateAnd(talent_avenging, talent_avencrus_proc)
    local talent_crusade_spell = ERALIBTalent:CreateAnd(talent_crusade, talent_not_avencrus_proc)
    local talent_crusade_proc = ERALIBTalent:CreateAnd(talent_crusade, talent_avencrus_proc)
    local htalent_anshe = ERALIBTalent:Create(117668)

    local hud = ERACombatFrames_PaladinCommonSetup(cFrame, 3, 408458, ERALIBTalent:Create(128243), true, 384029, ERALIBTalent:Create(115468), talents)
    ---@cast hud PalaRetHUD
    hud.pala_lastCrusadingStrike = 0
    hud.pala_lastTemplarStrike = 0
    hud.pala_lastAshes = 0
    hud.pala_lastHammerTemplar = 0

    ERACombatFrames_PaladinNonHealerCleanse(hud, talents)

    function hud:pala_castSuccess(t, spellID)
        if spellID == 407480 then
            self.pala_lastTemplarStrike = t
        elseif spellID == 255937 then
            self.pala_lastAshes = t
        elseif spellID == 427453 then
            self.pala_lastHammerTemplar = t
        end
    end
    function hud:pala_CLEU(t, evt, spellID)
        if evt == "SPELL_ENERGIZE" and spellID == 406834 then
            self.pala_lastCrusadingStrike = t
        end
    end

    local instaflashCooldown = hud:AddTrackedCooldown(19750, talent_instaflash)
    function hud:PreUpdateDisplayOverride(t, combat)
        if talent_instaflash:PlayerHasTalent() and instaflashCooldown.remDuration <= self.remGCD then
            self.health.bar:SetForecast(5.9 * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100))
        else
            self.health.bar:SetForecast(0)
        end
    end

    --- SAO ---

    local howProc = hud:AddTrackedBuff(383329, talent_final_verdict)
    local hTemplarWrath = ERACombatFrames_PaladinTemplar_returnWrath(hud, talents)
    local anshe = hud:AddTrackedBuff(445206, htalent_anshe)
    local howAllowed = hud:AddOrTimer(false, hTemplarWrath, howProc, anshe)
    hud:AddTimerOverlay(howAllowed, "talents-animations-class-paladin", true, "MIDDLE", false, false, false, false, nil) --Adventures-Buff-Heal-Burst

    hud:AddOverlayBasedOnSpellActivation(184575, 450913, false, "LEFT", false, false, false, false, nil)

    local freeStorm = hud:AddTrackedBuff(326733, talent_free_storm)
    hud:AddAuraOverlay(freeStorm, 1, 459314, false, "RIGHT", false, false, false, true)

    local bonusStorm = hud:AddTrackedBuff(387178, talent_bonus_storm)
    hud:AddAuraOverlay(bonusStorm, 1, "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)

    --- bars ---

    local slashBar = hud:AddGenericBar(PaladinTemplarSlashTimer:create(hud, talent_templar_strike), 1112940, 0.0, 1.0, 1.0)
    hud:AddGenericBar(PaladinTemplarRetributionTimer:create(hud, talents.h_templar), 5342121, 1.0, 1.0, 0.0)

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

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(343527, talent_execution), nil, 1.0, 0.0, 0.0)
    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(343721, talent_orbital_strike), nil, 1.0, 0.0, 0.0)

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
    2 - crusading
    3 - templar strike
    4 - templar slash if short duration
    5 - judgment
    6 - boj
    7 - crusader, or templar slash if long duration
    8 - judgment charged
    9 - boj charged
    10 - crusader charged
    11 - ashes
    12 - execution / orbital strike
    13 - toll

    ]]

    function how.onTimer:ComputeDurationOverride(t)
        local dur = self.cd.data.remDuration
        if dur <= 0 then return 0 end
        if dur < avengingOrCrusade.remDuration or dur < howAllowed.remDuration then
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
        return 6
    end
    function boj.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function crusaderStrike.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end
    function crusaderStrike.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 10
    end

    function templarStrike.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    local slashPrio = hud:AddPriority(1112940, talent_templar_strike)
    function slashPrio:ComputeAvailablePriorityOverride(t)
        local dur = slashBar.timer.remDuration
        if dur > self.hud.occupied then
            if dur <= self.hud.occupied + 1.5 * self.hud.hasteMultiplier then
                return 4
            else
                return 7
            end
        else
            return 0
        end
    end

    function judgment.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end
    function judgment.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function ashes.onTimer:ComputeAvailablePriorityOverride(t)
        return 11
    end

    function execution.onTimer:ComputeAvailablePriorityOverride(t)
        return 12
    end

    function orbital.onTimer:ComputeAvailablePriorityOverride(t)
        return 12
    end

    function toll.onTimer:ComputeAvailablePriorityOverride(t)
        return 13
    end

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
    --[[
    function instaflashPrio:ComputeAvailablePriorityOverride(t)
        return 16 * (self.hud.health.currentHealth / self.hud.health.maxHealth)
    end
    ]]

    local crusadingTimer = PaladinCrusadingTimer:create(hud, talent_autostrike, talent_fast_auto)
    local crusadingPrio = hud:AddPriority(135278, talent_autostrike)
    function crusadingPrio:ComputeAvailablePriorityOverride()
        return 2
    end
    function crusadingPrio:ComputeDurationOverride(t)
        return crusadingTimer.remDuration
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(198034, talent_hammernado), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31884, talent_avenging_spell), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(231895, talent_crusade_spell), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(184662, talent_shield_of_vengeance), hud.defenseGroup, nil, -2, nil, true)
    ERACombatFrames_PaladinDivProt(hud, 403876, -1, 1)
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

---@class PaladinCrusadingTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private talentFastAuto ERALIBTalent
---@field private phud PalaRetHUD
PaladinCrusadingTimer = {}
PaladinCrusadingTimer.__index = PaladinCrusadingTimer
setmetatable(PaladinCrusadingTimer, { __index = ERATimer })

---@param hud PalaRetHUD
---@param talent ERALIBTalent
---@param talentFastAuto ERALIBTalent
---@return PaladinCrusadingTimer
function PaladinCrusadingTimer:create(hud, talent, talentFastAuto)
    local x = {}
    setmetatable(x, PaladinCrusadingTimer)
    ---@cast x PaladinCrusadingTimer
    x:constructTimer(hud)
    x.talent = talent
    x.phud = hud
    x.talentFastAuto = talentFastAuto
    return x
end

function PaladinCrusadingTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PaladinCrusadingTimer:updateData(t)
    --local remDur = 2 * 3.6 * self.hud.hasteMultiplier * (1 - self.talentFastAuto.rank * 0.2) - (t - self.phud.pala_lastCrusadingStrike)
    local remDur = 2 * UnitAttackSpeed("player") - (t - self.phud.pala_lastCrusadingStrike)
    if remDur > 0 then
        self.remDuration = remDur
    else
        self.remDuration = 0
    end
end

---@class PaladinTemplarRetributionTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private phud PalaRetHUD
PaladinTemplarRetributionTimer = {}
PaladinTemplarRetributionTimer.__index = PaladinTemplarRetributionTimer
setmetatable(PaladinTemplarRetributionTimer, { __index = ERATimer })

---@param hud PalaRetHUD
---@param talent ERALIBTalent
---@return PaladinTemplarRetributionTimer
function PaladinTemplarRetributionTimer:create(hud, talent)
    local x = {}
    setmetatable(x, PaladinTemplarRetributionTimer)
    ---@cast x PaladinTemplarRetributionTimer
    x:constructTimer(hud)
    x.talent = talent
    x.phud = hud
    return x
end

function PaladinTemplarRetributionTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PaladinTemplarRetributionTimer:updateData(t)
    if IsSpellOverlayed(427453) then
        local remDur = 12 - (t - self.phud.pala_lastAshes)
        if remDur > 0 then
            local sinceLastHammer = t - self.phud.pala_lastHammerTemplar
            if sinceLastHammer <= 13 then
                self.remDuration = 0
            else
                self.remDuration = remDur
            end
        else
            self.remDuration = 0
        end
    else
        self.remDuration = 0
    end
end

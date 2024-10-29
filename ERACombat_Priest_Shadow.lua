---@class PriestShadowHUD : PriestHUD
---@field priest_lastSield number
---@field priest_lastDmgTaken number
---@field priest_lastSummon number
---@field priest_lastIncreaseSummon_blast number
---@field priest_lastIncreaseSummon_death number

---@param cFrame ERACombatFrame
---@param talents ERACombat_PriestCommonTalents
function ERACombatFrames_PriestShadowSetup(cFrame, talents)
    local talent_dispell_disease = ERALIBTalent:Create(103854)
    local talent_silence = ERALIBTalent:Create(103792)
    local talent_dispersion = ERALIBTalent:Create(103806)
    local talent_horror = ERALIBTalent:Create(103793)
    local talent_increase_summon = ERALIBTalent:Create(103783)
    local talent_blender = ERALIBTalent:Create(103788)
    local talent_fiend = ERALIBTalent:CreateAnd(ERALIBTalent:CreateNot(talent_blender), talents.shadowfiend)
    local talent_cheap_plague = ERALIBTalent:Create(103786)
    local talent_expensive_plague = ERALIBTalent:Create(115671)
    local talent_regular_plague = ERALIBTalent:CreateNOR(talent_cheap_plague, talent_expensive_plague)
    local talent_death_proc = ERALIBTalent:Create(103681)
    local talent_blast_proc = ERALIBTalent:Create(103805)
    local talent_plague_proc = ERALIBTalent:Create(103684)
    local talent_surge = ERALIBTalent:Create(103812)
    local talent_crash_target = ERALIBTalent:Create(103813)
    local talent_crash_ground = ERALIBTalent:Create(125983)
    local talent_unfurling = ERALIBTalent:Create(103804)
    local talent_ascension = ERALIBTalent:Create(103680)
    local talent_eruption = ERALIBTalent:Create(103674)
    local talent_torrent = ERALIBTalent:Create(103796)
    local talent_yshaarj = ERALIBTalent:Create(103787)
    local talent_important_minblender = ERALIBTalent:CreateOr(talent_yshaarj, talent_increase_summon, talent_increase_summon)
    local talent_star = ERALIBTalent:Create(103828)
    local talent_halo = ERALIBTalent:Create(103827)

    local hud = ERACombatFrames_PriestCommonSetup(cFrame, talents, 3)
    ---@cast hud PriestShadowHUD
    hud.priest_lastSield = 0
    hud.priest_lastDmgTaken = 0
    hud.priest_lastSummon = 0
    hud.priest_lastIncreaseSummon_blast = 0
    hud.priest_lastIncreaseSummon_death = 0

    local insa = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Insanity, 14, 0.6, 0.0, 1.0)
    insa.bar:AddMarkingFrom0(50, talent_regular_plague)
    insa.bar:AddMarkingFrom0(45, talent_cheap_plague)
    insa.bar:AddMarkingFrom0(55, talent_expensive_plague)

    local mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, 12, 0.0, 0.0, 1.0, nil)
    mana.hideFullOutOfCombat = true
    function mana:ConfirmIsVisibleOverride(t, combat)
        if combat then
            return self.currentPower / self.maxPower <= 0.6
        else
            return self.currentPower / self.maxPower <= 0.5
        end
    end
    function mana:CollapseIfTransparent(t, combat)
        return true
    end

    local dots = ERAHUDDOT:Create(hud)
    local pain = dots:AddDOT(589, nil, 1.0, 0.8, 0.0, nil, 0, 21) -- 16 + 5
    local touch = dots:AddDOT(34914, nil, 0.5, 0.4, 1.0, nil, 1.5, 21)

    hud:AddKick(hud:AddTrackedCooldown(15487, talent_silence))

    hud:AddChannelInfo(15407, 0.75)                              -- mind flay 4.5 seconds, delayed first hit
    hud:AddChannelInfo(391403, 0.375, talent_surge)              -- mind flay insanity 1.5 seconds, delayed first hit
    hud:AddChannelInfo(263165, 0.75, talent_torrent, nil, false) -- torrent 3 seconds, instant first hit, unaffected by haste

    local enemies = ERACombatEnemies:Create(cFrame, 3)

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, tarGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if sourceGUID == self.cFrame.playerGUID then
            if evt == "SPELL_CAST_SUCCESS" then
                if spellID == 17 then
                    self.priest_lastSield = t
                elseif spellID == 34433 or spellID == 200174 then
                    self.priest_lastSummon = t
                elseif spellID == 8092 then
                    self.priest_lastIncreaseSummon_blast = t
                elseif spellID == 32379 then
                    self.priest_lastIncreaseSummon_death = t
                end
            end
        elseif tarGUID == self.cFrame.playerGUID and (evt == "SPELL_DAMAGE" or evt == "SWING_DAMAGE") then
            self.priest_lastDmgTaken = t
        end
    end

    --- SAO ---

    hud:AddAuraOverlay(hud.priest_instaflash, 1, 450933, false, "BOTTOM", false, false, true, false)

    local deathProc = hud:AddTrackedBuff(392511, talent_death_proc)
    hud:AddAuraOverlay(deathProc, 1, "talents-animations-class-priest", true, "MIDDLE", false, false, false, false)

    local blastProc = hud:AddTrackedBuff(375981, talent_blast_proc)
    hud:AddAuraOverlay(blastProc, 1, 627609, false, "TOP", false, false, false, false)

    local surgeFlay = hud:AddTrackedBuff(391401, talent_surge)
    local surgeSpike = hud:AddTrackedBuff(407468, talent_surge)
    local surgeBuffs = {}
    table.insert(surgeBuffs, surgeFlay)
    table.insert(surgeBuffs, surgeSpike)
    for _, sur in ipairs(surgeBuffs) do
        hud:AddAuraOverlay(sur, 1, 592058, false, "LEFT", false, false, false, false)
        hud:AddAuraOverlay(sur, 2, 592058, false, "RIGHT", true, false, false, false)
    end

    local plagueProc = hud:AddTrackedBuff(373204, talent_plague_proc)
    function hud:PreUpdateDisplayOverridePriest(t, combat)
        if plagueProc.remDuration > self.remGCD then
            insa.bar:SetMainColor(1.0, 0.0, 0.0)
            insa.bar:SetBorderColor(1.0, 0.0, 0.0)
        else
            insa.bar:SetMainColor(0.6, 0.0, 1.0)
            insa.bar:SetBorderColor(1.0, 1.0, 1.0)
        end
    end

    --- bars ---

    local plagueDuration = hud:AddTrackedDebuffOnTarget(335467)
    hud:AddAuraBar(plagueDuration, nil, 0.6, 0.0, 1.0)

    for _, sur in ipairs(surgeBuffs) do
        local surgeBar = hud:AddAuraBar(sur, nil, 0.0, 1.0, 0.4)
        function surgeBar:ComputeDurationOverride(t)
            if self.aura.stacks > 2 or self.aura.remDuration < self.hud.timerDuration - 1 then
                return self.aura.remDuration
            else
                return 0
            end
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(47585, talent_dispersion), nil, 0.6, 0.5, 0.6)

    hud:AddAuraBar(hud:AddTrackedBuff(341282, talent_unfurling), nil, 0.5, 0.4, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(391109, talent_ascension), nil, 1.0, 0.0, 0.0)
    local voidform = hud:AddTrackedBuff(194249, talent_eruption)
    hud:AddAuraBar(voidform, nil, 1.0, 0.0, 0.0)

    local yshaarj_healthy_pride = hud:AddTrackedBuff(373316, talent_yshaarj)
    local yshaarj_enrage_anger = hud:AddTrackedBuff(373318, talent_yshaarj)
    local yshaarj_stun_despair = hud:AddTrackedBuff(373317, talent_yshaarj)
    local yshaarj_feared_fear = hud:AddTrackedBuff(373319, talent_yshaarj)
    local yshaarj_default_violence = hud:AddTrackedBuff(373320, talent_yshaarj)
    local yshaarjBuffs = {}
    table.insert(yshaarjBuffs, yshaarj_healthy_pride)
    table.insert(yshaarjBuffs, yshaarj_enrage_anger)
    table.insert(yshaarjBuffs, yshaarj_stun_despair)
    table.insert(yshaarjBuffs, yshaarj_feared_fear)
    table.insert(yshaarjBuffs, yshaarj_default_violence)
    for _, yshrj in ipairs(yshaarjBuffs) do
        hud:AddAuraBar(yshrj, nil, 1.0, 0.7, 0.9)
    end
    hud:AddGenericBar(PriestShadowSummonTimer:create(hud, ERALIBTalent:CreateAnd(talent_increase_summon, ERALIBTalent:CreateNot(talent_yshaarj)), talent_increase_summon, yshaarj_default_violence), 136199, 1.0, 0.7, 0.9)

    --- rotation ---

    local blast = hud:AddRotationCooldown(hud:AddTrackedCooldown(8092))

    local death = hud:AddRotationCooldown(hud:AddTrackedCooldown(32379))
    function death:DesaturatedOverride(t, combat)
        local phud = self.hud
        ---@cast phud PriestShadowHUD
        return not (phud.priest_target20 or deathProc.remDuration > phud.remGCD)
    end

    local torrent = hud:AddRotationCooldown(hud:AddTrackedCooldown(263165, talent_torrent))

    local crash_target = hud:AddRotationCooldown(hud:AddTrackedCooldown(457042, talent_crash_target))
    local crash_ground = hud:AddRotationCooldown(hud:AddTrackedCooldown(205385, talent_crash_ground))
    local crashes = {}
    table.insert(crashes, crash_target)
    table.insert(crashes, crash_ground)

    local star = hud:AddRotationCooldown(hud:AddTrackedCooldown(122121, talent_star))
    local halo = hud:AddRotationCooldown(hud:AddTrackedCooldown(120644, talent_halo))

    hud:AddRotationStacks(hud:AddTrackedBuff(390636, talents.rhapsody), 20, 16).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --[[

    prio

    1 - death
    2 - void bolt
    3 - blast
    4 - crash 3+ targets
    5 - star/halo
    6 - blast charged
    7 - torrent
    8 - blender/fiend
    9 - crash 2 targets
    10 - unfurling

    ]] --

    function death.onTimer:ComputeDurationOverride(t)
        local phud = self.hud
        ---@cast phud PriestHUD
        if phud.priest_target20 or deathProc.remDuration > phud.remGCD then
            return self.cd.data.remDuration
        else
            return -1
        end
    end
    function death.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    local boltCooldown = hud:AddTrackedCooldown(205448, talent_eruption)
    local boltPrio = hud:AddPriority(1035040, talent_eruption)
    function boltPrio:ComputeDurationOverride(t)
        if voidform.remDuration > boltCooldown.remDuration then
            return boltCooldown.remDuration
        else
            return -1
        end
    end
    function boltPrio:ComputeAvailablePriorityOverride(t)
        if voidform.remDuration > boltCooldown.remDuration then
            return 2
        else
            return 0
        end
    end

    function blast.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end
    function blast.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 6
    end

    for _, cr in ipairs(crashes) do
        function cr.onTimer:ComputeAvailablePriorityOverride(t)
            if enemies:GetCount() > 2 then
                return 4
            elseif enemies:GetCount() > 1 then
                return 9
            else
                return 0
            end
        end
    end

    function star.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end
    function halo.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function torrent.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    ERACombatFrames_PriestBlenderFiend(hud, 200174, talent_fiend, talent_blender, 8)

    local unfurlingCooldown = hud:AddTrackedDebuffOnSelf(341291, false, talent_unfurling)
    local unfurlingPrio = hud:AddPriority(1386547, talent_unfurling)
    function unfurlingPrio:ComputeDurationOverride(t)
        return unfurlingCooldown.remDuration
    end
    function unfurlingPrio:ComputeAvailablePriorityOverride(t)
        return 10
    end

    local lifePrio = hud:AddPriority(4667420, talents.life)
    function lifePrio:ComputeDurationOverride(t)
        local phud = self.hud
        ---@cast phud PriestShadowHUD
        if phud.health.currentHealth / phud.health.maxHealth < 0.35 then
            return hud.priest_lifeCooldown.remDuration
        else
            return -1
        end
    end
    function lifePrio:ComputeAvailablePriorityOverride(t)
        local phud = self.hud
        ---@cast phud PriestShadowHUD
        if phud.health.currentHealth / phud.health.maxHealth < 0.35 then
            return 100
        else
            return 0
        end
    end

    local shieldPrio = hud:AddPriority(135940)
    function shieldPrio:ComputeDurationOverride(t)
        return hud.priest_shieldCooldown.remDuration
    end
    function shieldPrio:ComputeAvailablePriorityOverride(t)
        local phud = self.hud
        ---@cast phud PriestShadowHUD
        if phud.priest_lastSield > 0 and t - phud.priest_lastSield < 13 and t - phud.priest_lastDmgTaken < 20 then
            return 101
        else
            return 0
        end
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(33076, talents.pom), hud.healGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(391109, talent_ascension), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(228260, talent_eruption), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(47585, talent_dispersion), hud.defenseGroup)

    hud:AddUtilityDispell(hud:AddTrackedCooldown(213634, talent_dispell_disease), hud.specialGroup, nil, nil, nil, false, false, true, false, false)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(64044, talent_horror), hud.controlGroup)

    ERACombatFrames_PriestFinalSetup(hud, talents)
end

---@class PriestShadowSummonTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private talentIncrease ERALIBTalent
---@field private phud PriestShadowHUD
---@field private yshaarj ERAAura
---@field private accIncrease number
PriestShadowSummonTimer = {}
PriestShadowSummonTimer.__index = PriestShadowSummonTimer
setmetatable(PriestShadowSummonTimer, { __index = ERATimer })

---@param hud PriestShadowHUD
---@param talent ERALIBTalent
---@param talentIncrease ERALIBTalent
---@param yshaarjAdditionalDuration ERAAura
---@return PriestShadowSummonTimer
function PriestShadowSummonTimer:create(hud, talent, talentIncrease, yshaarjAdditionalDuration)
    local x = {}
    setmetatable(x, PriestShadowSummonTimer)
    ---@cast x PriestShadowSummonTimer
    x:constructTimer(hud)
    x.talent = talent
    x.talentIncrease = talentIncrease
    x.phud = hud
    x.yshaarj = yshaarjAdditionalDuration
    x.accIncrease = 0
    return x
end

function PriestShadowSummonTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PriestShadowSummonTimer:updateData(t)
    local totDur
    if self.yshaarj.remDuration > 0 then
        totDur = 20
    else
        totDur = 15
    end
    if self.talentIncrease:PlayerHasTalent() then
        if self.phud.priest_lastIncreaseSummon_blast > self.phud.priest_lastSummon and t - self.phud.priest_lastIncreaseSummon_blast < 1 then
            self.accIncrease = self.accIncrease + 0.7
        end
        self.phud.priest_lastIncreaseSummon_blast = 0

        if self.phud.priest_lastIncreaseSummon_death > self.phud.priest_lastSummon and t - self.phud.priest_lastIncreaseSummon_death < 1 then
            self.accIncrease = self.accIncrease + 0.7
        end
        self.phud.priest_lastIncreaseSummon_death = 0
    else
        self.phud.priest_lastIncreaseSummon_blast = 0
        self.phud.priest_lastIncreaseSummon_death = 0
    end
    self.remDuration = totDur + self.accIncrease - (t - self.phud.priest_lastSummon)
    if self.remDuration <= 0 then
        self.remDuration = 0
        self.accIncrease = 0
    end
end

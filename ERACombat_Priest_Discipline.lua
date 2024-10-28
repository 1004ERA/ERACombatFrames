---@class PriestDisciplineHUD : PriestHUD
---@field priest_lastSummon number
---@field priest_lastIncreaseSummon_penance number
---@field priest_lastIncreaseSummon_blast number
---@field priest_lastIncreaseSummon_death number
---@field priest_lastHarsh number

---@param cFrame ERACombatFrame
---@param talents ERACombat_PriestHealerTalents
function ERACombatFrames_PriestDisciplineSetup(cFrame, talents)
    local talent_radiance = ERALIBTalent:Create(103722)
    local talent_painsup = ERALIBTalent:Create(103713)
    local talent_darkside = ERALIBTalent:Create(103724)
    local talent_schism = ERALIBTalent:Create(103704)
    local talent_barrier_pw = ERALIBTalent:Create(103687)
    local talent_barrier_luminous = ERALIBTalent:Create(116182)
    local talent_penance4 = ERALIBTalent:Create(103702)
    local talent_penance3 = ERALIBTalent:CreateNotTalent(103702)
    local talent_wicked = ERALIBTalent:Create(103718)
    local talent_pain = ERALIBTalent:CreateNotTalent(103718)
    local talent_rapture = ERALIBTalent:Create(103727)
    local talent_covenant = ERALIBTalent:Create(103706)
    local talent_ulti = ERALIBTalent:Create(103700)
    local talent_evangelism = ERALIBTalent:Create(103691)
    local talent_increase_summon = ERALIBTalent:Create(103712)
    local talent_blender = ERALIBTalent:Create(103710)
    local talent_shadowfiend = ERALIBTalent:CreateAnd(talents.shadowfiend, ERALIBTalent:CreateNot(talent_blender))
    local talent_harsh = ERALIBTalent:Create(103697)
    local talent_equilibrium = ERALIBTalent:Create(103696)

    local hud = ERACombatFrames_PriestCommonSetup(cFrame, talents, 1)
    ---@cast hud PriestDisciplineHUD
    hud.priest_lastSummon = 0
    hud.priest_lastIncreaseSummon_penance = 0
    hud.priest_lastIncreaseSummon_blast = 0
    hud.priest_lastIncreaseSummon_death = 0
    hud.priest_lastHarsh = 0

    --------------------------
    --#region GROUP FRAMES ---

    local dispellCooldown = hud:AddTrackedCooldown(527)

    local groupFrame
    local hOptions = ERACombatOptions_getOptionsForSpec(nil, 1).healerOptions
    ---@cast hOptions ERACombatGroupFrameOptions
    if not hOptions.disabled then
        groupFrame = ERAGroupFrame:Create(cFrame, hud, hOptions, 1)
        groupFrame:AddDisplay(groupFrame:AddBuff(194384, false), 0, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0) -- atonement
        groupFrame:AddDisplay(groupFrame:AddBuff(17, false), 1, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)     -- shield
        groupFrame:AddDisplay(groupFrame:AddBuff(139, false, talents.renew), 2, 1, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0)
        groupFrame:AddDisplay(groupFrame:AddBuff(41635, false, talents.pom), 3, 1, 0.6, 0.5, 0.0, 0.6, 0.5, 0.0).displayAsMaxStacks = 10
        groupFrame:AddDispell(dispellCooldown, talents.normalDispell, true, false, false, false, false)
        groupFrame:AddDispell(dispellCooldown, talents.betterlDispell, true, false, true, false, false)
    else
        groupFrame = nil
    end

    --#endregion
    --------------------------

    local dots = ERAHUDDOT:Create(hud)
    dots:AddDOT(204213, nil, 1.0, 1.0, 0.0, talent_wicked, 0.0, 20)
    dots:AddDOT(589, nil, 1.0, 1.0, 0.0, talent_pain, 0.0, 16)

    ERACombatFrames_PriestHealerSetup(hud, groupFrame, talents, dispellCooldown)

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, tarGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if sourceGUID == self.cFrame.playerGUID then
            if evt == "SPELL_CAST_SUCCESS" then
                if spellID == 34433 or spellID == 123040 then
                    self.priest_lastSummon = t
                elseif spellID == 47758 or spellID == 47540 or spellID == 400169 then -- penance (holy, holy, shadow)
                    self.priest_lastIncreaseSummon_penance = t
                elseif spellID == 8092 then
                    self.priest_lastIncreaseSummon_blast = t
                elseif spellID == 32379 then
                    self.priest_lastIncreaseSummon_death = t
                end
            end
        end
    end

    local harsh = hud:AddTrackedBuff(373183, talent_harsh)
    function hud:DataUpdatedOverride(t, combat)
        if harsh.remDuration > 0.5 then
            self.priest_lastHarsh = t
        end
    end

    local penanceCount = function(t)
        local cpt
        if talent_penance4:PlayerHasTalent() then
            cpt = 4
        else
            cpt = 3
        end
        if t - hud.priest_lastHarsh < 4 then
            cpt = cpt + 2 * (1 + harsh.stacks)
        end
        return 2 / (cpt - 1)
    end
    hud:AddChannelInfo(47758, 1.0, nil, penanceCount)
    hud:AddChannelInfo(400169, 1.0, nil, penanceCount) -- shadow penance

    local blastCooldown = hud:AddTrackedCooldown(8092)
    local penanceCooldown = hud:AddTrackedCooldown(47540)
    local starCooldown = hud:AddTrackedCooldown(110744, talents.star_healer)
    local haloCooldown = hud:AddTrackedCooldown(110744, talents.halo_healer)

    --- SAO ---

    local darkside = hud:AddTrackedBuff(198069, talent_darkside)
    hud:AddAuraOverlay(darkside, 1, 656728, false, "BOTTOM", false, false, true, false)

    --- bars ---

    local schism = hud:AddTrackedDebuffOnTarget(214621, talent_schism)
    hud:AddAuraBar(schism, nil, 0.6, 0.0, 1.0)

    local covenant = hud:AddTrackedBuff(322105, talent_covenant)
    hud:AddAuraBar(covenant, nil, 0.5, 0.0, 0.2)

    hud:AddAuraBar(hud:AddTrackedBuff(47536, talent_rapture), nil, 0.9, 0.9, 1.0)

    local equilibriumShadow = hud:AddAuraBar(hud:AddTrackedBuff(390707, talent_equilibrium), nil, 0.0, 0.5, 1.0)
    function equilibriumShadow:ComputeDurationOverride(t)
        local dur = self.aura.remDuration
        if blastCooldown.remDuration + 1.5 * self.hud.hasteMultiplier < dur then
            return dur
        else
            if covenant.remDuration > self.hud.remGCD then
                if
                    (penanceCooldown.remDuration < dur and penanceCooldown.remDuration < covenant.remDuration)
                    or
                    (talents.star_healer:PlayerHasTalent() and starCooldown.remDuration < dur and starCooldown.remDuration < covenant.remDuration)
                    or
                    (talents.halo_healer:PlayerHasTalent() and haloCooldown.remDuration + 1.5 * self.hud.hasteMultiplier < dur and haloCooldown.remDuration + 1.5 * self.hud.hasteMultiplier < covenant.remDuration)
                then
                    return dur
                else
                    return 0
                end
            else
                return 0
            end
        end
    end
    local equilibriumHoly = hud:AddAuraBar(hud:AddTrackedBuff(390706, talent_equilibrium), nil, 1.0, 0.5, 0.0)

    hud:AddGenericBar(PriestDisciplineSummonTimer:create(hud, ERALIBTalent:CreateAnd(talent_increase_summon, ERALIBTalent:CreateNot(talent_covenant)), talent_blender, talent_increase_summon), 136199, 1.0, 0.7, 0.9)

    --- rotation ---

    local deathIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(32379, talents.death))
    function deathIcon:DesaturatedOverride(t, combat)
        local phud = self.hud
        ---@cast phud PriestHUD
        return not phud.priest_target20
    end

    local blastIcon = hud:AddRotationCooldown(blastCooldown)

    local penanceIcon = hud:AddRotationCooldown(penanceCooldown)

    local shieldIcon = hud:AddRotationCooldown(hud.priest_shieldCooldown)

    local radianceIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(194509, talent_radiance))

    hud:AddRotationStacks(hud:AddTrackedBuff(390636, talents.rhapsody), 20, 16).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    local pomIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(33076, talents.pom))

    local starIcon = hud:AddRotationCooldown(starCooldown)
    local haloIcon = hud:AddRotationCooldown(haloCooldown)

    local lifeIcon = hud:AddRotationCooldown(hud.priest_lifeCooldown)

    --[[

    prio

    1 - death
    2 - penance
    3 - blast
    4 - shield
    5 - pom
    6 - star/halo
    7 - blender/fiend

    ]] --

    function deathIcon.onTimer:ComputeDurationOverride(t)
        local phud = self.hud
        ---@cast phud PriestHUD
        if phud.priest_target20 then
            return self.cd.data.remDuration
        else
            return -1
        end
    end
    function deathIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    function penanceIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function blastIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function shieldIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function pomIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function starIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end
    function haloIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    ERACombatFrames_PriestBlenderFiend(hud, 123040, talent_shadowfiend, talent_blender, 7)

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(47536, talent_rapture), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(246287, talent_evangelism), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(421453, talent_ulti), hud.powerUpGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(33206, talent_painsup), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(271466, talent_barrier_luminous), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(62618, talent_barrier_pw), hud.defenseGroup)

    ERACombatFrames_PriestFinalSetup(hud, talents)
end

---@class PriestDisciplineSummonTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private talentBlender ERALIBTalent
---@field private talentIncrease ERALIBTalent
---@field private phud PriestDisciplineHUD
---@field private yshaarj ERAAura
---@field private accIncrease number
PriestDisciplineSummonTimer = {}
PriestDisciplineSummonTimer.__index = PriestDisciplineSummonTimer
setmetatable(PriestDisciplineSummonTimer, { __index = ERATimer })

---@param hud PriestDisciplineHUD
---@param talent ERALIBTalent
---@param talentBlender ERALIBTalent
---@param talentIncrease ERALIBTalent
---@return PriestDisciplineSummonTimer
function PriestDisciplineSummonTimer:create(hud, talent, talentBlender, talentIncrease)
    local x = {}
    setmetatable(x, PriestDisciplineSummonTimer)
    ---@cast x PriestDisciplineSummonTimer
    x:constructTimer(hud)
    x.talent = talent
    x.talentBlender = talentBlender
    x.talentIncrease = talentIncrease
    x.phud = hud
    x.accIncrease = 0
    return x
end

function PriestDisciplineSummonTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PriestDisciplineSummonTimer:updateData(t)
    local totDur
    if self.talentBlender:PlayerHasTalent() then
        totDur = 12
    else
        totDur = 15
    end
    if self.talentIncrease:PlayerHasTalent() then
        if self.phud.priest_lastIncreaseSummon_penance > self.phud.priest_lastSummon and t - self.phud.priest_lastIncreaseSummon_penance < 1 then
            self.accIncrease = self.accIncrease + 0.7
        end
        self.phud.priest_lastIncreaseSummon_penance = 0

        if self.phud.priest_lastIncreaseSummon_blast > self.phud.priest_lastSummon and t - self.phud.priest_lastIncreaseSummon_blast < 1 then
            self.accIncrease = self.accIncrease + 0.7
        end
        self.phud.priest_lastIncreaseSummon_blast = 0

        if self.phud.priest_lastIncreaseSummon_death > self.phud.priest_lastSummon and t - self.phud.priest_lastIncreaseSummon_death < 1 then
            self.accIncrease = self.accIncrease + 0.7
        end
        self.phud.priest_lastIncreaseSummon_death = 0
    else
        self.phud.priest_lastIncreaseSummon_penance = 0
        self.phud.priest_lastIncreaseSummon_blast = 0
        self.phud.priest_lastIncreaseSummon_death = 0
    end
    self.remDuration = totDur + self.accIncrease - (t - self.phud.priest_lastSummon)
    if self.remDuration < 0 then
        self.remDuration = 0
        self.accIncrease = 0
    end
end

---@class PalaProtHUD : PaladinHUD
---@field pala_lastTyr number
---@field pala_lastHammerTemplar number

---@param cFrame ERACombatFrame
---@param talents PaladinCommonTalents
function ERACombatFrames_PaladinProtectionSetup(cFrame, talents)
    local talent_righteous_hammer = ERALIBTalent:Create(102431)
    local talent_blessed_hammer = ERALIBTalent:Create(102430)
    local talent_normal_hammer = ERALIBTalent:CreateNOR(talent_righteous_hammer, talent_blessed_hammer)
    local talent_redoubt = ERALIBTalent:Create(102462)
    local talent_grand_crusader = ERALIBTalent:Create(102453)
    local talent_shining = ERALIBTalent:Create(102467)
    local talent_long_consecration = ERALIBTalent:Create(102432)
    local talent_ardef = ERALIBTalent:Create(102445)
    local talent_spellwarding = ERALIBTalent:Create(111886)
    local talent_wog_titans = ERALIBTalent:Create(102472)
    local talent_wog_block = ERALIBTalent:Create(102450)
    local talent_sotr_wog_consecration = ERALIBTalent:Create(102444)
    local talent_sotr_heal = ERALIBTalent:Create(115447)
    local talent_sotr_armor = ERALIBTalent:Create(102464)
    local talent_sotr_block = ERALIBTalent:Create(102463)
    local talent_avenging_might = ERALIBTalent:Create(102448)
    local talent_avenging_sanctified = ERALIBTalent:Create(102611)
    local talent_sentinel = ERALIBTalent:Create(102447)
    local talent_any_avenging = ERALIBTalent:CreateAnd(ERALIBTalent:CreateOr(talent_avenging_might, talent_avenging_sanctified, talents.avenging), ERALIBTalent:CreateNot(talent_sentinel))
    local talent_gak = ERALIBTalent:Create(102456)
    local talent_tyr = ERALIBTalent:Create(102466)
    local talent_bastion = ERALIBTalent:Create(102454)
    local talent_finest_hour = ERALIBTalent:Create(102474)
    local htalent_smith_lda = ERALIBTalent:Create(117885)

    local hud = ERACombatFrames_PaladinCommonSetup(cFrame, 2, 223819, ERALIBTalent:Create(115490), false, 386730, ERALIBTalent:Create(102443), talents)
    ---@cast hud PalaProtHUD
    hud.pala_lastTyr = 0
    hud.pala_lastHammerTemplar = 0

    ERACombatFrames_PaladinNonHealerCleanse(hud, talents)

    function hud:pala_castSuccess(t, spellID)
        if spellID == 427453 then
            self.pala_lastHammerTemplar = t
        elseif spellID == 387174 then
            self.pala_lastTyr = t
        end
    end

    --- SAO ---

    local shining = hud:AddTrackedBuff(327510, ERALIBTalent:CreateOr(htalent_smith_lda, talent_shining))
    hud:AddAuraOverlay(shining, 1, 450933, false, "RIGHT", true, false, false, false)

    hud:AddOverlayBasedOnSpellActivation(31935, 450925, false, "LEFT", false, false, false, false, talent_grand_crusader)

    local hTemplarWrath = ERACombatFrames_PaladinTemplar_returnWrath(hud, talents)
    hud:AddAuraOverlay(hTemplarWrath, 1, "talents-animations-class-paladin", true, "MIDDLE", false, false, false, false, nil)--Adventures-Buff-Heal-Burst

    --- bars ---

    local consecrBar = ERACombatFrames_PaladinConsecration(hud, 5, 9, talent_long_consecration)
    local consecrBuff = hud:AddTrackedBuff(188370)
    function consecrBar:ConfirmDurationOverride(t, dur)
        if consecrBuff.remDuration > self.hud.occupied then
            self:SetColor(ERA_Paladin_Consecr_R, ERA_Paladin_Consecr_G, ERA_Paladin_Consecr_B)
        else
            self:SetColor(1.0, 0.0, 0.0)
        end
        return dur
    end

    hud:AddAuraBar(hud:AddTrackedBuff(132403), nil, 0.55, 0.0, 0.25) -- sotr
    hud:AddAuraBar(hud:AddTrackedBuff(280375, talent_redoubt), nil, 0.0, 1.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(31850, talent_ardef), nil, 0.0, 1.0, 0.2)
    hud:AddAuraBar(hud:AddTrackedBuff(86659, talent_gak), nil, 0.0, 0.0, 0.8)
    hud:AddAuraBar(hud:AddTrackedBuff(327193, talent_finest_hour), nil, 1.0, 1.0, 0.0)

    local sentinelDuration = hud:AddTrackedBuff(389539, talent_sentinel)
    hud:AddAuraBar(sentinelDuration, nil, 1.0, 0.0, 1.0)
    local avengingDuration = hud:AddTrackedBuff(31884, talent_any_avenging)
    hud:AddAuraBar(avengingDuration, nil, 1.0, 0.0, 1.0)
    local avengingOrCrusade = hud:AddOrTimer(false, sentinelDuration, avengingDuration)

    local shiningShortBar = hud:AddAuraBar(shining, 133192, 0.5, 1.0, 0.2)
    function shiningShortBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddGenericBar(PaladinTemplarProtectionTimer:create(hud, talents.h_templar), 5342121, 1.0, 1.0, 0.0)

    --- rotation ---

    local crusader = hud:AddRotationCooldown(hud:AddTrackedCooldown(35395, talent_normal_hammer))
    local righteousHammer = hud:AddRotationCooldown(hud:AddTrackedCooldown(53595, talent_righteous_hammer))
    local blessedHammer = hud:AddRotationCooldown(hud:AddTrackedCooldown(204019, talent_blessed_hammer))

    local avenger = hud:AddRotationCooldown(hud:AddTrackedCooldown(31935))

    local judgment = hud:AddRotationCooldown(hud:AddTrackedCooldown(20271))

    local how = hud:AddRotationCooldown(hud:AddTrackedCooldown(24275, talents.how))
    how.checkUsable = true

    local tyr = hud:AddRotationCooldown(hud:AddTrackedCooldown(387174, talent_tyr))

    local toll = hud:AddRotationCooldown(hud.pala_tollCooldown)

    hud:AddRotationStacks(hud:AddTrackedBuff(182104, talent_shining), 3, 2, 133192)

    ERACombatFrames_PaladinLightSmith(hud, talents, 6, 12)

    local bastionBuff = hud:AddTrackedBuff(378974, talent_bastion)
    hud:AddRotationStacks(bastionBuff, 5, 6)
    function hud.pala_holypower:PreUpdateDisplayOverride(t, combat)
        if bastionBuff.remDuration > self.hud.occupied then
            self:SetBorderColor(1.0, 0.0, 0.0)
        else
            self:SetBorderColor(0.7, 0.7, 0.7)
        end
    end

    --[[

    prio

    1 - how
    2 - hammer
    3 - judgment
    4 - avenger
    5 - consecr refresh
    6 - armaments
    7 - hammer charged
    8 - judgment charged
    9 - consecr pretty soon
    10 - tyr
    11 - toll
    12 - armaments charged

    ]]

    function how.onTimer:ComputeDurationOverride(t)
        local dur = self.cd.data.remDuration
        if dur <= 0 then return 0 end
        if dur < avengingOrCrusade.remDuration then
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

    local hammers = {}
    table.insert(hammers, crusader)
    table.insert(hammers, righteousHammer)
    table.insert(hammers, blessedHammer)
    for _, cd in ipairs(hammers) do
        ---@cast cd ERAHUDRotationCooldownIcon
        function cd.onTimer:ComputeAvailablePriorityOverride(t)
            return 2
        end
        function cd.availableChargePriority:ComputeAvailablePriorityOverride(t)
            return 7
        end
    end

    function judgment.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end
    function judgment.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function avenger.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function tyr.onTimer:ComputeAvailablePriorityOverride(t)
        return 10
    end

    function toll.onTimer:ComputeAvailablePriorityOverride(t)
        return 11
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(327193, talent_finest_hour), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(389539, talent_sentinel), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31884, talent_any_avenging), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(378974, talent_bastion), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31850, talent_ardef), hud.defenseGroup, nil, -1)
    ERACombatFrames_PaladinForebearanceCooldown(hud:AddUtilityCooldown(hud:AddTrackedCooldown(204018, talent_spellwarding), hud.defenseGroup))
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(86659, talent_gak), hud.defenseGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(62124), hud.specialGroup) -- taunt
end

---@class PaladinTemplarProtectionTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private phud PalaProtHUD
PaladinTemplarProtectionTimer = {}
PaladinTemplarProtectionTimer.__index = PaladinTemplarProtectionTimer
setmetatable(PaladinTemplarProtectionTimer, { __index = ERATimer })

---@param hud PalaProtHUD
---@param talent ERALIBTalent
---@return PaladinTemplarProtectionTimer
function PaladinTemplarProtectionTimer:create(hud, talent)
    local x = {}
    setmetatable(x, PaladinTemplarProtectionTimer)
    ---@cast x PaladinTemplarProtectionTimer
    x:constructTimer(hud)
    x.talent = talent
    x.phud = hud
    return x
end

function PaladinTemplarProtectionTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PaladinTemplarProtectionTimer:updateData(t)
    if IsSpellOverlayed(427453) then
        local remDur = 12 - (t - self.phud.pala_lastTyr)
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

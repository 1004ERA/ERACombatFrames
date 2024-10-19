---@class PaladinHUD : ERAHUD
---@field pala_holypower ERAHUDModulePointsUnitPower
---@field pala_mana ERAHUDPowerBarModule
---@field pala_purpose ERAAura
---@field pala_forebearance ERAAura
---@field pala_tollCooldown ERACooldown
---@field pala_lastConsecration number
---@field pala_castSuccess nil|fun(this:PaladinHUD, t:number, spellID:integer)
---@field pala_CLEU nil|fun(this:PaladinHUD, t:number, evt:string, spellID:integer)

---@class (exact) PaladinCommonTalents
---@field loh ERALIBTalent
---@field bof ERALIBTalent
---@field how ERALIBTalent
---@field cleanse ERALIBTalent
---@field auras ERALIBTalent
---@field crusaderAura ERALIBTalent
---@field turn ERALIBTalent
---@field steed ERALIBTalent
---@field repent ERALIBTalent
---@field blind ERALIBTalent
---@field kick ERALIBTalent
---@field avenging ERALIBTalent
---@field sacrifice ERALIBTalent
---@field bop ERALIBTalent
---@field toll ERALIBTalent
---@field h_armaments ERALIBTalent
---@field h_rite_sanctification ERALIBTalent
---@field h_rite_adjuration ERALIBTalent
---@field h_aurora ERALIBTalent
---@field h_templar ERALIBTalent
---@field h_templar_wrath ERALIBTalent
---@field h_templar_shake ERALIBTalent
---@field h_templar_deliverance ERALIBTalent

function ERACombatFrames_PaladinSetup(cFrame)
    ERACombatGlobals_SpecID1 = 65
    ERACombatGlobals_SpecID2 = 66
    ERACombatGlobals_SpecID3 = 70

    ERAPieIcon_BorderR = 1.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.5

    ERA_Paladin_Consecr_R = 1.0
    ERA_Paladin_Consecr_G = 0.6
    ERA_Paladin_Consecr_B = 0.1

    local holyOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local protOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local retrOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { holyOptions, protOptions, retrOptions }

    ---@type PaladinCommonTalents
    local talents = {
        loh = ERALIBTalent:Create(102583),
        bof = ERALIBTalent:Create(102587),
        how = ERALIBTalent:Create(102479),
        cleanse = ERALIBTalent:Create(102476),
        auras = ERALIBTalent:Create(102586),
        crusaderAura = ERALIBTalent:Create(102588),
        turn = ERALIBTalent:Create(102623),
        steed = ERALIBTalent:Create(102625),
        repent = ERALIBTalent:Create(102585),
        blind = ERALIBTalent:Create(102584),
        kick = ERALIBTalent:Create(102591),
        avenging = ERALIBTalent:Create(102593),
        sacrifice = ERALIBTalent:Create(102602),
        bop = ERALIBTalent:Create(102604),
        toll = ERALIBTalent:Create(102465),
        h_armaments = ERALIBTalent:Create(117882),
        h_rite_sanctification = ERALIBTalent:Create(117881),
        h_rite_adjuration = ERALIBTalent:Create(117880),
        h_aurora = ERALIBTalent:Create(117666),
        h_templar = ERALIBTalent:Create(117813),
        h_templar_wrath = ERALIBTalent:Create(117820),
        h_templar_shake = ERALIBTalent:Create(117823),
        h_templar_deliverance = ERALIBTalent:Create(117815),
    }

    if (not holyOptions.disabled) then
        ERACombatFrames_PaladinHolySetup(cFrame, talents)
    end
    if (not protOptions.disabled) then
        ERACombatFrames_PaladinProtectionSetup(cFrame, talents)
    end
    if (not retrOptions.disabled) then
        ERACombatFrames_PaladinRetributionSetup(cFrame, talents)
    end
end

---@param cFrame ERACombatFrame
---@param spec integer
---@param purposeID integer
---@param purposeTalent ERALIBTalent
---@param showResonance boolean
---@param resonanceID integer
---@param resonanceTalent ERALIBTalent
---@param talents PaladinCommonTalents
---@return PaladinHUD
function ERACombatFrames_PaladinCommonSetup(cFrame, spec, purposeID, purposeTalent, showResonance, resonanceID, resonanceTalent, talents)
    local hud = ERAHUD:Create(cFrame, 1.5, true, spec == 1, false, spec)
    ---@cast hud PaladinHUD
    hud.pala_lastConsecration = 0

    hud.pala_holypower = ERAHUDModulePointsUnitPower:Create(hud, Enum.PowerType.HolyPower, 0.7, 0.7, 0.7, 1.0, 1.0, 0.5, nil)

    hud.pala_mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, 12, 0.0, 0.0, 1.0, nil)
    hud.pala_mana.hideFullOutOfCombat = true
    if spec == 1 then
        hud.pala_mana.placeAtBottomIfHealer = true
    else
        function hud.pala_mana:ConfirmIsVisibleOverride(t, combat)
            if combat then
                return self.currentPower / self.maxPower <= 0.6
            else
                return self.currentPower / self.maxPower <= 0.5
            end
        end
        function hud.pala_mana:CollapseIfTransparent(t, combat)
            return true
        end
    end

    hud.pala_tollCooldown = hud:AddTrackedCooldown(375576, talents.toll)

    hud.pala_forebearance = hud:AddTrackedDebuffOnSelf(25771, true)

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if sourceGUID == self.cFrame.playerGUID then
            if evt == "SPELL_CAST_SUCCESS" then
                if spellID == 26573 then
                    self.pala_lastConsecration = t
                elseif self.pala_castSuccess then
                    self:pala_castSuccess(t, spellID)
                end
            elseif self.pala_CLEU then
                self:pala_CLEU(t, evt, spellID)
            end
        end
    end

    -- SAO ---

    hud.pala_purpose = hud:AddTrackedBuff(purposeID, ERALIBTalent:CreateOr(talents.h_aurora, purposeTalent))
    hud:AddAuraOverlay(hud.pala_purpose, 1, 459314, false, "TOP", false, false, false, false)

    local concentration = hud:AddTrackedBuffAnyCaster(317920, talents.auras)
    local devotion = hud:AddOrTimer(false, hud:AddTrackedBuffAnyCaster(465, talents.auras), hud:AddTrackedBuffAnyCaster(353101, talents.auras))                     -- by self, by other paladin
    local crusaderAura = hud:AddOrTimer(false, hud:AddTrackedBuffAnyCaster(32223, talents.crusaderAura), hud:AddTrackedBuffAnyCaster(328557, talents.crusaderAura)) -- by self, by other paladin
    local anyAura = hud:AddOrTimer(false, concentration, devotion, crusaderAura)
    hud:AddMissingOverlay(anyAura, false, 450920, false, "BOTTOM", false, false, true, false)

    --- rotation ---

    if showResonance then
        local resonanceTimer = PaladinResonanceTimer:create(hud, resonanceID, resonanceTalent)
        local resonanceIcon = hud:AddPriority(656322, resonanceTalent)
        function resonanceIcon:ComputeDurationOverride(t)
            return resonanceTimer.remDuration
        end
    end

    hud:AddKick(hud:AddTrackedCooldown(96231, talents.kick))

    -- bars ---

    local shortPurpose = hud:AddAuraBar(hud.pala_purpose, nil, 0.96, 0.55, 0.73)
    function shortPurpose:ComputeDurationOverride(t)
        if self.aura.remDuration < 4 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(642), nil, 1.0, 1.0, 1.0) -- bubble
    hud:AddAuraBar(hud:AddTrackedBuff(1022, talents.bop), nil, 0.5, 0.5, 0.5)

    local bofDuration = hud:AddTrackedBuff(1044, talents.bof)
    hud:AddAuraBar(bofDuration, nil, 0.7, 1.0, 0.0)

    -------------------
    --#region STEED ---

    local _, _, race = UnitRace("player")
    local steedID = 276111
    if race == 1 then
        -- human
        steedID = 221883
    elseif race == 3 then
        -- dwarf
        steedID = 276111
    elseif race == 6 then
        -- tauren
        steedID = 221885
    elseif race == 10 then
        -- blood elf
        steedID = 221886
    elseif race == 11 then
        -- draenei
        steedID = 221887
    elseif race == 30 then
        -- lightforged
        steedID = 221887
    elseif race == 31 then
        -- zandalari
        steedID = 294133
    elseif race == 34 then
        -- dark iron dwarf
        steedID = 276112
    elseif race == 84 or race == 85 then
        -- earthen
        steedID = 453804
    end
    local steedDuration = hud:AddTrackedBuff(steedID, talents.steed)
    hud:AddAuraBar(steedDuration, nil, 0.0, 0.3, 1.0)

    --#endregion
    -------------------

    --- utility ---

    local loh = hud:AddUtilityCooldown(hud:AddTrackedCooldown(633, talents.loh), hud.healGroup)

    local bubble = hud:AddUtilityCooldown(hud:AddTrackedCooldown(642), hud.defenseGroup)
    local bop = hud:AddUtilityCooldown(hud:AddTrackedCooldown(1022, talents.bop), hud.defenseGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(6940, talents.sacrifice), hud.specialGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(853), hud.controlGroup) -- stun hammer
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(20066, talents.repent), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115750, talents.blind), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(190784, talents.steed), hud.movementGroup)
    hud:AddUtilityAuraOutOfCombat(steedDuration)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(1044, talents.bof), hud.movementGroup)
    hud:AddUtilityAuraOutOfCombat(bofDuration)

    local forebearanceCooldowns = {}
    table.insert(forebearanceCooldowns, loh)
    table.insert(forebearanceCooldowns, bubble)
    table.insert(forebearanceCooldowns, bop)
    for _, icon in ipairs(forebearanceCooldowns) do
        ERACombatFrames_PaladinForebearanceCooldown(icon)
    end

    return hud
end

---@param hud PaladinHUD
---@param talents PaladinCommonTalents
function ERACombatFrames_PaladinNonHealerCleanse(hud, talents)
    hud:AddUtilityDispell(hud:AddTrackedCooldown(213644, talents.cleanse), hud.specialGroup, nil, nil, nil, false, true, true, false, false)
end

---@param cd ERAHUDUtilityCooldownInGroup
function ERACombatFrames_PaladinForebearanceCooldown(cd)
    function cd:UpdatedOverride(t, combat)
        local hud = self.hud
        ---@cast hud PaladinHUD
        if hud.pala_forebearance.remDuration > 0 then
            self.icon:SetVertexColor(1.0, 0.0, 0.0, 1.0)
        else
            self.icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        end
    end
end

---@param hud PaladinHUD
---@param spellID integer
---@param displayOrder number|nil
---@param level integer
function ERACombatFrames_PaladinDivProt(hud, spellID, displayOrder, level)
    local talent
    if level > 1 then
        talent = ERALIBTalent:CreateLevel(level)
    else
        talent = nil
    end
    hud:AddAuraBar(hud:AddTrackedBuff(spellID, talent), nil, 0.7, 0.6, 0.6)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(spellID, talent), hud.defenseGroup, nil, displayOrder)
end

---@alias PalaSmithType "BULWARK" | "WEAPON"

---@class PalaSmithIcon : ERAHUDRotationCooldownIcon
---@field smith_type PalaSmithType

---@param hud PaladinHUD
---@param talents PaladinCommonTalents
---@param prio number
---@param chargedPrio number
function ERACombatFrames_PaladinLightSmith(hud, talents, prio, chargedPrio)
    local cd = hud:AddTrackedCooldown(432459, talents.h_armaments)

    local icon = hud:AddRotationCooldown(cd, nil, nil)
    ---@cast icon PalaSmithIcon
    icon.smith_type = "BULWARK"
    function icon:UpdatedOverride(t, combat)
        local requiredIconID = C_Spell.GetSpellInfo(432459).iconID
        if requiredIconID == 432459 then
            self.smith_type = "BULWARK"
        else
            self.smith_type = "WEAPON"
        end
        self:setIconID(requiredIconID)
    end
    function icon.onTimer:ComputeAvailablePriorityOverride(t)
        return prio
    end
    function icon.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return chargedPrio
    end
    icon.icon:SetOverlayAlpha(0.7)

    hud:AddAuraBar(hud:AddTrackedBuff(432496, talents.h_armaments), nil, 0.7, 0.4, 0.0)
    hud:AddAuraBar(hud:AddTrackedBuff(432502, talents.h_armaments), nil, 0.7, 0.4, 0.0)

    hud:AddMissingOverlay(hud:AddTrackedBuff(433550, talents.h_rite_sanctification), false, 450923, false, "BOTTOM", false, true, false, false):SetVertexColor(0.7, 0.4, 0.0)
    hud:AddMissingOverlay(hud:AddTrackedBuff(433584, talents.h_rite_adjuration), false, 450923, false, "BOTTOM", false, true, false, false):SetVertexColor(0.7, 0.4, 0.0)
end

---@param hud PaladinHUD
---@param talents PaladinCommonTalents
---@return ERAAura
function ERACombatFrames_PaladinTemplar_returnWrath(hud, talents)
    hud:AddAuraBar(hud:AddTrackedBuff(431536, talents.h_templar_shake), nil, 1.0, 1.0, 0.7)
    return hud:AddTrackedBuff(452244, talents.h_templar_wrath)
end

---@class PaladinResonanceTimer : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent
---@field private aura ERAAura
PaladinResonanceTimer = {}
PaladinResonanceTimer.__index = PaladinResonanceTimer
setmetatable(PaladinResonanceTimer, { __index = ERATimer })

---@param hud PaladinHUD
---@param resonanceID integer
---@param talent ERALIBTalent
---@return PaladinResonanceTimer
function PaladinResonanceTimer:create(hud, resonanceID, talent)
    local x = {}
    setmetatable(x, PaladinResonanceTimer)
    ---@cast x PaladinResonanceTimer
    x:constructTimer(hud)
    x.talent = talent
    x.aura = hud:AddTrackedBuff(resonanceID, talent)
    return x
end

function PaladinResonanceTimer:checkDataItemTalent()
    return self.talent:PlayerHasTalent()
end

---@param t number
function PaladinResonanceTimer:updateData(t)
    local dur = self.aura.remDuration
    if dur > 0 then
        while dur > 5 do
            dur = dur - 5
        end
        self.remDuration = dur
    else
        self.remDuration = 0
    end
end

--------------------------
--#region CONSECRATION ---

---@class PaladinConsecrationTimer : ERATimer
---@field private __index unknown
---@field private talent_long_consecration nil|ERALIBTalent
---@field private phud PaladinHUD
PaladinConsecrationTimer = {}
PaladinConsecrationTimer.__index = PaladinConsecrationTimer
setmetatable(PaladinConsecrationTimer, { __index = ERATimer })

---@param hud PaladinHUD
---@param talent_long_consecration nil|ERALIBTalent
---@return PaladinConsecrationTimer
function PaladinConsecrationTimer:create(hud, talent_long_consecration)
    local x = {}
    setmetatable(x, PaladinConsecrationTimer)
    ---@cast x PaladinConsecrationTimer
    x:constructTimer(hud)
    x.talent_long_consecration = talent_long_consecration
    x.phud = hud
    return x
end

function PaladinConsecrationTimer:checkDataItemTalent()
    return true
end

---@param t number
function PaladinConsecrationTimer:updateData(t)
    local totDur
    if self.talent_long_consecration and self.talent_long_consecration:PlayerHasTalent() then
        totDur = 14
    else
        totDur = 12
    end
    local remDur = totDur - (t - self.phud.pala_lastConsecration)
    if remDur > 0 then
        self.remDuration = remDur
    else
        self.remDuration = 0
    end
end

---@param hud PaladinHUD
---@param consecrRefreshPrio number
---@param consecrSoonPrio number
---@param talent_long_consecration ERALIBTalent|nil
---@return ERAHUDGenericBar
function ERACombatFrames_PaladinConsecration(hud, consecrRefreshPrio, consecrSoonPrio, talent_long_consecration)
    local consecrBar = hud:AddGenericBar(PaladinConsecrationTimer:create(hud, talent_long_consecration), 135926, ERA_Paladin_Consecr_R, ERA_Paladin_Consecr_G, ERA_Paladin_Consecr_B)

    local consecrCooldown = hud:AddTrackedCooldown(26573)
    local consecrIcon = hud:AddPriority(135926)
    function consecrIcon:ComputeDurationOverride(t)
        if consecrCooldown.remDuration > consecrBar.timer.remDuration then
            return consecrCooldown.remDuration
        else
            return 0
        end
    end
    function consecrIcon:ComputeAvailablePriorityOverride(t)
        if consecrCooldown.remDuration > 0 then
            return 0
        else
            local cdur = consecrBar.timer.remDuration
            if cdur <= self.hud.occupied + 0.2 then
                return consecrRefreshPrio
            elseif cdur <= 2.1 * self.hud.totGCD then
                return consecrSoonPrio
            else
                return 0
            end
        end
    end

    return consecrBar
end

--#endregion
--------------------------

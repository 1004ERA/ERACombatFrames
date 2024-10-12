---@class PaladinHUD : ERAHUD
---@field pala_holypower ERAHUDModulePointsUnitPower
---@field pala_mana ERAHUDPowerBarModule
---@field pala_purpose ERAAura
---@field pala_forebearance ERAAura
---@field pala_tollCooldown ERACooldown

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

    hud.pala_forebearance = hud:AddTrackedDebuffOnSelf(25771)

    -- SAO ---

    hud.pala_purpose = hud:AddTrackedBuff(purposeID, purposeTalent)
    hud:AddAuraOverlay(hud.pala_purpose, 1, 459314, false, "TOP", false, false, false, false)

    local concentration = hud:AddTrackedBuff(317920, talents.auras)
    local devotion = hud:AddTrackedBuff(465, talents.auras)
    local crusaderAura = hud:AddTrackedBuff(32223, talents.crusaderAura)
    local anyAura = hud:AddOrTimer(false, concentration, devotion, crusaderAura)
    hud:AddMissingTimerOverlay(anyAura, false, 450920, false, "BOTTOM", false, false, true, false)

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

    local steedDuration = hud:AddTrackedBuff(294133, talents.steed)
    hud:AddAuraBar(steedDuration, nil, 0.0, 0.3, 1.0)
    local bofDuration = hud:AddTrackedBuff(1044, talents.bof)
    hud:AddAuraBar(bofDuration, nil, 0.7, 1.0, 0.0)

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
---@param displayOrder number|nil
function ERACombatFrames_PaladinDivProt(hud, displayOrder)
    local talent_divprot = ERALIBTalent:CreateLevel(26)
    hud:AddAuraBar(hud:AddTrackedBuff(498, talent_divprot), nil, 0.7, 0.6, 0.6)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(498, talent_divprot), hud.defenseGroup, nil, displayOrder)
end

---@param hud PaladinHUD
---@param timer ERATimer
---@param refreshPrio number
---@param soonPrio number
function ERACombatFrames_PaladinConsecration(hud, timer, refreshPrio, soonPrio)

    local consecrBar = hud:AddGenericBar(timer, 135926, ERA_Paladin_Consecr_R, ERA_Paladin_Consecr_G, ERA_Paladin_Consecr_B)

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
                return 5
            elseif cdur <= 2.1 * self.hud.totGCD then
                return 8
            else
                return 0
            end
        end
    end
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

---@class (exact) DruidCommonTalents
---@field regen ERALIBTalent
---@field ironfur ERALIBTalent
---@field soothe ERALIBTalent
---@field skullbash ERALIBTalent
---@field maim ERALIBTalent
---@field charge ERALIBTalent
---@field dash ERALIBTalent
---@field tigerdash ERALIBTalent
---@field stampeding ERALIBTalent
---@field entanglement ERALIBTalent
---@field vortex ERALIBTalent
---@field typhoon ERALIBTalent
---@field roar ERALIBTalent
---@field bash ERALIBTalent
---@field renewal ERALIBTalent
---@field vigil ERALIBTalent
---@field innerv ERALIBTalent
---@field wild ERALIBTalent

---@class DruidHUD : ERAHUD
---@field rage ERAHUDPowerBarModule
---@field nrg ERAHUDPowerBarModule
---@field combo ERAHUDModulePointsUnitPower
---@field mana ERAHUDPowerBarModule
---@field catForm ERAAura
---@field bearForm ERAAura

---@param cFrame ERACombatFrame
function ERACombatFrames_DruidSetup(cFrame)
    ERACombatGlobals_SpecID1 = 102
    ERACombatGlobals_SpecID2 = 103
    ERACombatGlobals_SpecID3 = 104
    ERACombatGlobals_SpecID4 = 105

    ERA_Druid_Rejuv_R = 1.0
    ERA_Druid_Rejuv_G = 0.6
    ERA_Druid_Rejuv_B = 1.0

    ERA_Druid_Regro_R = 0.2
    ERA_Druid_Regro_G = 1.0
    ERA_Druid_Regro_B = 0.6

    local mkOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local ctOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local brOptions = ERACombatOptions_getOptionsForSpec(nil, 3)
    local trOptions = ERACombatOptions_getOptionsForSpec(nil, 4)

    cFrame.hideAlertsForSpec = { mkOptions, ctOptions, brOptions, trOptions }

    ---@type DruidCommonTalents
    local druidTalents = {
        regen = ERALIBTalent:Create(103298),
        ironfur = ERALIBTalent:Create(103305),
        soothe = ERALIBTalent:Create(103307),
        skullbash = ERALIBTalent:Create(103302),
        maim = ERALIBTalent:Create(103299),
        charge = ERALIBTalent:Create(103276),
        dash = ERALIBTalent:CreateNotTalent(103275),
        tigerdash = ERALIBTalent:Create(103275),
        stampeding = ERALIBTalent:Create(103312),
        entanglement = ERALIBTalent:Create(103322),
        vortex = ERALIBTalent:Create(103321),
        typhoon = ERALIBTalent:Create(103287),
        roar = ERALIBTalent:Create(103316),
        bash = ERALIBTalent:Create(103315),
        renewal = ERALIBTalent:Create(103310),
        vigil = ERALIBTalent:Create(103324),
        innerv = ERALIBTalent:Create(103323),
        wild = ERALIBTalent:Create(103309),
    }

    if (not mkOptions.disabled) then
        ERACombatFrames_DruidMoonkinSetup(cFrame, druidTalents)
    end
    if (not ctOptions.disabled) then
        ERACombatFrames_DruidFeralSetup(cFrame, druidTalents)
    end
    if (not brOptions.disabled) then
        ERACombatFrames_DruidGuardianSetup(cFrame, druidTalents)
    end
    if (not trOptions.disabled) then
        ERACombatFrames_DruidRestorationSetup(cFrame, druidTalents)
    end
end

---@param cFrame ERACombatFrame
---@param spec integer
---@param talents DruidCommonTalents
---@param talent_dispell ERALIBTalent|nil
---@return DruidHUD
function ERACombatFrames_Druid_CommonSetup(cFrame, spec, talents, talent_dispell)
    local baseGCD
    if spec == 2 then
        baseGCD = 1.0
    else
        baseGCD = 1.5
    end

    local hud = ERAHUD:Create(cFrame, baseGCD, true, spec == 4, false, spec)
    ---@cast hud DruidHUD

    hud.catForm = hud:AddTrackedBuff(768)
    hud.bearForm = hud:AddTrackedBuff(5487)

    hud:AddOffensiveDispell(hud:AddTrackedCooldown(2908, talents.soothe), nil, nil, false, true)
    hud:AddKick(hud:AddTrackedCooldown(106839, talents.skullbash))

    local collapsingBars = {}

    ------------------
    --#region BEAR ---

    hud.rage = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Rage, 14, 1.0, 0.0, 0.0, nil)
    function hud.rage:ConfirmIsVisibleOverride(t, combat)
        local dhud = self.hud
        ---@cast dhud DruidHUD
        if dhud.bearForm.remDuration > 0 then
            return combat or self.currentPower > 0
        else
            return false
        end
    end

    hud.rage.bar:AddMarkingFrom0(40)

    --#endregion
    ------------------

    -----------------
    --#region CAT ---

    hud.combo = ERAHUDModulePointsUnitPower:Create(hud, Enum.PowerType.ComboPoints, 0.5, 0.2, 0.0, 1.0, 0.1, 0.0, nil)
    if spec ~= 2 then
        function hud.combo:ConfirmIsVisibleOverride(t, combat)
            local dhud = self.hud
            ---@cast dhud DruidHUD
            return dhud.catForm.remDuration > 0
        end
        function hud.combo:CollapseIfTransparent(t, combat)
            return true
        end
    end

    hud.nrg = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Energy, 14, 1.0, 1.0, 0.0, nil)
    hud.nrg.hideFullOutOfCombat = true
    function hud.nrg:ConfirmIsVisibleOverride(t, combat)
        local dhud = self.hud
        ---@cast dhud DruidHUD
        if dhud.catForm.remDuration > 0 then
            return combat or self.currentPower > 0
        else
            return false
        end
    end

    hud.nrg.bar:AddMarkingFrom0(40)

    local biteMark = hud.nrg.bar:AddMarkingFrom0(50)
    function biteMark:ComputeValueOverride(t)
        if hud.combo.currentPoints >= 5 then
            return 50
        else
            return -1
        end
    end

    --#endregion
    -----------------

    ------------------
    --#region HEAL ---

    hud.mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, 12, 0.0, 0.0, 1.0, nil)
    if spec == 4 then
        hud.mana.hideFullOutOfCombat = true
        hud.mana.placeAtBottomIfHealer = true
    else
        function hud.mana:ConfirmIsVisibleOverride(t, combat)
            if combat then
                return self.currentPower / self.maxPower <= 0.6
            else
                return self.currentPower / self.maxPower <= 0.7
            end
        end
        table.insert(collapsingBars, hud.mana)
    end

    --#endregion
    ------------------

    table.insert(collapsingBars, hud.rage)
    table.insert(collapsingBars, hud.nrg)
    for _, b in ipairs(collapsingBars) do
        function b:CollapseIfTransparent(t, combat)
            return true
        end
    end

    ------------------
    --#region BARS ---

    hud:AddAuraBar(hud:AddTrackedBuff(22812), nil, 0.7, 0.6, 0.0) -- bark

    hud:AddAuraBar(hud:AddTrackedBuff(192081, talents.ironfur), nil, 0.6, 0.6, 0.5)

    hud:AddAuraBar(hud:AddTrackedBuff(124974, talents.vigil), nil, 0.0, 0.5, 0.0)

    hud:AddAuraBar(hud:AddTrackedBuff(319454, talents.wild), nil, 1.0, 1.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(774), nil, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B)

    --#endregion
    ------------------

    ---------------------
    --#region UTILITY ---

    hud:AddEmptyTimer(hud:AddBuffOnAllPartyMembers(1126), 8, 136078, ERALIBTalent:CreateLevel(9))

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(124974, talents.vigil), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108238, talents.renewal), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(22842, talents.regen), hud.healGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(319454, talents.wild), hud.powerUpGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(22812), hud.defenseGroup) -- bark

    if talent_dispell then
        hud:AddUtilityDispell(hud:AddTrackedCooldown(2782, talent_dispell), hud.specialGroup, nil, nil, nil, false, true, false, true, false)
    end
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(29166, talents.innerv), hud.specialGroup)

    local maimCooldown = hud:AddTrackedCooldown(22570, talents.maim)
    local maimIcon = hud:AddUtilityCooldown(maimCooldown, hud.controlGroup)
    if spec ~= 2 then
        maimCooldown.mustRedrawUtilityLayoutIfChangedStatus = true
        function maimIcon:ConfirmShowOverride()
            local mhud = self.hud
            ---@cast mhud DruidHUD
            return mhud.catForm.remDuration > 0 or self.data.remDuration > 0
        end
    end

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(5211, talents.bash), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(99, talents.roar), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(132469, talents.typhoon), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102793, talents.vortex), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102359, talents.entanglement), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102401, talents.charge), hud.movementGroup, 538771)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(1850, talents.dash), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(252216, talents.tigerdash), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(106898, talents.stampeding), hud.movementGroup)

    --#endregion
    ---------------------

    return hud
end

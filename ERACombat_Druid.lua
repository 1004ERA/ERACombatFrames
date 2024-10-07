---@class (exact) DruidCommonTalents
---@field regen ERALIBTalent
---@field ironfur ERALIBTalent
---@field growth ERALIBTalent
---@field surge ERALIBTalent
---@field sunfire ERALIBTalent
---@field rake ERALIBTalent
---@field rip ERALIBTalent
---@field thrash ERALIBTalent
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
---@field rageMark ERAHUDStatusMarkingFrom0
---@field wildBuff ERAAura
---@field wildCooldown ERACooldown
---@field lastSurge number
---@field surgeCooldown ERACooldown
---@field lastMangle number
---@field mangleCooldown ERACooldown
---@field lastThrash number
---@field thrashCooldown ERACooldown
---@field lastGrowth number
---@field growthCooldown ERACooldown
---@field getLastSurge fun(this:DruidHUD): number
---@field getLastThrash fun(this:DruidHUD): number
---@field getLastMangle fun(this:DruidHUD): number
---@field getLastGrowth fun(this:DruidHUD): number

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

    ERA_Druid_IrFur_R = 0.6
    ERA_Druid_IrFur_G = 0.6
    ERA_Druid_IrFur_B = 0.5

    ERA_Druid_Thras_R = 0.7
    ERA_Druid_Thras_G = 0.5
    ERA_Druid_Thras_B = 0.3
    ERA_Druid_Rake_R = 1.0
    ERA_Druid_Rake_G = 0.0
    ERA_Druid_Rake_B = 0.0
    ERA_Druid_Rip_R = 1.0
    ERA_Druid_Rip_G = 0.0
    ERA_Druid_Rip_B = 1.0

    ERA_Druid_MoonF_R = 0.0
    ERA_Druid_MoonF_G = 0.0
    ERA_Druid_MoonF_B = 1.0
    ERA_Druid_SunF_R = 1.0
    ERA_Druid_SunF_G = 0.0
    ERA_Druid_SunF_B = 0.0

    ERA_Druid_Vine_R = 0.0
    ERA_Druid_Vine_G = 0.5
    ERA_Druid_Vine_B = 1.0

    local mkOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local ctOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local brOptions = ERACombatOptions_getOptionsForSpec(nil, 3)
    local trOptions = ERACombatOptions_getOptionsForSpec(nil, 4)

    cFrame.hideAlertsForSpec = { mkOptions, ctOptions, brOptions, trOptions }

    ---@type DruidCommonTalents
    local druidTalents = {
        regen = ERALIBTalent:Create(103298),
        ironfur = ERALIBTalent:Create(103305),
        growth = ERALIBTalent:Create(103320),
        surge = ERALIBTalent:Create(103278),
        sunfire = ERALIBTalent:Create(103286),
        rake = ERALIBTalent:Create(103277),
        rip = ERALIBTalent:Create(103300),
        thrash = ERALIBTalent:Create(103301),
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
---@param talent_bonus_wild ERALIBTalent|nil
---@return DruidHUD
function ERACombatFrames_Druid_CommonSetup(cFrame, spec, talents, talent_dispell, talent_bonus_wild)
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

    ----------------------
    --#region OFF-SPEC ---

    hud.lastSurge = 0
    hud.surgeCooldown = hud:AddTrackedCooldown(197626, talents.surge)
    hud.lastMangle = 0
    hud.mangleCooldown = hud:AddTrackedCooldown(33917)
    hud.lastThrash = 0
    hud.thrashCooldown = hud:AddTrackedCooldown(77758, talents.thrash)
    hud.lastGrowth = 0
    hud.growthCooldown = hud:AddTrackedCooldown(48438, talents.growth)

    function hud:getLastSurge() return self.lastSurge end
    function hud:getLastMangle() return self.lastMangle end
    function hud:getLastThrash() return self.lastThrash end
    function hud:getLastGrowth() return self.lastGrowth end

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUID == self.cFrame.playerGUID and evt == "SPELL_CAST_SUCCESS") then
            if (spellID == self.surgeCooldown.spellID) then
                self.lastSurge = t
            elseif (spellID == self.mangleCooldown.spellID) then
                self.lastMangle = t
            elseif (spellID == self.thrashCooldown.spellID) then
                self.lastThrash = t
            elseif (spellID == self.growthCooldown.spellID) then
                self.lastGrowth = t
            end
        end
    end

    --#endregion
    ----------------------

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

    hud.rageMark = hud.rage.bar:AddMarkingFrom0(40)

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

    hud:AddAuraBar(hud:AddTrackedBuff(192081, talents.ironfur), nil, ERA_Druid_IrFur_R, ERA_Druid_IrFur_G, ERA_Druid_IrFur_B)
    hud:AddAuraBar(hud:AddTrackedBuff(22842, talents.regen), nil, 0.5, 1.0, 0.0)

    hud:AddAuraBar(hud:AddTrackedBuff(124974, talents.vigil), nil, 0.0, 0.5, 0.0)

    if talent_bonus_wild then
        hud.wildBuff = hud:AddTrackedBuff(319454, ERALIBTalent:CreateOr(talents.wild, talent_bonus_wild))
    else
        hud.wildBuff = hud:AddTrackedBuff(319454, talents.wild)
    end
    hud:AddAuraBar(hud.wildBuff, nil, 1.0, 0.9, 0.5)

    local rejuvOnSelf = hud:AddTrackedBuff(774)
    hud:AddAuraBar(rejuvOnSelf, nil, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B)

    --#endregion
    ------------------

    ---------------------
    --#region UTILITY ---

    hud:AddUtilityAuraOutOfCombat(rejuvOnSelf)

    hud:AddEmptyTimer(hud:AddBuffOnAllPartyMembers(1126), 8, 136078, ERALIBTalent:CreateLevel(9))

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(124974, talents.vigil), hud.healGroup, nil, nil, nil, function(cd, t) return cd.hud.health.currentHealth / cd.hud.health.maxHealth <= 0.8 end)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108238, talents.renewal), hud.healGroup, nil, nil, nil, function(cd, t) return cd.hud.health.currentHealth / cd.hud.health.maxHealth <= 0.7 end)
    if spec ~= 3 then
        hud:AddUtilityCooldown(hud:AddTrackedCooldown(22842, talents.regen), hud.healGroup, nil, nil, nil, function(cd, t) return cd.hud.health.currentHealth / cd.hud.health.maxHealth <= 0.7 end)
    end

    hud.wildCooldown = hud:AddTrackedCooldown(319454, talents.wild)
    hud:AddUtilityCooldown(hud.wildCooldown, hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(22812), hud.defenseGroup, nil, nil, nil, function(cd, t) return cd.hud.health.currentHealth / cd.hud.health.maxHealth <= 0.7 end) -- bark

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

----------------------
--#region OFF-SPEC ---

---@param hud DruidHUD
---@param prio number
---@param cd ERACooldownBase
---@param iconID integer
---@param getter fun(h:DruidHUD): number
---@param form nil|ERAAura
---@param talent nil|ERALIBTalent
function ERACombatFrames_Druid_OffSpecTimer(hud, prio, cd, iconID, getter, form, talent)
    local item = hud:AddPriority(iconID, talent)
    function item:ComputeDurationOverride(t)
        return cd.remDuration
    end
    function item:ComputeAvailablePriorityOverride(t)
        if ((not form) or form.remDuration > 0) and t - getter(hud) - cd.totDuration < 6 then
            return prio
        else
            return 0
        end
    end

    local unavailable = hud:AddPriority(iconID, talent)
    function unavailable:ComputeAvailablePriorityOverride(t)
        if ((not form) or form.remDuration > 0) and t - getter(hud) - cd.totDuration < 6 and cd.remDuration > self.hud.timerDuration then
            self.icon:SetVertexColor(1.0, 0.0, 0.0, 1.0)
            return prio
        else
            return 0
        end
    end
end

---@class OffSpecDOT : ERAAura
---@field druid_lastActive number

---@param hud DruidHUD
---@param spellID integer
---@param r number
---@param g number
---@param b number
---@param missingTexture integer|string
---@param isAtlas boolean
---@param displayMissingBasedOnRecent boolean
---@param form nil|ERAAura
---@param talent nil|ERALIBTalent
---@param rotateLeft boolean
---@param rotateRight boolean
---@return ERASAO
function ERACombatFrames_Druid_OffSpecDOT(hud, spellID, duration, showFullDuration, r, g, b, missingTexture, isAtlas, displayMissingBasedOnRecent, form, talent, rotateLeft, rotateRight)
    local debuff = hud:AddTrackedDebuffOnTarget(spellID, talent)
    ---@cast debuff OffSpecDOT
    debuff.druid_lastActive = 0

    local bar = hud:AddAuraBar(debuff, nil, r, g, b)
    if showFullDuration then
        bar.overrideShowStacks = true
        function bar:ComputeDurationOverride(t)
            if self.aura.remDuration > 0 then
                debuff.druid_lastActive = t
                local untilRefresh = self.aura.remDuration - (duration * 0.3 - 1)
                if untilRefresh < 0 then
                    self:SetIconDesaturated(false)
                    self:SetText(nil)
                else
                    self:SetIconDesaturated(true)
                    self:SetText(tostring(math.ceil(untilRefresh)))
                end
                return self.aura.remDuration
            else
                return 0
            end
        end
    else
        function bar:ComputeDurationOverride(t)
            if self.aura.remDuration > 0 then
                debuff.druid_lastActive = t
                if self.aura.remDuration < duration * 0.3 - 1 and ((not form) or form.remDuration > 0) then
                    return self.aura.remDuration
                else
                    return 0
                end
            else
                return 0
            end
        end
    end

    local missing = hud:AddMissingTimerOverlay(debuff, true, missingTexture, isAtlas, "MIDDLE", false, false, rotateLeft, rotateRight)
    if displayMissingBasedOnRecent then
        function missing:ConfirmIsActiveOverride(t, combat)
            if form and form.remDuration <= 0 then return false end
            return t - debuff.druid_lastActive < 5
        end
    else
        function missing:ConfirmIsActiveOverride(t, combat)
            return (not form) or form.remDuration > 0
        end
    end

    return missing
end

---@param hud DruidHUD
---@param talents DruidCommonTalents
---@param showMoonfire ERALIBTalent
function ERACombatFrames_Druid_NonBalance(hud, talents, showMoonfire)
    ERACombatFrames_Druid_OffSpecTimer(hud, 102, hud.surgeCooldown, 135730, hud.getLastSurge, nil, talents.surge)
    local moonfireSAO = ERACombatFrames_Druid_OffSpecDOT(hud, 164812, 18, false, ERA_Druid_MoonF_R, ERA_Druid_MoonF_G, ERA_Druid_MoonF_B, 450920, false, true, nil, showMoonfire, false, true)
    moonfireSAO:SetVertexColor(ERA_Druid_MoonF_R, ERA_Druid_MoonF_G, ERA_Druid_MoonF_B)
    local sunfireSAO = ERACombatFrames_Druid_OffSpecDOT(hud, 164815, 18, false, ERA_Druid_SunF_R, ERA_Druid_SunF_G, ERA_Druid_SunF_B, 450921, false, true, nil, nil, true, false)
    sunfireSAO:SetVertexColor(ERA_Druid_SunF_R, ERA_Druid_SunF_G, ERA_Druid_SunF_B)
end
---@param hud DruidHUD
---@param talents DruidCommonTalents
function ERACombatFrames_Druid_NonFeral(hud, talents)
    local ripSAO = ERACombatFrames_Druid_OffSpecDOT(hud, 1079, 24, true, ERA_Druid_Rip_R, ERA_Druid_Rip_G, ERA_Druid_Rip_B, 450919, false, false, hud.catForm, talents.rip, true, false)
    ripSAO:SetVertexColor(ERA_Druid_Rip_R, ERA_Druid_Rip_G, ERA_Druid_Rip_B)
    local rakeSAO = ERACombatFrames_Druid_OffSpecDOT(hud, 155722, 15, false, ERA_Druid_Rake_R, ERA_Druid_Rake_G, ERA_Druid_Rake_B, 450923, false, false, hud.catForm, talents.rake, false, false)
    rakeSAO:SetVertexColor(ERA_Druid_Rake_R, ERA_Druid_Rake_G, ERA_Druid_Rake_B)
    local thrashSAO = ERACombatFrames_Druid_OffSpecDOT(hud, 405233, 15, false, ERA_Druid_Thras_R, ERA_Druid_Thras_G, ERA_Druid_Thras_B, 450917, false, false, hud.catForm, talents.thrash, true, false)
    thrashSAO:SetVertexColor(ERA_Druid_Thras_R, ERA_Druid_Thras_G, ERA_Druid_Thras_B)
end
---@param hud DruidHUD
---@param talents DruidCommonTalents
function ERACombatFrames_Druid_NonGuardian(hud, talents)
    ERACombatFrames_Druid_OffSpecTimer(hud, 100, hud.mangleCooldown, 132135, hud.getLastMangle, hud.bearForm, talents.thrash)
    ERACombatFrames_Druid_OffSpecTimer(hud, 101, hud.thrashCooldown, 451161, hud.getLastThrash, hud.bearForm, talents.thrash)
end
---@param hud DruidHUD
---@param talents DruidCommonTalents
function ERACombatFrames_Druid_NonRestoration(hud, talents)
    ERACombatFrames_Druid_OffSpecTimer(hud, 103, hud.growthCooldown, 236153, hud.getLastGrowth, nil, talents.growth)
end

--#endregion
----------------------

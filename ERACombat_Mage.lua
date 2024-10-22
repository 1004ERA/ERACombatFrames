---@class (exact) ERACombat_MageCommonTalents
---@field iblock ERALIBTalent
---@field steal ERALIBTalent
---@field dispell ERALIBTalent
---@field mirror ERALIBTalent
---@field fae ERALIBTalent
---@field alter ERALIBTalent
---@field slow ERALIBTalent
---@field rof ERALIBTalent
---@field nova ERALIBTalent
---@field shimmer ERALIBTalent
---@field blink ERALIBTalent
---@field floes ERALIBTalent
---@field wave ERALIBTalent
---@field dragon ERALIBTalent
---@field supernova ERALIBTalent
---@field displacement ERALIBTalent
---@field invis ERALIBTalent
---@field greaterInvis ERALIBTalent
---@field massSheep ERALIBTalent
---@field massInvis ERALIBTalent
---@field massBarrier ERALIBTalent

---@class MageHUD : ERAHUD
---@field mage_mana ERAHUDPowerBarModule
---@field mage_lastDamageTaken number

---@param cFrame ERACombatFrame
function ERACombatFrames_MageSetup(cFrame)
    ERACombatGlobals_SpecID1 = 62
    ERACombatGlobals_SpecID2 = 63
    ERACombatGlobals_SpecID3 = 64

    local arcaneOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local fireOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local frostOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { arcaneOptions }

    ---@type ERACombat_MageCommonTalents
    local talents = {
        iblock = ERALIBTalent:Create(80181),
        steal = ERALIBTalent:Create(80140),
        dispell = ERALIBTalent:Create(80175),
        mirror = ERALIBTalent:Create(80183),
        fae = ERALIBTalent:Create(80171),
        alter = ERALIBTalent:Create(80174),
        slow = ERALIBTalent:Create(80154),
        rof = ERALIBTalent:Create(80144),
        nova = ERALIBTalent:Create(125820),
        shimmer = ERALIBTalent:Create(80163),
        blink = ERALIBTalent:CreateNotTalent(80163),
        floes = ERALIBTalent:Create(80162),
        wave = ERALIBTalent:Create(80160),
        dragon = ERALIBTalent:Create(125819),
        supernova = ERALIBTalent:Create(125818),
        displacement = ERALIBTalent:Create(80152),
        invis = ERALIBTalent:CreateNotTalent(115877),
        greaterInvis = ERALIBTalent:Create(115877),
        massSheep = ERALIBTalent:Create(80164),
        massInvis = ERALIBTalent:Create(115878),
        massBarrier = ERALIBTalent:Create(125817),
    }

    if (not arcaneOptions.disabled) then
        ERACombatFrames_MageArcaneSetup(cFrame, talents)
    end
    if (not fireOptions.disabled) then
        --ERACombatFrames_MageFireSetup(cFrame, talents)
    end
    if (not frostOptions.disabled) then
        --ERACombatFrames_MageFrostSetup(cFrame, talents)
    end
end

---@param cFrame ERACombatFrame
---@param talents ERACombat_MageCommonTalents
---@param spec integer
---@param barrierID integer
---@return MageHUD
function ERACombatFrames_MageCommonSetup(cFrame, talents, spec, barrierID)
    local hud = ERAHUD:Create(cFrame, 1.5, true, false, false, spec)
    ---@cast hud MageHUD
    hud.mage_lastDamageTaken = 0

    if spec ~= 1 then
        hud.mage_mana = ERAHUDPowerBarModule:Create(hud, 0, 12, 0.0, 0.0, 1.0)
        hud.mage_mana.hideFullOutOfCombat = true
        function hud.mage_mana:ConfirmIsVisibleOverride(t, combat)
            if combat then
                return self.currentPower / self.maxPower <= 0.6
            else
                return self.currentPower / self.maxPower <= 0.5
            end
        end
        function hud.mage_mana:CollapseIfTransparent(t, combat)
            return true
        end
    end

    function hud:AdditionalCLEU(t)
        local _, evt, _, _, _, _, _, tarGUID = CombatLogGetCurrentEventInfo()
        if tarGUID == self.cFrame.playerGUID and (evt == "SPELL_DAMAGE" or evt == "SWING_DAMAGE") then
            self.mage_lastDamageTaken = t
        end
    end

    --- bars ---

    local displacementCooldown = hud:AddTrackedCooldown(389713, talents.displacement)
    local invis_progress_duration = hud:AddTrackedBuff(66, talents.invis)
    local invisDuration = hud:AddTrackedBuff(32612, talents.invis)
    local greaterInvisDuration = hud:AddTrackedBuff(110959, talents.greaterInvis)

    hud:AddAuraBar(invis_progress_duration, 135994, 0.5, 0.5, 0.5)
    hud:AddAuraBar(invisDuration, nil, 0.7, 0.7, 0.7)
    hud:AddAuraBar(greaterInvisDuration, nil, 0.7, 0.7, 0.7)

    hud:AddAuraBar(hud:AddTrackedBuff(45438, talents.iblock), nil, 0.5, 0.5, 1.0)
    hud:AddAuraBar(hud:AddTrackedBuff(342246, talents.alter), nil, 1.0, 0.8, 0.2)
    hud:AddAuraBar(hud:AddTrackedBuff(108839, talents.floes), nil, 0.5, 1.0, 0.8)

    --- rotation ---

    hud:AddKick(hud:AddTrackedCooldown(2139))
    hud:AddOffensiveDispell(hud:AddTrackedCooldown(30449, talents.steal), nil, nil, true, false)

    local barrierCooldown = hud:AddTrackedCooldown(barrierID)
    local barrierPrio = hud:AddPriority(C_Spell.GetSpellInfo(barrierID).iconID)
    function barrierPrio:ComputeDurationOverride(t)
        return barrierCooldown.remDuration
    end
    function barrierPrio:ComputeAvailablePriorityOverride(t)
        local hud = self.hud
        ---@cast hud MageHUD
        if hud.mage_lastDamageTaken > 0 and t - hud.mage_lastDamageTaken > 32 then
            return 0
        else
            return 100
        end
    end

    --- utility ---

    hud:AddMissingUtility(hud:AddBuffOnAllPartyMembers(nil, hud:AddTrackedBuffAnyCaster(1459)), 5, 5, 135932)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(235450), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(45438, talents.iblock), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(414660, talents.massBarrier), hud.defenseGroup)

    hud:AddUtilityDispell(hud:AddTrackedCooldown(475, talents.dispell), hud.specialGroup, nil, nil, nil, false, false, false, true, false)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(55342, talents.mirror), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(66, talents.invis), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(110959, talents.greaterInvis), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(414664, talents.massInvis), hud.specialGroup)

    hud:AddUtilityAuraOutOfCombat(hud:AddTrackedBuff(414664, talents.massInvis))
    hud:AddUtilityAuraOutOfCombat(greaterInvisDuration)
    hud:AddUtilityAuraOutOfCombat(invisDuration)
    hud:AddUtilityAuraOutOfCombat(invis_progress_duration, 135994)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(120), hud.controlGroup) -- cone
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(122), hud.controlGroup) -- frost nova
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(157980, talents.supernova), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(31661, talents.dragon), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(113724, talents.rof), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(157997, talents.nova), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(157981, talents.wave), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(383121, talents.massSheep), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(212653, talents.shimmer), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(1953, talents.blink), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108839, talents.floes), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(342245, talents.alter), hud.movementGroup)
    hud:AddUtilityCooldown(displacementCooldown, hud.movementGroup)

    return hud
end

---@param hud MageHUD
---@param talents ERACombat_MageCommonTalents
---@param prio number
function ERACombatFrames_MageFae(hud, talents, prio)
    local icon = hud:AddRotationCooldown(hud:AddTrackedCooldown(382440, talents.fae))
    function icon.onTimer:ComputeAvailablePriorityOverride(t)
        return prio
    end
end
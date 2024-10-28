---@class PriestHUD : ERAHUD
---@field priest_mana ERAHUDPowerBarModule
---@field priest_target20 boolean
---@field priest_instaflash ERAAura
---@field priest_lifeCooldown ERACooldown
---@field priest_shieldCooldown ERACooldown
---@field PreUpdateDisplayOverridePriest nil|fun(this:PriestHUD, t:number, combat:boolean)

---@class (exact) ERACombat_PriestCommonTalents
---@field dispellOff ERALIBTalent
---@field shadowfiend ERALIBTalent
---@field renew ERALIBTalent
---@field pom ERALIBTalent
---@field rhapsody ERALIBTalent
---@field death ERALIBTalent
---@field protflash ERALIBTalent
---@field feather ERALIBTalent
---@field tendrils ERALIBTalent
---@field dominate ERALIBTalent
---@field mass ERALIBTalent
---@field leap ERALIBTalent
---@field pi ERALIBTalent
---@field embrace ERALIBTalent
---@field star_healer ERALIBTalent
---@field halo_healer ERALIBTalent
---@field swap ERALIBTalent
---@field instaflash ERALIBTalent
---@field life ERALIBTalent

---@class (exact) ERACombat_PriestHealerTalents : ERACombat_PriestCommonTalents
---@field normalDispell ERALIBTalent
---@field betterlDispell ERALIBTalent


---@param cFrame ERACombatFrame
function ERACombatFrames_PriestSetup(cFrame)
    ERACombatGlobals_SpecID1 = 256
    ERACombatGlobals_SpecID2 = 257
    ERACombatGlobals_SpecID3 = 258

    ---@type ERACombat_PriestCommonTalents
    local talents = {
        dispellOff = ERALIBTalent:Create(103867),
        shadowfiend = ERALIBTalent:Create(103865),
        renew = ERALIBTalent:Create(103869),
        pom = ERALIBTalent:Create(103870),
        rhapsody = ERALIBTalent:Create(103850),
        death = ERALIBTalent:Create(103864),
        protflash = ERALIBTalent:Create(103858),
        feather = ERALIBTalent:Create(103853),
        tendrils = ERALIBTalent:Create(103859),
        dominate = ERALIBTalent:Create(103678),
        mass = ERALIBTalent:Create(103849),
        leap = ERALIBTalent:Create(103868),
        pi = ERALIBTalent:Create(103844),
        embrace = ERALIBTalent:Create(103841),
        star_healer = ERALIBTalent:Create(103831),
        halo_healer = ERALIBTalent:Create(103830),
        swap = ERALIBTalent:Create(103820),
        instaflash = ERALIBTalent:Create(103823),
        life = ERALIBTalent:Create(103822),
    }

    ---@cast talents ERACombat_PriestHealerTalents
    talents.normalDispell = ERALIBTalent:CreateNotTalent(103855)
    talents.betterlDispell = ERALIBTalent:Create(103855)

    local disciplineOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local holyOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local shadowOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { disciplineOptions, shadowOptions }

    if (not disciplineOptions.disabled) then
        ERACombatFrames_PriestDisciplineSetup(cFrame, talents)
    end
    if (not holyOptions.disabled) then
        --ERACombatFrames_PriestHolySetup(cFrame, talents)
    end
    if (not shadowOptions.disabled) then
        ERACombatFrames_PriestShadowSetup(cFrame, talents)
    end
end

---@param cFrame ERACombatFrame
---@param talents ERACombat_PriestCommonTalents
---@param spec integer
---@return PriestHUD
function ERACombatFrames_PriestCommonSetup(cFrame, talents, spec)
    local hud = ERAHUD:Create(cFrame, 1.5, spec ~= 2, spec ~= 3, false, spec)
    ---@cast hud PriestHUD
    hud.priest_target20 = false

    hud.priest_lifeCooldown = hud:AddTrackedCooldown(373481, talents.life)
    hud.priest_shieldCooldown = hud:AddTrackedCooldown(17)

    function hud:PreUpdateDataOverride(t, combat)
        if self.canAttackTarget then
            self.priest_target20 = 5 * UnitHealth("target") < UnitHealthMax("target")
        else
            self.priest_target20 = false
        end
    end

    function hud:PreUpdateDisplayOverride(t, combat)
        if self.priest_lifeCooldown.remDuration <= self.remGCD and self.health.currentHealth / self.health.maxHealth < 0.35 then
            self.health.bar:SetForecast(10.35 * GetSpellBonusHealing())
        else
            self.health.bar:SetForecast(0)
        end
        if self.PreUpdateDisplayOverridePriest then
            self:PreUpdateDisplayOverridePriest(t, combat)
        end
    end

    local lifeMarking = hud.health.bar:AddMarkingFrom0(-1, talents.life)
    lifeMarking:SetAvailableColor(1.0, 0.0, 0.0)
    lifeMarking:SetInsufficientColor(0.0, 0.0, 1.0)
    function lifeMarking:ComputeValueOverride(t)
        if hud.priest_lifeCooldown.remDuration <= 3 and hud.health.currentHealth / hud.health.maxHealth < 0.42 then
            return hud.health.maxHealth * 0.35
        else
            return -1
        end
    end

    hud.priest_instaflash = hud:AddTrackedBuff(114255, talents.instaflash)

    --- bars ---

    hud:AddAuraBar(hud:AddTrackedBuff(139, talents.renew), nil, 0.5, 1.0, 0.5)
    hud:AddAuraBar(hud:AddTrackedBuff(193065, talents.protflash), nil, 1.0, 1.0, 1.0)

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108968, talents.swap), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(15286, talents.embrace), hud.healGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(10060, talents.pi), hud.powerUpGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(586), hud.specialGroup) -- fade
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(32375, talents.mass), hud.specialGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108920, talents.tendrils), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(205364, talents.dominate), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(121536, talents.feather), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(73325, talents.leap), hud.movementGroup)

    hud:AddMissingUtility(hud:AddBuffOnAllPartyMembers(nil, hud:AddTrackedBuff(21562)), 5, 5, 135987)

    return hud
end

---@param hud PriestHUD
---@param talents ERACombat_PriestCommonTalents
function ERACombatFrames_PriestFinalSetup(hud, talents)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(19236), hud.healGroup) -- desperate prayer

    hud:AddOffensiveDispell(hud:AddTrackedCooldown(528, talents.dispellOff), nil, nil, true, false)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(8122), hud.controlGroup)
end

---@param hud PriestHUD
---@param group ERAGroupFrame|nil
---@param talents ERACombat_PriestHealerTalents
---@param dispellCooldown ERACooldown
function ERACombatFrames_PriestHealerSetup(hud, group, talents, dispellCooldown)
    local mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, 13, 0.0, 0.0, 1.0, nil)
    mana.hideFullOutOfCombat = true

    if group then
        local lifeProc = group:AddProc(4667420, talents.life)
        function lifeProc:IsActive(unit, t)
            return hud.priest_lifeCooldown.remDuration <= hud.remGCD and (not unit.dead) and unit.currentHealth / unit.maxHealth < 0.35
        end
    end

    hud:AddAuraOverlay(hud.priest_instaflash, 1, 450933, false, "TOP", false, false, false, true)
    hud:AddAuraOverlay(hud.priest_instaflash, 2, 450933, false, "RIGHT", true, false, false, false)

    hud:AddUtilityDispell(dispellCooldown, hud.specialGroup, nil, nil, talents.normalDispell, true, false, false, false, false)
    hud:AddUtilityDispell(dispellCooldown, hud.specialGroup, nil, nil, talents.betterlDispell, true, false, true, false, false)
end

---@param hud PriestHUD
---@param blenderID integer
---@param talent_fiend ERALIBTalent
---@param talent_blender ERALIBTalent
---@param prioValue number
function ERACombatFrames_PriestBlenderFiend(hud, blenderID, talent_fiend, talent_blender, prioValue)
    ---@class ERA_Priest_FiendBlender
    ---@field cd ERACooldown
    ---@field talent ERALIBTalent
    ---@field iconID integer

    ---@type ERA_Priest_FiendBlender
    local fiend = {
        cd = hud:AddTrackedCooldown(34433, talent_fiend),
        talent = talent_fiend,
        iconID = 136199
    }
    ---@type ERA_Priest_FiendBlender
    local blender = {
        cd = hud:AddTrackedCooldown(blenderID, talent_blender),
        talent = talent_blender,
        iconID = 136214
    }
    local fiend_blender = {}
    table.insert(fiend_blender, fiend)
    table.insert(fiend_blender, blender)

    for _, fb in ipairs(fiend_blender) do
        ---@cast fb ERA_Priest_FiendBlender
        local prio = hud:AddPriority(fb.iconID, fb.talent)
        function prio:ComputeDurationOverride(t)
            return fb.cd.remDuration
        end
        function prio:ComputeAvailablePriorityOverride(t)
            return prioValue
        end
    end

    for _, fb in ipairs(fiend_blender) do
        ---@cast fb ERA_Priest_FiendBlender
        hud:AddUtilityCooldown(fb.cd, hud.powerUpGroup)
    end
end

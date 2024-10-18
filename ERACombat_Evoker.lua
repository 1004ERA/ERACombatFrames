---@class (exact) ERAEvokerHUD : ERAHUD
---@field evoker_mana ERAHUDPowerBarModule
---@field evoker_essence ERAEvokerEssenceModule
---@field evoker_essenceBurst ERAAura
---@field evoker_leapingBuff ERAAura
---@field evoker_burnout ERAAura
---@field evoker_firebreathCooldown ERACooldown
---@field evoker_unravelIcon ERAHUDRotationCooldownIcon
---@field evoker_unravelUsable boolean
---@field evoker_unravelAbsorbValue number
---@field evoker_dispellCooldown ERACooldownBase
---@field evoker_cauterizeCooldown ERACooldownBase

---@class (exact) ERACombat_EvokerCommonTalents
---@field quell ERALIBTalent
---@field unravel ERALIBTalent
---@field landslide ERALIBTalent
---@field obsidian ERALIBTalent
---@field tip ERALIBTalent
---@field cauterize ERALIBTalent
---@field expunge ERALIBTalent
---@field spiral ERALIBTalent
---@field paradox ERALIBTalent
---@field zephyr ERALIBTalent
---@field rescue ERALIBTalent
---@field embrace ERALIBTalent
---@field renewing ERALIBTalent
---@field sleep ERALIBTalent
---@field source ERALIBTalent
---@field roar ERALIBTalent
---@field leaping ERALIBTalent
---@field fast_blossom ERALIBTalent
---@field burnout_or_onslaught ERALIBTalent
---@field maneuverability ERALIBTalent
---@field not_maneuverability ERALIBTalent
---@field engulf ERALIBTalent

---@param cFrame ERACombatFrame
function ERACombatFrames_EvokerSetup(cFrame)
    ERACombatGlobals_SpecID1 = 1467
    ERACombatGlobals_SpecID2 = 1468
    ERACombatGlobals_SpecID3 = 1473

    local devastationOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local preservationOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local augmentationOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { devastationOptions, preservationOptions, augmentationOptions }

    ---@type ERACombat_EvokerCommonTalents
    local talents = {
        quell = ERALIBTalent:Create(115620),
        unravel = ERALIBTalent:Create(115617),
        landslide = ERALIBTalent:Create(115614),
        obsidian = ERALIBTalent:Create(115613),
        tip = ERALIBTalent:Create(115665),
        cauterize = ERALIBTalent:Create(115602),
        expunge = ERALIBTalent:Create(115615),
        spiral = ERALIBTalent:Create(115666),
        paradox = ERALIBTalent:Create(125610),
        zephyr = ERALIBTalent:Create(115661),
        rescue = ERALIBTalent:Create(115596),
        embrace = ERALIBTalent:Create(115655),
        renewing = ERALIBTalent:Create(115669),
        sleep = ERALIBTalent:Create(115601),
        source = ERALIBTalent:Create(115658),
        roar = ERALIBTalent:Create(115607),
        leaping = ERALIBTalent:Create(115657),
        fast_blossom = ERALIBTalent:Create(115577),
        burnout_or_onslaught = ERALIBTalent:CreateOr(ERALIBTalent:Create(115624), ERALIBTalent:Create(117541)),
        maneuverability = ERALIBTalent:Create(117538),
        not_maneuverability = ERALIBTalent:CreateNotTalent(117538),
        engulf = ERALIBTalent:Create(117547),
    }

    local enemies = ERACombatEnemies:Create(cFrame, ERACombatOptions_specIDOrNilIfDisabled(devastationOptions), ERACombatOptions_specIDOrNilIfDisabled(augmentationOptions))

    if (not devastationOptions.disabled) then
        ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, talents)
    end
    if (not preservationOptions.disabled) then
        ERACombatFrames_EvokerPreservationSetup(cFrame, talents)
    end
    if (not augmentationOptions.disabled) then
        ERACombatFrames_EvokerAugmentationSetup(cFrame, enemies, talents)
    end
end

--------------
--- COMMON ---
--------------

---@param cFrame ERACombatFrame
---@param manaHeight number
---@param essenceDirection ERAHUDModulePointsPartialDirection
---@param burstID integer
---@param unravelPrio number
---@param talents ERACombat_EvokerCommonTalents
---@param talent_big_empower ERALIBTalent|nil
---@param spec integer
---@return ERAEvokerHUD
function ERAEvokerCommonSetup(cFrame, manaHeight, essenceDirection, burstID, unravelPrio, talents, talent_big_empower, spec)
    local hud = ERAHUD:Create(cFrame, 1.5, false, spec == 2, false, spec)
    ---@cast hud ERAEvokerHUD

    hud.evoker_mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, manaHeight, 0.0, 0.0, 1.0, nil)
    hud.evoker_mana.hideFullOutOfCombat = true
    if spec == 2 then
        hud.evoker_mana.placeAtBottomIfHealer = true
    else
        function hud.evoker_mana:ConfirmIsVisibleOverride(t, combat)
            if combat then
                return self.currentPower / self.maxPower <= 0.6
            else
                return self.currentPower / self.maxPower <= 0.5
            end
        end
        function hud.evoker_mana:CollapseIfTransparent(t, combat)
            return true
        end
    end

    hud.evoker_essence = ERAEvokerEssenceModule:create(hud, essenceDirection)

    if talent_big_empower then
        ---@type ERASpellAdditionalID
        local additionalFirebreath = {
            spellID = 382266,
            talent = talent_big_empower
        }
        hud.evoker_firebreathCooldown = hud:AddTrackedCooldown(357208, nil, additionalFirebreath)
    else
        hud.evoker_firebreathCooldown = hud:AddTrackedCooldown(357208)
    end

    function hud:PreUpdateDataOverride(t)
        if talents.unravel:PlayerHasTalent() then
            local a = UnitGetTotalAbsorbs("target")
            if a and a > 0 then
                hud.evoker_unravelAbsorbValue = a
            else
                hud.evoker_unravelAbsorbValue = 0
            end
            hud.evoker_unravelUsable = C_Spell.IsSpellUsable(368432)
        else
            hud.evoker_unravelAbsorbValue = 0
            hud.evoker_unravelUsable = false
        end
    end

    --- SAO ---

    hud.evoker_essenceBurst = hud:AddTrackedBuff(burstID)
    local essenceBurstAlert = 4699056
    if spec == 2 then
        hud:AddAuraOverlay(hud.evoker_essenceBurst, 1, essenceBurstAlert, false, "TOP", false, true, false, true)
    else
        hud:AddAuraOverlay(hud.evoker_essenceBurst, 1, essenceBurstAlert, false, "LEFT", false, false, false, false)
    end
    hud:AddAuraOverlay(hud.evoker_essenceBurst, 2, essenceBurstAlert, false, "RIGHT", true, false, false, false)

    hud.evoker_burnout = hud:AddTrackedBuff(375802, talents.burnout_or_onslaught)
    hud:AddAuraOverlay(hud.evoker_burnout, 1, 449491, false, "BOTTOM", false, false, true, false)

    --- bars ---

    hud:AddChannelInfo(356995, 0.75)                               -- disintegrate
    hud:AddAuraBar(hud:AddTrackedBuff(358267), nil, 1.0, 1.0, 1.0) -- hover

    hud:AddAuraBar(hud:AddTrackedBuff(374348, talents.renewing), nil, 1.0, 0.7, 0.0)

    local burstBar = hud:AddAuraBar(hud.evoker_essenceBurst, nil, 0.7, 1.0, 0.7)
    function burstBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud.evoker_leapingBuff = hud:AddTrackedBuff(370901, talents.leaping)
    local leapingBar = hud:AddAuraBar(hud.evoker_leapingBuff, nil, 1, 0.7, 0)
    function leapingBar:ComputeDurationOverride(t)
        if (self.aura.remDuration < self.hud.timerDuration or hud.evoker_firebreathCooldown.remDuration < 5) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local burnoutBar = hud:AddAuraBar(hud.evoker_burnout, nil, 0, 1, 0)
    function burnoutBar:ComputeDurationOverride(t)
        if (self.aura.remDuration < self.hud.timerDuration or self.aura.stacks > 1) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    --- rotation ---

    hud:AddKick(hud:AddTrackedCooldown(351338, talents.quell))

    local unravelIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(368432, talents.unravel))
    hud.evoker_unravelIcon = unravelIcon
    unravelIcon.specialPosition = true
    function unravelIcon:UpdatedOverride(t, combat)
        if self.data.remDuration > 0 then
            if hud.evoker_unravelUsable or hud.evoker_unravelAbsorbValue > 0 then
                self.icon:SetAlpha(1.0)
            else
                self.icon:SetAlpha(0.4)
            end
            self.icon:StopHighlight()
            self.icon:Show()
        else
            if combat and (hud.evoker_unravelUsable or hud.evoker_unravelAbsorbValue > 0) then
                self.icon:SetAlpha(1.0)
                self.icon:Highlight()
                self.icon:Show()
            else
                self.icon:Hide()
            end
        end
    end
    function unravelIcon.onTimer:ComputeDurationOverride(t)
        if hud.evoker_unravelUsable or hud.evoker_unravelAbsorbValue > 0 then
            return self.cd.data.remDuration
        else
            return -1
        end
    end
    function unravelIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if hud.evoker_unravelUsable then
            return unravelPrio
        else
            return 0
        end
    end

    --- utility ---

    local talent_bronzebuff = ERALIBTalent:CreateLevel(60)
    hud:AddMissingUtility(hud:AddAnyActive(hud:AddTrackedCooldown(364342, talent_bronzebuff), hud:AddBuffOnAllPartyMembers(talent_bronzebuff,
        hud:AddTrackedBuffAnyCaster(381748, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(442744, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(432674, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(364342, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381732, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381757, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381754, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381746, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381752, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381741, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381756, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381758, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381753, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381749, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(432655, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381751, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(381750, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(432652, talent_bronzebuff),
        hud:AddTrackedBuffAnyCaster(432658, talent_bronzebuff)
    )), 5, 15, 4622448, talent_bronzebuff)
    hud:AddMissingUtility(hud:AddBuffOnFriendlyHealer(talents.source, hud:AddTrackedBuff(369459, talents.source)), 4, 12, 4630412, talents.source)

    hud:AddUtilityAuraOutOfCombat(hud.evoker_burnout)
    hud:AddUtilityAuraOutOfCombat(hud.evoker_leapingBuff)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374348, talents.renewing), hud.healGroup)
    if spec ~= 2 then hud:AddUtilityCooldown(hud:AddTrackedCooldown(360995, talents.embrace), hud.healGroup, nil, nil, nil, function(cd, t) return cd.hud.health.currentHealth / cd.hud.health.maxHealth <= 0.8 end) end

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(370553, talents.tip), hud.powerUpGroup)
    hud:AddGenericTimer(hud:AddOrTimer(false, hud:AddTrackedCooldown(390386), hud:AddSatedDebuff()), hud.powerUpGroup, 4723908)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(363916, talents.obsidian), hud.defenseGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(358267), hud.movementGroup) -- hover
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(406732, talents.paradox), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(370665, talents.rescue), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374968, talents.spiral), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374227, talents.zephyr), hud.movementGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(358385, talents.landslide), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(360806, talents.sleep), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(357214), hud.controlGroup) -- buffet
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(368970), hud.controlGroup) -- swipe
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(372048, talents.roar), hud.controlGroup)

    if spec == 2 then
        hud.evoker_dispellCooldown = hud:AddTrackedCooldown(360823, talents.expunge)
        hud:AddUtilityDispell(hud.evoker_dispellCooldown, hud.specialGroup, nil, nil, nil, true, true, false, false, false)
    else
        hud.evoker_dispellCooldown = hud:AddTrackedCooldown(365585, talents.expunge)
        hud:AddUtilityDispell(hud.evoker_dispellCooldown, hud.specialGroup, nil, nil, nil, false, true, false, false, false)
    end
    hud.evoker_cauterizeCooldown = hud:AddTrackedCooldown(374251, talents.cauterize)
    hud:AddUtilityDispell(hud.evoker_cauterizeCooldown, hud.specialGroup, nil, nil, nil, false, true, true, true, true)

    return hud
end

---------------
--- ESSENCE ---
---------------

---@class (exact) ERAEvokerEssenceModule : ERAHUDModulePointsPartial
---@field private __index unknown
---@field nextAvailable number
---@field private lastGain number|nil
---@field private lastWholeValue integer
ERAEvokerEssenceModule = {}
ERAEvokerEssenceModule.__index = ERAEvokerEssenceModule
setmetatable(ERAEvokerEssenceModule, { __index = ERAHUDModulePointsPartial })

---@param hud ERAHUD
---@param direction ERAHUDModulePointsPartialDirection
---@return ERAEvokerEssenceModule
function ERAEvokerEssenceModule:create(hud, direction)
    local e = {}
    setmetatable(e, ERAEvokerEssenceModule)
    ---@cast e ERAEvokerEssenceModule
    e.nextAvailable = 0
    e:constructPoints(hud, 0.7, 0.8, 0.3, 0.5, 0.7, 0.9, 0.9, 0.2, 0.5, nil, direction)
    e.lastWholeValue = 0
    return e
end

function ERAEvokerEssenceModule:GetIdlePointsOverride()
    return self.maxPoints
end

function ERAEvokerEssenceModule:getMaxPoints()
    return UnitPowerMax("player", 19)
end

---@param t number
function ERAEvokerEssenceModule:getCurrentPoints(t)
    ---@type integer
    local points = math.floor(UnitPower("player", 19))
    if (points < self.maxPoints) then
        local partial = UnitPartialPower("player", 19) / 1000
        if (self.lastWholeValue + 1 == points and partial < 0.1) then
            self.lastGain = t
        end
        local rate = GetPowerRegenForPowerType(19)
        if ((not rate) or rate <= 0) then
            rate = 0.2
        end
        local duration = 1 / rate
        if (false and self.lastGain) then
            local delta = t - self.lastGain
            if (delta < 2 * duration) then
                -- sigmoide : les valeurs basses de UnitPartialPower ont l'air d'être moins fiables que les hautes
                local partial_weight = 0.5 * 1 / (1 + exp(-13 * (partial - 0.5)))
                if (delta > duration) then
                    if (delta > duration * 1.1618033988749894) then
                        delta = delta - duration
                    else
                        delta = duration
                    end
                end
                local estimated = delta / duration
                partial = (partial * partial_weight + estimated) / (1 + partial_weight)
            end
        end
        self.nextAvailable = duration * (1 - partial)
        return points + partial
    else
        self.nextAvailable = 0
        return points
    end
end

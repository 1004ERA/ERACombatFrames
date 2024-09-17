---@alias EvokerEssenceDirection "TO_LEFT" | "TO_RIGHT"

---@class (exact) ERAEvokerHUD : ERAHUD
---@field evoker_essence ERAEvokerEssenceModule
---@field evoker_essenceBurst ERAAura
---@field evoker_leapingBuff ERAAura
---@field evoker_burnout ERAAura
---@field evoker_firebreathCooldown ERACooldown
---@field evoker_unravelIcon ERAHUDRotationCooldownIcon
---@field evoker_unravelUsable boolean
---@field evoker_unravelAbsorbValue number

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
    ERACombatEvokerEssence_size = 22
    ERACombatEvokerEssence_spacing = 2

    local devastationActive = ERACombatOptions_IsSpecActive(1)
    local preservationActive = ERACombatOptions_IsSpecActive(2)
    local augmentationActive = ERACombatOptions_IsSpecActive(3)

    cFrame.hideAlertsForSpec = { devastationActive, preservationActive, augmentationActive }

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

    local enemies = ERACombatEnemies:Create(cFrame, devastationActive, augmentationActive)

    if (devastationActive) then
        ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, talents)
    end
    if (preservationActive) then
        ERACombatFrames_EvokerPreservationSetup(cFrame, talents)
    end
    if (augmentationActive) then
        ERACombatFrames_EvokerAugmentationSetup(cFrame, enemies, talents)
    end
end

--------------
--- COMMON ---
--------------

---@param hud ERAEvokerHUD
---@param essenceDirection EvokerEssenceDirection
---@param burstID integer
---@param unravelPrio number
---@param talents ERACombat_EvokerCommonTalents
---@param talent_big_empower ERALIBTalent|nil
---@param spec integer
function ERAEvokerCommonSetup(hud, essenceDirection, burstID, unravelPrio, talents, talent_big_empower, spec)
    hud.evoker_essence = ERAEvokerEssenceModule:create(hud, essenceDirection)

    if talent_big_empower then
        local additionalFirebreath = {
            id = 382266,
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

    hud:AddChannelInfo(356995, 0.75)                         -- disintegrate
    hud:AddAuraBar(hud:AddTrackedBuff(358267), nil, 1, 1, 1) -- hover

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

    local bronzeBuffCooldown = hud:AddTrackedCooldown(364342)
    hud:AddEmptyTimer(hud:AddOrTimer(false, bronzeBuffCooldown, hud:AddBuffOnAllPartyMembers(381748)), 8, 4622448, ERALIBTalent:CreateLevel(60))
    hud:AddEmptyTimer(hud:AddBuffOnFriendlyHealer(369459, talents.source), 8, 4630412, talents.source)

    hud:AddUtilityAuraOutOfCombat(hud.evoker_burnout)
    hud:AddUtilityAuraOutOfCombat(hud.evoker_leapingBuff)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374348, talents.renewing), hud.healGroup)
    if spec ~= 2 then hud:AddUtilityCooldown(hud:AddTrackedCooldown(360995, talents.embrace), hud.healGroup) end

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(370553, talents.tip), hud.powerUpGroup)
    hud:AddGenericTimer(hud:AddOrTimer(false, hud:AddTrackedCooldown(390386), hud:AddSatedDebuff()), hud.powerUpGroup, 4723908)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(363916, talents.obsidian), hud.defenseGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(358267), hud.movementGroup) -- hover
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(406732, talents.paradox), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374968, talents.spiral), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(374227, talents.zephyr), hud.movementGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(358385, talents.landslide), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(360806, talents.sleep), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(357214), hud.controlGroup) -- buffet
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(368970), hud.controlGroup) -- swipe
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(372048, talents.roar), hud.controlGroup)

    if spec == 2 then
        hud:AddUtilityDispell(hud:AddTrackedCooldown(365585, talents.expunge), hud.specialGroup, nil, nil, nil, true, true, false, false, false)
    else
        hud:AddUtilityDispell(hud:AddTrackedCooldown(365585, talents.expunge), hud.specialGroup, nil, nil, nil, false, true, false, false, false)
    end
    hud:AddUtilityDispell(hud:AddTrackedCooldown(374251, talents.cauterize), hud.specialGroup, nil, nil, nil, false, true, true, true, true)
end

---------------
--- ESSENCE ---
---------------

---@class (exact) ERAEvokerEssenceModule : ERAHUDResourceModule
---@field private __index unknown
---@field maxEssence integer
---@field currentEssence integer
---@field nextAvailable number
---@field partial number
---@field private lastGain number|nil
---@field private points ERAEvokerEssencePoint[]
---@field private activePoints integer
---@field private direction EvokerEssenceDirection
---@field private updateMax fun(this:ERAEvokerEssenceModule)
ERAEvokerEssenceModule = {}
ERAEvokerEssenceModule.__index = ERAEvokerEssenceModule
setmetatable(ERAEvokerEssenceModule, { __index = ERAHUDResourceModule })

---@param hud ERAHUD
---@param direction EvokerEssenceDirection
---@return ERAEvokerEssenceModule
function ERAEvokerEssenceModule:create(hud, direction)
    local e = {}
    setmetatable(e, ERAEvokerEssenceModule)
    ---@cast e ERAEvokerEssenceModule
    e.direction = direction
    e.points = {}
    e.activePoints = 0
    e.maxEssence = 0
    e.currentEssence = 0
    e.nextAvailable = 0
    e:constructModule(hud, ERACombatEvokerEssence_size)
    return e
end

function ERAEvokerEssenceModule:checkTalentOverride()
    self:updateMax()
    return true
end

function ERAEvokerEssenceModule:updateMax()
    local max = UnitPowerMax("player", 19)
    if max ~= self.maxEssence then
        self.maxEssence = max
        for i = 1 + #(self.points), max do
            table.insert(self.points, ERAEvokerEssencePoint:create(self, self.frame))
        end
        local x
        local delta = ERACombatEvokerEssence_size + ERACombatEvokerEssence_spacing
        if self.direction == "TO_LEFT" then
            x = self.hud.barsWidth - delta * max + delta / 2
        else
            x = delta / 2
        end
        for i, p in ipairs(self.points) do
            p:updateTalent(self.frame, i, max, x)
            x = x + delta
        end
    end
end

---@param t number
---@param combat boolean
function ERAEvokerEssenceModule:updateData(t, combat)
    local points = UnitPower("player", 19)
    self:updateMax()
    if (points < self.maxEssence) then
        local partial = UnitPartialPower("player", 19) / 1000
        if (self.currentEssence + 1 == points and partial < 0.1) then
            self.lastGain = t
        end
        self.currentEssence = points
        local rate = GetPowerRegenForPowerType(19)
        if ((not rate) or rate <= 0) then
            rate = 0.2
        end
        local duration = 1 / rate
        if (self.lastGain) then
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
        self.partial = partial
        self.nextAvailable = duration * (1 - partial)
    else
        self.currentEssence = points
        self.nextAvailable = 0
        for i = 1, points do
            self.points[i]:drawAvailable()
        end
    end
end

---@param t number
---@param combat boolean
function ERAEvokerEssenceModule:updateDisplay(t, combat)
    if self.currentEssence >= self.maxEssence then
        if combat then
            for i = 1, self.maxEssence do
                self.points[i]:drawAvailable()
            end
            self:show()
        else
            self:hide()
        end
    else
        for i = 1, self.currentEssence do
            self.points[i]:drawAvailable()
        end
        self.points[self.currentEssence + 1]:drawFilling(self.partial)
        for i = self.currentEssence + 2, self.maxEssence do
            self.points[i]:drawEmpty()
        end
        self:show()
    end
end

-------------
--- POINT ---
-------------

---@class (exact) ERAEvokerEssencePoint
---@field private __index unknown
---@field private frame Frame
---@field private point Texture
---@field private wasAvailable boolean
---@field private wasFilling boolean
---@field private wasEmpty boolean
ERAEvokerEssencePoint = {}
ERAEvokerEssencePoint.__index = ERAEvokerEssencePoint

---@param owner ERAEvokerEssenceModule
---@param parentFrame Frame
---@return ERAEvokerEssencePoint
function ERAEvokerEssencePoint:create(owner, parentFrame)
    local p = {}

    local frame = CreateFrame("Frame", nil, parentFrame, "ERAEvokerEssencePointFrame")
    local point = frame.FULL_POINT

    p.size = ERACombatEvokerEssence_size
    p.trt = frame.TRT
    p.trr = frame.TRR
    p.tlt = frame.TLT
    p.tlr = frame.TLR
    p.blr = frame.BLR
    p.blt = frame.BLT
    p.brt = frame.BRT
    p.brr = frame.BRR
    ERAPieControl_Init(p)

    ---@cast frame Frame
    frame:SetSize(ERACombatEvokerEssence_size, ERACombatEvokerEssence_size)

    setmetatable(p, ERAEvokerEssencePoint)
    ---@cast p ERAEvokerEssencePoint
    p.frame = frame
    p.point = point
    p.wasAvailable = false
    p.wasFilling = false
    p.wasEmpty = false
    return p
end

function ERAEvokerEssencePoint:updateTalent(frame, index, maxPoints, x)
    if (index > maxPoints) then
        self.frame:Hide()
    else
        self.frame:SetPoint("CENTER", frame, "LEFT", x, 0)
        self.frame:Show()
    end
end

function ERAEvokerEssencePoint:drawAvailable()
    if (not self.wasAvailable) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = true
        self.wasFilling = false
        self.point:SetVertexColor(0.5, 0.7, 0.9, 1)
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

function ERAEvokerEssencePoint:drawFilling(part)
    if (not self.wasFilling) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = false
        self.wasFilling = true
        self.point:SetVertexColor(0.9, 0.2, 0.5, 1)
    end
    ERAPieControl_SetOverlayValue(self, 1 - part)
end

function ERAEvokerEssencePoint:drawEmpty()
    if (not self.wasEmpty) then
        self.wasAvailable = false
        self.wasFilling = false
        self.wasEmpty = true
        self.point:Hide()
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

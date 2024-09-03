---@class ERACombat_EvokerCommonTalents
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

---@class ERACombat_EvokerTimerParams
---@field quellX number
---@field quellY number
---@field unravelX number
---@field unravelY number
---@field unravelPrio number

---@class ERACombat_EvokerUnravelCooldown : ERACombatTimersCooldown
---@field absorbValue number
---@field useable boolean

---@class ERACombatTimers_Evoker : ERACombatTimers
---@field evoker_unravel ERACombat_EvokerUnravelCooldown
---@field evoker_unravelIcon ERACombatTimersCooldownIcon
---@field evoker_leapingBuff ERACombatTimersAura
---@field evoker_firebreathCooldown ERACombatTimersCooldown
---@field evoker_burnoutTimer ERACombatTimersAura
---@field evoker_offsetX number
---@field evoker_offsetY number
---@field evoker_additionalPreupdate fun(t: number) | nil

function ERACombatFrames_EvokerSetup(cFrame)
    local devastationActive = 1
    local preservationActive = 2
    local augmentationActive = 3

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
        burnout_or_onslaught = ERALIBTalent:CreateOr(ERALIBTalent:Create(115624), ERALIBTalent:Create(117541))
    }

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -55, 128, 16, 16, 0, true, 0.4, 0.4, 0.8, 0, devastationActive, preservationActive, augmentationActive)

    local essence = ERACombatEvokerEssence:create(cFrame, -111, -51, 0, devastationActive, augmentationActive)

    local combatHealth = ERACombatHealth:Create(cFrame, -191, -14, 151, 22, devastationActive, augmentationActive)

    local enemies = ERACombatEnemies:Create(cFrame, devastationActive, augmentationActive)

    if (devastationActive) then
        ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, essence, combatHealth, talents)
    end
    if (preservationActive) then
        ERACombatFrames_EvokerPreservationSetup(cFrame, talents)
    end
    if (augmentationActive) then
        ERACombatFrames_EvokerAugmentationSetup(cFrame, enemies, essence, combatHealth, talents)
    end
end

---comment
---@param cFrame ERACombatFrame
---@param timers ERACombatTimers_Evoker
---@param tParams ERACombat_EvokerTimerParams
---@param talents ERACombat_EvokerCommonTalents
---@param spec number
---@return ERACombatUtilityFrame
function ERACombat_EvokerSetup(cFrame, timers, tParams, talents, spec)
    --------------
    --- timers ---
    --------------

    timers:AddChannelInfo(356995, 0.75)

    timers:AddKick(351338, tParams.quellX, tParams.quellY, talents.quell)

    timers:AddAuraBar(timers:AddTrackedBuff(358267), nil, 1, 1, 1) -- hover

    timers.evoker_leapingBuff = timers:AddTrackedBuff(370901, talents.leaping)
    local leapingBar = timers:AddAuraBar(timers.evoker_leapingBuff, nil, 1, 0.7, 0)
    function leapingBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (self.aura.remDuration < 5 or timers.evoker_firebreathCooldown.remDuration < 4) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local burnout_buff_ID = 375802
    timers.evoker_burnoutTimer = timers:AddTrackedBuff(burnout_buff_ID, talents.burnout_or_onslaught)
    timers:AddAuraBar(timers.evoker_burnoutTimer, nil, 0, 1, 0)

    local unravel = timers:AddTrackedCooldown(368432, talents.unravel)
    ---@cast unravel ERACombat_EvokerUnravelCooldown
    timers.evoker_unravel = unravel
    local unravelIcon = timers:AddCooldownIcon(unravel, nil, tParams.unravelX, tParams.unravelY, true, true)
    timers.evoker_unravelIcon = unravelIcon
    function unravelIcon:TimerVisibilityOverride(t)
        local cd = self.cd
        ---@cast cd ERACombat_EvokerUnravelCooldown
        if cd.useable or (cd.absorbValue > 0 and cd.remDuration > 0) then
            self.icon:SetAlpha(1.0)
            if (cd.remDuration > 0) then
                self.icon:Highlight()
            else
                self.icon:StopHighlight()
            end
            return true
        else
            self.icon:StopHighlight()
            if (self.cd.remDuration > 0) then
                self.icon:SetAlpha(0.4)
            else
                self.icon:SetAlpha(0.1)
            end
            return false
        end
    end
    function unravelIcon:ComputeAvailablePriorityOverride()
        local cd = self.cd
        ---@cast cd ERACombat_EvokerUnravelCooldown
        if (cd.useable) then
            return 2
        else
            return 0
        end
    end

    function timers:PreUpdateCombatOverride(t)
        local a = UnitGetTotalAbsorbs("target")
        if a and a > 0 then
            unravel.absorbValue = a
        else
            unravel.absorbValue = 0
        end
        unravel.useable = C_Spell.IsSpellUsable(368432)
        if (self.evoker_additionalPreupdate) then
            self.evoker_additionalPreupdate(t)
        end
    end

    ---------------
    --- utility ---
    ---------------

    local utility = ERACombatUtilityFrame:Create(cFrame, 0, -191, spec)

    utility:AddMissingBuffAnyCaster(4622448, 1, 0, ERALIBTalent:CreateLevel(60), 381748) -- bronze buff
    utility:AddMissingBuffOnGroupMember(4630412, 1, 1, talents.source, 369459).onlyOnHealer = true

    utility:AddBuffIcon(utility:AddTrackedBuff(burnout_buff_ID, talents.burnout_or_onslaught), nil, 0.5, 0.9, false)

    utility:AddCooldown(-5, 0, 390386, nil, true) -- BL

    utility:AddCooldown(-1, 0, 363916, nil, true, talents.obsidian)

    utility:AddCooldown(0, 0, 358267, nil, true) -- hover
    utility:AddCooldown(1, 0, 357214, nil, true) -- buffet
    utility:AddCooldown(2, 0, 372048, nil, true, talents.roar)
    utility:AddCooldown(3, 0, 368970, nil, true) -- swipe

    utility:AddWarlockHealthStone(-2.5, -0.9)
    utility:AddCooldown(-1.5, -0.9, 406732, nil, true, talents.paradox)
    utility:AddCooldown(-1.5, -0.9, 374968, nil, true, talents.spiral)
    utility:AddCooldown(-0.5, -0.9, 374227, nil, true, talents.zephyr)
    utility:AddWarlockPortal(0.5, -0.9)

    utility:AddTrinket1Cooldown(-1.5, -1.9)
    utility:AddTrinket2Cooldown(-0.5, -1.9)

    utility:AddCooldown(1.5, 0.9, 358385, nil, true, talents.landslide)
    utility:AddCooldown(2.5, 0.9, 360806, nil, true, talents.sleep)

    if (spec == 2) then
        utility:AddDefensiveDispellCooldown(2, 2, 365585, nil, talents.expunge, "Magic", "Poison")
    else
        utility:AddDefensiveDispellCooldown(2, 2, 365585, nil, talents.expunge, "Poison")
    end
    utility:AddDefensiveDispellCooldown(3, 2, 374251, nil, talents.cauterize, "Poison", "Curse", "Disease", "Bleed")

    return utility
end

-----------
--- DPS ---
-----------

---comment
---@param utility ERACombatUtilityFrame
---@param talents ERACombat_EvokerCommonTalents
function ERACombat_EvokerDPS_Utility(utility, talents)
    utility:AddCooldown(-0.5, 0.9, 370553, nil, true, talents.tip)
    utility:AddCooldown(-3, 0, 374348, nil, true, talents.renewing)
    utility:AddCooldown(-2, 0, 360995, nil, true, talents.embrace)
end

---@class ERACombatTimers_EvokerDPS : ERACombatTimers_Evoker
---@field essence ERACombat_EvokerEssence

---comment
---@param cFrame ERACombatFrame
---@param talents ERACombat_EvokerCommonTalents
---@param talent_big_empower ERALIBTalent
---@param spec number
---@return ERACombatTimers_EvokerDPS
function ERACombat_EvokerDPS(cFrame, talents, talent_big_empower, spec)
    local timers = ERACombatTimersGroup:Create(cFrame, -101, 4, 1.5, false, false, spec)
    ---@cast timers ERACombatTimers_EvokerDPS

    timers.offsetIconsX = -42
    timers.offsetIconsY = -32

    local firebreathAlternative = {
        id = 382266,
        talent = talent_big_empower
    }
    local firebreathCooldown = timers:AddTrackedCooldown(357208, nil, firebreathAlternative)
    timers.evoker_firebreathCooldown = firebreathCooldown

    return timers
end

------------------------------------------------------------------------------------------------------------------------
---- ESSENCE -----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatEvokerEssence_size = 24
ERACombatEvokerEssence_margin = 4

ERACombatEvokerEssencePoint = {}
ERACombatEvokerEssencePoint.__index = ERACombatEvokerEssencePoint

function ERACombatEvokerEssencePoint:create(group, index)
    local p = {}
    setmetatable(p, ERACombatEvokerEssencePoint)

    p.index = index

    p.frame = CreateFrame("Frame", nil, group.frame, "ERAEvokerEssencePointFrame")
    p.frame:SetSize(ERACombatEvokerEssence_size, ERACombatEvokerEssence_size)
    p.size = ERACombatEvokerEssence_size
    p.point = p.frame.FULL_POINT
    p.trt = p.frame.TRT
    p.trr = p.frame.TRR
    p.tlt = p.frame.TLT
    p.tlr = p.frame.TLR
    p.blr = p.frame.BLR
    p.blt = p.frame.BLT
    p.brt = p.frame.BRT
    p.brr = p.frame.BRR
    ERAPieControl_Init(p)

    p.wasAvailable = false
    p.wasFilling = false
    p.wasEmpty = false

    return p
end

function ERACombatEvokerEssencePoint:updateTalent(frame, maxPoints, x, anchor)
    if (self.index > maxPoints) then
        self.frame:Hide()
    else
        self.frame:SetPoint("CENTER", frame, anchor, x, 0)
        self.frame:Show()
    end
end

function ERACombatEvokerEssencePoint:drawAvailable()
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

function ERACombatEvokerEssencePoint:drawFilling(part)
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

function ERACombatEvokerEssencePoint:drawEmpty()
    if (not self.wasEmpty) then
        self.wasAvailable = false
        self.wasFilling = false
        self.wasEmpty = true
        self.point:Hide()
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

ERACombatEvokerEssence = {}
ERACombatEvokerEssence.__index = ERACombatEvokerEssence
setmetatable(ERACombatEvokerEssence, { __index = ERACombatModule })

---@class ERACombat_EvokerEssence
---@field currentPoints number
---@field maxPoints number
---@field nextAvailable number

---comment
---@param cFrame ERACombatFrame
---@param x number
---@param y number
---@param orientation number 1 : left to right
---@param ... number Specializations
---@return ERACombat_EvokerEssence
function ERACombatEvokerEssence:create(cFrame, x, y, orientation, ...)
    local e = {}
    setmetatable(e, ERACombatEvokerEssence)
    e:construct(cFrame, 0.2, 0.02, false, ...)
    e.frame = CreateFrame("Frame", nil, UIParent, nil)
    if (orientation == 1) then
        e.frame:SetPoint("LEFT", UIParent, "CENTER", x, y)
    else
        e.frame:SetPoint("RIGHT", UIParent, "CENTER", x, y)
    end
    e.frame:SetSize((ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin) * 6, ERACombatEvokerEssence_size)
    e.orientation = orientation
    e.currentPoints = 0
    e.maxPoints = UnitPowerMax("player", 19)
    e.nextAvailable = 0
    e.lastFull = 0
    e.points = {}
    for i = 1, 6 do
        table.insert(e.points, ERACombatEvokerEssencePoint:create(e, i))
    end
    return e
end

function ERACombatEvokerEssence:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatEvokerEssence:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatEvokerEssence:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatEvokerEssence:ExitVehicle(toCombat)
    self.frame:Show()
end
function ERACombatEvokerEssence:ResetToIdle()
    self.frame:Show()
end
function ERACombatEvokerEssence:CheckTalents()
    self:updatePoints()
    self.mustUpdatePoints = true
end
function ERACombatEvokerEssence:updatePoints()
    if (self.mustUpdatePoints) then
        self.mustUpdatePoints = false
        self.maxPoints = UnitPowerMax("player", 19)
        for i = #self.points + 1, self.maxPoints do
            table.insert(self.points, ERACombatEvokerEssencePoint:create(self, i))
        end
        local x
        local anchor
        if (self.orientation == 1) then
            x = 0.5 * (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
            anchor = "LEFT"
        else
            x = (0.5 - self.maxPoints) * (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
            anchor = "RIGHT"
        end
        for i, p in ipairs(self.points) do
            p:updateTalent(self.frame, self.maxPoints, x, anchor)
            x = x + (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
        end
    end
end

function ERACombatEvokerEssence:UpdateIdle(t)
    self:update(t)
    if (self.currentPoints == self.maxPoints) then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end
function ERACombatEvokerEssence:UpdateCombat(t)
    self:update(t)
end

function ERACombatEvokerEssence:update(t)
    self:updatePoints()
    local points = UnitPower("player", 19)
    if (points < self.maxPoints) then
        local partial = UnitPartialPower("player", 19) / 1000
        if (self.currentPoints + 1 == points and partial < 0.1) then
            self.lastGain = t
        end
        self.currentPoints = points
        local rate = GetPowerRegenForPowerType(19)
        if ((not rate) or rate <= 0) then
            rate = 0.2
        end
        local duration = 1 / rate
        if (self.lastGain) then
            local delta = t - self.lastGain
            if (delta < 2 * duration) then
                --local partial_weight = partial * partial
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
            --[[
            if (delta < 3 * duration) then
                while delta > duration do
                    delta = delta - duration
                end
                local estimated = delta / duration
                if (math.abs(estimated - partial) < 0.1) then
                    partial = estimated
                end
            end
            ]]
        end
        self.nextAvailable = duration * (1 - partial)
        for i = 1, points do
            self.points[i]:drawAvailable()
        end
        self.points[points + 1]:drawFilling(partial)
        for i = points + 2, self.maxPoints do
            self.points[i]:drawEmpty()
        end
    else
        self.currentPoints = points
        self.nextAvailable = 0
        for i = 1, points do
            self.points[i]:drawAvailable()
        end
    end
end

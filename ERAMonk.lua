-- TODO
-- rien

---@class MonkDisruptTimerIconParams
---@field kickX number
---@field kickY number
---@field paraX number
---@field paraY number

---@class MonkCommonTalents
---@field diffuse ERALIBTalent
---@field fortify ERALIBTalent
---@field clash ERALIBTalent
---@field lust ERALIBTalent
---@field transcendence ERALIBTalent
---@field torpedo ERALIBTalent
---@field roll ERALIBTalent
---@field paralysis ERALIBTalent
---@field disenrage ERALIBTalent
---@field rop ERALIBTalent
---@field sleep ERALIBTalent
---@field detox ERALIBTalent
---@field kick ERALIBTalent

function ERACombatFrames_MonkSetup(cFrame)
    cFrame.hideAlertsForSpec = { 1 }

    ERACombatGlobals_SpecID1 = 268
    ERACombatGlobals_SpecID2 = 270
    ERACombatGlobals_SpecID3 = 269

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mwActive = ERACombatOptions_IsSpecActive(2)
    local wwActive = ERACombatOptions_IsSpecActive(3)

    ---@type MonkCommonTalents
    local monkTalents = {}
    monkTalents.diffuse = ERALIBTalent:Create(124959)
    monkTalents.fortify = ERALIBTalent:Create(124968)
    monkTalents.clash = ERALIBTalent:Create(124945)
    monkTalents.lust = ERALIBTalent:Create(124937)
    monkTalents.transcendence = ERALIBTalent:Create(124962)
    monkTalents.torpedo = ERALIBTalent:Create(124981)
    monkTalents.roll = ERALIBTalent:CreateNotTalent(124981)
    monkTalents.paralysis = ERALIBTalent:Create(124932)
    monkTalents.disenrage = ERALIBTalent:Create(124931)
    monkTalents.rop = ERALIBTalent:Create(124926)
    monkTalents.sleep = ERALIBTalent:Create(124925)
    monkTalents.detox = ERALIBTalent:Create(124941)
    monkTalents.kick = ERALIBTalent:Create(124943)

    local enemies = ERACombatEnemies:Create(cFrame, 1, 3)

    if (bmActive) then
        ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, monkTalents)
    end
    if (mwActive) then
        --ERACombatFrames_MonkMistweaverSetup(cFrame, talent_diffuse, talent_dampen, talent_fortify)
    end
    if (wwActive) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, monkTalents)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

---comment
---@param cFrame any
---@param spec number
---@param includeDetox boolean
---@param monkTalents MonkCommonTalents
---@return table
function ERACombatFrames_MonkUtility(cFrame, spec, includeDetox, monkTalents)
    local utility = ERACombatUtilityFrame:Create(cFrame, -16, -212, spec)

    utility:AddCooldown(-0.5, 0.9, 322109, nil, false) -- touch of death

    utility:AddTrinket2Cooldown(-3, 0, nil)
    utility:AddTrinket1Cooldown(-2, 0, nil)
    utility:AddCooldown(0, 0, 115203, nil, true, monkTalents.fortify)
    utility:AddWarlockHealthStone(-0.5, -0.9)
    utility:AddCooldown(2, 0, 122783, nil, true, monkTalents.diffuse)
    utility:AddBeltCooldown(3, 0, nil)
    utility:AddCloakCooldown(4, 0, nil)
    utility:AddRacial(3, 1)
    utility:AddCooldown(4, 1, 115078, nil, true, monkTalents.paralysis)
    utility:AddCooldown(3, 2, 119381, nil, true) -- sweep
    utility:AddCooldown(4, 2, 116844, nil, true, monkTalents.rop)
    utility:AddCooldown(4, 2, 198898, nil, true, monkTalents.sleep)
    utility:AddCooldown(3, 3, 324312, nil, true, monkTalents.clash)
    utility:AddCooldown(4, 3, 119996, nil, true, monkTalents.transcendence)
    utility:AddCooldown(5, 3, 101643, nil, true, monkTalents.transcendence).alphaWhenOffCooldown = 0.1
    utility:AddCooldown(3, 4, 109132, 574574, true, monkTalents.roll)
    utility:AddCooldown(3, 4, 115008, 607849, true, monkTalents.torpedo)
    utility:AddCooldown(4, 4, 116841, nil, true, monkTalents.lust)
    if (includeDetox) then
        utility:AddDefensiveDispellCooldown(3, 5, 218164, nil, monkTalents.detox, "poison", "disease")
    end
    utility:AddCooldown(4, 5, 115546, nil, true).alphaWhenOffCooldown = 0.2
    utility:AddWarlockPortal(5, 5)


    return utility
end

---comment
---@param timers any
---@param talents MonkCommonTalents
---@param disrupt MonkDisruptTimerIconParams
function ERACombatFrames_MonkTimerBars(timers, talents, disrupt)
    timers:AddChannelInfo(115175, 1.0) -- soothing mist
    timers:AddChannelInfo(117952, 1.0) -- crackling jade lightning

    timers:AddAuraBar(timers:AddTrackedBuff(122783, talents.diffuse), nil, 0.7, 0.6, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(120954, talents.fortify), nil, 0.8, 0.8, 0.0)

    timers:AddKick(116705, disrupt.kickX, disrupt.kickY, talents.kick, false)
    timers:AddOffensiveDispellIcon(629534, disrupt.paraX, disrupt.paraX, true, talents.disenrage, "enrage")
end

-- recurring

ERACombatFrames_MonkRecurringIcon = {}
ERACombatFrames_MonkRecurringIcon.__index = ERACombatFrames_MonkRecurringIcon
setmetatable(ERACombatFrames_MonkRecurringIcon, { __index = ERACombatTimerIcon })

function ERACombatFrames_MonkRecurringIcon:create(group, iconID, talent, buffAlready)
    local i = {}
    setmetatable(i, ERACombatFrames_MonkRecurringIcon)
    i.iconID = iconID
    i:construct(group, 0, 0, iconID, true)
    i.talent = talent
    i.buffAlready = buffAlready
    return i
end

function ERACombatFrames_MonkRecurringIcon:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        self.talentActive = true
        return true
    else
        self:hide()
        self.talentActive = false
        return false
    end
end

function ERACombatFrames_MonkRecurringIcon:updateIconCooldownTexture()
    return self.iconID
end

function ERACombatFrames_MonkRecurringIcon:updateAfterReset(t)
    self:updateIconCooldownTexture()
end

function ERACombatFrames_MonkRecurringIcon:updateTimerDurationAndMainIconVisibility(t, timerStandardDuration)
    self.shouldShowMainIcon = false
    local last, dur = self:getLastAndDuration()
    if (last > 0) then
        local elapsed = t - last
        self.timerDuration = dur - (elapsed - dur * math.floor(elapsed / dur))
        if (self.buffAlready) then
            self.iconTimer:SetDesaturated(self.buffAlready.remDuration <= 0)
        end
    else
        self.timerDuration = -1
    end
end
function ERACombatFrames_MonkRecurringIcon:getLastAndDuration()
    return 0, 1
end

function ERACombatFrames_MonkRecurringIcon_instaVivify(timers, talent, instaVivifyTimer)
    local i = ERACombatFrames_MonkRecurringIcon:create(timers, 1360980, talent, instaVivifyTimer)
    function i:getLastAndDuration()
        return self.group.lastInstaVivify, 10
    end
end
------------------------------------------------------------------------------------------------------------------------
---- BM ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, monkTalents)
    local talent_rsk = ERALIBTalent:Create(124985)
    local talent_bof = ERALIBTalent:Create(124843)
    local talent_not_bof = ERALIBTalent:CreateNotTalent(124843)
    local talent_no_shuffle = ERALIBTalent:CreateNotTalent(124864)
    local talent_rjw = ERALIBTalent:Create(125007)
    local talent_chib = ERALIBTalent:Create(126501)
    local talent_celestialb = ERALIBTalent:Create(124841)
    local talent_strong_rsk = ERALIBTalent:Create(124984)
    local talent_strong_eh = ERALIBTalent:Create(124948)
    local talent_critical_eh = ERALIBTalent:Create(124923)
    local talent_scaling_eh = ERALIBTalent:Create(124924)
    local talent_healing_taken = ERALIBTalent:Create(124936)
    local talent_weapons = ERALIBTalent:Create(124996)
    local talent_not_weapons = ERALIBTalent:CreateNotTalent(124996)
    local talent_exploding = ERALIBTalent:Create(125001)
    local talent_zenmed = ERALIBTalent:Create(125006)
    local talent_charred = ERALIBTalent:Create(124986)
    local talent_celestial_flames = ERALIBTalent:Create(124844)
    local talent_insta_vivify = ERALIBTalent:Create(124935)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 42, 1, true, false, 1)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -36
    local first_column_X = 0.5

    ---@type MonkDisruptTimerIconParams
    local disruptParams = {
        kickX = first_column_X,
        kickY = 3,
        paraX = 5,
        paraY = 5,
    }

    ERACombatFrames_MonkTimerBars(timers, monkTalents, disruptParams)

    local kegCooldown = timers:AddTrackedCooldown(121253)
    local purifCooldown = timers:AddTrackedCooldown(119582)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 3, true, 1, 1, 0, false, 1)

    local barWidth = 151
    local barX = -181

    local health = ERACombatHealth:Create(cFrame, barX, 26, barWidth, 22, 1)

    ERACombatStagger:Create(cFrame, barX, 3, barWidth, 11, purifCooldown)

    local nrg = ERACombatPower:Create(cFrame, barX, -6, barWidth, 16, 3, false, 1.0, 1.0, 0.0, 1)
    nrg:AddConsumer(25, 606551)
    nrg:AddConsumer(65, 606551)
    local kegConsumer = nrg:AddConsumer(40, 594274)
    function kegConsumer:ComputeVisibility()
        if (kegCooldown.hasCharges) then
            return kegCooldown.currentCharges > 0
        else
            return kegCooldown.remDuration <= 3
        end
    end
    function kegConsumer:ComputeIconVisibility()
        if (kegCooldown.hasCharges) then
            self.icon:SetDesaturated(false)
        else
            if (kegCooldown.remDuration <= 0 or kegCooldown.remDuration + 0.05 <= timers.occupied) then
                self.icon:SetDesaturated(false)
            else
                self.icon:SetDesaturated(true)
            end
        end
        return true
    end

    local purifIcon = timers:AddCooldownIcon(purifCooldown, nil, -4.5, 1, true, true)

    local bokAlternative = {}
    bokAlternative.id = 100784
    bokAlternative.talent = talent_no_shuffle
    local bokCooldown = timers:AddTrackedCooldown(205523, nil, bokAlternative) -- 100784 (basic) or 205523 (with shuffle)
    local bokIcon = timers:AddCooldownIcon(bokCooldown, nil, -1, 0, true, true)
    function bokIcon:ShouldShowMainIcon()
        return false
    end

    local kegIcon = timers:AddCooldownIcon(kegCooldown, nil, -1, 0, true, true)

    local ehCooldown = timers:AddTrackedCooldown(322101)
    local ehIcon = timers:AddCooldownIcon(ehCooldown, nil, -2, 0, true, true)

    local bofCooldown = timers:AddTrackedCooldown(115181, talent_bof)
    local bofIcon = timers:AddCooldownIcon(bofCooldown, nil, -3, 0, true, true)

    local rskCooldown = timers:AddTrackedCooldown(107428, talent_rsk)
    local rskIcons = {}
    table.insert(rskIcons, timers:AddCooldownIcon(rskCooldown, nil, -3, 0, true, true, talent_not_bof))
    table.insert(rskIcons, timers:AddCooldownIcon(rskCooldown, nil, -4, 0, true, true, talent_bof))

    local rjwBuff = timers:AddTrackedBuff(116847, talent_rjw)
    local rjwCooldown = timers:AddTrackedCooldown(116847, talent_rjw)
    local rjwIcon = timers:AddCooldownIcon(rjwCooldown, nil, -0.5, -0.9, false, true)
    function rjwIcon:ShouldShowMainIcon()
        return false
    end
    local rjwLongBar = timers:AddAuraBar(rjwBuff, nil, 0.0, 0.6, 0.2)
    function rjwLongBar:GetRemDurationOr0IfInvisible(t)
        if (rjwCooldown.remDuration <= self.group.remGCD) then
            return 0
        else
            return self.aura.remDuration
        end
    end
    local rjwShortBar = timers:AddAuraBar(rjwBuff, nil, 0.0, 1.0, 0.7)
    function rjwShortBar:GetRemDurationOr0IfInvisible(t)
        if (rjwCooldown.remDuration <= self.group.remGCD) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, -1.5, -0.9, true, true)

    local celestialbCooldown = timers:AddTrackedCooldown(322507, talent_celestialb)
    local celestialbIcons = {}
    table.insert(celestialbIcons, timers:AddCooldownIcon(celestialbCooldown, nil, -1.5, -0.9, true, true, ERALIBTalent:CreateNot(talent_chib)))
    table.insert(celestialbIcons, timers:AddCooldownIcon(celestialbCooldown, nil, -2.5, -0.9, true, true, talent_chib))

    local todCooldown = timers:AddTrackedCooldown(322109)
    local todIcons = {}
    for i = 0, 3 do
        table.insert(todIcons, timers:AddCooldownIcon(todCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_chi_b_or_w, talent_elixir, talent_celestialb)))
    end

    local zenmedBuff = timers:AddTrackedBuff(115176, talent_zenmed)
    timers:AddAuraBar(zenmedBuff, nil, 0.3, 0.6, 0.3)

    local weaponsBuff = timers:AddTrackedBuff(387184, talent_weapons)
    timers:AddAuraBar(weaponsBuff, nil, 0.0, 0.0, 1.0)

    timers:AddAuraBar(timers:AddTrackedBuff(325190, talent_celestial_flames), nil, 1.0, 0.0, 0.0)
    timers:AddAuraBar(timers:AddTrackedBuff(386963, talent_charred), nil, 0.7, 0.3, 0.0)

    local instaVivifyTimer = timers:AddTrackedBuff(392883, talent_insta_vivify)
    ERACombatFrames_MonkRecurringIcon_instaVivify(timers, talent_insta_vivify, instaVivifyTimer)

    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED" and spellID == 392883) then
            self.lastInstaVivify = t
        end
    end

    timers.ehSlot = -1
    function timers:OnResetToIdle()
        self.ehSlot = ERALIB_GetSpellSlot(322101)
        self.lastInstaVivify = 0
    end

    function timers:DataUpdated(t)
        self.healthPercent = health.currentHealth / health.maxHealth

        if (instaVivifyTimer.remDuration > 0 and nrg.currentPower >= 30) then
            nrg.bar:SetBorderColor(0.0, 1.0, 0.0)
        else
            nrg.bar:SetBorderColor(1.0, 1.0, 1.0)
        end

        if (ehCooldown.remDuration <= self.occupied) then
            local baseValue = UnitAttackPower("player") * (1 + 0.04 * talent_healing_taken.rank) * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
            local ehheal = 1.2 * baseValue * (1 + 0.05 * talent_strong_eh.rank) -- scaling plutôt à 1.4 ?
            if (talent_scaling_eh:PlayerHasTalent()) then
                ehheal = ehheal * (2 - self.healthPercent)
            end
            local orbHeal
            if (self.ehSlot > 0) then
                local s = GetActionCount(self.ehSlot)
                if (s and s > 0) then
                    orbHeal = s * 3 * baseValue -- scaling plutôt à 3.5 voire 3.6 ?
                else
                    orbHeal = 0
                end
            else
                orbHeal = 0
            end
            local crit = GetCritChance() / 100
            health:SetHealing(orbHeal + ehheal * (1 + (crit + 0.15 * talent_strong_eh.rank) * (1 + 0.5 * talent_critical_eh.rank)))
        else
            health:SetHealing(0)
        end
    end

    local utility = ERACombatFrames_MonkUtility(cFrame, 1, true, monkTalents)
    utility:AddCooldown(-4.5, 0.9, 115176, nil, true, talent_zenmed)
    utility:AddCooldown(-3.5, 0.9, 132578, nil, true, ERALIBTalent:Create(124849)) -- niuzao
    utility:AddCooldown(-2.5, 0.9, 387184, nil, true, talent_weapons)
    utility:AddCooldown(-1.5, 0.9, 325153, nil, true, talent_exploding)
    utility:AddCooldown(-0.5, 0.9, 115399, nil, true, ERALIBTalent:Create(124991)) -- black ox brew
    utility:AddCooldown(1, 0, 122278, nil, true, ERALIBTalent:Create(124978))      -- dampen
    -- out of combat
    utility:AddCooldown(-2, 2, 123986, nil, false, talent_chib)
    utility:AddCooldown(-4, 2, 322507, nil, false, talent_celestialb)
    utility:AddCooldown(-2, 3, 121253, nil, false) -- keg
    utility:AddCooldown(-3, 3, 107428, nil, false, talent_rsk)
    utility:AddCooldown(-4, 3, 115181, nil, false, talent_bof)
    utility:AddCooldown(-5, 3, 322101, nil, false) -- eh

    --[[

    PRIO

    1 - expel harm low health
    2 - elixir low health
    3 - vivify low health
    4 - touch of death
    5 - keg smash
    6 - bok
    7 - bof
    8 - chib many targets
    9 - chiw
    10 - expel harm
    11 - elixir
    12 - chib few targets but healing
    13 - rjw many targets
    14 - rsk
    15 - rjw few targets
    16 - celestialb
    17 - keg smash long charge
    18 - elixir
    19 - vivify
    20 - chib

    ]]

    function ehIcon:computeAvailablePriority()
        if (timers.healthPercent < 0.4) then
            return 1
        elseif (timers.healthPercent < 0.8) then
            return 10
        else
            return 0
        end
    end

    local vivifyPrio = timers:AddPriority(1360980)
    function vivifyPrio:computePriority(t)
        if (nrg.currentPower >= 30 and instaVivifyTimer.remDuration > 0) then
            if (timers.healthPercent < 0.5) then
                return 2
            elseif (timers.healthPercent < 0.8) then
                return 19
            else
                return 0
            end
        else
            return 0
        end
    end

    for _, i in ipairs(todIcons) do
        function i:computeAvailablePriority()
            -- CHANGE 11 local u, nomana = IsUsableSpell(322109)
            local u, nomana = C_Spell.IsSpellUsable(322109)
            if (u or nomana) then
                return 4
            else
                return 0
            end
        end
    end

    function kegIcon:computeAvailablePriority()
        return 5
    end
    local kegchargedPrio = timers:AddPriority(594274)
    function kegchargedPrio:computePriority(t)
        if (kegCooldown.hasCharges and 0 < kegCooldown.currentCharges and kegCooldown.currentCharges < kegCooldown.maxCharges) then
            self.icon:SetDesaturated(kegCooldown.remDuration > 2)
            if (kegCooldown.remDuration < 3) then
                return 5
            else
                return 17
            end
        else
            return 0
        end
    end

    function bokIcon:computeAvailablePriority()
        return 6
    end

    function bofIcon:computeAvailablePriority()
        return 7
    end

    function chibIcon:computeAvailablePriority()
        if (enemies:GetCount() > 3) then
            return 8
        elseif (timers.healthPercent < 0.8) then
            return 12
        else
            return 20
        end
    end

    local rjwPrio = timers:AddPriority(606549)
    function rjwPrio:computePriority(t)
        if (talent_rjw:PlayerHasTalent() and rjwBuff.remDuration <= timers.occupied) then
            local threshold
            if (talent_strong_rsk.rank == 2) then
                threshold = 4
            elseif (talent_strong_rsk.rank == 1) then
                threshold = 3
            else
                threshold = 2
            end
            if (enemies:GetCount() >= threshold) then
                return 13
            else
                return 15
            end
        else
            return 0
        end
    end

    for _, i in ipairs(rskIcons) do
        function i:computeAvailablePriority()
            return 14
        end
    end

    for _, i in ipairs(celestialbIcons) do
        function i:computeAvailablePriority()
            return 16
        end
    end
end

ERACombatStagger = {}
ERACombatStagger.__index = ERACombatStagger
setmetatable(ERACombatStagger, { __index = ERACombatModule })

function ERACombatStagger:Create(cFrame, x, y, barWidth, barHeight, purifyingCooldown)
    local bar = {}
    setmetatable(bar, ERACombatStagger)
    bar.frame = CreateFrame("Frame", nil, UIParent, nil)
    bar.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    bar.frame:SetSize(barWidth, barHeight)
    bar.bar = ERACombatStatusBar:create(bar.frame, 0, 0, barWidth, barHeight, 1.0, 0.0, 0.0)
    bar.purifCooldown = purifyingCooldown
    bar:construct(cFrame, -1, 0.05, false, 1)
    return bar
end

function ERACombatStagger:EnterCombat()
    self:enter()
end
function ERACombatStagger:ExitCombat()
    self:exit()
end
function ERACombatStagger:ResetToIdle()
    self:exit()
end
function ERACombatStagger:SpecInactive(wasActive)
    if (wasActive) then
        self:exit()
    end
end
function ERACombatStagger:enter()
    self.frame:Show()
    self.bar:SetAll(UnitHealthMax("player"), UnitStagger("player"), 0, 0, 0)
end
function ERACombatStagger:exit()
    self.frame:Hide()
end

function ERACombatStagger:UpdateCombat(t)
    if (self.purifCooldown.hasCharges) then
        if (self.purifCooldown.currentCharges > 0) then
            if (self.purifCooldown.currentCharges >= self.purifCooldown.maxCharges) then
                self.bar:SetMainColor(1.0, 0.0, 1.0)
            else
                self.bar:SetMainColor(1.0, 0.0, 0.5)
            end
        else
            self.bar:SetMainColor(1.0, 0.0, 0.0)
        end
    else
        if (self.purifCooldown.remDuration > 0) then
            self.bar:SetMainColor(0.8, 0.0, 0.0)
        else
            self.bar:SetMainColor(1.0, 0.0, 0.5)
        end
    end
    self.bar:SetAll(UnitHealthMax("player"), UnitStagger("player"), 0, 0, 0)
end

function ERACombatStagger:CheckTalents()
    -- rien
end

------------------------------------------------------------------------------------------------------------------------
---- MW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkMistweaverSetup(cFrame, talent_diffuse, talent_dampen, talent_fortify)
    local talent_rsk = ERALIBTalent:Create(101508)
    local talent_renewing = ERALIBTalent:Create(101394)
    local talent_invigorating = ERALIBTalent:Create(101358)
    local talent_font = ERALIBTalent:Create(101406)
    local talent_pulse = ERALIBTalent:Create(101368)
    local talent_not_pulse = ERALIBTalent:CreateNotTalent(101368)
    local talent_fae = ERALIBTalent:Create(101359)
    local talent_chib = ERALIBTalent:Create(101527)
    local talent_chiw = ERALIBTalent:Create(101528)
    local talent_elixir = ERALIBTalent:Create(101374)
    local talent_tft = ERALIBTalent:Create(101410)
    local talent_rjw = ERALIBTalent:Create(101362)
    local talent_manatea = ERALIBTalent:Create(101379)
    local talent_not_manatea = ERALIBTalent:CreateNotTalent(101379)
    local talent_yulon = ERALIBTalent:Create(101397)
    local talent_chiji = ERALIBTalent:Create(101396)
    local talent_short_invoke = ERALIBTalent:Create(101381)
    local talent_revival = ERALIBTalent:Create(101378)
    local talent_restoral = ERALIBTalent:Create(101377)
    local talent_sheilun = ERALIBTalent:Create(101392)
    local talent_not_sheilun = ERALIBTalent:CreateNotTalent(101392)
    local talent_fast_sheilun = ERALIBTalent:Create(101405)
    local talent_cocoon = ERALIBTalent:Create(101390)
    local talent_stronger_vivify_1 = ERALIBTalent:Create(101510)
    local talent_stronger_vivify_2 = ERALIBTalent:Create(101357)
    local talent_insta_vivify = ERALIBTalent:Create(101513)
    local talent_ancient_teachings = ERALIBTalent:Create(101408)
    local talent_ancient_concordance = ERALIBTalent:Create(101371)
    local talent_normal_detox = ERALIBTalent:CreateNotTalent(102627)
    local talent_better_detox = ERALIBTalent:Create(102627)

    --[[
    local timers = ERACombatTimersGroup:Create(cFrame, -144, -101, 1.5, true, true, 2)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -36
    --]]
    local timers = ERACombatTimersGroup:Create(cFrame, -144, -44, 1.5, true, true, 2)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -93
    local first_column_X = 0.5
    local first_column_X_delta = -0.1
    local first_column_Y = 2
    ERACombatFrames_MonkTimerBars(timers, talent_diffuse, talent_dampen, talent_fortify)

    timers:AddChannelInfo(115175, 1.0) -- soothing mist
    timers:AddChannelInfo(117952, 1.0) -- crackling jade lightning

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 0, true, 0.0, 0.0, 1.0, false, 2)

    local health = ERACombatHealth:Create(cFrame, 0, -111, 144, 20, 2)
    local mana = ERACombatPower:Create(cFrame, 0, -131, 144, 16, 0, false, 0.0, 0.0, 1.0, 2)

    local sheilunBar = ERACombatFrames_MonkSheilunBar:create(cFrame, -72, -104, 144, 8, health, talent_sheilun) --(cFrame, x, y, length, thickness, combatHealth, talent_sheilun)

    local grid = ERACombatGrid:Create(cFrame, -151, -16, "BOTTOMRIGHT", 2, 115450, "Magic", "Poison", "Disease")

    timers:AddAuraBar(timers:AddTrackedBuff(197908, talent_manatea), nil, 0.2, 0.2, 1.0)
    ERACombatTimerMonkInvokeBar:create(timers, 574571, 0.0, 1.0, 0.2, talent_yulon, talent_short_invoke)
    ERACombatTimerMonkInvokeBar:create(timers, 877514, 1.0, 0.2, 0.0, talent_chiji, talent_short_invoke)

    local instaVivifyTimer = timers:AddTrackedBuff(392883, talent_insta_vivify)
    ERACombatFrames_MonkRecurringIcon_instaVivify(timers, talent_insta_vivify, instaVivifyTimer)

    timers:AddKick(116705, first_column_X + 1.8, first_column_Y + 3, ERALIBTalent:Create(101504))

    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, first_column_X, first_column_Y + 1, true, true)
    local chiwCooldown = timers:AddTrackedCooldown(115098, talent_chiw)
    local chiwIcon = timers:AddCooldownIcon(chiwCooldown, nil, first_column_X, first_column_Y + 1, true, true)

    local renewingCooldown = timers:AddTrackedCooldown(115151, talent_renewing)
    local renewingIcon = timers:AddCooldownIcon(renewingCooldown, nil, first_column_X, first_column_Y + 2, true, true)

    local fontCooldown = timers:AddTrackedCooldown(191837, talent_font)
    local fontIcon = timers:AddCooldownIcon(fontCooldown, nil, first_column_X, first_column_Y + 3, true, true)

    local pulseCooldown = timers:AddTrackedCooldown(124081, talent_pulse)
    local pulseIcon = timers:AddCooldownIcon(pulseCooldown, nil, first_column_X, first_column_Y + 4, true, true)

    local faeCooldown = timers:AddTrackedCooldown(388193, talent_fae)
    local faeIcon = timers:AddCooldownIcon(faeCooldown, nil, first_column_X + 0.9, first_column_Y + 2.5, true, true)

    ERACombatFrames_MonkSheilunIcon:create(timers, first_column_X + 0.9, first_column_Y + 3.5, sheilunBar, talent_sheilun, talent_fast_sheilun)

    local rjwCooldown = timers:AddTrackedCooldown(196725, talent_rjw)
    local rjwIcons = {}
    table.insert(rjwIcons, timers:AddCooldownIcon(rjwCooldown, nil, first_column_X + 0.9, first_column_Y + 3.5, true, true, talent_not_sheilun))
    table.insert(rjwIcons, timers:AddCooldownIcon(rjwCooldown, nil, first_column_X + 0.9, first_column_Y + 4.5, true, true, talent_sheilun))

    local elixirCooldown = timers:AddTrackedCooldown(122281, talent_elixir)
    local elixirIcon = timers:AddCooldownIcon(elixirCooldown, nil, first_column_X + 0.9, first_column_Y + 0.5, true, true)

    local ehCooldown = timers:AddTrackedCooldown(322101)
    local ehIcon = timers:AddCooldownIcon(ehCooldown, nil, first_column_X, first_column_Y, true, true)

    local tftBuff = timers:AddTrackedBuff(116680, talent_tft)
    local tftCooldown = timers:AddTrackedCooldown(116680, talent_tft)
    local tftIcons = {}
    table.insert(tftIcons, timers:AddCooldownIcon(tftCooldown, nil, first_column_X, first_column_Y + 4, true, true, talent_not_pulse))
    table.insert(tftIcons, timers:AddCooldownIcon(tftCooldown, nil, first_column_X, first_column_Y + 5, true, true, talent_pulse))
    for _, i in ipairs(tftIcons) do
        function i:OverrideHighlight()
            if (tftBuff.remDuration > self.group.occupied) then
                self.icon:Highlight()
            else
                self.icon:StopHighlight()
            end
            return true
        end
    end

    local instaRenewingChijiTimer = timers:AddTrackedBuff(343820, talent_chiji)
    timers:AddStacksProgressIcon(instaRenewingChijiTimer, 877514, first_column_X + 1.9, first_column_Y + 0.5, 3, talent_chiji).highlightWhenFull = true

    local selfRenewingBar = timers:AddAuraBar(timers:AddTrackedBuff(119611, talent_renewing), nil, 0.0, 1.0, 0.0)
    function selfRenewingBar:GetRemDurationOr0IfInvisible(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local selfEnvelopingBar = timers:AddAuraBar(timers:AddTrackedBuff(124682), nil, 0.6, 0.7, 0.0)
    function selfEnvelopingBar:GetRemDurationOr0IfInvisible(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    timers:AddAuraBar(timers:AddTrackedBuff(388026, talent_ancient_teachings), nil, 1.0, 0.2, 0.8)
    timers:AddAuraBar(timers:AddTrackedBuff(389391, talent_ancient_concordance), 3528275, 0.2, 0.1, 0.8)

    timers.lastInvoke = 0
    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID) then
            if (evt == "SPELL_AURA_APPLIED") then
                if (spellID == 392883) then
                    self.lastInstaVivify = t
                end
            elseif (evt == "SPELL_CAST_SUCCESS" and (spellID == 322118 or spellID == 325197)) then
                self.lastInvoke = t
            end
        end
    end
    function timers:OnResetToIdle()
        self.lastInstaVivify = 0
    end

    local rskIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(107428, talent_rsk), nil, 0, 0, true, true)
    function rskIcon:ShouldShowMainIcon()
        return false
    end
    function rskIcon:computeAvailablePriority()
        return 2
    end

    for _, i in ipairs(tftIcons) do
        function i:computeAvailablePriority()
            return 3
        end
    end

    local todPrio = timers:AddPriority(606552)
    function todPrio:computePriority(t)
        local u, nomana = C_Spell.IsSpellUsable(322109) -- CHANGE 11 IsUsableSpell(322109)
        if (u or nomana) then
            return 1
        else
            return 0
        end
    end

    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    local renewingDef = grid:AddTrackedBuff(119611, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, talent_renewing)
    local envelopingDef = grid:AddTrackedBuff(124682, 1, 1, 0.6, 0.7, 0.0, 0.6, 0.7, 0.0, nil)
    local cocoonDef = grid:AddTrackedBuff(116849, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, talent_cocoon)

    grid.vivifyHealing = 0
    function grid:UpdatedInCombat(t)
        local h = 0.89 * GetSpellBonusHealing() * (1 + 0.2 * talent_stronger_vivify_1.rank) * (1 + 0.2 * talent_stronger_vivify_2.rank) * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
        local crit = GetCritChance() / 100
        local nocrit = 1 - crit
        local acc = 0
        local minDur
        if (instaVivifyTimer.remDuration > 0) then
            minDur = timers.occupied
        else
            minDur = timers.occupied + 1.5 / timers.haste
        end
        for _, i in ipairs(renewingDef.instances) do
            if (i.remDuration > minDur) then
                local missing = i.unitframe.maxHealth - i.unitframe.currentHealth
                if (missing < h) then
                    acc = acc + missing
                else
                    if (missing < 2 * h) then
                        acc = acc + h * nocrit + missing * crit
                    else
                        acc = acc + h * (1 + crit)
                    end
                end
            end
        end
        self.invigoratingStandardHealing = 5 * h * (1 + crit)
        self.invigoratingPredictedHealing = acc
    end

    ERACombatFrames_MonkInvigoratingBar:create(cFrame, -64, -32, 100, 20, grid, instaVivifyTimer, talent_invigorating)

    local utility = ERACombatFrames_MonkUtility(cFrame, 2, false, talent_diffuse, talent_dampen, talent_fortify)
    utility:AddDefensiveDispellCooldown(3, 5, 115450, nil, talent_better_detox, "magic", "poison", "disease")
    utility:AddDefensiveDispellCooldown(3, 5, 115450, nil, talent_normal_detox, "magic")
    utility:AddCooldown(-1.5, 0.9, 116849, nil, true, talent_cocoon)
    utility:AddCooldown(-2.5, 0.9, 322118, nil, true, talent_yulon)
    utility:AddCooldown(-2.5, 0.9, 325197, nil, true, talent_chiji)
    utility:AddCooldown(-3.5, 0.9, 115310, nil, true, talent_revival)
    utility:AddCooldown(-3.5, 0.9, 388615, nil, true, talent_restoral)
    utility:AddCooldown(-4.5, 0.9, 197908, nil, true, talent_manatea)
    -- out of combat
    utility:AddCooldown(-2, 1.8, 122281, nil, false, talent_elixir)
    utility:AddCooldown(-3, 1.8, 123986, nil, false, talent_chib)
    utility:AddCooldown(-3, 1.8, 115098, nil, false, talent_chiw)
    utility:AddCooldown(-4, 1.8, 116680, nil, false, talent_tft)
    utility:AddCooldown(-1.5, 2.7, 115151, nil, false, talent_renewing)
    utility:AddCooldown(-2.5, 2.7, 388193, nil, false, talent_fae)
    utility:AddCooldown(-3.5, 2.7, 191837, nil, false, talent_font)
    utility:AddCooldown(-4.5, 2.7, 124081, nil, false, talent_pulse)
end

-- invigorating --

ERACombatFrames_MonkInvigoratingBar = {}
ERACombatFrames_MonkInvigoratingBar.__index = ERACombatFrames_MonkInvigoratingBar
setmetatable(ERACombatFrames_MonkInvigoratingBar, { __index = ERACombatFrames_PseudoResourceBar })

function ERACombatFrames_MonkInvigoratingBar:create(cFrame, x, y, width, height, grid, instaVivifyTimer, talent_invigorating)
    local inv = {}
    setmetatable(inv, ERACombatFrames_MonkInvigoratingBar)
    inv:constructPseudoResource(cFrame, x, y, width, height, 2, 0, false, 2)
    inv.grid = grid
    inv.instaVivifyTimer = instaVivifyTimer
    inv.talent = talent_invigorating
    return inv
end

function ERACombatFrames_MonkInvigoratingBar:GetMax(t)
    return self.grid.invigoratingStandardHealing
end
function ERACombatFrames_MonkInvigoratingBar:GetValue(t)
    return self.grid.invigoratingPredictedHealing
end

function ERACombatFrames_MonkInvigoratingBar:Updated(t)
    if (self.grid.isSolo or not self.talent:PlayerHasTalent()) then
        self:Hide()
    else
        if (self.instaVivifyTimer.remDuration > self.instaVivifyTimer.group.occupied) then
            self:SetBarColor(0.0, 1.0, 0.0)
        else
            self:SetBarColor(0.0, 0.5, 1.0)
        end
        self:Show()
    end
end

-- invoke --

ERACombatTimerMonkInvokeBar = {}
ERACombatTimerMonkInvokeBar.__index = ERACombatTimerMonkInvokeBar
setmetatable(ERACombatTimerMonkInvokeBar, { __index = ERACombatTimerStatusBar })

function ERACombatTimerMonkInvokeBar:create(group, iconID, r, g, b, talent, talent_short_invoke)
    local bar = {}
    setmetatable(bar, ERACombatTimerMonkInvokeBar)
    bar:construct(group, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    -- assignation
    bar.talent = talent
    bar.talent_short_invoke = talent_short_invoke
    return bar
end

function ERACombatTimerMonkInvokeBar:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatTimerMonkInvokeBar:GetRemDurationOr0IfInvisible(t)
    local std
    if (self.talent_short_invoke:PlayerHasTalent()) then
        std = 12
    else
        std = 25
    end
    local dur = std - (t - self.group.lastInvoke)
    if (dur > 0) then
        return dur
    else
        return 0
    end
end

-- sheilun --

ERACombatFrames_MonkSheilunBar = {}
ERACombatFrames_MonkSheilunBar.__index = ERACombatFrames_MonkSheilunBar
setmetatable(ERACombatFrames_MonkSheilunBar, { __index = ERACombatFrames_PseudoResourceBar })

function ERACombatFrames_MonkSheilunBar:create(cFrame, x, y, length, thickness, combatHealth, talent_sheilun)
    local sh = {}
    setmetatable(sh, ERACombatFrames_MonkSheilunBar)
    sh:constructPseudoResource(cFrame, x, y, length, thickness, 1, 0, false, 2)
    sh.talent = talent_sheilun
    sh:updateSlot()
    sh.stacks = 0
    sh.lastGain = 0
    sh.combatHealth = combatHealth
    sh:SetBarColor(0.0, 0.8, 0.5)
    return sh
end
function ERACombatFrames_MonkSheilunBar:OnResetToIdle()
    self.lastGain = 0
    self:updateSlot()
end
function ERACombatFrames_MonkSheilunBar:updateSlot()
    self.slot = ERALIB_GetSpellSlot(399491)
end

function ERACombatFrames_MonkSheilunBar:GetMax(t)
    return self.combatHealth.maxHealth
end
function ERACombatFrames_MonkSheilunBar:GetValue(t)
    if (self.slot and self.slot > 0) then
        local s = GetActionCount(self.slot)
        if (s and s > 0) then
            self:setStacks(t, s)
            local healing = s * 1.14 * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
            return healing
        else
            self:setStacks(t, 0)
            return 0
        end
    else
        self:setStacks(t, 0)
        return 0
    end
end
function ERACombatFrames_MonkSheilunBar:setStacks(t, s)
    if (self.stacks < s) then
        self.lastGain = t
    end
    self.stacks = s
end

function ERACombatFrames_MonkSheilunBar:Updated(t)
    if (self.talent:PlayerHasTalent()) then
        self:Show()
    else
        self:Hide()
    end
end

ERACombatFrames_MonkSheilunIcon = {}
ERACombatFrames_MonkSheilunIcon.__index = ERACombatFrames_MonkSheilunIcon
setmetatable(ERACombatFrames_MonkSheilunIcon, { __index = ERACombatTimerIcon })

function ERACombatFrames_MonkSheilunIcon:create(group, x, y, sheilunBar, talent_sheilun, talent_fast_sheilun)
    local i = {}
    setmetatable(i, ERACombatFrames_MonkSheilunIcon)
    i:construct(group, x, y, 1242282, true)
    i.talent = talent_sheilun
    i.talent_fast = talent_fast_sheilun
    i.stacks = 0
    i.sheilunBar = sheilunBar
    return i
end

function ERACombatFrames_MonkSheilunIcon:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        self.talentActive = true
        return true
    else
        self:hide()
        self.talentActive = false
        return false
    end
end

function ERACombatFrames_MonkSheilunIcon:updateIconCooldownTexture()
    return 1242282
end

function ERACombatFrames_MonkSheilunIcon:updateAfterReset(t)
    self:updateIconCooldownTexture()
end

function ERACombatFrames_MonkSheilunIcon:updateTimerDurationAndMainIconVisibility(t, timerStandardDuration)
    local s = self.sheilunBar.stacks
    if (s > 0) then
        self.shouldShowMainIcon = true
        if (s ~= self.stacks) then
            self.stacks = s
            self.icon:SetMainText(self.stacks)
        end
        self.icon:SetOverlayValue((10 - s) / 10)
    else
        self.shouldShowMainIcon = false
    end
    if (s < 10 and self.sheilunBar.lastGain > 0) then
        local dur
        if (self.talent_fast:PlayerHasTalent()) then
            dur = 4
        else
            dur = 8
        end
        local elapsed = t - self.sheilunBar.lastGain
        self.timerDuration = dur - (elapsed - dur * math.floor(elapsed / dur))
    else
        self.timerDuration = -1
    end
end

------------------------------------------------------------------------------------------------------------------------
---- WW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

---comment
---@param cFrame any
---@param enemies any
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, monkTalents)
    local talent_whirling = ERALIBTalent:Create(125011)
    local talent_not_whirling = ERALIBTalent:CreateNotTalent(125011)
    local talent_windlord = ERALIBTalent:Create(125022)
    local talent_fae_active = ERALIBTalent:Create(126026)
    local talent_fae_passive = ERALIBTalent:Create(124816)
    local talent_fae_any = ERALIBTalent:CreateOr(talent_fae_active, talent_fae_passive)
    local talent_chib = ERALIBTalent:Create(124952)
    local talent_sef = ERALIBTalent:Create(124826)
    local talent_inner_peace = ERALIBTalent:Create(125021)
    local talent_capacitor = ERALIBTalent:Create(124832)
    local talent_insta_vivify = ERALIBTalent:Create(124935)
    local talent_spinning_ignition = ERALIBTalent:Create(124822)
    local talent_combat_wisdom = ERALIBTalent:Create(125025)

    local points = ERACombatPointsUnitPower:Create(cFrame, -101, 6, 12, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil, 2, 3)
    points.talentedIdlePoints = 2
    points.talentIdle = talent_combat_wisdom

    local nrg = ERACombatPower:Create(cFrame, -161, -6, 121, 16, 3, false, 1.0, 1.0, 0.0, 3)
    local tigerPalmConsumer60 = nrg:AddConsumer(60, 606551, ERALIBTalent:CreateNot(talent_inner_peace))
    local tigerPalmConsumer55 = nrg:AddConsumer(55, 606551, talent_inner_peace)

    local health = ERACombatHealth:Create(cFrame, 0, -77, 144, 22, 3)
    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 3, true, 1, 1, 0, false, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 32, 1, true, false, 3)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -22
    local first_column_X = 0.5

    ---@type MonkDisruptTimerIconParams
    local disruptParams = {
        kickX = first_column_X + 1,
        kickY = 1,
        paraX = first_column_X + 1,
        paraY = 2
    }

    ERACombatFrames_MonkTimerBars(timers, monkTalents, disruptParams)

    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED") then
            if (spellID == 392883) then
                self.lastInstaVivify = t
            end
        end
    end

    function timers:OnResetToIdle()
        self.spinningSlot = ERALIB_GetSpellSlot(101546)
        self.lastInstaVivify = 0
    end

    local rskCooldown = timers:AddTrackedCooldown(107428)
    local rskIcon = timers:AddCooldownIcon(rskCooldown, nil, -1, 0, true, true)
    local fofCooldown = timers:AddTrackedCooldown(113656)
    local fofIcon = timers:AddCooldownIcon(fofCooldown, nil, -2, 0, true, true)
    local whirlingCooldown = timers:AddTrackedCooldown(152175, talent_whirling)
    local whirlingIcon = timers:AddCooldownIcon(whirlingCooldown, nil, -3, 0, true, true)

    local ehCooldown = timers:AddTrackedCooldown(322101)
    local ehIcons = {}
    table.insert(ehIcons, timers:AddCooldownIcon(ehCooldown, nil, -3, 0, true, true, talent_not_whirling))
    table.insert(ehIcons, timers:AddCooldownIcon(ehCooldown, nil, -4, 0, true, true, talent_whirling))

    local chibIcon = timers:AddAuraIcon(timers:AddTrackedBuff(460490, talent_chib), 0, 0, nil, talent_chib)
    function chibIcon:ShouldShowWhenAbsent()
        return false
    end
    chibIcon.icon:Highlight()

    local faeCooldown = timers:AddTrackedCooldown(388193, talent_fae_active)
    local faeIcon = timers:AddCooldownIcon(faeCooldown, nil, -1.5, -0.9, true, true, talent_fae_active)

    local windlordCooldown = timers:AddTrackedCooldown(392983, talent_windlord)
    local windlordIcons = {}
    table.insert(windlordIcons, timers:AddCooldownIcon(windlordCooldown, nil, -1.5, -0.9, true, true, ERALIBTalent:CreateNot(talent_fae_active)))
    table.insert(windlordIcons, timers:AddCooldownIcon(windlordCooldown, nil, -2.5, -0.9, true, true, talent_fae_active))

    local todCooldown = timers:AddTrackedCooldown(322109)
    local todIcons = {}
    for i = 0, 3 do
        table.insert(todIcons, timers:AddCooldownIcon(todCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_fae_active, talent_windlord)))
    end

    --[[
    local morechiTimer = timers:AddTrackedBuff(129914, talent_power_strikes)
    function points:PointsUpdated(t)
        if (timers.cFrame.inCombat) then
            local incr
            if (morechiTimer.remDuration > timers.remGCD) then
                self:SetBorderColor(0.5, 0.0, 1.0)
                incr = 3
            else
                self:SetBorderColor(1.0, 1.0, 0.0)
                incr = 2
            end
            if (self.currentPoints + incr > self.maxPoints) then
                self:SetPointColor(1.0, 0.5, 0.0)
            else
                self:SetPointColor(0.0, 1.0, 0.5)
            end
        else
            self:SetBorderColor(1.0, 1.0, 0.0)
            self:SetPointColor(0.0, 1.0, 0.5)
        end
    end
    ]] --

    local instaVivifyTimer = timers:AddTrackedBuff(392883, talent_insta_vivify)
    --ERACombatFrames_MonkRecurringIcon_instaVivify(timers, talent_insta_vivify, instaVivifyTimer)
    --[[
    local powerStrikesTimer = ERACombatFrames_MonkRecurringIcon:create(timers, 629484, talent_power_strikes, morechiTimer)
    function powerStrikesTimer:getLastAndDuration()
        return self.group.lastPowerStrikes, 15
    end
    ]] --

    local spinningIcon = ERACombatTimersMonkSpinningIcon:create(timers, first_column_X, 1)
    local spinningBuff = timers:AddTrackedBuff(325202, ERALIBTalent:Create(124834))
    local spinningIgnition = timers:AddTrackedBuff(393057, talent_spinning_ignition)

    timers:AddStacksProgressIcon(spinningIgnition, nil, first_column_X, 2, 30, talent_spinning_ignition)
    local capacitorBuff = timers:AddTrackedBuff(393039, talent_capacitor)
    timers:AddStacksProgressIcon(capacitorBuff, nil, first_column_X, 3, 20, talent_capacitor)
    timers:AddKick(116705, first_column_X + 1, 3, ERALIBTalent:Create(101504))

    local faexposureTimer = timers:AddTrackedDebuff(395414, talent_fae_any)
    timers:AddAuraBar(faexposureTimer, 3528275, 0.7, 0.0, 1.0)

    --[[
    local forbiddenTechniqueBar = timers:AddAuraBar(timers:AddTrackedBuff(393099), nil, 0.7, 0.0, 0.0)
    function forbiddenTechniqueBar:GetRemDurationOr0IfInvisible(t)
        local u, nomana = C_Spell.IsSpellUsable(322109) -- CHANGE 11 IsUsableSpell(322109)
        if (u or nomana) then
            self.view.icon:SetDesaturated(false)
        else
            self.view.icon:SetDesaturated(true)
        end
        return self.aura.remDuration
    end
    ]]                                                                   --

    timers:AddAuraBar(timers:AddTrackedBuff(116768), nil, 0.9, 0.0, 0.7) -- free BoK
    timers:AddAuraBar(timers:AddTrackedBuff(125174), nil, 1.0, 1.0, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(137639, talent_sef), nil, 1.0, 0.0, 1.0)
    timers:AddAuraBar(spinningBuff, 606543, 0.0, 0.8, 0.2)
    local ignitionBar = timers:AddAuraBar(spinningIgnition, 988193, 0.5, 1.0, 0.2)
    function ignitionBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration < 6) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    function timers:DataUpdated(t)
        if (instaVivifyTimer.remDuration > 0 and nrg.currentPower >= 30) then
            nrg.bar:SetBorderColor(0.0, 1.0, 0.0)
        else
            nrg.bar:SetBorderColor(1.0, 1.0, 1.0)
        end
    end

    local utility = ERACombatFrames_MonkUtility(cFrame, 3, true, monkTalents)
    utility:AddCooldown(5, 4, 101545, nil, true)                                   -- fsk
    utility:AddCooldown(-1.5, 0.9, 122470, nil, true)                              -- karma
    utility:AddCooldown(-2.5, 0.9, 123904, nil, true, ERALIBTalent:Create(125013)) -- xuen
    utility:AddCooldown(-3.5, 0.9, 137639, nil, true, talent_sef)
    -- out of combat
    utility:AddCooldown(-3, 2, 388193, nil, false, talent_fae_active)
    utility:AddCooldown(-4, 2, 392983, nil, false, talent_windlord)
    utility:AddCooldown(-2, 3, 107428, nil, false) -- rsk
    utility:AddCooldown(-3, 3, 113656, nil, false) -- fof
    utility:AddCooldown(-4, 3, 152175, nil, false, talent_whirling)
    utility:AddCooldown(-5, 3, 322101, nil, false) -- eh


    --[[

    PRIO

    1 - touch of death
    2 - palm refill 2 chi
    3 - rsk
    4 - fae exposure
    X - palm dump
    6 - fof
    7 - windlord
    8 - whirling
    9 - CJL
    10 - sck
    11 : chi burst

    ]]

    for _, i in ipairs(todIcons) do
        function i:computeAvailablePriority()
            local u, nomana = C_Spell.IsSpellUsable(322109) -- CHANGE 11 IsUsableSpell(322109)
            if (u or nomana) then
                return 1
            else
                return 0
            end
        end
    end

    local tigerDump = timers:AddPriority(606551)
    function tigerDump:computePriority(t)
        if (nrg.currentPower >= 50 and points.currentPoints < 2) then
            return 2
        else
            if (nrg.maxPower - nrg.currentPower < 20 and points.maxPoints - points.currentPoints >= 2) then
                return 5
            else
                return 0
            end
        end
    end

    function rskIcon:computeAvailablePriority()
        return 3
    end

    function faeIcon:computeAvailablePriority()
        return 4
    end

    function fofIcon:computeAvailablePriority()
        return 6
    end

    for _, i in ipairs(windlordIcons) do
        function i:computeAvailablePriority()
            return 7
        end
    end

    function whirlingIcon:computeAvailablePriority()
        return 8
    end

    local cjlPrio = timers:AddPriority(606542)
    function cjlPrio:computePriority(t)
        if (capacitorBuff.stacks >= 20) then
            return 9
        else
            return 0
        end
    end

    local sckPrio = timers:AddPriority(606543)
    function sckPrio:computePriority(t)
        if ((spinningBuff.remDuration > timers.occupied and spinningBuff.remDuration <= 6) or (spinningIgnition.remDuration > timers.occupied and spinningIgnition.remDuration <= 6)) then
            return 10
        else
            return 0
        end
    end

    local chibPrio = timers:AddPriority(135734)
    function chibPrio:computePriority()
        if (chibIcon.aura.remDuration > 0) then
            return 11
        else
            return 0
        end
    end
end

ERACombatTimersMonkSpinningIcon = {}
ERACombatTimersMonkSpinningIcon.__index = ERACombatTimersMonkSpinningIcon
setmetatable(ERACombatTimersMonkSpinningIcon, { __index = ERACombatTimersHintProgressIcon })

function ERACombatTimersMonkSpinningIcon:create(group, x, y)
    local pr = {}
    setmetatable(pr, ERACombatTimersMonkSpinningIcon)
    pr.stacks = 0
    pr:constructProgress(group, 606543, x, y)
    return pr
end

function ERACombatTimersMonkSpinningIcon:ComputeIsVisible(t)
    local slot = self.group.spinningSlot
    if (slot and slot > 0) then
        local s = GetActionCount(slot)
        if (s and s > 0) then
            if (s > 1) then
                if (self.stacks ~= s) then
                    self.stacks = s
                    self.icon:SetMainText(self.stacks)
                end
                self.icon:SetOverlayValue((5 - s) / 5)
                return true
            else
                self.stacks = 1
                return false
            end
        else
            self.stacks = 0
            return false
        end
    else
        self.stacks = 0
        return false
    end
end

function ERACombatTimersMonkSpinningIcon:talentIncactive()
    self.stacks = 0
end

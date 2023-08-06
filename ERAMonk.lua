-- TODO
-- tout

function ERACombatFrames_MonkSetup(cFrame)
    ERACombatGlobals_SpecID1 = 268
    ERACombatGlobals_SpecID2 = 270
    ERACombatGlobals_SpecID3 = 269

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mwActive = ERACombatOptions_IsSpecActive(2)
    local wwActive = ERACombatOptions_IsSpecActive(3)

    local talent_diffuse = ERALIBTalent:Create(101515)
    local talent_dampen = ERALIBTalent:Create(101522)
    local talent_fortify = ERALIBTalent:Create(101496)

    local enemies = ERACombatEnemies:Create(cFrame, 1, 3)

    if (bmActive) then
        ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, talent_diffuse, talent_dampen, talent_fortify)
    end
    if (mwActive) then
        ERACombatFrames_MonkMistweaverSetup(cFrame, talent_diffuse, talent_dampen, talent_fortify)
    end
    if (wwActive) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, talent_diffuse, talent_dampen, talent_fortify)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkUtility(cFrame, spec, includeDetox, talent_diffuse, talent_dampen, talent_fortify)
    local utility = ERACombatUtilityFrame:Create(cFrame, -16, -212, spec)

    utility:AddTrinket2Cooldown(-3, 0, nil)
    utility:AddTrinket1Cooldown(-2, 0, nil)
    utility:AddCooldown(-1, 0, 388686, nil, true, ERALIBTalent:Create(101519)) -- tiger statue
    utility:AddCooldown(0, 0, 115203, nil, true, talent_fortify)
    utility:AddWarlockHealthStone(-0.5, -0.9)
    utility:AddCooldown(1, 0, 122278, nil, true, talent_dampen)
    utility:AddCooldown(2, 0, 122783, nil, true, talent_diffuse)
    utility:AddRacial(3, 1)
    utility:AddCooldown(4, 1, 115078, nil, true, ERALIBTalent:Create(101506))                            -- paralysis
    utility:AddCooldown(3, 2, 119381, nil, true)                                                         -- sweep
    utility:AddCooldown(4, 2, 116844, nil, true, ERALIBTalent:Create(101516))                            -- rop
    utility:AddCooldown(4, 2, 198898, nil, true, ERALIBTalent:Create(101464))                            -- song
    utility:AddCooldown(3, 3, 119996, nil, true, ERALIBTalent:Create(101512))                            -- do transfer
    utility:AddCooldown(4, 3, 101643, nil, true, ERALIBTalent:Create(101512)).alphaWhenOffCooldown = 0.2 -- put transfer
    utility:AddWarlockPortal(5, 3)
    utility:AddCooldown(3, 4, 109132, 574574, true, ERALIBTalent:CreateNotTalent(101502))                -- roll
    utility:AddCooldown(3, 4, 115008, 607849, true, ERALIBTalent:Create(101502))                         -- torpedo
    utility:AddCooldown(4, 4, 116841, nil, true, ERALIBTalent:Create(101507))                            -- lust
    if (includeDetox) then
        utility:AddDefensiveDispellCooldown(3, 5, 218164, nil, ERALIBTalent:Create(101416), "Poison", "Disease")
    end
    utility:AddCooldown(4, 5, 115546, nil, true).alphaWhenOffCooldown = 0.2                              -- taunt
    utility:AddCooldown(5, 5, 115315, nil, true, ERALIBTalent:Create(101535)).alphaWhenOffCooldown = 0.2 -- ox statue
    utility:AddCooldown(3, 0, 115313, nil, true, ERALIBTalent:Create(101532)).alphaWhenOffCooldown = 0.2 -- serpent statue

    return utility
end

function ERACombatFrames_MonkTimerBars(timers, talent_diffuse, talent_dampen, talent_fortify)
    timers:AddAuraBar(timers:AddTrackedBuff(122783, talent_diffuse), nil, 0.7, 0.6, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(122278, talent_dampen), nil, 0.6, 0.6, 0.0)
    timers:AddAuraBar(timers:AddTrackedBuff(120954, talent_fortify), nil, 0.8, 0.8, 0.0)
end

------------------------------------------------------------------------------------------------------------------------
---- BM ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, talent_diffuse, talent_dampen, talent_fortify)
    local talent_rsk = ERALIBTalent:Create(101508)
    local talent_bof = ERALIBTalent:Create(101464)
    local talent_not_bof = ERALIBTalent:CreateNotTalent(101464)
    local talent_rjw = ERALIBTalent:Create(101549)
    local talent_chib = ERALIBTalent:Create(101527)
    local talent_chiw = ERALIBTalent:Create(101528)
    local talent_chi_b_or_w = ERALIBTalent:CreateOr(talent_chib, talent_chiw)
    local talent_chi_b_nor_w = ERALIBTalent:CreateNOR(talent_chib, talent_chiw)
    local talent_elixir = ERALIBTalent:Create(101458)
    local talent_celestialb = ERALIBTalent:Create(101463)
    local talent_strong_rsk = ERALIBTalent:Create(101523)
    local talent_strong_eh = ERALIBTalent:Create(101530)
    local talent_critical_eh = ERALIBTalent:Create(101526)
    local talent_scaling_eh = ERALIBTalent:Create(101499)
    local talent_healing_taken = ERALIBTalent:Create(101529)
    local talent_weapons = ERALIBTalent:Create(101539)
    local talent_not_weapons = ERALIBTalent:CreateNotTalent(101539)
    local talent_bonedust = ERALIBTalent:Create(101552)
    local talent_exploding = ERALIBTalent:Create(101542)
    local talent_zenmed = ERALIBTalent:Create(101547)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 42, 1, false, 1)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -36
    local first_column_X = 0.5
    ERACombatFrames_MonkTimerBars(timers, talent_diffuse, talent_dampen, talent_fortify)

    local kegCooldown = timers:AddTrackedCooldown(121253)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 3, true, 1, 1, 0, false, 1)

    local barWidth = 151
    local barX = -181

    local health = ERACombatHealth:Create(cFrame, barX, 26, barWidth, 22, 1)

    ERACombatStagger:Create(cFrame, barX, 3, barWidth, 11)

    local nrg = ERACombatPower:Create(cFrame, barX, -6, barWidth, 16, 3, false, 1.0, 1.0, 0.0, 1)
    nrg:AddConsumer(25, 606551)
    nrg:AddConsumer(65, 606551)
    local kegConsumer = nrg:AddConsumer(40, 594274)
    function kegConsumer:ComputeVisibility()
        return kegCooldown.remDuration <= 3
    end
    function kegConsumer:ComputeIconVisibility()
        if (kegCooldown.remDuration <= 0 or kegCooldown.remDuration + 0.05 <= timers.occupied) then
            self.icon:SetDesaturated(false)
        else
            self.icon:SetDesaturated(true)
        end
        return true
    end

    timers:AddKick(116705, first_column_X, 3, ERALIBTalent:Create(101504))

    local purifCooldown = timers:AddTrackedCooldown(119582)
    local purifIcon = timers:AddCooldownIcon(purifCooldown, nil, -4.5, 1, true, true)

    local bokIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(205523), nil, -1, 0, true, true)
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
    timers:AddAuraBar(rjwBuff, nil, 0.0, 1.0, 0.7)
    local rjwCooldown = timers:AddTrackedCooldown(116847, talent_rjw)
    local rjwIcon = timers:AddCooldownIcon(rjwCooldown, nil, -0.5, -0.9, false, true)

    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, -1.5, -0.9, true, true)
    local chiwCooldown = timers:AddTrackedCooldown(115098, talent_chiw)
    local chiwIcon = timers:AddCooldownIcon(chiwCooldown, nil, -1.5, -0.9, true, true)

    local elixirCooldown = timers:AddTrackedCooldown(122281, talent_elixir)
    local elixirIcons = {}
    table.insert(elixirIcons, timers:AddCooldownIcon(elixirCooldown, nil, -1.5, -0.9, true, true, talent_chi_b_nor_w))
    table.insert(elixirIcons, timers:AddCooldownIcon(elixirCooldown, nil, -2.5, -0.9, true, true, talent_chi_b_or_w))

    local celestialbCooldown = timers:AddTrackedCooldown(322507, talent_celestialb)
    local celestialbIcons = {}
    for i = 0, 2 do
        table.insert(celestialbIcons, timers:AddCooldownIcon(celestialbCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_chi_b_or_w, talent_elixir)))
    end

    local todCooldown = timers:AddTrackedCooldown(322109)
    local todIcons = {}
    for i = 0, 3 do
        table.insert(todIcons, timers:AddCooldownIcon(todCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_chi_b_or_w, talent_elixir, talent_celestialb)))
    end

    --local zenmedBuff = timers:AddTrackedBuff(115176, talent_zenmed)
    --timers:AddAuraBar(zenmedBuff, nil, 0.3, 0.6, 0.3)

    local weaponsBuff = timers:AddTrackedBuff(387184, talent_weapons)
    timers:AddAuraBar(weaponsBuff, nil, 1.0, 0.0, 0.0)

    local boneTimer = timers:AddTrackedDebuff(386276, talent_bonedust)
    timers:AddAuraBar(boneTimer, nil, 0.7, 0.3, 0.0)

    local instaVivifyTimer = timers:AddTrackedBuff(392883, ERALIBTalent:Create(101513))

    function timers:DataUpdated(t)
        self.healthPercent = health.currentHealth / health.maxHealth

        if (instaVivifyTimer.remDuration > 0 and nrg.currentPower >= 30) then
            nrg.bar:SetBorderColor(0.0, 1.0, 0.0)
        else
            nrg.bar:SetBorderColor(1.0, 1.0, 1.0)
        end

        if (ehCooldown.remDuration <= self.occupied) then
            local ehheal = 1.2 * UnitAttackPower("player") * (1 + talent_strong_eh.rank / 20) * (1 + 0.04 * talent_healing_taken.rank) * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
            if (talent_scaling_eh:PlayerHasTalent()) then
                ehheal = ehheal * (2 - self.healthPercent)
            end
            local crit = GetCritChance() / 100 + 0.15 * talent_strong_eh.rank
            health:SetHealing(ehheal * (1 + crit * (1 + 0.5 * talent_critical_eh.rank)))
        else
            health:SetHealing(0)
        end
    end

    local utility = ERACombatFrames_MonkUtility(cFrame, 1, true, talent_diffuse, talent_dampen, talent_fortify)
    utility:AddCooldown(5, 4, 324312, nil, true, ERALIBTalent:Create(101440))      -- clash
    utility:AddCooldown(-0.5, 0.9, 115399, nil, true, ERALIBTalent:Create(101450)) -- black ox brew
    utility:AddCooldown(-1.5, 0.9, 115176, nil, true, talent_zenmed)
    utility:AddCooldown(-2.5, 0.9, 132578, nil, true, ERALIBTalent:Create(101544)) -- niuzao
    utility:AddCooldown(-3.5, 0.9, 387184, nil, true, talent_weapons)
    utility:AddCooldown(-3.5, 0.9, 386276, nil, true, ERALIBTalent:CreateAnd(talent_bonedust, talent_not_weapons))
    utility:AddCooldown(-4.5, 0.9, 386276, nil, true, ERALIBTalent:CreateAnd(talent_bonedust, talent_weapons))
    for i = 0, 2 do
        utility:AddCooldown(-3.5 - i, 0.9, 325153, nil, true, ERALIBTalent:CreateAnd(talent_exploding, ERALIBTalent:CreateCount(i, talent_weapons, talent_bonedust)))
    end
    -- out of combat
    utility:AddCooldown(-2, 2, 115098, nil, false, talent_chiw)
    utility:AddCooldown(-2, 2, 123986, nil, false, talent_chib)
    utility:AddCooldown(-3, 2, 122281, nil, false, talent_elixir)
    utility:AddCooldown(-4, 2, 322507, nil, false, talent_celestialb)
    utility:AddCooldown(-5, 2, 322109, nil, false) -- touch of death
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
    17 - elixir
    18 - vivify
    19 - chib

    ]]

    function ehIcon:computeAvailablePriority()
        local u, nomana = IsUsableSpell(322109)
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
                return 18
            else
                return 0
            end
        else
            return 0
        end
    end

    for _, i in ipairs(todIcons) do
        function i:computeAvailablePriority()
            local u, nomana = IsUsableSpell(322109)
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
            return 19
        end
    end

    function chiwIcon:computeAvailablePriority()
        return 9
    end

    for _, i in ipairs(elixirIcons) do
        function i:computeAvailablePriority()
            if (timers.healthPercent < 0.66) then
                return 11
            elseif (timers.healthPercent < 0.8) then
                return 17
            else
                return 0
            end
        end
    end

    local rjwPrio = timers:AddPriority(606549)
    function rjwPrio:computePriority(t)
        if (rjwBuff.remDuration <= timers.occupied) then
            local ec = enemies:GetCount()
            local threshold
            if (talent_strong_rsk.rank == 2) then
                threshold = 4
            elseif (talent_strong_rsk.rank == 1) then
                threshold = 3
            else
                threshold = 2
            end
            if (ec >= threshold) then
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

function ERACombatStagger:Create(cFrame, x, y, barWidth, barHeight)
    local bar = {}
    setmetatable(bar, ERACombatStagger)
    bar.frame = CreateFrame("Frame", nil, UIParent, nil)
    bar.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    bar.frame:SetSize(barWidth, barHeight)
    bar.bar = ERACombatStatusBar:create(bar.frame, 0, 0, barWidth, barHeight, 1.0, 0.0, 0.0)
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
    self.bar:SetAll(UnitHealthMax("player"), 2000 + UnitStagger("player"), 0, 0, 0)
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
    local talent_font = ERALIBTalent:Create(101406)
    local talent_pulse = ERALIBTalent:Create(101368)
    local talent_fae = ERALIBTalent:Create(101359)
    local talent_chib = ERALIBTalent:Create(101527)
    local talent_chiw = ERALIBTalent:Create(101528)
    local talent_elixir = ERALIBTalent:Create(101374)
    local talent_tft = ERALIBTalent:Create(101410)
    local talent_manatea = ERALIBTalent:Create(101379)
    local talent_yulon = ERALIBTalent:Create(101397)
    local talent_chiji = ERALIBTalent:Create(101396)
    local talent_cocoon = ERALIBTalent:Create(101390)
    local talent_stronger_vivify_1 = ERALIBTalent:Create(101510)
    local talent_stronger_vivify_2 = ERALIBTalent:Create(101357)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -101, 1.5, true, 2)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -36
    local first_column_X = 0.5
    local first_column_Y = 2
    ERACombatFrames_MonkTimerBars(timers, talent_diffuse, talent_dampen, talent_fortify)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 0, true, 0.0, 0.0, 1.0, false, 2)

    local health = ERACombatHealth:Create(cFrame, 0, -111, 144, 20, 2)
    local mana = ERACombatPower:Create(cFrame, 0, -131, 144, 16, 0, false, 0.0, 0.0, 1.0, 2)

    local grid = ERACombatGrid:Create(cFrame, -133, -16, "BOTTOMRIGHT", 2, 115450, "Magic", "Poison", "Disease")

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

    local elixirCooldown = timers:AddTrackedCooldown(122281, talent_elixir)
    local elixirIcon = timers:AddCooldownIcon(elixirCooldown, nil, first_column_X + 0.9, first_column_Y + 0.5, true, true)

    local tftCooldown = timers:AddTrackedCooldown(116680, talent_tft)
    local tftIcon = timers:AddCooldownIcon(tftCooldown, nil, first_column_X, first_column_Y, true, true)

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

    timers.lastInvoke = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (evt == "SPELL_CAST_SUCCESS" and sourceGUY == self.cFrame.playerGUID and (spellID == 322118 or spellID == 325197)) then
            self.lastInvoke = t
        end
    end

    local rskIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(107428, talent_rsk), nil, 0, 0, true, true)
    function rskIcon:ShouldShowMainIcon()
        return false
    end
    function rskIcon:computeAvailablePriority()
        return 1
    end

    timers:AddAuraBar(timers:AddTrackedBuff(197908, talent_manatea), nil, 0.2, 0.2, 1.0)
    ERACombatTimerInvokeBar:create(timers, 574571, 0.0, 1.0, 0.2, talent_yulon)
    ERACombatTimerInvokeBar:create(timers, 877514, 1.0, 0.2, 0.0, talent_chiji)

    local instaVivifyTimer = timers:AddTrackedBuff(392883, ERALIBTalent:Create(101513))

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
            if (i.remDuration > timers.occupied) then
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

    ERACombatFrames_MonkInvigoratingBar:create(cFrame, -64, -32, 100, 20, grid, instaVivifyTimer)

    local utility = ERACombatFrames_MonkUtility(cFrame, 2, false, talent_diffuse, talent_dampen, talent_fortify)
    utility:AddCooldown(-1.5, 0.9, 116849, nil, true, talent_cocoon)
    utility:AddCooldown(-2.5, 0.9, 322118, nil, true, talent_yulon)
    utility:AddCooldown(-2.5, 0.9, 325197, nil, true, talent_chiji)
    utility:AddCooldown(-3.5, 0.9, 115310, nil, true) -- revival
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

ERACombatFrames_MonkInvigoratingBar = {}
ERACombatFrames_MonkInvigoratingBar.__index = ERACombatFrames_MonkInvigoratingBar
setmetatable(ERACombatFrames_MonkInvigoratingBar, { __index = ERACombatFrames_PseudoResourceBar })

function ERACombatFrames_MonkInvigoratingBar:create(cFrame, x, y, width, height, grid, instaVivifyTimer)
    local inv = {}
    setmetatable(inv, ERACombatFrames_MonkInvigoratingBar)
    inv:constructPseudoResource(cFrame, x, y, width, height, 2, 0, false, 2)
    inv.grid = grid
    inv.instaVivifyTimer = instaVivifyTimer
    return inv
end

function ERACombatFrames_MonkInvigoratingBar:GetMax(t)
    return self.grid.invigoratingStandardHealing
end
function ERACombatFrames_MonkInvigoratingBar:GetValue(t)
    return self.grid.invigoratingPredictedHealing
end

function ERACombatFrames_MonkInvigoratingBar:Updated(t)
    if (self.instaVivifyTimer.remDuration > self.instaVivifyTimer.group.occupied) then
        self:SetBarColor(0.0, 1.0, 0.0)
    else
        self:SetBarColor(0.0, 0.5, 1.0)
    end
end

ERACombatTimerInvokeBar = {}
ERACombatTimerInvokeBar.__index = ERACombatTimerInvokeBar
setmetatable(ERACombatTimerInvokeBar, { __index = ERACombatTimerStatusBar })

function ERACombatTimerInvokeBar:create(group, iconID, r, g, b, talent)
    local bar = {}
    setmetatable(bar, ERACombatTimerInvokeBar)
    bar:construct(group, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    -- assignation
    bar.talent = talent
    return bar
end

function ERACombatTimerInvokeBar:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatTimerInvokeBar:GetRemDurationOr0IfInvisible(t)
    local dur = 25 - (t - self.group.lastInvoke)
    if (dur > 0) then
        return dur
    else
        return 0
    end
end

------------------------------------------------------------------------------------------------------------------------
---- WW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, talent_diffuse, talent_dampen, talent_fortify)
    local talent_whirling = ERALIBTalent:Create(101474)
    local talent_not_whirling = ERALIBTalent:CreateNotTalent(101474)
    local talent_windlord = ERALIBTalent:Create(101491)
    local talent_rjw = ERALIBTalent:Create(101436)
    local talent_fae = ERALIBTalent:Create(101488)
    local talent_chib = ERALIBTalent:Create(101527)
    local talent_chiw = ERALIBTalent:Create(101528)
    local talent_chi_b_or_w = ERALIBTalent:CreateOr(talent_chib, talent_chiw)
    local talent_chi_b_nor_w = ERALIBTalent:CreateNOR(talent_chib, talent_chiw)
    local talent_sef = ERALIBTalent:Create(101429)
    local talent_serenity = ERALIBTalent:Create(101428)
    local talent_or_sef_serenity = ERALIBTalent:CreateOr(talent_sef, talent_serenity)
    local talent_nor_sef_serenity = ERALIBTalent:CreateNOR(talent_sef, talent_serenity)
    local talent_bonedust = ERALIBTalent:Create(101485)
    local talent_power_strikes = ERALIBTalent:Create(101424)
    local talent_several_blackout = ERALIBTalent:Create(101435)
    local talent_karma = ERALIBTalent:Create(101420)
    local talent_spinning_ignition = ERALIBTalent:Create(101417)
    local talent_capacitor = ERALIBTalent:Create(101480)

    local points = ERACombatPointsUnitPower:Create(cFrame, -101, 6, 12, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil, 2, 3)

    local nrg = ERACombatPower:Create(cFrame, -161, -6, 121, 16, 3, false, 1.0, 1.0, 0.0, 3)
    local tigerPalmConsumer = nrg:AddConsumer(50, 606551)

    local health = ERACombatHealth:Create(cFrame, 0, -77, 144, 22, 3)
    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 3, true, 1, 1, 0, false, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 32, 1, false, 3)
    timers.offsetIconsX = -32
    timers.offsetIconsY = -22
    local first_column_X = 0.5
    ERACombatFrames_MonkTimerBars(timers, talent_diffuse, talent_dampen, talent_fortify)

    function timers:OnResetToIdle()
        self.spinningSlot = -1
        for s = 1, 72 do
            local actionType, id = GetActionInfo(s)
            if (actionType == "spell" and id == 101546) then
                self.spinningSlot = s
                break
            end
        end
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

    local rjwCooldown = timers:AddTrackedCooldown(116847, talent_rjw)
    local rjwIcon = timers:AddCooldownIcon(rjwCooldown, nil, -0.5, -0.9, true, true)

    local chiwCooldown = timers:AddTrackedCooldown(115098, talent_chiw)
    local chiwIcon = timers:AddCooldownIcon(chiwCooldown, nil, -1.5, -0.9, true, true)
    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, -1.5, -0.9, true, true)

    local faeCooldown = timers:AddTrackedCooldown(388193, talent_fae)
    local faeIcons = {}
    table.insert(faeIcons, timers:AddCooldownIcon(faeCooldown, nil, -1.5, -0.9, true, true, talent_chi_b_nor_w))
    table.insert(faeIcons, timers:AddCooldownIcon(faeCooldown, nil, -2.5, -0.9, true, true, talent_chi_b_or_w))

    local windlordCooldown = timers:AddTrackedCooldown(392983, talent_windlord)
    local windlordIcons = {}
    for i = 0, 2 do
        table.insert(windlordIcons, timers:AddCooldownIcon(windlordCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_chi_b_or_w, talent_fae)))
    end

    local todCooldown = timers:AddTrackedCooldown(322109)
    local todIcons = {}
    for i = 0, 3 do
        table.insert(todIcons, timers:AddCooldownIcon(todCooldown, nil, -1.5 - i, -0.9, true, true, ERALIBTalent:CreateCount(i, talent_chi_b_or_w, talent_fae, talent_windlord)))
    end

    local morechiTimer = timers:AddTrackedBuff(129914, talent_power_strikes)
    function points:PointsUpdated(t)
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
    end

    local instaVivifyTimer = timers:AddTrackedBuff(392883, ERALIBTalent:Create(101513))

    local spinningIcon = ERACombatTimersMonkSpinningIcon:create(timers, first_column_X, 1)
    local spinningBuff = timers:AddTrackedBuff(325202, ERALIBTalent:Create(101437))
    local spinningIgnition = timers:AddTrackedBuff(393057, talent_spinning_ignition)

    local boneTimer = timers:AddTrackedDebuff(386276, talent_bonedust)

    timers:AddStacksProgressIcon(spinningIgnition, nil, first_column_X, 2, 30, talent_spinning_ignition)
    timers:AddStacksProgressIcon(timers:AddTrackedBuff(392989, talent_capacitor), nil, first_column_X, 3, 20, talent_capacitor)
    timers:AddKick(116705, first_column_X + 1, 3, ERALIBTalent:Create(101504))

    timers:AddAuraBar(timers:AddTrackedBuff(125174, talent_karma), nil, 1.0, 1.0, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(137639, talent_sef), nil, 1.0, 0.0, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(152173, talent_serenity), nil, 1.0, 0.0, 1.0)
    timers:AddAuraBar(boneTimer, nil, 0.7, 0.3, 0.0)
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

    local utility = ERACombatFrames_MonkUtility(cFrame, 3, true, talent_diffuse, talent_dampen, talent_fortify)
    utility:AddCooldown(5, 4, 101545, nil, true, ERALIBTalent:Create(101432))      -- fsk
    utility:AddCooldown(-1.5, 0.9, 122470, nil, true, talent_karma)
    utility:AddCooldown(-2.5, 0.9, 123904, nil, true, ERALIBTalent:Create(101473)) -- xuen
    utility:AddCooldown(-3.5, 0.9, 137639, nil, true, talent_sef)
    utility:AddCooldown(-3.5, 0.9, 152173, nil, true, talent_serenity)
    utility:AddCooldown(-3.5, 0.9, 386276, nil, true, ERALIBTalent:CreateAnd(talent_bonedust, talent_nor_sef_serenity))
    utility:AddCooldown(-4.5, 0.9, 386276, nil, true, ERALIBTalent:CreateAnd(talent_bonedust, talent_or_sef_serenity))
    -- out of combat
    utility:AddCooldown(-2, 2, 115098, nil, false, talent_chiw)
    utility:AddCooldown(-2, 2, 123986, nil, false, talent_chib)
    utility:AddCooldown(-3, 2, 388193, nil, false, talent_fae)
    utility:AddCooldown(-4, 2, 392983, nil, false, talent_windlord)
    utility:AddCooldown(-5, 2, 322109, nil, false) -- touch of death
    utility:AddCooldown(-2, 3, 107428, nil, false) -- rsk
    utility:AddCooldown(-3, 3, 113656, nil, false) -- fof
    utility:AddCooldown(-4, 3, 152175, nil, false, talent_whirling)
    utility:AddCooldown(-5, 3, 322101, nil, false) -- eh


    --[[

    PRIO

    1 - touch of death
    2 - palm refill 1 or 2 chi
    3 - rsk
    4 - rjw
    5 - palm dump
    6 - fof
    7 - chib many targets
    8 - whirling
    9 - chiw
    10 - windlord
    11 - fae
    12 - chib few targets
    13 - sck

    ]]

    for _, i in ipairs(todIcons) do
        function i:computeAvailablePriority()
            local u, nomana = IsUsableSpell(322109)
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
            local incr
            if (morechiTimer.remDuration > timers.remGCD) then
                incr = 3
            else
                incr = 2
            end
            if (nrg.maxPower - nrg.currentPower < 20 and points.maxPoints - points.currentPoints >= incr) then
                return 5
            else
                return 0
            end
        end
    end

    function rskIcon:computeAvailablePriority()
        return 3
    end

    function rjwIcon:computeAvailablePriority()
        local ec = enemies:GetCount()
        if (ec > 3 or (ec > 1 and not talent_several_blackout:PlayerHasTalent())) then
            return 4
        else
            return 0
        end
    end

    function fofIcon:computeAvailablePriority()
        return 6
    end

    function chibIcon:computeAvailablePriority()
        if (enemies:GetCount() > 2) then
            return 7
        else
            return 12
        end
    end

    function whirlingIcon:computeAvailablePriority()
        return 8
    end

    function chiwIcon:computeAvailablePriority()
        return 9
    end

    for _, i in ipairs(windlordIcons) do
        function i:computeAvailablePriority()
            return 10
        end
    end

    for _, i in ipairs(faeIcons) do
        function i:computeAvailablePriority()
            return 11
        end
    end

    local sckPrio = timers:AddPriority(606543)
    function sckPrio:computePriority(t)
        if ((spinningBuff.remDuration > timers.occupied and spinningBuff.remDuration <= 6) or (spinningIgnition.remDuration > timers.occupied and spinningIgnition.remDuration <= 6)) then
            return 13
        else
            local ec = enemies:GetCount()
            if (ec > 1) then
                if (boneTimer.remDuration > 0 or spinningIcon.stacks + 1 >= ec) then
                    return 13
                else
                    return 0
                end
            else
                return 0
            end
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
    pr:constructProgress(group, 606543, x, y, ERALIBTalent:Create(101434))
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

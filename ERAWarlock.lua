function ERACombatFrames_WarlockSetup(cFrame)
    local affliActive = ERACombatOptions_IsSpecActive(1)
    local demonoActive = ERACombatOptions_IsSpecActive(2)
    local destroActive = ERACombatOptions_IsSpecActive(3)

    ERACombatHealth:Create(cFrame, 0, -88, 128, 22, affliActive, demonoActive, destroActive)
    ERACombatHealth:Create(cFrame, 0, -111, 128, 16, affliActive, demonoActive, destroActive):SetUnitID("pet")

    ERACombatPointsUnitPower:Create(cFrame, -32, -32, 7, 5, 0.1, 0.6, 0.1, 1.0, 0.0, 1.0, nil, 1, affliActive, demonoActive).idlePoints = 3

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -101, 128, 16, -1, true, 0.0, 0.0, 0.0, true, affliActive, demonoActive, destroActive)

    if (affliActive) then
        ERACombatFrames_WarlockAffliSetup(cFrame)
    end
    if (demonoActive) then
        ERACombatFrames_WarlockDemonoSetup(cFrame)
    end
    if (destroActive) then
        ERACombatFrames_WarlockDestroSetup(cFrame)
    end
end

function ERACombatFrames_WarlockModulesSetup(cFrame, ...)
    local timers = ERACombatTimersGroup:Create(cFrame, -101, -11, 1.5, false, ...)
    timers.offsetIconsX = 8
    timers.offsetIconsY = 16

    local talent_tp = ERALIBTalent:Create(91441)

    local utility = ERACombatUtilityFrame:Create(cFrame, 0, -181, ...)

    utility:AddTrinket2Cooldown(-5, 0, nil)
    utility:AddTrinket1Cooldown(-4, 0, nil)
    utility:AddWarlockHealthStone(-1, 0)
    utility:AddCooldown(0, 0, 108416, nil, true, ERALIBTalent:Create(91444))                               -- pact
    utility:AddCooldown(1, 0, 104773, nil, true)                                                           -- resolve
    utility:AddCooldown(2, 0, 333889, nil, true, ERALIBTalent:Create(91439))                               -- fel domination
    utility:AddCooldown(3, 0, 6358, nil, true).showOnlyIfPetSpellKnown = true                              --  succubus
    utility:AddCooldown(3, 0, 17767, nil, true).showOnlyIfPetSpellKnown = true                             --  voidwalker
    utility:AddRacial(0.5, -0.9).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(3.5, 3.9, 48018, nil, true, talent_tp).alphaWhenOffCooldown = 0.1                  -- place circle
    utility:AddDefensiveDispellCooldown(3.5, 4.9, 89808, nil, nil, "Magic").showOnlyIfPetSpellKnown = true -- imp dispell
    utility:AddCooldown(3, 3, 48020, nil, true, talent_tp)                                                 -- teleport circle
    utility:AddWarlockPortal(4, 3)
    utility:AddCooldown(3, 2, 6789, nil, true, ERALIBTalent:Create(91457))                                 -- coil
    utility:AddCooldown(3, 2, 5484, nil, true, ERALIBTalent:Create(91458))                                 -- howl
    utility:AddCooldown(4, 2, 30283, nil, true, ERALIBTalent:Create(91452))                                -- shadowfury
    utility:AddCooldown(3, 1, 384069, nil, true, ERALIBTalent:Create(91450))                               -- shadowflame
    utility:AddCooldown(4, 1, 328774, nil, true, ERALIBTalent:Create(91442))                               -- amplify

    ERACombatWarlockRush:create(utility, 0, 6)

    ERACombatWarlockCurses:create(cFrame, 256, 128, timers, ...)

    return timers, utility
end

--------------------------------------------------------------------------------------------------------------------------------
---- RUSH --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatWarlockRush = {}
ERACombatWarlockRush.__index = ERACombatWarlockRush
setmetatable(ERACombatWarlockRush, { __index = ERACombatUtilityIcon })

function ERACombatWarlockRush:create(group, x, y)
    local mi = {}
    setmetatable(mi, ERACombatWarlockRush)
    local talent = nil
    mi.aura = group:AddTrackedBuff(111400, talent)
    mi:construct(group, x, y, 538043, 1, true, talent)
    mi.icon:Beam()
    return mi
end

function ERACombatWarlockRush:updateIdle(t)
    self:update(t)
end
function ERACombatWarlockRush:doUpdateCombat(t)
    self:update(t)
end
function ERACombatWarlockRush:update(t)
    if ((self.aura.remDuration > 0 or self.aura.stacks > 0) and not IsPlayerMoving()) then
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

------------------------------------------------------------------------------------------------------------------------
---- AFFLICTION --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockAffliSetup(cFrame)
    local timers, utility = ERACombatFrames_WarlockModulesSetup(cFrame, 1)

    local talent_strong_corruption = ERALIBTalent:Create(91555)
    local talent_infinite_corruption = ERALIBTalent:Create(91575)
    local talent_finite_corruption = ERALIBTalent:CreateNotTalent(91575)
    local talent_drainsoul = ERALIBTalent:Create(91566)
    local talent_fast_dots = ERALIBTalent:Create(91580)
    local talent_haunt = ERALIBTalent:Create(91552)
    local talent_haunted = ERALIBTalent:Create(91506)
    local talent_big_agony = ERALIBTalent:Create(91572)
    local talent_strong_agony = ERALIBTalent:Create(115461)
    local talent_strong_filler = ERALIBTalent:Create(91564)
    local talent_strong_unstable = ERALIBTalent:Create(91429)
    local talent_siphon = ERALIBTalent:Create(91574)
    local talent_taint = ERALIBTalent:Create(91556)
    local talent_singularity = ERALIBTalent:Create(91557)
    local talent_rot = ERALIBTalent:Create(91578)
    local talent_glare = ERALIBTalent:Create(91554)
    local talent_draindemise = ERALIBTalent:Create(91567)

    -- TIMERS --

    timers:AddChannelInfo(198590, 1)
    timers:AddChannelInfo(234153, 1)

    local first_column_X = 0

    local corruptionTimerForInfinite = timers:AddTrackedDebuff(146739, talent_infinite_corruption)
    timers:AddMissingAura(corruptionTimerForInfinite, nil, first_column_X, 3, true)

    timers:AddKick(19647, first_column_X, 2, nil, true)
    timers:AddOffensiveDispellCooldown(19505, first_column_X, 4, nil, "Magic").displayOnlyIfSpellPetKnown = true

    local hauntCooldown = timers:AddTrackedCooldown(48181, talent_haunt)
    local hauntCooldownIcon = timers:AddCooldownIcon(hauntCooldown, nil, -2, 0, true, true)

    local taintCooldown = timers:AddTrackedCooldown(278350, talent_taint)
    local taintCooldownIcon = timers:AddCooldownIcon(taintCooldown, nil, -3, 0, true, true)

    local singularityCooldown = timers:AddTrackedCooldown(205179, talent_singularity)
    local singularityCooldownIcon = timers:AddCooldownIcon(singularityCooldown, nil, -3, 0, true, true)

    local rotCooldown = timers:AddTrackedCooldown(386997, talent_rot)
    local rootIcons = {}
    table.insert(rootIcons, timers:AddCooldownIcon(rotCooldown, nil, -3, 0, true, true, ERALIBTalent:CreateNOR(talent_taint, talent_singularity)))
    table.insert(rootIcons, timers:AddCooldownIcon(rotCooldown, nil, -4, 0, true, true, ERALIBTalent:CreateOr(talent_taint, talent_singularity)))
    local rotTimer = timers:AddTrackedDebuff(386997, talent_rot)
    timers:AddAuraBar(rotTimer, nil, 0.0, 0.0, 1.0)

    local glareCooldown = timers:AddTrackedCooldown(205180, talent_glare)
    local glareCooldownIcon = timers:AddCooldownIcon(glareCooldown, nil, -2.5, -0.9, true, true)

    local draindemiseTimer = timers:AddTrackedBuff(334320, talent_draindemise)
    local draindemiseBar = timers:AddAuraBar(draindemiseTimer, nil, 0.6, 0.8, 0.5)
    function draindemiseBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration <= 5 or self.aura.stacks >= 48) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    timers:AddStacksProgressIcon(draindemiseTimer, nil, first_column_X, 1, 50)

    -- out of combat
    utility:AddCooldown(-2, 3, 48181, nil, false, talent_haunt)
    utility:AddCooldown(-3, 3, 278350, nil, false, talent_taint)
    utility:AddCooldown(-3, 3, 205179, nil, false, talent_singularity)
    utility:AddCooldown(-2, 2, 386997, nil, false, talent_rot)
    utility:AddCooldown(-3, 2, 205180, nil, false, talent_glare)

    -- DOT TRACKER --

    local dotracker =
        ERACombatDOTracker:Create(
            timers,
            nil,
            1,
            function(tracker)
                local mult = 1 + talent_strong_filler.rank / 10
                if (talent_drainsoul:PlayerHasTalent()) then
                    if (UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") < 0.2) then
                        return 1.392192 * mult
                    else
                        return 0.696096 * mult
                    end
                else
                    return 0.5265 * mult
                end
            end
        )

    -- unstable
    local unstableDOT = dotracker:AddDOT(
        316099,
        nil,
        0.9,
        0.9,
        0.2,
        1.5,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 17.85
            else
                return 21
            end
        end,
        function(dotDef, currentTarget)
            return 0, 2.6565 * (1 + talent_strong_unstable.rank * 0.15) * (1 + talent_haunted.rank * 0.2), true
        end,
        nil,
        true,
        0.5,
        0.5,
        0.1
    )

    -- corruption
    local corruptionDOT = dotracker:AddDOT(
        146739,
        nil,
        0.9,
        0.2,
        0.2,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 11.9
            else
                return 14
            end
        end,
        function(dotDef, currentTarget)
            return 0.138, 0.91 * (1 + talent_strong_corruption.rank * 0.075) * (1 + talent_haunted.rank * 0.2), true
        end,
        talent_finite_corruption
    )

    -- agony
    local agonyDOT = dotracker:AddDOT(
        980,
        nil,
        0.9,
        0.5,
        0.1,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 15.3
            else
                return 18
            end
        end,
        function(dotDef, currentTarget)
            local mult
            if (talent_big_agony:PlayerHasTalent()) then
                mult = 18
            else
                mult = 10
            end
            return 0, 0.0161805 * 9 * mult * (1 + talent_strong_agony.rank * 0.075) * (1 + talent_haunted.rank * 0.2), true
        end
    )

    -- siphon
    local siphonDOT = dotracker:AddDOT(
        63106,
        nil,
        0.0,
        0.7,
        0.0,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 12.75
            else
                return 15
            end
        end,
        function(dotDef, currentTarget)
            return 0, 0.96 * (1 + talent_haunted.rank * 0.2), true
        end,
        talent_siphon
    )

    --[[

    PRIO

    1 - refresh agony urgent
    2 - haunt
    3 - drain life soul rot
    4 - agony
    5 - drain life
    6 - unstable
    7 - singularity / taint (if enemies > 1)
    8 - corruption
    9 - siphon
    10 - glare
    11 - taint few enemies

    ]]

    local agonyPrio = timers:AddPriority(136139)
    function agonyPrio:computePriority(t)
        if (agonyDOT.remDurationOnCurrentTarget < 3) then
            return 1
        elseif (agonyDOT.isWorthRefresing) then
            return 4
        else
            return 0
        end
    end

    function hauntCooldownIcon:computeAvailablePriority()
        return 2
    end

    local drainLifePrio = timers:AddPriority(136169)
    function drainLifePrio:computePriority(t)
        if (rotTimer.remDuration > timers.remGCD) then
            return 3
        elseif (draindemiseTimer.stacks >= 50) then
            return 5
        else
            return 0
        end
    end

    local unstablePrio = timers:AddPriority(136228)
    function unstablePrio:computePriority(t)
        if (unstableDOT.isWorthRefresing) then
            return 6
        else
            return 0
        end
    end

    function singularityCooldownIcon:computeAvailablePriority()
        return 7
    end

    function taintCooldownIcon:computeAvailablePriority()
        if (dotracker.enemiesTracker:GetCount() > 1) then
            return 7
        else
            return 11
        end
    end

    local corruptionPrio = timers:AddPriority(136118)
    function corruptionPrio:computePriority(t)
        if (talent_infinite_corruption:PlayerHasTalent()) then
            if (corruptionTimerForInfinite.remDuration <= 3.57) then
                return 8
            else
                return 0
            end
        else
            if (corruptionDOT.isWorthRefresing) then
                return 8
            else
                return 0
            end
        end
    end

    local siphonPrio = timers:AddPriority(136188)
    function siphonPrio:computePriority(t)
        if (talent_siphon:PlayerHasTalent() and siphonDOT.isWorthRefresing) then
            return 9
        else
            return 0
        end
    end

    function glareCooldownIcon:computeAvailablePriority()
        return 10
    end
end

------------------------------------------------------------------------------------------------------------------------
---- DEMONOLOGY --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockDemonoSetup(cFrame)
    local timers, utility = ERACombatFrames_WarlockModulesSetup(cFrame, 2)
    local first_column_X = 0

    ERACombatFrames_WarlockDemonologyImps:create(cFrame, -128, -136)

    local talent_doom = ERALIBTalent:Create(91548)
    local talent_soulstrike = ERALIBTalent:Create(91537)
    local talent_vilefiend = ERALIBTalent:Create(91538)
    local talent_or_soulstrike_vilefiend = ERALIBTalent:CreateOr(talent_soulstrike, talent_vilefiend)
    local talent_nor_soulstrike_vilefiend = ERALIBTalent:CreateNOR(talent_soulstrike, talent_vilefiend)
    local talent_guillotine = ERALIBTalent:Create(115460)
    local talent_strength = ERALIBTalent:Create(91540)
    local talent_bilescourge = ERALIBTalent:Create(91541)
    local talent_or_strength_bilescourge = ERALIBTalent:CreateOr(talent_strength, talent_bilescourge)
    local talent_nor_strength_bilescourge = ERALIBTalent:CreateNOR(talent_strength, talent_bilescourge)
    local talent_siphon = ERALIBTalent:Create(91521)
    local talent_tyrant = ERALIBTalent:Create(91550)
    local talent_portal = ERALIBTalent:Create(91515)

    timers:AddKick(89766, first_column_X, 2, nil, true)
    timers:AddKick(19647, first_column_X, 2, nil, true)
    timers:AddOffensiveDispellCooldown(19505, first_column_X, 3, nil, "Magic").displayOnlyIfSpellPetKnown = true

    local dreadstalkersCooldown = timers:AddTrackedCooldown(104316)
    local dreadstalkersCooldownIcon = timers:AddCooldownIcon(dreadstalkersCooldown, nil, -2, 0, true, true)

    local soulstrikeCooldown = timers:AddTrackedCooldown(264057, talent_soulstrike)
    local soulstrikeCooldownIcon = timers:AddCooldownIcon(soulstrikeCooldown, nil, -3, 0, true, true)
    local vilefiendCooldown = timers:AddTrackedCooldown(264119, talent_vilefiend)
    local vilefiendCooldownIcon = timers:AddCooldownIcon(vilefiendCooldown, nil, -3, 0, true, true)

    local guillotineCooldown = timers:AddTrackedCooldown(386833, talent_guillotine)
    local guillotineIcons = {}
    table.insert(guillotineIcons, timers:AddCooldownIcon(guillotineCooldown, nil, -3, 0, true, true, talent_nor_soulstrike_vilefiend))
    table.insert(guillotineIcons, timers:AddCooldownIcon(guillotineCooldown, nil, -4, 0, true, true, talent_or_soulstrike_vilefiend))

    local strengthCooldown = timers:AddTrackedCooldown(267171, talent_strength)
    local strengthCooldownIcon = timers:AddCooldownIcon(strengthCooldown, nil, -2, -1, true, true)
    local bilescourgeCooldown = timers:AddTrackedCooldown(267211, talent_bilescourge)
    local bilescourgeCooldownIcon = timers:AddCooldownIcon(bilescourgeCooldown, nil, -2, -1, true, true)

    local siphonCooldown = timers:AddTrackedCooldown(264130, talent_siphon)
    local siphonIcons = {}
    table.insert(siphonIcons, timers:AddCooldownIcon(siphonCooldown, nil, -2, -1, true, true, talent_nor_strength_bilescourge))
    table.insert(siphonIcons, timers:AddCooldownIcon(siphonCooldown, nil, -3, -1, true, true, talent_or_strength_bilescourge))

    local tyrantCooldown = timers:AddTrackedCooldown(265187, talent_tyrant)
    local tyrantIcons = {}
    for i = 0, 2 do
        table.insert(tyrantIcons, timers:AddCooldownIcon(tyrantCooldown, nil, -2 - i, 0, true, true, ERALIBTalent:CreateCount(i, talent_strength, talent_siphon)))
    end

    local doomTimer = timers:AddTrackedDebuff(603, talent_doom)
    timers:AddAuraBar(doomTimer, nil, 0.0, 0.6, 0.1)

    local portalTimer = timers:AddTrackedBuff(267218, talent_portal)
    timers:AddAuraBar(portalTimer, nil, 0.8, 0.0, 0.9)

    utility:AddCooldown(-3, 0, 111898, nil, true, ERALIBTalent:Create(91531)) -- felguard
    utility:AddCooldown(-4, 0, 267217, nil, true, talent_portal)              -- portal

    -- out of combat
    utility:AddCooldown(-2, 4, 264057, nil, false, talent_soulstrike)
    utility:AddCooldown(-2, 4, 264119, nil, false, talent_vilefiend)
    utility:AddCooldown(-3, 4, 386833, nil, false, talent_guillotine)
    utility:AddCooldown(-2, 3, 104316, nil, false) -- stalkers
    utility:AddCooldown(-3, 3, 267171, nil, false, talent_strength)
    utility:AddCooldown(-3, 3, 267211, nil, false, talent_bilescourge)
    utility:AddCooldown(-2, 2, 264130, nil, false, talent_siphon)
    utility:AddCooldown(-3, 2, 265187, nil, false, talent_tyrant)

    local enemies = ERACombatEnemies:Create(cFrame, 2)

    --[[

    PRIO

    1 - dreadstalkers
    2 - bilescourge aoe
    3 - soul strike
    4 - doom
    5 - guillotine
    6 - vilefiend
    7 - strength
    8 - tyrant

    ]]

    function dreadstalkersCooldownIcon:computeAvailablePriority()
        return 1
    end

    function bilescourgeCooldownIcon:computeAvailablePriority()
        if (enemies:GetCount() > 2) then
            return 2
        else
            return 0
        end
    end

    function soulstrikeCooldownIcon:computeAvailablePriority()
        return 3
    end

    local doomPrio = timers:AddPriority(136122)
    function doomPrio:computePriority(t)
        if (doomTimer.remDuration > 0 or not talent_doom:PlayerHasTalent()) then
            return 0
        else
            return 4
        end
    end

    for _, i in ipairs(guillotineIcons) do
        function i:computeAvailablePriority()
            return 5
        end
    end

    function vilefiendCooldownIcon:computeAvailablePriority()
        return 6
    end

    function strengthCooldownIcon:computeAvailablePriority()
        return 7
    end

    for _, i in ipairs(tyrantIcons) do
        function i:computeAvailablePriority()
            return 8
        end
    end
end

ERACombatFrames_WarlockDemonologyImps = {}
ERACombatFrames_WarlockDemonologyImps.__index = ERACombatFrames_WarlockDemonologyImps
setmetatable(ERACombatFrames_WarlockDemonologyImps, { __index = ERACombatFrames_PseudoResourceBar })

function ERACombatFrames_WarlockDemonologyImps:create(cFrame, x, y)
    local imps = {}
    setmetatable(imps, ERACombatFrames_WarlockDemonologyImps)
    imps:constructPseudoResource(cFrame, x, y, 100, 20, 2, 1, true, 2)

    imps:updateSlot()

    return imps
end
function ERACombatFrames_WarlockDemonologyImps:OnResetToIdle()
    self:updateSlot()
end
function ERACombatFrames_WarlockDemonologyImps:updateSlot()
    self.slot = ERALIB_GetSpellSlot(196277)
end

function ERACombatFrames_WarlockDemonologyImps:GetMax(t)
    return 9
end
function ERACombatFrames_WarlockDemonologyImps:GetValue(t)
    if (self.slot and self.slot > 0) then
        return GetActionCount(self.slot)
    else
        return 0
    end
end

------------------------------------------------------------------------------------------------------------------------
---- DESTRUCTION -------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatWarlockDestru_boltCastTime(haste, timers, backdraftTimer, ruinTimer, azjaqirBoltTimer, azjaqirTalent)
    local mult
    if (backdraftTimer.remDuration > timers.occupied) then
        mult = 0.7
    else
        mult = 1.0
    end
    if (ruinTimer.remDuration > timers.occupied) then
        mult = mult * 0.5
    end
    if (azjaqirBoltTimer.remDuration > timers.occupied) then
        mult = mult * (1 - azjaqirTalent.rank / 10)
    end
    return mult * 3 / haste
end

function ERACombatFrames_WarlockDestroSetup(cFrame)
    local timers, utility = ERACombatFrames_WarlockModulesSetup(cFrame, 3)
    local first_column_X = 0

    local talent_conflagrate = ERALIBTalent:Create(91590)
    local talent_backdraft = ERALIBTalent:Create(91589)
    local talent_soulfire = ERALIBTalent:Create(91492)
    local talent_not_soulfire = ERALIBTalent:CreateNotTalent(91492)
    local talent_demonfire = ERALIBTalent:Create(91586)
    local talent_rift = ERALIBTalent:Create(91423)
    local talent_havoc = ERALIBTalent:Create(91493)
    local talent_not_havoc = ERALIBTalent:CreateNotTalent(91493)
    local talent_cataclysm = ERALIBTalent:Create(91487)
    local talent_shadowburn = ERALIBTalent:Create(91582)
    local talent_eradication = ERALIBTalent:Create(91501)
    local talent_not_ritualist = ERALIBTalent:CreateNotTalent(91475)
    local talent_ritualist_1 = ERALIBTalent:CreateRank(91475, 1)
    local talent_ritualist_2 = ERALIBTalent:CreateRank(91475, 2)
    local talent_azjaqir = ERALIBTalent:Create(91480)

    local embers = ERACombatWarlockDestruEmbers:create(cFrame)

    local backdraftTimer = timers:AddTrackedBuff(117828, talent_backdraft)

    local eradicationTimer = timers:AddTrackedDebuff(196414, talent_eradication)
    timers:AddAuraBar(eradicationTimer, nil, 0.8, 0.0, 1.0)

    local immoTimer = timers:AddTrackedDebuff(157736)
    local immoBar = timers:AddAuraBar(immoTimer, nil, 1.0, 1.0, 0.0)
    function immoBar:GetRemDurationOr0IfInvisible(t)
        local rem = self.aura.remDuration
        self.view.icon:SetDesaturated(rem >= 6.5)
        return rem
    end
    timers:AddMissingAura(immoTimer, nil, first_column_X, 4.5, true)

    local conflagCooldown = timers:AddTrackedCooldown(17962, talent_conflagrate)
    local conflagCooldownIcon = timers:AddCooldownIcon(conflagCooldown, nil, first_column_X, 1, true, true)

    local shadowburnCooldown = timers:AddTrackedCooldown(17877, talent_shadowburn)
    local shadowburnCooldownIcon = timers:AddCooldownIcon(shadowburnCooldown, nil, first_column_X, 2, true, true)
    function shadowburnCooldownIcon:OverrideTimerVisibility()
        if (UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") < 0.2) then
            self.icon:SetAlpha(1.0)
            return true
        else
            self.icon:SetAlpha(0.3)
            return false
        end
    end

    timers:AddKick(19647, first_column_X + 1, 3, nil, true)
    timers:AddOffensiveDispellCooldown(19505, first_column_X + 2, 3, nil, "Magic").displayOnlyIfSpellPetKnown = true

    local soulfireCooldown = timers:AddTrackedCooldown(6353, talent_soulfire)
    local soulfireCooldownIcon = timers:AddCooldownIcon(soulfireCooldown, nil, -2, 0, true, true)

    local demonfireCooldown = timers:AddTrackedCooldown(196447, talent_demonfire)
    local demonfireIcons = {}
    table.insert(demonfireIcons, timers:AddCooldownIcon(demonfireCooldown, nil, -2, 0, true, true, talent_not_soulfire))
    table.insert(demonfireIcons, timers:AddCooldownIcon(demonfireCooldown, nil, -3, 0, true, true, talent_soulfire))

    local riftCooldown = timers:AddTrackedCooldown(387976, talent_rift)
    local riftIcons = {}
    for i = 0, 2 do
        table.insert(riftIcons, timers:AddCooldownIcon(riftCooldown, nil, -2 - i, 0, true, true, ERALIBTalent:CreateCount(i, talent_soulfire, talent_demonfire)))
    end

    local havocCooldown = timers:AddTrackedCooldown(80240, talent_havoc)
    local havocCooldownIcon = timers:AddCooldownIcon(havocCooldown, nil, -2.5, -0.9, true, true)

    local cataclysmCooldown = timers:AddTrackedCooldown(152108, talent_cataclysm)
    local cataIcons = {}
    table.insert(cataIcons, timers:AddCooldownIcon(cataclysmCooldown, nil, -2.5, -0.9, true, true, talent_not_havoc))
    table.insert(cataIcons, timers:AddCooldownIcon(cataclysmCooldown, nil, -3.5, -0.9, true, true, talent_havoc))

    local ruinTimer = timers:AddTrackedBuff(387157)
    local impendingTimer = timers:AddTrackedBuff(387158)
    local impendingIcons = {}
    table.insert(impendingIcons, timers:AddStacksProgressIcon(impendingTimer, nil, first_column_X, 3, 15, talent_not_ritualist))
    table.insert(impendingIcons, timers:AddStacksProgressIcon(impendingTimer, nil, first_column_X, 3, 12, talent_ritualist_1))
    table.insert(impendingIcons, timers:AddStacksProgressIcon(impendingTimer, nil, first_column_X, 3, 10, talent_ritualist_2))
    for _, i in ipairs(impendingIcons) do
        function i:ShouldHighlight(t)
            return ruinTimer.remDuration > 0
        end
    end

    local azjaqirBoltTimer = timers:AddTrackedBuff(387409, talent_azjaqir)
    timers:AddAuraBar(azjaqirBoltTimer, nil, 0.0, 1.0, 0.5)

    local boltMarker = timers:AddMarker(0.5, 1.0, 0.0)
    function boltMarker:computeTimeOr0IfInvisible(haste)
        return ERACombatWarlockDestru_boltCastTime(haste, timers, backdraftTimer, ruinTimer, azjaqirBoltTimer, talent_azjaqir)
    end

    local enemies = ERACombatEnemies:Create(cFrame, 3)
    ERACombatWarlockDestruHavocBar:create(timers, embers, backdraftTimer, ruinTimer, azjaqirBoltTimer, talent_azjaqir)

    utility:AddCooldown(-3, 0, 1122, nil, true, ERALIBTalent:Create(91502)) -- infernal

    -- out of combat
    utility:AddCooldown(-2, 4, 80240, nil, false, talent_havoc)
    utility:AddCooldown(-1, 4, 17877, nil, false, talent_shadowburn)
    utility:AddCooldown(-1, 3, 17962, nil, false, talent_conflagrate)
    utility:AddCooldown(-2, 3, 6353, nil, false, talent_soulfire)
    utility:AddCooldown(-3, 3, 196447, nil, false, talent_demonfire)
    utility:AddCooldown(-2, 2, 152108, nil, false, talent_cataclysm)
    utility:AddCooldown(-3, 2, 387976, nil, false, talent_rift)

    --[[

    PRIO

    1 - immo
    2 - havoc
    3 - shadowburn
    4 - conflag max charges
    5 - demonfire
    6 - cata
    7 - soulfire
    8 - rift
    9 - conflag

    ]]

    local immoPrio = timers:AddPriority(135817)
    function immoPrio:computePriority(t)
        if (immoTimer.remDuration < 6.5) then
            return 1
        else
            return 0
        end
    end

    function havocCooldownIcon:computeAvailablePriority()
        if (enemies:GetCount() > 1) then
            return 2
        else
            return 0
        end
    end

    function shadowburnCooldownIcon:computeAvailablePriority()
        if (UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") < 0.2) then
            return 3
        else
            return 0
        end
    end

    function conflagCooldownIcon:computeAvailablePriority()
        return 4
    end
    local conflagchargedPrio = timers:AddPriority(135807)
    function conflagchargedPrio:computePriority(t)
        if (conflagCooldown.hasCharges and 0 < conflagCooldown.currentCharges and conflagCooldown.currentCharges < conflagCooldown.maxCharges) then
            self.icon:SetDesaturated(true)
            return 9
        else
            return 0
        end
    end

    for _, i in ipairs(demonfireIcons) do
        function i:computeAvailablePriority()
            return 5
        end
    end

    for _, i in ipairs(cataIcons) do
        function i:computeAvailablePriority()
            return 6
        end
    end

    function soulfireCooldownIcon:computeAvailablePriority()
        return 7
    end

    for _, i in ipairs(riftIcons) do
        function i:computeAvailablePriority()
            return 8
        end
    end
end

ERACombatWarlockDestruHavocBar = {}
ERACombatWarlockDestruHavocBar.__index = ERACombatWarlockDestruHavocBar
setmetatable(ERACombatWarlockDestruHavocBar, { __index = ERACombatTimerStatusBar })

function ERACombatWarlockDestruHavocBar:create(timers, embers, backdraftTimer, ruinTimer, azjaqirBoltTimer, talent_azjaqir)
    local bar = {}
    setmetatable(bar, ERACombatWarlockDestruHavocBar)
    bar.embers = embers
    bar.backdraftTimer = backdraftTimer
    bar.ruinTimer = ruinTimer
    bar.azjaqirBoltTimer = azjaqirBoltTimer
    bar.talent_azjaqir = talent_azjaqir
    bar:construct(timers, 460695, 0.8, 0.4, 0.3, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    bar.chaosBoltOK = true
    return bar
end

function ERACombatWarlockDestruHavocBar:checkTalentsOrHide()
    return true
end

function ERACombatWarlockDestruHavocBar:GetRemDurationOr0IfInvisible(t)
    local rem = 15 - (t - self.embers.lastHavoc)
    if (rem > 0) then
        if (rem > 0.3 + self.group.occupied + ERACombatWarlockDestru_boltCastTime(1 + GetHaste() / 100, self.group, self.backdraftTimer, self.ruinTimer, self.azjaqirBoltTimer, self.talent_azjaqir)) then
            self.view:SetColor(0.8, 0.4, 0.3)
        else
            self.view:SetColor(0.5, 0.4, 0.3)
        end
        return rem
    else
        return 0
    end
end

ERACombatWarlockDestruEmbers_EmberSize = 32
ERACombatWarlockDestruEmbers_EmberHalfSize = ERACombatWarlockDestruEmbers_EmberSize / 2
ERACombatWarlockDestruEmbers_EmberOverlayAlpha = 0.8

ERACombatWarlockDestruEmbers = {}
ERACombatWarlockDestruEmbers.__index = ERACombatWarlockDestruEmbers
setmetatable(ERACombatWarlockDestruEmbers, { __index = ERACombatModule })

function ERACombatWarlockDestruEmbers:create(cFrame)
    local e = {}
    setmetatable(e, ERACombatWarlockDestruEmbers)
    e:construct(cFrame, 0.5, 0.1, true, 3)

    e.frame = CreateFrame("Frame", nil, UIParent, nil)
    e.frame:SetSize(ERACombatWarlockDestruEmbers_EmberSize * 5, ERACombatWarlockDestruEmbers_EmberSize)
    e.frame:SetPoint("LEFT", UIParent, "CENTER", -64, -64)
    e.embers = {}
    for i = 1, 5 do
        table.insert(e.embers, ERACombatWarlockDestruEmber:create(e, i))
    end

    e.events = {}
    function e.events:UNIT_POWER_FREQUENT(unitID)
        if (unitID == "player") then
            e:updateEmbers()
        end
    end
    e.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            group.events[event](self, ...)
        end
    )

    e.embersValue = -1
    e.idleStable = -1

    e.lastHavoc = 0

    e.frame:Hide()
    return e
end

function ERACombatWarlockDestruEmbers:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_AURA_APPLIED" and sourceGUY == self.cFrame.playerGUID and spellID == 80240) then
        self.lastHavoc = t
    end
end

function ERACombatWarlockDestruEmbers:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatWarlockDestruEmbers:EnterIdle(fromCombat)
    self.frame:Show()
    self.idleStable = -1
end
function ERACombatWarlockDestruEmbers:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatWarlockDestruEmbers:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatWarlockDestruEmbers:ExitVehicle(toCombat)
    self.frame:Show()
end
function ERACombatWarlockDestruEmbers:ResetToIdle()
    self.frame:Show()
end

function ERACombatWarlockDestruEmbers:UpdateIdle(t)
    local e = UnitPower("player", 7, true)
    if (e == 30) then
        if (self.idleStable > 0) then
            if (t - self.idleStable > 10) then
                self.idleStable = 0
                self.frame:Hide()
                return
            end
        else
            self.idleStable = t
        end
        self:updateEmbersWithInfo(e)
    else
        if (self.idleStable <= 0) then
            self.frame:Show()
        end
        self:updateEmbersWithInfo(e)
    end
end
function ERACombatWarlockDestruEmbers:UpdateCombat(t)
    self:updateEmbers()
end
function ERACombatWarlockDestruEmbers:updateEmbers()
    self:updateEmbersWithInfo(UnitPower("player", 7, true))
end
function ERACombatWarlockDestruEmbers:updateEmbersWithInfo(e)
    if (self.embersValue ~= e) then
        self.embersValue = e
        local whole = math.floor(e / 10)
        local fragments = e - whole * 10
        local e
        for i = 1, whole do
            e = self.embers[i]
            e:SetOverlayValue(0)
            e.ember:Show()
            e.ember:SetVertexColor(1.0, 0.0, 0.0, 1.0)
            e.text:SetText(nil)
        end
        if (whole < 5) then
            local emptyStart
            if (fragments > 0) then
                e = self.embers[whole + 1]
                e:SetOverlayValue(1 - fragments / 10)
                e.ember:Show()
                e.ember:SetVertexColor(0.7, 0.5, 0.0, 1.0)
                e.text:SetText(fragments)
                emptyStart = whole + 2
            else
                emptyStart = whole + 1
            end
            for i = emptyStart, 5 do
                e = self.embers[i]
                e:SetOverlayValue(0)
                e.ember:Hide()
                e.text:SetText(nil)
            end
        end
    end
end

ERACombatWarlockDestruEmber = {}
ERACombatWarlockDestruEmber.__index = ERACombatWarlockDestruEmber

function ERACombatWarlockDestruEmber:create(group, i)
    local e = {}
    setmetatable(e, ERACombatWarlockDestruEmber)

    e.frame = CreateFrame("Frame", nil, group.frame, "ERAWarlockEmberFrame")
    e.frame:SetSize(ERACombatWarlockDestruEmbers_EmberSize, ERACombatWarlockDestruEmbers_EmberSize)
    e.frame:SetPoint("LEFT", group.frame, "LEFT", (i - 1) * ERACombatWarlockDestruEmbers_EmberSize, 0)

    e.ember = e.frame.Ember
    e.text = e.frame.Text
    ERALIB_SetFont(e.text, 16)

    e.trt = e.frame.TRT
    e.trr = e.frame.TRR
    e.tlt = e.frame.TLT
    e.tlr = e.frame.TLR
    e.blr = e.frame.BLR
    e.blt = e.frame.BLT
    e.brt = e.frame.BRT
    e.brr = e.frame.BRR
    e.rec = {}
    table.insert(e.rec, e.tlr)
    table.insert(e.rec, e.trr)
    table.insert(e.rec, e.brr)
    table.insert(e.rec, e.blr)
    for i, r in ipairs(e.rec) do
        r:SetColorTexture(0, 0, 0, ERACombatWarlockDestruEmbers_EmberOverlayAlpha)
        r:Hide()
    end
    e.tri = {}
    table.insert(e.tri, e.tlt)
    table.insert(e.tri, e.trt)
    table.insert(e.tri, e.brt)
    table.insert(e.tri, e.blt)
    for i, t in ipairs(e.tri) do
        t:SetVertexColor(0, 0, 0, ERACombatWarlockDestruEmbers_EmberOverlayAlpha)
        t:Hide()
    end
    e.oClear = true
    e.quadrant = 0

    return e
end

function ERACombatWarlockDestruEmber_calcPosition(p, halfSize, straight)
    if (straight) then
        return halfSize * math.tan(2 * p * 3.1416)
    else
        return halfSize * (1 - math.tan((1 - 8 * p) * 3.1416 / 4))
    end
end

function ERACombatWarlockDestruEmber:SetOverlayValue(value)
    local halfSize = ERACombatWarlockDestruEmbers_EmberHalfSize
    if ((not value) or value <= 0) then
        if (not self.oClear) then
            self.oClear = true
            self.quadrant = 0
            for i, t in ipairs(self.tri) do
                t:Hide()
            end
            for i, r in ipairs(self.rec) do
                r:Hide()
            end
        end
    elseif (value >= 1) then
        self.oClear = false
        self.quadrant = 0
        for i, t in ipairs(self.tri) do
            t:Hide()
        end
        for i, r in ipairs(self.rec) do
            r:Show()
        end
        self.trr:SetWidth(halfSize)
        self.brr:SetHeight(halfSize)
        self.blr:SetWidth(halfSize)
        self.tlr:SetHeight(halfSize)
    else
        self.oClear = false
        if (value <= 0.125) then
            if (self.quadrant ~= 1) then
                self.quadrant = 1
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Hide()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Show()
            end
            self.tlt:SetPoint("TOPLEFT", self.frame, "TOP", -ERACombatWarlockDestruEmber_calcPosition(value, halfSize, true), 0)
        elseif (value <= 0.25) then
            if (self.quadrant ~= 2) then
                self.quadrant = 2
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Show()
            end
            local h = ERACombatWarlockDestruEmber_calcPosition(value - 0.125, halfSize, false)
            self.tlt:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -h)
            self.tlr:SetHeight(h)
        elseif (value <= 0.375) then
            if (self.quadrant ~= 3) then
                self.quadrant = 3
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Show()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blt:SetPoint("BOTTOMLEFT", self.frame, "LEFT", 0, -ERACombatWarlockDestruEmber_calcPosition(value - 0.25, halfSize, true))
        elseif (value <= 0.5) then
            if (self.quadrant ~= 4) then
                self.quadrant = 4
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Show()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            local w = ERACombatWarlockDestruEmber_calcPosition(value - 0.375, halfSize, false)
            self.blt:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", w, 0)
            self.blr:SetWidth(w)
        elseif (value <= 0.625) then
            if (self.quadrant ~= 5) then
                self.quadrant = 5
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Show()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brt:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOM", ERACombatWarlockDestruEmber_calcPosition(value - 0.5, halfSize, true), 0)
        elseif (value <= 0.75) then
            if (self.quadrant ~= 6) then
                self.quadrant = 6
                self.trr:Hide()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Show()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            local h = ERACombatWarlockDestruEmber_calcPosition(value - 0.625, halfSize, false)
            self.brr:SetHeight(h)
            self.brt:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, h)
        elseif (value <= 0.875) then
            if (self.quadrant ~= 7) then
                self.quadrant = 7
                self.trr:Hide()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Show()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brr:SetHeight(halfSize)
            self.trt:SetPoint("TOPRIGHT", self.frame, "RIGHT", 0, ERACombatWarlockDestruEmber_calcPosition(value - 0.75, halfSize, true))
        else
            if (self.quadrant ~= 8) then
                self.quadrant = 8
                self.trr:Show()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Show()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brr:SetHeight(halfSize)
            local w = ERACombatWarlockDestruEmber_calcPosition(value - 0.875, halfSize, false)
            self.trr:SetWidth(w)
            self.trt:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -w, 0)
        end
    end
end


------------------------------------------------------------------------------------------------------------------------
---- TOOLS -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatFrames_WarlockExhaustionBar = {}
ERACombatFrames_WarlockExhaustionBar.__index = ERACombatFrames_WarlockExhaustionBar
setmetatable(ERACombatFrames_WarlockExhaustionBar, { __index = ERACombatTimerStatusBar })

function ERACombatFrames_WarlockExhaustionBar:create(timers, curse)
    local c = {}
    setmetatable(c, ERACombatFrames_WarlockExhaustionBar)
    c:construct(timers, curse.iconID, 0.5, 0.5, 0.5, "Interface\\Buttons\\WHITE8x8")
    c.view:SetSize(16)
    c.curse = curse
    return c
end

function ERACombatFrames_WarlockExhaustionBar:checkTalentsOrHide()
    return true
end

function ERACombatFrames_WarlockExhaustionBar:GetRemDurationOr0IfInvisible(t)
    return self.curse.remDuration
end

ERACombatWarlockCurses_IconSize = 64
ERACombatWarlockCurses = {}
ERACombatWarlockCurses.__index = ERACombatWarlockCurses
setmetatable(ERACombatWarlockCurses, { __index = ERACombatModule })

function ERACombatWarlockCurses:create(cFrame, x, y, timers, spec)
    local c = {}
    setmetatable(c, ERACombatWarlockCurses)
    c:construct(cFrame, -1, 0.1, true, spec)

    c.frame = CreateFrame("Frame", nil, UIParent, nil)
    c.frame:SetSize(2 * ERACombatWarlockCurses_IconSize, ERACombatWarlockCurses_IconSize)
    c.frame:SetPoint("TOP", UIParent, "CENTER", x, y)

    c.cursesBySpellID = {}
    c.tongues = ERACombatWarlockCurse:create(c, 1714, 60, 136140, -ERACombatWarlockCurses_IconSize)
    c.weakness = ERACombatWarlockCurse:create(c, 702, 120, 136138, ERACombatWarlockCurses_IconSize)
    c.exhaustion = ERACombatWarlockCurse:create(c, 334275, 12, 136162, nil)

    ERACombatFrames_WarlockExhaustionBar:create(timers, c.exhaustion)

    c.targetInfos = {}

    return c
end

function ERACombatWarlockCurses:SpecInactive(wasActive)
    self.frame:Hide()
end

function ERACombatWarlockCurses:ResetToIdle()
    self.frame:Hide()
    self.targetInfos = {}
end
function ERACombatWarlockCurses:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatWarlockCurses:ExitCombat(toIdle)
    self.frame:Hide()
    self.targetInfos = {}
end

function ERACombatWarlockCurses:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, targetGUY, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (targetGUY and evt == "SPELL_AURA_APPLIED" or evt == "SPELL_AURA_REFRESH") then
        local c = self.cursesBySpellID[spellID]
        if (c) then
            local ti = self.targetInfos[targetGUY]
            if (not ti) then
                ti = {}
                self.targetInfos[targetGUY] = ti
            end
            ti[c] = t
        end
    end
end

function ERACombatWarlockCurses:UpdateCombat(t)
    if (UnitCanAttack("player", "target")) then
        for _, c in pairs(self.cursesBySpellID) do
            c:prepareUpdate()
        end
        local thisPlayerHasOneCurseActive
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, source, _, _, spellID = UnitDebuff("target", i)
            if (spellID) then
                local c = self.cursesBySpellID[spellID]
                if (c) then
                    c:auraFound(t, stacks, durAura, expirationTime, source == "player")
                end
            else
                break
            end
        end
        local thisPlayerHasOneCurseActive = false
        for _, c in pairs(self.cursesBySpellID) do
            if (c.maxDurationByPlayer) then
                thisPlayerHasOneCurseActive = true
                break
            end
        end
        local targetGUID = UnitGUID("target")
        for _, c in pairs(self.cursesBySpellID) do
            c:update(t, thisPlayerHasOneCurseActive, targetGUID)
        end
    else
        for _, c in pairs(self.cursesBySpellID) do
            c:noTarget()
        end
    end
end

ERACombatWarlockCurse = {}
ERACombatWarlockCurse.__index = ERACombatWarlockCurse

function ERACombatWarlockCurse:create(curses, spellID, standardDuration, iconID, x)
    local c = {}
    setmetatable(c, ERACombatWarlockCurse)
    c.curses = curses
    c.spellID = spellID
    c.iconID = iconID
    if (x) then
        c.icon = ERAPieIcon:Create(curses.frame, "CENTER", ERACombatWarlockCurses_IconSize, iconID)
        c.icon:Draw(x, 0)
        c.icon:Hide()
    end
    c.standardDuration = standardDuration
    c.remDuration = 0
    c.totDuration = 1
    curses.cursesBySpellID[spellID] = c
    return c
end

function ERACombatWarlockCurse:noTarget()
    if (self.icon) then
        self.icon:Hide()
    end
end

function ERACombatWarlockCurse:prepareUpdate()
    self.remDuration = 0
    self.totDuration = 1
    self.maxDurationByPlayer = false
end

function ERACombatWarlockCurse:auraFound(t, stacks, durAura, expirationTime, sourceIsPlayer)
    local auraRemDuration
    if (expirationTime and expirationTime > 0) then
        auraRemDuration = expirationTime - t
    else
        auraRemDuration = 4096
    end
    if ((not durAura) or durAura < auraRemDuration) then
        durAura = auraRemDuration
    end
    if (not (stacks and stacks > 0)) then
        stacks = 1
    end
    if (auraRemDuration > self.remDuration) then
        self.remDuration = auraRemDuration
        self.totDuration = durAura
        self.maxDurationByPlayer = sourceIsPlayer
    elseif (sourceIsPlayer) then
        self.maxDurationByPlayer = false
    end
end

function ERACombatWarlockCurse:update(t, thisPlayerHasOneCurseActive, targetGUID)
    if (self.icon) then
        if (self.remDuration > 0) then
            self.icon:SetOverlayValue(self.remDuration / self.totDuration)
            self.icon:SetVertexColor(1, 1, 1, 1)
            self.icon:Show()
            local ti = self.curses.targetInfos[targetGUID]
            if (ti) then
                if (not ti[self]) then
                    ti[self] = t - (self.totDuration - self.remDuration)
                end
            else
                ti = {}
                self.curses.targetInfos[targetGUID] = ti
                ti[self] = t - (self.totDuration - self.remDuration)
            end
        else
            if (thisPlayerHasOneCurseActive) then
                self.icon:Hide()
            else
                local ti = self.curses.targetInfos[targetGUID]
                if (ti) then
                    local lastApplied = ti[self]
                    if (lastApplied and (t - lastApplied) < 1.5 * self.standardDuration) then
                        self.icon:SetOverlayValue(0)
                        self.icon:SetVertexColor(1, 0, 0, 1)
                        self.icon:Show()
                        return
                    end
                end
                self.icon:Hide()
            end
        end
    end
end

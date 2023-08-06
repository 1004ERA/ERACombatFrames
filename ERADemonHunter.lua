-- TODO
-- unifier fury et pain pour Shadowlands

function ERACombatFrames_DemonHunterSetup(cFrame)
    ERACombatGlobals_SpecID1 = 557
    ERACombatGlobals_SpecID2 = 581

    local havocActive = ERACombatOptions_IsSpecActive(1)
    local vengeanceActive = ERACombatOptions_IsSpecActive(2)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 123, 26, 17, false, 0.8, 0.1, 0.8, false, havocActive, vengeanceActive)

    local enemies = ERACombatEnemies:Create(cFrame, havocActive, vengeanceActive)

    if (havocActive) then
        ERACombatFrames_DemonHunterHavocSetup(cFrame, enemies)
    end
    if (vengeanceActive) then
        ERACombatFrames_DemonHunterVengeanceSetup(cFrame, enemies)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- HAVOC -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DemonHunterHavocSetup(cFrame, enemies)
    local timers = ERACombatTimersGroup:Create(cFrame, -101, -11, 1.5, false, 1)
    timers.watchDispellableMagic = true
    timers.offsetIconsX = 8
    timers.offsetIconsY = 16

    ERACombatHealth:Create(cFrame, -188, -55, 161, 22, 1)

    local fury = ERACombatPower:Create(cFrame, -188, -18, 161, 22, 17, true, 0.8, 0.1, 0.8, 1)

    local talent_demon_blades_improved = ERALIBTalent:Create(112941)
    local talent_demon_blades_autoattack = ERALIBTalent:Create(112940)
    local talent_strong_dance = ERALIBTalent:Create(112834)
    local talent_momentum = ERALIBTalent:Create(112943)
    local talent_serrated = ERALIBTalent:Create(112934)
    local talent_strong_glaive = ERALIBTalent:CreateOr(talent_serrated, ERALIBTalent:Create(115244), ERALIBTalent:Create(115244), ERALIBTalent:Create(112826), ERALIBTalent:Create(112932), ERALIBTalent:Create(112829))
    local talent_strong_rush = ERALIBTalent:CreateOr(talent_momentum, ERALIBTalent:Create(112942))
    local talent_strong_beam = ERALIBTalent:Create(112949)
    local talent_sigil_flame = ERALIBTalent:Create(112854)
    local talent_not_sigil_flame = ERALIBTalent:CreateNotTalent(112854)
    local talent_decree = ERALIBTalent:Create(112930)
    local talent_felblade = ERALIBTalent:Create(112842)
    local talent_essence_break = ERALIBTalent:Create(112956)
    local talent_not_essence_break = ERALIBTalent:CreateNotTalent(112956)
    local talent_tempest = ERALIBTalent:Create(112946)
    local talent_barrage = ERALIBTalent:Create(112945)
    local talent_eruption = ERALIBTalent:Create(115246)
    local talent_nova = ERALIBTalent:Create(112911)
    local talent_misery = ERALIBTalent:Create(112859)
    local talent_hunt = ERALIBTalent:Create(112837)

    local danceTimer = timers:AddTrackedCooldown(188499, ERALIBTalent:CreateLevel(12))
    local eyesbTimer = timers:AddTrackedCooldown(198013, ERALIBTalent:CreateLevel(11))
    local metamTimer = timers:AddTrackedBuff(162264)

    -- FURY --

    fury:AddConsumer(40, 1305152)
    local danceConsumer = fury:AddConsumer(35, 1305149)
    local eyeBeamConsumer = fury:AddConsumer(30, 1305156)
    local dumpConsumer = fury:AddConsumer(75, 1305152)

    function dumpConsumer:ComputeVisibility()
        return talent_strong_dance:PlayerHasTalent() or enemies:GetCount() > 1
    end

    function danceConsumer:ComputeVisibility()
        return danceTimer.remDuration <= 4 and (talent_strong_dance:PlayerHasTalent() or enemies:GetCount() > 1)
    end
    function danceConsumer:ComputeIconVisibility()
        if (danceTimer.remDuration + 0.1 <= timers.remGCD) then
            self.icon:SetDesaturated(false)
        else
            self.icon:SetDesaturated(true)
        end
        return true
    end

    function eyeBeamConsumer:ComputeVisibility()
        if (eyesbTimer.remDuration <= 4) then
            return true
        else
            return false
        end
    end
    function eyeBeamConsumer:ComputeIconVisibility()
        if (eyesbTimer.remDuration <= timers.remGCD) then
            self.icon:SetDesaturated(false)
        else
            self.icon:SetDesaturated(true)
        end
        return true
    end

    -- TIMER --

    timers:AddKick(183752, -0.3, 2, ERALIBTalent:CreateLevel(19))
    timers:AddOffensiveDispellCooldown(278326, 0.7, 2, ERALIBTalent:Create(112926), "Magic")

    local glaiveTimer = timers:AddTrackedCooldown(185123)
    local glaiveTimerDisplay = timers:AddCooldownIcon(glaiveTimer, nil, -0.3, -1, true, true)
    function glaiveTimerDisplay:OverrideTimerVisibility()
        if (talent_demon_blades_autoattack:PlayerHasTalent() or talent_strong_glaive:PlayerHasTalent()) then
            glaiveTimerDisplay.icon:SetAlpha(1.0)
            return true
        else
            glaiveTimerDisplay.icon:SetAlpha(0.3)
            return false
        end
    end

    local danceTimerDisplay = timers:AddCooldownIcon(danceTimer, nil, -2, -1, true, true)
    function danceTimerDisplay:OverrideTimerVisibility()
        if (enemies:GetCount() > 1 or talent_strong_dance:PlayerHasTalent()) then
            danceTimerDisplay.icon:SetAlpha(1.0)
            return true
        else
            danceTimerDisplay.icon:SetAlpha(0.3)
            return false
        end
    end

    local rushTimer = timers:AddTrackedCooldown(195072)
    local rushTimerDisplay = timers:AddCooldownIcon(rushTimer, nil, -0.3, 1, true, true)
    function rushTimerDisplay:OverrideTimerVisibility()
        return enemies:GetCount() > 2 or talent_strong_rush:PlayerHasTalent()
    end

    local huntCooldown = timers:AddTrackedCooldown(370965, talent_hunt)
    local huntCooldownIcon = timers:AddCooldownIcon(huntCooldown, nil, -0.3, -2, true, true)

    local felBladeIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(232893, talent_felblade), nil, -3, -1, true, true)
    felBladeIcon.beamWhenAvailable = 2

    timers:AddCooldownIcon(timers:AddTrackedCooldown(198793), nil, -0.3, 0, false, false) -- retreat

    local eyesbTimerDisplay = timers:AddCooldownIcon(eyesbTimer, nil, -2.5, -1.8, true, true)

    local immolationCooldown = timers:AddTrackedCooldown(258920)
    local immolationCooldownIcon = timers:AddCooldownIcon(immolationCooldown, nil, -1.5, -1.8, true, true)

    local sigilFlameCooldown = timers:AddTrackedCooldown(204596, talent_sigil_flame)
    local sigilFlameCooldownIcon = timers:AddCooldownIcon(sigilFlameCooldown, nil, -4, -1, true, true)

    local decreeCooldown = timers:AddTrackedCooldown(390163, talent_decree)
    local decreeCooldownIcons = {}
    table.insert(decreeCooldownIcons, timers:AddCooldownIcon(decreeCooldown, nil, -4, -1, true, true, talent_not_sigil_flame))
    table.insert(decreeCooldownIcons, timers:AddCooldownIcon(decreeCooldown, nil, -5, -1, true, true, talent_sigil_flame))

    local essenceBreakDebuff = timers:AddTrackedDebuff(320338, talent_essence_break)
    timers:AddAuraBar(essenceBreakDebuff, nil, 0.8, 0.0, 0.7)
    local essenceBreakCooldown = timers:AddTrackedCooldown(258860, talent_essence_break)
    local essenceBreakIcon = timers:AddCooldownIcon(essenceBreakCooldown, nil, -3.5, -1.8, true, true)
    essenceBreakIcon.beamWhenAvailable = 1
    essenceBreakIcon.beamWhenAvailableOnlyIfReset = false

    local tempestCooldown = timers:AddTrackedCooldown(342817, talent_tempest)
    local tempestCooldownIcons = {}
    table.insert(tempestCooldownIcons, timers:AddCooldownIcon(tempestCooldown, nil, -3.5, -1.8, true, true, talent_not_essence_break))
    table.insert(tempestCooldownIcons, timers:AddCooldownIcon(tempestCooldown, nil, -4.5, -1.8, true, true, talent_essence_break))

    local barrageCooldown = timers:AddTrackedCooldown(258925, talent_barrage)
    local barrageCooldownIcons = {}
    table.insert(barrageCooldownIcons, timers:AddCooldownIcon(barrageCooldown, nil, -3.5, -1.8, true, true, talent_not_essence_break))
    table.insert(barrageCooldownIcons, timers:AddCooldownIcon(barrageCooldown, nil, -4.5, -1.8, true, true, talent_essence_break))

    timers:AddAuraBar(metamTimer, nil, 0.0, 0.7, 0.0)

    local momentumTimer = timers:AddTrackedBuff(208628, talent_momentum)
    timers:AddAuraBar(momentumTimer, nil, 0.8, 0.7, 0.0)

    local serratedDebuff = timers:AddTrackedDebuff(390155, talent_serrated)
    local serratedBar = timers:AddAuraBar(serratedDebuff, nil, 0.3, 0.5, 0.35)
    function serratedBar:GetRemDurationOr0IfInvisible(t)
        if (serratedDebuff.remDuration <= 4) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local missingSerrated = timers:AddMissingAura(serratedDebuff, nil, 0, -1, true)
    function missingSerrated:OverrideVisible(t)
        return (glaiveTimer.currentCharges > 0 or glaiveTimer.remDuration <= self.group.remGCD + 0.05)
    end

    local eyesbMarker = timers:AddMarker(0.2, 1.0, 0.5, nil)
    function eyesbMarker:computeTimeOr0IfInvisible(haste)
        local x = eyesbTimer.remDuration
        if (x <= 4) then
            if (x <= timers.remGCD) then
                self:SetColor(0.2, 1.0, 0.5)
            else
                self:SetColor(1, 0, 1)
            end
            return (1 + talent_strong_beam.rank / 10) * 2 / haste
        else
            return 0
        end
    end

    -- UTILITY --

    local out_of_combat_cooldowns = ERACombatUtilityFrame:Create(cFrame, -128, 0, 1)
    out_of_combat_cooldowns:AddCooldown(-0.5, 0.9, 258920, nil, false)             -- immolation
    out_of_combat_cooldowns:AddCooldown(0.5, 0.9, 185123, nil, false)              -- glaive
    out_of_combat_cooldowns:AddCooldown(1, 0, 232893, nil, false, talent_felblade) -- fel blade
    out_of_combat_cooldowns:AddCooldown(0, 0, 195072, nil, false)                  -- rush
    out_of_combat_cooldowns:AddCooldown(-1, 0, 198793, nil, false)                 -- retreat
    out_of_combat_cooldowns:AddCooldown(-2, 0, 370965, nil, false, talent_hunt)
    out_of_combat_cooldowns:AddCooldown(0, -1, 204596, nil, false)                 -- sigil flame
    out_of_combat_cooldowns:AddCooldown(-1, -1, 390163, nil, false, talent_decree)
    out_of_combat_cooldowns:AddCooldown(0, -2, 198013, nil, false)                 -- beam
    out_of_combat_cooldowns:AddCooldown(-1, -2, 320338, nil, false)                -- essence
    out_of_combat_cooldowns:AddCooldown(-2, -2, 342817, nil, false)                -- tempest
    out_of_combat_cooldowns:AddCooldown(-2, -2, 258925, nil, false)                -- barrage

    local utility = ERACombatUtilityFrame:Create(cFrame, -88, -212, 1)

    utility:AddTrinket2Cooldown(-3, 0, nil)
    utility:AddTrinket1Cooldown(-2, 0, nil)
    utility:AddCooldown(-1, 0, 191427, nil, true, ERALIBTalent:CreateLevel(20))                               -- metamorphosis

    utility:AddCooldown(1, 0, 198589, nil, true, ERALIBTalent:CreateLevel(18))                                -- blur
    utility:AddCooldown(2, 0, 196718, nil, true, ERALIBTalent:Create(112921))                                 -- darkness
    utility:AddCooldown(3, 0, 196555, nil, true, ERALIBTalent:Create(115247))                                 -- netherwalk

    utility:AddCooldown(0.5, -0.9, 217832, nil, true, ERALIBTalent:Create(112927)).alphaWhenOffCooldown = 0.5 -- prison
    utility:AddWarlockHealthStone(1.5, -0.9)
    utility:AddWarlockPortal(2.5, -0.9)

    utility:AddCooldown(1.5, -1.9, 185245, nil, true).alphaWhenOffCooldown = 0.2  -- taunt
    utility:AddCooldown(2.5, -1.9, 188501, nil, true).alphaWhenOffCooldown = 0.15 -- vision

    utility:AddRacial(4, 1).alphaWhenOffCooldown = 0.4

    utility:AddCooldown(4, 2, 207684, nil, true, talent_misery)
    utility:AddCooldown(4, 3, 179057, nil, true, talent_nova)
    utility:AddCooldown(4, 4, 211881, nil, true, talent_eruption)



    --[[

    PRIO

    1 - fel blade very low fury
    2 - blade dance (no essence break)
    3 - essence break (no eye beam)
    4 - blade dance
    5 - chaos strike (essence break, or last hits before end of metamorphosis)
    6 - throw glaive serrated
    7 - felblade low fury
    8 - eye beam
    9 - tempest dump
    10 - chaos strike dump
    11 - immolation
    12 - tempest or barrage
    13 - decree
    14 - essence break
    15 - throw glaive talented
    16 - sigil of flames
    17 - throw glaive  nottalented
    18 - fel blade
    19 - hunt

    ]]

    function felBladeIcon:computeAvailablePriority()
        if (fury.currentPower >= 30) then
            if (eyesbTimer.isAvailable) then
                return 18
            else
                if (fury.currentPower >= 35) then
                    if (danceTimerDisplay.priorityObject.priority > 0) then
                        return 18
                    else
                        if (fury.maxPower - fury.currentPower < 40) then
                            return 18
                        else
                            return 7
                        end
                    end
                else
                    return 7
                end
            end
        else
            return 1
        end
    end

    function danceTimerDisplay:computeAvailablePriority()
        if (talent_strong_dance:PlayerHasTalent() or enemies:GetCount() > 1) then
            if (talent_essence_break:PlayerHasTalent()) then
                if (essenceBreakCooldown.remDuration <= 4) then
                    return 4
                else
                    return 2
                end
            else
                return 2
            end
        else
            return 0
        end
    end

    function essenceBreakIcon:computeAvailablePriority()
        if (eyesbTimer.remDuration > 5) then
            return 3
        else
            return 14
        end
    end

    local chaosStrikeDump = timers:AddPriority(1305152)
    function chaosStrikeDump:computePriority(t)
        if (
                (metamTimer.remDuration > timers.remGCD and math.ceil(metamTimer.remDuration / timers.totGCD) < fury.currentPower / 40)
                or
                (essenceBreakDebuff.remDuration > timers.remGCD and fury.currentPower >= 40)
            ) then
            return 5
        else
            if (fury.maxPower - fury.currentPower < 32) then
                return 10
            else
                return 0
            end
        end
    end

    function glaiveTimerDisplay:computeAvailablePriority()
        if (talent_serrated:PlayerHasTalent()) then
            if (serratedDebuff.remDuration <= 1.7) then
                return 6
            else
                return 15
            end
        else
            return 17
        end
    end

    function eyesbTimerDisplay:computeAvailablePriority()
        return 8
    end

    function immolationCooldownIcon:computeAvailablePriority()
        return 11
    end

    for _, i in ipairs(barrageCooldownIcons) do
        function i:computeAvailablePriority()
            return 12
        end
    end
    for _, i in ipairs(tempestCooldownIcons) do
        function i:computeAvailablePriority()
            if (fury.maxPower - fury.currentPower < 32) then
                return 9
            else
                return 12
            end
        end
    end

    for _, i in ipairs(decreeCooldownIcons) do
        function i:computeAvailablePriority()
            return 13
        end
    end

    function sigilFlameCooldownIcon:computeAvailablePriority()
        return 16
    end

    function huntCooldownIcon:computeAvailablePriority()
        return 19
    end
end

------------------------------------------------------------------------------------------------------------------------
---- VENGEANCE ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatSoulFragments = {}
ERACombatSoulFragments.__index = ERACombatSoulFragments
setmetatable(ERACombatSoulFragments, { __index = ERACombatPoints })

function ERACombatSoulFragments:Create(cFrame, x, y, souls)
    local p = {}
    setmetatable(p, ERACombatSoulFragments)
    p:ConstructPoints(cFrame, x, y, 5, 0.0, 0.7, 0.0, 0.4, 0.0, 1.0, nil, 2, 2)
    p.souls = souls
    return p
end

function ERACombatSoulFragments:GetCurrentPoints(t)
    if (self.cFrame.inCombat) then
        return self.souls.stacks
    else
        return 0
    end
end

function ERACombatFrames_DemonHunterVengeanceSetup(cFrame, enemies)
    local timers = ERACombatTimersGroup:Create(cFrame, -123, -11, 1.5, false, 2)
    timers.offsetIconsX = 8
    timers.offsetIconsY = -16
    timers.watchDispellableMagic = true

    local talent_frailty = ERALIBTalent:CreateOr(ERALIBTalent:Create(112893), ERALIBTalent:Create(112894))
    local talent_fracture = ERALIBTalent:Create(112885)
    local talent_felblade = ERALIBTalent:Create(112842)
    local talent_not_fracture = ERALIBTalent:CreateNotTalent(112885)
    local talent_rapid_glaive = ERALIBTalent:Create(112883)
    local talent_slow_glaive = ERALIBTalent:CreateNotTalent(112883)
    local talent_soul_carver = ERALIBTalent:Create(112898)
    local talent_not_soul_carver = ERALIBTalent:CreateNotTalent(112898)
    local talent_protective_immolation = ERALIBTalent:CreateOr(ERALIBTalent:Create(112924), ERALIBTalent:Create(112868))
    local talent_decree = ERALIBTalent:Create(112874)
    local talent_not_decree = ERALIBTalent:CreateNotTalent(112874)
    local talent_hunt = ERALIBTalent:Create(112837)
    local talent_barrier = ERALIBTalent:Create(112870)
    local talent_bulk = ERALIBTalent:Create(112869)
    local talent_misery = ERALIBTalent:Create(112859)
    local talent_silence = ERALIBTalent:Create(112904)
    local talent_chains = ERALIBTalent:Create(112867)
    local talent_better_soul_heal = ERALIBTalent:Create(112863)

    local souls = timers:AddTrackedBuff(203981)

    local combatHealth = ERACombatHealth:Create(cFrame, -224, -60, 177, 26, 2)

    local pukeTimer = timers:AddTrackedCooldown(212084, ERALIBTalent:CreateLevel(11))
    local spikBuffTimer = timers:AddTrackedBuff(203819)
    local spikCooldownTimer = timers:AddTrackedCooldown(203720)
    local frailtyDebuff = timers:AddTrackedDebuff(247456)
    local metamTimer = timers:AddTrackedBuff(187827)

    -- POWER --

    local fury = ERACombatPower:Create(cFrame, -224, -28, 177, 20, 17, true, 0.8, 0.1, 0.8, 2)
    fury:AddConsumer(30, 1344653)
    fury:AddConsumer(60, 1344653)
    fury:AddConsumer(90, 1344653)

    local pukeConsumer = fury:AddConsumer(50, 1450143)
    function pukeConsumer:ComputeVisibility()
        return pukeTimer.remDuration <= 5
    end
    function pukeConsumer:ComputeIconVisibility()
        if (pukeTimer.remDuration <= 0 or pukeTimer.remDuration + 0.05 <= timers.occupied) then
            self.icon:SetDesaturated(false)
        else
            self.icon:SetDesaturated(true)
        end
        return true
    end

    ERACombatSoulFragments:Create(cFrame, -161, -99, souls)

    -- TIMER --

    local vertical_column_X_offset = -0.36
    local vertical_column_Y_offset = 0.1

    timers:AddCooldownIcon(timers:AddTrackedCooldown(185123), nil, vertical_column_X_offset, 3 + vertical_column_Y_offset, true, true).alphaWhenOffCooldown = 0.3 -- glaive
    timers:AddCooldownIcon(timers:AddTrackedCooldown(189110), nil, vertical_column_X_offset, 2 + vertical_column_Y_offset, false, false)                          -- infernal strike
    timers:AddKick(183752, 1 + vertical_column_X_offset, 2 + vertical_column_Y_offset, ERALIBTalent:CreateLevel(19))
    timers:AddOffensiveDispellCooldown(278326, 1 + vertical_column_X_offset, 3 + vertical_column_Y_offset, ERALIBTalent:Create(112926), "Magic")

    local fractureCooldown = timers:AddTrackedCooldown(263642, talent_fracture)
    local fractureCooldownIcon = timers:AddCooldownIcon(fractureCooldown, nil, vertical_column_X_offset, 1 + vertical_column_Y_offset, true, true)

    local immolationIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(258920), nil, vertical_column_X_offset, 0 + vertical_column_Y_offset, true, true)
    immolationIcon.beamWhenAvailable = 1
    immolationIcon.beamWhenAvailableOnlyIfReset = false

    local felbladeCooldown = timers:AddTrackedCooldown(232893, talent_felblade)
    local felbladeCooldownIcon = timers:AddCooldownIcon(felbladeCooldown, nil, vertical_column_X_offset, -1 + vertical_column_Y_offset, true, true)
    felbladeCooldownIcon.beamWhenAvailable = 1

    timers:AddCooldownIcon(spikCooldownTimer, nil, -2, -1, true, true)
    timers:AddCooldownIcon(pukeTimer, nil, -3, -1, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(204021), nil, -4, -1, true, true) -- firebrand

    local barrierCooldown = timers:AddTrackedCooldown(263648, talent_barrier)
    local barrierCooldownIcon = timers:AddCooldownIcon(barrierCooldown, nil, -5, -1, true, true)

    local soulCarverIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(207407, talent_soul_carver), nil, -1.5, -1.8, true, true, talent_soul_carver)
    soulCarverIcon.beamWhenAvailable = 1
    soulCarverIcon.beamWhenAvailableOnlyIfReset = false

    local sigilFlameCooldown = timers:AddTrackedCooldown(204596)
    local sigilFlameCooldownIcon = timers:AddCooldownIcon(sigilFlameCooldown, nil, -2.5, -1.8, true, true)

    local decreeCooldown = timers:AddTrackedCooldown(390163, talent_decree)
    local decreeCooldownIcon = timers:AddCooldownIcon(decreeCooldown, nil, -3.5, -1.8, true, true)

    local huntCooldown = timers:AddTrackedCooldown(370965, talent_decree)
    local huntIcons = {}
    table.insert(huntIcons, timers:AddCooldownIcon(huntCooldown, nil, -3.5, -1.8, true, true, talent_not_decree))
    table.insert(huntIcons, timers:AddCooldownIcon(huntCooldown, nil, -4.5, -1.8, true, true, talent_decree))

    timers:AddAuraBar(spikBuffTimer, nil, 0.8, 0.8, 0.0)                   -- spikes
    timers:AddAuraBar(metamTimer, nil, 0.0, 0.7, 0.0)
    timers:AddAuraBar(timers:AddTrackedDebuff(207771), nil, 0.3, 1.0, 0.6) -- brand
    timers:AddMissingAura(frailtyDebuff, nil, vertical_column_X_offset, 4.5 + vertical_column_Y_offset, true, talent_frailty)
    local frailtyBar = timers:AddAuraBar(frailtyDebuff, nil, 1.0, 0.0, 0.2)
    function frailtyBar:GetRemDurationOr0IfInvisible()
        if (frailtyDebuff.remDuration <= 4) then
            return frailtyDebuff.remDuration
        else
            return 0
        end
    end

    -- DAMAGE WINDOW --

    local damageWindow = ERACombatTankWindow:Create(timers, 200, 2, 5, 0, 4, 300, ERACombatOptions_IsSpecModuleActive(2, ERACombatOptions_TankWindow))
    function damageWindow:Updated(t)
        local ap = UnitAttackPower("player")
        local versa = 1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100
        local soulcount = math.max(2, souls.stacks)
        combatHealth:SetHealing((0.5 * ap * (1 + soulcount) + (1 + 0.1 * talent_better_soul_heal.rank) * soulcount * math.max(0.01 * combatHealth.currentHealth / combatHealth.maxHealth, 0.06 * damageWindow.currentDamage)) * versa)
    end

    -- UTILITY --

    local out_of_combat_cooldowns = ERACombatUtilityFrame:Create(cFrame, -128, 0, 2)
    out_of_combat_cooldowns:AddCooldown(-0.5, 0.9, 258920, nil, false)             -- immolation
    out_of_combat_cooldowns:AddCooldown(0.5, 0.9, 185123, nil, false)              -- glaive
    out_of_combat_cooldowns:AddCooldown(1, 0, 232893, nil, false, talent_felblade) -- fel blade
    out_of_combat_cooldowns:AddCooldown(0, 0, 189110, nil, false)                  -- infernal strike
    out_of_combat_cooldowns:AddCooldown(-1, 0, 370965, nil, false, talent_hunt)
    out_of_combat_cooldowns:AddCooldown(0, -1, 204596, nil, false)                 -- sigil flame
    out_of_combat_cooldowns:AddCooldown(-1, -1, 390163, nil, false, talent_decree)
    out_of_combat_cooldowns:AddCooldown(0, -2, 203720, nil, false)                 -- spikes
    out_of_combat_cooldowns:AddCooldown(-1, -2, 212084, nil, false)                -- puke
    out_of_combat_cooldowns:AddCooldown(-2, -2, 204021, nil, false)                -- brand

    local utility = ERACombatUtilityFrame:Create(cFrame, -88, -202, 2)

    utility:AddCooldown(1, -2, 188501, nil, true).alphaWhenOffCooldown = 0.15                             -- vision
    utility:AddCooldown(0, -2, 217832, nil, true, ERALIBTalent:Create(112927)).alphaWhenOffCooldown = 0.5 -- prison
    utility:AddCooldown(0, 0, 187827, nil, true, ERALIBTalent:CreateLevel(20))                            -- metamorphosis
    utility:AddCooldown(1, 0, 196718, nil, true, ERALIBTalent:Create(112921))                             -- darkness
    utility:AddCooldown(2, 0, 320341, nil, true, talent_bulk)
    utility:AddWarlockHealthStone(-2.5, -0.9)
    utility:AddTrinket2Cooldown(-1.5, -0.9, nil)
    utility:AddTrinket1Cooldown(-0.5, -0.9, nil)
    utility:AddRacial(0.5, -0.9).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(3, 4, 185245, nil, true).alphaWhenOffCooldown = 0.3   -- taunt
    utility:AddCooldown(3, 3, 198793, nil, true, ERALIBTalent:Create(112853)) -- retreat
    utility:AddCooldown(3, 2, 202138, nil, true, talent_chains)
    utility:AddCooldown(3.9, 2.5, 207684, nil, true, talent_misery)
    utility:AddCooldown(3.9, 3.5, 202137, nil, true, talent_silence)
    utility:AddWarlockPortal(4.8, 3)

    --[[

    PRIO

    1 - fracture all charges available
    2 - immolation (talent and not full fury soon)
    3 - dump
    4 - immolation (talent)
    5 - fracture
    6 - fel blade
    7 - soul carver
    8 - barrier
    9 - immolation
    10 - decree
    11 - hunt

    ]]

    function fractureCooldownIcon:computeAvailablePriority()
        if (talent_fracture:PlayerHasTalent()) then
            return 1
        else
            return 0
        end
    end

    function immolationIcon:computeAvailablePriority()
        if (talent_protective_immolation:PlayerHasTalent()) then
            local missingFury = fury.maxPower - fury.currentPower
            if (talent_fracture:PlayerHasTalent() and fractureCooldown.currentCharges > 0 and missingFury >= 25
                    and fractureCooldown.currentCharges + 1 >= fractureCooldown.maxCharges and fractureCooldown.remDuration <= 0.7
                ) then
                return 4
            else
                return 1
            end
        else
            return 9
        end
    end

    local dump = timers:AddPriority(1344653)
    function dump:computePriority(t)
        if (fury.maxPower - fury.currentPower < 25) then
            return 3
        else
            return 0
        end
    end

    local fractureNotAllCharges = timers:AddPriority(1388065)
    function fractureNotAllCharges:computePriority(t)
        if (talent_fracture:PlayerHasTalent()) then
            if (fractureCooldown.currentCharges > 0 and fractureCooldown.maxCharges > fractureCooldown.currentCharges and fury.maxPower - fury.currentPower >= 25) then
                return 5
            else
                return 0
            end
        else
            return 0
        end
    end

    function felbladeCooldownIcon:computeAvailablePriority()
        if (fury.maxPower - fury.currentPower >= 35) then
            return 6
        else
            return 0
        end
    end

    function soulCarverIcon:computeAvailablePriority()
        return 7
    end

    function barrierCooldownIcon:computeAvailablePriority()
        return 8
    end

    function decreeCooldownIcon:computeAvailablePriority()
        return 10
    end

    for _, i in ipairs(huntIcons) do
        function i:computeAvailablePriority()
            return 11
        end
    end
end

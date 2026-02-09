---@param cFrame ERACombatMainFrame
---@param talents DeathKnightTalents
function ERACombatFrames_DeathKnight_Unholy(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    --------------------------------
    --#region TALENTS

    local talent_sanlayn = ERALIBTalent:Create(117648)
    local talent_rider = ERALIBTalent:Create(117663)
    local talent_scythe = ERALIBTalent:Create(96330)
    local talent_putrefy = ERALIBTalent:Create(133522)
    local talent_transfo = ERALIBTalent:Create(96322)
    local talent_army = ERALIBTalent:Create(96333)
    local talent_sreaper = ERALIBTalent:Create(96314)
    local talent_pestilence = ERALIBTalent:Create(133513)
    local talent_clawing = ERALIBTalent:Create(133523)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.RunicPower)
    local runes = HUDRunesData:create(hud)

    local grip = hud:AddCooldown(49576)
    local dnd = hud:AddCooldown(43265)
    local fortitude = hud:AddCooldown(48792, talents.fortitude)
    local advance = hud:AddCooldown(48265)
    local walk = hud:AddCooldown(212552, talents.walk)
    local kick = hud:AddCooldown(47528, talents.kick)
    local vader = hud:AddCooldown(221562, talents.vader)
    local lichborne = hud:AddCooldown(49039)
    local ams = hud:AddCooldown(48707)
    local pact = hud:AddCooldown(48743, talents.pact)
    local amz = hud:AddCooldown(51052, talents.amz)
    local blind = hud:AddCooldown(207167, talents.blind)
    local icePrison = hud:AddCooldown(45524, talents.icePrison)
    local putrefy = hud:AddCooldown(1247378, talent_putrefy)
    local transfo = hud:AddCooldown(1233448, talent_transfo)
    local army = hud:AddCooldown(42650, talent_army)
    local sreaper = hud:AddCooldown(343294, talent_sreaper)
    local pestilence = hud:AddCooldown(1271967, talent_pestilence)


    local doom = hud:AddAuraByPlayer(49530, false)
    local commander = hud:AddAuraByPlayer(390259, false)
    local bloodqueen = hud:AddAuraByPlayer(433901, false, talent_sanlayn)
    local dot1 = hud:AddAuraByPlayer(1240996, true)
    local dot2 = hud:AddAuraByPlayer(191587, true)
    local frenzy = hud:AddAuraByPlayer(377587, false)
    local scythe = hud:AddAuraByPlayer(455397, false, talent_scythe)
    local transfoBuff = hud:AddAuraByPlayer(1233448, false, talent_transfo)
    local clawing = hud:AddAuraByPlayer(1241567, false, talent_clawing)
    local lesser = hud:AddAuraByPlayer(1242998, false)
    local strikestack = hud:AddAuraByPlayer(1254252, false)
    local draw = hud:AddAuraByPlayer(374598, false, talents.draw)
    local runeStrength = hud:AddAuraByPlayer(53365, false)
    local undeath = hud:AddAuraByPlayer(444633, true, talent_rider)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(draw)

    hud:AddEssentialsLeftAura(runeStrength)

    hud:AddEssentialsLeftAura(lesser)

    hud:AddEssentialsCooldown(putrefy, nil, nil, 0.3, 1.0, 0.1, false)

    hud:AddEssentialsCooldown(pestilence, nil, nil, 1.0, 0.0, 1.0, false)

    local strikestackIcon, strikestackSlot = hud:AddEssentialsAura(strikestack, 237530)
    strikestackIcon:ShowStacksRatherThanDuration()
    strikestackSlot:AddTimerBar(0.5, scythe, nil, 0.4, 0.0, 0.0)

    local dotIcon, _, dotBar = hud:AddEssentialsAura(dot1, 7439189, nil, 1.0, 1.0, 0.0)
    dotIcon.showRedIfMissingInCombat = true
    dotBar.showPandemic = true

    local _, dndSlot = hud:AddEssentialsCooldown(dnd, nil, nil, 0.7, 0.0, 1.0, false)
    dndSlot:AddTimerBar(0.25, bloodqueen, nil, 1.0, 0.0, 0.0)

    hud:AddEssentialsCooldown(sreaper, nil, nil, 0.0, 0.0, 1.0, false)

    local _, transfoSlot = hud:AddEssentialsCooldown(transfo, nil, nil, 0.6, 0.5, 0.7)
    transfoSlot:AddTimerBar(0.25, transfoBuff, nil, 0.8, 0.5, 0.0)

    local _, undeathSlot, undeathBar = hud:AddEssentialsAura(undeath, nil, nil, 0.3, 0.8, 0.0):ShowStacksRatherThanDuration()

    hud:AddEssentialsRightAura(clawing)

    -- defensive
    hud.defensiveGroup:AddCooldown(pact)
    hud.defensiveGroup:AddCooldown(fortitude)
    hud.defensiveGroup:AddCooldown(ams)
    hud.defensiveGroup:AddCooldown(amz)
    hud.defensiveGroup:AddCooldown(lichborne)

    -- movement
    hud.movementGroup:AddCooldown(grip)
    hud.movementGroup:AddCooldown(advance)
    hud.movementGroup:AddCooldown(walk)

    -- control
    hud.controlGroup:AddCooldown(kick)
    hud:AddKickInfo(kick)
    hud.controlGroup:AddCooldown(vader)
    hud.controlGroup:AddCooldown(blind)
    hud.controlGroup:AddCooldown(icePrison)

    -- powerboost
    hud.powerboostGroup:AddCooldown(army)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddSpellIconAlert(55090, 5927645, talent_sanlayn, "CovenantChoice-Celebration-Venthyr-DetailLine", true).playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddMissingAuraOverlayAlert(dot2, nil, "icons_64x64_disease", true, false)

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddRunes(runes)

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.2, 0.7, 1.0)
    local tickCoil = powerBar:AddTick(136145, nil, function() return 30 end)
    function tickCoil:OverrideAlpha()
        if (doom.auraIsPresent) then
            return 0.0
        else
            return 1.0
        end
    end
    local tickDoom = powerBar:AddTick(136145, nil, function() return 20 end)
    function tickDoom:OverrideAlpha()
        if (doom.auraIsPresent) then
            return 1.0
        else
            return 0.0
        end
    end

    local petHealth = hud:AddPetHealth()
    hud:AddResourceSlot(true):AddHealth(petHealth, true)

    --#endregion
    --------------------------------
end

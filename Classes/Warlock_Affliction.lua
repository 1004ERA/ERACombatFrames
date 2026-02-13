---@param cFrame ERACombatMainFrame
---@param talents WarlockTalents
function ERACombatFrames_Warlock_Affliction(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_harvester = ERALIBTalent:Create(117448)
    local talent_malevolence = ERALIBTalent:Create(117439)
    local talent_wither = ERALIBTalent:Create(117437)
    local talent_corruption = ERALIBTalent:CreateNotTalent(117437)
    local talent_haunt = ERALIBTalent:Create(91552)
    local talent_harvest = ERALIBTalent:Create(136120)
    local talent_glare = ERALIBTalent:Create(91554)
    local talent_sacrifice = ERALIBTalent:Create(124691)
    local talent_unstableFree = ERALIBTalent:Create(136117)
    local talent_infinite_corruption = ERALIBTalent:Create(91572)
    local talent_finite_corruption = ERALIBTalent:CreateNot(talent_infinite_corruption)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local shards = hud:AddPowerTargetIdle(Enum.PowerType.SoulShards, nil, function() return 3 end)

    local commonSpells = ERACombatFrames_WarlockCommonSpells(hud, talents)

    local haunt = hud:AddCooldown(48181, talent_haunt)
    local harvest = hud:AddCooldown(1257052, talent_harvest)
    local glare = hud:AddCooldown(205180, talent_glare)
    local malevolence = hud:AddCooldown(442726, talent_malevolence)

    local agony = hud:AddAuraByPlayer(980, true)
    local corruption = hud:AddAuraByPlayer(146739, true, talent_corruption)
    local wither = hud:AddAuraByPlayer(445474, true, talent_wither)
    local unstable = hud:AddAuraByPlayer(1259790, true)
    local unstableFree = hud:AddAuraByPlayer(1260269, false, talent_unstableFree)
    local sacriBuff = hud:AddAuraByPlayer(196099, false, talent_sacrifice)
    local seed = hud:AddAuraByPlayer(27243, true)
    local nightfall = hud:AddAuraByPlayer(264571, false)
    local hauntBuff = hud:AddAuraByPlayer(48181, true, talent_haunt)
    local malevoBuff = hud:AddAuraByPlayer(442726, false, talent_malevolence)
    local succulent = hud:AddAuraByPlayer(449793, false, talent_harvester)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    hud:AddChannelInfo(198590, 5, 1)

    -- essentials

    hud:AddEssentialsLeftAura(succulent)

    hud:AddEssentialsLeftAura(unstable)

    local _, malevoSlot = hud:AddEssentialsCooldown(malevolence, nil, nil, 0.7, 0.1, 0.8)
    malevoSlot:AddTimerBar(0.75, malevoBuff, nil, 1.0, 1.0, 1.0)

    hud:AddDOT(corruption, nil, talent_finite_corruption, 0.8, 0.6, 0.0)
    hud:AddDOT(wither, nil, talent_finite_corruption, 0.8, 0.6, 0.0)

    hud:AddDOT(agony, nil, nil, 1.0, 0.8, 0.5)

    local _, hauntSlot = hud:AddEssentialsCooldown(haunt, nil, nil, 0.0, 0.0, 1.0)
    hauntSlot:AddTimerBar(0.25, hauntBuff, nil, 1.0, 1.0, 1.0)

    hud:AddEssentialsRightCooldown(harvest)

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.resolve)
    hud.defensiveGroup:AddCooldown(commonSpells.pact)

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.teleport)
    hud.movementGroup:AddCooldown(commonSpells.gateway)

    -- special
    hud.specialGroup:AddCooldown(commonSpells.instapet)
    --hud.specialGroup:AddCooldown(commonSpells.soulburn)

    -- control
    hud.controlGroup:AddCooldown(commonSpells.commandDemonKick).showOnlyIf = commonSpells.commandDemonIsKick
    hud.controlGroup:AddCooldown(commonSpells.coil)
    hud.controlGroup:AddCooldown(commonSpells.shadowfury)
    hud.controlGroup:AddCooldown(commonSpells.howl)
    hud.controlGroup:AddCooldown(commonSpells.bweakness)
    hud.controlGroup:AddCooldown(commonSpells.btongues)

    -- powerboost
    hud.powerboostGroup:AddCooldown(glare)

    -- buff
    hud.buffGroup:AddAura(malevoBuff)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddMissingAuraOverlayAlert(corruption, talent_infinite_corruption, "icons_64x64_disease", true, false, "NONE", "CENTER").showOnlyWhenInCombatWithEnemyTarget = true
    hud:AddMissingAuraOverlayAlert(wither, talent_infinite_corruption, "icons_64x64_disease", true, false, "NONE", "CENTER").showOnlyWhenInCombatWithEnemyTarget = true
    --hud:AddAuraOverlayAlert(unstableFree, nil, "Artifacts-PriestShadow-Header", true).playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    --hud:AddAuraOverlayAlert(unstableFree, nil, "oribos-weeklyrewards-orb-dialog", true).playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddAuraOverlayAlert(unstableFree, nil, "Insanity-TopPurpleShadow", true, "NONE", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddPowerPoints(shards, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, nil, function() return 3 end)

    local petHealth = hud:AddPetHealth()
    local petBar = hud:AddResourceSlot(true):AddHealth(petHealth, true)
    function petBar:ShowIfNoUnit(t, combat)
        return (not talent_sacrifice:PlayerHasTalent()) or not sacriBuff.auraIsPresent
    end

    --#endregion
    --------------------------------
end

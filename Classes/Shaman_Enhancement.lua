---@param cFrame ERACombatMainFrame
---@param talents ShamanTalents
function ERACombatFrames_Shaman_Enhancement(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)
    hud.hideDefaultSpellAlerts = true

    --------------------------------
    --#region TALENTS

    local talent_stormbringer = ERALIBTalent:Create(117489)
    local talent_totemic = ERALIBTalent:Create(117474)
    local talent_crash = ERALIBTalent:Create(101840)
    local talent_10_maelstrom = ERALIBTalent:Create(101802)
    local talent_voltaic = ERALIBTalent:Create(101819)
    local talent_flshock = ERALIBTalent:CreateNot(talent_voltaic)
    local talent_sundering = ERALIBTalent:Create(101841)
    local talent_ascendance = ERALIBTalent:Create(114291)
    local talent_rooted = ERALIBTalent:Create(101816)
    local talent_ascendance_or_rooted = ERALIBTalent:CreateOr(talent_ascendance, talent_rooted)
    local talent_doomwind_buff = ERALIBTalent:Create(101824)
    local talent_doomwind_cd = ERALIBTalent:CreateAnd(ERALIBTalent:CreateNot(talent_ascendance_or_rooted), talent_doomwind_buff)
    local talent_conduit = ERALIBTalent:Create(117460)
    local talent_surging = ERALIBTalent:Create(125617)
    local talent_hothand = ERALIBTalent:Create(101809)
    local talent_primordial = ERALIBTalent:Create(101828)
    local talent_apex = ERALIBTalent:CreateOr(ERALIBTalent:Create(136969), ERALIBTalent:Create(136970), ERALIBTalent:Create(136971))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local stormstrike = hud:AddCooldown(17364)
    local lava = hud:AddCooldown(60103)
    local crash = hud:AddCooldown(187874, talent_crash)
    local flshock = hud:AddCooldown(470411, talent_flshock)
    local voltaic = hud:AddCooldown(470057, talent_voltaic)
    local doomwind = hud:AddCooldown(384352, talent_doomwind_cd)
    local ascendance = hud:AddCooldown(114051, talent_ascendance)
    local sundering = hud:AddCooldown(197214, talent_sundering)
    local totemic = hud:AddCooldown(444995, talent_totemic)
    local lunge = hud:AddCooldown(196884)

    local lshield = hud:AddAuraByPlayer(192106, false)
    local maelstrom = hud:AddAuraByPlayer(187880, false)
    local crashBuff = hud:AddAuraByPlayer(187874, false, talent_crash)
    local flame = hud:AddAuraByPlayer(188389, true)
    local tempest = hud:AddAuraByPlayer(454015, false, talent_stormbringer)
    local surging = hud:AddAuraByPlayer(454372, false, talent_surging)
    local conduit = hud:AddAuraByPlayer(467778, false, talent_conduit)
    local spiritwalk = hud:AddAuraByPlayer(79206, false, talents.spiritwalk)
    local discharge = hud:AddAuraByPlayer(455096, false, talent_stormbringer)
    local searing = hud:AddAuraByPlayer(445034, false, talent_totemic)
    local ascendanceDuration = hud:AddAuraByPlayer(114051, false, talent_ascendance)
    local rootedDuration = hud:AddAuraByPlayer(114051, false, talent_rooted)
    local dwinds = hud:AddAuraByPlayer(384352, false, talent_doomwind_buff)
    local raging_heal = hud:AddAuraByPlayer(384143, false, talent_10_maelstrom)
    local hothand = hud:AddAuraByPlayer(201900, false, talent_hothand)
    local apex = hud:AddAuraByPlayer(1262830, false, talent_apex)

    local primordialUsable = hud:AddAuraBoolean(hud:AddAuraByPlayer(1218125, false, talent_primordial))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive

    -- movement
    hud.movementGroup:AddCooldown(lunge)

    -- control

    -- buffs

    -- powerboost
    hud.powerboostGroup:AddCooldown(ascendance)
    hud.powerboostGroup:AddCooldown(doomwind)

    local commonSpells = ERACombatFrames_ShamanCommonSpells(hud, talents, false)

    -- assist

    -- essentials

    hud:AddEssentialsLeftAura(surging, 136044):ShowStacksRatherThanDuration()
    hud:AddEssentialsLeftAura(raging_heal):ShowStacksRatherThanDuration()

    hud:AddEssentialsCooldown(totemic, nil, nil, 0.5, 0.6, 0.0)

    local _, crashSlot = hud:AddEssentialsCooldown(crash, nil, nil, 0.4, 0.4, 1.0)
    crashSlot:AddTimerBar(0.75, crashBuff, nil, 1.0, 1.0, 1.0)
    crashSlot:AddTimerBar(0.25, apex, nil, 0.0, 1.0, 0.0)

    local _, stormSlot = hud:AddEssentialsCooldown(stormstrike, 1397637, nil, 0.5, 0.5, 1.0)
    stormSlot:AddTimerBar(0.75, ascendanceDuration, nil, 1.0, 0.0, 1.0)
    stormSlot:AddTimerBar(0.75, rootedDuration, nil, 1.0, 0.0, 1.0).doNotCutLongDuration = true
    crashSlot:AddTimerBar(0.25, dwinds, nil, 0.55, 0.4, 0.4).doNotCutLongDuration = true

    local _, lavaSlot = hud:AddEssentialsCooldown(lava, nil, nil, 1.0, 0.0, 0.0)
    lavaSlot:AddTimerBar(0.25, hothand, nil, 1.0, 0.5, 0.0).doNotCutLongDuration = true
    lavaSlot:AddTimerBar(0.75, searing, nil, 0.5, 1.0, 0.0).doNotCutLongDuration = true

    local _, flameSlot = hud:AddEssentialsCooldown(flshock, nil, nil, 0.8, 0.4, 0.0, false)
    flameSlot:AddOverlapingCooldown(voltaic, nil, nil, 0.8, 0.4, 0.0)
    flameSlot:AddTimerBar(0.5, voltaic, nil, 0.8, 0.4, 0.0)

    local _, dotSlot = hud:AddDOT(flame, 135805, nil, 1.0, 1.0, 0.0) -- 2175503 451164
    dotSlot:AddTimerBar(0.75, spiritwalk, nil, 0.7, 1.0, 0.7)

    local sunderingIcon = hud:AddEssentialsCooldown(sundering, nil, nil, 0.5, 0.5, 0.2)
    sunderingIcon.overlayAlsoIf = primordialUsable

    hud:AddEssentialsRightAura(discharge):ShowStacksRatherThanDuration()

    hud:AddEssentialsRightCooldown(commonSpells.relocation, nil, talent_totemic)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud.alertGroup:AddMissingAuraAlert(lshield)

    conduit.playSoundWhenApperars = ECF_CDM_Sounds.Instruments_BellRing
    --hothand.playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST
    dwinds.playSoundWhenApperars = ECF_CDM_Sounds.Instruments_Guitar_Chug -- Instruments_XylophoneMetal
    rootedDuration.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddAuraOverlayAlert(tempest, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Fulmination.tga", false, "NONE", "TOP")
    hud:AddAuraOverlayAlert(discharge, nil, "Interface/Addons/ERACombatFrames/textures/alerts/maelstrom_weapon_2.tga", false, "ROTATE_RIGHT", "RIGHT")
    hud:AddAuraOverlayAlert(apex, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Daybreak.tga", false, "NONE", "LEFT")

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local maelstromPoints = hud:AddResourceSlot(false):AddStacksPoints(maelstrom, 1.0, 1.0, 1.0, 0.5, 0.7, 1.0, nil, function() return 0 end, function() if (talent_10_maelstrom:PlayerHasTalent()) then return 10 else return 5 end end)

    --#endregion
    --------------------------------
end

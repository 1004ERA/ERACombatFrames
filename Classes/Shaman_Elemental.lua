---@param cFrame ERACombatMainFrame
---@param talents ShamanTalents
function ERACombatFrames_Shaman_Elemental(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_stormbringer = ERALIBTalent:Create(117489)
    local talent_farseer = ERALIBTalent:Create(117485)
    local talent_ancestral_swift = ERALIBTalent:Create(117491)
    local talent_blast = ERALIBTalent:Create(127924)
    local talent_eshock = ERALIBTalent:Create(101854)
    local talent_earthquake = ERALIBTalent:CreateOr(ERALIBTalent:Create(127925), ERALIBTalent:Create(101855))
    local talent_cheap_spenders = ERALIBTalent:Create(101877)
    local talent_stormkeeper = ERALIBTalent:Create(101859)
    local talent_ascendant = ERALIBTalent:Create(101860)
    local talent_voltaic = ERALIBTalent:Create(101883)
    local talent_flshock = ERALIBTalent:CreateNot(talent_voltaic)
    local talent_fire_elem = ERALIBTalent:Create(101864)
    local talent_surging = ERALIBTalent:Create(125617)
    local talent_conduit = ERALIBTalent:Create(117460)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Maelstrom)

    local thunder = hud:AddCooldown(51490)
    local lava = hud:AddCooldown(51505)
    local flshock = hud:AddCooldown(470411, talent_flshock)
    local voltaic = hud:AddCooldown(470057, talent_voltaic)
    local ascendance = hud:AddCooldown(114050, talent_ascendant)
    local stormkeeper = hud:AddCooldown(191634, talent_stormkeeper)
    local ancestral_swift = hud:AddCooldown(443454, talent_ancestral_swift)

    local ascendanceDuration = hud:AddAuraByPlayer(1219480, false, talent_ascendant)
    local flame = hud:AddAuraByPlayer(470411, true)
    local blast_mastery = hud:AddAuraByPlayer(173184, false, talent_blast)
    local blast_crit = hud:AddAuraByPlayer(118522, false, talent_blast)
    local blast_haste = hud:AddAuraByPlayer(173183, false, talent_blast)
    local shield = hud:AddAuraByPlayer(192106, false)
    local fireElem = hud:AddAuraTotem(1, 378255, talent_fire_elem)
    local spiritwalk = hud:AddAuraByPlayer(79206, false, talents.spiritwalk)
    local stormkeeper_stacks = hud:AddAuraByPlayer(191634, false, talent_stormkeeper)
    local tempest = hud:AddAuraByPlayer(454015, false, talent_stormbringer)
    local surging = hud:AddAuraByPlayer(454372, false, talent_surging)
    local conduit = hud:AddAuraByPlayer(467778, false, talent_conduit)
    local ancestors = hud:AddAuraByPlayer(443450, false, talent_farseer)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- control
    hud.controlGroup:AddCooldown(thunder)

    -- buffs
    hud.buffGroup:AddAura(ascendanceDuration)
    hud.buffGroup:AddAuraLike(fireElem)
    hud.buffGroup:AddAura(spiritwalk)

    -- powerboost
    hud.powerboostGroup:AddCooldown(ascendance)

    -- alerts
    hud.alertGroup:AddMissingAuraAlert(shield)

    local commonSpells = ERACombatFrames_ShamanCommonSpells(hud, talents, false, talent_ancestral_swift)

    -- essentials

    local _, aswiftSlot = hud:AddEssentialsCooldown(ancestral_swift, nil, nil, 0.6, 0.8, 1.0)
    aswiftSlot:AddTimerBar(0.75, ancestors, nil, 0.0, 0.0, 1.0).doNotCutLongDuration = true

    local blastC, blastSlot = hud:AddEssentialsAura(blast_crit)
    blastC.showRedIfMissingInCombat = true
    blastC:SetBorderColor(0.4, 0.5, 0.0)
    blastSlot:AddOverlapingAura(blast_mastery):SetBorderColor(0.6, 0.0, 1.0)
    --blastSlot:AddOverlapingAura(blast_haste):SetBorderColor(0.0, 1.0, 0.0)
    blastSlot:AddTimerBar(0.33, blast_crit, nil, 0.4, 0.5, 0.0)
    blastSlot:AddTimerBar(0.66, blast_mastery, nil, 0.6, 0.0, 1.0)
    --blastSlot:AddTimerBar(0.25, blast_haste, nil, 0.0, 1.0, 0.0)

    local _, lavaSlot = hud:AddEssentialsCooldown(lava, nil, nil, 1.0, 0.0, 0.0)
    lavaSlot:AddTimerBar(0.25, ascendanceDuration, nil, 1.0, 0.0, 1.0)
    lavaSlot:AddTimerBar(0.75, fireElem, nil, 1.0, 1.0, 1.0)

    local _, flameSlot = hud:AddEssentialsCooldown(flshock, nil, nil, 0.8, 0.4, 0.0, false)
    flameSlot:AddOverlapingCooldown(voltaic, nil, nil, 0.8, 0.4, 0.0)
    flameSlot:AddTimerBar(0.5, voltaic, nil, 0.8, 0.4, 0.0)

    local _, dotSlot = hud:AddDOT(flame, 135805, nil, 1.0, 1.0, 0.0) -- 2175503 451164
    dotSlot:AddTimerBar(0.75, spiritwalk, nil, 0.7, 1.0, 0.7)

    hud:AddEssentialsCooldown(stormkeeper, nil, nil, 0.2, 0.2, 1.0)

    hud:AddEssentialsRightAura(stormkeeper_stacks, 839974):ShowStacksRatherThanDuration() -- 135990 136099

    hud:AddEssentialsRightAura(surging, 136044):ShowStacksRatherThanDuration()

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    conduit.playSoundWhenApperars = ECF_CDM_Sounds.Instruments_BellRing
    hud:AddAuraOverlayAlert(tempest, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Fulmination.tga", false, "NONE", "TOP")--.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.0, 0.7, 0.9)
    powerBar:AddTick(136026, talent_eshock, function() if (talent_cheap_spenders:PlayerHasTalent()) then return 55 else return 60 end end)
    powerBar:AddTick(451165, ERALIBTalent:CreateAnd(talent_earthquake, ERALIBTalent:CreateNot(talent_eshock)), function() if (talent_cheap_spenders:PlayerHasTalent()) then return 55 else return 60 end end)
    powerBar:AddTick(651244, talent_blast, function() if (talent_cheap_spenders:PlayerHasTalent()) then return 80 else return 90 end end)

    --#endregion
    --------------------------------
end

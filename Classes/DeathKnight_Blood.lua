---@param cFrame ERACombatMainFrame
---@param talents DeathKnightTalents
function ERACombatFrames_DeathKnight_Blood(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_sanlayn = ERALIBTalent:Create(117648)
    local talent_drw = ERALIBTalent:Create(96269)
    local talent_gorefiend = ERALIBTalent:Create(96170)
    local talent_limb = ERALIBTalent:Create(136213)
    local talent_consumption = ERALIBTalent:Create(126300)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.RunicPower)
    local runes = HUDRunesData:create(hud)

    local caress = hud:AddCooldown(195292)
    local boil = hud:AddCooldown(50842)
    local dnd = hud:AddCooldown(43265)
    local fortitude = hud:AddCooldown(48792, talents.fortitude)
    local consumption = hud:AddCooldown(1263824, talent_consumption)
    local advance = hud:AddCooldown(48265)
    local walk = hud:AddCooldown(212552, talents.walk)
    local kick = hud:AddCooldown(47528, talents.kick)
    local vader = hud:AddCooldown(221562, talents.vader)
    local lichborne = hud:AddCooldown(49039)
    local vblood = hud:AddCooldown(55233)
    local ams = hud:AddCooldown(48707)
    local taunt = hud:AddCooldown(56222)
    local pact = hud:AddCooldown(48743, talents.pact)
    local limb = hud:AddCooldown(1263569, talent_limb)
    local gorefiend = hud:AddCooldown(108199, talent_gorefiend)
    local amz = hud:AddCooldown(51052, talents.amz)
    local blind = hud:AddCooldown(207167, talents.blind)
    local icePrison = hud:AddCooldown(45524, talents.icePrison)
    local drw = hud:AddCooldown(49028, talent_drw)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftCooldown(caress)

    hud:AddEssentialsCooldown(boil, nil, nil, 1.0, 0.0, 0.0)

    hud:AddEssentialsCooldown(dnd, nil, nil, 0.7, 0.0, 1.0, false)

    hud:AddEssentialsCooldown(consumption, nil, nil, 0.0, 1.0, 0.0)

    -- defensive
    hud:AddDefensiveCooldown(vblood)
    hud:AddDefensiveCooldown(pact)
    hud:AddDefensiveCooldown(fortitude)
    hud:AddDefensiveCooldown(ams)
    hud:AddDefensiveCooldown(amz)
    hud:AddDefensiveCooldown(lichborne)

    -- control
    hud:AddControlCooldown(kick)
    hud:AddKickInfo(kick)
    hud:AddControlCooldown(advance)
    hud:AddControlCooldown(walk)
    hud:AddControlCooldown(limb)
    hud:AddControlCooldown(gorefiend)
    hud:AddControlCooldown(vader)
    hud:AddControlCooldown(blind)
    hud:AddControlCooldown(icePrison)

    -- powerboost
    hud:AddPowerboostCooldown(drw)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddSpellIconAlert(206930, 5927645, talent_sanlayn, "CovenantChoice-Celebration-Venthyr-DetailLine", true).playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddRunes(runes)

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.2, 0.7, 1.0)

    --#endregion
    --------------------------------
end

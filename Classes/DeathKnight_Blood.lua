---@param cFrame ERACombatMainFrame
---@param talents DeathKnightTalents
function ERACombatFrames_DeathKnight_Blood(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_sanlayn = ERALIBTalent:Create(117648)
    local talent_deathbringer = ERALIBTalent:Create(117659)
    local talent_drw = ERALIBTalent:Create(96269)
    local talent_gorefiend = ERALIBTalent:Create(96170)
    local talent_limb = ERALIBTalent:Create(136213)
    local talent_consumption = ERALIBTalent:Create(126300)
    local talent_coagul = ERALIBTalent:Create(96169)
    local talent_hemostasis = ERALIBTalent:Create(96268)
    local talent_ossuary = ERALIBTalent:Create(96277)
    local talent_draw_ossuary = ERALIBTalent:CreateAnd(talents.draw, talent_ossuary)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.RunicPower)
    local runes = HUDRunesData:create(hud)

    local grip = hud:AddCooldown(49576)
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
    local deathbringer = hud:AddCooldown(439843, talent_deathbringer)

    local boneShield = hud:AddAuraByPlayer(195181, false)
    local coagul = hud:AddAuraByPlayer(391477, false, talent_coagul)
    local scourge = hud:AddAuraByPlayer(81136, false)
    local drwBuff = hud:AddAuraByPlayer(81256, false, talent_drw)
    local draw = hud:AddAuraByPlayer(374598, false, talents.draw)
    local hemostasis = hud:AddAuraByPlayer(273946, false, talent_hemostasis)
    local fortitudeBuff = hud:AddAuraByPlayer(48792, false, talents.fortitude)
    local chill = hud:AddAuraByPlayer(3915666, true, talents.chill)
    local bPlague = hud:AddAuraByPlayer(50842, true)
    local lichBuff = hud:AddAuraByPlayer(49039, false)
    local ossuary = hud:AddAuraByPlayer(219786, false)
    local runeStrength = hud:AddAuraByPlayer(53365, false)
    local vBloodBuff = hud:AddAuraByPlayer(55233, false)
    local deathStrikeHealing = hud:AddAuraByPlayer(49998, false)

    local vampStrike = hud:AddIconBoolean(206930, 5927645, talent_sanlayn)

    --#endregion
    --------------------------------
    ---/run

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(runeStrength)

    local bshieldIcon, bshieldSlot = hud:AddEssentialsAura(boneShield)
    bshieldIcon:ShowStacksRatherThanDuration()
    bshieldIcon.showRedIfMissingInCombat = true
    bshieldSlot:AddTimerBar(0.25, lichBuff, nil, 0.5, 0.5, 0.5).doNotCutLongDuration = true
    bshieldSlot:AddTimerBar(0.75, vBloodBuff, nil, 0.0, 1.0, 0.0).doNotCutLongDuration = true

    local _, boilSlot = hud:AddEssentialsCooldown(boil, nil, nil, 1.0, 0.0, 0.0)
    --boilSlot:AddTimerBar(0.25, runeStrength, nil, 0.7, 0.4, 0.9)
    boilSlot:AddTimerBar(0.75, drwBuff, nil, 0.9, 0.4, 0.7).doNotCutLongDuration = true

    local _, dndSlot = hud:AddEssentialsCooldown(dnd, nil, nil, 0.7, 0.0, 1.0, false)
    boilSlot:AddTimerBar(0.25, draw, nil, 0.0, 1.0, 1.0).doNotCutLongDuration = true

    hud:AddEssentialsCooldown(deathbringer, nil, nil, 0.6, 0.0, 0.5)

    hud:AddEssentialsCooldown(consumption, nil, nil, 0.0, 1.0, 0.0)

    -- defensive
    hud.defensiveGroup:AddCooldown(vblood)
    hud.defensiveGroup:AddCooldown(pact)
    hud.defensiveGroup:AddCooldown(fortitude)
    hud.defensiveGroup:AddCooldown(ams)
    hud.defensiveGroup:AddCooldown(amz)
    hud.defensiveGroup:AddCooldown(lichborne)

    -- movement
    hud.movementGroup:AddCooldown(grip)
    hud.movementGroup:AddCooldown(advance)
    hud.movementGroup:AddCooldown(walk)
    hud.movementGroup:AddCooldown(caress)

    -- control
    hud.controlGroup:AddCooldown(kick)
    hud:AddKickInfo(kick)
    hud.controlGroup:AddCooldown(limb)
    hud.controlGroup:AddCooldown(gorefiend)
    hud.controlGroup:AddCooldown(vader)
    hud.controlGroup:AddCooldown(blind)
    hud.controlGroup:AddCooldown(icePrison)

    -- powerboost
    hud.powerboostGroup:AddCooldown(drw)

    -- buffs
    hud.buffGroup:AddAura(hemostasis):ShowStacksRatherThanDuration()
    hud.buffGroup:AddAura(vBloodBuff)
    hud.buffGroup:AddAura(fortitudeBuff)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddPublicBooleanOverlayAlert(nil, "CovenantChoice-Celebration-Venthyr-DetailLine", true, vampStrike).playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddRunes(runes)

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.2, 0.7, 1.0)
    local tickOssuaryDraw = powerBar:AddTick(237517, talent_draw_ossuary, function() return 25 end)
    function tickOssuaryDraw:OverrideAlpha()
        if (draw.auraIsPresent and ossuary.auraIsPresent) then
            return 1.0
        else
            return 0.0
        end
    end
    local tickDraw = powerBar:AddTick(237517, talents.draw, function() return 30 end)
    function tickDraw:OverrideAlpha()
        if (draw.auraIsPresent and not ossuary.auraIsPresent) then
            return 1.0
        else
            return 0.0
        end
    end
    local tickOssuary = powerBar:AddTick(237517, talent_ossuary, function() return 35 end)
    function tickOssuary:OverrideAlpha()
        if (ossuary.auraIsPresent and not draw.auraIsPresent) then
            return 1.0
        else
            return 0.0
        end
    end
    local tickNothing = powerBar:AddTick(237517, nil, function() return 40 end)
    function tickNothing:OverrideAlpha()
        if (ossuary.auraIsPresent or draw.auraIsPresent) then
            return 0.0
        else
            return 1.0
        end
    end

    local healing = hud:AddResourceSlot(false):AddStacksBar(deathStrikeHealing, 1.0, 0.5, 0.5, nil, function() return 100 end, function() return 0 end)
    healing.showEmptyInCombat = true
    healing.heightMultiplier = 0.5

    --#endregion
    --------------------------------
end

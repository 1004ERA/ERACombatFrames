---@param cFrame ERACombatMainFrame
---@param talents DruidTalents
function ERACombatFrames_Druid_Guardian(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    --------------------------------
    --#region TALENTS

    local talent_chosen = ERALIBTalent:Create(117205)
    local talent_claw = ERALIBTalent:Create(117206)
    local talent_incarnation = ERALIBTalent:Create(103201)
    local talent_berserk = ERALIBTalent:CreateAnd(ERALIBTalent:Create(103216), ERALIBTalent:CreateNot(talent_incarnation))
    local talent_instincts = ERALIBTalent:Create(103193)
    local talent_dreamcenarius = ERALIBTalent:Create(114698)
    local talent_goryfur = ERALIBTalent:Create(135566)
    local talent_bristling = ERALIBTalent:Create(103230)
    local talent_beam = ERALIBTalent:Create(114700)
    local talent_redmoon = ERALIBTalent:Create(135336)
    local talent_moonfire = ERALIBTalent:CreateNot(talent_redmoon)
    local talent_sundering = ERALIBTalent:Create(114701)
    local talent_convoke = ERALIBTalent:Create(103200)
    local talent_galactic = ERALIBTalent:Create(103212)
    local talent_galactic_moonfire = ERALIBTalent:CreateAnd(talent_galactic, talent_moonfire)
    local talent_galactic_redmoon = ERALIBTalent:CreateAnd(talent_galactic, talent_redmoon)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local rage = hud:AddPowerLowIdle(Enum.PowerType.Rage)

    local mangle = hud:AddCooldown(33917)
    local thrash = hud:AddCooldown(77758)
    local regen = hud:AddCooldown(22842)
    local instincts = hud:AddCooldown(61336, talent_instincts)
    local berserk = hud:AddCooldown(50334, talent_berserk)
    local incarnation = hud:AddCooldown(102558, talent_incarnation)
    local bristling = hud:AddCooldown(155835, talent_bristling)
    local beam = hud:AddCooldown(204066, talent_beam)
    local redmoon = hud:AddCooldown(1252871, talent_redmoon)
    local convoke = hud:AddCooldown(391528, talent_convoke)
    local sundering = hud:AddCooldown(1253799, talent_sundering)

    local berserk_incarnation = hud:AddAuraByPlayer(50334, false)
    local bristlingBuff = hud:AddAuraByPlayer(155835, false, talent_bristling)
    local dreamcenarius = hud:AddAuraByPlayer(372119, false, talent_dreamcenarius)
    local regenBuff = hud:AddAuraByPlayer(22842, false)
    local ironfur = hud:AddAuraByPlayer(192081, false)
    local beamDuration = hud:AddAuraByPlayer(204066, false, talent_beam)
    local sunderingDuration = hud:AddAuraByPlayer(1253799, false, talent_sundering)
    local instinctsDuration = hud:AddAuraByPlayer(61336, false, talent_instincts)
    local thrashDuration = hud:AddAuraByPlayer(77758, true)
    local moonfire = hud:AddAuraByPlayer(8921, true, talent_moonfire)
    local redmoonDuration = hud:AddAuraByPlayer(1252871, true, talent_redmoon)
    --local galactic_redmoon = hud:AddAuraByPlayer(?, false, talent_galactic_redmoon)
    local galactic_moonfire = hud:AddAuraByPlayer(203964, false, talent_galactic_moonfire)
    local ravage = hud:AddIconBoolean(6807, 5927623, talent_claw)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddDOT(moonfire, nil, nil, 0.3, 0.3, 1.0)

    local _, redmoonSlot = hud:AddEssentialsCooldown(redmoon, nil, nil, 0.4, 0.2, 0.9)
    redmoonSlot:AddTimerBar(0.75, redmoonDuration, nil, 0.3, 0.3, 1.0)

    local _, mangleSlot = hud:AddEssentialsCooldown(mangle, nil, nil, 1.0, 0.0, 0.0)
    mangleSlot:AddTimerBar(0.75, ironfur, nil, 0.5, 0.4, 0.4)

    local thrashIcon = hud:AddEssentialsCooldown(thrash, nil, nil, 0.8, 0.7, 0.6)
    thrashIcon:HideCountdown()
    function thrashIcon:IconUpdated(t, combat, icon)
        icon:SetMainText(thrashDuration.stacksDisplay, true)
    end

    local _, regenSlot = hud:AddEssentialsCooldown(regen, nil, nil, 0.0, 0.7, 0.0)
    regenSlot:AddTimerBar(0.25, regenBuff, nil, 0.0, 1.0, 0.0).doNotCutLongDuration = true

    local _, beamSlot = hud:AddEssentialsCooldown(beam, nil, nil, 0.7, 0.4, 1.0)
    beamSlot:AddTimerBar(0.25, beamDuration, nil, 1.0, 1.0, 1.0).doNotCutLongDuration = true

    local _, bristlingSlot = hud:AddEssentialsCooldown(bristling, nil, nil, 0.7, 0.5, 0.5)
    --bristlingSlot:AddTimerBar(0.25, bristlingBuff, nil, 0.8, 0.6, 0.6).doNotCutLongDuration = true

    local _, sunderingSlot = hud:AddEssentialsCooldown(sundering, nil, nil, 0.9, 0.8, 0.4)
    sunderingSlot:AddTimerBar(0.25, sunderingDuration, nil, 1.0, 0.9, 0.5).doNotCutLongDuration = true

    -- defensive
    hud.defensiveGroup:AddCooldown(instincts)

    -- movement

    -- special

    -- control

    -- powerboost
    hud.powerboostGroup:AddCooldown(berserk)
    hud.powerboostGroup:AddCooldown(incarnation)
    hud.powerboostGroup:AddCooldown(convoke)

    -- buff
    hud.buffGroup:AddAura(berserk_incarnation)
    hud.buffGroup:AddAura(instinctsDuration)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(dreamcenarius, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Natures_Grace.tga", false, "MIRROR_H", "RIGHT")
    hud:AddPublicBooleanOverlayAlert(nil, "CovenantChoice-Celebration-Venthyr-DetailLine", true, ravage, "NONE", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local rageBar = hud:AddResourceSlot(false):AddPowerValue(rage, 1.0, 0.0, 0.0)
    local mainTick = rageBar:AddTick(132276, nil, function() return 40 end)
    local regenTick = rageBar:AddTick(132091, nil, function() return 10 end)
    function regenTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return regen.cooldownDuration:EvaluateRemainingPercent(hud.curveShowSoonAvailable)
    end

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, false, true, false)
end

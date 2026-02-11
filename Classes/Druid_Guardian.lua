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
    local talent_sundering = ERALIBTalent:Create(114701)
    local talent_convoke = ERALIBTalent:Create(103200)
    local talent_galactic = ERALIBTalent:Create(103212)

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
    local moonfire = hud:AddAuraByPlayer(8921, true)
    local redmoonDuration = hud:AddAuraByPlayer(1252871, true, talent_redmoon)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsCooldown(mangle, nil, nil, 1.0, 0.0, 0.0)
    hud:AddEssentialsCooldown(thrash, nil, nil, 0.8, 0.7, 0.6)

    -- defensive

    -- movement

    -- special

    -- control

    -- powerboost

    -- buff

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local rageBar = hud:AddResourceSlot(false):AddPowerValue(rage, 1.0, 0.0, 0.0)

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, false, true, false)
end

---@param cFrame ERACombatMainFrame
---@param talents DruidTalents
function ERACombatFrames_Druid_Restoration(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 4)

    --------------------------------
    --#region TALENTS


    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local starsurge = hud:AddCooldown(197626, talents.starsurge)

    local moonfire = hud:AddAuraByPlayer(8921, true)
    local sunfire = hud:AddAuraByPlayer(93402, true, talents.sunfire)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddDOT(moonfire, nil, nil, 0.2, 0.2, 0.8)

    hud:AddDOT(sunfire, nil, nil, 0.8, 0.8, 0.2)

    hud:AddEssentialsCooldown(starsurge, nil, nil, 1.0, 0.0, 1.0)

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

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, 0.2, 0.2, 1.0)

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, false, false, true)
end

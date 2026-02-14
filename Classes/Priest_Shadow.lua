---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Shadow(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)
    hud:AddChannelInfo(15407, 6, 0.75)

    --------------------------------
    --#region TALENTS

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mBlast = hud:AddCooldown(8092)

    local vTouch = hud:AddAuraByPlayer(34914, true)
    local swp = hud:AddAuraByPlayer(589, true)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsCooldown(mBlast, nil, nil, 1.0, 0.0, 0.0)

    hud:AddDOT(vTouch, nil, nil, 1.0, 0.5, 1.0)

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, true)

    --------------------------------
    --#region ALERTS

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    --#endregion
    --------------------------------
end

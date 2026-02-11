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


    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials


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

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, false, false, true)
end

---@param cFrame ERACombatMainFrame
---@param talents PaladinTalents
function ERACombatFrames_Paladin_Holy(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)
    --------------------------------
    --#region TALENTS

    

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive

    -- movement

    -- control

    -- buffs
    

    -- powerboost
    

    local commonSpells = ERACombatFrames_PaladinCommonSpells(cFrame, hud, talents)

    -- assist
    

    -- essentials

    

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end
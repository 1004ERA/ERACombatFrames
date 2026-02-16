---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Holy(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS

    local talent_oracle = ERALIBTalent:Create()
    local talent_archon = ERALIBTalent:Create(117300)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local pws = hud:AddCooldown(17)

    local swp = hud:AddAuraByPlayer(589, true)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive

    -- movement

    -- control

    -- buffs

    -- powerboost

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, false)

    -- assist

    -- essentials

    hud:AddDOT(swp, nil, nil, 1.0, 0.8, 0.0)

    ERACombatFrames_PriestSWDeath(hud, nil, commonSpells)


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

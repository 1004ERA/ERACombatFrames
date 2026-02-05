---@param cFrame ERACombatMainFrame
---@param talents DemonHunterTalents
function ERACombatFrames_DemonHunter_Vengeance(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS



    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)
    local souls = hud:AddAuraByPlayer(203981, false)

    local fracture = hud:AddCooldown(263642)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials
    hud:AddEssentialsCooldown(fracture, nil, nil, 0.4, 0.7, 0.4)

    -- defensive

    -- control

    -- powerboost

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddStacksPoints(souls, 0.2, 1.0, 0.2, 0.5, 0.0, 1.0, nil, function() return 0 end, function() return 6 end)
    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 1.0, 0.0, 1.0)


    --#endregion
    --------------------------------
end

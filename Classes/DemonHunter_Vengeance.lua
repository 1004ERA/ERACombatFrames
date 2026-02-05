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

    

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    -- defensive

    -- control

    -- powerboost

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 1.0, 0.0, 1.0)
    

    --#endregion
    --------------------------------
end

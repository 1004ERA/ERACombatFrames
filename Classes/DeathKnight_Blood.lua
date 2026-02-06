---@param cFrame ERACombatMainFrame
---@param talents DeathKnightTalents
function ERACombatFrames_DeathKnight_Blood(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS



    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.RunicPower)
    local runes = HUDRunesData:create(hud)

    local boil = hud:AddCooldown(50842)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsCooldown(boil, nil, nil, 1.0, 0.0, 0.0)

    -- defensive

    -- control


    -- powerboost

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddRunes(runes)

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.2, 0.7, 1.0)

    --#endregion
    --------------------------------
end

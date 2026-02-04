---@param cFrame ERACombatMainFrame
function ERACombatFrames_DemonHunter_Havoc(cFrame)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    local bladeDance = hud:AddCooldown(188499)
    -- TODO talent throw glaive 25
    local throwGlaive = hud:AddCooldown(204157) -- throw glaive 0
    local eyeBeam = hud:AddCooldown(198013)

    local reaverMark = hud:AddAuraByPlayer(442679, true) --442624
    local metaBuff = hud:AddAuraByPlayer(191427, false) --162264

    local _, bladeDancePlacement = hud:AddEssentialsCooldown(bladeDance, nil, nil, 1.0, 0.0, 0.0)
    local reverMarkIcon = hud:AddEssentialsAura(reaverMark)
    reverMarkIcon.showRedIfMissingInCombat = true
    hud:AddEssentialsCooldown(throwGlaive, nil, nil, 0.5, 0.7, 0.5)
    --glaiveIcon.watchAdditionalOverlay = 442294
    hud:AddEssentialsCooldown(eyeBeam, nil, nil, 0.1, 0.9, 0.2)

    bladeDancePlacement:AddTimerBar(0.75, metaBuff, nil, 0.9, 0.5, 1.0)

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)
    local powerBar = hud:AddPowerBarValueDisplay(power, 1.0, 0.0, 1.0)
    powerBar:AddTick(1305149, nil, function() return 35 end) -- blade dance
    powerBar:AddTick(1305152, nil, function() return 75 end) -- chaos strike + blade dance
    local eyeTick = powerBar:AddTick(1305156, nil, function() return 30 end)
    function eyeTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return eyeBeam.swipeDuration:EvaluateRemainingPercent(hud.curveAlphaSoon0)
    end
end

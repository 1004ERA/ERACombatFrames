---comment
---@param cFrame ERACombatMainFrame
function ERACombatFrames_DemonHunterSetup(cFrame)
    local havoc = HUDModule:Create(cFrame, 1.5, 1)
    havoc:AddEssentialsCooldown(havoc:AddCooldown(188499))
    local power = havoc:AddPowerLowIdle(Enum.PowerType.Fury)
    havoc:AddPowerBarValueDisplay(power, 1.0, 0.0, 1.0)
end

---@param cFrame ERACombatMainFrame
function ERACombatFrames_EvokerSetup(cFrame)
    ---@class EvokerTalents
    local talents = {

    }

    local hud = HUDModule:Create(cFrame, 1.5, 1)

    local surge = hud:AddCooldown(359073)
    hud:AddEssentialsCooldown(surge, nil, nil, 0.0, 0.5, 1.0)
end

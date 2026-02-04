---@param cFrame ERACombatMainFrame
function ERACombatFrames_Priest_Shadow(cFrame)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    hud:AddChannelInfo(15407, 6, 0.75)

    local mBlast = hud:AddCooldown(8092)
    hud:AddEssentialsCooldown(mBlast, nil, nil, 1.0, 0.0, 0.0)
end

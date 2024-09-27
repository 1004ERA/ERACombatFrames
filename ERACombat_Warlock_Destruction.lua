---@param cFrame ERACombatFrame
---@param talents WarlockCommonTalents
function ERACombatFrames_WarlockDestructionSetup(cFrame, talents)
    local talent_not_sacrifice = ERALIBTalent:CreateNotTalent(125618)
    local hud = ERACombatFrames_WarlockCommonSetup(cFrame, 3, talents, talent_not_sacrifice)
end

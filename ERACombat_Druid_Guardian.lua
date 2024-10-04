---@param cFrame ERACombatFrame
---@param talents DruidCommonTalents
function ERACombatFrames_DruidGuardianSetup(cFrame, talents)
    local hud = ERACombatFrames_Druid_CommonSetup(cFrame, 3, talents, ERALIBTalent:Create(103293))
end
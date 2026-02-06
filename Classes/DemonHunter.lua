---@param cFrame ERACombatMainFrame
function ERACombatFrames_DemonHunterSetup(cFrame)
    ---@class DemonHunterTalents
    local talents = {
        retreat = ERALIBTalent:Create(112853),
        imprison = ERALIBTalent:Create(112927),
        misery = ERALIBTalent:Create(112859),
        nova = ERALIBTalent:Create(112911),
        dispelloff = ERALIBTalent:Create(112926),
        darkness = ERALIBTalent:Create(112921),
    }

    ERACombatFrames_DemonHunter_Havoc(cFrame, talents)
    ERACombatFrames_DemonHunter_Vengeance(cFrame, talents)
    ERACombatFrames_DemonHunter_Devourer(cFrame, talents)
end

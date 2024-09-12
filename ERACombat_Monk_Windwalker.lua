---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, monkTalents)
    local talent_whirling = ERALIBTalent:Create(125011)
    local talent_not_whirling = ERALIBTalent:CreateNotTalent(125011)
    local talent_windlord = ERALIBTalent:Create(125022)
    local talent_fae_active = ERALIBTalent:Create(126026)
    local talent_fae_passive = ERALIBTalent:Create(124816)
    local talent_fae_any = ERALIBTalent:CreateOr(talent_fae_active, talent_fae_passive)
    local talent_chib = ERALIBTalent:Create(124952)
    local talent_sef = ERALIBTalent:Create(124826)
    local talent_inner_peace = ERALIBTalent:Create(125021)
    local talent_capacitor = ERALIBTalent:Create(124832)
    local talent_spinning_ignition = ERALIBTalent:Create(124822)
    local talent_combat_wisdom = ERALIBTalent:Create(125025)
    local htalent_conduit = ERALIBTalent:Create(125062)

    local hud = ERAHUD:Create(cFrame, 1.0, true, false, 3, 1.0, 1.0, 0.0, false, 3)
    ---@cast hud MonkHUD
    hud.power.hideFullOutOfCombat = true

    ERACombatFrames_MonkCommonSetup(hud, monkTalents)

    local chi = ERAHUDModulePointsUnitPower:Create(hud, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil)
    function chi:GetIdlePointsOverride()
        if talent_combat_wisdom:PlayerHasTalent() then
            return 2
        else
            return 0
        end
    end

    hud.power.bar:AddMarkingFrom0(55, talent_inner_peace)
    hud.power.bar:AddMarkingFrom0(60, ERALIBTalent:CreateNot(talent_inner_peace))
end

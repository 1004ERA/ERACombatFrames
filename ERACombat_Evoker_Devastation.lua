---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerDevastationSetup(cFrame, enemies, talents)
    local talent_big_empower = ERALIBTalent:Create(115586)
    local talent_surge = ERALIBTalent:Create(115581)
    local talent_firestorm = ERALIBTalent:Create(115585)
    local talent_instastorm = ERALIBTalent:Create(115584)
    local talent_shatter = ERALIBTalent:Create(115627)
    local talent_iridescence = ERALIBTalent:Create(115633)
    local talent_dragonrage = ERALIBTalent:Create(115643)
    local talent_massdisintegrate = ERALIBTalent:Create(117536)
    local talent_imminent_destruction = ERALIBTalent:Create(115638)

    local hud = ERAHUD:Create(cFrame, 1.5, false, false, 0, 0.0, 0.0, 1.0, false, 1)
    ---@cast hud ERAEvokerHUD
    hud.power.hideFullOutOfCombat = true
    hud.powerHeight = 10
    function hud:IsCombatPowerVisibleOverride(t)
        return self.power.currentPower / self.power.maxPower <= 0.75
    end

    ERAEvokerCommonSetup(hud, "TO_LEFT", talents, talent_big_empower, 1)
end

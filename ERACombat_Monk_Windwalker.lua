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
    local talent_freespinning = ERALIBTalent:Create(124834)
    local talent_xuen = ERALIBTalent:Create(125013)
    local htalent_conduit = ERALIBTalent:Create(125062)

    local hud = ERAHUD:Create(cFrame, 1.0, true, false, 3, 1.0, 1.0, 0.0, false, 3)
    ---@cast hud MonkHUD
    hud.power.hideFullOutOfCombat = true

    ERACombatFrames_MonkCommonSetup(hud, monkTalents, true, true)

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

    ----------------
    --- ROTATION ---
    ----------------

    local rsk = hud:AddTrackedCooldown(107428)
    hud:AddRotationCooldown(rsk)

    local fof = hud:AddTrackedCooldown(113656)
    hud:AddRotationCooldown(fof)

    local whirling = hud:AddTrackedCooldown(152175, talent_whirling)
    hud:AddRotationCooldown(whirling)

    local spinningStacks = hud:AddSpellStacks(101546)
    hud:AddRotationStacks(spinningStacks, 5, 606543)

    local windlord = hud:AddTrackedCooldown(392983, talent_windlord)
    hud:AddRotationCooldown(windlord)

    local faeCooldown = hud:AddTrackedCooldown(388193, talent_fae_active)
    hud:AddRotationCooldown(faeCooldown)

    local chib = hud:AddTrackedBuff(460490, talent_chib)
    local chibIcon = hud:AddRotationBuff(chib)
    chibIcon.icon:Highlight()
    function chibIcon:ShowWhenMissing(t, combat)
        return false
    end

    local spinningIgnition = hud:AddTrackedBuff(393057, talent_spinning_ignition)
    hud:AddRotationStacks(spinningIgnition, 30)

    ------------
    --- BARS ---
    ------------

    local freebok = hud:AddTrackedBuff(116768)
    hud:AddBarWithID(freebok, nil, 0.7, 0.0, 0.1)

    local karmaBuff = hud:AddTrackedBuff(125174)
    hud:AddBarWithID(karmaBuff, nil, 1.0, 1.0, 1.0)

    local sefBuff = hud:AddTrackedBuff(137639, talent_sef)
    hud:AddBarWithID(sefBuff, nil, 1.0, 0.0, 1.0)

    local freespinning = hud:AddTrackedBuff(325202)
    hud:AddBarWithID(freespinning, nil, 0.0, 0.8, 0.2)

    local ignitionBar = hud:AddBarWithID(spinningIgnition, 606543, 0.0, 0.8, 0.2)
    function ignitionBar:ComputeDurationOverride(t)
        if self.timer.remDuration < self.hud.timerDuration then
            return self.timer.remDuration
        else
            return 0
        end
    end

    ---------------
    --- UTILITY ---
    ---------------

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(101545), hud.movementGroup, nil, 2.5) -- fsk
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(137639, talent_sef, nil, -3), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(123904, talent_xuen, nil, -2), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(443028, htalent_conduit, nil, -1), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(122470), hud.defenseGroup, nil, 0) -- karma
end

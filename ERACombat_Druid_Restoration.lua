---@class ERACombatGrid_DruidRestoration : ERACombatGrid

---@param cFrame ERACombatFrame
---@param talents DruidCommonTalents
function ERACombatFrames_DruidRestorationSetup(cFrame, talents)
    local talent_swiftness = ERALIBTalent:Create(103101)
    local talent_ward = ERALIBTalent:Create(103104)
    local talent_treants = ERALIBTalent:Create(117104)
    local talent_overgrowth = ERALIBTalent:Create(103115)
    local talent_efflo = ERALIBTalent:Create(103111)
    local talent_tranqui = ERALIBTalent:Create(103108)
    local talent_ironbark = ERALIBTalent:Create(103141)
    --local talent_nourish = ERALIBTalent:Create(103094)
    local talent_nourish_synthesis = ERALIBTalent:Create(117105)
    local talent_incarnation = ERALIBTalent:Create(103120)
    local talent_convoke = ERALIBTalent:Create(103119)
    local talent_bonus_wild = ERALIBTalent:Create(103123)
    local talent_flourish = ERALIBTalent:Create(123776)
    local talent_reforestation = ERALIBTalent:Create(103125)
    local talent_incarnation_or_reforestation = ERALIBTalent:CreateOr(talent_incarnation, talent_reforestation)
    local talent_germination = ERALIBTalent:Create(103127)

    local hud = ERACombatFrames_Druid_CommonSetup(cFrame, 4, talents, nil, talent_bonus_wild)

    ERACombatFrames_Druid_NonBalance(hud, talents, ERALIBTalentTrue)
    ERACombatFrames_Druid_NonFeral(hud, talents)
    ERACombatFrames_Druid_NonGuardian(hud, talents)

    local bloomR = 0.0
    local bloomG = 0.9
    local bloomB = 0.5

    ------------------
    --#region GRID ---

    ---@type ERACombatGrid|nil
    local grid
    if ERACombatOptions_IsSpecModuleActive(4, ERACombatOptions_Grid) then
        grid = ERACombatGrid:Create(cFrame, "BOTTOMRIGHT", 4, 88423, "Magic", "Poison", "Curse")
        ---@cast grid ERACombatGrid_DruidRestoration

        -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
        local ironbDef = grid:AddTrackedBuff(102342, 0, 1, 0.6, 0.4, 0.4, 0.6, 0.4, 0.4, talent_ironbark)
        local bloomDef = grid:AddTrackedBuff(33763, 0, 2, bloomR, bloomG, bloomB, bloomR, bloomG, bloomB)
        local regroDef = grid:AddTrackedBuff(8936, 1, 2, 0.0, 0.8, 0.0, 0.0, 0.8, 0.0)
        local rejuvDef = grid:AddTrackedBuff(774, 2, 1, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B)
        local wildgDef = grid:AddTrackedBuff(48438, 3, 1, 0.7, 1.0, 0.3, 0.7, 1.0, 0.3)
        local rejuv2Def = grid:AddTrackedBuff(155777, 3, 2, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B, talent_germination)

        function grid:UpdatedInCombatOverride(t)

        end
    else
        grid = nil
    end

    --#endregion
    ------------------

    local elderDruidCooldown = hud:AddTrackedDebuffOnSelf(426790, talent_bonus_wild)

    --- SAO ---

    local clearcast = hud:AddTrackedBuff(16870)
    hud:AddAuraOverlay(clearcast, 1, 450929, false, "TOP", false, false, false, true)
    hud:AddAuraOverlay(clearcast, 2, 450929, false, "RIGHT", true, false, false, false)

    local effloDuration = hud:AddTrackedBuff(145205, talent_efflo)
    local missingEfflo = hud:AddMissingTimerOverlay(effloDuration, false, "perks-tick-glow", true, "MIDDLE", false, false, false, false)
    function missingEfflo:ConfirmIsActiveOverride(t, combat)
        return combat and self.hud.isInGroup and self.hud.groupMembersExcludingSelf > 4
    end

    --- bars ---

    local incarnationDuration = hud:AddTrackedBuff(33891, talent_incarnation_or_reforestation)
    hud:AddAuraBar(incarnationDuration, nil, 1.0, 0.0, 1.0)

    local effloBar = hud:AddAuraBar(effloDuration, nil, 1.0, 0.3, 0.5)
    function effloBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration - 1 then
            return self.aura.remDuration
        else
            return 0
        end
    end


    hud:AddAuraBar(hud:AddTrackedBuff(33763), nil, bloomR, bloomG, bloomB)

    hud:AddAuraBar(hud:AddTrackedBuff(155777, talent_germination), nil, ERA_Druid_Rejuv_R, ERA_Druid_Rejuv_G, ERA_Druid_Rejuv_B)

    --- rotation ---

    local wgrowth = hud:AddRotationCooldown(hud:AddTrackedCooldown(48438))

    local swiftmend = hud:AddRotationCooldown(hud:AddTrackedCooldown(18562))

    local ward = hud:AddRotationCooldown(hud:AddTrackedCooldown(102351, talent_ward))

    local treants = hud:AddRotationCooldown(hud:AddTrackedCooldown(102693, talent_treants))

    local swiftness = hud:AddRotationCooldown(hud:AddTrackedCooldown(132158, talent_swiftness))

    local overgrowth = hud:AddRotationCooldown(hud:AddTrackedCooldown(203651, talent_overgrowth))

    local ironbark = hud:AddRotationCooldown(hud:AddTrackedCooldown(102342, talent_ironbark))

    hud:AddRotationStacks(hud:AddTrackedBuff(400534, talent_nourish_synthesis), 3, 3)

    --[[

    prio

    1 - wgrowth
    2 - swiftmend
    3 - ward
    4 - treants
    5 - swiftness
    6 - wild

    ]]

    function wgrowth.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    function swiftmend.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function ward.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function treants.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function swiftness.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    local wildPrio = hud:AddPriority(135879, talent_bonus_wild)
    function wildPrio:ComputeDurationOverride(t)
        return elderDruidCooldown.remDuration
    end
    function wildPrio:ComputeAvailablePriorityOverride(t)
        return 6
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(740, talent_tranqui), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(197721, talent_flourish), hud.healGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(391528, talent_convoke), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(33891, talent_incarnation), hud.powerUpGroup)
end

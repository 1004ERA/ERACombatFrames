---@param cFrame ERACombatFrame
---@param talents DruidCommonTalents
function ERACombatFrames_DruidFeralSetup(cFrame, talents)
    local talent_long_dots = ERALIBTalent:Create(103154)
    local talent_short_dots = ERALIBTalent:Create(103156)
    local talent_thrash = ERALIBTalent:CreateAnd(talents.thrash, ERALIBTalent:CreateNotTalent(114823))
    local talent_instincts = ERALIBTalent:Create(103180)
    local talent_incarnation = ERALIBTalent:Create(103178)
    local talent_berserk = ERALIBTalent:CreateAnd(ERALIBTalent:Create(103162), ERALIBTalent:CreateNot(talent_incarnation))
    local talent_convoke = ERALIBTalent:Create(103177)
    local talent_slash = ERALIBTalent:Create(103151)
    local talent_swarm = ERALIBTalent:Create(103175)
    local talent_frenzy = ERALIBTalent:Create(103170)
    local talent_predator = ERALIBTalent:Create(103152)

    local hud = ERACombatFrames_Druid_CommonSetup(cFrame, 2, talents, ERALIBTalent:Create(103282), nil)

    ERACombatFrames_Druid_NonBalance(hud, talents, ERALIBTalentTrue)
    ERACombatFrames_Druid_NonGuardian(hud, talents)
    ERACombatFrames_Druid_NonRestoration(hud, talents)

    local dots = ERAHUDDOT:Create(hud)

    local rake = dots:AddDOT(155722, nil, ERA_Druid_Rake_R, ERA_Druid_Rake_G, ERA_Druid_Rake_B, nil, 0, 12)
    local thrash = dots:AddDOT(405233, nil, ERA_Druid_Thras_R, ERA_Druid_Thras_G, ERA_Druid_Thras_B, talent_thrash, 0, 15)
    local rip = dots:AddDOT(1079, nil, ERA_Druid_Rip_R, ERA_Druid_Rip_G, ERA_Druid_Rip_B, nil, 0, 24)
    rip.writeTimeToRefresh = true
    ---@type ERAHUDDOTDefinition[]
    local dotsArray = {}
    table.insert(dotsArray, rake)
    table.insert(dotsArray, thrash)
    table.insert(dotsArray, rip)
    for _, dot in ipairs(dotsArray) do
        function dot:ComputeRefreshDurationOverride(t)
            local mult = 1
            if talent_long_dots:PlayerHasTalent() then
                mult = mult * 1.25
            end
            if talent_short_dots:PlayerHasTalent() then
                mult = mult * 0.8
            end
            return mult * self.baseTotDuration * 0.3
        end
    end

    local slashCooldown = hud:AddTrackedCooldown(202028, talent_slash)
    local slashMarker = hud.nrg.bar:AddMarkingFrom0(25, talent_slash)
    function slashMarker:ComputeValueOverride(t)
        if slashCooldown.currentCharges > 0 then
            return 25
        else
            return -1
        end
    end

    --- SAO ---

    local clarity = hud:AddTrackedBuff(135700)
    hud:AddAuraOverlay(clarity, 1, 510823, false, "LEFT", false, false, false, false)

    local swiftness = hud:AddTrackedBuff(69369)
    hud:AddAuraOverlay(swiftness, 1, 450929, false, "RIGHT", true, false, false, false)

    local biteProc = hud:AddTrackedBuff(1, talent_predator)
    hud:AddAuraOverlay(biteProc, 1, 510822, false, "TOP", false, false, false, false)

    --- bars ---

    hud:AddAuraBar(hud:AddTrackedBuff(5217), nil, 1.0, 1.0, 0.0) -- fury
    hud:AddAuraBar(hud:AddTrackedBuff(106951, talent_berserk), nil, 1.0, 0.0, 1.0)
    hud:AddAuraBar(hud:AddTrackedBuff(102543, talent_incarnation), nil, 1.0, 0.0, 1.0)
    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(391888, talent_swarm), nil, 0.0, 0.8, 0.4)

    --- rotation ---

    local slash = hud:AddRotationCooldown(slashCooldown)

    local fury = hud:AddRotationCooldown(hud:AddTrackedCooldown(5217))

    local swarm = hud:AddRotationCooldown(hud:AddTrackedCooldown(391888, talent_swarm))

    local frenzy = hud:AddRotationCooldown(hud:AddTrackedCooldown(274837, talent_frenzy))

    --[[

    prio

    1 - bite proc
    2 - slash
    3 - fury
    4 - swarm
    5 - frenzy

    ]]

    local biteProcPrio = hud:AddPriority(132127, talent_predator)
    function biteProcPrio:ComputeAvailablePriorityOverride(t)
        if biteProc.remDuration > 0 then
            return 1
        else
            return 0
        end
    end

    function slash.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function fury.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function swarm.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function frenzy.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(106951, talent_berserk), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102543, talent_incarnation), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(391528, talent_convoke), hud.powerUpGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(61336, talent_instincts), hud.defenseGroup)
end

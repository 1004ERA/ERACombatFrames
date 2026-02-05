---@param cFrame ERACombatMainFrame
---@param talents DemonHunterTalents
function ERACombatFrames_DemonHunter_Havoc(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_initiative = ERALIBTalent:Create(1129450)
    local talent_exergy = ERALIBTalent:Create(112943)
    local talent_inertia = ERALIBTalent:Create(117744)
    local talent_glaivecost = ERALIBTalent:Create(115244)
    local talent_hunt = ERALIBTalent:Create(112830)
    local talent_tempest = ERALIBTalent:Create(134203)
    local talent_ebreak = ERALIBTalent:Create(112956)
    local talent_aldrachi = ERALIBTalent:Create(117512)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)

    -- cooldown
    local rush = hud:AddCooldown(195072)
    local bladeDance = hud:AddCooldown(188499)
    -- TODO talent throw glaive 25
    local throwGlaive = hud:AddCooldown(204157) -- throw glaive 0
    local eyeBeam = hud:AddCooldown(198013)
    local immo = hud:AddCooldown(258920)
    local hunt = hud:AddCooldown(370965, talent_hunt)
    local ebreak = hud:AddCooldown(258860, talent_ebreak)
    local retreat = hud:AddCooldown(198793)
    local felblade = hud:AddCooldown(232893, talents.felblade)
    local misery = hud:AddCooldown(207684, talents.misery)
    local imprison = hud:AddCooldown(217832, talents.imprison)
    local nova = hud:AddCooldown(179057, talents.nova)
    local dispelloff = hud:AddCooldown(278326, talents.dispelloff)
    local darnkess = hud:AddCooldown(196718, talents.darkness)
    local kick = hud:AddCooldown(183752)
    local meta = hud:AddCooldown(191427)
    local blur = hud:AddCooldown(198589)

    -- auras
    local reaverMark = hud:AddAuraByPlayer(442679, true, talent_aldrachi) --442624
    local reaverGlaive = hud:AddAuraByPlayer(442290, false, talent_aldrachi)
    local metaBuff = hud:AddAuraByPlayer(191427, false)                   --162264
    local initiative = hud:AddAuraByPlayer(388108, false)
    --local inertia = hud:AddAuraByPlayer(427640, false)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftCooldown(retreat)
    hud:AddEssentialsLeftCooldown(rush)

    hud:AddEssentialsCooldown(felblade, nil, nil, 0.8, 1.0, 0.5)

    local _, bladeDancePlacement = hud:AddEssentialsCooldown(bladeDance, nil, nil, 1.0, 0.0, 0.0)

    local reverMarkIcon, reaverMarkPlacement = hud:AddEssentialsAura(reaverMark)
    reverMarkIcon.showRedIfMissingInCombat = true
    reverMarkIcon:HideCountdown()
    function reverMarkIcon:GetMainText()
        return reaverGlaive.stacksDisplay
    end
    reaverMarkPlacement:AddTimerBar(0.25, reaverGlaive, nil, 0.6, 0.3, 0.7)

    local glaiveIcon, glaivePlacement = hud:AddEssentialsCooldown(throwGlaive, nil, nil, 0.5, 0.7, 0.5)
    glaiveIcon.watchAdditionalOverlay = 442294

    hud:AddEssentialsCooldown(eyeBeam, nil, nil, 0.1, 0.9, 0.2)

    hud:AddEssentialsCooldown(immo, nil, nil, 0.8, 1.0, 0.0)

    hud:AddEssentialsRightCooldown(ebreak)
    hud:AddEssentialsRightCooldown(hunt)

    local metaBar = bladeDancePlacement:AddTimerBar(0.75, metaBuff, nil, 0.9, 0.5, 1.0)
    metaBar.doNotCutLongDuration = true
    local initiativeBar = glaivePlacement:AddTimerBar(0.25, initiative, nil, 0.7, 0.8, 0.0)
    initiativeBar.doNotCutLongDuration = true

    -- defensive
    hud:AddDefensiveCooldown(blur)
    hud:AddDefensiveCooldown(darnkess)

    -- control
    hud:AddControlCooldown(kick)
    hud:AddKickInfo(kick)
    hud:AddControlCooldown(nova)
    hud:AddControlCooldown(dispelloff)
    hud:AddControlCooldown(misery)
    hud:AddControlCooldown(imprison)

    -- powerboost
    hud:AddPowerboostCooldown(meta)

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 1.0, 0.0, 1.0)
    powerBar:AddTick(1305149, nil, function() return 35 end) -- blade dance
    powerBar:AddTick(1305152, nil, function() return 75 end) -- chaos strike + blade dance
    local eyeTick = powerBar:AddTick(1305156, nil, function() return 30 end)
    function eyeTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return eyeBeam.cooldownDuration:EvaluateRemainingPercent(hud.curveAlphaSoon0)
    end
    local tempestTick = powerBar:AddTick(1455916, talent_tempest, function() return 60 end)
    function tempestTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return bladeDance.cooldownDuration:EvaluateRemainingPercent(hud.curveAlphaSoon0)
    end

    --#endregion
    --------------------------------
end

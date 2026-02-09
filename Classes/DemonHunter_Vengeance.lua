---@param cFrame ERACombatMainFrame
---@param talents DemonHunterTalents
function ERACombatFrames_DemonHunter_Vengeance(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS

    local talent_felblade = ERALIBTalent:Create(134271)
    local talent_bomb = ERALIBTalent:Create(112907)
    local talent_brand = ERALIBTalent:Create(112864)
    local talent_silence = ERALIBTalent:Create(112904)
    local talent_felfire = ERALIBTalent:Create(112866)
    local talent_spite = ERALIBTalent:Create(112894)
    local talent_chains = ERALIBTalent:Create(112867)
    local talent_misery = ERALIBTalent:CreateAnd(talents.misery, ERALIBTalent:CreateNot(talent_chains))
    local talent_carver = ERALIBTalent:Create(112898)
    local talent_voidfall = ERALIBTalent:Create(135667)
    local talent_aldrachi = ERALIBTalent:Create(117512)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)

    local souls = hud:AddAuraByPlayer(203981, false)
    local felfire = hud:AddAuraByPlayer(389724, false, talent_felfire)
    local reaverGlaive = hud:AddAuraByPlayer(442290, false, talent_aldrachi)
    local metaBuff = hud:AddAuraByPlayer(187827, false)
    local frailty = hud:AddAuraByPlayer(389958, true)
    local reaverMark = hud:AddAuraByPlayer(442679, true, talent_aldrachi)
    local spikes = hud:AddAuraByPlayer(203720, false)
    local voidfall = hud:AddAuraByPlayer(1253304, false) --, talent_voidfall)

    local fracture = hud:AddCooldown(263642)
    local devastation = hud:AddCooldown(212084)
    local bomb = hud:AddCooldown(247454, talent_bomb)
    local immo = hud:AddCooldown(258920)
    local felblade = hud:AddCooldown(232893, talent_felblade)
    local glaive = hud:AddCooldown(204157)
    local spikesCooldown = hud:AddCooldown(203720)
    local nova = hud:AddCooldown(179057, talents.nova)
    local iStrike = hud:AddCooldown(189110)
    local kick = hud:AddCooldown(183752)
    local dispelloff = hud:AddCooldown(278326, talents.dispelloff)
    local retreat = hud:AddCooldown(198793, talents.retreat)
    local sigSpite = hud:AddCooldown(390163, talent_spite)
    local sigFlame = hud:AddCooldown(204596)
    local sigMisery = hud:AddCooldown(207684, talent_misery)
    local sigSilence = hud:AddCooldown(202137, talent_silence)
    local sigChains = hud:AddCooldown(202138, talent_chains)
    local darkness = hud:AddCooldown(196718, talents.darkness)
    local carver = hud:AddCooldown(207407, talent_carver)
    local brand = hud:AddCooldown(204021, talent_brand)
    local meta = hud:AddCooldown(187827)
    local imprison = hud:AddCooldown(217832, talents.imprison)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftCooldown(retreat)
    hud:AddEssentialsLeftCooldown(sigFlame)
    hud:AddEssentialsLeftCooldown(iStrike)
    local glaiveIcon = hud:AddEssentialsLeftCooldown(glaive, nil, nil)
    glaiveIcon.watchAdditionalOverlay = 442294

    hud:AddEssentialsCooldown(felblade, nil, nil, 0.8, 1.0, 0.5)

    local _, fractureSlot = hud:AddEssentialsCooldown(fracture, nil, nil, 0.6, 0.7, 0.6)
    local metaBar = fractureSlot:AddTimerBar(0.75, metaBuff, nil, 1.0, 0.0, 1.0)
    metaBar.doNotCutLongDuration = true

    local reverMarkIcon, reaverMarkPlacement = hud:AddEssentialsAura(reaverMark)
    reverMarkIcon.showRedIfMissingInCombat = true
    reverMarkIcon:HideCountdown()
    function reverMarkIcon:GetMainText()
        return reaverGlaive.stacksDisplay
    end
    reaverMarkPlacement:AddTimerBar(0.25, reaverGlaive, nil, 0.6, 0.3, 0.7)

    hud:AddEssentialsCooldown(devastation, nil, nil, 0.2, 0.7, 0.0)

    local _, bombSlot = hud:AddEssentialsCooldown(bomb, nil, nil, 0.7, 0.0, 0.7)

    hud:AddEssentialsCooldown(immo, nil, nil, 0.8, 0.6, 0.0)

    local _, spikesSlot = hud:AddEssentialsCooldown(spikesCooldown, nil, nil, 1.0, 1.0, 0.0)
    local spikesBar = spikesSlot:AddTimerBar(0.25, spikes, nil, 1.0, 0.0, 0.0)
    spikesBar.doNotCutLongDuration = true

    hud:AddEssentialsRightCooldown(carver)
    hud:AddEssentialsRightCooldown(sigSpite)
    local voidfallIcon = hud:AddEssentialsRightAura(voidfall)
    voidfallIcon:ShowStacksRatherThanDuration()
    voidfallIcon.alwaysHideOutOfCombat = true

    -- defensive
    hud.defensiveGroup:AddCooldown(darkness)

    -- control
    hud.controlGroup:AddCooldown(kick)
    hud:AddKickInfo(kick)
    hud.controlGroup:AddCooldown(nova)
    hud.controlGroup:AddCooldown(sigSilence)
    hud.controlGroup:AddCooldown(sigMisery)
    hud.controlGroup:AddCooldown(sigChains)
    hud.controlGroup:AddCooldown(dispelloff)
    hud.controlGroup:AddCooldown(imprison)

    -- powerboost
    hud.powerboostGroup:AddCooldown(brand)
    hud.powerboostGroup:AddCooldown(meta)

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddStacksPoints(souls, 0.2, 1.0, 0.2, 0.5, 0.0, 1.0, nil, function() return 0 end, function() return 6 end)
    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 1.0, 0.0, 1.0)
    local cleaveTick = powerBar:AddTick(1344653, nil, function() return 35 end)
    function cleaveTick:OverrideAlpha()
        if (talent_bomb:PlayerHasTalent()) then
            ---@diagnostic disable-next-line: return-type-mismatch
            return bomb.cooldownDuration:EvaluateRemainingDuration(hud.curveHideLessThanTwo)
        else
            return 1.0
        end
    end
    local cleaveAndBombTick = powerBar:AddTick(1344653, talent_bomb, function() return 75 end)
    function cleaveAndBombTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return bomb.cooldownDuration:EvaluateRemainingPercent(hud.curveShowSoonAvailable)
    end
    local bombTick = powerBar:AddTick(1097742, talent_bomb, function() return 40 end)
    function bombTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return bomb.cooldownDuration:EvaluateRemainingPercent(hud.curveShowSoonAvailable)
    end
    local devaTick = powerBar:AddTick(1450143, nil, function() return 50 end)
    function devaTick:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return devastation.cooldownDuration:EvaluateRemainingPercent(hud.curveShowSoonAvailable)
    end

    --#endregion
    --------------------------------
end

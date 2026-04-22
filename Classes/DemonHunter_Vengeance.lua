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
    local talent_nova = ERALIBTalent:Create(134282)
    local talent_felfire = ERALIBTalent:Create(112866)
    local talent_spite = ERALIBTalent:Create(112894)
    local talent_chains = ERALIBTalent:Create(112867)
    local talent_misery = ERALIBTalent:CreateAnd(talents.misery, ERALIBTalent:CreateNot(talent_chains))
    local talent_carver = ERALIBTalent:Create(112898)
    local talent_voidfall = ERALIBTalent:Create(135667)
    local talent_aldrachi = ERALIBTalent:Create(117512)
    local talent_not_aldrachi = ERALIBTalent:CreateNot(talent_aldrachi)
    local talent_fblade_def = ERALIBTalent:Create(117493)
    local talent_retreat_reset_fblade = ERALIBTalent:Create(123047)
    local talent_apex = ERALIBTalent:CreateOr(ERALIBTalent:Create(137041), ERALIBTalent:Create(137042), ERALIBTalent:Create(137043))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)

    local souls = hud:AddAuraByPlayer(203981, false)
    local brandBuff = hud:AddAuraByPlayer(204021, false)
    local felfire = hud:AddAuraByPlayer(389724, false, talent_felfire)
    local fbladeDef = hud:AddAuraByPlayer(442714, false, talent_fblade_def)
    local reaverGlaive = hud:AddAuraByPlayer(442290, false, talent_aldrachi)
    local metaBuff = hud:AddAuraByPlayer(187827, false)
    local frailty = hud:AddAuraByPlayer(389958, true)
    local reaverMark = hud:AddAuraByPlayer(442679, true, talent_aldrachi)
    local spikes = hud:AddAuraByPlayer(203720, false)
    local voidfall = hud:AddAuraByPlayer(1253304, false, talent_voidfall)
    local apex = hud:AddAuraByPlayer(1270444, false, talent_apex)

    local fracture = hud:AddCooldown(263642)
    local devastation = hud:AddCooldown(212084)
    local bomb = hud:AddCooldown(247454, talent_bomb)
    local immo = hud:AddCooldown(258920)
    local felblade = hud:AddCooldown(232893, talent_felblade)
    local glaive = hud:AddCooldown(204157)
    local spikesCooldown = hud:AddCooldown(203720)
    local nova = hud:AddCooldown(179057, talent_nova)
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

    local reaverGlaiveUsable = hud:AddIconBoolean(204157, 5927616, talent_aldrachi)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftCooldown(glaive, nil, talent_not_aldrachi)
    hud:AddEssentialsLeftCooldown(retreat)
    hud:AddEssentialsLeftCooldown(iStrike)

    local glaiveIcon = hud:AddEssentialsLeftCooldown(glaive, nil, talent_aldrachi)
    glaiveIcon.watchIconChange = true
    glaiveIcon.watchAdditionalOverlay = 442294
    local reverMarkIcon, reaverMarkPlacement = hud:AddEssentialsAura(reaverMark)
    reverMarkIcon.showRedIfMissingInCombat = true
    reverMarkIcon:HideCountdown()
    function reverMarkIcon:GetMainText()
        return reaverGlaive.stacksDisplay
    end
    reaverMarkPlacement:AddTimerBar(0.25, reaverGlaive, nil, 0.6, 0.3, 0.7)

    local _, fbladeSlot = hud:AddEssentialsCooldown(felblade, nil, nil, 0.8, 1.0, 0.5)
    fbladeSlot:AddTimerBar(0.25, fbladeDef, talent_retreat_reset_fblade, 0.5, 0.5, 0.5).doNotCutLongDuration = true

    local _, fractureSlot = hud:AddEssentialsCooldown(fracture, nil, nil, 0.6, 0.7, 0.6)
    local metaBar = fractureSlot:AddTimerBar(0.75, metaBuff, nil, 1.0, 0.0, 1.0)
    metaBar.doNotCutLongDuration = true
    fractureSlot:AddTimerBar(0.25, apex, nil, 0.0, 1.0, 1.0)

    local _, bombSlot = hud:AddEssentialsCooldown(bomb, nil, nil, 0.7, 0.0, 0.7)

    hud:AddEssentialsCooldown(immo, nil, nil, 0.8, 0.6, 0.0)

    local _, brandSlot = hud:AddEssentialsCooldown(brand, nil, nil, 0.2, 0.7, 0.0)
    brandSlot:AddTimerBar(0.75, brandBuff, nil, 0.7, 1.0, 0.6).doNotCutLongDuration = true

    local _, spikesSlot = hud:AddEssentialsCooldown(spikesCooldown, nil, nil, 1.0, 1.0, 0.0)
    local spikesBar = spikesSlot:AddTimerBar(0.25, spikes, nil, 1.0, 0.0, 0.0)
    spikesBar.doNotCutLongDuration = true

    hud:AddEssentialsRightCooldown(carver)
    hud:AddEssentialsRightCooldown(sigFlame)
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
    hud.powerboostGroup:AddCooldown(devastation)
    hud.powerboostGroup:AddCooldown(meta)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    --hud:AddPublicBooleanOverlayAlert(nil, "talents-heroclass-demonhunter-aldrachireaver", true, reaverGlaiveUsable, "NONE", "CENTER")
    hud:AddPublicBooleanOverlayAlert(nil, "talents-animations-class-demonhunter", true, reaverGlaiveUsable, "NONE", "CENTER")

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

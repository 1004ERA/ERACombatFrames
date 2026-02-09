---@param cFrame ERACombatMainFrame
---@param talents DemonHunterTalents
function ERACombatFrames_DemonHunter_Devourer(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    --------------------------------
    --#region TALENTS

    local talent_nova = ERALIBTalent:Create(132289)
    local talent_voidfall = ERALIBTalent:Create(135667)
    local talent_immo_not_spontaneous = ERALIBTalent:CreateAnd(ERALIBTalent:Create(132286), ERALIBTalent:CreateNotTalent(135730))
    local talent_meta = ERALIBTalent:Create(132282)
    local talent_collapstar = ERALIBTalent:Create(132281)
    local talent_idle_shards = ERALIBTalent:Create(133511)
    local talent_slash = ERALIBTalent:Create(133531)
    local talent_rolling = ERALIBTalent:Create(136693)
    local talent_hunt = ERALIBTalent:Create(135736)
    local talent_glutton = ERALIBTalent:Create(134331)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.Fury)

    local souls = hud:AddAuraByPlayer(1227619, false)
    local collapstar = hud:AddAuraByPlayer(1227702, false)
    local metastacks = hud:AddAuraByPlayer(1225789, false)
    local voidfall = hud:AddAuraByPlayer(1253304, false, talent_voidfall)
    local rolling = hud:AddAuraByPlayer(1244237, false, talent_rolling)
    local immoBuff = hud:AddAuraByPlayer(1241937, false)

    local reap = hud:AddCooldown(1226019)
    local immo = hud:AddCooldown(1241937, talent_immo_not_spontaneous)
    local blade = hud:AddCooldown(1245412)
    local glaive = hud:AddCooldown(185123)
    local blur = hud:AddCooldown(198589)
    local darkness = hud:AddCooldown(196718, talents.darkness)
    local hunt = hud:AddCooldown(1246167, talent_hunt)
    local nova = hud:AddCooldown(1234195, talent_nova)
    local shift = hud:AddCooldown(1234796)
    local retreat = hud:AddCooldown(198793)
    local kick = hud:AddCooldown(183752)
    local dispelloff = hud:AddCooldown(278326)
    local misery = hud:AddCooldown(207684)
    local imprison = hud:AddCooldown(217832)
    local beam = hud:AddCooldown(473728)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftCooldown(shift)
    hud:AddEssentialsLeftCooldown(retreat)

    local bladeIcon = hud:AddEssentialsCooldown(blade, nil, nil, 0.0, 1.0, 0.5)
    bladeIcon.watchAdditionalOverlay = 1239123

    local reapIcon = hud:AddEssentialsCooldown(reap, nil, nil, 0.7, 0.4, 1.0)
    reapIcon:HideCountdown()
    reapIcon:SetMainTextColor(1.0, 0.5, 0.0)
    function reapIcon:GetMainText()
        return souls.stacksDisplay
    end

    local beamIcon = hud:AddEssentialsCooldown(beam, nil, nil, 1.0, 0.0, 0.0)
    function beamIcon:OverrideCombatVisibilityAlpha()
        if (C_Spell.IsSpellUsable(beam.spellID)) then
            return 1.0
        else
            return 0.0
        end
    end

    local _, immoSlot = hud:AddEssentialsCooldown(immo, nil, nil, 0.8, 0.6, 0.0)
    local immoBar = immoSlot:AddTimerBar(0.25, immoBuff, nil, 1.0, 1.0, 1.0)
    immoBar.doNotCutLongDuration = true

    hud:AddEssentialsRightCooldown(hunt)
    hud:AddEssentialsRightCooldown(glaive)
    local voidfallIcon = hud:AddEssentialsRightAura(voidfall)
    voidfallIcon:ShowStacksRatherThanDuration()
    voidfallIcon.alwaysHideOutOfCombat = true

    -- defensive
    hud.defensiveGroup:AddCooldown(blur)
    hud.defensiveGroup:AddCooldown(darkness)

    -- control
    hud.controlGroup:AddCooldown(kick)
    hud:AddKickInfo(kick)
    hud.controlGroup:AddCooldown(nova)
    hud.controlGroup:AddCooldown(dispelloff)
    hud.controlGroup:AddCooldown(misery)
    hud.controlGroup:AddCooldown(imprison)

    -- powerboost

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local soulsSlot = hud:AddResourceSlot(false)

    local metaBuildBar = soulsSlot:AddStacksBar(metastacks, 0.0, 0.0, 1.0, nil, function() return talent_glutton:PlayerHasTalent() and 35 or 50 end, function() return 0 end)
    function metaBuildBar:OverrideVisibilityAlpha(aura, t, combat)
        if (collapstar.auraIsPresent) then
            return 0.0
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            if (combat or issecretvalue(aura.stacks)) then
                return 1.0
            else
                if ((aura.stacks == 25 and talent_idle_shards:PlayerHasTalent()) or (aura.stacks == 0 and not talent_idle_shards:PlayerHasTalent())) then
                    return 0.0
                else
                    return 1.0
                end
            end
        end
    end
    function metaBuildBar:AdditionalUpdate(t, combat, bar, current)
        if (C_SpellActivationOverlay.IsSpellOverlayed(1217605)) then
            bar:SetBarColor(1.0, 1.0, 0.0, false)
        else
            bar:SetBarColor(0.0, 0.0, 1.0, false)
        end
    end

    local collapstarBuildBar = soulsSlot:AddStacksBar(collapstar, 0.8, 0.7, 1.0, nil, function() return 40 end, function() return 0 end)
    collapstarBuildBar:AddTick(7554199, nil, function() return 30 end)
    collapstarBuildBar.constantTickColor = CreateColor(0.0, 0.0, 1.0, 1.0)
    function collapstarBuildBar:AdditionalUpdate(t, combat, bar, current)
        if (C_SpellActivationOverlay.IsSpellOverlayed(1221150)) then
            bar:SetBarColor(0.0, 1.0, 0.0, false)
        else
            bar:SetBarColor(0.8, 0.7, 1.0, false)
        end
    end

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 1.0, 0.0, 1.0)
    function powerBar:AdditionalUpdate(t, combat, bar, current)
        if (collapstar.auraIsPresent) then
            bar:SetBarColor(1.0, 0.0, 0.0, false)
        else
            bar:SetBarColor(1.0, 0.0, 1.0, false)
        end
    end
    local rayTick = powerBar:AddTick(7554220, nil, function() return 100 end)
    function rayTick:OverrideAlpha()
        if (collapstar.auraIsPresent) then
            return 0.0
        else
            return 1.0
        end
    end

    --#endregion
    --------------------------------
end

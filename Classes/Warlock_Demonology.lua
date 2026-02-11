---@param cFrame ERACombatMainFrame
---@param talents WarlockTalents
function ERACombatFrames_Warlock_Demonology(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS

    local talent_harvester = ERALIBTalent:Create(117448)
    local talent_diabolist = ERALIBTalent:Create(117452)
    local talent_stalkers = ERALIBTalent:Create(125837)
    local talent_implosion = ERALIBTalent:Create(125836)
    local talent_siphon = ERALIBTalent:Create(136731)
    local talent_doomguard = ERALIBTalent:Create(125863)
    local talent_tyrant = ERALIBTalent:Create(125850)
    local talent_big_hunter = ERALIBTalent:Create(136725)
    local talent_big_imp = ERALIBTalent:Create(136726)
    local talent_doom = ERALIBTalent:Create(136729)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local shards = hud:AddPowerTargetIdle(Enum.PowerType.SoulShards, nil, function() return 3 end)

    local commonSpells = ERACombatFrames_WarlockCommonSpells(hud, talents)

    local stalkers = hud:AddCooldown(104316, talent_stalkers)
    local implosion = hud:AddCooldown(196277, talent_implosion)
    local siphon = hud:AddCooldown(264130, talent_siphon)
    local doomguard = hud:AddCooldown(1276672, talent_doomguard)
    local tyrant = hud:AddCooldown(265187, talent_tyrant)
    local bigHunter = hud:AddCooldown(1276467, talent_big_hunter)
    local bigImp = hud:AddCooldown(1276452, talent_big_imp)

    local boltOverlay = hud:AddSpellOverlayBoolean(264178)

    local boltInstant = hud:AddAuraByPlayer(264173, false)
    local doom = hud:AddAuraByPlayer(460553, true, talent_doom)
    local succulent = hud:AddAuraByPlayer(449793, false, talent_harvester)
    local stalkersDuration = hud:AddAuraByPlayer(104316, false, talent_stalkers)
    local imps = hud:AddAuraByPlayer(296553, false)
    --local motherBolt = hud:AddIconBoolean(686, 841220, talent_diabolist)
    --local pitHand = hud:AddIconBoolean(105174, 135800, talent_diabolist)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    local diabolist = ERACombatFrames_WarlockDiabolist(hud, talent_diabolist)

    hud:AddEssentialsAura(succulent)

    hud:AddEssentialsAura(boltInstant):ShowStacksRatherThanDuration()

    hud:AddEssentialsCooldown(stalkers, nil, nil, 0.7, 0.0, 0.0)

    hud:AddEssentialsCooldown(implosion, nil, nil, 0.7, 0.0, 0.7)

    hud:AddEssentialsCooldown(siphon, nil, nil, 0.7, 0.0, 0.7)

    hud:AddEssentialsCooldown(tyrant, nil, nil, 0.7, 0.5, 1.0)

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.resolve)
    hud.defensiveGroup:AddCooldown(commonSpells.pact)

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.teleport)
    hud.movementGroup:AddCooldown(commonSpells.gateway)

    -- special
    hud.specialGroup:AddCooldown(commonSpells.instapet)
    --hud.specialGroup:AddCooldown(commonSpells.soulburn)

    -- control
    hud.controlGroup:AddCooldown(commonSpells.commandDemonKick).showOnlyIf = commonSpells.commandDemonIsKick
    hud.controlGroup:AddCooldown(commonSpells.coil)
    hud.controlGroup:AddCooldown(commonSpells.shadowfury)
    hud.controlGroup:AddCooldown(commonSpells.howl)
    hud.controlGroup:AddCooldown(commonSpells.bweakness)
    hud.controlGroup:AddCooldown(commonSpells.btongues)

    -- powerboost
    hud.powerboostGroup:AddCooldown(doomguard)
    hud.powerboostGroup:AddCooldown(bigImp)
    hud.powerboostGroup:AddCooldown(bigHunter)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS


    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local shardsDisplay = hud:AddResourceSlot(false):AddPowerPoints(shards, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, nil, function() return 3 end)
    function shardsDisplay:DisplayUpdated(t, combat)
        if (diabolist.ruination.auraIsPresent) then
            self:SetBorderColor(0.0, 1.0, 1.0, false)
        else
            self:SetBorderColor(1.0, 1.0, 0.0, false)
        end
        if (diabolist.infernalBolt.auraIsPresent) then
            self:SetPointColor(0.0, 1.0, 0.0, false)
        else
            self:SetPointColor(1.0, 0.0, 1.0, false)
        end
    end

    local impsBar = hud:AddResourceSlot(false):AddStacksBar(imps, 0.8, 0.8, 0.0, nil, function() return 15 end, function() return 0 end)
    impsBar.heightMultiplier = 0.666
    function impsBar:OverrideVisibilityAlpha(aura, t, combat)
        if (combat) then
            return 1.0
        else
            return 0.0
        end
    end

    local petHealth = hud:AddPetHealth()
    local petBar = hud:AddResourceSlot(true):AddHealth(petHealth, true)

    --#endregion
    --------------------------------
end

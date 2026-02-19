---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Holy(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS

    local talent_oracle = ERALIBTalent:Create(117286)
    local talent_archon = ERALIBTalent:Create(134273)
    local talent_hwSanctify = ERALIBTalent:CreateAnd(ERALIBTalent:Create(103766), ERALIBTalent:CreateNotTalent(103733))
    local talent_hwChastise = ERALIBTalent:Create(103776)
    local talent_blaze = ERALIBTalent:Create(103777)
    local talent_hymn = ERALIBTalent:Create(103755)
    local talent_apotheosis = ERALIBTalent:Create(103748)
    local talent_divinity = ERALIBTalent:Create(128611)
    local talent_lightweaver = ERALIBTalent:Create(103734)
    local talent_naaru = ERALIBTalent:Create(103675)
    local talent_epiphany = ERALIBTalent:Create(103740)
    local talent_hfire = ERALIBTalent:Create(134283)
    local talent_swp = ERALIBTalent:CreateNot(talent_hfire)
    local talent_apex = ERALIBTalent:Create(136993)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local pom = hud:AddCooldown(33076)
    local dispell = hud:AddCooldown(527)
    local guardian = hud:AddCooldown(47788)
    local hwSerenity = hud:AddCooldown(2050)
    local hwSanctify = hud:AddCooldown(34861, talent_hwSanctify)
    local hwChastise = hud:AddCooldown(88625, talent_hwChastise)
    local hymn = hud:AddCooldown(64843, talent_hymn)
    local apotheosis = hud:AddCooldown(200183, talent_apotheosis)
    local halo = hud:AddCooldown(120517, talent_archon)
    local hfire = hud:AddCooldown(14914, talent_hfire)

    local swp = hud:AddAuraByPlayer(589, true, talent_swp)
    local hfireDuration = hud:AddAuraByPlayer(14914, true, talent_hfire)
    local redemption = hud:AddAuraByPlayer(20711, false)
    local apotheosisDuration = hud:AddAuraByPlayer(200183, false, talent_apotheosis)
    local naaru = hud:AddAuraByPlayer(392988, false, talent_naaru)
    local divinity = hud:AddAuraByPlayer(1215241, false, talent_divinity)
    local blaze = hud:AddAuraByPlayer(372616, false, talent_blaze)
    local lightweaver = hud:AddAuraByPlayer(390992, false, talent_lightweaver)
    local apex = hud:AddAuraByPlayer(1262766, false, talent_apex)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(guardian)

    -- movement

    -- control

    -- buffs
    hud.buffGroup:AddAura(divinity, nil, nil):ShowStacksRatherThanDuration()
    hud.buffGroup:AddAura(apotheosisDuration, nil, nil)
    hud.buffGroup:AddAura(redemption, nil, nil)

    -- powerboost
    hud.powerboostGroup:AddCooldown(hymn)
    hud.powerboostGroup:AddCooldown(apotheosis)

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, false)

    -- assist
    hud.assistGroup:AddCooldown(pom)
    hud.assistGroup:AddCooldown(dispell)
    hud.assistGroup:AddCooldown(hwSanctify)
    hud.assistGroup:AddCooldown(hwSerenity)
    hud.assistGroup:AddCooldown(halo)
    hud.assistGroup:AddCooldown(commonSpells.nova)
    hud.assistGroup:AddAura(lightweaver)

    -- essentials

    local _, dotSlot = hud:AddDOT(swp, nil, nil, 1.0, 0.8, 0.0)
    dotSlot:AddOverlapingCooldown(hfire):SetBorderColor(1.0, 0.8, 0.0)
    dotSlot:AddTimerBar(0.75, naaru, nil, 1.0, 1.0, 1.0)

    hud:AddEssentialsCooldown(hwChastise, nil, nil, 1.0, 0.0, 0.0)

    --hud:AddEssentialsAura(blaze):ShowStacksRatherThanDuration()

    ERACombatFrames_PriestSWDeath(hud, nil, commonSpells)

    hud:AddEssentialsRightCooldown(halo)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(apex, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Daybreak.tga", false, "ROTATE_RIGHT", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end

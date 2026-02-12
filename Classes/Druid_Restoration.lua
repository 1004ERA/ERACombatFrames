---@param cFrame ERACombatMainFrame
---@param talents DruidTalents
function ERACombatFrames_Druid_Restoration(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 4)
    ---@cast hud HUDModuleDruid

    --------------------------------
    --#region TALENTS

    local talent_grove = ERALIBTalent:Create(117195)
    local talent_stalker = ERALIBTalent:Create(117226)
    local talent_incarnation = ERALIBTalent:Create(103120)
    local talent_reforestation = ERALIBTalent:Create(103125)
    local talent_incarnation_buff = ERALIBTalent:CreateOr(talent_incarnation, talent_reforestation)
    local talent_convoke = ERALIBTalent:Create(103119)
    local talent_efflo = ERALIBTalent:Create(103111)
    local talent_ironbark = ERALIBTalent:Create(103141)
    local talent_swiftness = ERALIBTalent:Create(103101)
    local talent_tranq = ERALIBTalent:Create(103108)
    local talent_abundance = ERALIBTalent:Create(128277)
    local talent_elder = ERALIBTalent:Create(103123)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local starsurge = hud:AddCooldown(197626, talents.starsurge)
    local wgrowth = hud:AddCooldown(48438)
    local dispell = hud:AddCooldown(88423)
    local swiftmend = hud:AddCooldown(18562)
    local swiftness = hud:AddCooldown(132158, talent_swiftness)
    local ironbark = hud:AddCooldown(102342, talent_ironbark)
    local incarnation = hud:AddCooldown(33891, talent_incarnation)
    local convoke = hud:AddCooldown(391528, talent_convoke)
    local tranq = hud:AddCooldown(740, talent_tranq)

    local lifebloom = hud:AddAuraByPlayer(33763, false)
    lifebloom.useUnitCDM = true
    local moonfire = hud:AddAuraByPlayer(8921, true)
    local sunfire = hud:AddAuraByPlayer(93402, true, talents.sunfire)
    local barkskin = hud:AddAuraByPlayer(22812, false)
    local abundance = hud:AddAuraByPlayer(207383, false, talent_abundance)
    local elder = hud:AddAuraByPlayer(426784, false, talent_elder)
    local efflo = hud:AddAuraByPlayer(145205, false, talent_efflo)
    local incarnationDuration = hud:AddAuraByPlayer(117679, false, talent_incarnation_buff)
    local omen = hud:AddAuraByPlayer(113043, false)
    local reforestation = hud:AddAuraByPlayer(392356, false, talent_reforestation)
    local soulforest = hud:AddAuraByPlayer(158478, false)
    local dreamsurge = hud:AddAuraByPlayer(433831, false, talent_grove)
    local bloomingOffensive = hud:AddAuraByPlayer(429474, false, talent_grove)
    local bloomingHealing = hud:AddAuraByPlayer(429438, false, talent_grove)

    local bloomingHealingOverlay = hud:AddPublicBooleanAnd(hud:AddSpellOverlayBoolean(8936), hud:AddSpellOverlayBoolean(339))
    local starfireOverlay = hud:AddSpellOverlayBoolean(197628)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(reforestation):ShowStacksRatherThanDuration()

    local _, swiftmendSlot = hud:AddEssentialsCooldown(swiftmend, nil, nil, 0.0, 0.2, 0.7)
    swiftmendSlot:AddTimerBar(0.25, efflo, nil, 1.0, 0.7, 0.8)
    swiftmendSlot:AddTimerBar(0.75, soulforest, nil, 0.3, 0.5, 1.0).doNotCutLongDuration = true

    local lifebloomIcon = hud:AddEssentialsAura(lifebloom, nil, nil, 0.0, 1.0, 1.0)
    lifebloomIcon.showRedIfMissingInCombat = true

    local _, wgrowthSlot = hud:AddEssentialsCooldown(wgrowth, nil, nil, 0.7, 1.0, 0.7)
    wgrowthSlot:AddTimerBar(0.25, incarnationDuration, nil, 1.0, 0.0, 1.0)

    hud:AddEssentialsCooldown(starsurge, nil, nil, 1.0, 0.0, 1.0)

    local _, moonfireSlot = hud:AddDOT(moonfire, nil, nil, 0.2, 0.2, 0.8)
    moonfireSlot:AddTimerBar(0.75, elder, nil, 1.0, 0.0, 0.0).doNotCutLongDuration = true

    local _, sunfireSlot = hud:AddDOT(sunfire, nil, nil, 0.8, 0.8, 0.2)

    -- assist
    hud.assistGroup:AddAura(lifebloom).showRedIfMissingInCombat = true
    hud.assistGroup:AddCooldown(wgrowth)
    hud.assistGroup:AddCooldown(swiftmend)
    hud.assistGroup:AddCooldown(dispell)
    hud.assistGroup:AddCooldown(ironbark)

    -- defensive

    -- movement

    -- special

    -- control

    -- powerboost
    hud.powerboostGroup:AddCooldown(swiftness)
    hud.powerboostGroup:AddCooldown(incarnation)
    hud.powerboostGroup:AddCooldown(convoke)
    hud.powerboostGroup:AddCooldown(tranq)

    -- buff
    hud.buffGroup:AddAura(efflo).showRedIfMissingInCombat = true
    hud.buffGroup:AddAura(incarnationDuration)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddPublicBooleanOverlayAlert(nil, 463452, false, starfireOverlay, "NONE", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddPublicBooleanOverlayAlert(nil, "Interface/Addons/ERACombatFrames/textures/alerts/Natures_Grace.tga", false, bloomingHealingOverlay, "ROTATE_RIGHT", "TOP")

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    ERACombatFrames_Druid_FeralOffSpec_step1(hud)
    ERACombatFrames_Druid_GuardianOffSpec_step1(hud)

    hud:AddResourceSlot(false):AddStacksBar(abundance, 0.1, 0.7, 0.4, talent_abundance, function() return 12 end, function() return 0 end).heightMultiplier = 0.5

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, 0.2, 0.2, 1.0)

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, false, false, true)
    ERACombatFrames_Druid_FeralOffSpec_step2(hud, talents, moonfireSlot, sunfireSlot)
    ERACombatFrames_Druid_GuardianOffSpec_step2(hud, talents, commonSpells, moonfireSlot, sunfireSlot)
end

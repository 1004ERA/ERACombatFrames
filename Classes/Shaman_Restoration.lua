---@param cFrame ERACombatMainFrame
---@param talents ShamanTalents
function ERACombatFrames_Shaman_Restoration(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    --------------------------------
    --#region TALENTS

    local talent_farseer = ERALIBTalent:Create(117485)
    local talent_ancestral_swiftness = ERALIBTalent:Create(117491)
    local talent_lava = ERALIBTalent:Create(127873)
    local talent_unlimited_shield = ERALIBTalent:Create(127868)
    local talent_limited_shield = ERALIBTalent:CreateNot(talent_unlimited_shield)
    local talent_ascendance = ERALIBTalent:Create(101912)
    local talent_tide = ERALIBTalent:Create(135486)
    local talent_unleash = ERALIBTalent:Create(114811)
    local talent_tidwave = ERALIBTalent:Create(101928)
    local talent_downpour = ERALIBTalent:Create(127682)
    local talent_link = ERALIBTalent:Create(101924)
    local talent_coalescing = ERALIBTalent:Create(101925)
    local talent_rain_totem = ERALIBTalent:Create(117474)
    local talent_rain = ERALIBTalent:CreateAnd(ERALIBTalent:Create(101923), ERALIBTalent:CreateNot(talent_rain_totem))
    local talent_ascendance_or_proc = ERALIBTalent:CreateOr(talent_ascendance, ERALIBTalent:Create(101937))
    local talent_apex = ERALIBTalent:CreateOr(ERALIBTalent:Create(136975), ERALIBTalent:Create(136976), ERALIBTalent:Create(136977))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local stream = hud:AddCooldown(5394)
    local lava = hud:AddCooldown(51505, talent_lava)
    local rain = hud:AddCooldown(73920, talent_rain)
    local rain_totem = hud:AddCooldown(444995, talent_rain_totem)
    local ascendance = hud:AddCooldown(114052, talent_ascendance)
    local tide = hud:AddCooldown(108280, talent_tide)
    local unleash = hud:AddCooldown(73685, talent_unleash)
    local link = hud:AddCooldown(98008, talent_link)
    local riptide = hud:AddCooldown(61295)
    local dispell = hud:AddCooldown(77130)
    local flshock = hud:AddCooldown(470411)
    local aswift = hud:AddCooldown(443454, talent_ancestral_swiftness)

    local coalescing = hud:AddAuraByPlayer(470076, false, talent_coalescing)
    local ancestors = hud:AddAuraByPlayer(443450, false, talent_farseer)
    local tidwave = hud:AddAuraByPlayer(51564, false, talent_tidwave)
    local streamDuration = hud:AddAuraTotem(3, 5394)
    local ascendanceDuration = hud:AddAuraByPlayer(114052, false, talent_ascendance_or_proc)
    local spiritwalk = hud:AddAuraByPlayer(79206, false, talents.spiritwalk)
    local unleashBuff = hud:AddAuraByPlayer(73685, false, talent_unleash)
    local wshield = hud:AddAuraByPlayer(52127, false)
    local downpour = hud:AddAuraByPlayer(462486, false, talent_downpour)
    local flame = hud:AddAuraByPlayer(470411, true)
    local apex = hud:AddAuraByPlayer(1267089, true, talent_apex)

    local downpourUsable = hud:AddAuraBoolean(downpour)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(link)

    -- movement

    -- control

    -- buffs
    hud.buffGroup:AddAura(tidwave):ShowStacksRatherThanDuration()
    hud.buffGroup:AddAura(ascendanceDuration)
    hud.buffGroup:AddAura(spiritwalk)

    -- powerboost
    hud.powerboostGroup:AddCooldown(ascendance)
    hud.powerboostGroup:AddCooldown(tide)

    -- alerts
    hud.alertGroup:AddMissingAuraAlert(wshield)

    local commonSpells = ERACombatFrames_ShamanCommonSpells(hud, talents, true, talent_ancestral_swiftness)

    -- assist
    local riptideAssist = hud.assistGroup:AddCooldown(riptide)
    riptideAssist:HideCountdown()
    riptideAssist:SetMainTextColor(0.0, 1.0, 0.0)
    function riptideAssist:GetMainText()
        if (talent_coalescing:PlayerHasTalent()) then
            return tostring(coalescing.stacks)
        else
            return nil
        end
    end
    hud.assistGroup:AddCooldown(rain).overlayAlsoIf = downpourUsable
    hud.assistGroup:AddCooldown(rain_totem).overlayAlsoIf = downpourUsable
    --hud.assistGroup:AddAura(coalescing):ShowStacksRatherThanDuration()
    hud.assistGroup:AddCooldown(stream)
    hud.assistGroup:AddCooldown(unleash)
    hud.assistGroup:AddCooldown(dispell)

    -- essentials

    --hud:AddEssentialsLeftAura(tidwave):ShowStacksRatherThanDuration()

    local _, aswiftSlot = hud:AddEssentialsCooldown(aswift, nil, nil, 0.6, 0.8, 1.0)
    aswiftSlot:AddTimerBar(0.75, ancestors, nil, 0.0, 0.0, 1.0).doNotCutLongDuration = true

    hud:AddEssentialsCooldown(unleash, nil, nil, 0.0, 1.0, 0.0)

    local _, lavaSlot = hud:AddEssentialsCooldown(lava, nil, nil, 1.0, 0.0, 0.0)
    lavaSlot:AddTimerBar(0.25, ascendanceDuration, nil, 1.0, 0.0, 1.0)

    hud:AddEssentialsCooldown(flshock, nil, nil, 0.8, 0.4, 0.0, false)

    local _, dotSlot = hud:AddDOT(flame, 135805, nil, 1.0, 1.0, 0.0) -- 2175503 451164
    dotSlot:AddTimerBar(0.75, spiritwalk, nil, 0.7, 1.0, 0.7)

    local wshieldIcon = hud:AddEssentialsRightAura(wshield, nil, talent_limited_shield)
    wshieldIcon:ShowStacksRatherThanDuration()
    wshieldIcon.showRedIfMissingInCombat = true

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    ascendanceDuration.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddAuraOverlayAlert(unleashBuff, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Fury_of_Stormrage.tga", false, "NONE", "TOP")
    hud:AddAuraOverlayAlert(apex, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Daybreak.tga", false, "NONE", "LEFT").playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end

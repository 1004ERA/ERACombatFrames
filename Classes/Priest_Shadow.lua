---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Shadow(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)
    hud:AddChannelInfo(15407, 6, 0.75)

    --------------------------------
    --#region TALENTS

    local talent_archon = ERALIBTalent:Create(117300)
    local talent_voidweaver = ERALIBTalent:Create(117287)
    local talent_free_mblast = ERALIBTalent:Create(103813)
    local talent_free_madness = ERALIBTalent:Create(133550)
    local talent_crit_mblast = ERALIBTalent:Create(133400)
    local talent_shadowform = ERALIBTalent:CreateLevel(20) -- noramelent 10 mais on sait jamais
    local talent_voidform = ERALIBTalent:Create(103674)
    local talent_auto_swp = ERALIBTalent:Create(103809)
    local talent_independant_swp = ERALIBTalent:CreateNot(talent_auto_swp)
    local talent_crushing = ERALIBTalent:Create(103797)
    local talent_slam = ERALIBTalent:Create(115448)
    local talent_cheap_madness = ERALIBTalent:Create(103786)
    local talent_expensive_madness = ERALIBTalent:Create(115671)
    local talent_normal_madness = ERALIBTalent:CreateNOR(talent_cheap_madness, talent_expensive_madness)
    local talent_swDeath35 = ERALIBTalent:Create(todo.todo)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local insa = hud:AddPowerLowIdle(Enum.PowerType.Insanity)

    local silence = hud:AddCooldown(15487)
    local dispersion = hud:AddCooldown(47585)
    local embrace = hud:AddCooldown(15286)
    --local mBlast = hud:AddCooldown(8092)
    local pws = hud:AddCooldown(17)
    local slam = hud:AddCooldown(1227280, talent_slam)
    local voidform = hud:AddCooldown(228260, talent_voidform)
    local volley = hud:AddCooldown(1242173, talent_voidform)
    local halo = hud:AddCooldown(120644, talent_archon)
    local torrent = hud:AddCooldown(263165, talent_voidweaver)

    local form = hud:AddAuraByPlayer(232698, false, talent_shadowform)
    local vTouch = hud:AddAuraByPlayer(34914, true)
    local swp = hud:AddAuraByPlayer(589, true)
    local madness = hud:AddAuraByPlayer(335467, true)
    local crushing = hud:AddAuraByPlayer(1279354, false, talent_crushing)
    local dispersionDuration = hud:AddAuraByPlayer(47585, false)
    local rift = hud:AddAuraByPlayer(450193, false, talent_voidweaver)
    local freeMadness = hud:AddAuraByPlayer(373202, false, talent_free_madness)
    --local freeBlast = hud:AddAuraByPlayer(375888, false, talent_free_mblast)
    --local critBlast = hud:AddAuraByPlayer(391090, false, talent_crit_mblast)
    local voidformDuration = hud:AddAuraByPlayer(228264, false, talent_voidform)

    local missing_shadowform = hud:AddAuraBoolean(form)
    missing_shadowform.reverse = true
    local missing_voidform = hud:AddAuraBoolean(voidformDuration)
    missing_voidform.reverse = true
    local missing_both_forms = hud:AddPublicBooleanAnd(missing_shadowform, missing_voidform)
    local has_voidform_or_crushing = hud:AddPublicBooleanOr(hud:AddAuraBoolean(voidformDuration), hud:AddAuraBoolean(crushing))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(dispersion)
    hud.defensiveGroup:AddCooldown(embrace)

    -- movement

    -- control
    hud.controlGroup:AddCooldown(silence)
    hud:AddKickInfo(silence)

    -- buffs
    hud.buffGroup:AddAura(dispersionDuration)

    -- powerboost
    hud.powerboostGroup:AddCooldown(voidform)

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, true)

    -- essentials

    hud:AddEssentialsLeftCooldown(pws)

    local volleyIcon, volleySlot, volleyBar = hud:AddEssentialsCooldown(volley, 7439213, nil, 0.8, 0.0, 0.8)
    volleyBar.showOnlyIf = has_voidform_or_crushing
    volleyIcon.showOnlyIf = has_voidform_or_crushing
    --volleyIcon.showOnlyWhenUsableOrOverlay = true
    volleySlot:AddTimerBar(0.25, crushing, nil, 0.5, 0.0, 0.5)
    volleySlot:AddTimerBar(0.75, voidformDuration, nil, 1.0, 0.0, 1.0).doNotCutLongDuration = true

    hud:AddDOT(swp, nil, talent_independant_swp, 1.0, 0.8, 0.0)
    hud:AddDOT(vTouch, nil, nil, 0.7, 0.5, 1.0)

    hud:AddEssentialsCooldown(commonSpells.mBlast, nil, nil, 1.0, 0.0, 0.0)

    hud:AddEssentialsAura(madness, nil, nil, 0.0, 1.0, 0.0)

    hud:AddEssentialsCooldown(slam, nil, nil, 0.0, 0.0, 1.0)

    ERACombatFrames_PriestSWDeath(hud, talent_swDeath35, commonSpells)

    local _, torrentSlot = hud:AddEssentialsCooldown(torrent, nil, nil, 0.8, 0.7, 0.7)
    torrentSlot:AddTimerBar(0.25, rift, nil, 0.2, 0.0, 0.5).doNotCutLongDuration = true

    hud:AddEssentialsCooldown(halo, nil, nil, 0.8, 0.7, 0.7)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud.alertGroup:AddBooleanAlert(missing_both_forms, 136200, talent_shadowform)
    hud:AddAuraOverlayAlert(freeMadness, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Nightfall.tga", false, "MIRROR_H", "RIGHT").playSoundWhenApperars =
        SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddMissingAuraOverlayAlert(swp, talent_auto_swp, "icons_64x64_disease", true, false, "NONE", "CENTER").showOnlyWhenInCombatWithEnemyTarget = true

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local insaDisplay = hud:AddResourceSlot(false):AddPowerValue(insa, 0.8, 0.0, 0.8)
    insaDisplay:AddTick(7569529, talent_normal_madness, function() return 50 end)
    insaDisplay:AddTick(7569529, talent_cheap_madness, function() return 45 end)
    insaDisplay:AddTick(7569529, talent_expensive_madness, function() return 55 end)

    --#endregion
    --------------------------------
end

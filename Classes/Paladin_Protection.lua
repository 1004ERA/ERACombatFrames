---@param cFrame ERACombatMainFrame
---@param talents PaladinTalents
function ERACombatFrames_Paladin_Protection(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)
    --------------------------------
    --#region TALENTS

    local talent_lightsmith = ERALIBTalent:Create(117882)
    local talent_templar = ERALIBTalent:Create(117813)
    local talent_hrighteous = ERALIBTalent:Create(102431)
    local talent_hblessed = ERALIBTalent:Create(102430)
    local talent_crustrike = ERALIBTalent:CreateNOR(talent_hrighteous, talent_hblessed)
    local talent_wrath = ERALIBTalent:Create(102448)
    local talent_sentinel = ERALIBTalent:Create(102447)
    local talent_toll = ERALIBTalent:Create(136496)
    local talent_kick = ERALIBTalent:Create(102591)
    local talent_ardef = ERALIBTalent:Create(102445)
    local talent_spellwarding = ERALIBTalent:Create(111886)
    local talent_guardian = ERALIBTalent:Create(102456)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local hrighteous = hud:AddCooldown(53595, talent_hrighteous)
    local hblessed = hud:AddCooldown(204019, talent_hblessed)
    local crustrike = hud:AddCooldown(35395, talent_crustrike)
    local wrath = hud:AddCooldown(31884, talent_wrath)
    local sentinel = hud:AddCooldown(389539, talent_sentinel)
    local toll = hud:AddCooldown(375576, talent_toll)
    local captain = hud:AddCooldown(31935)
    local consecr = hud:AddCooldown(26573)
    local ardef = hud:AddCooldown(31850, talent_ardef)
    local spellwarding = hud:AddCooldown(204018, talent_spellwarding)
    local guardian = hud:AddCooldown(86659, talent_guardian)
    local armaments = hud:AddCooldown(432459, talent_lightsmith)

    local wrathDuration = hud:AddAuraByPlayer(31884, false, talent_wrath)
    local sentinelDuration = hud:AddAuraByPlayer(389539, false, talent_sentinel)
    local consecrDuration = hud:AddAuraTotem(1, 26573)
    local shield = hud:AddAuraByPlayer(53600, false)
    local shining = hud:AddAuraByPlayer(321136, false)
    local bubble = hud:AddAuraByPlayer(642, false)
    local ardefDuration = hud:AddAuraByPlayer(31850, false, talent_ardef)
    local deliverance = hud:AddAuraByPlayer(425518, false, talent_templar)
    local armament_sword = hud:AddAuraByPlayer(432502, false, talent_lightsmith)
    local armament_shield = hud:AddAuraByPlayer(432496, false, talent_lightsmith)

    local hammerOfLight = hud:AddIconBoolean(toll.spellID, 5342121, ERALIBTalent:CreateAnd(talent_toll, talent_templar))

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(guardian)
    hud.defensiveGroup:AddCooldown(spellwarding)

    -- movement

    -- control

    -- buffs
    hud.buffGroup:AddAura(armament_shield)
    hud.buffGroup:AddAura(armament_sword, nil, nil, true)

    -- powerboost
    hud.powerboostGroup:AddCooldown(wrath)
    hud.powerboostGroup:AddCooldown(sentinel)

    local commonSpells = ERACombatFrames_PaladinCommonSpells(cFrame, hud, talents, talent_kick, false)

    -- essentials

    hud:AddEssentialsLeftAura(deliverance):ShowStacksRatherThanDuration()

    local armamentIcon, armamentSlot = hud:AddEssentialsCooldown(armaments, nil, nil, 0.6, 0.4, 0.2)
    armamentIcon.watchIconChange = true
    armamentSlot:AddTimerBar(0.25, armament_shield, nil, 0.6, 0.4, 0.5)
    armamentSlot:AddTimerBar(0.75, armament_sword, nil, 0.9, 0.4, 0.2)

    local tollIcon = hud:AddEssentialsCooldown(toll, nil, nil, 0.5, 0.5, 1.0)
    tollIcon.watchIconChange = true

    ERACombatFrames_PaladinJudgment(hud, talents, commonSpells, 1241413, wrathDuration, sentinelDuration, true)

    local hrighteousIcon, mainSlot = hud:AddEssentialsCooldown(hrighteous, nil, nil, 1.0, 1.0, 1.0)
    hrighteousIcon:HideCountdown()
    mainSlot:AddOverlapingCooldown(hblessed):HideCountdown()
    mainSlot:AddTimerBar(0.5, hblessed, nil, 1.0, 1.0, 1.0)
    mainSlot:AddOverlapingCooldown(crustrike):HideCountdown()
    mainSlot:AddTimerBar(0.5, crustrike, nil, 1.0, 1.0, 1.0)

    mainSlot:AddTimerBar(0.25, shield, nil, 0.7, 0.3, 0.7).doNotCutLongDuration = true

    hud:AddEssentialsCooldown(captain, nil, nil, 1.0, 0.5, 0.0)

    local _, consecrSlot = hud:AddEssentialsAuraLike(consecrDuration)
    consecrSlot:AddTimerBar(0.5, consecr, nil, 0.66, 0.0, 0.0)

    local _, ardefSlot = hud:AddEssentialsCooldown(ardef, nil, nil, 1.0, 1.0, 1.0, false)
    ardefSlot:AddTimerBar(0.5, ardefDuration, nil, 0.5, 0.5, 0.5).doNotCutLongDuration = true
    ardefSlot:AddTimerBar(0.75, bubble, nil, 0.1, 0.1, 0.1).doNotCutLongDuration = true

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    shining.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddAuraOverlayAlert(shining, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Denounce.tga", false, "NONE", "CENTER")
    hud:AddPublicBooleanOverlayAlert(nil, "Interface/Addons/ERACombatFrames/textures/alerts/Surge_of_Light.tga", false, hammerOfLight, "ROTATE_RIGHT", "TOP").playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    function commonSpells.powerPoints:DisplayUpdated(t, combat)
        if (shining.auraIsActive) then
            self:SetBorderColor(0.0, 1.0, 0.0, false)
        else
            self:SetBorderColor(1.0, 1.0, 1.0, false)
        end
    end

    --#endregion
    --------------------------------
end

---@param cFrame ERACombatMainFrame
---@param talents PaladinTalents
function ERACombatFrames_Paladin_Holy(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)
    --------------------------------
    --#region TALENTS

    local talent_herald = ERALIBTalent:Create(117696)
    local talent_lightsmith = ERALIBTalent:Create(136795)
    local talent_not_lightsmith = ERALIBTalent:CreateNot(talent_lightsmith)
    local talent_afterimage = ERALIBTalent:Create(102601)
    local talent_toll = ERALIBTalent:CreateAnd(talent_not_lightsmith, ERALIBTalent:Create(102465))
    local talent_prism = ERALIBTalent:CreateAnd(talent_not_lightsmith, ERALIBTalent:Create(133480))
    local talent_auramastery = ERALIBTalent:Create(102548)
    local talent_consecration = ERALIBTalent:CreateNotTalent(115875)
    local talent_beacon_faith = ERALIBTalent:Create(102533)
    local talent_beacon_virtue = ERALIBTalent:Create(102532)
    local talent_beacon_normal = ERALIBTalent:CreateNot(talent_beacon_virtue)
    local talent_empyrean = ERALIBTalent:Create(102576)
    local talent_wrath = ERALIBTalent:Create(102569)
    local talent_crusader = ERALIBTalent:Create(102568)
    local talent_avenging = ERALIBTalent:CreateOr(talent_wrath, talent_crusader)
    local talent_awakening = ERALIBTalent:Create(116205)
    local talent_divinity = ERALIBTalent:Create(133501)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local shock = hud:AddCooldown(20473)
    local consecration = hud:AddCooldown(26573, talent_consecration)
    local prism = hud:AddCooldown(114165, talent_prism)
    local toll = hud:AddCooldown(375576, talent_toll)
    local armaments = hud:AddCooldown(432459, talent_lightsmith)
    local protection = hud:AddCooldown(498)
    local wrath = hud:AddCooldown(31884, talent_wrath)
    local crusader = hud:AddCooldown(216331, talent_crusader)
    local crustrike = hud:AddCooldown(1279187, talent_crusader)
    local beacon_virtue = hud:AddCooldown(200025, talent_beacon_virtue)
    local auramastery = hud:AddCooldown(31821, talent_auramastery)
    local dispell = hud:AddCooldown(4987)

    local afterimage = hud:AddAuraByPlayer(385414, false, talent_afterimage)
    local wrath_crusader = hud:AddAuraByPlayer(31884, false, talent_avenging)
    local empyrean = hud:AddAuraByPlayer(1241358, false, talent_empyrean)
    local divinity = hud:AddAuraByPlayer(1242008, false, talent_divinity)
    local awakening = hud:AddAuraByPlayer(414193, false, talent_awakening) -- géré par l'overlay de jugement
    local infusion = hud:AddAuraByPlayer(53576, false)                     -- géré par l'overlay de base

    local hasCrusader = hud:AddIconBoolean(crusader.spellID, 135891, talent_crusader)
    local beaconNormalAlert = hud:AddSpellOverlayBoolean(53563, talent_beacon_normal)
    local beaconFaithAlert = hud:AddPublicBooleanAnd(hud:AddSpellOverlayBoolean(156910, talent_beacon_faith), hud.isInGroupOrRaid)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(protection)
    hud.defensiveGroup:AddCooldown(auramastery)

    -- movement

    -- control

    -- buffs

    -- assist
    hud.assistGroup:AddCooldown(shock)
    hud.assistGroup:AddCooldown(beacon_virtue)
    hud.assistGroup:AddCooldown(dispell)
    hud.assistGroup:AddCooldown(toll)
    hud.assistGroup:AddCooldown(prism)
    hud.assistGroup:AddCooldown(armaments)
    --hud.assistGroup:AddAura(divinity)

    -- powerboost
    hud.powerboostGroup:AddCooldown(wrath)
    hud.powerboostGroup:AddCooldown(crusader, 589117)

    local commonSpells = ERACombatFrames_PaladinCommonSpells(cFrame, hud, talents, nil, true)
    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    -- assist

    -- essentials

    local armamentIcon, armamentSlot = hud:AddEssentialsCooldown(armaments, nil, nil, 0.6, 0.4, 0.2)
    armamentIcon.watchIconChange = true

    hud:AddEssentialsCooldown(toll, nil, nil, 0.5, 0.5, 1.0)
    hud:AddEssentialsCooldown(prism, nil, nil, 0.5, 0.5, 1.0)

    ERACombatFrames_PaladinJudgment(hud, talents, commonSpells, 1241413, wrath_crusader, nil, true)

    hud:AddEssentialsCooldown(shock, nil, nil, 1.0, 1.0, 1.0)

    local crustrikeIon, crustrikeSlot = hud:AddEssentialsCooldown(crustrike, nil, nil, 1.0, 1.0, 1.0)
    crustrikeIon.showOnlyIf = hasCrusader
    crustrikeSlot:AddTimerBar(0.25, wrath_crusader, talent_crusader, 1.0, 0.0, 1.0)

    hud:AddEssentialsRightCooldown(consecration)
    hud:AddEssentialsRightAura(afterimage):ShowStacksRatherThanDuration()

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    empyrean.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    awakening.playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST
    hud:AddAuraOverlayAlert(divinity, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Denounce.tga", false, "NONE", "CENTER")

    hud.alertGroup:AddBooleanAlert(beaconNormalAlert, 236247)
    hud.alertGroup:AddBooleanAlert(beaconFaithAlert, 1030095)

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    function commonSpells.powerPoints:DisplayUpdated(t, combat)
        if (empyrean.auraIsActive) then
            self:SetBorderColor(1.0, 0.0, 0.0, false)
            self:SetPointColor(1.0, 0.0, 0.0, false)
        else
            self:SetBorderColor(1.0, 1.0, 1.0, false)
            self:SetPointColor(1.0, 1.0, 0.5, false)
        end
    end

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end

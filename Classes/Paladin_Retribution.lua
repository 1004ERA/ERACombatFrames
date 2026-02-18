---@param cFrame ERACombatMainFrame
---@param talents PaladinTalents
function ERACombatFrames_Paladin_Retribution(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1, 3)
    --------------------------------
    --#region TALENTS

    local talent_templar = ERALIBTalent:Create(117813)
    local talent_herald = ERALIBTalent:Create(117696)
    local talent_anshe = ERALIBTalent:Create(117668)
    local talent_autostrike = ERALIBTalent:Create(136809)
    local talent_combostrike = ERALIBTalent:Create(115473)
    local talent_normalstrike = ERALIBTalent:CreateNOR(talent_autostrike, talent_combostrike)
    local talent_wake = ERALIBTalent:Create(102497)
    local talent_execution = ERALIBTalent:Create(115435)
    local talent_autowrath = ERALIBTalent:Create(102525)
    local talent_normalwrath = ERALIBTalent:CreateNot(talent_autowrath)
    local talent_empyrean = ERALIBTalent:Create(115051)
    local talent_jje = ERALIBTalent:Create(102511)
    local talent_legacy = ERALIBTalent:Create(115453)
    local talent_toll = ERALIBTalent:Create(135564)
    local talent_kick = ERALIBTalent:Create(136594)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local normalstrike = hud:AddCooldown(35395, talent_normalstrike)
    local combostrike = hud:AddCooldown(407480, talent_combostrike)
    local autostrike = hud:AddAuraByPlayer(404542, false, talent_autostrike)

    local justice = hud:AddCooldown(184575)
    local protection = hud:AddCooldown(403876)
    local wrath = hud:AddCooldown(31884, talent_normalwrath)
    local wake = hud:AddCooldown(255937, talent_wake)
    local execution = hud:AddCooldown(343527, talent_execution)
    local toll = hud:AddCooldown(375576, talent_toll)

    local wrathDuration = hud:AddAuraByPlayer(31884, false)
    --local purpose = hud:AddAuraByPlayer(408459, false, talents.purpose)
    local resonance = hud:AddAuraByPlayer(384029, false, talents.resonance)
    local empyrean = hud:AddAuraByPlayer(326732, false, talent_empyrean)
    local executionDuration = hud:AddAuraByPlayer(343527, true, talent_execution)
    local jje = hud:AddAuraByPlayer(406157, false, talent_jje)
    local legacy = hud:AddAuraByPlayer(387170, false, talent_legacy)
    local deliverance = hud:AddAuraByPlayer(433674, false, talent_templar)
    local dawnlight = hud:AddAuraByPlayer(431377, true, talent_herald)
    local anshe = hud:AddAuraByPlayer(445206, false, talent_anshe)

    local hammerOfLight = hud:AddIconBoolean(255937, 5342121, ERALIBTalent:CreateAnd(talent_wake, talent_templar))
    local hasWrath = hud:AddAuraBoolean(wrathDuration)
    local hasNotWrath = hud:AddAuraBoolean(wrathDuration)
    hasNotWrath.reverse = true

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(protection)

    -- movement

    -- control

    -- buffs
    hud.buffGroup:AddAura(wrathDuration)

    -- powerboost
    hud.powerboostGroup:AddCooldown(wrath)

    local commonSpells = ERACombatFrames_PaladinCommonSpells(cFrame, hud, talents, talent_kick)

    -- essentials

    hud:AddEssentialsLeftAura(resonance)

    hud:AddEssentialsCooldown(toll, nil, nil, 0.5, 0.5, 1.0)

    ERACombatFrames_PaladinJudgment(hud, talents, commonSpells, 24275, wrathDuration, nil, false)

    hud:AddEssentialsCooldown(normalstrike, nil, nil, 1.0, 1.0, 1.0):HideCountdown()
    local comboIcon = hud:AddEssentialsCooldown(combostrike, nil, nil, 1.0, 1.0, 1.0)
    comboIcon:HideCountdown()
    comboIcon.watchIconChange = true
    hud:AddEssentialsAura(autostrike, nil, nil, 1.0, 1.0, 1.0, true):HideCountdown()

    hud:AddEssentialsCooldown(justice, nil, nil, 1.0, 0.5, 0.0)

    local wakeIcon, wakeSlot = hud:AddEssentialsCooldown(wake, nil, nil, 1.0, 0.0, 0.0)
    wakeIcon.watchIconChange = true
    wakeSlot:AddTimerBar(0.75, dawnlight, nil, 0.0, 0.0, 1.0).doNotCutLongDuration = true

    local _, executionSlot = hud:AddEssentialsCooldown(execution, nil, nil, 0.0, 0.7, 0.0)
    executionSlot:AddTimerBar(0.25, executionDuration, nil, 0.5, 1.0, 0.5).doNotCutLongDuration = true

    hud:AddEssentialsRightAura(deliverance):ShowStacksRatherThanDuration()

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    empyrean.playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddPublicBooleanOverlayAlert(nil, "Interface/Addons/ERACombatFrames/textures/alerts/Surge_of_Light.tga", false, hammerOfLight, "ROTATE_RIGHT", "TOP").playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST
    hud:AddAuraOverlayAlert(legacy, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Denounce.tga", false, "NONE", "CENTER")

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    function commonSpells.powerPoints:DisplayUpdated(t, combat)
        if (empyrean.auraIsActive) then
            self:SetBorderColor(1.0, 0.0, 0.0, false)
        else
            self:SetBorderColor(1.0, 1.0, 0.0, false)
        end
        if (jje.auraIsActive) then
            self:SetPointColor(0.0, 1.0, 0.0, false)
        else
            self:SetPointColor(1.0, 1.0, 0.5, false)
        end
    end

    --#endregion
    --------------------------------
end

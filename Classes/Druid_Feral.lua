---@param cFrame ERACombatMainFrame
---@param talents DruidTalents
function ERACombatFrames_Druid_Feral(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1, 2)
    ---@cast hud HUDModuleDruid

    --------------------------------
    --#region TALENTS

    local talent_claw = ERALIBTalent:Create(117206)
    local talent_wildstalker = ERALIBTalent:Create(117226)
    local talent_omen = ERALIBTalent:Create(103187)
    local talent_coiled = ERALIBTalent:Create(103144)
    local talent_sabertooth = ERALIBTalent:Create(103163)
    local talent_instincts = ERALIBTalent:Create(103180)
    local talent_ambush = ERALIBTalent:Create(114771)
    local talent_ashamane = ERALIBTalent:Create(103178)
    local talent_berserk = ERALIBTalent:CreateAnd(ERALIBTalent:Create(103162), ERALIBTalent:CreateNot(talent_ashamane))
    local talent_tenacity = ERALIBTalent:Create(103168)
    local talent_momentum = ERALIBTalent:Create(103179)
    local talent_apex = ERALIBTalent:Create(103172)
    local talent_francticfrenzy = ERALIBTalent:Create(134211)
    local talent_feralfrenzy = ERALIBTalent:CreateAnd(ERALIBTalent:Create(103175), ERALIBTalent:CreateNot(talent_francticfrenzy))
    local talent_convoke = ERALIBTalent:Create(103177)
    local talent_moonfire = ERALIBTalent:Create(103170)
    local talent_chomp = ERALIBTalent:Create(134212)
    local talent_hunger = ERALIBTalent:Create(103156)
    local talent_apex = ERALIBTalent:Create(137045)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local combo = hud:AddPowerLowIdle(Enum.PowerType.ComboPoints)
    local nrj = hud:AddPowerHighIdle(Enum.PowerType.Energy)

    local fury = hud:AddCooldown(5217)
    local instincts = hud:AddCooldown(61336, talent_instincts)
    local berserk = hud:AddCooldown(106951, talent_berserk)
    local ashamane = hud:AddCooldown(102543, talent_ashamane)
    local convoke = hud:AddCooldown(391528, talent_convoke)
    local feralfrenzy = hud:AddCooldown(274837, talent_feralfrenzy)
    local francticfrenzy = hud:AddCooldown(1273807, talent_francticfrenzy)
    local chomp = hud:AddCooldown(1244258, talent_chomp)

    local apex = hud:AddAuraByPlayer(391881, false, talent_apex)
    local berserkashamane = hud:AddAuraByPlayer(106951, false)
    local coiled = hud:AddAuraByPlayer(449537, false, talent_coiled)
    local hunger = hud:AddAuraByPlayer(1244547, false, talent_hunger)
    local omen = hud:AddAuraByPlayer(16864, false, talent_omen)
    local sabertooth = hud:AddAuraByPlayer(202031, true, talent_sabertooth)
    local tenacity = hud:AddAuraByPlayer(391872, false, talent_tenacity)
    local momentum = hud:AddAuraByPlayer(391875, false, talent_momentum) -- osef
    local ambush = hud:AddAuraByPlayer(384667, false, talent_ambush)
    local ravage = hud:AddAuraByPlayer(441583, false, talent_claw)
    --local moonfire = hud:AddAuraByPlayer(?, false, talent_moonfire)
    local swiftness = hud:AddAuraByPlayer(16974, false)
    local furyBuff = hud:AddAuraByPlayer(5217, false)
    local rake = hud:AddAuraByPlayer(1822, true)
    local rip = hud:AddAuraByPlayer(1079, true)
    local vines = hud:AddAuraByPlayer(439528, true, talent_wildstalker)
    local apex = hud:AddAuraByPlayer(1263658, false, talent_apex)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(coiled)
    hud:AddEssentialsLeftAura(tenacity)

    local _, furySlot = hud:AddEssentialsCooldown(fury, nil, nil, 1.0, 1.0, 0.0)
    furySlot:AddTimerBar(0.75, furyBuff, nil, 1.0, 0.0, 0.0).doNotCutLongDuration = true
    furySlot:AddTimerBar(0.25, berserkashamane, nil, 0.0, 0.0, 1.0)

    local rakeIcon, rakeSlot = hud:AddDOT(rake, nil, nil, 0.8, 0.7, 0.0)
    function rakeIcon:IconUpdated(t, combat, icon)
        icon:SetHighlight(ambush.auraIsActive)
    end
    --rakeSlot:AddTimerBar(0.25, sabertooth, nil, 1.0, 1.0, 1.0).doNotCutLongDuration = true
    --rakeSlot:AddTimerBar(0.75, vines, nil, 0.0, 1.0, 0.0).doNotCutLongDuration = true

    local _, ripSlot = hud:AddDOT(rip, nil, nil, 1.0, 0.0, 1.0)
    ripSlot:AddTimerBar(0.25, apex, nil, 0.7, 0.4, 0.4)

    hud:AddEssentialsCooldown(feralfrenzy, nil, nil, 0.0, 1.0, 1.0)
    hud:AddEssentialsCooldown(francticfrenzy, nil, nil, 0.0, 1.0, 1.0)

    local chompIcon = hud:AddEssentialsCooldown(chomp, nil, nil, 0.6, 0.4, 0.3)
    chompIcon.saturateWhenUsable = true

    hud:AddEssentialsRightAura(swiftness, 136085)
    hud:AddEssentialsRightAura(hunger):ShowStacksRatherThanDuration()

    -- defensive
    hud.defensiveGroup:AddCooldown(instincts)

    -- movement

    -- special

    -- control

    -- powerboost
    hud.powerboostGroup:AddCooldown(berserk)
    hud.powerboostGroup:AddCooldown(ashamane)
    hud.powerboostGroup:AddCooldown(convoke)

    -- buff
    hud.buffGroup:AddAura(berserkashamane)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(swiftness, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Natures_Grace.tga", false, "ROTATE_RIGHT", "TOP")
    hud:AddAuraOverlayAlert(apex, nil, "Start-VersusSplash", true, "NONE", "CENTER").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddAuraOverlayAlert(ravage, nil, "CovenantChoice-Celebration-Venthyr-DetailLine", true, "NONE", "TOP").playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    ERACombatFrames_Druid_GuardianOffSpec_step1(hud)

    local comboDisplay = hud:AddResourceSlot(false):AddPowerPoints(combo, 0.6, 0.8, 0.0, 1.0, 0.0, 0.0, nil, function() return 0 end)
    function comboDisplay:DisplayUpdated(t, combat)
        if (apex.auraIsActive) then
            self:SetPointColor(0.0, 1.0, 0.0, false)
        else
            self:SetPointColor(1.0, 0.0, 0.0, false)
        end
    end

    local nrjBar = hud:AddResourceSlot(false):AddPowerValue(nrj, 1.0, 1.0, 0.0)
    local shredTick = nrjBar:AddTick(136231, nil, function() return 40 end)
    local biteTick = nrjBar:AddTick(132127, nil, function() return 50 end)
    function biteTick:OverrideAlpha()
        ---@diagnostic disable-next-line: param-type-mismatch
        if (issecretvalue(combo.current)) then
            return 1.0
        else
            return combo.current / 5
        end
    end

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, false, true, false, false)
    ERACombatFrames_Druid_GuardianOffSpec_step2(hud, talents, commonSpells, rakeSlot, ripSlot)
end

---@param cFrame ERACombatMainFrame
---@param talents DruidTalents
function ERACombatFrames_Druid_Balance(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)
    ---@cast hud HUDModuleDruid

    --------------------------------
    --#region TALENTS

    local talent_grove = ERALIBTalent:Create(117195)
    local talent_elune = ERALIBTalent:Create(117205)
    local talent_treants = ERALIBTalent:Create(109844)
    local talent_balance_power = ERALIBTalent:Create(109862)
    local talent_incarnation = ERALIBTalent:Create(109839)
    local talent_alignment = ERALIBTalent:CreateAnd(ERALIBTalent:Create(109849), ERALIBTalent:CreateNot(talent_incarnation))
    local talent_shroom = ERALIBTalent:Create(128232)
    local talent_grace = ERALIBTalent:Create(136832)
    local talent_amplification = ERALIBTalent:Create(109846)
    local talent_cosmos = ERALIBTalent:Create(109857)
    local talent_starweaver = ERALIBTalent:Create(109873)
    local talent_convoke = ERALIBTalent:Create(109838)
    local talent_fury = ERALIBTalent:Create(109859)
    local talent_moons = ERALIBTalent:Create(109860)
    local talent_umbral = ERALIBTalent:Create(109870)
    local talent_harmony = ERALIBTalent:Create(133404)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerTargetIdle(Enum.PowerType.LunarPower, nil, function()
        if (talent_balance_power:PlayerHasTalent()) then
            return 50
        else
            return 0
        end
    end)

    local alignment = hud:AddCooldown(383410, talent_alignment)
    local incarnation = hud:AddCooldown(390414, talent_incarnation)
    local fury = hud:AddCooldown(202770, talent_fury)
    local moons = hud:AddCooldown(274281, talent_moons)
    local convoke = hud:AddCooldown(391528, talent_convoke)
    local treants = hud:AddCooldown(205636, talent_treants)
    local shroom = hud:AddCooldown(88747, talent_shroom)
    local eclipse = hud:AddCooldown(1233346)
    local beam = hud:AddCooldown(78675)

    local bloomingRegrowth = hud:AddAuraByPlayer(429438, false, talent_grove)
    local bloomingDamage = hud:AddAuraByPlayer(429474, false, talent_grove)
    local frenzy = hud:AddAuraByPlayer(231042, false)
    local alignment_incarnation = hud:AddAuraByPlayer(194223, false)
    local grace = hud:AddAuraByPlayer(450347, false, talent_grace)
    local starweaverStarsurge = hud:AddAuraByPlayer(393944, false, talent_starweaver)
    local starweaverStarfall = hud:AddAuraByPlayer(393942, false, talent_starweaver)
    local cosmos = hud:AddAuraByPlayer(450356, false, talent_cosmos)
    local umbral = hud:AddAuraByPlayer(393760, false, talent_umbral)
    local solarEclipse = hud:AddAuraByPlayer(48517, false)
    local lunarEclipse = hud:AddAuraByPlayer(48518, false)
    local moonfire = hud:AddAuraByPlayer(8921, true)
    local sunfire = hud:AddAuraByPlayer(93402, true)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(bloomingDamage)

    hud:AddEssentialsCooldown(fury, nil, nil, 0.0, 1.0, 1.0)
    local moonsIcon = hud:AddEssentialsCooldown(moons, nil, nil, 0.0, 1.0, 1.0)
    moonsIcon.watchIconChange = true

    local _, moonfireSlot = hud:AddDOT(moonfire, nil, nil, 0.2, 0.2, 0.8)

    local eclipseIcon, eclipseSlot = hud:AddEssentialsCooldown(eclipse, nil, nil, 1.0, 1.0, 1.0)
    eclipseIcon.watchIconChange = true
    eclipseSlot:AddTimerBar(0.25, lunarEclipse, nil, 0.3, 0.3, 1.0).doNotCutLongDuration = true
    eclipseSlot:AddTimerBar(0.75, solarEclipse, nil, 1.0, 1.0, 0.3).doNotCutLongDuration = true

    local _, sunfireSlot = hud:AddDOT(sunfire, nil, nil, 0.8, 0.8, 0.2)

    hud:AddEssentialsCooldown(treants, nil, nil, 0.0, 1.0, 0.0)

    hud:AddEssentialsCooldown(shroom, nil, nil, 1.0, 0.5, 0.8)

    hud:AddEssentialsRightAura(bloomingRegrowth)

    -- defensive

    -- movement

    -- special

    -- control
    hud.controlGroup:AddCooldown(beam)
    hud:AddKickInfo(beam)

    -- powerboost
    hud.powerboostGroup:AddCooldown(alignment)
    hud.powerboostGroup:AddCooldown(incarnation)
    hud.powerboostGroup:AddCooldown(convoke)

    -- buff
    --hud.buffGroup:AddAura(grace):ShowStacksRatherThanDuration()
    hud.buffGroup:AddAura(alignment_incarnation)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(frenzy, nil, "Adventures-Buff-Heal-Burst", true, "NONE", "BOTTOM")
    hud:AddAuraOverlayAlert(cosmos, nil, "ChallengeMode-Runes-BackgroundBurst", true, "NONE", "CENTER")
    hud:AddAuraOverlayAlert(starweaverStarsurge, nil, "Garr_BuildingUpgradeExplosion", true, "NONE", "RIGHT")
    hud:AddAuraOverlayAlert(starweaverStarfall, nil, 463452, false, "ROTATE_LEFT", "LEFT")
    hud:AddAuraOverlayAlert(bloomingDamage, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Feral_OmenOfClarity.tga", false, "NONE", "LEFT")
    hud:AddAuraOverlayAlert(bloomingRegrowth, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Natures_Grace.tga", false, "MIRROR_H", "RIGHT")

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    --ERACombatFrames_Druid_FeralOffSpec(hud, talents, moonfireSlot, sunfireSlot)
    ERACombatFrames_Druid_FeralOffSpec_step1(hud)
    ERACombatFrames_Druid_GuardianOffSpec_step1(hud)

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.5, 0.0, 0.6)
    function powerBar:AdditionalBarUpdate(t, combat, bar, current)
        if (cosmos.auraIsPresent) then
            bar:SetBarColor(1.0, 1.0, 1.0, false)
        else
            if (starweaverStarsurge.auraIsPresent) then
                if (starweaverStarfall.auraIsPresent) then
                    bar:SetBarColor(1.0, 1.0, 1.0, false)
                else
                    bar:SetBarColor(1.0, 0.6, 0.2, false)
                end
            else
                if (starweaverStarfall.auraIsPresent) then
                    bar:SetBarColor(0.2, 0.6, 1.0, false)
                else
                    bar:SetBarColor(0.6, 0.0, 0.7, false)
                end
            end
        end
    end
    local ticks = { { spell = 78674, icon = 135730, default = 40 }, { spell = 191034, icon = 236168, default = 50 } }
    for _, t in ipairs(ticks) do
        local tick = powerBar:AddTick(t.icon, nil, function(self)
            local infoTable = C_Spell.GetSpellPowerCost(t.spell)
            if (infoTable) then
                for _, info in ipairs(infoTable) do
                    if (info.type == Enum.PowerType.LunarPower) then
                        ---@diagnostic disable-next-line: inject-field
                        self.powerCost = info.cost
                        return info.cost
                    end
                end
            end
            ---@diagnostic disable-next-line: inject-field
            self.powerCost = t.default
            return t.default
        end)
        tick.continuouslyCheckValue = true
        function tick:OverrideAlpha()
            ---@diagnostic disable-next-line: undefined-field
            if (self.powerCost > 0) then
                return 1.0
            else
                return 0.0
            end
        end
    end

    --#endregion
    --------------------------------

    local commonSpells = ERACombatFrames_DruidCommonSpells(hud, talents, true, false, false, false)
    ERACombatFrames_Druid_FeralOffSpec_step2(hud, talents, nil, nil)
    ERACombatFrames_Druid_GuardianOffSpec_step2(hud, talents, commonSpells, moonfireSlot, sunfireSlot)
end

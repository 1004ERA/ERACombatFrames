---@param cFrame ERACombatMainFrame
---@param talents DeathKnightTalents
function ERACombatFrames_DeathKnight_Frost(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 2)

    --------------------------------
    --#region TALENTS

    local talent_deathbringer = ERALIBTalent:Create(117659)
    local talent_rider = ERALIBTalent:Create(117663)
    local talent_onslaught = ERALIBTalent:Create(128266)
    local talent_remorseless = ERALIBTalent:CreateNotTalent(126017)
    local talent_sindragosa = ERALIBTalent:Create(96222)
    local talent_pof = ERALIBTalent:Create(125874)
    local talent_erw = ERALIBTalent:Create(96225)
    local talent_frostwyrm = ERALIBTalent:Create(96236)
    local talent_bonegrinder = ERALIBTalent:Create(96253)
    local talent_cryogenic = ERALIBTalent:Create(131618)
    local talent_exterminate = ERALIBTalent:Create(117665)
    local talent_frostbane = ERALIBTalent:Create(96223)
    local talent_frostreaper = ERALIBTalent:Create(96228)
    local talent_streak = ERALIBTalent:Create(96254)
    local talent_feast = ERALIBTalent:Create(123411)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local power = hud:AddPowerLowIdle(Enum.PowerType.RunicPower)
    local runes = HUDRunesData:create(hud)

    local grip = hud:AddCooldown(49576)
    local ghoul = hud:AddCooldown(46585, talents.ghoul)
    local fortitude = hud:AddCooldown(48792, talents.fortitude)
    local advance = hud:AddCooldown(48265)
    local walk = hud:AddCooldown(212552, talents.walk)
    local kick = hud:AddCooldown(47528, talents.kick)
    local vader = hud:AddCooldown(221562, talents.vader)
    local lichborne = hud:AddCooldown(49039)
    local ams = hud:AddCooldown(48707)
    local pact = hud:AddCooldown(48743, talents.pact)
    local amz = hud:AddCooldown(51052, talents.amz)
    local blind = hud:AddCooldown(207167, talents.blind)
    local icePrison = hud:AddCooldown(45524, talents.icePrison)
    local dnd = hud:AddCooldown(43265)
    local remorseless = hud:AddCooldown(196770, talent_remorseless)
    local sindragosa = hud:AddCooldown(1249658, talent_sindragosa)
    local pof = hud:AddCooldown(51271, talent_pof)
    local erw = hud:AddCooldown(47568, talent_erw)
    local frostwyrm = hud:AddCooldown(279302, talent_frostwyrm)
    local deathbringer = hud:AddCooldown(439843, talent_deathbringer)

    local bonegrinder = hud:AddAuraByPlayer(377098, false, talent_bonegrinder)
    local feast = hud:AddAuraByPlayer(440861, false, talent_feast)
    local sindraBuff = hud:AddAuraByPlayer(1249658, false, talent_sindragosa)
    local cryogenic = hud:AddAuraByPlayer(456237, false, talent_cryogenic)
    local exterminate = hud:AddAuraByPlayer(441378, false, talent_exterminate)
    local frostbane = hud:AddAuraByPlayer(455993, false, talent_frostbane)
    local frostreaper = hud:AddAuraByPlayer(1230301, false, talent_frostreaper)
    local onslaught = hud:AddAuraByPlayer(1230272, false, talent_onslaught)
    local streak = hud:AddAuraByPlayer(1230153, false, talent_streak)
    local remorselessBuff = hud:AddAuraByPlayer(1233152, false)
    local pofBuff = hud:AddAuraByPlayer(51271, false, talent_pof)
    local runeStrength = hud:AddAuraByPlayer(53365, false)
    local draw = hud:AddAuraByPlayer(374598, false, talents.draw)
    local fever = hud:AddAuraByPlayer(55095, true)
    local reapermark = hud:AddAuraByPlayer(439843, true, talent_deathbringer)
    local undeath = hud:AddAuraByPlayer(444633, true, talent_rider)
    local succor = hud:AddAuraByPlayer(178819, false)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials

    hud:AddEssentialsLeftAura(draw)

    hud:AddEssentialsLeftAura(runeStrength)

    local _, dndSlot = hud:AddEssentialsCooldown(dnd, nil, nil, 0.7, 0.0, 1.0, false)
    dndSlot:AddTimerBar(0.25, bonegrinder, nil, 1.0, 0.0, 1.0).doNotCutLongDuration = true
    dndSlot:AddTimerBar(0.75, sindraBuff, nil, 0.0, 0.0, 1.0).doNotCutLongDuration = true

    local _, remorselessSlot = hud:AddEssentialsCooldown(remorseless, nil, nil, 0.5, 0.5, 0.5, false)

    local _, pofSlot = hud:AddEssentialsCooldown(pof, nil, nil, 0.5, 0.0, 0.0)
    remorselessSlot:AddTimerBar(0.25, remorselessBuff, nil, 1.0, 1.0, 1.0)
    pofSlot:AddTimerBar(0.75, pofBuff, nil, 1.0, 0.0, 0.0).doNotCutLongDuration = true

    hud:AddEssentialsCooldown(erw, nil, nil, 0.8, 0.6, 0.0, false)

    local _, undeathSlot, undeathBar = hud:AddEssentialsAura(undeath, nil, nil, 0.3, 0.8, 0.0):ShowStacksRatherThanDuration()

    local _, reaperSlot = hud:AddEssentialsCooldown(deathbringer, nil, nil, 0.6, 0.0, 0.5, false)
    reaperSlot:AddOverlapingAura(reapermark):ShowStacksRatherThanDuration()
    reaperSlot:AddTimerBar(0.5, reapermark, nil, 0.7, 0.0, 0.6).doNotCutLongDuration = true

    hud:AddEssentialsRightAura(cryogenic):ShowStacksRatherThanDuration()

    local succorIcon = hud:AddEssentialsRightAura(succor)

    -- defensive
    hud.defensiveGroup:AddCooldown(pact)
    hud.defensiveGroup:AddCooldown(fortitude)
    hud.defensiveGroup:AddCooldown(ams)
    hud.defensiveGroup:AddCooldown(amz)
    hud.defensiveGroup:AddCooldown(lichborne)

    -- movement
    hud.movementGroup:AddCooldown(grip)
    hud.movementGroup:AddCooldown(advance)
    hud.movementGroup:AddCooldown(walk)

    -- control
    hud.controlGroup:AddCooldown(kick)
    hud:AddKickInfo(kick)
    hud.controlGroup:AddCooldown(vader)
    hud.controlGroup:AddCooldown(blind)
    hud.controlGroup:AddCooldown(icePrison)

    -- powerboost
    hud.powerboostGroup:AddCooldown(frostwyrm)
    hud.powerboostGroup:AddCooldown(sindragosa)
    hud.powerboostGroup:AddCooldown(ghoul)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    succor.playSoundWhenApperars = SOUNDKIT.UI_PERSONAL_LOOT_BANNER
    draw.playSoundWhenApperars = SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST
    hud:AddMissingAuraOverlayAlert(fever, nil, "icons_64x64_disease", true, false, "NONE", "CENTER").showOnlyWhenInCombatWithEnemyTarget = true
    hud:AddAuraOverlayAlert(frostbane, nil, "CovenantChoice-Celebration-Kyrian-DetailLine", true, "NONE", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local runesDisplay = hud:AddResourceSlot(false):AddRunes(runes)
    function runesDisplay:RunesUpdated()
        if (feast.auraIsActive) then
            self:SetBorderColor(1.0, 0.0, 0.0)
        else
            self:SetBorderColor(1.0, 1.0, 1.0)
        end
    end

    local powerBar = hud:AddResourceSlot(false):AddPowerValue(power, 0.2, 0.7, 1.0)
    local tick = powerBar:AddTick(237520, nil, function()
        local infoTable = C_Spell.GetSpellPowerCost(49143)
        if (infoTable) then
            for _, info in ipairs(infoTable) do
                if (info.type == Enum.PowerType.RunicPower) then
                    return info.cost
                end
            end
        end
        return 35
    end)
    tick.continuouslyCheckValue = true
    local tickSindra = powerBar:AddTick(1029007, talent_sindragosa, function() return 60 end)
    function tickSindra:OverrideAlpha()
        ---@diagnostic disable-next-line: return-type-mismatch
        return sindragosa.cooldownDuration:EvaluateRemainingDuration(hud.curveShowSoonAvailable)
    end

    --#endregion
    --------------------------------
end

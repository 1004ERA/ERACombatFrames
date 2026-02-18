---@param cFrame ERACombatMainFrame
function ERACombatFrames_PaladinSetup(cFrame)
    ---@class PaladinTalents
    local talents = {
        how = ERALIBTalent:Create(133481),
        loh = ERALIBTalent:Create(102583),
        dispell = ERALIBTalent:Create(102476),
        blinding = ERALIBTalent:Create(102584),
        turn = ERALIBTalent:Create(102623),
        steed = ERALIBTalent:Create(102625),
        greaterj = ERALIBTalent:Create(102590),
        bof = ERALIBTalent:Create(128251),
        sacri = ERALIBTalent:Create(102602),
        resonance = ERALIBTalent:Create(115468),
        bop = ERALIBTalent:Create(102604),
        purpose = ERALIBTalent:Create(128243),
    }
    ERACombatFrames_Paladin_Holy(cFrame, talents)
    ERACombatFrames_Paladin_Protection(cFrame, talents)
    ERACombatFrames_Paladin_Retribution(cFrame, talents)
end

---@param cFrame ERACombatMainFrame
---@param hud HUDModule
---@param talents PaladinTalents
---@param talent_kick ERALIBTalent|nil
---@param isHoly boolean
---@return PaladinCommonSpells
function ERACombatFrames_PaladinCommonSpells(cFrame, hud, talents, talent_kick, isHoly)
    local holyPower = hud:AddPowerLowIdle(Enum.PowerType.HolyPower)
    ---@class PaladinCommonSpells
    local commonSpells = {
        bof = hud:AddCooldown(1044, talents.bof),
        bop = hud:AddCooldown(1022, talents.bop),
        sacri = hud:AddCooldown(6940, talents.sacri),
        blind = hud:AddCooldown(115750, talents.blinding),
        steed = hud:AddCooldown(190784, talents.steed),
        loh = hud:AddCooldown(633, talents.loh),
        turn = hud:AddCooldown(10326, talents.turn),
        kick = hud:AddCooldown(96231, talent_kick),
        bubble = hud:AddCooldown(642),
        stun = hud:AddCooldown(853),
        judgment = hud:AddCooldown(20271),
        --greaterj = hud:AddAuraByPlayer(231663, true, talents.greaterj),
        holyPower = holyPower,
        powerPoints = hud:AddResourceSlot(false):AddPowerPoints(holyPower, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, function() return 0 end)
    }

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.loh)
    hud.defensiveGroup:AddCooldown(commonSpells.bubble)
    hud.defensiveGroup:AddCooldown(commonSpells.bop)
    hud.defensiveGroup:AddCooldown(commonSpells.sacri)

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.steed)
    hud.movementGroup:AddCooldown(commonSpells.bof)

    -- special
    if (not isHoly) then
        hud.specialGroup:AddCooldown(hud:AddCooldown(213644, ERALIBTalent:Create(102476)))
    end

    -- control
    if (not isHoly) then
        hud.controlGroup:AddCooldown(commonSpells.kick)
        hud:AddKickInfo(commonSpells.kick)
    end
    hud.controlGroup:AddCooldown(commonSpells.stun)
    hud.controlGroup:AddCooldown(commonSpells.blind)
    hud.controlGroup:AddCooldown(commonSpells.turn)

    -- powerboost

    -- alert

    return commonSpells
end

---@param hud HUDModule
---@param talents PaladinTalents
---@param spells PaladinCommonSpells
---@param howID integer
---@param mainWrath HUDAura
---@param secondaryWrath HUDAura|nil
---@param hideCountdown boolean
function ERACombatFrames_PaladinJudgment(hud, talents, spells, howID, mainWrath, secondaryWrath, hideCountdown)
    local hasMainWrath = hud:AddAuraBoolean(mainWrath)
    local hasAnyWrath, hasNeitherWrath
    if (secondaryWrath) then
        local hasSecondaryWrath = hud:AddAuraBoolean(secondaryWrath)
        hasAnyWrath = hud:AddPublicBooleanOr(hasMainWrath, hasSecondaryWrath)
        hasNeitherWrath = hud:AddPublicBooleanOr(hasMainWrath, hasSecondaryWrath)
    else
        hasAnyWrath = hasMainWrath
        hasNeitherWrath = hud:AddAuraBoolean(mainWrath)
    end
    hasNeitherWrath.reverse = true

    local jIcon, jSlot, jBar = hud:AddEssentialsCooldown(spells.judgment, nil, nil, 0.7, 0.7, 0.5)
    jIcon.showOnlyIf = hasNeitherWrath
    jBar.showOnlyIf = hasNeitherWrath
    local how = hud:AddCooldown(howID, talents.how)
    local howIcon = jSlot:AddOverlapingCooldown(how)
    howIcon.showOnlyIf = hasAnyWrath
    jSlot:AddTimerBar(0.5, how, nil, 0.7, 0.7, 0.5).showOnlyIf = hasAnyWrath
    if (hideCountdown) then
        jIcon:HideCountdown()
        howIcon:HideCountdown()
    end

    jSlot:AddTimerBar(0.75, mainWrath, nil, 1.0, 0.0, 1.0).doNotCutLongDuration = true
    if (secondaryWrath) then
        jSlot:AddTimerBar(0.75, secondaryWrath, nil, 1.0, 0.0, 1.0).doNotCutLongDuration = true
    end
end

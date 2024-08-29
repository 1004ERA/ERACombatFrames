---@class MonkCommonTimerIconParams
---@field kickX number
---@field kickY number
---@field paraX number
---@field paraY number
---@field todX number
---@field todY number
---@field todPrio number

---@class MonkCommonTalents
---@field diffuse ERALIBTalent
---@field fortify ERALIBTalent
---@field clash ERALIBTalent
---@field lust ERALIBTalent
---@field transcendence ERALIBTalent
---@field torpedo ERALIBTalent
---@field roll ERALIBTalent
---@field paralysis ERALIBTalent
---@field disenrage ERALIBTalent
---@field rop ERALIBTalent
---@field sleep ERALIBTalent
---@field detox ERALIBTalent
---@field kick ERALIBTalent
---@field vivification ERALIBTalent
---@field healingTaken4 ERALIBTalent
---@field healingDone2 ERALIBTalent
---@field vivify_30pct ERALIBTalent
---@field strongEH ERALIBTalent
---@field scalingEH ERALIBTalent

function ERACombatFrames_MonkSetup(cFrame)
    cFrame.hideAlertsForSpec = { 1 }

    ERACombatGlobals_SpecID1 = 268
    ERACombatGlobals_SpecID2 = 270
    ERACombatGlobals_SpecID3 = 269

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mwActive = ERACombatOptions_IsSpecActive(2)
    local wwActive = ERACombatOptions_IsSpecActive(3)

    ---@type MonkCommonTalents
    local monkTalents = {
        diffuse = ERALIBTalent:Create(124959),
        fortify = ERALIBTalent:Create(124968),
        clash = ERALIBTalent:Create(124945),
        lust = ERALIBTalent:Create(124937),
        transcendence = ERALIBTalent:Create(124962),
        torpedo = ERALIBTalent:Create(124981),
        roll = ERALIBTalent:CreateNotTalent(124981),
        paralysis = ERALIBTalent:Create(124932),
        disenrage = ERALIBTalent:Create(124931),
        rop = ERALIBTalent:Create(124926),
        sleep = ERALIBTalent:Create(124925),
        detox = ERALIBTalent:Create(124941),
        kick = ERALIBTalent:Create(124943),
        vivification = ERALIBTalent:Create(124935),
        healingDone2 = ERALIBTalent:Create(124964),
        healingTaken4 = ERALIBTalent:Create(124936),
        vivify_30pct = ERALIBTalent:Create(125076),
        strongEH = ERALIBTalent:Create(124948),
        scalingEH = ERALIBTalent:Create(124924)
    }

    local enemies = ERACombatEnemies:Create(cFrame, 1, 3)

    if (bmActive) then
        ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, monkTalents)
    end
    if (mwActive) then
        ERACombatFrames_MonkMistweaverSetup(cFrame, monkTalents)
    end
    if (wwActive) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, monkTalents)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

---comment
---@param cFrame any
---@param spec number
---@param includeDetox boolean
---@param monkTalents MonkCommonTalents
---@return ERACombatUtilityFrame
function ERACombatFrames_MonkUtility(cFrame, spec, includeDetox, monkTalents)
    local utility = ERACombatUtilityFrame:Create(cFrame, -16, -212, spec)

    utility:AddCooldown(-4, 0, 322109, nil, false) -- touch of death
    utility:AddWarlockHealthStone(0.5, -0.9)

    utility:AddTrinket2Cooldown(-3, 0, nil)
    utility:AddTrinket1Cooldown(-2, 0, nil)
    utility:AddCooldown(1, 0, 122783, nil, true, monkTalents.diffuse)
    utility:AddCooldown(2, 0, 115203, nil, true, monkTalents.fortify)
    utility:AddBeltCooldown(3, 0, nil)
    utility:AddCloakCooldown(4, 0, nil)

    utility:AddRacial(3, 1)
    utility:AddCooldown(4, 1, 115078, nil, true, monkTalents.paralysis)

    utility:AddCooldown(3, 2, 119381, nil, true) -- sweep
    utility:AddCooldown(4, 2, 116844, nil, true, monkTalents.rop)
    utility:AddCooldown(4, 2, 198898, nil, true, monkTalents.sleep)

    utility:AddCooldown(3, 3, 324312, nil, true, monkTalents.clash)
    utility:AddCooldown(4, 3, 119996, nil, true, monkTalents.transcendence)
    utility:AddCooldown(5, 3, 101643, nil, true, monkTalents.transcendence).alphaWhenOffCooldown = 0.1

    utility:AddCooldown(3, 4, 109132, 574574, true, monkTalents.roll)
    utility:AddCooldown(3, 4, 115008, 607849, true, monkTalents.torpedo)
    utility:AddCooldown(4, 4, 116841, nil, true, monkTalents.lust)

    if (includeDetox) then
        utility:AddDefensiveDispellCooldown(3, 5, 218164, nil, monkTalents.detox, "poison", "disease")
    end
    utility:AddCooldown(4, 5, 115546, nil, true).alphaWhenOffCooldown = 0.2
    utility:AddWarlockPortal(5, 5)


    return utility
end

---comment
---@param timers ERACombatTimers
---@param talents MonkCommonTalents
---@param timerParams MonkCommonTimerIconParams
function ERACombatFrames_MonkTimerBars(timers, talents, timerParams)
    timers:AddChannelInfo(115175, 1.0) -- soothing mist
    timers:AddChannelInfo(117952, 1.0) -- crackling jade lightning

    timers:AddAuraBar(timers:AddTrackedBuff(122783, talents.diffuse), nil, 0.7, 0.6, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(120954, talents.fortify), nil, 0.8, 0.8, 0.0)

    timers:AddKick(116705, timerParams.kickX, timerParams.kickY, talents.kick, false)
    timers:AddOffensiveDispellIcon(629534, timerParams.paraX, timerParams.paraX, true, talents.disenrage, "enrage")

    local tod = timers:AddCooldownIcon(timers:AddTrackedCooldown(322109), nil, timerParams.todX, timerParams.todY, true, true)
    function tod:ComputeAvailablePriorityOverride()
        local u, nomana = C_Spell.IsSpellUsable(322109)
        if (u or nomana) then
            return timerParams.todPrio
        else
            return 0
        end
    end
end

-- recurring

ERACombatFrames_MonkRecurringIcon = {}
ERACombatFrames_MonkRecurringIcon.__index = ERACombatFrames_MonkRecurringIcon
setmetatable(ERACombatFrames_MonkRecurringIcon, { __index = ERACombatTimerIcon })

function ERACombatFrames_MonkRecurringIcon:create(group, iconID, talent, buffAlready)
    local i = {}
    setmetatable(i, ERACombatFrames_MonkRecurringIcon)
    i.iconID = iconID
    i:construct(group, 0, 0, iconID, true)
    i.talent = talent
    i.buffAlready = buffAlready
    return i
end

function ERACombatFrames_MonkRecurringIcon:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        self.talentActive = true
        return true
    else
        self:hide()
        self.talentActive = false
        return false
    end
end

function ERACombatFrames_MonkRecurringIcon:updateIconCooldownTexture()
    return self.iconID
end

function ERACombatFrames_MonkRecurringIcon:updateAfterReset(t)
    self:updateIconCooldownTexture()
end

function ERACombatFrames_MonkRecurringIcon:updateTimerDurationAndMainIconVisibility(t, timerStandardDuration)
    self.shouldShowMainIcon = false
    local last, dur = self:getLastAndDuration()
    if (last > 0) then
        local elapsed = t - last
        self.timerDuration = dur - (elapsed - dur * math.floor(elapsed / dur))
        if (self.buffAlready) then
            self.iconTimer:SetDesaturated(self.buffAlready.remDuration <= 0)
        end
    else
        self.timerDuration = -1
    end
end
function ERACombatFrames_MonkRecurringIcon:getLastAndDuration()
    return 0, 1
end

function ERACombatFrames_MonkRecurringIcon_instaVivify(timers, talent, instaVivifyTimer)
    local i = ERACombatFrames_MonkRecurringIcon:create(timers, 1360980, talent, instaVivifyTimer)
    function i:getLastAndDuration()
        return self.group.lastInstaVivify, 10
    end
end

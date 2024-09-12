---@class ERACombatTimers_MonkWindwalker : ERACombatTimers
---@field offsetIconsX number
---@field offsetIconsY number
---@field lastInstaVivify number
---@field spinningSlot number
---@field nrg ERACombatPower
---@field combatHealth ERACombatHealth

---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkWindwalkerSetup_OLD(cFrame, enemies, monkTalents)
    local talent_whirling = ERALIBTalent:Create(125011)
    local talent_not_whirling = ERALIBTalent:CreateNotTalent(125011)
    local talent_windlord = ERALIBTalent:Create(125022)
    local talent_fae_active = ERALIBTalent:Create(126026)
    local talent_fae_passive = ERALIBTalent:Create(124816)
    local talent_fae_any = ERALIBTalent:CreateOr(talent_fae_active, talent_fae_passive)
    local talent_chib = ERALIBTalent:Create(124952)
    local talent_sef = ERALIBTalent:Create(124826)
    local talent_inner_peace = ERALIBTalent:Create(125021)
    local talent_capacitor = ERALIBTalent:Create(124832)
    local talent_spinning_ignition = ERALIBTalent:Create(124822)
    local talent_combat_wisdom = ERALIBTalent:Create(125025)

    local htalent_conduit = ERALIBTalent:Create(125062)

    local points = ERACombatPointsUnitPower:Create(cFrame, -101, 6, 12, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil, 2, 3)
    points:SetTalented(2, talent_combat_wisdom)

    local nrg = ERACombatPower:Create(cFrame, -161, -6, 121, 16, 3, false, 1.0, 1.0, 0.0, 3)
    local tigerPalmConsumer60 = nrg:AddConsumer(60, 606551, ERALIBTalent:CreateNot(talent_inner_peace))
    local tigerPalmConsumer55 = nrg:AddConsumer(55, 606551, talent_inner_peace)

    local combatHealth = ERACombatHealth:Create(cFrame, 0, -77, 144, 22, 3)
    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 22, 3, true, 1, 1, 0, 0, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 32, 1, true, false, 3)
    ---@cast timers ERACombatTimers_MonkWindwalker
    timers.offsetIconsX = -32
    timers.offsetIconsY = -22
    local first_column_X = 0.5

    timers.combatHealth = combatHealth
    timers.nrg = nrg

    ---@type MonkCommonTimerIconParams
    local timerParams = {
        kickX = first_column_X + 1,
        kickY = 1,
        paraX = first_column_X + 1,
        paraY = 2,
        todPrio = 1,
        todX = -3.5,
        todY = -0.9
    }

    ERACombatFrames_MonkTimerBars(timers, monkTalents, timerParams)

    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED") then
            if (spellID == 392883) then
                self.lastInstaVivify = t
            end
        end
    end

    function timers:OnResetToIdle()
        self.spinningSlot = ERALIB_GetSpellSlot(101546)
        self.lastInstaVivify = 0
    end

    local rskCooldown = timers:AddTrackedCooldown(107428)
    local rskIcon = timers:AddCooldownIcon(rskCooldown, nil, -1, 0, true, true)
    local fofCooldown = timers:AddTrackedCooldown(113656)
    local fofIcon = timers:AddCooldownIcon(fofCooldown, nil, -2, 0, true, true)
    local whirlingCooldown = timers:AddTrackedCooldown(152175, talent_whirling)
    local whirlingIcon = timers:AddCooldownIcon(whirlingCooldown, nil, -3, 0, true, true)

    local chibIcon = timers:AddAuraIcon(timers:AddTrackedBuff(460490, talent_chib), 0, 0, nil, talent_chib)
    function chibIcon:ShouldShowWhenAbsentOverride()
        return false
    end
    chibIcon.icon:Highlight()

    local faeCooldown = timers:AddTrackedCooldown(388193, talent_fae_active)
    local faeIcon = timers:AddCooldownIcon(faeCooldown, nil, -1.5, -0.9, true, true, talent_fae_active)

    local windlordCooldown = timers:AddTrackedCooldown(392983, talent_windlord)
    local windlordIcons = {}
    table.insert(windlordIcons, timers:AddCooldownIcon(windlordCooldown, nil, -1.5, -0.9, true, true, ERALIBTalent:CreateNot(talent_fae_active)))
    table.insert(windlordIcons, timers:AddCooldownIcon(windlordCooldown, nil, -2.5, -0.9, true, true, talent_fae_active))

    --[[
    local morechiTimer = timers:AddTrackedBuff(129914, talent_power_strikes)
    function points:PointsUpdated(t)
        if (timers.cFrame.inCombat) then
            local incr
            if (morechiTimer.remDuration > timers.remGCD) then
                self:SetBorderColor(0.5, 0.0, 1.0)
                incr = 3
            else
                self:SetBorderColor(1.0, 1.0, 0.0)
                incr = 2
            end
            if (self.currentPoints + incr > self.maxPoints) then
                self:SetPointColor(1.0, 0.5, 0.0)
            else
                self:SetPointColor(0.0, 1.0, 0.5)
            end
        else
            self:SetBorderColor(1.0, 1.0, 0.0)
            self:SetPointColor(0.0, 1.0, 0.5)
        end
    end
    ]] --

    local instaVivifyTimer = timers:AddTrackedBuff(392883, monkTalents.vivification)
    --ERACombatFrames_MonkRecurringIcon_instaVivify(timers, monkTalents.vivification, instaVivifyTimer)
    --[[
    local powerStrikesTimer = ERACombatFrames_MonkRecurringIcon:create(timers, 629484, talent_power_strikes, morechiTimer)
    function powerStrikesTimer:getLastAndDuration()
        return self.group.lastPowerStrikes, 15
    end
    ]] --

    local spinningIcon = ERACombatTimersMonkSpinningIcon:create(timers, first_column_X, 1)
    local spinningBuff = timers:AddTrackedBuff(325202, ERALIBTalent:Create(124834))
    local spinningIgnition = timers:AddTrackedBuff(393057, talent_spinning_ignition)

    timers:AddStacksProgressIcon(spinningIgnition, nil, first_column_X, 2, 30, talent_spinning_ignition)
    local capacitorBuff = timers:AddTrackedBuff(393039, talent_capacitor)
    timers:AddStacksProgressIcon(capacitorBuff, nil, first_column_X, 3, 20, talent_capacitor)
    timers:AddKick(116705, first_column_X + 1, 3, ERALIBTalent:Create(101504))

    local faexposureTimer = timers:AddTrackedDebuff(395414, talent_fae_any)
    timers:AddAuraBar(faexposureTimer, 3528275, 0.7, 0.0, 1.0)

    timers:AddAuraBar(timers:AddTrackedBuff(116768), nil, 0.7, 0.0, 0.1) -- free BoK
    timers:AddAuraBar(timers:AddTrackedBuff(125174), nil, 1.0, 1.0, 1.0) -- karma ?
    timers:AddAuraBar(timers:AddTrackedBuff(137639, talent_sef), nil, 1.0, 0.0, 1.0)
    timers:AddAuraBar(spinningBuff, 606543, 0.0, 0.8, 0.2)
    local ignitionBar = timers:AddAuraBar(spinningIgnition, 988193, 0.5, 1.0, 0.2)
    function ignitionBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (self.aura.remDuration < 6) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    function timers:DataUpdatedOverride(t)
        if (instaVivifyTimer.remDuration > 0 and self.nrg.currentPower >= 8) then
            self.nrg.bar:SetBorderColor(0.0, 1.0, 0.0)
            local mult = 1.4 * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
            mult = mult * (1 + monkTalents.healingDone2.rank * 0.02)
            mult = mult * (1 + monkTalents.healingTaken4.rank * 0.04)
            mult = mult * (1 + monkTalents.vivify_30pct.rank * 0.3)
            self.combatHealth:SetHealing(6 * GetSpellBonusHealing() * mult)
        else
            self.nrg.bar:SetBorderColor(1.0, 1.0, 1.0)
            self.combatHealth:SetHealing(0)
        end
    end

    local utility = ERACombatFrames_MonkUtility(cFrame, 3, true, monkTalents)
    utility:AddCooldown(5, 4, 101545, nil, true)                                   -- fsk
    utility:AddCooldown(-1.5, 0.9, 443028, nil, true, htalent_conduit)
    utility:AddCooldown(-2.5, 0.9, 123904, nil, true, ERALIBTalent:Create(125013)) -- xuen
    utility:AddCooldown(-3.5, 0.9, 137639, nil, true, talent_sef)
    utility:AddCooldown(-1, 0, 122470, nil, true)                                  -- karma

    -- out of combat
    utility:AddCooldown(-3, 2, 388193, nil, false, talent_fae_active)
    utility:AddCooldown(-4, 2, 392983, nil, false, talent_windlord)
    utility:AddCooldown(-2, 3, 107428, nil, false) -- rsk
    utility:AddCooldown(-3, 3, 113656, nil, false) -- fof
    utility:AddCooldown(-4, 3, 152175, nil, false, talent_whirling)

    --[[

    PRIO

    1 - touch of death
    2 - palm refill 2 chi
    3 - rsk
    4 - fae exposure
    X - palm dump
    6 - fof
    7 - windlord
    8 - whirling
    9 - CJL
    10 - sck
    11 : chi burst

    ]]

    local tigerDump = timers:AddPriority(606551)
    function tigerDump:ComputePriority(t)
        if (nrg.currentPower >= 50 and points.currentPoints < 2) then
            return 2
        else
            if (nrg.maxPower - nrg.currentPower < 20 and points.maxPoints - points.currentPoints >= 2) then
                return 5
            else
                return 0
            end
        end
    end

    function rskIcon:ComputeAvailablePriorityOverride()
        return 3
    end

    function faeIcon:ComputeAvailablePriorityOverride()
        return 4
    end

    function fofIcon:ComputeAvailablePriorityOverride()
        return 6
    end

    for _, i in ipairs(windlordIcons) do
        function i:ComputeAvailablePriorityOverride()
            return 7
        end
    end

    function whirlingIcon:ComputeAvailablePriorityOverride()
        if C_Spell.IsSpellUsable(self.cd.spellID) then
            self.iconTimer:SetDesaturated(false)
        else
            self.iconTimer:SetDesaturated(true)
        end
        return 8
    end

    local cjlPrio = timers:AddPriority(606542)
    function cjlPrio:ComputePriority(t)
        if (capacitorBuff.stacks >= 20) then
            return 9
        else
            return 0
        end
    end

    local sckPrio = timers:AddPriority(606543)
    function sckPrio:ComputePriority(t)
        if ((spinningBuff.remDuration > timers.occupied and spinningBuff.remDuration <= 6) or (spinningIgnition.remDuration > timers.occupied and spinningIgnition.remDuration <= 6)) then
            return 10
        else
            return 0
        end
    end

    local chibPrio = timers:AddPriority(135734)
    function chibPrio:ComputePriority()
        if (chibIcon.aura.remDuration > 0) then
            return 11
        else
            return 0
        end
    end
end

ERACombatTimersMonkSpinningIcon = {}
ERACombatTimersMonkSpinningIcon.__index = ERACombatTimersMonkSpinningIcon
setmetatable(ERACombatTimersMonkSpinningIcon, { __index = ERACombatTimersHintProgressIcon })

function ERACombatTimersMonkSpinningIcon:create(group, x, y)
    local pr = {}
    setmetatable(pr, ERACombatTimersMonkSpinningIcon)
    pr.stacks = 0
    pr:constructProgress(group, 606543, x, y)
    return pr
end

function ERACombatTimersMonkSpinningIcon:ComputeIsVisibleOverride(t)
    local slot = self.group.spinningSlot
    if (slot and slot > 0) then
        local s = GetActionCount(slot)
        if (s and s > 0) then
            if (s > 1) then
                if (self.stacks ~= s) then
                    self.stacks = s
                    self.icon:SetMainText(self.stacks)
                end
                self.icon:SetOverlayValue((5 - s) / 5)
                return true
            else
                self.stacks = 1
                return false
            end
        else
            self.stacks = 0
            return false
        end
    else
        self.stacks = 0
        return false
    end
end

function ERACombatTimersMonkSpinningIcon:talentIncactive()
    self.stacks = 0
end

---@class ERACombatGridMonkParams
---@field vivifyHealing number
---@field invigoratingStandardHealing number
---@field invigoratingPredictedHealing number

---@class ERACombatGrid_MonkMistweaver : ERACombatGrid
---@field monkParams ERACombatGridMonkParams

---@class ERACombatTimers_MonkMistweaver : ERACombatTimers
---@field offsetIconsX number
---@field offsetIconsY number
---@field lastInstaVivify number
---@field lastInvoke number
---@field sheilunSlot number
---@field sheilunStacks number
---@field lastSheilunGain number

---comment
---@param s1 MonkMistweaverInvigoratingStep
---@param s2 MonkMistweaverInvigoratingStep
---@return boolean
function ERAMonkMistweaver_SortInvigoratingSteps(s1, s2)
    return s1.value < s2.value
end

---comment
---@param cFrame any
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkMistweaverSetup_OLD(cFrame, monkTalents)
    local talent_rsk = ERALIBTalent:Create(124984)
    local talent_renewing = ERALIBTalent:Create(124888)
    local talent_invigorating = ERALIBTalent:Create(124891)
    local talent_zenpulse = ERALIBTalent:Create(124889)
    local talent_fae = ERALIBTalent:Create(124881)
    local talent_chib = ERALIBTalent:Create(126499)
    local talent_tft = ERALIBTalent:Create(124921)
    local talent_manatea = ERALIBTalent:Create(124920)
    local talent_not_manatea = ERALIBTalent:CreateNotTalent(124920)
    local talent_yulon = ERALIBTalent:Create(124915)
    local talent_chiji = ERALIBTalent:Create(124914)
    local talent_chiji_sck = ERALIBTalent:Create(124887)
    local talent_short_invoke = ERALIBTalent:Create(124894)
    local talent_revival = ERALIBTalent:Create(124919)
    local talent_restoral = ERALIBTalent:Create(124918)
    local talent_sheilun = ERALIBTalent:Create(124904)
    local talent_sheilun_shaohao = ERALIBTalent:Create(124902)
    local talent_fast_sheilun = ERALIBTalent:Create(124903)
    local talent_cocoon = ERALIBTalent:Create(124875)
    local talent_stronger_invigorating_10pct = ERALIBTalent:Create(124900)
    local talent_ancient_teachings = ERALIBTalent:Create(124882)
    local talent_ancient_concordance = ERALIBTalent:Create(124886)
    local talent_normal_detox = ERALIBTalent:CreateNotTalent(124866)
    local talent_better_detox = ERALIBTalent:Create(124866)

    local htalent_conduit = ERALIBTalent:Create(125062)
    local htalent_blackox = ERALIBTalent:Create(125060)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -44, 1.5, true, true, 2)
    ---@cast timers ERACombatTimers_MonkMistweaver
    timers.offsetIconsX = -32
    timers.offsetIconsY = -93
    local first_column_X = 0.5
    local first_column_X_delta = -0.1
    local first_column_Y = 2

    ---@type MonkCommonTimerIconParams
    local timerParams = {
        kickX = first_column_X + 1,
        kickY = first_column_Y + 3,
        paraX = first_column_X + 1,
        paraY = first_column_Y + 4,
        todPrio = 1,
        todX = first_column_X,
        todY = first_column_Y - 1
    }

    ERACombatFrames_MonkTimerBars(timers, monkTalents, timerParams)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 22, 0, true, 0.0, 0.0, 1.0, 0, 2)

    local health = ERACombatHealth:Create(cFrame, 0, -111, 144, 20, 2)
    local mana = ERACombatPower:Create(cFrame, 0, -131, 144, 16, 0, false, 0.0, 0.0, 1.0, 2)

    --local sheilunBar = ERACombatFrames_MonkSheilunBar:create(cFrame, -72, -104, 144, 8, health, timers, talent_sheilun, monkTalents)

    local grid = ERACombatGrid:Create(cFrame, -151, -16, "BOTTOMRIGHT", 2, 115450, "Magic", "Poison", "Disease")
    ---@cast grid ERACombatGrid_MonkMistweaver
    grid.monkParams = {
        vivifyHealing = 0,
        invigoratingStandardHealing = 0,
        invigoratingPredictedHealing = 0
    }

    timers:AddAuraBar(timers:AddTrackedBuff(197908, talent_manatea), nil, 0.2, 0.2, 1.0)
    ERACombatTimerMonkInvokeBar:create(timers, 574571, 0.0, 1.0, 0.2, talent_yulon, talent_short_invoke)
    ERACombatTimerMonkInvokeBar:create(timers, 877514, 1.0, 0.2, 0.0, talent_chiji, talent_short_invoke)

    timers.sheilunSlot = -1
    timers.sheilunStacks = 0
    timers.lastSheilunGain = 0

    local instaVivifyTimer = timers:AddTrackedBuff(392883, monkTalents.vivification)
    ERACombatFrames_MonkRecurringIcon_instaVivify(timers, monkTalents.vivification, instaVivifyTimer)

    timers:AddKick(116705, first_column_X + 1.8, first_column_Y + 3, ERALIBTalent:Create(101504))

    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, first_column_X, first_column_Y + 1, true, true)

    local renewingCooldown = timers:AddTrackedCooldown(115151, talent_renewing)
    local renewingIcon = timers:AddCooldownIcon(renewingCooldown, nil, first_column_X, first_column_Y + 2, true, true)

    local faeCooldown = timers:AddTrackedCooldown(388193, talent_fae)
    local faeIcon = timers:AddCooldownIcon(faeCooldown, nil, first_column_X, first_column_Y + 3, true, true)

    ERACombatFrames_MonkSheilunIcon:create(timers, first_column_X, first_column_Y + 5, talent_sheilun, talent_fast_sheilun)

    timers:AddStacksProgressIcon(timers:AddTrackedBuff(115867, talent_manatea), nil, first_column_X + 0.9, first_column_Y + 4.5, 20)

    local ehCooldown = timers:AddTrackedCooldown(322101)
    local ehIcon = timers:AddCooldownIcon(ehCooldown, nil, first_column_X, first_column_Y, true, true)

    timers:AddProc(timers:AddTrackedBuff(392883, monkTalents.vivification), nil, first_column_X + 1, first_column_Y + 0.5, false, false)

    local tftBuff = timers:AddTrackedBuff(116680, talent_tft)
    local tftCooldown = timers:AddTrackedCooldown(116680, talent_tft)
    local tftIcon = timers:AddCooldownIcon(tftCooldown, nil, first_column_X, first_column_Y + 4, true, true)
    function tftIcon:HighlightOverride(t)
        if (tftBuff.remDuration > self.group.occupied) then
            self.icon:Highlight()
        else
            self.icon:StopHighlight()
        end
        return true
    end

    local instaRenewingChijiTimer = timers:AddTrackedBuff(343820, talent_chiji)
    timers:AddStacksProgressIcon(instaRenewingChijiTimer, 877514, first_column_X + 1.9, first_column_Y + 0.5, 3, talent_chiji).highlightWhenFull = true

    local selfRenewingBar = timers:AddAuraBar(timers:AddTrackedBuff(119611, talent_renewing), nil, 0.0, 1.0, 0.0)
    function selfRenewingBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local selfEnvelopingBar = timers:AddAuraBar(timers:AddTrackedBuff(124682), nil, 0.6, 0.7, 0.0)
    function selfEnvelopingBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    timers:AddAuraBar(timers:AddTrackedBuff(388026, talent_ancient_teachings), nil, 1.0, 0.2, 0.8)
    --timers:AddAuraBar(timers:AddTrackedBuff(389391, talent_ancient_concordance), 3528275, 0.2, 0.1, 0.8)
    timers:AddAuraBar(timers:AddTrackedBuff(443112, htalent_blackox), nil, 0.5, 0.6, 0.0)
    timers:AddAuraBar(timers:AddTrackedBuff(438443, talent_chiji_sck), 606543, 0.8, 1.0, 0.5)

    -- anger
    timers:AddProc(timers:AddTrackedBuff(405807, talent_sheilun_shaohao), nil, first_column_X, first_column_Y + 6, false, false)
    timers:AddAuraBar(timers:AddTrackedBuff(400106, talent_sheilun_shaohao), nil, 0.6, 0.0, 0.0)
    -- doubt
    timers:AddProc(timers:AddTrackedBuff(405808, talent_sheilun_shaohao), nil, first_column_X, first_column_Y + 6, false, false)
    timers:AddAuraBar(timers:AddTrackedBuff(400097, talent_sheilun_shaohao), nil, 0.0, 0.3, 0.2)
    -- despair
    timers:AddProc(timers:AddTrackedBuff(405810, talent_sheilun_shaohao), nil, first_column_X, first_column_Y + 6, false, false)
    timers:AddAuraBar(timers:AddTrackedBuff(400100, talent_sheilun_shaohao), nil, 0.5, 0.6, 0.8)
    -- fear
    timers:AddProc(timers:AddTrackedBuff(405809, talent_sheilun_shaohao), nil, first_column_X, first_column_Y + 6, false, false)
    timers:AddAuraBar(timers:AddTrackedBuff(400103, talent_sheilun_shaohao), nil, 0.7, 0.0, 0.5)


    timers.lastInvoke = 0
    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID) then
            if (evt == "SPELL_AURA_APPLIED") then
                if (spellID == 392883) then
                    self.lastInstaVivify = t
                end
            elseif (evt == "SPELL_CAST_SUCCESS" and (spellID == 322118 or spellID == 325197)) then
                self.lastInvoke = t
            end
        end
    end

    function timers:PreUpdateCombatOverride(t)
        if (self.sheilunSlot and self.sheilunSlot > 0) then
            local s = GetActionCount(self.sheilunSlot)
            if (self.sheilunStacks < s) then
                self.lastSheilunGain = t
            end
            self.sheilunStacks = s
        else
            self.sheilunStacks = 0
        end
    end

    function timers:OnResetToIdle()
        self.lastInstaVivify = 0
        self.sheilunSlot = ERALIB_GetSpellSlot(399491)
    end

    local rskIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(107428, talent_rsk), nil, 0, 0, true, true)
    function rskIcon:ShouldShowMainIconOverride()
        return false
    end
    function rskIcon:ComputeAvailablePriorityOverride()
        return 2
    end

    function tftIcon:ComputeAvailablePriorityOverride()
        return 3
    end

    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    local renewingDef = grid:AddTrackedBuff(119611, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, talent_renewing)
    local envelopingDef = grid:AddTrackedBuff(124682, 1, 1, 0.6, 0.7, 0.0, 0.6, 0.7, 0.0, nil)
    local cocoonDef = grid:AddTrackedBuff(116849, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, talent_cocoon)

    ---@type MonkMistweaverInvigoratingStep[]
    local invigoratingSteps = {}
    for i = 1, 6 do
        table.insert(invigoratingSteps, {})
    end

    function grid:UpdatedInCombatOverride(t)
        local baseH = GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100) * (1 + monkTalents.healingDone2.rank * 0.02)
        local crit = GetCritChance() / 100
        local nocrit = 1 - crit
        local minDur
        if (instaVivifyTimer.remDuration > 0) then
            minDur = timers.occupied
        else
            minDur = timers.occupied + 1.5 / timers.haste
        end

        local targetsCount = 0
        for _, i in ipairs(renewingDef.instances) do
            if (i.remDuration > minDur) then
                targetsCount = targetsCount + 1
            end
        end

        local invigoratingH
        if (targetsCount > 5) then
            invigoratingH = 1.2 * baseH * (4 + math.sqrt(targetsCount - 4))
        else
            invigoratingH = 1.2 * baseH
        end
        if (talent_stronger_invigorating_10pct:PlayerHasTalent()) then
            invigoratingH = invigoratingH * 1.1
        end

        local pulseH
        if (talent_zenpulse:PlayerHasTalent()) then
            pulseH = 1.5 * baseH
        else
            pulseH = 0
        end
        local pulseChance = 0.06 * targetsCount

        invigoratingSteps[1].chance = nocrit * (1 - pulseChance)
        invigoratingSteps[1].value = invigoratingH
        invigoratingSteps[2].chance = nocrit * pulseChance * nocrit
        invigoratingSteps[2].value = invigoratingH + pulseH
        invigoratingSteps[3].chance = nocrit * pulseChance * crit
        invigoratingSteps[3].value = invigoratingH + 2 * pulseH
        invigoratingSteps[4].chance = crit * (1 - pulseChance)
        invigoratingSteps[4].value = 2 * invigoratingH
        invigoratingSteps[5].chance = crit * pulseChance * nocrit
        invigoratingSteps[5].value = 2 * invigoratingH + pulseH
        invigoratingSteps[6].chance = crit * pulseChance * crit
        invigoratingSteps[6].value = 2 * invigoratingH + 2 * pulseH
        --table.sort(invigoratingSteps, ERAMonkMistweaver_SortInvigoratingSteps) -- pas besoin

        local acc = 0
        for _, i in ipairs(renewingDef.instances) do
            if (i.remDuration > minDur) then
                local missing = i.unitframe.absorbHealingValue + i.unitframe.maxHealth - i.unitframe.currentHealth
                for _, s in ipairs(invigoratingSteps) do
                    acc = acc + s.chance * math.min(missing, s.value)
                end
            end
        end

        self.monkParams.invigoratingStandardHealing = 5 * (1.2 * baseH + 0.3 * 1.5 * baseH) * (1 + crit)
        self.monkParams.invigoratingPredictedHealing = acc
    end

    ERACombatFrames_MonkInvigoratingBar:create(cFrame, -64, -32, 100, 20, grid, instaVivifyTimer, talent_invigorating)

    local utility = ERACombatFrames_MonkUtility(cFrame, 2, false, monkTalents)
    utility:AddDefensiveDispellCooldown(3, 5, 115450, nil, talent_better_detox, "Magic", "Poison", "Disease")
    utility:AddDefensiveDispellCooldown(3, 5, 115450, nil, talent_normal_detox, "Magic")
    utility:AddCooldown(-1, 0, 116849, nil, true, talent_cocoon)
    utility:AddCooldown(0, 0, 443028, nil, true, htalent_conduit)
    utility:AddCooldown(-1.5, -0.9, 322118, nil, true, talent_yulon)
    utility:AddCooldown(-1.5, -0.9, 325197, nil, true, talent_chiji)
    utility:AddCooldown(-0.5, -0.9, 115310, nil, true, talent_revival)
    utility:AddCooldown(-0.5, -0.9, 388615, nil, true, talent_restoral)
    -- out of combat
    utility:AddCooldown(-3, 1.8, 123986, nil, false, talent_chib)
    utility:AddCooldown(-4, 1.8, 116680, nil, false, talent_tft)
    utility:AddCooldown(-2.5, 2.7, 115151, nil, false, talent_renewing)
    utility:AddCooldown(-3.5, 2.7, 388193, nil, false, talent_fae)
end

-- invigorating --

ERACombatFrames_MonkInvigoratingBar = {}
ERACombatFrames_MonkInvigoratingBar.__index = ERACombatFrames_MonkInvigoratingBar
setmetatable(ERACombatFrames_MonkInvigoratingBar, { __index = ERACombatFrames_PseudoResourceBar })

function ERACombatFrames_MonkInvigoratingBar:create(cFrame, x, y, width, height, grid, instaVivifyTimer, talent_invigorating)
    local inv = {}
    setmetatable(inv, ERACombatFrames_MonkInvigoratingBar)
    inv:constructPseudoResource(cFrame, x, y, width, height, 2, 0, false, 2)
    inv.grid = grid
    inv.instaVivifyTimer = instaVivifyTimer
    inv.talent = talent_invigorating
    return inv
end

function ERACombatFrames_MonkInvigoratingBar:GetMax(t)
    return self.grid.monkParams.invigoratingStandardHealing
end
function ERACombatFrames_MonkInvigoratingBar:GetValue(t)
    return self.grid.monkParams.invigoratingPredictedHealing
end

function ERACombatFrames_MonkInvigoratingBar:Updated(t)
    if (self.grid.isSolo or not self.talent:PlayerHasTalent()) then
        self:Hide()
    else
        if (self.instaVivifyTimer.remDuration > self.instaVivifyTimer.group.occupied) then
            self:SetBarColor(0.0, 1.0, 0.0)
        else
            self:SetBarColor(0.0, 0.5, 1.0)
        end
        self:Show()
    end
end

-- invoke --

ERACombatTimerMonkInvokeBar = {}
ERACombatTimerMonkInvokeBar.__index = ERACombatTimerMonkInvokeBar
setmetatable(ERACombatTimerMonkInvokeBar, { __index = ERACombatTimerStatusBar })

function ERACombatTimerMonkInvokeBar:create(group, iconID, r, g, b, talent, talent_short_invoke)
    local bar = {}
    setmetatable(bar, ERACombatTimerMonkInvokeBar)
    bar:construct(group, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    -- assignation
    bar.talent = talent
    bar.talent_short_invoke = talent_short_invoke
    return bar
end

function ERACombatTimerMonkInvokeBar:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatTimerMonkInvokeBar:GetRemDurationOr0IfInvisibleOverride(t)
    local std
    if (self.talent_short_invoke:PlayerHasTalent()) then
        std = 12
    else
        std = 25
    end
    local dur = std - (t - self.group.lastInvoke)
    if (dur > 0) then
        return dur
    else
        return 0
    end
end

-- sheilun --

ERACombatFrames_MonkSheilunBar = {}
ERACombatFrames_MonkSheilunBar.__index = ERACombatFrames_MonkSheilunBar
setmetatable(ERACombatFrames_MonkSheilunBar, { __index = ERACombatFrames_PseudoResourceBar })

---comment
---@param cFrame ERACombatFrame
---@param x number
---@param y number
---@param length number
---@param thickness number
---@param combatHealth ERACombatHealth
---@param timers ERACombatTimers_MonkMistweaver
---@param talent_sheilun ERALIBTalent
---@param monkTalents MonkCommonTalents
---@return table
function ERACombatFrames_MonkSheilunBar:create(cFrame, x, y, length, thickness, combatHealth, timers, talent_sheilun, monkTalents)
    local sh = {}
    setmetatable(sh, ERACombatFrames_MonkSheilunBar)
    sh:constructPseudoResource(cFrame, x, y, length, thickness, 1, 0, false, 2)
    sh.talent = talent_sheilun
    sh:updateSlot()
    sh.timers = timers
    sh.monkTalents = monkTalents
    sh.combatHealth = combatHealth
    sh:SetBarColor(0.0, 0.8, 0.5)
    return sh
end

function ERACombatFrames_MonkSheilunBar:GetMax(t)
    return self.combatHealth.maxHealth
end
function ERACombatFrames_MonkSheilunBar:GetValue(t)
    return self.timers.sheilunStacks * 1.14 * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100) * (1 + self.monkTalents.healingDone2 * 0.02)
end

function ERACombatFrames_MonkSheilunBar:Updated(t)
    if (self.talent:PlayerHasTalent()) then
        self:Show()
    else
        self:Hide()
    end
end

ERACombatFrames_MonkSheilunIcon = {}
ERACombatFrames_MonkSheilunIcon.__index = ERACombatFrames_MonkSheilunIcon
setmetatable(ERACombatFrames_MonkSheilunIcon, { __index = ERACombatTimerIcon })

---comment
---@param group ERACombatTimers_MonkMistweaver
---@param x number
---@param y number
---@param talent_sheilun ERALIBTalent
---@param talent_fast_sheilun ERALIBTalent
---@return ERACombatTimersIcon
function ERACombatFrames_MonkSheilunIcon:create(group, x, y, talent_sheilun, talent_fast_sheilun)
    local i = {}
    setmetatable(i, ERACombatFrames_MonkSheilunIcon)
    i:construct(group, x, y, 1242282, true)
    i.talent = talent_sheilun
    i.talent_fast = talent_fast_sheilun
    i.stacks = 0
    return i
end

function ERACombatFrames_MonkSheilunIcon:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        self.talentActive = true
        return true
    else
        self:hide()
        self.talentActive = false
        return false
    end
end

function ERACombatFrames_MonkSheilunIcon:updateIconCooldownTexture()
    return 1242282
end

function ERACombatFrames_MonkSheilunIcon:updateAfterReset(t)
    self:updateIconCooldownTexture()
end

function ERACombatFrames_MonkSheilunIcon:updateTimerDurationAndMainIconVisibility(t, timerStandardDuration)
    local s = self.group.sheilunStacks
    if (s > 0) then
        self.shouldShowMainIcon = true
        if (s ~= self.stacks) then
            self.stacks = s
            self.icon:SetMainText(self.stacks)
        end
        self.icon:SetOverlayValue((10 - s) / 10)
    else
        self.shouldShowMainIcon = false
    end
    if (s < 10 and self.group.lastSheilunGain > 0) then
        local dur
        if (self.talent_fast:PlayerHasTalent()) then
            dur = 4
        else
            dur = 8
        end
        local elapsed = t - self.group.lastSheilunGain
        self.timerDuration = dur - (elapsed - dur * math.floor(elapsed / dur))
    else
        self.timerDuration = -1
    end
end

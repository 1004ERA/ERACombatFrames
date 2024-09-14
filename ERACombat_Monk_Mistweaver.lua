---@class ERACombatGrid_MonkMistweaver : ERACombatGrid
---@field invigoratingStandardHealing number
---@field invigoratingPredictedHealing number

---@class MonkMistweaverHUD : MonkHUD
---@field lastInvoke number

---@class MonkMistweaverInvigoratingStep
---@field chance number
---@field value number

---@param cFrame ERACombatFrame
---@param talents MonkCommonTalents
function ERACombatFrames_MonkMistweaverSetup(cFrame, talents)
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
    local talent_invoke = ERALIBTalent:CreateOr(talent_yulon, talent_chiji)
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

    local hud = ERAHUD:Create(cFrame, 1.5, true, true, 0, 0.0, 0.0, 1.0, false, 2)
    ---@cast hud MonkMistweaverHUD
    hud.power.hideFullOutOfCombat = true
    hud.powerHeight = 12
    hud.lastInvoke = 0

    ERACombatFrames_MonkCommonSetup(hud, talents, 0, nil)

    local instaVivifyTimer = hud:AddPriority(1360980, talents.vivification)
    function instaVivifyTimer:ComputeDurationOverride(t)
        self.icon:SetDesaturated(hud.instaVivify.stacks == 0)
        return hud.nextInstaVifify.remDuration
    end

    ------------------
    --#region grid ---
    ------------------

    local grid = ERACombatGrid:Create(cFrame, "BOTTOMRIGHT", 2, 115450, "Magic", "Poison", "Disease")
    ---@cast grid ERACombatGrid_MonkMistweaver
    grid.invigoratingStandardHealing = 0
    grid.invigoratingPredictedHealing = 0

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
        local baseH = GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100) * (1 + talents.healingDone2.rank * 0.02)
        local crit = GetCritChance() / 100
        local nocrit = 1 - crit
        local minDur
        if (hud.instaVivify.remDuration > 0) then
            minDur = hud.occupied
        else
            minDur = hud.occupied + hud.totGCD
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

        self.invigoratingStandardHealing = 5 * (1.2 * baseH + 0.3 * 1.5 * baseH) * (1 + crit)
        self.invigoratingPredictedHealing = acc
    end

    --#endregion

    ERAHUD_MonkInvigoratingBar:create(hud, grid, talent_invigorating)

    --- SAO ---

    local instaVivivySAO = hud:AddAuraOverlay(hud.instaVivify, 1, 623951, false, "RIGHT", true, false, false, false)
    ---@param combat boolean
    ---@param t number
    function instaVivivySAO:ConfirmIsActiveOverride(t, combat)
        return combat or self.hud.health.currentHealth < self.hud.health.maxHealth
    end

    local blackOxBuff = hud:AddTrackedBuff(443112, htalent_blackox)
    hud:AddAuraOverlay(blackOxBuff, 1, 623950, false, "TOP", false, false, false, true)

    --- rotation ---

    local chibIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(123986, talent_chib))

    hud:AddRotationCooldown(hud:AddTrackedCooldown(115151, talent_renewing))

    local faeIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(388193, talent_fae))

    local sheilunStacks = hud:AddSpellStacks(399491, talent_sheilun)
    hud:AddRotationStacks(sheilunStacks, 10, 9).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2
    local sheilunTimer = hud:AddPriority(1242282, talent_sheilun)
    function sheilunTimer:ComputeDurationOverride(t)
        if sheilunStacks.lastStackGain > 0 and sheilunStacks.stacks > 6 then
            local interval
            if talent_fast_sheilun:PlayerHasTalent() then
                interval = 4
            else
                interval = 8
            end
            local delta = t - sheilunStacks.lastStackGain
            local ratio = delta / interval
            return interval * (1 - (ratio - math.floor(ratio)))
        else
            return -1
        end
    end

    hud:AddRotationStacks(hud:AddTrackedBuff(115867, talent_manatea), 20, 18).soundOnHighlight = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_NIGHTFAE

    local tftBuff = hud:AddTrackedBuff(116680, talent_tft)
    local tftCooldown = hud:AddTrackedCooldown(116680, talent_tft)
    local tftIcon = hud:AddRotationCooldown(tftCooldown)
    function tftIcon:HighlightOverride(t, combat)
        return tftBuff.remDuration > 0
    end

    local instaRenewingBuff = hud:AddTrackedBuff(343820, talent_chiji)
    hud:AddRotationStacks(instaRenewingBuff, 3, 3).soundOnHighlight = SOUNDKIT.UI_9_0_ANIMA_DIVERSION_REVENDRETH_CONFIRM_CHANNEL

    --[[
    prio
    1 - tod
    2 - rsk
    3 - fae
    4 - chib
    5 - tft
    ]]

    local rskCooldown = hud:AddTrackedCooldown(107428, talent_rsk)
    local rskIcon = hud:AddPriority(642415, talent_rsk)
    function rskIcon:ComputeDurationOverride(t)
        return rskCooldown.remDuration
    end
    function rskIcon:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function faeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function chibIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function tftIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    --- bars ---

    function hud:MonkCLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_CAST_SUCCESS" and (spellID == 322118 or spellID == 325197)) then
            self.lastInvoke = t
        end
    end
    local invokeTimer = MistweaverInvokeTimer:create(hud, talent_invoke, talent_short_invoke)
    hud:AddGenericBar(invokeTimer, 574571, 0.0, 1.0, 0.2, talent_yulon)
    hud:AddGenericBar(invokeTimer, 877514, 1.0, 0.2, 0.0, talent_chiji)

    local selfRenewingBar = hud:AddAuraBar(hud:AddTrackedBuff(119611, talent_renewing), nil, 0.0, 1.0, 0.0)
    function selfRenewingBar:ComputeDurationOverride(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local selfEnvelopingBar = hud:AddAuraBar(hud:AddTrackedBuff(124682), nil, 0.6, 0.7, 0.0)
    function selfEnvelopingBar:ComputeDurationOverride(t)
        if (grid.isSolo) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(388026, talent_ancient_teachings), nil, 1.0, 0.2, 0.8)
    --hud:AddAuraBar(hud:AddTrackedBuff(389391, talent_ancient_concordance), 3528275, 0.2, 0.1, 0.8)
    local blackOxBar = hud:AddAuraBar(blackOxBuff, nil, 0.5, 0.6, 0.0)
    function blackOxBar:ComputeDurationOverride()
        if self.aura.remDuration < self.hud.timerDuration then
            return self.aura.remDuration
        else
            return 0
        end
    end
    hud:AddAuraBar(hud:AddTrackedBuff(438443, talent_chiji_sck), 606543, 0.8, 1.0, 0.5)

    -- anger
    hud:AddRotationBuff(hud:AddTrackedBuff(405807, talent_sheilun_shaohao))
    hud:AddAuraBar(hud:AddTrackedBuff(400106, talent_sheilun_shaohao), nil, 0.6, 0.0, 0.0)
    -- doubt
    hud:AddRotationBuff(hud:AddTrackedBuff(405808, talent_sheilun_shaohao)).overlapPrevious = true
    hud:AddAuraBar(hud:AddTrackedBuff(400097, talent_sheilun_shaohao), nil, 0.0, 0.3, 0.2)
    -- despair
    hud:AddRotationBuff(hud:AddTrackedBuff(405810, talent_sheilun_shaohao)).overlapPrevious = true
    hud:AddAuraBar(hud:AddTrackedBuff(400100, talent_sheilun_shaohao), nil, 0.5, 0.6, 0.8)
    -- fear
    hud:AddRotationBuff(hud:AddTrackedBuff(405809, talent_sheilun_shaohao)).overlapPrevious = true
    hud:AddAuraBar(hud:AddTrackedBuff(400103, talent_sheilun_shaohao), nil, 0.7, 0.0, 0.5)

    hud:AddAuraBar(hud:AddTrackedBuff(197908, talent_manatea), nil, 0.1, 0.5, 1.0)

    --- utility ---

    local detoxCooldown = hud:AddTrackedCooldown(115450)
    hud:AddUtilityDispell(detoxCooldown, hud.specialGroup, nil, -1, talent_better_detox, true, true, true, false, false)
    hud:AddUtilityDispell(detoxCooldown, hud.specialGroup, nil, -1, talent_normal_detox, true, false, false, false, false)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(322118, talent_yulon), hud.powerUpGroup, nil, -1)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(325197, talent_chiji), hud.powerUpGroup, nil, -1)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(116849, talent_cocoon), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(443028, htalent_conduit), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115310, talent_revival), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(388615, talent_restoral), hud.healGroup)
end

---@class MistweaverInvokeTimer : ERATimer
---@field private __index unknown
---@field private talentEitherInvoke ERALIBTalent
---@field private talentShortInvoke ERALIBTalent
---@field private mhud MonkMistweaverHUD
MistweaverInvokeTimer = {}
MistweaverInvokeTimer.__index = MistweaverInvokeTimer
setmetatable(MistweaverInvokeTimer, { __index = ERATimer })

---@param hud MonkMistweaverHUD
---@param talentEitherInvoke ERALIBTalent
---@param talentShortInvoke ERALIBTalent
---@return MistweaverInvokeTimer
function MistweaverInvokeTimer:create(hud, talentEitherInvoke, talentShortInvoke)
    local x = {}
    setmetatable(x, MistweaverInvokeTimer)
    ---@cast x MistweaverInvokeTimer
    x:constructTimer(hud)
    x.talentEitherInvoke = talentEitherInvoke
    x.talentShortInvoke = talentShortInvoke
    x.mhud = hud
    return x
end

function MistweaverInvokeTimer:checkDataItemTalent()
    return self.talentEitherInvoke:PlayerHasTalent()
end

---@param t number
function MistweaverInvokeTimer:updateData(t)
    if self.talentShortInvoke:PlayerHasTalent() then
        self.totDuration = 12
    else
        self.totDuration = 25
    end
    local remDur = self.totDuration - (t - self.mhud.lastInvoke)
    if remDur > 0 then
        self.remDuration = remDur
    else
        self.remDuration = 0
    end
end

---@class ERAHUD_MonkInvigoratingBar : ERAHUD_PseudoResourceBar
---@field private __index unknown
---@field private grid ERACombatGrid_MonkMistweaver
ERAHUD_MonkInvigoratingBar = {}
ERAHUD_MonkInvigoratingBar.__index = ERAHUD_MonkInvigoratingBar
setmetatable(ERAHUD_MonkInvigoratingBar, { __index = ERAHUD_PseudoResourceBar })

---@param hud MonkMistweaverHUD
---@param grid ERACombatGrid_MonkMistweaver
---@param talentInvigorating ERALIBTalent
---@return ERAHUD_MonkInvigoratingBar
function ERAHUD_MonkInvigoratingBar:create(hud, grid, talentInvigorating)
    local c = {}
    setmetatable(c, ERAHUD_MonkInvigoratingBar)
    ---@cast c ERAHUD_MonkInvigoratingBar
    c:constructPseudoResource(hud, 12, 2, 0.2, 1.0, 0.7, false, talentInvigorating)
    c.grid = grid
    return c
end
function ERAHUD_MonkInvigoratingBar:getValue(t, combat)
    return self.grid.invigoratingPredictedHealing
end
function ERAHUD_MonkInvigoratingBar:getMax(t, combat)
    return self.grid.invigoratingStandardHealing
end

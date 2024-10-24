---@class ERACombatGRFrame_MonkMistweaver : ERAGroupFrame
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
    local talent_rwk = ERALIBTalent:Create(128221)
    local talent_rsk = ERALIBTalent:CreateAnd(ERALIBTalent:Create(124984), ERALIBTalent:CreateNot(talent_rwk))
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
    local talent_jadefire_teachings = ERALIBTalent:Create(124882)
    local talent_normal_detox = ERALIBTalent:CreateNotTalent(124866)
    local talent_better_detox = ERALIBTalent:Create(124866)
    local talent_crackling_tea = ERALIBTalent:Create(128220)

    local hud = ERAHUD:Create(cFrame, 1.5, true, true, false, 2)
    ---@cast hud MonkMistweaverHUD
    hud.lastInvoke = 0
    local mana = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Mana, 12, 0.0, 0.0, 1.0, nil)
    mana.hideFullOutOfCombat = true
    mana.placeAtBottomIfHealer = true

    ERACombatFrames_MonkCommonSetup(hud, talents, 1.2, nil)

    local instaVivifyTimer = hud:AddPriority(1360980, talents.vivification)
    function instaVivifyTimer:ComputeDurationOverride(t)
        self.icon:SetDesaturated(hud.instaVivify.stacks == 0)
        return hud.nextInstaVifify.remDuration
    end

    local detoxCooldown = hud:AddTrackedCooldown(115450)

    -------------------------
    --#region group frame ---

    local hOptions = ERACombatOptions_getOptionsForSpec(nil, 2).healerOptions
    ---@cast hOptions ERACombatGroupFrameOptions
    local groupFrame = ERAGroupFrame:Create(cFrame, hud, hOptions, 2)
    local renewingOnGroup = groupFrame:AddBuff(119611, false, talent_renewing)
    if not hOptions.disabled then
        groupFrame:AddDispell(detoxCooldown, talent_normal_detox, true, false, false, false, false)
        groupFrame:AddDispell(detoxCooldown, talent_better_detox, true, true, true, false, false)
        groupFrame:AddDisplay(renewingOnGroup, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5)
        groupFrame:AddDisplay(groupFrame:AddBuff(124682, false), 1, 1, 0.6, 0.7, 0.0, 0.6, 0.7, 0.0) -- enveloping
        groupFrame:AddDisplay(groupFrame:AddBuff(116849, false), 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0) -- cocoon
    end

    ---@cast groupFrame ERACombatGRFrame_MonkMistweaver
    groupFrame.invigoratingStandardHealing = 0
    groupFrame.invigoratingPredictedHealing = 0

    ---@type MonkMistweaverInvigoratingStep[]
    local invigoratingSteps = {}
    for i = 1, 6 do
        table.insert(invigoratingSteps, {})
    end

    function groupFrame:UpdatedOverride(t)
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
        for _, i in ipairs(renewingOnGroup.activeInstances) do
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
        for _, i in ipairs(renewingOnGroup.activeInstances) do
            if (i.remDuration > minDur) then
                local missing = i.unit.currentHealAbsorb + i.unit.maxHealth - i.unit.currentHealth
                for _, s in ipairs(invigoratingSteps) do
                    acc = acc + s.chance * math.min(missing, s.value)
                end
            end
        end

        self.invigoratingStandardHealing = 5 * (1.2 * baseH + 0.3 * 1.5 * baseH) * (1 + crit)
        self.invigoratingPredictedHealing = acc
    end

    ERAHUD_MonkInvigoratingBar:create(hud, groupFrame, talent_invigorating)

    --#endregion
    -------------------------

    ERACombatMonk_HHarmony(hud, talents)

    --- SAO ---

    local instaVivivySAO = hud:AddAuraOverlay(hud.instaVivify, 1, 623951, false, "RIGHT", true, false, false, false)
    ---@param combat boolean
    ---@param t number
    function instaVivivySAO:ConfirmIsActiveOverride(t, combat)
        return combat or self.hud.health.currentHealth < self.hud.health.maxHealth
    end

    local blackOxBuff = hud:AddTrackedBuff(443112, talents.h_conduit_blackox)
    hud:AddAuraOverlay(blackOxBuff, 1, 623950, false, "TOP", false, false, false, true)

    local danceDuration = hud:AddTrackedBuff(438443, talent_chiji_sck)
    hud:AddAuraOverlay(danceDuration, 1, 1001512, false, "BOTTOM", false, false, true, false)
    hud:AddAuraOverlay(hud:AddTrackedBuff(467317, talent_crackling_tea), 1, 623952, false, "BOTTOM", false, false, true, false)

    --- rotation ---

    local ehIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(322101))

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

    -- shaoTeachings --

    ---@type ERAHUDRotationAuraIcon[]
    local shaoTeachings = {}

    -- anger
    local anger = hud:AddRotationBuff(hud:AddTrackedBuff(405807, talent_sheilun_shaohao))
    hud:AddAuraBar(hud:AddTrackedBuff(400106, talent_sheilun_shaohao), nil, 0.6, 0.0, 0.0)
    table.insert(shaoTeachings, anger)
    -- doubt
    local doubt = hud:AddRotationBuff(hud:AddTrackedBuff(405808, talent_sheilun_shaohao))
    hud:AddAuraBar(hud:AddTrackedBuff(400097, talent_sheilun_shaohao), nil, 0.0, 0.3, 0.2)
    doubt.overlapsPrevious = anger
    table.insert(shaoTeachings, doubt)
    -- despair
    local despair = hud:AddRotationBuff(hud:AddTrackedBuff(405810, talent_sheilun_shaohao))
    hud:AddAuraBar(hud:AddTrackedBuff(400100, talent_sheilun_shaohao), nil, 0.5, 0.6, 0.8)
    despair.overlapsPrevious = doubt
    table.insert(shaoTeachings, despair)
    -- fear
    local fear = hud:AddRotationBuff(hud:AddTrackedBuff(405809, talent_sheilun_shaohao))
    hud:AddAuraBar(hud:AddTrackedBuff(400103, talent_sheilun_shaohao), nil, 0.7, 0.0, 0.5)
    fear.overlapsPrevious = despair
    table.insert(shaoTeachings, fear)

    for _, st in ipairs(shaoTeachings) do
        function st:ShowWhenMissing(t, combat)
            return false
        end
        function st:ShowOutOfCombat(t)
            return false
        end
    end

    local chibIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(123986, talent_chib))

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
    3 - eh
    4 - fae
    5 - chib
    6 - tft
    ]]

    local rskCooldown = hud:AddTrackedCooldown(107428, talent_rsk)
    local rskIcon = hud:AddPriority(642415, talent_rsk)
    function rskIcon:ComputeDurationOverride(t)
        return rskCooldown.remDuration
    end
    function rskIcon:ComputeAvailablePriorityOverride(t)
        return 2
    end
    local rwkCooldown = hud:AddTrackedCooldown(467307, talent_rwk)
    local rwkIcon = hud:AddPriority(1381298, talent_rwk)
    function rwkIcon:ComputeDurationOverride(t)
        return rwkCooldown.remDuration
    end
    function rwkIcon:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function ehIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if self.hud.health.currentHealth / self.hud.health.maxHealth < 0.8 then
            return 3
        else
            return 0
        end
    end

    function faeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function chibIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function tftIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
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
        if groupFrame.isSolo then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local selfEnvelopingBar = hud:AddAuraBar(hud:AddTrackedBuff(124682), nil, 0.6, 0.7, 0.0)
    function selfEnvelopingBar:ComputeDurationOverride(t)
        if groupFrame.isSolo then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(388026, talent_jadefire_teachings), nil, 1.0, 0.2, 0.8)
    local blackOxBar = hud:AddAuraBar(blackOxBuff, nil, 0.5, 0.6, 0.0)
    function blackOxBar:ComputeDurationOverride()
        if self.aura.remDuration < self.hud.timerDuration - 1 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local danceBar = hud:AddAuraBar(danceDuration, 606543, 0.4, 1.0, 0.6)
    function danceBar:ComputeDurationOverride()
        if self.aura.remDuration < self.hud.timerDuration - 1 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(197908, talent_manatea), nil, 0.1, 0.5, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(443421, talents.h_conduit_heartofyulon), nil, 1.0, 0.5, 0.0)

    --- utility ---

    hud:AddUtilityDispell(detoxCooldown, hud.specialGroup, nil, -1, talent_better_detox, true, true, true, false, false)
    hud:AddUtilityDispell(detoxCooldown, hud.specialGroup, nil, -1, talent_normal_detox, true, false, false, false, false)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(322118, talent_yulon), hud.powerUpGroup, nil, -1, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(325197, talent_chiji), hud.powerUpGroup, nil, -1, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(116849, talent_cocoon), hud.healGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(443028, talents.h_conduit), hud.healGroup, nil, nil, nil, true)
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
---@field private grf ERACombatGRFrame_MonkMistweaver
ERAHUD_MonkInvigoratingBar = {}
ERAHUD_MonkInvigoratingBar.__index = ERAHUD_MonkInvigoratingBar
setmetatable(ERAHUD_MonkInvigoratingBar, { __index = ERAHUD_PseudoResourceBar })

---@param hud MonkMistweaverHUD
---@param grf ERACombatGRFrame_MonkMistweaver
---@param talentInvigorating ERALIBTalent
---@return ERAHUD_MonkInvigoratingBar
function ERAHUD_MonkInvigoratingBar:create(hud, grf, talentInvigorating)
    local c = {}
    setmetatable(c, ERAHUD_MonkInvigoratingBar)
    ---@cast c ERAHUD_MonkInvigoratingBar
    c:constructPseudoResource(hud, 12, 2, 0.2, 1.0, 0.7, false, talentInvigorating)
    c.grf = grf
    return c
end
function ERAHUD_MonkInvigoratingBar:getValue(t, combat)
    return self.grf.invigoratingPredictedHealing
end
function ERAHUD_MonkInvigoratingBar:getMax(t, combat)
    return self.grf.invigoratingStandardHealing
end

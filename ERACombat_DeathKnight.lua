---@class ERADKSoulReaperCooldown : ERACooldownIgnoringRunes
---@field targetIsLowHealth boolean

---@class ERADKHUD : ERAHUD
---@field runes ERADKRunesModule
---@field runicPower ERAHUDPowerBarModule
---@field enemies ERACombatEnemiesCount
---@field damageTaken ERACombatDamageTaken
---@field soulReaperCooldown ERADKSoulReaperCooldown
---@field blooddrawBuff ERAAura
---@field succor ERAAura

---@class (exact) DKCommonTalents
---@field kick ERALIBTalent
---@field soulreaper ERALIBTalent
---@field wraithwalk ERALIBTalent
---@field pact ERALIBTalent
---@field fortitude ERALIBTalent
---@field raisedead ERALIBTalent
---@field unholyRaisedead ERALIBTalent
---@field blinding ERALIBTalent
---@field vader ERALIBTalent
---@field necrolimb ERALIBTalent
---@field sacrifice ERALIBTalent
---@field deathstrike ERALIBTalent
---@field improved_deathstrike ERALIBTalent
---@field amz ERALIBTalent
---@field blooddraw ERALIBTalent
---@field rootchains ERALIBTalent
---@field cleavednd ERALIBTalent
---@field deathcharger ERALIBTalent
---@field not_deathcharger ERALIBTalent
---@field reapermark ERALIBTalent
---@field reapermark1rune ERALIBTalent
---@field reapermark2rune ERALIBTalent

---@param cFrame ERACombatFrame
function ERACombatFrames_DeathKnightSetup(cFrame)
    ERACombatGlobals_SpecID1 = 250
    ERACombatGlobals_SpecID2 = 251
    ERACombatGlobals_SpecID3 = 252

    ERADK_RuneSize = 24
    ERADK_SuccorR = 0.8
    ERADK_SuccorG = 0.7
    ERADK_SuccorB = 0.5

    local bloodOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local frostOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local unholyOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { bloodOptions, frostOptions, unholyOptions }

    local rd = ERALIBTalent:Create(96201)
    local urd = ERALIBTalent:Create(96325)

    ---@type DKCommonTalents
    local talents = {
        kick = ERALIBTalent:Create(96213),
        soulreaper = ERALIBTalent:Create(96192),
        wraithwalk = ERALIBTalent:Create(96206),
        pact = ERALIBTalent:Create(96204),
        fortitude = ERALIBTalent:Create(96210),
        raisedead = ERALIBTalent:CreateAnd(rd, ERALIBTalent:CreateNot(urd)),
        unholyRaisedead = urd,
        blinding = ERALIBTalent:Create(96172),
        vader = ERALIBTalent:Create(96193),
        necrolimb = ERALIBTalent:Create(96177),
        sacrifice = ERALIBTalent:Create(125608),
        deathstrike = ERALIBTalent:Create(96200),
        improved_deathstrike = ERALIBTalent:Create(96196),
        amz = ERALIBTalent:Create(96194),
        blooddraw = ERALIBTalent:Create(96184),
        rootchains = ERALIBTalent:Create(96215),
        cleavednd = ERALIBTalent:Create(96202),
        deathcharger = ERALIBTalent:Create(123412),
        not_deathcharger = ERALIBTalent:CreateNotTalent(123412),
        reapermark = ERALIBTalent:Create(117659),
        reapermark2rune = ERALIBTalent:CreateAnd(ERALIBTalent:Create(117659), ERALIBTalent:CreateNotTalent(117629)),
        reapermark1rune = ERALIBTalent:Create(117629),
    }

    local enemies = ERACombatEnemies:Create(cFrame, ERACombatOptions_specIDOrNilIfDisabled(bloodOptions), ERACombatOptions_specIDOrNilIfDisabled(frostOptions), ERACombatOptions_specIDOrNilIfDisabled(unholyOptions))

    if (not bloodOptions.disabled) then
        --ERAPieIcon_BorderR = 1.0
        --ERAPieIcon_BorderG = 0.0
        --ERAPieIcon_BorderB = 0.0
        ERACombatFrames_DeathKnightBloodSetup(cFrame, enemies, talents)
    end
    if (not frostOptions.disabled) then
        --ERAPieIcon_BorderR = 0.0
        --ERAPieIcon_BorderG = 0.0
        --ERAPieIcon_BorderB = 1.0
        ERACombatFrames_DeathKnightFrostSetup(cFrame, enemies, talents)
    end
    if (not unholyOptions.disabled) then
        --ERAPieIcon_BorderR = 0.0
        --ERAPieIcon_BorderG = 1.0
        --ERAPieIcon_BorderB = 0.0
        ERACombatFrames_DeathKnightUnholySetup(cFrame, enemies, talents)
    end
end

---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents DKCommonTalents
---@param spec integer
---@return ERADKHUD
function ERACombatFrames_DKCommonSetup(cFrame, enemies, talents, spec)
    local hud = ERAHUD:Create(cFrame, 1.5, true, false, spec == 3, spec)
    ---@cast hud ERADKHUD

    hud.enemies = enemies
    hud.runes = ERADKRunesModule:create(hud)
    hud.runicPower = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.RunicPower, 16, 0.2, 0.7, 1.0, nil)
    hud.damageTaken = ERACombatDamageTaken:Create(hud.cFrame, 5, spec)

    --- rotation ---

    hud:AddKick(hud:AddTrackedCooldown(47528, talents.kick))

    local soulReaperCooldown = ERACooldownIgnoringRunes:Create(hud, 343294, 1, talents.soulreaper)
    ---@cast soulReaperCooldown ERADKSoulReaperCooldown
    hud.soulReaperCooldown = soulReaperCooldown
    function hud:PreUpdateDataOverride(t)
        hud.soulReaperCooldown.targetIsLowHealth = UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") <= 0.35
    end

    local nextRune = hud:AddPriority(1121021)
    function nextRune:ComputeDurationOverride(t)
        if hud.runes.availableRunes <= 2 then
            return hud.runes.nextRuneDuration
        else
            return 0
        end
    end

    --- bars ---

    hud.blooddrawBuff = hud:AddTrackedBuff(454871, talents.blooddraw)
    hud:AddAuraBar(hud.blooddrawBuff, nil, 0.8, 0.4, 0.5)

    hud.succor = hud:AddTrackedBuff(101568)
    hud:AddAuraBar(hud.succor, nil, ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)

    hud:AddAuraBar(hud:AddTrackedBuff(48792, talents.fortitude), nil, 0.2, 0.0, 0.8)
    hud:AddAuraBar(hud:AddTrackedBuff(49039), nil, 0.4, 0.4, 0.4)     -- lichborne
    hud:AddAuraBar(hud:AddTrackedBuff(188290), 136144, 0.8, 0.5, 0.0) -- cleave dnd
    hud:AddAuraBar(hud:AddTrackedBuff(444347, talents.deathcharger), nil, 0.8, 1.0, 0.9)
    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(434765, talents.reapermark), nil, 0.6, 0.2, 0.4)

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(48743, talents.pact), hud.healGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(327574, talents.sacrifice), hud.healGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(383269, talents.necrolimb), hud.powerUpGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(48707), hud.defenseGroup) -- ams
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(51052, talents.amz), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(48792, talents.fortitude), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(49039), hud.defenseGroup) -- lichborne

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(56222), hud.specialGroup) -- taunt
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(46585, talents.raisedead), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(46584, talents.unholyRaisedead), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(61999), hud.specialGroup) -- raise ally

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(49576), hud.controlGroup) -- grip
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(45524, talents.rootchains), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(207167, talents.blinding), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(221562, talents.vader), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(48265, talents.not_deathcharger), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(444347, talents.deathcharger), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(212552, talents.wraithwalk), hud.movementGroup)

    return hud
end

---@param hud ERADKHUD
---@param prio integer
function ERACombatFrames_DKSoulReaper(hud, prio)
    local soulReaperIcon = hud:AddRotationCooldown(hud.soulReaperCooldown)
    function soulReaperIcon.onTimer:ComputeDurationOverride(t)
        if hud.soulReaperCooldown.targetIsLowHealth then
            return self.cd.data.remDuration
        else
            return 0
        end
    end
    function soulReaperIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if hud.soulReaperCooldown.targetIsLowHealth then
            return prio
        else
            return 0
        end
    end
end

---@param hud ERADKHUD
---@param talents DKCommonTalents
---@param prio number
function ERACombatFrames_DK_ReaperMark(hud, talents, prio)
    local reapermark1rune = ERACooldownIgnoringRunes:Create(hud, 439843, 1, talents.reapermark1rune)
    local reapermark2rune = ERACooldownIgnoringRunes:Create(hud, 439843, 2, talents.reapermark2rune)
    local reapermarkIcons = {}
    table.insert(reapermarkIcons, hud:AddRotationCooldown(reapermark1rune))
    table.insert(reapermarkIcons, hud:AddRotationCooldown(reapermark2rune))
    for _, i in ipairs(reapermarkIcons) do
        function i.onTimer:ComputeAvailablePriorityOverride(t)
            return prio
        end
    end
end

---@param hud ERADKHUD
---@param debuff ERAAura
function ERACombatFrames_DK_MissingDisease(hud, debuff)
    hud:AddMissingTimerOverlay(debuff, true, "PowerSwirlAnimation-Whirls-Soulbinds", true, "MIDDLE", false, false, false, false)
end

---@param hud ERADKHUD
---@param talents DKCommonTalents
function ERACombatFrames_DK_DPS(hud, talents)
    function hud:PreUpdateDisplayOverride(t, combat)
        local strikeCost
        local additionalH
        if hud.succor.remDuration > hud.occupied + 0.1 then
            strikeCost = 0
            hud.health.bar:SetPrevisionColor(ERADK_SuccorR, ERADK_SuccorG, ERADK_SuccorB)
            additionalH = 0.1 * hud.health.maxHealth
        else
            if talents.improved_deathstrike:PlayerHasTalent() then
                strikeCost = 40
            else
                strikeCost = 45
            end
            if hud.blooddrawBuff.remDuration > hud.occupied + 0.1 then
                strikeCost = strikeCost - 10
            end
            hud.health.bar:SetPrevisionColor(0.5, 0.5, 1.0)
            additionalH = 0
        end
        if hud.runicPower.currentPower >= strikeCost then
            local baseH = hud.health.maxHealth * 0.07
            local dmgH = 0.25 * hud.damageTaken.currentDamage
            if (dmgH > baseH or additionalH > 0) then
                local healing = math.max(baseH, dmgH)
                if (talents.improved_deathstrike:PlayerHasTalent()) then
                    healing = healing * 1.6
                end
                hud.health.bar:SetForecast(healing + additionalH)
            else
                hud.health.bar:SetForecast(0)
            end
        else
            hud.health.bar:SetForecast(0)
        end
    end
end

-------------
--- RUNES ---
-------------

---@class ERADKRuneInfo
---@field remDur number
---@field totDur number

---@class (exact) ERADKRunesModule : ERAHUDResourceModule
---@field private __index unknown
---@field availableRunes number
---@field nextRuneDuration number
---@field secondNextRuneDuration number
---@field private icons ERAPieIcon[]
---@field private infos ERADKRuneInfo[]
ERADKRunesModule = {}
ERADKRunesModule.__index = ERADKRunesModule
setmetatable(ERADKRunesModule, { __index = ERAHUDResourceModule })

function ERADKRunesModule:create(hud)
    local ru = {}
    setmetatable(ru, ERADKRunesModule)
    ---@cast ru ERADKRunesModule
    ru:constructModule(hud, ERADK_RuneSize)

    ru.icons = {}
    ru.infos = {}
    for i = 1, 6 do
        -- rune : 1121021
        -- rune violette forte : 252272
        -- rune violette faible : 1323037
        local icon = ERAPieIcon:Create(ru.frame, "CENTER", ERADK_RuneSize, 252272)
        icon:SetOverlayAlpha(0.95)
        icon:Draw((i - 3.5) * ERADK_RuneSize, 0, false)
        table.insert(ru.icons, icon)
        local info = {}
        info.remDur = 0
        info.totDur = 10
        table.insert(ru.infos, info)
    end

    ru.nextRuneDuration = 0
    ru.secondNextRuneDuration = 0
    ru.availableRunes = 0

    return ru
end

function ERADKRunesModule:checkTalentOverride()
    return true
end

---@param t number
---@param combat boolean
function ERADKRunesModule:PreUpdateDataOverride(t, combat)
    for i, info in ipairs(self.infos) do
        local start, duration, runeReady = GetRuneCooldown(i)
        if (start and start > 0 and not runeReady) then
            info.remDur = duration - (t - start)
            info.totDur = duration
        else
            info.remDur = 0
        end
    end
    table.sort(self.infos, ERARunes_sort)
    self.availableRunes = 0
    self.nextRuneDuration = 1004
    self.secondNextRuneDuration = 1004
    for _, info in ipairs(self.infos) do
        if (info.remDur <= 0) then
            self.availableRunes = self.availableRunes + 1
        else
            if info.remDur < self.nextRuneDuration then
                self.secondNextRuneDuration = self.nextRuneDuration
                self.nextRuneDuration = info.remDur
            elseif info.remDur < self.secondNextRuneDuration then
                self.secondNextRuneDuration = info.remDur
            end
        end
    end
end
function ERARunes_sort(r1, r2)
    return r1.remDur > r2.remDur
end

---@param t number
---@param combat boolean
function ERADKRunesModule:updateData(t, combat)
    -- fait dans PreUpdateDataOverride
end

---@param t number
---@param combat boolean
function ERADKRunesModule:UpdateDisplayReturnVisibility(t, combat)
    if self.availableRunes >= 6 and not combat then
        return nil
    else
        for i, info in ipairs(self.infos) do
            local icon = self.icons[i]
            if (info.remDur <= 0) then
                icon:SetIconTexture(1121021)
                icon:SetOverlayValue(0)
            else
                icon:SetIconTexture(1323037)
                icon:SetOverlayValue(info.remDur / info.totDur)
            end
        end
        return true
    end
end

------------------------------------------------------------------------------------------------------------------------
-- fucking blizzard API considering spells are on cooldown when runes are not available --------------------------------
------------------------------------------------------------------------------------------------------------------------

---@class ERACooldownIgnoringRunes : ERACooldownBase
---@field private __index unknown
---@field private runeCost integer
---@field private lastGoodUpdate number
---@field private lastGoodRemdur number
ERACooldownIgnoringRunes = {}
ERACooldownIgnoringRunes.__index = ERACooldownIgnoringRunes
setmetatable(ERACooldownIgnoringRunes, { __index = ERACooldownBase })

---@param hud ERADKHUD
---@param spellID integer
---@param runeCost integer
---@param talent ERALIBTalent | nil
---@param ... ERACooldownAdditionalID
---@return ERACooldownIgnoringRunes
function ERACooldownIgnoringRunes:Create(hud, spellID, runeCost, talent, ...)
    local cd = {}
    setmetatable(cd, ERACooldownIgnoringRunes)
    ---@cast cd ERACooldownIgnoringRunes
    cd:constructCooldownBase(hud, spellID, talent, ...)
    cd.lastGoodRemdur = 0
    cd.lastGoodUpdate = 0
    cd.runeCost = runeCost
    return cd
end

---@param t number
function ERACooldownIgnoringRunes:updateCooldownData(t)
    local hud = self.hud
    ---@cast hud ERADKHUD
    local chargesInfo = C_Spell.GetSpellCharges(self.spellID)
    if chargesInfo and chargesInfo.maxCharges > 1 then
        self.hasCharges = true
        self.maxCharges = chargesInfo.maxCharges
        self.currentCharges = chargesInfo.currentCharges
        self.totDuration = chargesInfo.cooldownDuration
        if chargesInfo.currentCharges >= chargesInfo.maxCharges then
            self.remDuration = 0
            self.isAvailable = true
        else
            self.remDuration = chargesInfo.cooldownDuration - (t - chargesInfo.cooldownStartTime)
            self.isAvailable = chargesInfo.currentCharges > 0
        end
    else
        self.hasCharges = false
        self.maxCharges = 1
        local cdInfo = C_Spell.GetSpellCooldown(self.spellID)
        if cdInfo and cdInfo.startTime and cdInfo.startTime > 0 and cdInfo.duration and cdInfo.duration > 0 then
            local remDur = cdInfo.duration - (t - cdInfo.startTime)
            local hasRunes = hud.runes.availableRunes >= self.runeCost
            local durDiff
            if hasRunes then
                durDiff = 0
            else
                if self.runeCost == 1 then
                    durDiff = remDur - hud.runes.nextRuneDuration
                else
                    durDiff = remDur - hud.runes.secondNextRuneDuration
                end
            end
            if hasRunes or (not self.lastGoodUpdate) or durDiff > 0.1 then
                if remDur <= self.hud.remGCD + 0.1 then
                    self.isAvailable = true
                    self.currentCharges = 1
                    -- totDuration reste inchangé
                    if self.lastGoodUpdate > 0 then
                        self.remDuration = self.lastGoodRemdur - (t - self.lastGoodUpdate)
                        if self.remDuration < 0 then
                            self.remDuration = 0
                        elseif self.remDuration > self.hud.remGCD - 0.1 then
                            self.remDuration = 0
                        elseif self.remDuration > remDur then
                            self.remDuration = remDur
                        end
                    else
                        self.remDuration = 0
                    end
                else
                    self.isAvailable = false
                    self.currentCharges = 0
                    self.totDuration = cdInfo.duration
                    self.remDuration = remDur
                    if durDiff > 0.1 then
                        self.lastGoodRemdur = remDur
                        self.lastGoodUpdate = t
                    end
                end
            else
                -- cd.totDuration reste inchangé
                self.remDuration = self.lastGoodRemdur - (t - self.lastGoodUpdate)
                if (self.remDuration < 0) then
                    self.remDuration = 0
                    self.currentCharges = 1
                    self.isAvailable = true
                    return
                end
                if (self.remDuration > remDur) then
                    self.remDuration = remDur
                end
                self.currentCharges = 0
                self.isAvailable = false
            end
        else
            self.isAvailable = true
            self.currentCharges = 1
            self.remDuration = 0
            if cdInfo.duration and cdInfo.duration > 0 then
                self.totDuration = cdInfo.duration
            end
            self.lastGoodRemdur = 0
            self.lastGoodUpdate = t
        end
    end
end

---@class MonkBrewmasterHUD : MonkHUD
---@field purifCooldown ERACooldown
---@field spheres ERASpellStacks

---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents MonkCommonTalents
function ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, talents)
    local talent_rsk = ERALIBTalent:Create(124985)
    local talent_bof = ERALIBTalent:Create(124843)
    local talent_not_bof = ERALIBTalent:CreateNotTalent(124843)
    local talent_no_shuffle = ERALIBTalent:CreateNotTalent(124864)
    local talent_rjw = ERALIBTalent:Create(125007)
    local talent_chib = ERALIBTalent:Create(126501)
    local talent_celestialb = ERALIBTalent:Create(124841)
    local talent_strong_rsk = ERALIBTalent:Create(124984)
    local talent_weapons = ERALIBTalent:Create(124996)
    local talent_exploding = ERALIBTalent:Create(125001)
    local talent_zenmed = ERALIBTalent:Create(125006)
    local talent_charred = ERALIBTalent:Create(124986)
    local talent_celestial_flames = ERALIBTalent:Create(124844)
    local talent_dampen = ERALIBTalent:Create(124978)
    local talent_niuzao = ERALIBTalent:Create(124849)
    local talent_black_brew = ERALIBTalent:Create(124991)

    local hud = ERAHUD:Create(cFrame, 1, true, false, false, 1)
    local nrj = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.Energy, 16, 1.0, 1.0, 0.0, nil)
    ---@cast hud MonkBrewmasterHUD
    nrj.hideFullOutOfCombat = true

    ERACombatFrames_MonkCommonSetup(hud, talents, 1.2, ERALIBTalent:Create(124867))

    local kegCooldown = hud:AddTrackedCooldown(121253)
    hud.purifCooldown = hud:AddTrackedCooldown(119582)

    local stagger = ERABMStagger:create(hud)

    ERACombatMonk_HHarmony(hud, talents)
    ERAHUD_MonkFlurry:create(hud, talents, 25, 25, nil)

    nrj.bar:AddMarkingFrom0(65)
    local kegConsumer = nrj.bar:AddMarkingFrom0(40)
    function kegConsumer:ComputeValueOverride(t)
        if (kegCooldown.hasCharges and kegCooldown.currentCharges > 0) or kegCooldown.remDuration <= 4 then
            return self.baseValue
        else
            return -1
        end
    end

    local ehCooldown = hud:AddTrackedCooldown(322101)
    hud.spheres = hud:AddSpellStacks(322101)

    --- healing ---

    function hud:PreUpdateDisplayOverride(t, combat)
        local vivifyHealing
        if self.instaVivify.remDuration > 0 then
            vivifyHealing = ERACombatFrames_InstaVivifyHealing(talents, 1.2)
        else
            vivifyHealing = 0
        end

        local ehHealing
        if ehCooldown.remDuration <= 0 then
            ehHealing = ERACombatFrames_MonkBrewmasterEH(hud, talents)
        else
            ehHealing = 0
        end

        if vivifyHealing > ehHealing then
            self.health.bar:SetPrevisionColor(0.5, 0.5, 1.0)
            self.health.bar:SetForecast(vivifyHealing)
        else
            self.health.bar:SetPrevisionColor(0.0, 1.0, 0.8)
            self.health.bar:SetForecast(ehHealing)
        end
    end

    --- rotation ---

    local kegIcon = hud:AddRotationCooldown(kegCooldown)

    local rskIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(107428, talent_rsk))

    local purifIcon = hud:AddRotationCooldown(hud.purifCooldown)

    local bofDOT = hud:AddTrackedDebuffOnTarget(123725, talent_bof)
    local bofIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(115181, talent_bof))

    local celestialBrewIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(322507, talent_celestialb))

    local chilBurstIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(123986, talent_chib))

    local explodingIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(325153, talent_exploding))

    ---@type ERASpellAdditionalID
    local bokAlternative = {
        spellID = 100784,
        talent = talent_no_shuffle
    }
    local bokCooldown = hud:AddTrackedCooldown(205523, nil, bokAlternative) -- 100784 (basic) or 205523 (with shuffle)
    local bokIcon = hud:AddRotationCooldown(bokCooldown)

    local rjwCooldown = hud:AddTrackedCooldown(116847, talent_rjw)

    --[[

    PRIO

    1 - touch of death
    2 - expel harm low health
    3 - celestialbrew low health
    4 - vivify low health
    5 - bof missing
    6 - keg smash full charges
    7 - bok
    8 - bof refresh
    9 - keg smash
    10 - rjw many targets
    11 - chiburst many targets
    12 - rsk
    13 - exploding keg many targets
    14 - rjw
    15 - chiburst
    16 - celestialbrew
    17 - expel harm
    18 - vivify
    19 - exploding keg

    ]]

    ---@class BMEHTimer : ERAHUDRawPriority
    ---@field ehPct number
    local ehTimer = hud:AddPriority(627486)
    ehTimer.ehPct = 0
    function ehTimer:ComputeDurationOverride(t)
        local h = ERACombatFrames_MonkBrewmasterEH(hud, talents)
        if h < self.hud.health.maxHealth - self.hud.health.currentHealth then
            self.ehPct = h / self.hud.health.maxHealth
            return ehCooldown.remDuration
        else
            return -1
        end
    end
    function ehTimer:ComputeAvailablePriorityOverride(t)
        if self.ehPct > 0.2 then
            return 2
        elseif self.ehPct > 0.07 then
            return 17
        else
            return 0
        end
    end

    function celestialBrewIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if self.hud.health.currentHealth / self.hud.health.maxHealth < 0.75 then
            return 3
        else
            return 16
        end
    end

    ---@class BMVVTimer : ERAHUDRawPriority
    ---@field vvPct number
    local vivifyTimer = hud:AddPriority(1360980, talents.vivification)
    vivifyTimer.vvPct = 0
    function vivifyTimer:ComputeDurationOverride(t)
        local h = ERACombatFrames_InstaVivifyHealing(talents, 1.2)
        if h < self.hud.health.maxHealth - self.hud.health.currentHealth then
            self.icon:SetDesaturated(hud.instaVivify.stacks == 0)
            self.vvPct = h / self.hud.health.maxHealth
            return hud.nextInstaVifify.remDuration
        else
            return -1
        end
    end
    local vivifyPrio = hud:AddPriority(1360980, talents.vivification)
    function vivifyPrio:ComputeAvailablePriorityOverride(t)
        if hud.instaVivify.stacks > 0 then
            if vivifyTimer.vvPct > 0.2 then
                return 4
            elseif vivifyTimer.vvPct > 0.07 then
                return 18
            else
                return 0
            end
        else
            return 0
        end
    end

    function bofIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if bofDOT.remDuration > self.hud.occupied + self.hud.totGCD then
            return 8
        else
            return 5
        end
    end

    function kegIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end
    function kegIcon.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function bokIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    local rjwPrio = hud:AddPriority(606549, talent_rjw)
    function rjwPrio:ComputeAvailablePriorityOverride(t)
        if rjwCooldown.remDuration > 0 then
            return 0
        else
            if enemies:GetCount() > 3 then
                return 10
            else
                return 14
            end
        end
    end

    function chilBurstIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() > 3 then
            return 11
        else
            return 15
        end
    end

    function rskIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 12
    end

    function explodingIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() > 3 then
            return 13
        else
            return 19
        end
    end

    --- bars ---

    local rjwBuff = hud:AddTrackedBuff(116847, talent_rjw)
    local rjwLongBar = hud:AddAuraBar(rjwBuff, nil, 0.0, 0.6, 0.2)
    function rjwLongBar:ComputeDurationOverride(t)
        if rjwCooldown.remDuration > 0 then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local rjwShortBar = hud:AddAuraBar(rjwBuff, nil, 0.0, 1.0, 0.7)
    function rjwShortBar:ComputeDurationOverride(t)
        if rjwCooldown.remDuration > 0 then
            return 0
        else
            return self.aura.remDuration
        end
    end

    hud:AddAuraBar(hud:AddTrackedBuff(115176, talent_zenmed), nil, 0.3, 0.6, 0.3)
    hud:AddAuraBar(hud:AddTrackedBuff(387184, talent_weapons), nil, 0.0, 0.0, 1.0)
    hud:AddAuraBar(hud:AddTrackedBuff(325190, talent_celestial_flames), nil, 1.0, 0.0, 0.0)
    hud:AddAuraBar(hud:AddTrackedBuff(386963, talent_charred), nil, 0.7, 0.3, 0.0)

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(387184, talent_weapons), hud.powerUpGroup, nil, -3, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(132578, talent_niuzao), hud.powerUpGroup, nil, -2, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115399, talent_black_brew), hud.powerUpGroup, nil, -1, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(122278, talent_dampen), hud.defenseGroup, nil, 1.5, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115176, talent_zenmed), hud.defenseGroup)
end

---@param hud MonkBrewmasterHUD
---@param talents MonkCommonTalents
---@return number
function ERACombatFrames_MonkBrewmasterEH(hud, talents)
    local ehHealing = 1.3 * (1 + talents.strongEH.rank * 0.05)
    if (talents.scalingEH:PlayerHasTalent()) then
        ehHealing = ehHealing * (2 - (hud.health.currentHealth / hud.health.maxHealth))
    end
    return (ehHealing + hud.spheres.stacks * 3.2) * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100) * (1 + 0.04 * talents.healingTaken4.rank) * (1 + 0.02 * talents.healingDone2.rank)
end

---@class ERABMStagger : ERAHUDResourceModule
---@field __index unknown
---@field private mhud MonkBrewmasterHUD
---@field private bar ERAHUDStatusBar
---@field staggerValue number
---@field staggerPercent number
ERABMStagger = {}
ERABMStagger.__index = ERABMStagger
setmetatable(ERABMStagger, { __index = ERAHUDResourceModule })

---@param hud MonkBrewmasterHUD
---@return ERABMStagger
function ERABMStagger:create(hud)
    local s = {}
    setmetatable(s, ERABMStagger)
    ---@cast s ERABMStagger
    s:constructModule(hud, 12)
    s.mhud = hud
    s.bar = ERAHUDStatusBar:create(s.frame, 0, 6, hud.barsWidth, 12, 1.0, 1.0, 1.0)
    s.bar:show()
    s.staggerValue = 0
    s.staggerPercent = 0
    return s
end

function ERABMStagger:checkTalentOverride()
    return true
end

---@param combat boolean
---@param t number
function ERABMStagger:updateData(t, combat)
    self.staggerValue = UnitStagger("player")
    self.staggerPercent = self.staggerValue / self.mhud.health.maxHealth
end

---@param combat boolean
---@param t number
function ERABMStagger:UpdateDisplayReturnVisibility(t, combat)
    if self.staggerValue > 0 then
        self.bar:SetValueAndMax(self.staggerValue, self.hud.health.maxHealth)
    else
        if combat then
            self.bar:SetValueAndMax(0, self.hud.health.maxHealth)
        else
            return nil
        end
    end
    if self.mhud.purifCooldown.currentCharges == 0 then
        self.bar:SetMainColor(1.0, 0.0, 0.0)
    elseif self.mhud.purifCooldown.currentCharges == 1 then
        self.bar:SetMainColor(1.0, 0.0, 1.0)
    else
        self.bar:SetMainColor(0.0, 0.9, 1.0)
    end
    return true
end

---@class (exact) MonkCommonTalents
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
---@field kick ERALIBTalent
---@field vivification ERALIBTalent
---@field healingTaken4 ERALIBTalent
---@field healingDone2 ERALIBTalent
---@field vivify_30pct ERALIBTalent
---@field strongEH ERALIBTalent
---@field scalingEH ERALIBTalent
---@field tod15 ERALIBTalent
---@field h_shadopan ERALIBTalent
---@field h_conduit ERALIBTalent
---@field h_conduit_heartofyulon ERALIBTalent
---@field h_conduit_blackox ERALIBTalent
---@field h_harmony ERALIBTalent

---@class MonkHUD : ERAHUD
---@field lastInstaVivify number
---@field instaVivify ERAAura
---@field nextInstaVifify MonkInstaVivify
---@field tod ERACooldown
---@field MonkCLEU fun(this:MonkHUD, t:number)

---@param cFrame ERACombatFrame
function ERACombatFrames_MonkSetup(cFrame)
    ERACombatGlobals_SpecID1 = 268
    ERACombatGlobals_SpecID2 = 270
    ERACombatGlobals_SpecID3 = 269

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local mwOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local wwOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { bmOptions, mwOptions, wwOptions }

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
        kick = ERALIBTalent:Create(124943),
        vivification = ERALIBTalent:Create(124935),
        healingDone2 = ERALIBTalent:Create(124964),
        healingTaken4 = ERALIBTalent:Create(124936),
        vivify_30pct = ERALIBTalent:Create(125076),
        strongEH = ERALIBTalent:Create(124948),
        scalingEH = ERALIBTalent:Create(124924),
        tod15 = ERALIBTalent:Create(124930),
        h_shadopan = ERALIBTalent:Create(125069),
        h_conduit = ERALIBTalent:Create(125062),
        h_conduit_heartofyulon = ERALIBTalent:Create(125055),
        h_conduit_blackox = ERALIBTalent:Create(125060),
        h_harmony = ERALIBTalent:Create(125033),
    }

    local enemies = ERACombatEnemies:Create(cFrame, ERACombatOptions_specIDOrNilIfDisabled(bmOptions), ERACombatOptions_specIDOrNilIfDisabled(wwOptions))

    if (not bmOptions.disabled) then
        ERACombatFrames_MonkBrewmasterSetup(cFrame, enemies, monkTalents)
    end
    if (not mwOptions.disabled) then
        ERACombatFrames_MonkMistweaverSetup(cFrame, monkTalents)
    end
    if (not wwOptions.disabled) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, monkTalents)
    end
end

--------------------
--#region COMMON ---
--------------------

---@param hud MonkHUD
---@param talents MonkCommonTalents
---@param vivificationMultiplier number|nil
---@param detox ERALIBTalent|nil
function ERACombatFrames_MonkCommonSetup(hud, talents, vivificationMultiplier, detox)
    hud.tod = hud:AddTrackedCooldown(322109)

    local instaVivifyID = 392883

    hud.instaVivify = hud:AddTrackedBuff(instaVivifyID, talents.vivification)

    hud.lastInstaVivify = 0
    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED") then
            if (spellID == instaVivifyID) then
                self.lastInstaVivify = t
            end
        end
        self:MonkCLEU(t)
    end
    function hud:MonkCLEU(t)
    end
    hud.nextInstaVifify = MonkInstaVivify:create(hud, talents.vivification)

    if vivificationMultiplier then
        function hud:PreUpdateDisplayOverride(t, combat)
            if self.instaVivify.remDuration > 0 then
                self.health.bar:SetForecast(ERACombatFrames_InstaVivifyHealing(talents, vivificationMultiplier))
            else
                self.health.bar:SetForecast(0)
            end
        end
    end

    ----------------
    --- ROTATION ---
    ----------------

    hud:AddChannelInfo(115175, 1.0) -- soothing mist
    hud:AddChannelInfo(117952, 1.0) -- crackling jade lightning

    hud:AddAuraBar(hud:AddTrackedBuff(122783, talents.diffuse), nil, 0.7, 0.6, 1.0)
    hud:AddAuraBar(hud:AddTrackedBuff(120954, talents.fortify), nil, 0.8, 0.8, 0.0)

    local todPrio = hud:AddPriority(606552)
    function todPrio:ComputeDurationOverride(t)
        if hud.tod.remDuration <= 0 then
            if C_Spell.IsSpellUsable(hud.tod.spellID) then
                return hud.tod.remDuration
            else
                return -1
            end
        else
            local tarH = UnitHealth("target")
            if tarH and tarH > 0 and (
                    (tarH < self.hud.health.currentHealth)
                    or
                    (talents.tod15:PlayerHasTalent() and tarH / UnitHealthMax("target") < 0.15)
                )
            then
                return hud.tod.remDuration
            else
                return -1
            end
        end
    end
    function todPrio:ComputeAvailablePriorityOverride(t)
        --[[
        local u, nomana = C_Spell.IsSpellUsable(hud.tod.spellID)
        if (u or nomana) then
        else
            return 0
        end
        ]]
        return 1
    end

    hud:AddKick(hud:AddTrackedCooldown(116705), nil, talents.kick)

    local paralysis = hud:AddTrackedCooldown(115078, talents.paralysis)
    hud:AddOffensiveDispell(paralysis, nil, talents.disenrage, false, true)

    ---------------
    --- UTILITY ---
    ---------------

    hud:AddUtilityCooldown(hud.tod, hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(122783, talents.diffuse), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115203, talents.fortify), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(119381), hud.controlGroup) -- sweep
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(116844, talents.rop), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(198898, talents.sleep), hud.controlGroup)
    hud:AddUtilityCooldown(paralysis, hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(109132, talents.roll), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115008, talents.torpedo), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(116841, talents.lust), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(324312, talents.clash), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(119996, talents.transcendence), hud.movementGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(101643, talents.transcendence), hud.movementGroup)
    if detox then
        hud:AddUtilityDispell(hud:AddTrackedCooldown(218164, detox), hud.specialGroup, nil, nil, nil, false, true, true, false, false)
    end
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(115546), hud.specialGroup) -- taunt
end

---@param talents MonkCommonTalents
---@param vivificationMultiplier number
---@return number
function ERACombatFrames_InstaVivifyHealing(talents, vivificationMultiplier)
    local mult = vivificationMultiplier * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
    mult = mult * (1 + talents.healingDone2.rank * 0.02)
    mult = mult * (1 + talents.healingTaken4.rank * 0.04)
    mult = mult * (1 + talents.vivify_30pct.rank * 0.3)
    return 6 * GetSpellBonusHealing() * mult
end

----------------------
--#region HHARMONY ---

---@param hud MonkHUD
---@param talents MonkCommonTalents
function ERACombatMonk_HHarmony(hud, talents)
    local h = ERAHUD_MonkHHarmony:create(hud, talents)
    hud:AddAuraBar(h.auraSpend, nil, 1.0, 0.5, 0.0)
end

---@class (exact) ERAHUD_MonkHHarmony : ERAHUD_PseudoResourceBar
---@field private __index unknown
---@field aura1 ERAAura
---@field aura2 ERAAura
---@field aura3 ERAAura
---@field auraSpend ERAAura
ERAHUD_MonkHHarmony = {}
ERAHUD_MonkHHarmony.__index = ERAHUD_MonkHHarmony
setmetatable(ERAHUD_MonkHHarmony, { __index = ERAHUD_PseudoResourceBar })

---@param hud MonkHUD
---@param talents MonkCommonTalents
---@return ERAHUD_MonkHHarmony
function ERAHUD_MonkHHarmony:create(hud, talents)
    local wi = {}
    setmetatable(wi, ERAHUD_MonkHHarmony)
    ---@cast wi ERAHUD_MonkHHarmony
    wi:constructPseudoResource(hud, 12, 2, 0.0, 0.5, 1.0, false, talents.h_harmony)
    wi.showOutOfCombat = false
    wi.aura1 = hud:AddTrackedBuff(450521, talents.h_harmony)
    wi.aura1.fetchTooltipValue = true
    wi.aura2 = hud:AddTrackedBuff(450526, talents.h_harmony)
    wi.aura2.fetchTooltipValue = true
    wi.aura3 = hud:AddTrackedBuff(450531, talents.h_harmony)
    wi.aura3.fetchTooltipValue = true
    wi.auraSpend = hud:AddTrackedBuff(450711, talents.h_harmony)
    wi.auraSpend.fetchTooltipValue = true
    return wi
end

function ERAHUD_MonkHHarmony:getValue(t, combat)
    if self.auraSpend.remDuration > 0 then
        return self.auraSpend.value
    else
        return self.aura1.value + self.aura2.value + self.aura3.value
    end
end

function ERAHUD_MonkHHarmony:getMax(t, combat)
    return self.hud.health.maxHealth
end

function ERAHUD_MonkHHarmony:DisplayUpdatedOverride(t, combat)
    if self.auraSpend.remDuration > 0 then
        self:SetColor(1.0, 0.5, 0.0)
    else
        self:SetColor(0.0, 0.5, 1.0)
    end
end

--#endregion
----------------------

------------------------
--#region TIMER CLEU ---
------------------------

---@class MonkTimerCLEU : ERATimer
---@field private __index unknown
---@field private talent ERALIBTalent|nil
---@field getLastTime fun(this:MonkTimerCLEU): number
---@field protected setLastTime fun(this:MonkTimerCLEU, t:number)
---@field private isValid boolean
---@field mhud MonkHUD
MonkTimerCLEU = {}
MonkTimerCLEU.__index = MonkTimerCLEU
setmetatable(MonkTimerCLEU, { __index = ERATimer })

---@param hud MonkHUD
---@param talent ERALIBTalent|nil
function MonkTimerCLEU:constructCLEU(hud, totDuration, talent)
    self:constructTimer(hud)
    self.talent = talent
    self.totDuration = totDuration
    self.mhud = hud
end

function MonkTimerCLEU:checkDataItemTalent()
    return not (self.talent and not self.talent:PlayerHasTalent())
end

---@param t number
function MonkTimerCLEU:updateData(t)
    local last = self:getLastTime()
    if last and last > 0 then
        self.isValid = true
        self.remDuration = self.totDuration - (t - last)
        if self.remDuration < 0 then
            while self.remDuration < 0 do
                self.remDuration = self.remDuration + self.totDuration
            end
            self:setLastTime(t + self.remDuration - self.totDuration)
        end
    else
        self.remDuration = 0
        self.isValid = false
    end
end

--- VIVIFY ---

---@class MonkInstaVivify : MonkTimerCLEU
---@field __index unknown
---@field mhud MonkHUD
MonkInstaVivify = {}
MonkInstaVivify.__index = MonkInstaVivify
setmetatable(MonkInstaVivify, { __index = MonkTimerCLEU })

---@param hud MonkHUD
---@param talent ERALIBTalent
---@return MonkInstaVivify
function MonkInstaVivify:create(hud, talent)
    local v = {}
    setmetatable(v, MonkInstaVivify)
    ---@cast v MonkInstaVivify
    v:constructCLEU(hud, 10, talent)
    return v
end

---@return number
function MonkInstaVivify:getLastTime()
    return self.mhud.lastInstaVivify
end

---@param t number
function MonkInstaVivify:setLastTime(t)
    self.mhud.lastInstaVivify = t
end

--#endregion

--------------------
--#region FLURRY ---

---@class (exact) ERAHUD_MonkFlurry : ERAHUD_PseudoResourceBar
---@field private __index unknown
---@field progressAura ERAAura
---@field chargesAura ERAAura
---@field private fillerCost1 number
---@field private fillerCost2 number
---@field private talentFillerCost2 ERALIBTalent|nil
ERAHUD_MonkFlurry = {}
ERAHUD_MonkFlurry.__index = ERAHUD_MonkFlurry
setmetatable(ERAHUD_MonkFlurry, { __index = ERAHUD_PseudoResourceBar })

---@param hud MonkHUD
---@param talents MonkCommonTalents
---@param fillerCost1 number
---@param fillerCost2 number
---@param talentFillerCost2 ERALIBTalent|nil
---@return ERAHUD_MonkFlurry
function ERAHUD_MonkFlurry:create(hud, talents, fillerCost1, fillerCost2, talentFillerCost2)
    local wi = {}
    setmetatable(wi, ERAHUD_MonkFlurry)
    ---@cast wi ERAHUD_MonkFlurry
    wi:constructPseudoResource(hud, 12, 2, 1.0, 0.5, 0.0, false, talents.h_shadopan)
    wi.showOutOfCombat = false
    wi.fillerCost1 = fillerCost1
    wi.fillerCost2 = fillerCost2
    wi.talentFillerCost2 = talentFillerCost2
    wi.progressAura = hud:AddTrackedBuff(470670, talents.h_shadopan)
    wi.chargesAura = hud:AddTrackedBuff(451021, talents.h_shadopan)
    return wi
end

function ERAHUD_MonkFlurry:getValue(t, combat)
    return self.progressAura.stacks
end

function ERAHUD_MonkFlurry:getMax(t, combat)
    return 240
end

function ERAHUD_MonkFlurry:DisplayUpdatedOverride(t, combat)
    local fc
    if self.talentFillerCost2 and self.talentFillerCost2:PlayerHasTalent() then
        fc = self.fillerCost2
    else
        fc = self.fillerCost1
    end
    if self.progressAura.stacks + fc >= 240 then
        self:SetColor(0.5, 1.0, 0.0)
    else
        self:SetColor(1.0, 0.5, 0.0)
    end
    self:SetText(tostring(self.chargesAura.stacks))
end

--#endregion
--------------------

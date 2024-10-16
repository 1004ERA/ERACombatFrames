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

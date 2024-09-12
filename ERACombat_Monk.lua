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
---@field detox ERALIBTalent
---@field kick ERALIBTalent
---@field vivification ERALIBTalent
---@field healingTaken4 ERALIBTalent
---@field healingDone2 ERALIBTalent
---@field vivify_30pct ERALIBTalent
---@field strongEH ERALIBTalent
---@field scalingEH ERALIBTalent

---@class MonkHUD : ERAHUD
---@field lastInstaVivify number
---@field nextInstaVifify MonkInstaVivify

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

    local enemies = ERACombatEnemies:Create(cFrame, bmActive, wwActive)

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

--------------------
--#region COMMON ---
--------------------

---@param hud MonkHUD
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkCommonSetup(hud, monkTalents)
    hud.lastInstaVivify = 0
    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED") then
            if (spellID == 392883) then
                self.lastInstaVivify = t
            end
        end
    end
    hud.nextInstaVifify = MonkInstaVivify:create(hud, monkTalents.vivification)
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

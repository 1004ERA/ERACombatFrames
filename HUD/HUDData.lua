----------------------------------------------------------------
--- GENERIC DATA -----------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDDataItem
---@field private __index HUDDataItem
---@field talent ERALIBTalent|nil
---@field talentActive boolean
---@field hud HUDModule
---@field Update fun(self:HUDDataItem, t:number)
---@field protected constructItem fun(self:HUDDataItem, hud:HUDModule, talent:ERALIBTalent|nil)
---@field protected talentIsActive fun(self:HUDDataItem)
HUDDataItem = {}
HUDDataItem.__index = HUDDataItem

function HUDDataItem:constructItem(hud, talent)
    self.talent = talent
    self.hud = hud
    hud:addData(self)
end

---comment
---@return boolean
function HUDDataItem:computeTalentActive()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.talentActive = false
        return false
    else
        self.talentActive = true
        self:talentIsActive()
        return true
    end
end
function HUDDataItem:talentIsActive()
end

----------------------------------------------------------------
--- HEALTH -----------------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDHealth : HUDDataItem
---@field private __index HUDHealth
---@field unit "player"|"pet"
---@field health number
---@field maxHealth number
---@field healthPercent100 number
---@field goodAbsorb number
---@field badAbsorb number
HUDHealth = {}
HUDHealth.__index = HUDHealth
setmetatable(HUDHealth, { __index = HUDDataItem })

---comment
---@param hud HUDModule
---@param unit "player"|"pet"
---@return HUDHealth
function HUDHealth:Create(hud, unit)
    local x = {}
    setmetatable(x, HUDHealth)
    ---@cast x HUDHealth
    x:constructItem(hud)
    x.unit = unit
    x.health = 1
    x.maxHealth = 2
    x.healthPercent100 = 50
    x.goodAbsorb = 0
    x.badAbsorb = 0
    return x
end

function HUDHealth:Update()
    self.health = UnitHealth(self.unit)
    self.maxHealth = UnitHealthMax(self.unit)
    self.healthPercent100 = UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)
    self.goodAbsorb = UnitGetTotalAbsorbs(self.unit)
    self.badAbsorb = UnitGetTotalHealAbsorbs(self.unit)
end

----------------------------------------------------------------
--- POWER ------------------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDPower : HUDDataItem
---@field private __index HUDPower
---@field powerType Enum.PowerType
---@field current number
---@field max number
---@field percent100 number
---@field idleAlphaOOC number
---@field protected updateIdleAlpha fun(self:HUDPower): number
HUDPower = {}
HUDPower.__index = HUDPower
setmetatable(HUDPower, { __index = HUDDataItem })

---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
function HUDPower:constructPower(hud, powerType, talent)
    self.current = 0
    self.max = 100
    self.powerType = powerType
    self:constructItem(hud, talent)
end

function HUDPower:Update()
    self.current = UnitPower("player", self.powerType)
    self.max = UnitPowerMax("player", self.powerType)
    self.percent100 = UnitPowerPercent("player", self.powerType, false, CurveConstants.ScaleTo100)
    self.idleAlphaOOC = self:updateIdleAlpha()
end
---@class (exact) HUDPowerLowIdle : HUDPower
---@field private __index HUDPowerLowIdle
HUDPowerLowIdle = {}
HUDPowerLowIdle.__index = HUDPowerLowIdle
setmetatable(HUDPowerLowIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerLowIdle
function HUDPowerLowIdle:Create(hud, powerType, talent)
    local x = {}
    setmetatable(x, HUDPowerLowIdle)
    ---@cast x HUDPowerLowIdle
    x:constructPower(hud, powerType, talent)
    return x
end
function HUDPowerLowIdle:updateIdleAlpha()
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.hud.curveHide4pctEmpty)
end

---@class (exact) HUDPowerHighIdle : HUDPower
---@field private __index HUDPowerHighIdle
HUDPowerHighIdle = {}
HUDPowerHighIdle.__index = HUDPowerHighIdle
setmetatable(HUDPowerHighIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerHighIdle
function HUDPowerHighIdle:Create(hud, powerType, talent)
    local x = {}
    setmetatable(x, HUDPowerHighIdle)
    ---@cast x HUDPowerHighIdle
    x:constructPower(hud, powerType, talent)
    return x
end
function HUDPowerHighIdle:updateIdleAlpha()
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.hud.curveHide96pctFull)
end

---@class (exact) HUDPowerTargetIdle : HUDPower
---@field private __index HUDPowerTargetIdle
---@field private idleCurve LuaCurveObject
---@field private targetPercent fun(): number
HUDPowerTargetIdle = {}
HUDPowerTargetIdle.__index = HUDPowerTargetIdle
setmetatable(HUDPowerTargetIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@param targetPercent fun(): number
---@return HUDPowerTargetIdle
function HUDPowerTargetIdle:Create(hud, powerType, talent, targetPercent)
    local x = {}
    setmetatable(x, HUDPowerTargetIdle)
    ---@cast x HUDPowerTargetIdle
    x:constructPower(hud, powerType, talent)
    x.idleCurve = C_CurveUtil:CreateCurve()
    x.idleCurve:SetType(Enum.LuaCurveType.Step)
    x.targetPercent = targetPercent
    return x
end
function HUDPowerTargetIdle:talentIsActive()
    local target = self.targetPercent()
    self.idleCurve:ClearPoints()
    self.idleCurve:AddPoint(target - 1, 1)
    self.idleCurve:AddPoint(target - 0.011, 1)
    self.idleCurve:AddPoint(target - 0.01, 0)
    self.idleCurve:AddPoint(target + 0.01, 0)
    self.idleCurve:AddPoint(target + 0.011, 1)
    self.idleCurve:AddPoint(target + 1, 1)
end
function HUDPowerTargetIdle:updateIdleAlpha()
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.idleCurve)
end

----------------------------------------------------------------
--- GENERIC TIMER ----------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDTimer : HUDDataItem
---@field private __index HUDTimer
---@field protected constructTimer fun(self:HUDTimer, hud:HUDModule, talent:ERALIBTalent|nil)
---@field protected updateDuration fun(self:HUDTimer, t:number): LuaDurationObject
---@field duration LuaDurationObject
HUDTimer = {}
HUDTimer.__index = HUDTimer
setmetatable(HUDTimer, { __index = HUDDataItem })

function HUDTimer:constructTimer(hud, talent)
    self:constructItem(hud, talent)
end

function HUDTimer:Update(t)
    self.duration = self:updateDuration(t)
end

----------------------------------------------------------------
--- COOLDOWN ---------------------------------------------------
----------------------------------------------------------------

---@class (exact) HUDCooldown : HUDTimer
---@field private __index HUDCooldown
---@field spellID number
---@field cdData SpellCooldownInfo
HUDCooldown = {}
HUDCooldown.__index = HUDCooldown
setmetatable(HUDCooldown, { __index = HUDTimer })

---comment
---@param spellID number
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@return HUDCooldown
function HUDCooldown:Create(spellID, hud, talent)
    local x = {}
    setmetatable(x, HUDCooldown)
    ---@cast x HUDCooldown
    x:constructTimer(hud, talent)

    x.spellID = spellID

    return x
end

function HUDCooldown:updateDuration(t)
    self.cdData = C_Spell.GetSpellCooldown(self.spellID)
    return C_Spell.GetSpellCooldownDuration(self.spellID)
end

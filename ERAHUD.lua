ERAHUD_TimerGCDCount = 5

---@class ERAHUD
---@field remGCD number
---@field totGCD number
---@field hasteMultiplier number
---@field timerDuration number
---@field private baseGCD number
---@field private minGCD number
---@field private timers ERATimer[]
---@field private activeTimers ERATimer[]
---@field private buffs ERAAURA[]
---@field private activeBuffs table<number, ERAAURA>
---@field private debuffs ERAAURA[]
---@field private activeDebuffs table<number, ERAAURA>
---@field private updateData fun(this:ERAHUD, t:number)
---@field private EnterCombat fun(this:ERAHUD)
---@field private ExitCombat fun(this:ERAHUD)
---@field private ResetToIdle fun(this:ERAHUD)
---@field private CheckTalents fun(this:ERAHUD)

---@class ERAHUD : ERACombatModule
ERAHUD = {}
ERAHUD.__index = ERAHUD
setmetatable(ERAHUD, { __index = ERACombatModule })

---@param cFrame ERACombatFrame
---@param baseGCD number
---@param requireCLEU boolean
---@param spec number
---@return ERAHUD
function ERAHUD:Create(cFrame, baseGCD, requireCLEU, spec)
    local hud = {}
    setmetatable(hud, ERAHUD)
    ---@cast hud ERAHUD

    -- data
    hud.remGCD = 0
    hud.totGCD = baseGCD
    hud.baseGCD = baseGCD
    if baseGCD > 1 then
        hud.minGCD = 0.75
    else
        baseGCD = 1
    end
    hud.hasteMultiplier = 1
    hud.timerDuration = baseGCD * ERAHUD_TimerGCDCount

    -- data content
    hud.timers = {}
    hud.activeTimers = {}
    hud.buffs = {}
    hud.activeBuffs = {}
    hud.debuffs = {}
    hud.activeDebuffs = {}

    hud:construct(cFrame, 0.2, 0.02, requireCLEU, spec)
    return hud
end

function ERAHUD:EnterCombat()
end

function ERAHUD:ExitCombat()
end

function ERAHUD:ResetToIdle()
end
function ERAHUD:OnResetToIdleOverride()
end

function ERAHUD:CheckTalents()
    self.activeTimers = {}
    for _, t in ipairs(self.timers) do
        if (t:checkTalent()) then
            table.insert(self.activeTimers, t)
        end
    end
    self.activeBuffs = {}
    for _, a in ipairs(self.buffs) do
        if a.talentActive then
            self.activeBuffs[a.spellID] = a
        end
    end
    self.activeDebuffs = {}
    for _, a in ipairs(self.debuffs) do
        if a.talentActive then
            self.activeDebuffs[a.spellID] = a
        end
    end
end

------------
--- DATA ---
------------

---@param t ERATimer
function ERAHUD:addTimer(t)
    table.insert(self.timers, t)
end

---@param a ERAAURA
function ERAHUD:addBuff(a)
    table.insert(self.buffs, a)
end
---@param a ERAAURA
function ERAHUD:addDebuff(a)
    table.insert(self.debuffs, a)
end

---@param t number
function ERAHUD:updateData(t)
    self.hasteMultiplier = 100 / (1 + GetHaste())
    local cdInfo = C_Spell.GetSpellCooldown(61304)
    self.totGCD = math.max(self.minGCD, self.baseGCD * self.hasteMultiplier)
    if (cdInfo and cdInfo.startTime and cdInfo.startTime > 0) then
        self.remGCD = cdInfo.duration - (t - cdInfo.startTime)
    else
        self.remGCD = 0
    end
    self.timerDuration = self.totGCD * ERAHUD_TimerGCDCount

    for i = 1, 40 do
        local auraInfo = C_UnitAuras.GetDebuffDataByIndex("target", i, "PLAYER")
        if (auraInfo) then
            local a = self.activeDebuffs[auraInfo.spellId]
            if (a ~= nil) then
                a:auraFound(t, auraInfo)
            end
        else
            break
        end
    end
    for i = 1, 40 do
        local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i, "PLAYER")
        if (auraInfo) then
            local a = self.activeBuffs[auraInfo.spellId]
            if (a ~= nil) then
                a:auraFound(t, auraInfo)
            end
        else
            break
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE TAKEN ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
---@class ERACombatDamageTaken : ERACombatModule
---@field currentDamage number
---@field windowDuration number
---@field private first ERACombatDamageEvent | nil
---@field private last ERACombatDamageEvent | nil
---@field private link ERACombatDamageEvent
---@field private lastUpdate number
---@field updateIfNecessary fun(this:ERACombatDamageTaken, t:number)
---@field hasEvents fun(this:ERACombatDamageTaken): boolean
---@field DamageUpdatedOverride fun(this:ERACombatDamageTaken, t:number)

---@class ERACombatDamageTaken
ERACombatDamageTaken = {}
ERACombatDamageTaken.__index = ERACombatDamageTaken
setmetatable(ERACombatDamageTaken, { __index = ERACombatModule })

---comment
---@param cFrame ERACombatFrame
---@param windowDuration number
---@param ... number specializations
---@return ERACombatDamageTaken
function ERACombatDamageTaken:Create(cFrame, windowDuration, ...)
    local dt = {}
    setmetatable(dt, ERACombatDamageTaken)
    dt:construct(cFrame, -1, 0.1, true, ...)
    dt.windowDuration = windowDuration

    dt.link = ERACombatDamageEvent:create(nil, dt)
    local current = dt.link
    for i = 2, 256 do
        current = ERACombatDamageEvent:create(current, dt)
    end
    dt.link.nxt = current
    dt.first = nil
    dt.last = nil
    dt.currentDamage = 0
    dt.lastUpdate = 0

    return dt
end

function ERACombatDamageTaken:ExitCombat()
    self.currentDamage = 0
    local current = self.first
    if (current) then
        local nxtlast = self.last.nxt
        repeat
            current:hide()
            current = current.nxt
        until (current == nxtlast)
        self.first = nil
        self.last = nil
    end
end

function ERACombatDamageTaken:ResetToIdle()
    self:ExitCombat()
end
function ERACombatDamageTaken:SpecInactive(wasActive)
    if (wasActive) then
        self:ExitCombat()
    end
end

function ERACombatDamageTaken:CLEU(t)
    local _, evt, _, _, _, _, _, destGUY, _, _, _, dmgIfSwing, _, _, dmgIfSpell, absIfSwing, _, _, _, absIfSpell = CombatLogGetCurrentEventInfo()
    if (destGUY == self.cFrame.playerGUID) then
        local dmg
        if (evt == "SWING_DAMAGE") then
            if (absIfSwing) then
                dmg = dmgIfSwing + absIfSwing
            else
                dmg = dmgIfSwing
            end
        elseif (evt == "SPELL_DAMAGE" or evt == "SPELL_PERIODIC_DAMAGE" or evt == "RANGE_DAMAGE") then
            if (absIfSpell) then
                dmg = dmgIfSpell + absIfSpell
            else
                dmg = dmgIfSpell
            end
        else
            return
        end
        local chosenOne
        if (self.last) then
            if (self.last.nxt == self.first) then
                -- plus de place
                return
            else
                chosenOne = self.last.nxt
            end
        else
            self.first = self.link
            chosenOne = self.link
        end
        self.last = chosenOne
        chosenOne.t = t
        chosenOne.dmg = dmg
    end
end

---@param w ERACombatDamageTakenWindow
function ERACombatDamageTaken:setupWindow(w)
    local current = self.link
    ---@cast current ERACombatDamageEventLine
    repeat
        ERACombatDamageEventLine_setupLine(current, w)
        current = current.nxt
    until (current == self.link)
end

function ERACombatDamageTaken:UpdateCombat(t, elapsed)
    self:updateIfNecessary(t)
end

function ERACombatDamageTaken:updateIfNecessary(t)
    if (t > self.lastUpdate) then
        self.lastUpdate = t
        if (self.first) then
            local tPast = t - self.windowDuration
            while (self.first.t <= tPast) do
                self.first:hide()
                if (self.first == self.last) then
                    self.first = nil
                    self.last = nil
                    break
                else
                    self.first = self.first.nxt
                end
            end
        end
        self.currentDamage = 0
        local current = self.first
        if current then
            local nxtlast = self.last.nxt
            repeat
                self.currentDamage = self.currentDamage + current.dmg
                current = current.nxt
            until (current == nxtlast)
        end
        self:DamageUpdatedOverride(t)
    end
end
function ERACombatDamageTaken:DamageUpdatedOverride(t)
end

---@return boolean
function ERACombatDamageTaken:hasEvents()
    return self.first ~= nil
end

---@param p ERACombatDamageCurvePoint
function ERACombatDamageTaken:prepareCurvePoint(p)
    local current = self.first
    ---@cast current ERACombatDamageEventLine
    local nxtlast = self.last.nxt
    repeat
        p:add(current)
        current = current.nxt
    until (current == nxtlast)
end

function ERACombatDamageTaken:drawLines(max, tPast)
    local current = self.first
    ---@cast current ERACombatDamageEventLine
    local nxtlast = self.last.nxt
    repeat
        current:draw(max, tPast)
        current = current.nxt
    until (current == nxtlast)
end

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE WINDOW ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class ERACombatDamageTakenWindow
---@field timers ERACombatTimers
---@field dt ERACombatDamageTaken
---@field private frame Frame
---@field chart Frame
---@field height number
---@field scaleY number
---@field width number
---@field pointsCount number
---@field private points ERACombatDamageCurvePoint[]

---@class ERACombatDamageTakenWindow
ERACombatDamageTakenWindow = {}
ERACombatDamageTakenWindow.__index = ERACombatDamageTakenWindow
setmetatable(ERACombatDamageTakenWindow, { __index = ERACombatModuleNestedInTimers })

---@param timers ERACombatTimers
---@param dt ERACombatDamageTaken
---@param height number
---@param initWidth number
---@param spec number
function ERACombatDamageTakenWindow:Create(timers, dt, height, initWidth, spec)
    local w = {}
    w.frame = CreateFrame("Frame", nil, timers.frame, "ERACombatDamageWindowFrame")
    w.brText = w.frame.BRText
    w.chart = w.frame.Chart
    setmetatable(w, ERACombatDamageTakenWindow)
    w:constructNested(timers, 0, 0, "BOTTOMRIGHT", false, spec)
    ---@cast w ERACombatDamageTakenWindow
    w.dt = dt
    w.frame:SetSize(initWidth, height)
    w.width = initWidth
    w.height = height
    w.scaleY = 0.5

    -- points
    w.points = {}
    w.pointsCount = 64
    for i = 1, w.pointsCount do
        table.insert(w.points, ERACombatDamageCurvePoint:create(w))
    end

    dt:setupWindow(w)

    ERALIB_SetFont(w.brText, 50)
end

function ERACombatDamageTakenWindow:updateAsNested_returnHeightForTimerOverlay(t)
    self.dt:updateIfNecessary(t)

    local w = ERACombat_TimerWidth * (self.dt.windowDuration / self.timers.timerStandardDuration)
    if (self.width ~= w) then
        self.width = w
        self.frame:SetSize(w, self.height)
    end

    if (not self.dt:hasEvents()) then
        for i, p in ipairs(self.points) do
            p.dmg = 0
            p:draw(1, 1, i)
        end
        return 0
    end

    local tPast = t - self.dt.windowDuration
    local delta = self.dt.windowDuration / self.pointsCount

    for i, p in ipairs(self.points) do
        p:prepareUpdate(tPast + i * delta)
    end

    local max = UnitHealthMax("player") * self.scaleY

    for _, p in ipairs(self.points) do
        self.dt:prepareCurvePoint(p)
    end

    local prv = 0
    for i, p in ipairs(self.points) do
        p:draw(max, prv, i)
        prv = p.y
    end

    self.dt:drawLines(max, tPast)
end

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE EVENT ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class ERACombatDamageEvent
---@field t number
---@field dmg number
---@field nxt ERACombatDamageEvent|nil
---@field protected dt ERACombatDamageTaken
---@field hide fun(this:ERACombatDamageEvent)

---@class ERACombatDamageEvent
ERACombatDamageEvent = {}
ERACombatDamageEvent.__index = ERACombatDamageEvent

---@param nxt ERACombatDamageEvent|nil
---@param dt ERACombatDamageTaken
---@return ERACombatDamageEvent
function ERACombatDamageEvent:create(nxt, dt)
    local evt = {}
    setmetatable(evt, ERACombatDamageEvent)
    evt.t = 0
    evt.dmg = 0
    evt.nxt = nxt
    evt.dt = dt
    return evt
end

function ERACombatDamageEvent:hide()
end

---@class ERACombatDamageEventLine : ERACombatDamageEvent
---@field line Line
---@field w ERACombatDamageTakenWindow
---@field visible boolean

---@class ERACombatDamageEventLine
ERACombatDamageEventLine = {}
ERACombatDamageEventLine.__index = ERACombatDamageEventLine
setmetatable(ERACombatDamageEventLine, { __index = ERACombatDamageEvent })

---@param x ERACombatDamageEvent
---@param w ERACombatDamageTakenWindow
function ERACombatDamageEventLine_setupLine(x, w)
    ---@cast x ERACombatDamageEventLine
    x.w = w
    x.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatDamageWindowDELine")
    x.line:Hide()
    x.visible = false
end

function ERACombatDamageEventLine:hide()
    if (self.visible) then
        self.visible = false
        self.line:Hide()
    end
end

---@param max number
---@param tPast number
function ERACombatDamageEventLine:draw(max, tPast)
    local x = self.w.width * (1 - (self.t - tPast) / self.w.dt.windowDuration)
    self.line:SetStartPoint("BOTTOMLEFT", self.w.chart, x, 0)
    local y
    if (self.dmg > max) then
        y = self.w.height
    else
        y = self.w.height * (self.dmg / max)
    end
    self.line:SetEndPoint("BOTTOMLEFT", self.w.chart, x, y)
    if (not self.visible) then
        self.visible = true
        self.line:Show()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- CURVE POINT -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class ERACombatDamageCurvePoint
---@field dmg number
---@field private t number
---@field  y number
---@field private w ERACombatDamageTakenWindow
---@field private line Line

---@class ERACombatDamageCurvePoint
ERACombatDamageCurvePoint = {}
ERACombatDamageCurvePoint.__index = ERACombatDamageCurvePoint

---@param w ERACombatDamageTakenWindow
---@return ERACombatDamageCurvePoint
function ERACombatDamageCurvePoint:create(w)
    local p = {}
    setmetatable(p, ERACombatDamageCurvePoint)
    p.dmg = 0
    p.w = w
    p.y = 0
    p.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatDamageWindowCurveLine")
    return p
end

---@param tPoint number
function ERACombatDamageCurvePoint:prepareUpdate(tPoint)
    self.t = tPoint
    self.dmg = 0
end

---@param de ERACombatDamageEvent
function ERACombatDamageCurvePoint:add(de)
    self.dmg = self.dmg + de.dmg / (1 + math.pow(4 * math.abs(de.t - self.t), 4))
end

---@param max number
---@param prvY number
---@param i number
function ERACombatDamageCurvePoint:draw(max, prvY, i)
    if (self.dmg > 0) then
        if (self.dmg >= max) then
            self.y = self.w.height - 1
        else
            self.y = self.w.height * self.dmg / max
        end
    else
        self.y = 1
    end
    self.line:SetStartPoint("BOTTOMLEFT", self.w.chart, self.w.width * (1 - ((i - 1) / self.w.pointsCount)), prvY)
    self.line:SetEndPoint("BOTTOMLEFT", self.w.chart, self.w.width * (1 - (i / self.w.pointsCount)), self.y)
end

---@class ERAHUDDamageTakenWindow : ERAHUDNestedModule
---@field private __index unknown
---@field dt ERACombatDamageTaken
---@field private frame Frame
---@field brText FontString
---@field chart Frame
---@field height number
---@field scaleY number
---@field width number
---@field pointsCount number
---@field private points ERAHUDDamageCurvePoint[]
ERAHUDDamageTakenWindow = {}
ERAHUDDamageTakenWindow.__index = ERAHUDDamageTakenWindow
setmetatable(ERAHUDDamageTakenWindow, { __index = ERAHUDNestedModule })

---@param hud ERAHUD
---@param dt ERACombatDamageTaken
---@param height number
---@param initWidth number
function ERAHUDDamageTakenWindow:Create(hud, dt, height, initWidth)
    local w = {}

    setmetatable(w, ERAHUDDamageTakenWindow)
    ---@cast w ERAHUDDamageTakenWindow
    local timerFrame = w:constructNested(hud, false)
    local frame = CreateFrame("Frame", nil, timerFrame, "ERACombatDamageWindowFrame")
    w.brText = frame.BRText
    w.chart = frame.Chart
    ---@cast frame Frame
    w.frame = frame
    w.dt = dt
    w.frame:SetSize(initWidth, height)
    w.width = initWidth
    w.height = height
    w.scaleY = 0.5

    -- points
    w.points = {}
    w.pointsCount = 64
    for i = 1, w.pointsCount do
        table.insert(w.points, ERAHUDDamageCurvePoint:create(w))
    end

    dt:setupWindow(w)

    ERALIB_SetFont(w.brText, 50)
end

function ERAHUDDamageTakenWindow:show()
    self.frame:Show()
end
function ERAHUDDamageTakenWindow:hide()
    self.frame:Hide()
end

---@param t number
function ERAHUDDamageTakenWindow:updateData(t)
    -- traité dans self.dt
end

---@param t number
---@param y number
---@param timerFrame Frame
---@param overlayFrame Frame
function ERAHUDDamageTakenWindow:updateDisplay_returnHeight(t, y, timerFrame, overlayFrame)
    self.dt:updateIfNecessary(t)

    self.frame:SetPoint("BOTTOMRIGHT", timerFrame, "RIGHT", 0, y)

    local w = ERAHUD_TimerWidth * (self.dt.windowDuration / self.hud.timerDuration)
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

    return self.height
end

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE EVENT ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class ERAHUDDamageEventLine : ERACombatDamageEvent
---@field line Line
---@field w ERAHUDDamageTakenWindow
---@field visible boolean
ERAHUDDamageEventLine = {}
ERAHUDDamageEventLine.__index = ERAHUDDamageEventLine
setmetatable(ERAHUDDamageEventLine, { __index = ERACombatDamageEvent })

---@param x ERACombatDamageEvent
---@param w ERAHUDDamageTakenWindow
function ERAHUDDamageEventLine_setupLine(x, w)
    ---@cast x ERAHUDDamageEventLine
    x.w = w
    x.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatDamageWindowDELine")
    x.line:Hide()
    x.visible = false
    setmetatable(x, ERAHUDDamageEventLine)
end

function ERAHUDDamageEventLine:hide()
    if (self.visible) then
        self.visible = false
        self.line:Hide()
    end
end

---@param max number
---@param tPast number
function ERAHUDDamageEventLine:draw(max, tPast)
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

---@class ERAHUDDamageCurvePoint
---@field dmg number
---@field private t number
---@field  y number
---@field private w ERAHUDDamageTakenWindow
---@field private line Line
ERAHUDDamageCurvePoint = {}
ERAHUDDamageCurvePoint.__index = ERAHUDDamageCurvePoint

---@param w ERAHUDDamageTakenWindow
---@return ERAHUDDamageCurvePoint
function ERAHUDDamageCurvePoint:create(w)
    local p = {}
    setmetatable(p, ERAHUDDamageCurvePoint)
    p.dmg = 0
    p.w = w
    p.y = 0
    p.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatDamageWindowCurveLine")
    return p
end

---@param tPoint number
function ERAHUDDamageCurvePoint:prepareUpdate(tPoint)
    self.t = tPoint
    self.dmg = 0
end

---@param de ERACombatDamageEvent
function ERAHUDDamageCurvePoint:add(de)
    self.dmg = self.dmg + de.dmg / (1 + math.pow(4 * math.abs(de.t - self.t), 4))
end

---@param max number
---@param prvY number
---@param i number
function ERAHUDDamageCurvePoint:draw(max, prvY, i)
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

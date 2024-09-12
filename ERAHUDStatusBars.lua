ERAHUDStatusBar_PrevisionHalfThickness = 2

---@class (exact) ERAHUDStatusBar
---@field private __index unknown
---@field visible boolean
---@field max number
---@field value number
---@field private minus number
---@field private plus number
---@field private forecast number
---@field private mainVisible boolean
---@field private minusVisible boolean
---@field private plusVisible boolean
---@field private forecastHVisible boolean
---@field private forecastVVisible boolean
---@field private maskBar fun(this:ERAHUDStatusBar, left:MaskTexture, right:MaskTexture, barSideWidth:number)
---@field private updateHeight fun(this:ERAHUDStatusBar)
---@field private update fun(this:ERAHUDStatusBar)
---@field private frame Frame
---@field private overlay Frame
---@field width number
---@field private height number
---@field private borderThickness number
---@field private mainBar Texture
---@field private minusBar Texture
---@field private plusBar Texture
---@field private forecastH Line
---@field private forecastV Line
---@field private borderLeft Texture
---@field private borderRight Texture
---@field private borderTop Texture
---@field private borderBottom Texture
---@field private maskBarsLeft MaskTexture
---@field private maskBarsRight MaskTexture
---@field private maskBGLeft MaskTexture
---@field private maskBGRight MaskTexture
---@field private maskMainLeft MaskTexture
---@field private maskMainRight MaskTexture
---@field private maskMainMiddle MaskTexture
---@field private r number
---@field private g number
---@field private b number
---@field private rB number
---@field private gB number
---@field private bB number
---@field private rF number
---@field private gF number
---@field private bF number
---@field private x number
---@field private y number
---@field private markings ERAHUDStatusMarking[]
---@field private activeMarkings ERAHUDStatusMarking[]
ERAHUDStatusBar = {}
ERAHUDStatusBar.__index = ERAHUDStatusBar

---@param parentFrame Frame
---@param x number
---@param y number
---@param barWidth number
---@param barHeight number
---@param r number
---@param g number
---@param b number
---@return ERAHUDStatusBar
function ERAHUDStatusBar:create(parentFrame, x, y, barWidth, barHeight, r, g, b)
    local bar = {}
    setmetatable(bar, ERAHUDStatusBar)
    ---@cast bar ERAHUDStatusBar

    local frame = CreateFrame("Frame", nil, parentFrame, "ERACombatStatusBarFrameXML")

    local mainBar = frame.MAIN_BAR
    local minusBar = frame.MINUS_BAR
    local plusBar = frame.PLUS_BAR
    local forecastH = frame.FORECAST_H
    local forecastV = frame.FORECAST_V
    bar.mainBar = mainBar
    bar.minusBar = minusBar
    bar.plusBar = plusBar
    bar.forecastH = forecastH
    bar.forecastV = forecastV

    ---@type MaskTexture
    local maskBarsLeft = frame.MASK_BARS_LEFT
    maskBarsLeft:ClearAllPoints()
    ---@type MaskTexture
    local maskBarsRight = frame.MASK_BARS_RIGHT
    maskBarsRight:ClearAllPoints()
    ---@type MaskTexture
    local maskMainLeft = frame.MASK_MAIN_LEFT
    maskMainLeft:ClearAllPoints()
    ---@type MaskTexture
    local maskMainRight = frame.MASK_MAIN_RIGHT
    maskMainRight:ClearAllPoints()
    ---@type MaskTexture
    local maskMainMiddle = frame.MASK_MAIN_MIDDLE
    ---@type MaskTexture
    local maskBGLeft = frame.MASK_BG_LEFT
    ---@type MaskTexture
    local maskBGRight = frame.MASK_BG_RIGHT
    ---@type Texture
    local borderRight = frame.BORDER_RIGHT
    ---@type Texture
    local borderLeft = frame.BORDER_LEFT
    ---@type Texture
    local borderTop = frame.BORDER_TOP
    ---@type Texture
    local borderBottom = frame.BORDER_BOTTOM

    bar.maskBarsLeft = maskBarsLeft
    bar.maskBarsRight = maskBarsRight
    bar.maskMainLeft = maskMainLeft
    bar.maskMainRight = maskMainRight
    bar.maskMainMiddle = maskMainMiddle
    bar.maskBGLeft = maskBGLeft
    bar.maskBGRight = maskBGRight
    bar.borderLeft = borderLeft
    bar.borderTop = borderTop
    bar.borderRight = borderRight
    bar.borderBottom = borderBottom

    ---@cast frame Frame
    bar.frame = frame
    frame:SetPoint("TOP", parentFrame, "CENTER", x, y)
    frame:SetSize(barWidth, barHeight)

    bar.width = barWidth
    bar.height = barHeight
    bar.borderThickness = barHeight / 8

    bar:updateHeight()

    bar.r = r
    bar.g = g
    bar.b = b
    bar.mainBar:SetVertexColor(r, g, b, 1)
    bar.rB = 1
    bar.gB = 1
    bar.bB = 1
    bar:SetBorderColor(0.9, 0.9, 0.9)
    bar.rF = 0.5
    bar.gF = 0.5
    bar.bF = 1.0

    bar.max = 1
    bar.value = 0
    bar.minus = 0
    bar.plus = 0
    bar.forecast = 0

    bar.mainBar:Hide()
    bar.mainVisible = false
    bar.minusBar:Hide()
    bar.minusVisible = false
    bar.plusBar:Hide()
    bar.plusVisible = false
    bar.forecastH:Hide()
    bar.forecastV:Hide()
    bar.forecastVVisible = false
    bar.forecastHVisible = false

    bar.overlay = CreateFrame("Frame", nil, frame)
    bar.overlay:SetFrameLevel(2)
    bar.overlay:SetAllPoints()
    bar.markings = {}
    bar.activeMarkings = {}

    bar.x = x
    bar.y = y

    bar.visible = true
    self:hide()

    return bar
end

---@param left MaskTexture
---@param right MaskTexture
---@param barSideWidth number
function ERAHUDStatusBar:maskBar(left, right, barSideWidth)
    left:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.borderThickness, -self.borderThickness)
    left:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.borderThickness, self.borderThickness)
    left:SetWidth(barSideWidth)
    right:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -self.borderThickness, -self.borderThickness)
    right:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -self.borderThickness, self.borderThickness)
    right:SetWidth(barSideWidth)
end

function ERAHUDStatusBar:updateHeight()
    self.frame:SetHeight(self.height)
    local sideWidth = self.height / 2
    self.maskBGLeft:SetWidth(sideWidth)
    self.maskBGRight:SetWidth(sideWidth)
    self.borderLeft:SetWidth(sideWidth)
    self.borderRight:SetWidth(sideWidth)
    self.borderTop:SetSize(self.width - 2 * sideWidth, self.borderThickness)
    self.borderBottom:SetSize(self.width - 2 * sideWidth, self.borderThickness)
    local barSideWidth = (self.height - 2 * self.borderThickness) / 2
    self:maskBar(self.maskBarsLeft, self.maskBarsRight, barSideWidth)
    self:maskBar(self.maskMainLeft, self.maskMainRight, barSideWidth)
    self.maskMainMiddle:SetPoint("TOPLEFT", self.frame, "TOPLEFT", barSideWidth, -self.borderThickness)
    self.maskMainMiddle:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", barSideWidth, self.borderThickness)
    self.maskMainMiddle:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -barSideWidth, -self.borderThickness)
    self.maskMainMiddle:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -barSideWidth, self.borderThickness)
    self.mainBar:ClearAllPoints()
    self.mainBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.borderThickness, -self.borderThickness)
    self.mainBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.borderThickness, self.borderThickness)
end

function ERAHUDStatusBar:show()
    if not self.visible then
        self.visible = true
        self.frame:Show()
    end
end
function ERAHUDStatusBar:hide()
    if self.visible then
        self.visible = false
        self.frame:Hide()
    end
end

function ERAHUDStatusBar:checkTalents()
    table.wipe(self.activeMarkings)
    for _, m in ipairs(self.markings) do
        if not (m.talent and not m.talent:PlayerHasTalent()) then
            table.insert(self.activeMarkings, m)
        else
            m:hide()
        end
    end
end

---@param x number
---@param y number
---@param height number
---@param parentFrame Frame
function ERAHUDStatusBar:place(x, y, height, parentFrame)
    if self.x ~= x or self.y ~= y or self.height ~= height then
        self.x = x
        self.y = y
        self.height = height
        self.frame:SetPoint("TOP", parentFrame, "CENTER", x, y)
        self.frame:SetHeight(height)
        self:updateHeight()
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDStatusBar:SetBorderColor(r, g, b)
    if (self.rB ~= r or self.gB ~= g or self.bB ~= b) then
        self.rB = r
        self.gB = g
        self.bB = b
        self.borderLeft:SetVertexColor(r, g, b, 1)
        self.borderTop:SetVertexColor(r, g, b, 1)
        self.borderRight:SetVertexColor(r, g, b, 1)
        self.borderBottom:SetVertexColor(r, g, b, 1)
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDStatusBar:SetMainColor(r, g, b)
    if (self.r ~= r or self.g ~= g or self.b ~= b) then
        self.r = r
        self.g = g
        self.b = b
        self.mainBar:SetVertexColor(r, g, b, 1)
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDStatusBar:SetPrevisionColor(r, g, b)
    if (self.rF ~= r or self.gF ~= g or self.bF ~= b) then
        self.rF = r
        self.gF = g
        self.bF = b
        self.forecastH:SetColorTexture(r, g, b, 1)
        self.forecastV:SetColorTexture(r, g, b, 1)
    end
end

---@param value number
---@param max number
function ERAHUDStatusBar:SetValueAndMax(value, max)
    local do_update = false
    if (self.value ~= value) then
        self.value = math.max(0, value)
        do_update = true
    end
    if self.max ~= max then
        self.max = max
        do_update = true
    end
    if do_update then
        self:update()
    end
end
---@param x number
function ERAHUDStatusBar:SetMax(x)
    if (self.max ~= x) then
        if (x <= 0) then
            self.max = 1
        else
            self.max = x
        end
        self:update()
    end
end
---@param x number
function ERAHUDStatusBar:SetValue(x)
    if (self.value ~= x) then
        self.value = math.max(0, x)
        self:update()
    end
end
---@param x number
function ERAHUDStatusBar:SetMinus(x)
    if (self.minus ~= x) then
        self.minus = x
        self:update()
    end
end
---@param x number
function ERAHUDStatusBar:SetPlus(x)
    if (self.plus ~= x) then
        self.plus = x
        self:update()
    end
end
---@param x number
function ERAHUDStatusBar:SetForecast(x)
    if (self.forecast ~= x) then
        self.forecast = x
        self:update()
    end
end
---@param max number
---@param value number
---@param minus number
---@param plus number
---@param forecast number
function ERAHUDStatusBar:SetAll(max, value, minus, plus, forecast)
    if (self.max ~= max or self.value ~= value or self.minus ~= minus or self.plus ~= plus or self.forecast ~= forecast) then
        self.max = max
        self.value = value
        self.minus = minus
        self.plus = plus
        self.forecast = forecast
        self:update()
    end
end
---@param max number
---@param value number
---@param minus number
---@param plus number
function ERAHUDStatusBar:SetAllExceptForecast(max, value, minus, plus)
    if (self.max ~= max or self.value ~= value or self.minus ~= minus or self.plus ~= plus) then
        self.max = max
        self.value = value
        self.minus = minus
        self.plus = plus
        self:update()
    end
end

---@param value number
---@return number
function ERAHUDStatusBar:CalcX(value)
    return self.borderThickness + value * (self.width - 2 * self.borderThickness) / self.max
end

function ERAHUDStatusBar:update()
    local w = self.width - 2 * self.borderThickness
    local ratio = w / self.max
    local xCurrent = math.min(w, ratio * self.value)
    local mainWidth
    if (self.minus > 0) then
        local valWidth
        if (self.minus >= self.value) then
            valWidth = 0
        else
            valWidth = (self.value - self.minus) * ratio
        end
        self.minusBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", valWidth + self.borderThickness, -self.borderThickness)
        self.minusBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", valWidth + self.borderThickness, self.borderThickness)
        self.minusBar:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", xCurrent + self.borderThickness, -self.borderThickness)
        self.minusBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", xCurrent + self.borderThickness, self.borderThickness)
        if (not self.minusVisible) then
            self.minusVisible = true
            self.minusBar:Show()
        end
        mainWidth = valWidth
    else
        mainWidth = xCurrent
        if (self.minusVisible) then
            self.minusVisible = false
            self.minusBar:Hide()
        end
    end
    if (mainWidth > 0) then
        if (not self.mainVisible) then
            self.mainVisible = true
            self.mainBar:Show()
        end
        self.mainBar:SetWidth(mainWidth)
    else
        if (self.mainVisible) then
            self.mainVisible = false
            self.mainBar:Hide()
        end
    end
    if (self.plus > 0) then
        local xPlus
        local total = self.value + self.plus
        if (total >= self.max) then
            xPlus = w
        else
            xPlus = total * ratio
        end
        self.plusBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", xCurrent + self.borderThickness, -self.borderThickness)
        self.plusBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", xCurrent + self.borderThickness, self.borderThickness)
        self.plusBar:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", xPlus + self.borderThickness, -self.borderThickness)
        self.plusBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", xPlus + self.borderThickness, self.borderThickness)
        if (not self.plusVisible) then
            self.plusVisible = true
            self.plusBar:Show()
        end
    else
        if (self.plusVisible) then
            self.plusVisible = false
            self.plusBar:Hide()
        end
    end
    if (self.forecast > 0) then
        local xFore
        local total = self.value + self.forecast
        if (total > self.max) then
            xFore = self.width - self.borderThickness
            if (self.forecastVVisible) then
                self.forecastVVisible = false
                self.forecastV:Hide()
            end
        else
            xFore = total * ratio + self.borderThickness
            local xV = xFore - ERACombatStatusBar_PrevisionHalfThickness
            self.forecastV:SetStartPoint("TOPLEFT", self.frame, xV, 0)
            self.forecastV:SetEndPoint("BOTTOMLEFT", self.frame, xV, 0)
            if (not self.forecastVVisible) then
                self.forecastVVisible = true
                self.forecastV:Show()
            end
        end
        self.forecastH:SetStartPoint("LEFT", self.frame, xCurrent + self.borderThickness, 0)
        self.forecastH:SetEndPoint("LEFT", self.frame, xFore, 0)
        if (not self.forecastHVisible) then
            self.forecastHVisible = true
            self.forecastH:Show()
        end
    else
        if (self.forecastHVisible) then
            self.forecastHVisible = false
            self.forecastVVisible = false
            self.forecastH:Hide()
            self.forecastV:Hide()
        end
    end
end

---@param m ERAHUDStatusMarking
function ERAHUDStatusBar:addMarking(m)
    table.insert(self.markings, m)
    return self.overlay
end

---@param t number
function ERAHUDStatusBar:updateMarkings(t)
    for _, m in ipairs(self.activeMarkings) do
        m:update(t, self.overlay)
    end
end

---@param baseValue number
---@param talent ERALIBTalent|nil
---@return ERAHUDStatusMarkingFrom0
function ERAHUDStatusBar:AddMarkingFrom0(baseValue, talent)
    return ERAHUDStatusMarkingFrom0:create(self, baseValue, talent)
end

---@param baseValue number
---@param talent ERALIBTalent|nil
---@return ERAHUDStatusMarkingFromMax
function ERAHUDStatusBar:AddMarkingFromMax(baseValue, talent)
    return ERAHUDStatusMarkingFromMax:create(self, baseValue, talent)
end

----------------
--- MARKINGS ---
----------------

---@class (exact) ERAHUDStatusMarking
---@field private __index unknown
---@field protected constructMarking fun(this:ERAHUDStatusMarking, bar:ERAHUDStatusBar, baseValue:number, talent:ERALIBTalent|nil)
---@field bar ERAHUDStatusBar
---@field baseValue number
---@field value number
---@field talent ERALIBTalent|nil
---@field UpdatedOverride fun(this:ERAHUDStatusMarking, t:number, line:Line)
---@field private line Line
---@field private x number
---@field ComputeValueOverride fun(this:ERAHUDStatusMarking, t:number): number
ERAHUDStatusMarking = {}
ERAHUDStatusMarking.__index = ERAHUDStatusMarking

---@param bar ERAHUDStatusBar
---@param baseValue number
---@param talent ERALIBTalent|nil
function ERAHUDStatusMarking:constructMarking(bar, baseValue, talent)
    self.bar = bar
    self.baseValue = baseValue
    self.talent = talent
    self.x = -1
    self.value = -1
    local frameOverlay = bar:addMarking(self)
    self.line = frameOverlay:CreateLine(nil, "OVERLAY", "ERACombatPowerTick")
end

function ERAHUDStatusMarking:hide()
    if self.x >= 0 then
        self.x = -1
        self.line:Hide()
    end
end

---@param t number
---@param frameOverlay Frame
function ERAHUDStatusMarking:update(t, frameOverlay)
    self.value = self:ComputeValueOverride(t)
    if self.value < 0 or self.value > self.bar.max then
        self:hide()
    else
        local x = self.bar:CalcX(self.value)
        if self.x ~= x then
            if self.x < 0 then
                self.line:Show()
            end
            self.line:SetStartPoint("BOTTOMLEFT", frameOverlay, x, 0)
            self.line:SetStartPoint("TOPLEFT", frameOverlay, x, 0)
            self.x = x
        end
        self:UpdatedOverride(t, self.line)
    end
end

---@class ERAHUDStatusMarkingFrom0 : ERAHUDStatusMarking
---@field private __index unknown
---@field private isGreen boolean
ERAHUDStatusMarkingFrom0 = {}
ERAHUDStatusMarkingFrom0.__index = ERAHUDStatusMarkingFrom0
setmetatable(ERAHUDStatusMarkingFrom0, { __index = ERAHUDStatusMarking })

---@param bar ERAHUDStatusBar
---@param baseValue number
---@param talent ERALIBTalent|nil
---@return ERAHUDStatusMarkingFrom0
function ERAHUDStatusMarkingFrom0:create(bar, baseValue, talent)
    local m = {}
    setmetatable(m, ERAHUDStatusMarkingFrom0)
    ---@cast m ERAHUDStatusMarkingFrom0
    m:constructMarking(bar, baseValue, talent)
    return m
end

---@param t number
function ERAHUDStatusMarkingFrom0:ComputeValueOverride(t)
    return self.baseValue
end
---@param t number
---@param line Line
function ERAHUDStatusMarkingFrom0:UpdatedOverride(t, line)
    if self.value >= self.bar.value then
        if not self.isGreen then
            self.isGreen = true
            line:SetVertexColor(0.0, 1.0, 0.0)
        end
    else
        if self.isGreen then
            self.isGreen = false
            line:SetVertexColor(1.0, 1.0, 1.0)
        end
    end
end

---@class ERAHUDStatusMarkingFromMax : ERAHUDStatusMarking
---@field private __index unknown
---@field private isRed boolean
ERAHUDStatusMarkingFromMax = {}
ERAHUDStatusMarkingFromMax.__index = ERAHUDStatusMarkingFromMax
setmetatable(ERAHUDStatusMarkingFromMax, { __index = ERAHUDStatusMarking })

---@param bar ERAHUDStatusBar
---@param baseValue number
---@param talent ERALIBTalent|nil
---@return ERAHUDStatusMarkingFromMax
function ERAHUDStatusMarkingFromMax:create(bar, baseValue, talent)
    local m = {}
    setmetatable(m, ERAHUDStatusMarkingFromMax)
    ---@cast m ERAHUDStatusMarkingFromMax
    m:constructMarking(bar, baseValue, talent)
    return m
end

---@param t number
function ERAHUDStatusMarkingFromMax:ComputeValueOverride(t)
    return self.bar.max - self.baseValue
end
---@param t number
---@param line Line
function ERAHUDStatusMarkingFromMax:UpdatedOverride(t, line)
    if self.value >= self.bar.value then
        if not self.isRed then
            self.isRed = true
            line:SetVertexColor(1.0, 0.0, 0.0)
        end
    else
        if self.isRed then
            self.isRed = false
            line:SetVertexColor(1.0, 1.0, 1.0)
        end
    end
end

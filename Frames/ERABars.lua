---@class (exact) ERAStatusBar
---@field private __index ERAStatusBar
---@field private parentFrame Frame
---@field private point "TOPLEFT"|"TOP"|"TOPRIGHT"
---@field private relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@field private mainFrame Frame
---@field private background Texture
---@field private bar StatusBar
---@field private left FontString|nil
---@field private middle FontString|nil
---@field private right FontString|nil
---@field private leftTxt string|nil
---@field private middleTxt string|nil
---@field private rightTxt string|nil
---@field private alpha number
---@field private visible boolean
---@field private barR number
---@field private barG number
---@field private barB number
---@field private minR number
---@field private minG number
---@field private minB number
---@field private maxR number
---@field private maxG number
---@field private maxB number
---@field private leftBorder Line
---@field private topBorder Line
---@field private rightBorder Line
---@field private bottomBorder Line
---@field private borderR number
---@field private borderG number
---@field private borderB number
---@field private borderThickness number
---@field private setupBarBorderThickness fun(self:ERAStatusBar, bar:StatusBar)
---@field private createText fun(self:ERAStatusBar, point:"LEFT"|"CENTER"|"RIGHT", offX:number): FontString
---@field private ensureMin fun(self:ERAStatusBar)
---@field private excessMin StatusBar|nil
---@field private excessMax StatusBar|nil
ERAStatusBar = {}
ERAStatusBar.__index = ERAStatusBar

---comment
---@param parentFrame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@return ERAStatusBar
function ERAStatusBar:Create(parentFrame, point, relativePoint)
    local x = {}
    setmetatable(x, ERAStatusBar)
    ---@cast x ERAStatusBar

    x.parentFrame = parentFrame
    x.point = point
    x.relativePoint = relativePoint

    x.mainFrame = CreateFrame("Frame", nil, parentFrame)

    x.background = x.mainFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    x.background:SetColorTexture(0.0, 0.0, 0.0, 0.8)
    x.background:SetAllPoints()

    x.bar = CreateFrame("StatusBar", nil, x.mainFrame)
    x.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    x.bar:SetFrameLevel(2)
    x.bar:SetMinMaxValues(0, 1)

    x.leftBorder = x.mainFrame:CreateLine()
    x.topBorder = x.mainFrame:CreateLine()
    x.rightBorder = x.mainFrame:CreateLine()
    x.bottomBorder = x.mainFrame:CreateLine()

    x:SetBorderThickness(4)
    x:SetBorderColor(1.0, 1.0, 1.0, false)

    return x
end

---comment
---@param x number
---@param y number
---@param width number
---@param height number
function ERAStatusBar:UpdateLayout(x, y, width, height)
    self.mainFrame:SetPoint(self.point, self.parentFrame, self.relativePoint, x, y)
    self.mainFrame:SetSize(width, height)
    if (self.left) then ERALIB_SetFont(self.left, height / 2) end
    if (self.middle) then ERALIB_SetFont(self.middle, height / 2) end
    if (self.right) then ERALIB_SetFont(self.right, height / 2) end
end

---comment
---@param visible boolean
function ERAStatusBar:SetActiveShown(visible)
    if (visible) then
        if (not self.visible) then
            self.visible = true
            self.mainFrame:Show()
        end
    else
        if (self.visible) then
            self.visible = false
            self.mainFrame:Hide()
        end
    end
end

---comment
---@param alpha number
---@param maybeSecret boolean
function ERAStatusBar:SetVisibilityAlpha(alpha, maybeSecret)
    if (maybeSecret) then
        self.alpha = nil
        self.mainFrame:SetAlpha(alpha)
    else
        if (self.alpha ~= alpha) then
            self.alpha = alpha
            self.mainFrame:SetAlpha(alpha)
        end
    end
end

---comment
---@param thick number
function ERAStatusBar:SetBorderThickness(thick)
    self.borderThickness = thick
    self:setupBarBorderThickness(self.bar)
    if (self.excessMin) then
        self:setupBarBorderThickness(self.excessMin)
    end
    if (self.excessMax) then
        self:setupBarBorderThickness(self.excessMax)
    end
    self.leftBorder:SetThickness(thick / 2)
    self.topBorder:SetThickness(thick / 2)
    self.rightBorder:SetThickness(thick / 2)
    self.bottomBorder:SetThickness(thick / 2)
    self.leftBorder:SetStartPoint("BOTTOMLEFT", self.mainFrame, thick / 2, thick / 4)
    self.leftBorder:SetEndPoint("TOPLEFT", self.mainFrame, thick / 2, -thick / 4)
    self.topBorder:SetStartPoint("TOPLEFT", self.mainFrame, thick / 4, -thick / 2)
    self.topBorder:SetEndPoint("TOPRIGHT", self.mainFrame, -thick / 4, -thick / 2)
    self.rightBorder:SetStartPoint("TOPRIGHT", self.mainFrame, -thick / 2, -thick / 4)
    self.rightBorder:SetEndPoint("BOTTOMRIGHT", self.mainFrame, -thick / 2, thick / 4)
    self.bottomBorder:SetStartPoint("BOTTOMRIGHT", self.mainFrame, -thick / 4, thick / 2)
    self.bottomBorder:SetEndPoint("BOTTOMLEFT", self.mainFrame, thick / 4, thick / 2)
end
function ERAStatusBar:setupBarBorderThickness(bar)
    bar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", self.borderThickness, -self.borderThickness)
    --bar:SetPoint("TOPRIGHT", self.mainFrame, "TOPLEFT", -self.borderThickness, -self.borderThickness)
    bar:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -self.borderThickness, self.borderThickness)
    --bar:SetPoint("BOTTOMLEFT", self.mainFrame, "BOTTOMLEFT", self.borderThickness, self.borderThickness)
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetBorderColor(r, g, b, maybeSecret)
    if (maybeSecret) then
        self.borderR = nil
        self.borderG = nil
        self.borderB = nil
        self.leftBorder:SetColorTexture(r, g, b, 1.0)
        self.topBorder:SetColorTexture(r, g, b, 1.0)
        self.rightBorder:SetColorTexture(r, g, b, 1.0)
        self.bottomBorder:SetColorTexture(r, g, b, 1.0)
    else
        if (r ~= self.borderR or g ~= self.borderG or b ~= self.borderB) then
            self.borderR = r
            self.borderG = g
            self.borderB = b
            self.leftBorder:SetColorTexture(r, g, b, 1.0)
            self.topBorder:SetColorTexture(r, g, b, 1.0)
            self.rightBorder:SetColorTexture(r, g, b, 1.0)
            self.bottomBorder:SetColorTexture(r, g, b, 1.0)
        end
    end
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetBarColor(r, g, b, maybeSecret)
    if (maybeSecret) then
        self.barR = nil
        self.barG = nil
        self.barB = nil
        self.bar:SetStatusBarColor(r, g, b, 1.0)
    else
        if (r ~= self.barR or g ~= self.barG or b ~= self.barB) then
            self.barR = r
            self.barG = g
            self.barB = b
            self.bar:SetStatusBarColor(r, g, b, 1.0)
        end
    end
end

---comment
---@param min number
---@param max number
function ERAStatusBar:SetMinMax(min, max)
    self.bar:SetMinMaxValues(min, max)
    if (self.excessMin) then
        self.excessMin:SetMinMaxValues(min, max)
    end
    if (self.excessMax) then
        self.excessMax:SetMinMaxValues(min, max)
    end
end
---comment
---@param val number
function ERAStatusBar:SetValue(val)
    self.bar:SetValue(val)
end

function ERAStatusBar:createText(point, offX)
    local txt = self.bar:CreateFontString(nil, "ARTWORK")
    txt:SetPoint(point, self.bar, point, offX, 0)
    ERALIB_SetFont(txt, self.mainFrame:GetHeight() / 2)
    return txt
end

---comment
---@param txt string
---@param maybeSecret boolean
function ERAStatusBar:SetLeftText(txt, maybeSecret)
    if (not self.left) then
        self.left = self:createText("LEFT", 2)
    end
    if (maybeSecret) then
        self.leftTxt = nil
        self.left:SetText(txt)
    else
        if (txt ~= self.leftTxt) then
            self.leftTxt = txt
            self.left:SetText(txt)
        end
    end
end

---comment
---@param txt string
---@param maybeSecret boolean
function ERAStatusBar:SetRightText(txt, maybeSecret)
    if (not self.right) then
        self.right = self:createText("RIGHT", -2)
    end
    if (maybeSecret) then
        self.rightTxt = nil
        self.right:SetText(txt)
    else
        if (txt ~= self.rightTxt) then
            self.rightTxt = txt
            self.right:SetText(txt)
        end
    end
end

---comment
---@param txt string
---@param maybeSecret boolean
function ERAStatusBar:SetMiddleText(txt, maybeSecret)
    if (not self.middle) then
        self.middle = self:createText("CENTER", 0)
    end
    if (maybeSecret) then
        self.middleTxt = nil
        self.middle:SetText(txt)
    else
        if (txt ~= self.middleTxt) then
            self.middleTxt = txt
            self.middle:SetText(txt)
        end
    end
end

function ERAStatusBar:ensureMin()
    if (not self.excessMin) then
        self.excessMin = CreateFrame("StatusBar", nil, self.mainFrame)
        self.excessMin:SetFrameLevel(3)
        self.excessMin:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        local min, max = self.bar:GetMinMaxValues()
        self.excessMin:SetMinMaxValues(min, max)
        self:setupBarBorderThickness(self.excessMin)
        self:SetExcessMinColor(0.0, 0.0, 1.0, false)
    end
end

function ERAStatusBar:ensureMax()
    if (not self.excessMax) then
        self.excessMax = CreateFrame("StatusBar", nil, self.mainFrame)
        self.excessMax:SetFrameLevel(4)
        self.excessMax:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        self.excessMax:SetReverseFill(true)
        local min, max = self.bar:GetMinMaxValues()
        self.excessMax:SetMinMaxValues(min, max)
        self:setupBarBorderThickness(self.excessMax)
        self:SetExcessMaxColor(1.0, 0.0, 0.0, false)
    end
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetExcessMinColor(r, g, b, maybeSecret)
    self:ensureMin()
    if (maybeSecret) then
        self.minR = nil
        self.minG = nil
        self.minB = nil
        self.excessMin:SetStatusBarColor(r, g, b, 0.666)
    else
        if (r ~= self.minR or g ~= self.minG or b ~= self.minB) then
            self.minR = r
            self.minG = g
            self.minB = b
            self.excessMin:SetStatusBarColor(r, g, b, 0.666)
        end
    end
end

---comment
---@param val number
function ERAStatusBar:SetExcessMin(val)
    self:ensureMin()
    self.excessMin:SetValue(val)
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetExcessMaxColor(r, g, b, maybeSecret)
    self:ensureMax()
    if (maybeSecret) then
        self.maxR = nil
        self.maxG = nil
        self.maxB = nil
        self.excessMax:SetStatusBarColor(r, g, b, 0.666)
    else
        if (r ~= self.maxR or g ~= self.maxG or b ~= self.maxB) then
            self.maxR = r
            self.maxG = g
            self.maxB = b
            self.excessMax:SetStatusBarColor(r, g, b, 0.666)
        end
    end
end

---comment
---@param val number
function ERAStatusBar:SetExcessMax(val)
    self:ensureMax()
    self.excessMax:SetValue(val)
end

--------------------------------------------------------------------------------------------------------------------------------
--#region CSTR  ----------------------------------------------------------------------------------------------------------------

---@class (exact) ERAStatusBar
---@field private __index ERAStatusBar
---@field private parentFrame Frame
---@field private point "TOPLEFT"|"TOP"|"TOPRIGHT"
---@field private relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@field private mainFrame Frame
---@field private background Texture
---@field private bar StatusBar
---@field private textFrame Frame
---@field private left FontString|nil
---@field private middle FontString|nil
---@field private right FontString|nil
---@field private leftTxt string|nil
---@field private middleTxt string|nil
---@field private rightTxt string|nil
---@field private alpha number
---@field private visible boolean
---@field private width number
---@field private barR number
---@field private barG number
---@field private barB number
---@field private addR number
---@field private addG number
---@field private addB number
---@field private subR number
---@field private subG number
---@field private subB number
---@field private leftBorder Line
---@field private topBorder Line
---@field private rightBorder Line
---@field private bottomBorder Line
---@field private borderR number
---@field private borderG number
---@field private borderB number
---@field private borderThickness number
---@field private modifAdditive StatusBar|nil
---@field private modifSubtractive StatusBar|nil
ERAStatusBar = {}
ERAStatusBar.__index = ERAStatusBar

---comment
---@param parentFrame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param frameLevel number|nil
---@return ERAStatusBar
function ERAStatusBar:Create(parentFrame, point, relativePoint, frameLevel)
    local x = {}
    setmetatable(x, ERAStatusBar)
    ---@cast x ERAStatusBar

    x.parentFrame = parentFrame
    x.point = point
    x.relativePoint = relativePoint
    x.width = 0

    x.mainFrame = CreateFrame("Frame", nil, parentFrame)
    if (frameLevel) then
        x.mainFrame:SetFrameLevel(frameLevel)
    end

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

    x.textFrame = CreateFrame("Frame", nil, x.bar)
    x.textFrame:SetFrameLevel(4)
    x.textFrame:SetAllPoints()

    x:SetBorderThickness(4)
    x:SetBorderColor(1.0, 1.0, 1.0, false)

    x.mainFrame:Hide()
    x.visible = false

    return x
end

---@return Frame
function ERAStatusBar:GetDrawFrame()
    return self.bar
end
---@return number
function ERAStatusBar:GetDrawFrameLevel()
    return 4
end
---@return number
function ERAStatusBar:GetBorderThickness()
    return self.borderThickness
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region LAYOUT & VISIBILITY  -------------------------------------------------------------------------------------------------

---comment
---@param x number
---@param y number
---@param width number
---@param height number
function ERAStatusBar:UpdateLayout(x, y, width, height)
    self.width = width
    self.mainFrame:SetPoint(self.point, self.parentFrame, self.relativePoint, x, y)
    self.mainFrame:SetSize(width, height)
    if (self.modifAdditive) then
        self:setupModifierWidth(self.modifAdditive)
    end
    if (self.modifSubtractive) then
        self:setupModifierWidth(self.modifSubtractive)
    end
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

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region BORDER  --------------------------------------------------------------------------------------------------------------

---comment
---@param thick number
function ERAStatusBar:SetBorderThickness(thick)
    self.borderThickness = thick
    self.bar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", thick, -thick)
    self.bar:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -thick, thick)
    if (self.modifAdditive) then
        self:setupModifierWidth(self.modifAdditive)
    end
    if (self.modifSubtractive) then
        self:setupModifierWidth(self.modifSubtractive)
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

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region VALUE  ---------------------------------------------------------------------------------------------------------------

---comment
---@param min number
---@param max number
function ERAStatusBar:SetMinMax(min, max)
    self.bar:SetMinMaxValues(min, max)
    if (self.modifAdditive) then
        self.modifAdditive:SetMinMaxValues(min, max)
    end
    if (self.modifSubtractive) then
        self.modifSubtractive:SetMinMaxValues(min, max)
    end
end
---comment
---@param val number
function ERAStatusBar:SetValue(val)
    self.bar:SetValue(val)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region MODIFIERS  -----------------------------------------------------------------------------------------------------------

---@private
---@param bar StatusBar
function ERAStatusBar:setupModifierWidth(bar)
    bar:SetWidth(self.width)
end

---@private
function ERAStatusBar:ensureAdditive()
    if (not self.modifAdditive) then
        self.modifAdditive = CreateFrame("StatusBar", nil, self.mainFrame)
        self.modifAdditive:SetFrameLevel(3)
        self.modifAdditive:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        local min, max = self.bar:GetMinMaxValues()
        self.modifAdditive:SetMinMaxValues(min, max)
        self:setupModifierWidth(self.modifAdditive)
        self:SetModifierAdditiveColor(0.1, 0.4, 1.0, false)
        local anchor = self.bar:GetStatusBarTexture()
        self.modifAdditive:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
        self.modifAdditive:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", 0, 0)
    end
end

---@private
function ERAStatusBar:ensureSubtractive()
    if (not self.modifSubtractive) then
        self.modifSubtractive = CreateFrame("StatusBar", nil, self.mainFrame)
        self.modifSubtractive:SetFrameLevel(3)
        self.modifSubtractive:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        self.modifSubtractive:SetReverseFill(true)
        local min, max = self.bar:GetMinMaxValues()
        self.modifSubtractive:SetMinMaxValues(min, max)
        self:setupModifierWidth(self.modifSubtractive)
        self:SetModifierSubtractiveColor(1.0, 0.0, 0.0, false)
        local anchor = self.bar:GetStatusBarTexture()
        self.modifSubtractive:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, 0)
        self.modifSubtractive:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
    end
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetModifierAdditiveColor(r, g, b, maybeSecret)
    self:ensureAdditive()
    if (maybeSecret) then
        self.addR = nil
        self.addG = nil
        self.addB = nil
        self.modifAdditive:SetStatusBarColor(r, g, b, 1.0)
    else
        if (r ~= self.addR or g ~= self.addG or b ~= self.addB) then
            self.addR = r
            self.addG = g
            self.addB = b
            self.modifAdditive:SetStatusBarColor(r, g, b, 1.0)
        end
    end
end

---comment
---@param val number
function ERAStatusBar:SetModifierAdditive(val)
    self:ensureAdditive()
    self.modifAdditive:SetValue(val)
end

---comment
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAStatusBar:SetModifierSubtractiveColor(r, g, b, maybeSecret)
    self:ensureSubtractive()
    if (maybeSecret) then
        self.subR = nil
        self.subG = nil
        self.subB = nil
        self.modifSubtractive:SetStatusBarColor(r, g, b, 1.0)
    else
        if (r ~= self.subR or g ~= self.subG or b ~= self.subB) then
            self.subR = r
            self.subG = g
            self.subB = b
            self.modifSubtractive:SetStatusBarColor(r, g, b, 1.0)
        end
    end
end

---comment
---@param val number
function ERAStatusBar:SetModifierSubtractive(val)
    self:ensureSubtractive()
    self.modifSubtractive:SetValue(val)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region TEXT  ----------------------------------------------------------------------------------------------------------------

function ERAStatusBar:createText(point, offX)
    local txt = self.textFrame:CreateFontString(nil, "OVERLAY")
    txt:SetPoint(point, self.bar, point, offX, 0)
    ERALIB_SetFont(txt, self.mainFrame:GetHeight() / 2)
    return txt
end

---comment
---@param txt string|nil
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
---@param txt string|nil
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
---@param txt string|nil
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

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

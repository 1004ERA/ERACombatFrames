--------------------------------------------------------------------------------------------------------------------------------
--#region ICONS ----------------------------------------------------------------------------------------------------------------

---@class (exact) ERAIcon
---@field private __index ERAIcon
---@field protected constructIcon fun(self:ERAIcon, parentFrame:Frame, point:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", relativePoint:"TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER", size:number, iconID:number, mainFrame:Frame, overlayFrame:Frame)
---@field protected additionalSetDesaturation nil|fun(self:ERAIcon, desat:number)
---@field private frame Frame
---@field private icon Texture
---@field private iconID number
---@field private mainText FontString
---@field private mainTextValue string|nil
---@field private secondaryText FontString
---@field private secondaryTextValue string|nil
---@field private point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@field private relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@field private parentFrame Frame
---@field private x number
---@field private y number
---@field private size number
---@field private beamAnim AnimationGroup
---@field private beaming boolean
---@field private desat number|nil
---@field private visible boolean
---@field private r number
---@field private g number
---@field private b number
---@field private alpha number
---@field private mainTextR number
---@field private mainTextG number
---@field private mainTextB number
---@field private mainTextA number
ERAIcon = {}
ERAIcon.__index = ERAIcon

function ERAIcon:constructIcon(parentFrame, point, relativePoint, size, iconID, mainFrame, overlayFrame)
    ---@cast mainFrame unknown
    ---@cast overlayFrame unknown
    self.mainText = overlayFrame.MainText
    self.secondaryText = overlayFrame.SecondaryText
    self.icon = mainFrame.Icon
    self.iconID = iconID
    self.beamAnim = mainFrame.BeamGroup
    ---@cast mainFrame Frame
    -- affichage
    self.frame = mainFrame
    self.size = size
    mainFrame:SetSize(size, size)
    ERALIB_SetFont(self.mainText, size * 0.4)
    ERALIB_SetFont(self.secondaryText, size * 0.32)
    self:SetIconTexture(iconID, true, false)

    -- position
    self.parentFrame = parentFrame
    self.point = point
    self.relativePoint = relativePoint

    -- anim
    self.beaming = false

    -- colors
    self.desat = nil
    self.alpha = 1
    self.r = 1
    self.g = 1
    self.b = 1
    self.mainTextR = 1.0
    self.mainTextG = 1.0
    self.mainTextB = 1.0
    self.mainTextA = 1.0

    -- statut
    self.visible = true
    --self:Hide()
end

---@param size number
function ERAIcon:SetSize(size)
    self.icon:SetSize(size, size)
end

---@param iconID number
---@param force boolean
---@param maybeSecret boolean
function ERAIcon:SetIconTexture(iconID, force, maybeSecret)
    if (maybeSecret) then
        self.iconID = nil
        self.icon:SetTexture(iconID)
    else
        if (force) then
            self.iconID = iconID
            --self.icon:SetTexture(136235) -- wow icon
            self.icon:SetTexture(iconID)
        else
            if (iconID and iconID ~= self.iconID) then
                self.iconID = iconID
                self.icon:SetTexture(iconID)
            end
        end
    end
end


---@param level number
function ERAIcon:SetFrameLevel(level)
    self.frame:SetFrameLevel(level)
end

---@param txt any|nil
---@param maybeSecret boolean
function ERAIcon:SetMainText(txt, maybeSecret)
    self.mainText:SetText(txt)
    --[[
    if (maybeSecret) then
        self.mainTextValue = nil
        self.mainText:SetText(txt)
    else
        if (self.mainTextValue ~= txt) then
            self.mainTextValue = txt
            self.mainText:SetText(txt)
        end
    end
    ]]
end
---@param r number
---@param g number
---@param b number
---@param a number
function ERAIcon:SetMainTextColor(r, g, b, a)
    if (self.mainTextR ~= r or self.mainTextG ~= g or self.mainTextB ~= b or self.mainTextA ~= a) then
        self.mainTextR = r
        self.mainTextG = g
        self.mainTextB = b
        self.mainTextA = a
        self.mainText:SetTextColor(r, g, b, a)
    end
end

---@param txt any|nil
---@param maybeSecret boolean
function ERAIcon:SetSecondaryText(txt, maybeSecret)
    self.secondaryText:SetText(txt)
    --[[
    if (maybeSecret) then
        self.secondaryTextValue = nil
        self.secondaryText:SetText(txt)
    else
        if (self.secondaryTextValue ~= txt) then
            self.secondaryTextValue = txt
            self.secondaryText:SetText(txt)
        end
    end
    ]]
end
---@param r number
---@param g number
---@param b number
---@param a number
function ERAIcon:SetSecondaryTextColor(r, g, b, a)
    self.secondaryText:SetTextColor(r, g, b, a)
end

---@param d boolean
function ERAIcon:SetDesaturated(d)
    self:SetDesaturation(d and 1.0 or 0.0, false)
end

---@param d number
---@param maybeSecret boolean
function ERAIcon:SetDesaturation(d, maybeSecret)
    if (maybeSecret) then
        self.desat = nil
        self.icon:SetDesaturation(d)
        if (self.additionalSetDesaturation) then
            self:additionalSetDesaturation(d)
        end
    else
        if (self.desat ~= d) then
            self.desat = d
            self.icon:SetDesaturation(d)
            if (self.additionalSetDesaturation) then
                self:additionalSetDesaturation(d)
            end
        end
    end
end

---comment
---@param a number
---@param maybeSecret boolean
function ERAIcon:SetVisibilityAlpha(a, maybeSecret)
    if (maybeSecret) then
        self.alpha = nil
        self.frame:SetAlpha(a)
    else
        if (self.alpha ~= a) then
            self.alpha = a
            self.frame:SetAlpha(a)
        end
    end
end

--[[
function ERAIcon:SetVertexColor(r, g, b, a)
    if (not a) then
        a = self.alpha
    end
    if (self.r ~= r or self.g ~= g or self.b ~= b or self.alpha ~= a) then
        self.r = r
        self.g = g
        self.b = b
        self.alpha = a
        self.icon:SetVertexColor(r, g, b, a)
    end
end
]]
---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function ERAIcon:SetTint(r, g, b, maybeSecret)
    if (maybeSecret) then
        self.r = nil
        self.g = nil
        self.b = nil
        self.icon:SetVertexColor(r, g, b, 1.0)
    else
        if (self.r ~= r or self.g ~= g or self.b ~= b) then
            self.r = r
            self.g = g
            self.b = b
            self.icon:SetVertexColor(r, g, b, 1.0)
        end
    end
end

---comment
---@param visible boolean
function ERAIcon:SetActiveShown(visible)
    if (visible) then
        if (not self.visible) then
            self.visible = true
            self.frame:Show()
            if (self.beaming) then
                self.beamAnim:Play()
            end
        end
    else
        if (self.visible) then
            self.visible = false
            self.frame:Hide()
            if (self.beaming) then
                self.beamAnim:Stop()
            end
        end
    end
end

function ERAIcon:SetPosition(x, y)
    if (self.x ~= x or self.y ~= y) then
        self.x = x
        self.y = y
        self.frame:SetPoint(self.point, self.parentFrame, self.relativePoint, x, y)
    end
end

function ERAIcon:Beam()
    if (not self.beaming) then
        self.beaming = true
        if (self.visible) then
            self.beamAnim:Play()
        end
    end
end
function ERAIcon:StopBeam()
    if (self.beaming) then
        self.beaming = false
        --if (self.visible) then
        self.beamAnim:Stop()
        --end
    end
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region PIE ICONS ------------------------------------------------------------------------------------------------------------

---@class (exact) ERAPieIcon : ERAIcon
---@field private __index ERAPieIcon
---@field private border Texture
---@field private swipe Cooldown
---@field private highlight Texture
---@field private highlighted boolean
---@field private highlightAnim1 AnimationGroup
---@field private highlightAnim2 AnimationGroup
---@field private countdownVisible boolean
ERAPieIcon = {}
ERAPieIcon.__index = ERAPieIcon
setmetatable(ERAPieIcon, { __index = ERAIcon })

---comment
---@param parentFrame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param iconID number
---@return ERAPieIcon
function ERAPieIcon:create(parentFrame, point, relativePoint, size, iconID)
    local x = {}
    setmetatable(x, ERAPieIcon)
    ---@cast x ERAPieIcon
    local frame = CreateFrame("Frame", nil, parentFrame, "ERAPieIconFrame")
    ---@cast frame unknown
    x.swipe = frame.CD
    x.border = frame.AROUND
    x.highlight = frame.OVER.BHIGH
    x.highlightAnim1 = frame.OVER.BHIGH.HighlightGroup1
    x.highlightAnim2 = frame.OVER.BHIGH.HighlightGroup2
    x:constructIcon(parentFrame, point, relativePoint, size, iconID, frame, frame.OVER)
    ---@cast frame Frame
    -- highlight
    --x.highlight:SetAtlas("PowerSwirlAnimation-SpinningGlowys")
    --x.highlight:SetAtlas("UF-Essence-SpinnerOut")
    x.highlight:SetAtlas("Spinner_Ring")
    x.highlighted = true
    x:SetHighlight(false)

    x.swipe:SetSwipeTexture("Interface/Addons/ERACombatFrames/textures/disk_256.tga", 0.0, 0.0, 0.0, 0.88)
    x.swipe:SetSwipeColor(0.0, 0.0, 0.0, 0.88)
    x.swipe:SetUseCircularEdge(true)
    --x.swipe:SetHideCountdownNumbers(true)
    x.countdownVisible = true

    return x
end

function ERAPieIcon:SetupAura()
    self.swipe:SetReverse(true)
    self.swipe:SetUseAuraDisplayTime(true)
end

function ERAPieIcon:HideDefaultCountdown()
    if (self.countdownVisible) then
        self.countdownVisible = false
        self.swipe:SetHideCountdownNumbers(true)
    end
end
function ERAPieIcon:ShowDefaultCountdown()
    if (not self.countdownVisible) then
        self.countdownVisible = true
        self.swipe:SetHideCountdownNumbers(false)
    end
end

---comment
---@param start number
---@param duration number
function ERAPieIcon:SetValue(start, duration)
    self.swipe:SetCooldown(start, duration)
end

---comment
---@param h boolean
function ERAPieIcon:SetHighlight(h)
    if (h) then
        if (not self.highlighted) then
            self.highlighted = true
            self.highlightAnim1:Play()
            self.highlightAnim2:Play()
            self.highlight:Show()
        end
    else
        if (self.highlighted) then
            self.highlighted = false
            self.highlightAnim1:Stop()
            self.highlightAnim2:Stop()
            self.highlight:Hide()
        end
    end
end

---comment
---@param r number
---@param g number
---@param b number
function ERAPieIcon:SetBorderColor(r, g, b)
    self.border:SetVertexColor(r, g, b, 1.0)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region SQUARE ICONS ---------------------------------------------------------------------------------------------------------

---@class (exact) ERASquareIcon : ERAIcon
---@field private __index ERASquareIcon
ERASquareIcon = {}
ERASquareIcon.__index = ERASquareIcon
setmetatable(ERASquareIcon, { __index = ERAIcon })

---comment
---@param parentFrame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"RIGHT"|"BOTTOMRIGHT"|"BOTTOM"|"BOTTOMLEFT"|"LEFT"|"CENTER"
---@param size number
---@param iconID number
---@return ERASquareIcon
function ERASquareIcon:create(parentFrame, point, relativePoint, size, iconID)
    local x = {}
    setmetatable(x, ERASquareIcon)
    ---@cast x ERASquareIcon
    local frame = CreateFrame("Frame", nil, parentFrame, "ERASquareIconFrame")
    ---@cast frame unknown
    x:constructIcon(parentFrame, point, relativePoint, size, iconID, frame, frame.OVER)
    ---@cast frame Frame
    return x
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

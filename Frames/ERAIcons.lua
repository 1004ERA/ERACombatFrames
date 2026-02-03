--------------------------------------------------------------------------------------------------------------------------------
---- ICONS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class (exact) ERAIcon
---@field private __index ERAIcon
---@field protected constructIcon fun(self:ERAIcon, parentFrame:Frame, point:"TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER", relativePoint:"TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER", size:number, iconID:number, frame:Frame)
---@field protected additionalSetDesaturated fun(self:ERAIcon, desat:boolean)
---@field private frame Frame
---@field private icon Texture
---@field private iconID number
---@field private mainText FontString
---@field private secondaryText FontString
---@field private point "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@field private relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@field private parentFrame Frame
---@field private x number
---@field private y number
---@field private size number
---@field private beamAnim AnimationGroup
---@field private beamScale Scale
---@field private beaming boolean
---@field private desat boolean
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

function ERAIcon:constructIcon(parentFrame, point, relativePoint, size, iconID, frame)
    ---@cast frame unknown
    self.mainText = frame.MainText
    self.secondaryText = frame.SecondaryText
    self.icon = frame.Icon
    self.iconID = iconID
    self.beamAnim = frame.BeamGroup
    self.beamScale = frame.BeamGroup.Beam
    ---@cast frame Frame
    ---@
    -- affichage
    self.frame = frame
    self.size = size
    frame:SetSize(size, size)
    ERALIB_SetFont(self.mainText, size * 0.4)
    ERALIB_SetFont(self.secondaryText, size * 0.32)
    self:SetIconTexture(iconID, true)

    -- position
    self.parentFrame = parentFrame
    self.point = point
    self.relativePoint = relativePoint

    -- anim
    self.beaming = false

    -- colors
    self.desat = false
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

function ERAIcon:SetIconTexture(iconID, force)
    if (force) then
        self.iconID = iconID
        self.icon:SetTexture(136235)
        self.icon:SetTexture(iconID)
    else
        if (iconID and iconID ~= self.iconID) then
            self.iconID = iconID
            self.icon:SetTexture(self.iconID)
        end
    end
end

function ERAIcon:SetMainText(txt)
    self.mainText:SetText(txt)
end
function ERAIcon:SetMainTextColor(r, g, b, a)
    if (self.mainTextR ~= r or self.mainTextG ~= g or self.mainTextB ~= b or self.mainTextA ~= a) then
        self.mainTextR = r
        self.mainTextG = g
        self.mainTextB = b
        self.mainTextA = a
        self.mainText:SetTextColor(r, g, b, a)
    end
end
function ERAIcon:SetSecondaryText(txt)
    self.secondaryText:SetText(txt)
end
function ERAIcon:SetSecondaryTextColor(r, g, b, a)
    self.secondaryText:SetTextColor(r, g, b, a)
end

function ERAIcon:SetDesaturated(d)
    if (d) then
        if (not self.desat) then
            self.desat = true
            self.icon:SetDesaturated(true)
            self:additionalSetDesaturated(true)
        end
    else
        if (self.desat) then
            self.desat = false
            self.icon:SetDesaturated(false)
            self:additionalSetDesaturated(false)
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

---comment
---@param visible boolean
function ERAIcon:SetActiveShown(visible)
    if (visible) then
        if (not self.visible) then
            self.visible = true
            self.frame:Show()
        end
    else
        if (self.visible) then
            self.visible = false
            self.frame:Hide()
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

--------------------------------------------------------------------------------------------------------------------------------
---- PIE ICONS -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

---@class (exact) ERAPieIcon : ERAIcon
---@field private __index ERAPieIcon
---@field private border Texture
---@field private swipe Cooldown
---@field private highlight Texture
---@field private highlighted boolean
---@field private highlightAnim1 AnimationGroup
---@field private highlightAnim2 AnimationGroup
ERAPieIcon = {}
ERAPieIcon.__index = ERAPieIcon
setmetatable(ERAPieIcon, { __index = ERAIcon })

---comment
---@param parentFrame Frame
---@param point "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param relativePoint "TOPLEFT"|"TOP"|"TOPRIGHT"|"CENTER"
---@param size number
---@param iconID number
---@return ERAPieIcon
function ERAPieIcon:create(parentFrame, point, relativePoint, size, iconID)
    local x = {}
    setmetatable(x, ERAPieIcon)
    ---@cast x ERAPieIcon
    local frame = CreateFrame("Frame", nil, parentFrame, "ERAPieIconFrame")
    ---@cast frame Frame
    x:constructIcon(parentFrame, point, relativePoint, size, iconID, frame)
    ---@cast frame unknown
    x.swipe = frame.CD
    x.border = frame.AROUND
    x.highlight = frame.BHIGH
    x.highlightAnim1 = frame.BHIGH.HighlightGroup1
    x.highlightAnim2 = frame.BHIGH.HighlightGroup2
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

    return x
end

function ERAPieIcon:SetAura()
    self.swipe:SetReverse(true)
    self.swipe:SetUseAuraDisplayTime(true)
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

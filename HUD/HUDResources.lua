---@class (exact) HUDResourceDisplay : HUDDisplay
---@field private __index HUDResourceDisplay
---@field protected constructResource fun(self:HUDResourceDisplay, hud:HUDModule, beforeHealth:boolean, talent:ERALIBTalent|nil)
---@field height number
---@field measure_returnHeight fun(self:HUDResourceDisplay, y:number, width:number, resourceFrame:Frame): number
---@field arrange fun(self:HUDResourceDisplay, y:number, width:number, height:number, resourceFrame:Frame): number
HUDResourceDisplay = {}
HUDResourceDisplay.__index = HUDResourceDisplay
setmetatable(HUDResourceDisplay, { __index = HUDDisplay })

---comment
---@param hud HUDModule
---@param beforeHealth boolean
---@param talent ERALIBTalent|nil
function HUDResourceDisplay:constructResource(hud, beforeHealth, talent)
    self:constructDisplay(hud, talent)
    hud:addResource(self, beforeHealth)
end

------------------------
--#region HEALTH -------

---@class (exact) HUDHealthDisplay : HUDResourceDisplay
---@field private __index HUDHealthDisplay
---@field private data HUDHealth
---@field private bar ERAStatusBar
HUDHealthDisplay = {}
HUDHealthDisplay.__index = HUDHealthDisplay
setmetatable(HUDHealthDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param data HUDHealth
---@param isPet boolean
---@param resourceFrame Frame
---@param frameLevel number
---@return HUDHealthDisplay
function HUDHealthDisplay:create(hud, data, isPet, resourceFrame, frameLevel)
    local x = {}
    setmetatable(x, HUDHealthDisplay)
    ---@cast x HUDHealthDisplay
    x:constructResource(hud, false)

    x.data = data
    x.bar = ERAStatusBar:Create(resourceFrame, "TOP", "TOP", frameLevel)
    if (isPet) then
        x.height = 2 * hud.options.healthHeight / 3
        x.bar:SetBarColor(0.0, 0.8, 0.0, false)
        x.bar:SetBorderColor(0.0, 0.8, 0.0, false)
    else
        x.height = hud.options.healthHeight
        x.bar:SetBarColor(0.0, 1.0, 0.0, false)
        x.bar:SetBorderColor(0.0, 1.0, 0.0, false)
    end

    return x
end

function HUDHealthDisplay:Activate()
    self.bar:SetActiveShown(true)
end
function HUDHealthDisplay:Deactivate()
    self.bar:SetActiveShown(false)
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDHealthDisplay:measure_returnHeight(y, width, resourceFrame)
    return self.height
end
---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDHealthDisplay:arrange(y, width, height, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
end

---@param t number
---@param combat boolean
function HUDHealthDisplay:Update(t, combat)
    if (combat) then
        self.bar:SetVisibilityAlpha(1.0, false)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        self.bar:SetVisibilityAlpha(UnitHealthPercent(self.data.unit, true, self.hud.curveHide96pctFull), true)
    end
    self.bar:SetMinMax(0, self.data.maxHealth)
    self.bar:SetValue(self.data.health)
    self.bar:SetModifierSubtractive(self.data.badAbsorb)
    self.bar:SetModifierAdditive(self.data.goodAbsorb)
    self.bar:SetRightText(string.format("%i", self.data.healthPercent100), true)
end

--#endregion
------------------------

------------------------
--#region RESOURCE BAR -

--------
--#region BAR

---@class (exact) HUDPowerBarDisplay : HUDResourceDisplay
---@field private __index HUDPowerBarDisplay
---@field protected bar ERAStatusBar
---@field private height number -- inherited
---@field private max number
---@field private dKind HUDPowerBarDisplayKind
---@field protected getMax fun(self:HUDPowerBarDisplay)
---@field protected getCurrentAndUpdate fun(self:HUDPowerBarDisplay, t:number, combat:boolean)
---@field isCurvePercent fun(self:HUDPowerBarDisplay): boolean
---@field getTickColor fun(self:HUDPowerBarDisplay, curve:LuaColorCurveObject): ColorMixin
---@field private ticks HUDPowerBarTick[]
---@field private ticksActive HUDPowerBarTick[]
HUDPowerBarDisplay = {}
HUDPowerBarDisplay.__index = HUDPowerBarDisplay
setmetatable(HUDPowerBarDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
---@param frameLevel number
---@param dKind HUDPowerBarDisplayKind
function HUDPowerBarDisplay:constructPower(hud, r, g, b, talent, resourceFrame, frameLevel, dKind)
    self:constructResource(hud, true, talent)
    self.dKind = dKind
    self.ticks = {}
    self.ticksActive = {}
    self.bar = ERAStatusBar:Create(resourceFrame, "TOP", "TOP", frameLevel)
    self.height = hud.options.powerHeight
    self.bar:SetBarColor(r, g, b, false)
    self.bar:SetBorderColor(r, g, b, false)
end

function HUDPowerBarDisplay:Activate()
    self.bar:SetActiveShown(true)
end
function HUDPowerBarDisplay:Deactivate()
    self.bar:SetActiveShown(false)
end

function HUDPowerBarDisplay:talentIsActive()
    self.max = self:getMax()
    self.bar:SetMinMax(0, self.max)
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDPowerBarDisplay:measure_returnHeight(y, width, resourceFrame)
    return self.height
end

---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDPowerBarDisplay:arrange_returnHeight(y, width, height, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
    self.ticksActive = {}
    local bThick = self.bar:GetBorderThickness()
    for _, t in ipairs(self.ticks) do
        if (t:checkTalentAndHideOrLayout(width, height, bThick, self.max)) then
            table.insert(self.ticksActive, t)
        end
    end
end

---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(): number
---@return HUDPowerBarTick
function HUDPowerBarDisplay:AddTick(iconID, talent, tickValue)
    local t = HUDPowerBarTick:create(self, iconID, talent, tickValue, self.bar)
    table.insert(self.ticks, t)
    return t
end

---@param t number
---@param combat boolean
function HUDPowerBarDisplay:Update(t, combat)
    local current = self:getCurrentAndUpdate(t, combat)
    self.bar:SetValue(current)
    self.dKind:updateDisplay(combat, self, self.bar, current, self.max)
    for _, tk in ipairs(self.ticksActive) do
        tk:update(t, combat)
    end
end

--#endregion
--------

--------
--#region BAR KINDS

---@class (exact) HUDPowerBarPowerDisplay : HUDPowerBarDisplay
---@field private __index HUDPowerBarPowerDisplay
---@field data HUDPower
HUDPowerBarPowerDisplay = {}
HUDPowerBarPowerDisplay.__index = HUDPowerBarPowerDisplay
setmetatable(HUDPowerBarPowerDisplay, { __index = HUDPowerBarDisplay })

---comment
---@param hud HUDModule
---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
---@param frameLevel number
---@param dKind HUDPowerBarDisplayKind
---@return HUDPowerBarPowerDisplay
function HUDPowerBarPowerDisplay:create(hud, data, r, g, b, talent, resourceFrame, frameLevel, dKind)
    local x = {}
    setmetatable(x, HUDPowerBarPowerDisplay)
    ---@cast x HUDPowerBarPowerDisplay
    x:constructPower(hud, r, g, b, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame, frameLevel, dKind)
    x.data = data
    return x
end

function HUDPowerBarPowerDisplay:getMax()
    return self.data.maxNotSecret
end
---@param t number
---@param combat boolean
---@return number
function HUDPowerBarPowerDisplay:getCurrentAndUpdate(t, combat)
    return self.data.current
end
function HUDPowerBarPowerDisplay:isCurvePercent()
    return true
end
---@param curve LuaColorCurveObject
---@return ColorMixin
function HUDPowerBarPowerDisplay:getTickColor(curve)
    ---@diagnostic disable-next-line: return-type-mismatch, param-type-mismatch
    return UnitPowerPercent("player", self.data.powerType, false, curve)
end

--#endregion
--------

--------
--#region DISPLAY KINDS

---@class (exact) HUDPowerBarDisplayKind
---@field private __index HUDPowerBarDisplayKind
---@field updateDisplay fun(self:HUDPowerBarDisplayKind, combat:boolean, owner:HUDPowerBarDisplay, bar:ERAStatusBar, current:number, max:number)
HUDPowerBarDisplayKind = {}
HUDPowerBarDisplayKind.__index = HUDPowerBarDisplayKind
function HUDPowerBarDisplayKind:constructKind()
end

---@class (exact) HUDPowerBarDisplayKindPower : HUDPowerBarDisplayKind
---@field private __index HUDPowerBarDisplayKindPower
---@field protected setTexts fun(self:HUDPowerBarDisplayKindPower, bar:ERAStatusBar, owner:HUDPowerBarPowerDisplay)
HUDPowerBarDisplayKindPower = {}
HUDPowerBarDisplayKindPower.__index = HUDPowerBarDisplayKindPower
setmetatable(HUDPowerBarDisplayKindPower, { __index = HUDPowerBarDisplayKind })
function HUDPowerBarDisplayKindPower:constructPower()
    self:constructKind()
end
---@param combat boolean
---@param owner HUDPowerBarDisplay
---@param bar ERAStatusBar
---@param current number
---@param max number
function HUDPowerBarDisplayKindPower:updateDisplay(combat, owner, bar, current, max)
    ---@cast owner HUDPowerBarPowerDisplay
    bar:SetRightText(string.format("%i", owner.data.percent100), true)
    if (combat) then
        bar:SetVisibilityAlpha(1.0, false)
    else
        bar:SetVisibilityAlpha(owner.data.idleAlphaOOC, true)
    end
    self:setTexts(bar, owner)
end

---@class (exact) HUDPowerBarDisplayKindPowerPercent : HUDPowerBarDisplayKindPower
---@field private __index HUDPowerBarDisplayKindPowerPercent
HUDPowerBarDisplayKindPowerPercent = {}
HUDPowerBarDisplayKindPowerPercent.__index = HUDPowerBarDisplayKindPowerPercent
setmetatable(HUDPowerBarDisplayKindPowerPercent, { __index = HUDPowerBarDisplayKindPower })
---@return HUDPowerBarDisplayKindPowerPercent
function HUDPowerBarDisplayKindPowerPercent:create()
    local x = {}
    setmetatable(x, HUDPowerBarDisplayKindPowerPercent)
    ---@cast x HUDPowerBarDisplayKindPowerPercent
    x:constructPower()
    return x
end
---@param bar ERAStatusBar
---@param owner HUDPowerBarPowerDisplay
function HUDPowerBarDisplayKindPowerPercent:setTexts(bar, owner)
    bar:SetRightText(string.format("%i", owner.data.percent100), true)
end

---@class (exact) HUDPowerBarDisplayKindPowerValue : HUDPowerBarDisplayKindPower
---@field private __index HUDPowerBarDisplayKindPowerValue
HUDPowerBarDisplayKindPowerValue = {}
HUDPowerBarDisplayKindPowerValue.__index = HUDPowerBarDisplayKindPowerValue
setmetatable(HUDPowerBarDisplayKindPowerValue, { __index = HUDPowerBarDisplayKindPower })
---@return HUDPowerBarDisplayKindPowerValue
function HUDPowerBarDisplayKindPowerValue:create()
    local x = {}
    setmetatable(x, HUDPowerBarDisplayKindPowerValue)
    ---@cast x HUDPowerBarDisplayKindPowerValue
    x:constructPower()
    return x
end
---@param bar ERAStatusBar
---@param owner HUDPowerBarPowerDisplay
function HUDPowerBarDisplayKindPowerValue:setTexts(bar, owner)
    bar:SetLeftText(string.format("%i", owner.data.current), true)
end

--#endregion
--------

--------
--#region TICKS

---@class (exact) HUDPowerBarTick
---@field private __index HUDPowerBarTick
---@field private owner HUDPowerBarDisplay
---@field private parentFrame Frame
---@field private talent ERALIBTalent|nil
---@field private icon Texture
---@field private tick Line
---@field private tickValueGetter fun(): number
---@field private tickValue number
---@field private curve LuaColorCurveObject
---@field OverrideAlpha nil|fun(self:HUDPowerBarTick): number
---@field OverrideDesaturated nil|fun(self:HUDPowerBarTick): number
HUDPowerBarTick = {}
HUDPowerBarTick.__index = HUDPowerBarTick

---comment
---@param owner HUDPowerBarDisplay
---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(): number
---@param sBar ERAStatusBar
---@return HUDPowerBarTick
function HUDPowerBarTick:create(owner, iconID, talent, tickValue, sBar)
    local x = {}
    setmetatable(x, HUDPowerBarTick)
    ---@cast x HUDPowerBarTick
    x.owner = owner
    x.talent = talent
    x.tickValueGetter = tickValue
    x.tickValue = 0

    x.parentFrame = sBar:GetDrawFrame()
    local drawLevel = sBar:GetDrawFrameLevel()
    x.tick = x.parentFrame:CreateLine(nil, "OVERLAY", nil, drawLevel)
    x.tick:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    x.tick:SetThickness(1)
    x.icon = x.parentFrame:CreateTexture(nil, "OVERLAY")
    x.icon:SetTexture(iconID)

    x.curve = C_CurveUtil.CreateColorCurve()
    x.curve:SetType(Enum.LuaCurveType.Step)

    return x
end

---@param barWidth number
---@param height number
---@param borderThickness number
---@param max number
---@return boolean
function HUDPowerBarTick:checkTalentAndHideOrLayout(barWidth, height, borderThickness, max)
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.tick:Hide()
        self.icon:Hide()
        return false
    else
        self.tickValue = self.tickValueGetter()
        local pct1 = self.tickValue / max
        self.curve:ClearPoints()
        if (self.owner:isCurvePercent()) then
            self.curve:AddPoint(0, CreateColor(0.8, 0.1, 0.1, 1.0))
            self.curve:AddPoint(pct1, CreateColor(0.0, 1.0, 0.0, 1.0))
        else
            self.curve:AddPoint(0, CreateColor(0.8, 0.1, 0.1, 1.0))
            self.curve:AddPoint(self.tickValue, CreateColor(0.0, 1.0, 0.0, 1.0))
        end

        local x = (barWidth - 2 * borderThickness) * pct1
        local y = -height * 0.5
        self.tick:SetStartPoint("TOPLEFT", self.parentFrame, x, 0)
        self.tick:SetEndPoint("TOPLEFT", self.parentFrame, x, y)
        self.icon:SetSize(height / 2, height / 2)
        self.icon:SetPoint("TOP", self.parentFrame, "TOPLEFT", x, y)

        self.tick:Show()
        self.icon:Show()

        return true
    end
end

---@param t number
---@param combat boolean
function HUDPowerBarTick:update(t, combat)
    local alpha
    if (self.OverrideAlpha) then
        alpha = self.OverrideAlpha(self)
        self.icon:SetAlpha(alpha)
    else
        alpha = 1.0
        self.icon:SetAlpha(1.0)
    end

    local color = self.owner:getTickColor(self.curve)
    ---@diagnostic disable-next-line: undefined-field
    self.tick:SetColorTexture(color.r, color.g, color.b, alpha)

    if (self.OverrideDesaturated) then
        self.icon:SetDesaturation(self.OverrideDesaturated(self))
    end
end

--#endregion
--------

---
--#endregion
------------------------

------------------------
--#region POWER POINTS -

---@class (exact) HUDPowerPointsDisplay : HUDResourceDisplay
---@field private __index HUDPowerPointsDisplay
---@field private height number -- inherited
---@field private frame Frame
---@field private rBorder number
---@field private gBorder number
---@field private bBorder number
---@field private rPoint number
---@field private gPoint number
---@field private bPoint number
---@field private points HUDPowerPointItem[]
---@field private maxPoints number
---@field protected getMaxPoints fun(self:HUDPowerPointsDisplay): number
HUDPowerPointsDisplay = {}
HUDPowerPointsDisplay.__index = HUDPowerPointsDisplay
setmetatable(HUDPowerPointsDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@param rPoint number
---@param gPoint number
---@param bPoint number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
function HUDPowerPointsDisplay:constructPoints(hud, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, talent, resourceFrame)
    self:constructResource(hud, true, talent)
    self.height = hud.options.powerHeight
    self.frame = CreateFrame("Frame", nil, resourceFrame)
    self.rBorder = rBorder
    self.gBorder = gBorder
    self.bBorder = bBorder
    self.rPoint = rPoint
    self.gPoint = gPoint
    self.bPoint = bPoint
    self.maxPoints = 0
end

function HUDPowerPointsDisplay:Activate()
    self.frame:Show()
end
function HUDPowerPointsDisplay:Deactivate()
    self.frame:Hide()
end

function HUDPowerPointsDisplay:talentIsActive()
    local max = self:getMaxPoints()
    if (max > self.maxPoints) then
        for i = self.maxPoints + 1, max do
            if (i > #self.points) then
                local newPoint = HUDPowerPointItem:create(i, self.frame, self.rBorder, self.gBorder, self.bBorder, self.rPoint, self.gPoint, self.bPoint)
                table.insert(self.points, newPoint)
            else
                self.points[i].frame:Show()
            end
        end
    elseif (max < self.maxPoints) then
        for i = max + 1, self.maxPoints do
            self.points[i].frame:Hide()
        end
    end
    self.maxPoints = max
end

---comment
---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDPowerPointsDisplay:updateLayout_returnHeight(y, width, resourceFrame)
    self.frame:SetPoint("TOP", resourceFrame, "TOP", y, 0)
    local size = math.min(self.hud.options.powerHeight, width / self.maxPoints)
    self.height = size
    self.frame:SetSize(width, size)

    for i = 1, self.maxPoints do
        local point = self.points[i]
        point.frame:SetPoint("CENTER", self.frame, "CENTER", size * (i - self.maxPoints / 2 - 0.5), 0)
        point.frame:SetSize(size, size)
    end

    return size
end

---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function HUDPowerPointsDisplay:SetBorderColor(r, g, b, maybeSecret)
    if (
        ---@diagnostic disable-next-line: param-type-mismatch
            (maybeSecret or issecretvalue(self.rBorder) or issecretvalue(self.gBorder) or issecretvalue(self.bBorder))
            or
            (self.rBorder ~= r or self.gBorder ~= g or self.bBorder ~= b)
        ) then
        self.rBorder = r
        self.gBorder = g
        self.bBorder = b
        for _, p in ipairs(self.points) do
            p:setBorderColor(r, g, b)
        end
    end
end

---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function HUDPowerPointsDisplay:SetPointColor(r, g, b, maybeSecret)
    if (
        ---@diagnostic disable-next-line: param-type-mismatch
            (maybeSecret or issecretvalue(self.rPoint) or issecretvalue(self.gPoint) or issecretvalue(self.bPoint))
            or
            (self.rPoint ~= r or self.gPoint ~= g or self.bPoint ~= b)
        ) then
        self.rPoint = r
        self.gPoint = g
        self.bPoint = b
        for _, p in ipairs(self.points) do
            p:setPointColor(r, g, b)
        end
    end
end

---comment
---@param t number
---@param combat boolean
function HUDPowerPointsDisplay:Update(t, combat)

end

----
--#region POINT ITEM

---@class (exact) HUDPowerPointItem
---@field private __index HUDPowerPointItem
---@field frame Frame
---@field private border Texture
---@field private point Texture
HUDPowerPointItem = {}
HUDPowerPointItem.__index = HUDPowerPointItem

---@param index number
---@param parentFrame Frame
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@param rPoint number
---@param gPoint number
---@param bPoint number
---@return HUDPowerPointItem
function HUDPowerPointItem:create(index, parentFrame, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint)
    local x = {}
    setmetatable(x, HUDPowerPointItem)
    ---@cast x HUDPowerPointItem
    local frame = CreateFrame("Frame", nil, parentFrame, "ECFHUDModulePointsFrame")
    ---@cast frame unknown
    x.border = frame.Border
    x.point = frame.Point
    ---@cast frame Frame
    x.frame = frame
    x:setBorderColor(rBorder, gBorder, bBorder)
    x:setPointColor(rPoint, gPoint, bPoint)
    return x
end
---@param r number
---@param g number
---@param b number
function HUDPowerPointItem:setBorderColor(r, g, b)
    self.border:SetVertexColor(r, g, b, 1.0)
end
---@param r number
---@param g number
---@param b number
function HUDPowerPointItem:setPointColor(r, g, b)
    self.point:SetVertexColor(r, g, b)
end
function HUDPowerPointItem:updateCount(value)

end

--#endregion
----

----
--#region KINDS

---@class (exact) HUDPowerPointsPowerDisplay : HUDPowerPointsDisplay
---@field private __index HUDPowerPointsDisplay
---@field private data HUDPower
HUDPowerPointsPowerDisplay = {}
HUDPowerPointsPowerDisplay.__index = HUDPowerPointsPowerDisplay
setmetatable(HUDPowerPointsPowerDisplay, { __index = HUDPowerPointsDisplay })

---comment
---@param hud HUDModule
---@param data HUDPower
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@param rPoint number
---@param gPoint number
---@param bPoint number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
function HUDPowerPointsPowerDisplay:create(hud, data, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, talent, resourceFrame)
    local x = {}
    setmetatable(x, HUDPowerPointsPowerDisplay)
    ---@cast x HUDPowerPointsPowerDisplay
    x:constructPoints(hud, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame)
    x.data = data
    return x
end

--#endregion
----

--#endregion
------------------------

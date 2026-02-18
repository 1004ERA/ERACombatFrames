---@class (exact) HUDResourceDisplay : HUDDisplay
---@field private __index HUDResourceDisplay
---@field protected constructResource fun(self:HUDResourceDisplay, hud:HUDModule, beforeHealth:boolean, talent:ERALIBTalent|nil)
---@field private desiredHeight number
---@field protected measure_protected_returnHeight fun(self:HUDResourceDisplay, y:number, width:number, resourceFrame:Frame): number
---@field arrange fun(self:HUDResourceDisplay, y:number, width:number, height:number, resourceFrame:Frame)
---@field protected ActivateResource fun(self:HUDResourceDisplay, dynamic:boolean)
---@field protected DeactivateResource fun(self:HUDResourceDisplay, dynamic:boolean)
---@field protected UpdateResource fun(self:HUDResourceDisplay, t:number, combat:boolean)
---@field protected dynamicLayout fun(self:HUDResourceDisplay, y:number, width:number, height:number, desiredHeight:number, resourceFrame:Frame)
---@field DynamicVisibility nil|fun(self:HUDResourceDisplay, t:number, combat:boolean): boolean
---@field private dynamicVisible boolean
HUDResourceDisplay = {}
HUDResourceDisplay.__index = HUDResourceDisplay
setmetatable(HUDResourceDisplay, { __index = HUDDisplay })

---comment
---@param hud HUDModule
---@param beforeHealth boolean
---@param talent ERALIBTalent|nil
function HUDResourceDisplay:constructResource(hud, beforeHealth, talent)
    self:constructDisplay(hud, talent)
end

function HUDResourceDisplay:Activate()
    self.dynamicVisible = true
    self:ActivateResource(false)
end
function HUDResourceDisplay:Deactivate()
    self.dynamicVisible = false
    self:DeactivateResource(false)
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDResourceDisplay:measure_returnHeight(y, width, resourceFrame)
    self.desiredHeight = self:measure_protected_returnHeight(y, width, resourceFrame)
    return self.desiredHeight
end

function HUDResourceDisplay:Update(t, combat)
    if (self.DynamicVisibility) then
        local visible = self:DynamicVisibility(t, combat)
        if (visible) then
            if (not self.dynamicVisible) then
                self.dynamicVisible = true
                self:ActivateResource(true)
                self.hud:dynamicResourceVisibilityChanged()
            end
        else
            if (self.dynamicVisible) then
                self.dynamicVisible = false
                self:DeactivateResource(true)
                self.hud:dynamicResourceVisibilityChanged()
            end
            return
        end
    end
    self:UpdateResource(t, combat)
end

function HUDResourceDisplay:dynamicLayout_returnVisible(y, width, height, resourceFrame)
    if (self.dynamicVisible) then
        self:dynamicLayout(y, width, height, self.desiredHeight, resourceFrame)
        return true
    else
        return false
    end
end

------------------------
--#region HEALTH -------

---@class (exact) HUDHealthDisplay : HUDResourceDisplay
---@field private __index HUDHealthDisplay
---@field private data HUDHealth
---@field private bar ERAStatusBar
---@field private healthHeight number
HUDHealthDisplay = {}
HUDHealthDisplay.__index = HUDHealthDisplay
setmetatable(HUDHealthDisplay, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param data HUDHealth
---@param isPet boolean
---@param resourceFrame Frame
---@param frameLevel number
---@param talent ERALIBTalent|nil
---@return HUDHealthDisplay
function HUDHealthDisplay:create(hud, data, isPet, resourceFrame, frameLevel, talent)
    local x = {}
    setmetatable(x, HUDHealthDisplay)
    ---@cast x HUDHealthDisplay
    x:constructResource(hud, false, talent)

    x.data = data
    x.bar = ERAStatusBar:Create(resourceFrame, "TOP", "TOP", frameLevel)
    if (isPet) then
        x.healthHeight = 2 * hud.options.healthHeight / 3
        x.bar:SetBarColor(0.5, 0.7, 0.0, false)
        x.bar:SetBorderColor(0.5, 0.7, 0.0, false)
    else
        x.healthHeight = hud.options.healthHeight
        x.bar:SetBarColor(0.0, 1.0, 0.0, false)
        x.bar:SetBorderColor(0.0, 1.0, 0.0, false)
    end

    return x
end

function HUDHealthDisplay:ActivateResource(dynamic)
    self.bar:SetActiveShown(true)
end
function HUDHealthDisplay:DeactivateResource(dynamic)
    self.bar:SetActiveShown(false)
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDHealthDisplay:measure_returnHeight(y, width, resourceFrame)
    return self.healthHeight
end
---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDHealthDisplay:arrange(y, width, height, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
end
---@param y number
---@param width number
---@param height number
---@param desiredHeight number
---@param resourceFrame Frame
function HUDHealthDisplay:dynamicLayout(y, width, height, desiredHeight, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
end

---@param t number
---@param combat boolean
function HUDHealthDisplay:UpdateResource(t, combat)
    if ((not self.data.unitExists) and ((not self:ShowIfNoUnit(t, combat)) or IsMounted())) then
        self.bar:SetVisibilityAlpha(0.0, false)
        return
    end
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
function HUDHealthDisplay:ShowIfNoUnit(t, combat)
    return true
end

--#endregion
------------------------

------------------------
--#region RESOURCE BAR -

----------------
--#region BAR

---@class (exact) HUDPowerBarDisplay : HUDResourceDisplay
---@field private __index HUDPowerBarDisplay
---@field protected bar ERAStatusBar
---@field private max number
---@field protected getMax fun(self:HUDPowerBarDisplay)
---@field protected getCurrentAndUpdate fun(self:HUDPowerBarDisplay, t:number, combat:boolean)
---@field isCurvePercent fun(self:HUDPowerBarDisplay): boolean
---@field getTickColor fun(self:HUDPowerBarDisplay, curve:LuaColorCurveObject): ColorMixin
---@field private ticks HUDPowerBarTick[]
---@field private ticksActive HUDPowerBarTick[]
---@field heightMultiplier number
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
function HUDPowerBarDisplay:constructPower(hud, r, g, b, talent, resourceFrame, frameLevel)
    self:constructResource(hud, true, talent)
    self.ticks = {}
    self.ticksActive = {}
    self.bar = ERAStatusBar:Create(resourceFrame, "TOP", "TOP", frameLevel)
    self.bar:SetBarColor(r, g, b, false)
    self.bar:SetBorderColor(r, g, b, false)
    self.heightMultiplier = 1
end

function HUDPowerBarDisplay:ActivateResource(dynamic)
    self.bar:SetActiveShown(true)
end
function HUDPowerBarDisplay:DeactivateResource(dynamic)
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
    return self.heightMultiplier * self.hud.options.powerHeight
end

---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDPowerBarDisplay:arrange(y, width, height, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
    self.ticksActive = {}
    local bThick = self.bar:GetBorderThickness()
    for _, t in ipairs(self.ticks) do
        if (t:checkTalentAndHideOrLayout(width, height, bThick, self.max)) then
            table.insert(self.ticksActive, t)
        end
    end
end
---@param y number
---@param width number
---@param height number
---@param desiredHeight number
---@param resourceFrame Frame
function HUDPowerBarDisplay:dynamicLayout(y, width, height, desiredHeight, resourceFrame)
    self.bar:UpdateLayout(0, y, width, height)
end

---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(self:HUDPowerBarTick): number
---@return HUDPowerBarTick
function HUDPowerBarDisplay:AddTick(iconID, talent, tickValue)
    local t = HUDPowerBarTick:create(self, iconID, talent, tickValue, self.bar)
    table.insert(self.ticks, t)
    return t
end

---@param t number
---@param combat boolean
function HUDPowerBarDisplay:UpdateResource(t, combat)
    local current = self:getCurrentAndUpdate(t, combat)
    self.bar:SetValue(current)
    for _, tk in ipairs(self.ticksActive) do
        tk:update(t, combat)
    end
    self:AdditionalBarUpdate(t, combat, self.bar, current)
end
---@param t number
---@param combat boolean
---@param bar ERAStatusBar
---@param current number
function HUDPowerBarDisplay:AdditionalBarUpdate(t, combat, bar, current)
end

--#endregion
----------------

----------------
--#region BAR KINDS

--------
--#region POWER

---@class (exact) HUDPowerBarPowerDisplay : HUDPowerBarDisplay
---@field private __index HUDPowerBarPowerDisplay
---@field private dKind HUDPowerBarDisplayKind
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
    x:constructPower(hud, r, g, b, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame, frameLevel)
    x.data = data
    x.dKind = dKind
    return x
end

function HUDPowerBarPowerDisplay:getMax()
    return self.data.maxNotSecret
end
---@param t number
---@param combat boolean
---@return number
function HUDPowerBarPowerDisplay:getCurrentAndUpdate(t, combat)
    local current = self.data.current
    self.dKind:updateDisplay(combat, self, self.bar, current, self.data.maxNotSecret)
    return current
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

----
--#region DISPLAY KINDS

---@class (exact) HUDPowerBarDisplayKind
---@field private __index HUDPowerBarDisplayKind
---@field updateDisplay fun(self:HUDPowerBarDisplayKind, combat:boolean, owner:HUDPowerBarPowerDisplay, bar:ERAStatusBar, current:number, max:number)
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
---@param owner HUDPowerBarPowerDisplay
---@param bar ERAStatusBar
---@param current number
---@param max number
function HUDPowerBarDisplayKindPower:updateDisplay(combat, owner, bar, current, max)
    ---@cast owner HUDPowerBarPowerDisplay
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
----

--#endregion
--------

--------
--#region STACKS

---@class (exact) HUDPowerBarStacksDisplay : HUDPowerBarDisplay
---@field private __index HUDPowerBarPowerDisplay
---@field private data HUDAura
---@field private targetIdleGetter fun(): number
---@field private targetIdle number
---@field private maxStacksGetter fun(): number
---@field private maxStacks number
---@field showEmptyInCombat boolean
---@field constantTickColor ColorMixin
---@field OverrideVisibilityAlpha fun(self:HUDPowerBarStacksDisplay, aura:HUDAura, t:number, combat:boolean): number
HUDPowerBarStacksDisplay = {}
HUDPowerBarStacksDisplay.__index = HUDPowerBarStacksDisplay
setmetatable(HUDPowerBarStacksDisplay, { __index = HUDPowerBarDisplay })

---comment
---@param hud HUDModule
---@param data HUDAura
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
---@param frameLevel number
---@param maxStacksGetter fun(): number
---@param targetIdleGetter fun(): number
---@return HUDPowerBarStacksDisplay
function HUDPowerBarStacksDisplay:create(hud, data, r, g, b, talent, resourceFrame, frameLevel, maxStacksGetter, targetIdleGetter)
    local x = {}
    setmetatable(x, HUDPowerBarStacksDisplay)
    ---@cast x HUDPowerBarStacksDisplay
    x:constructPower(hud, r, g, b, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame, frameLevel)
    x.data = data
    x.maxStacks = 1
    x.targetIdle = 0
    x.maxStacksGetter = maxStacksGetter
    x.targetIdleGetter = targetIdleGetter
    x.constantTickColor = CreateColor(1.0, 1.0, 1.0, 1.0)
    return x
end

function HUDPowerBarStacksDisplay:getMax()
    self.maxStacks = self.maxStacksGetter()
    self.targetIdle = self.targetIdleGetter()
    return self.maxStacks
end
---@param t number
---@param combat boolean
---@return number
function HUDPowerBarStacksDisplay:getCurrentAndUpdate(t, combat)
    if (self.OverrideVisibilityAlpha) then
        self.bar:SetVisibilityAlpha(self:OverrideVisibilityAlpha(self.data, t, combat), true)
    else
        if (self.data.auraIsActive) then
            if (combat) then
                self.bar:SetVisibilityAlpha(1.0, false)
            else
                ---@diagnostic disable-next-line: param-type-mismatch
                if (issecretvalue(self.data.stacks) or self.data.stacks == self.targetIdle) then
                    self.bar:SetVisibilityAlpha(0.0, false)
                else
                    self.bar:SetVisibilityAlpha(1.0, false)
                end
            end
        else
            if (combat and self.showEmptyInCombat) then
                self.bar:SetVisibilityAlpha(1.0, false)
            else
                self.bar:SetVisibilityAlpha(0.0, false)
            end
        end
    end
    if (self.data.auraIsActive) then
        self.bar:SetMiddleText(tostring(self.data.stacksDisplay), true)
    else
        self.bar:SetMiddleText("", false)
    end
    return self.data.stacks
end
function HUDPowerBarStacksDisplay:isCurvePercent()
    return false
end
---@param curve LuaColorCurveObject
---@return ColorMixin
function HUDPowerBarStacksDisplay:getTickColor(curve)
    return self.constantTickColor
end

--#endregion
--------

--#endregion
----------------

----------------
--#region TICKS

---@class (exact) HUDPowerBarTick
---@field private __index HUDPowerBarTick
---@field private owner HUDPowerBarDisplay
---@field private parentFrame Frame
---@field private talent ERALIBTalent|nil
---@field private icon Texture
---@field private tick Line
---@field private tickValueGetter fun(self:HUDPowerBarTick): number
---@field private tickValue number
---@field private curve LuaColorCurveObject
---@field continuouslyCheckValue boolean
---@field private barMax number
---@field private barWidth number
---@field private barHeight number
---@field private barBorderThickness number
---@field OverrideAlpha nil|fun(self:HUDPowerBarTick): number
---@field OverrideDesaturated nil|fun(self:HUDPowerBarTick): number
HUDPowerBarTick = {}
HUDPowerBarTick.__index = HUDPowerBarTick

---comment
---@param owner HUDPowerBarDisplay
---@param iconID number
---@param talent ERALIBTalent|nil
---@param tickValue fun(self:HUDPowerBarTick): number
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
    self.tickValue = -1004
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.tick:Hide()
        self.icon:Hide()
        return false
    else
        self.barWidth = barWidth
        self.barHeight = height
        self.barBorderThickness = borderThickness
        self.barMax = max
        self:updateValue()
        self.tick:Show()
        self.icon:Show()
        return true
    end
end

---@private
function HUDPowerBarTick:updateValue()
    local val = self:tickValueGetter()
    if (self.tickValue ~= val) then
        self.tickValue = val
        local pct1 = val / self.barMax
        self.curve:ClearPoints()
        if (self.owner:isCurvePercent()) then
            self.curve:AddPoint(0, CreateColor(0.8, 0.1, 0.1, 1.0))
            self.curve:AddPoint(pct1, CreateColor(0.0, 1.0, 0.0, 1.0))
        else
            self.curve:AddPoint(0, CreateColor(0.8, 0.1, 0.1, 1.0))
            self.curve:AddPoint(val, CreateColor(0.0, 1.0, 0.0, 1.0))
        end

        local x = (self.barWidth - 2 * self.barBorderThickness) * pct1
        local y = -self.barHeight * 0.5
        self.tick:SetStartPoint("TOPLEFT", self.parentFrame, x, 0)
        self.tick:SetEndPoint("TOPLEFT", self.parentFrame, x, y)
        self.icon:SetSize(self.barHeight / 2, self.barHeight / 2)
        self.icon:SetPoint("TOP", self.parentFrame, "TOPLEFT", x, y)
    end
end

---@param t number
---@param combat boolean
function HUDPowerBarTick:update(t, combat)
    if (self.continuouslyCheckValue) then
        self:updateValue()
    end

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
----------------

---
--#endregion
------------------------

------------------------
--#region POWER POINTS -

----
--#region BASE

---@class (exact) HUDResourcePoints : HUDResourceDisplay
---@field private __index HUDResourcePoints
---@field private bar StatusBar
---@field private barTexture Texture
---@field private mask MaskTexture
---@field private rBorder number
---@field private gBorder number
---@field private bBorder number
---@field private rPoint number
---@field private gPoint number
---@field private bPoint number
---@field pointSize number
---@field private points HUDPowerPointItem[]
---@field private maxPoints number
---@field protected getCurrentPoints fun(self:HUDResourcePoints): number
---@field protected getMaxPointsOnTalentCheck fun(self:HUDResourcePoints): number
---@field protected getVisibilityAlphaOOC fun(self:HUDResourcePoints): number
HUDResourcePoints = {}
HUDResourcePoints.__index = HUDResourcePoints
setmetatable(HUDResourcePoints, { __index = HUDResourceDisplay })

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
---@param frameLevel number
function HUDResourcePoints:constructPoints(hud, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, talent, resourceFrame, frameLevel)
    self:constructResource(hud, true, talent)
    self.bar = CreateFrame("StatusBar", nil, resourceFrame)
    self.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    self.bar:SetStatusBarColor(rPoint, gPoint, bPoint)
    self.bar:SetFrameLevel(frameLevel)
    self.bar:SetMinMaxValues(0, 1)
    self.barTexture = self.bar:GetStatusBarTexture()
    self.mask = self.bar:CreateMaskTexture(nil, "ARTWORK", nil, 1)
    self.mask:SetAllPoints()
    self.barTexture:AddMaskTexture(self.mask)
    self.rBorder = rBorder
    self.gBorder = gBorder
    self.bBorder = bBorder
    self.rPoint = rPoint
    self.gPoint = gPoint
    self.bPoint = bPoint
    self.maxPoints = 0
    self.points = {}
end

function HUDResourcePoints:ActivateResource(dynamic)
    self.bar:Show()
end
function HUDResourcePoints:DeactivateResource(dynamic)
    self.bar:Hide()
end

function HUDResourcePoints:talentIsActive()
    local max = self:getMaxPointsOnTalentCheck()
    if (max > self.maxPoints) then
        for i = self.maxPoints + 1, max do
            if (i > #self.points) then
                local newPoint = HUDPowerPointItem:create(self.bar, self.barTexture, self.rBorder, self.gBorder, self.bBorder)
                table.insert(self.points, newPoint)
            else
                self.points[i]:show(self.barTexture)
            end
        end
    elseif (max < self.maxPoints) then
        for i = max + 1, self.maxPoints do
            self.points[i]:hide(self.barTexture)
        end
    end
    self.maxPoints = max
    self.bar:SetMinMaxValues(0, max)
    self.mask:SetTexture("Interface/Addons/ERACombatFrames/textures/powerpoints_" .. max .. ".tga")
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDResourcePoints:measure_returnHeight(y, width, resourceFrame)
    self.pointSize = math.min(self.hud.options.powerHeight, width / self.maxPoints)
    return self.pointSize
end

---comment
---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDResourcePoints:arrange(y, width, height, resourceFrame)
    local pointsWidth = self.pointSize * self.maxPoints
    self.bar:SetPoint("CENTER", resourceFrame, "TOP", 0, y - height / 2)
    self.bar:SetSize(pointsWidth, self.pointSize)
    for i = 1, self.maxPoints do
        self.points[i]:updateLayout(self.pointSize * (i - self.maxPoints / 2 - 0.5), self.pointSize, self.bar)
    end
end
---@param y number
---@param width number
---@param height number
---@param desiredHeight number
---@param resourceFrame Frame
function HUDResourcePoints:dynamicLayout(y, width, height, desiredHeight, resourceFrame)
    self.bar:SetPoint("CENTER", resourceFrame, "TOP", 0, y - height / 2)
end

---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function HUDResourcePoints:SetBorderColor(r, g, b, maybeSecret)
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
function HUDResourcePoints:SetPointColor(r, g, b, maybeSecret)
    if (maybeSecret) then
        self.rPoint = nil
        self.gPoint = nil
        self.bPoint = nil
        self.bar:SetStatusBarColor(r, g, b)
    else
        if (self.rPoint ~= r or self.gPoint ~= g or self.bPoint ~= b) then
            self.rPoint = r
            self.gPoint = g
            self.bPoint = b
            self.bar:SetStatusBarColor(r, g, b)
        end
    end
end

---comment
---@param t number
---@param combat boolean
function HUDResourcePoints:UpdateResource(t, combat)
    self.bar:SetValue(self:getCurrentPoints())
    if (combat) then
        self.bar:SetAlpha(1.0)
    else
        self.bar:SetAlpha(self:getVisibilityAlphaOOC())
    end
end

--#endregion
----

----
--#region POINT ITEM

---@class (exact) HUDPowerPointItem
---@field private __index HUDPowerPointItem
---@field private border Texture
---@field private background Texture
HUDPowerPointItem = {}
HUDPowerPointItem.__index = HUDPowerPointItem

---@param parentFrame Frame
---@param parentBarTexture Texture
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@return HUDPowerPointItem
function HUDPowerPointItem:create(parentFrame, parentBarTexture, rBorder, gBorder, bBorder)
    local x = {}
    setmetatable(x, HUDPowerPointItem)
    ---@cast x HUDPowerPointItem
    x.border = parentFrame:CreateTexture(nil, "OVERLAY", nil, 6)
    x.border:SetTexture("Interface/Addons/ERACombatFrames/textures/circle_256_16_blur_b8_8_4.tga")
    x:setBorderColor(rBorder, gBorder, bBorder)
    x.background = parentFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    x.background:SetTexture("Interface/Addons/ERACombatFrames/textures/disk_256.tga")
    x.background:SetVertexColor(0.0, 0.0, 0.0, 0.66)
    x:show(parentBarTexture)
    return x
end

---@param x number
---@param size number
---@param parentFrame StatusBar
function HUDPowerPointItem:updateLayout(x, size, parentFrame)
    self.border:SetPoint("CENTER", parentFrame, "CENTER", x, 0)
    self.border:SetSize(size, size)
    self.background:SetPoint("CENTER", parentFrame, "CENTER", x, 0)
    self.background:SetSize(size, size)
end

---@param parentBarTexture Texture
function HUDPowerPointItem:show(parentBarTexture)
    self.border:Show()
    self.background:Show()
end
---@param parentBarTexture Texture
function HUDPowerPointItem:hide(parentBarTexture)
    self.border:Hide()
    self.background:Hide()
end

---@param r number
---@param g number
---@param b number
function HUDPowerPointItem:setBorderColor(r, g, b)
    self.border:SetVertexColor(r, g, b, 1.0)
end

--#endregion
----

----
--#region AURA STACKS

---@class (exact) HUDStacksPoints : HUDResourcePoints
---@field private __index HUDResourcePoints
---@field private data HUDAura
---@field private maxValueGetter fun(): number
---@field private idleValueGetter fun(): number
---@field private idleValue number
HUDStacksPoints = {}
HUDStacksPoints.__index = HUDStacksPoints
setmetatable(HUDStacksPoints, { __index = HUDResourcePoints })

---comment
---@param hud HUDModule
---@param data HUDAura
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@param rPoint number
---@param gPoint number
---@param bPoint number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
---@param frameLevel number
---@param idleValueGetter fun(): number
---@param maxValueGetter fun(): number
function HUDStacksPoints:create(hud, data, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, talent, resourceFrame, frameLevel, idleValueGetter, maxValueGetter)
    local x = {}
    setmetatable(x, HUDStacksPoints)
    ---@cast x HUDStacksPoints
    x:constructPoints(hud, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame, frameLevel)
    x.data = data
    x.idleValueGetter = idleValueGetter
    x.maxValueGetter = maxValueGetter
    x.idleValue = 0
    return x
end

function HUDStacksPoints:getMaxPointsOnTalentCheck()
    self.idleValue = self.idleValueGetter()
    return self.maxValueGetter()
end

function HUDStacksPoints:getCurrentPoints()
    return self.data.stacks
end

function HUDStacksPoints:getVisibilityAlphaOOC()
    ---@diagnostic disable-next-line: param-type-mismatch
    if (issecretvalue(self.data.stacks)) then
        return 1.0
    else
        if (self.data.stacks == self.idleValue) then
            return 0.0
        else
            return 1.0
        end
    end
end

--#endregion
----

----
--#region UNIT POWER

---@class (exact) HUDPowerPoints : HUDResourcePoints
---@field private __index HUDPowerPoints
---@field private data HUDPower
---@field private idleValueGetter fun(): number
---@field private idleValue number
HUDPowerPoints = {}
HUDPowerPoints.__index = HUDPowerPoints
setmetatable(HUDPowerPoints, { __index = HUDResourcePoints })

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
---@param frameLevel number
---@param idleValueGetter fun(): number
function HUDPowerPoints:create(hud, data, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, talent, resourceFrame, frameLevel, idleValueGetter)
    local x = {}
    setmetatable(x, HUDPowerPoints)
    ---@cast x HUDPowerPoints
    x:constructPoints(hud, rBorder, gBorder, bBorder, rPoint, gPoint, bPoint, ERALIBTalent_CombineMakeAnd(talent, data.talent), resourceFrame, frameLevel)
    x.data = data
    x.idleValueGetter = idleValueGetter
    x.idleValue = 0
    return x
end

function HUDPowerPoints:getMaxPointsOnTalentCheck()
    self.idleValue = self.idleValueGetter()
    return self.data.maxNotSecret
end

function HUDPowerPoints:getCurrentPoints()
    return self.data.current
end

function HUDPowerPoints:getVisibilityAlphaOOC()
    ---@diagnostic disable-next-line: param-type-mismatch
    if (issecretvalue(self.data.current)) then
        return 1.0
    else
        if (self.data.current == self.idleValue) then
            return 0.0
        else
            return 1.0
        end
    end
end

--#endregion
----

--#endregion
------------------------

------------------------
--#region POWER PARTIAL POINTS

----
--#region BASE

---@class (exact) HUDResourcePartialPoints : HUDResourceDisplay
---@field private __index HUDResourcePartialPoints
---@field private rBorder number
---@field private gBorder number
---@field private bBorder number
---@field private rPointFull number
---@field private gPointFull number
---@field private bPointFull number
---@field private rPointPartial number
---@field private gPointPartial number
---@field private bPointPartial number
---@field private frame Frame
---@field pointSize number
---@field private points HUDPartialPointItem[]
---@field private maxPoints number
---@field protected getCurrentValue fun(self:HUDResourcePartialPoints, t:number): number
---@field protected getMaxPointsOnTalentCheck fun(self:HUDResourcePartialPoints): integer
---@field protected getVisibilityAlphaOOC fun(self:HUDResourcePartialPoints, t:number, currentValue:number): number
---@field protected constructPoints fun(self:HUDResourcePartialPoints, hud:HUDModule, rBorder:number, gBorder:number, bBorder:number, rPointFull:number, gPointFull:number, bPointFull:number, rPointPartial:number, gPointPartial:number, bPointPartial:number, talent:ERALIBTalent|nil, resourceFrame:Frame, frameLevel:number)
HUDResourcePartialPoints = {}
HUDResourcePartialPoints.__index = HUDResourcePartialPoints
setmetatable(HUDResourcePartialPoints, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@param rPointFull number
---@param gPointFull number
---@param bPointFull number
---@param rPointPartial number
---@param gPointPartial number
---@param bPointPartial number
---@param talent ERALIBTalent|nil
---@param resourceFrame Frame
---@param frameLevel number
function HUDResourcePartialPoints:constructPoints(hud, rBorder, gBorder, bBorder, rPointFull, gPointFull, bPointFull, rPointPartial, gPointPartial, bPointPartial, talent, resourceFrame, frameLevel)
    self:constructResource(hud, true, talent)
    self.frame = CreateFrame("Frame", nil, resourceFrame)
    self.frame:SetFrameLevel(frameLevel)
    self.rBorder = rBorder
    self.gBorder = gBorder
    self.bBorder = bBorder
    self.rPointFull = rPointFull
    self.gPointFull = gPointFull
    self.bPointFull = bPointFull
    self.rPointPartial = rPointPartial
    self.gPointPartial = gPointPartial
    self.bPointPartial = bPointPartial
    self.maxPoints = 0
    self.points = {}
end

function HUDResourcePartialPoints:ActivateResource(dynamic)
    self.frame:Show()
end
function HUDResourcePartialPoints:DeactivateResource(dynamic)
    self.frame:Hide()
end

function HUDResourcePartialPoints:talentIsActive()
    local max = self:getMaxPointsOnTalentCheck()
    if (max > self.maxPoints) then
        for i = self.maxPoints + 1, max do
            if (i > #self.points) then
                local newPoint = HUDPartialPointItem:create(self.frame, self.rBorder, self.gBorder, self.bBorder)
                table.insert(self.points, newPoint)
            else
                self.points[i]:show()
            end
        end
    elseif (max < self.maxPoints) then
        for i = max + 1, self.maxPoints do
            self.points[i]:hide()
        end
    end
    self.maxPoints = max
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDResourcePartialPoints:measure_returnHeight(y, width, resourceFrame)
    self.pointSize = math.min(self.hud.options.powerHeight, width / self.maxPoints)
    return self.pointSize
end

---comment
---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDResourcePartialPoints:arrange(y, width, height, resourceFrame)
    local pointsWidth = self.pointSize * self.maxPoints
    self.frame:SetPoint("CENTER", resourceFrame, "TOP", 0, y - height / 2)
    self.frame:SetSize(pointsWidth, self.pointSize)
    for i = 1, self.maxPoints do
        self.points[i]:updateLayout(self.pointSize * (i - self.maxPoints / 2 - 0.5), self.pointSize, self.frame)
    end
end
---@param y number
---@param width number
---@param height number
---@param desiredHeight number
---@param resourceFrame Frame
function HUDResourcePartialPoints:dynamicLayout(y, width, height, desiredHeight, resourceFrame)
    self.frame:SetPoint("CENTER", resourceFrame, "TOP", 0, y - height / 2)
end

---@param r number
---@param g number
---@param b number
---@param maybeSecret boolean
function HUDResourcePartialPoints:SetBorderColor(r, g, b, maybeSecret)
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
function HUDResourcePartialPoints:SetPointFullColor(r, g, b, maybeSecret)
    if (
        ---@diagnostic disable-next-line: param-type-mismatch
            (maybeSecret or issecretvalue(self.rPointFull) or issecretvalue(self.gPointFull) or issecretvalue(self.bPointFull))
            or
            (self.rPointFull ~= r or self.gPointFull ~= g or self.bPointFull ~= b)
        ) then
        self.rPointFull = r
        self.gPointFull = g
        self.bPointFull = b
        for _, p in ipairs(self.points) do
            p:pointColorChanged()
        end
    end
end

---comment
---@param t number
---@param combat boolean
function HUDResourcePartialPoints:UpdateResource(t, combat)
    local current = self:getCurrentValue(t)
    if (combat) then
        self.frame:SetAlpha(1.0)
    else
        self.frame:SetAlpha(self:getVisibilityAlphaOOC(t, current))
    end
    for _, p in ipairs(self.points) do
        p:update(t, current, self.rPointPartial, self.gPointPartial, self.bPointPartial, self.rPointFull, self.gPointFull, self.bPointFull)
        current = current - 1
    end
end

--#endregion
----

----
--#region POINT ITEM

---@class (exact) HUDPartialPointItem
---@field private __index HUDPartialPointItem
---@field private border Texture
---@field private point Texture
---@field private background Texture
---@field private frame Frame
---@field private swipe Cooldown
---@field private is_full boolean
---@field private is_empty boolean
---@field private pcolChanged boolean
HUDPartialPointItem = {}
HUDPartialPointItem.__index = HUDPartialPointItem

---@param parentFrame Frame
---@param rBorder number
---@param gBorder number
---@param bBorder number
---@return HUDPartialPointItem
function HUDPartialPointItem:create(parentFrame, rBorder, gBorder, bBorder)
    local x = {}
    setmetatable(x, HUDPartialPointItem)
    ---@cast x HUDPartialPointItem

    x.frame = CreateFrame("Frame", nil, parentFrame)

    x.border = x.frame:CreateTexture(nil, "OVERLAY", nil, 0)
    x.border:SetTexture("Interface/Addons/ERACombatFrames/textures/circle_256_16_blur_b8_8_4.tga")
    x:setBorderColor(rBorder, gBorder, bBorder)
    x.border:SetAllPoints()

    x.point = x.frame:CreateTexture(nil, "ARTWORK", nil, 0)
    x.point:SetTexture("Interface/Addons/ERACombatFrames/textures/disk_256_padding_16_blur_128.tga")
    x.point:SetAllPoints()

    x.background = x.frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    x.background:SetTexture("Interface/Addons/ERACombatFrames/textures/disk_256.tga")
    x.background:SetVertexColor(0.0, 0.0, 0.0, 0.66)
    x.background:SetAllPoints()

    x.swipe = CreateFrame("Cooldown", nil, x.frame)
    x.swipe:SetSwipeTexture("Interface/Addons/ERACombatFrames/textures/disk_256.tga", 0.0, 0.0, 0.0, 0.88)
    x.swipe:SetSwipeColor(0.0, 0.0, 0.0, 0.88)
    x.swipe:SetFrameLevel(10)
    x.swipe:SetHideCountdownNumbers(true)
    x.swipe:SetAllPoints()

    x.is_full = nil

    return x
end

---@param x number
---@param size number
---@param parentFrame Frame
function HUDPartialPointItem:updateLayout(x, size, parentFrame)
    self.frame:SetPoint("CENTER", parentFrame, "CENTER", x, 0)
    self.frame:SetSize(size, size)
end

function HUDPartialPointItem:show()
    self.frame:Show()
end
function HUDPartialPointItem:hide()
    self.frame:Hide()
end

---@param r number
---@param g number
---@param b number
function HUDPartialPointItem:setBorderColor(r, g, b)
    self.border:SetVertexColor(r, g, b, 1.0)
end

function HUDPartialPointItem:pointColorChanged()
    self.pcolChanged = true
end

---@param t number
---@param value number
---@param rPartial number
---@param gPartial number
---@param bPartial number
---@param rFull number
---@param gFull number
---@param bFull number
function HUDPartialPointItem:update(t, value, rPartial, gPartial, bPartial, rFull, gFull, bFull)
    if (value >= 1) then
        if (self.is_full ~= true) then
            self.is_full = true
            self.is_empty = false
            self.point:SetVertexColor(rFull, gFull, bFull, 1.0)
            self.point:Show()
            self.swipe:Hide()
            self.pcolChanged = false
        elseif (self.pcolChanged) then
            self.point:SetVertexColor(rFull, gFull, bFull, 1.0)
            self.pcolChanged = false
        end
    elseif (value <= 0) then
        if (self.is_empty ~= true) then
            self.is_empty = true
            self.is_full = false
            self.point:Hide()
            self.swipe:Hide()
        end
    else
        if (self.is_empty or self.is_full) then
            self.is_empty = false
            self.is_full = false
            self.point:SetVertexColor(rPartial, gPartial, bPartial, 1.0)
            self.point:Show()
            self.swipe:Show()
            self.pcolChanged = false
        elseif (self.pcolChanged) then
            self.point:SetVertexColor(rPartial, gPartial, bPartial, 1.0)
            self.pcolChanged = false
        end
        self.swipe:SetCooldown(t - 10 * value, 10, 0)
    end
end

--#endregion
----

--#endregion
------------------------

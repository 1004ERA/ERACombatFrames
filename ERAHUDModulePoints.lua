ERAHUDModulePoints_PointSize = 22
ERAHUDModulePoints_PointSpacing = 4

ERAHUDModulePointsPartial_PointSize = 22
ERAHUDModulePointsPartial_PointSpacing = 4

-------------------
--#region WHOLE ---

--------------------
--#region MODULE ---

---@class (exact) ERAHUDModulePoints : ERAHUDResourceModule
---@field private __index unknown
---@field protected constructPoints fun(this:ERAHUDModulePoints, hud:ERAHUD, rB:number, gB:number, bB:number, rP:number, gP:number, bP:number, talent:ERALIBTalent|nil)
---@field private checkTalentOverride fun(this:ERAHUDModulePoints): boolean
---@field private rB number
---@field private gB number
---@field private bB number
---@field private rP number
---@field private gP number
---@field private bP number
---@field private updateMaxPoints fun(this:ERAHUDModulePoints)
---@field protected getMaxPoints fun(this:ERAHUDModulePoints): integer
---@field protected getCurrentPoints fun(this:ERAHUDModulePoints): integer
---@field GetIdlePointsOverride fun(this:ERAHUDModulePoints): integer
---@field private points ERAHUDModulePoint[]
---@field currentPoints integer
---@field maxPoints integer
ERAHUDModulePoints = {}
ERAHUDModulePoints.__index = ERAHUDModulePoints
setmetatable(ERAHUDModulePoints, { __index = ERAHUDResourceModule })

---@param hud ERAHUD
---@param rB number
---@param gB number
---@param bB number
---@param rP number
---@param gP number
---@param bP number
---@param talent ERALIBTalent|nil
function ERAHUDModulePoints:constructPoints(hud, rB, gB, bB, rP, gP, bP, talent)
    self:constructModule(hud, ERAHUDModulePoints_PointSize, talent)
    self.points = {}
    self.rB = rB
    self.gB = gB
    self.bB = bB
    self.rP = rP
    self.gP = gP
    self.bP = bP
    self.currentPoints = 0
    self.maxPoints = 0
end

function ERAHUDModulePoints:checkTalentOverride()
    self:updateMaxPoints()
    return true
end

function ERAHUDModulePoints:updateMaxPoints()
    local maxPoints = self:getMaxPoints()
    if maxPoints ~= self.maxPoints then
        if maxPoints > self.maxPoints then
            for i = self.maxPoints + 1, maxPoints do
                if i > #(self.points) then
                    local p = ERAHUDModulePoint:create(self.frame, self.rB, self.gB, self.bB, self.rP, self.gP, self.bP)
                    table.insert(self.points, p)
                end
            end
        else
            for i = maxPoints + 1, self.maxPoints do
                self.points[i]:hide()
            end
        end
        self.maxPoints = maxPoints
        local pointSize = ERAHUDModulePoints_PointSize + ERAHUDModulePoints_PointSpacing
        local x = (self.hud.barsWidth - maxPoints * pointSize) / 2 + pointSize / 2
        for i = 1, maxPoints do
            self.points[i]:draw(x, self.frame)
            x = x + pointSize
        end
    end
end

---@return integer
function ERAHUDModulePoints:GetIdlePointsOverride()
    return 0
end

---@param combat boolean
---@param t number
function ERAHUDModulePoints:updateData(t, combat)
    self:updateMaxPoints()
    self.currentPoints = self:getCurrentPoints()
end

---@param combat boolean
---@param t number
function ERAHUDModulePoints:updateDisplay(t, combat)
    if combat or self.currentPoints ~= self:GetIdlePointsOverride() then
        for i = 1, self.currentPoints do
            self.points[i]:update(true)
        end
        for i = self.currentPoints + 1, self.maxPoints do
            self.points[i]:update(false)
        end
        self:show()
    else
        self:hide()
    end
end

--#endregion
--------------------

-------------------
--#region POINT ---

---@class ERAHUDModulePoint
---@field private __index unknown
---@field private frame Frame
---@field private border Texture
---@field private point Texture
---@field private active boolean
ERAHUDModulePoint = {}
ERAHUDModulePoint.__index = ERAHUDModulePoint

---@param parentFrame Frame
---@param rB number
---@param gB number
---@param bB number
---@param rP number
---@param gP number
---@param bP number
---@return ERAHUDModulePoint
function ERAHUDModulePoint:create(parentFrame, rB, gB, bB, rP, gP, bP)
    local p = {}
    setmetatable(p, ERAHUDModulePoint)
    ---@cast p ERAHUDModulePoint
    local frame = CreateFrame("Frame", nil, parentFrame, "ERACombatPointFrame")
    local border = frame.Border
    local point = frame.Point
    ---@cast frame Frame
    p.frame = frame
    p.border = border
    p.point = point
    frame:SetSize(ERAHUDModulePoints_PointSize, ERAHUDModulePoints_PointSize)
    p.border:SetVertexColor(rB, gB, bB)
    p.point:SetVertexColor(rP, gP, bP)
    p.active = true
    return p
end

function ERAHUDModulePoint:hide()
    self.frame:Hide()
end

---@param x number
---@param parentFrame Frame
function ERAHUDModulePoint:draw(x, parentFrame)
    self.frame:Show()
    self.frame:SetPoint("CENTER", parentFrame, "LEFT", x, 0)
end

---@param active boolean
function ERAHUDModulePoint:update(active)
    if self.active ~= active then
        if active then
            self.active = true
            self.point:Show()
        else
            self.active = false
            self.point:Hide()
        end
    end
end

--#endregion
-------------------

------------------------
--#region UNIT POWER ---

---@class ERAHUDModulePointsUnitPower : ERAHUDModulePoints
---@field private __index unknown
---@field private powerType integer
---@field protected getMaxPoints fun(this:ERAHUDModulePointsUnitPower): integer
---@field protected getCurrentPoints fun(this:ERAHUDModulePointsUnitPower): integer
ERAHUDModulePointsUnitPower = {}
ERAHUDModulePointsUnitPower.__index = ERAHUDModulePointsUnitPower
setmetatable(ERAHUDModulePointsUnitPower, { __index = ERAHUDModulePoints })

---@param hud ERAHUD
---@param powerType integer
---@param rB number
---@param gB number
---@param bB number
---@param rP number
---@param gP number
---@param bP number
---@param talent ERALIBTalent|nil
---@return ERAHUDModulePointsUnitPower
function ERAHUDModulePointsUnitPower:Create(hud, powerType, rB, gB, bB, rP, gP, bP, talent)
    local up = {}
    setmetatable(up, ERAHUDModulePointsUnitPower)
    ---@cast up ERAHUDModulePointsUnitPower
    up.powerType = powerType
    up:constructPoints(hud, rB, gB, bB, rP, gP, bP, talent)
    return up
end

function ERAHUDModulePointsUnitPower:getCurrentPoints()
    return UnitPower("player", self.powerType)
end
function ERAHUDModulePointsUnitPower:getMaxPoints()
    return UnitPowerMax("player", self.powerType)
end

--#endregion
------------------------

--#endregion
-------------------

---------------------
--#region PARTIAL ---

--------------------
--#region MODULE ---

---@alias ERAHUDModulePointsPartialDirection "FROM_CENTER" | "TO_LEFT" | "TO_RIGHT"

---@class (exact) ERAHUDModulePointsPartial : ERAHUDResourceModule
---@field private __index unknown
---@field protected constructPoints fun(this:ERAHUDModulePointsPartial, hud:ERAHUD, rB:number, gB:number, bB:number, rFP:number, gFP:number, bFP:number, rPP:number, gPP:number, bPP:number, talent:ERALIBTalent|nil, direction:ERAHUDModulePointsPartialDirection)
---@field private checkTalentOverride fun(this:ERAHUDModulePointsPartial): boolean
---@field private rB number
---@field private gB number
---@field private bB number
---@field private rFP number
---@field private gFP number
---@field private bFP number
---@field private rPP number
---@field private gPP number
---@field private bPP number
---@field private direction ERAHUDModulePointsPartialDirection
---@field private updateMax fun(this:ERAHUDModulePointsPartial)
---@field protected getMaxPoints fun(this:ERAHUDModulePointsPartial): integer
---@field protected getCurrentPoints fun(this:ERAHUDModulePointsPartial, t:number): number
---@field protected GetIdlePointsOverride fun(this:ERAHUDModulePointsPartial): number
---@field PreUpdateDisplayOverride nil|fun(this:ERAHUDModulePointsPartial, t:number, combat:boolean)
---@field private points ERAHUDModulePointPartial[]
---@field currentPoints number
---@field partialPoint number
---@field maxPoints integer
ERAHUDModulePointsPartial = {}
ERAHUDModulePointsPartial.__index = ERAHUDModulePointsPartial
setmetatable(ERAHUDModulePointsPartial, { __index = ERAHUDResourceModule })

---@param hud ERAHUD
---@param rB number
---@param gB number
---@param bB number
---@param rFP number
---@param gFP number
---@param bFP number
---@param rPP number
---@param gPP number
---@param bPP number
---@param talent ERALIBTalent|nil
---@param direction ERAHUDModulePointsPartialDirection
function ERAHUDModulePointsPartial:constructPoints(hud, rB, gB, bB, rFP, gFP, bFP, rPP, gPP, bPP, talent, direction)
    self:constructModule(hud, ERAHUDModulePoints_PointSize, talent)
    self.points = {}
    self.rB = rB
    self.gB = gB
    self.bB = bB
    self.rFP = rFP
    self.gFP = gFP
    self.bFP = bFP
    self.rPP = rPP
    self.gPP = gPP
    self.bPP = bPP
    self.direction = direction
    self.currentPoints = 0
    self.partialPoint = 0
    self.maxPoints = 0
end

function ERAHUDModulePointsPartial:checkTalentOverride()
    self:updateMax()
    return true
end

function ERAHUDModulePointsPartial:updateMax()
    local max = self:getMaxPoints()
    if max ~= self.maxPoints then
        self.maxPoints = max
        for i = 1 + #(self.points), max do
            table.insert(self.points, ERAHUDModulePointPartial:create(self, self.frame, self.rB, self.gB, self.bB))
        end
        local x
        local delta = ERAHUDModulePointsPartial_PointSize + ERAHUDModulePointsPartial_PointSpacing
        if self.direction == "FROM_CENTER" then
            x = self.hud.barsWidth / 2 - delta * max / 2 + delta / 2
        elseif self.direction == "TO_LEFT" then
            x = self.hud.barsWidth - delta * max + delta / 2
        else
            x = delta / 2
        end
        for i, p in ipairs(self.points) do
            p:updateTalent(self.frame, i, max, x)
            x = x + delta
        end
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDModulePointsPartial:SetFullColor(r, g, b)
    self.rFP = r
    self.gFP = g
    self.bFP = b
end

---@param t number
---@param combat boolean
function ERAHUDModulePointsPartial:updateData(t, combat)
    self:updateMax()
    self.currentPoints = self:getCurrentPoints(t)
    self.partialPoint = self.currentPoints - math.floor(self.currentPoints)
end

---@param t number
---@param combat boolean
function ERAHUDModulePointsPartial:updateDisplay(t, combat)
    if self.PreUpdateDisplayOverride then
        self:PreUpdateDisplayOverride(t, combat)
    end
    if (not combat) and self.currentPoints == self:GetIdlePointsOverride() then
        self:hide()
    else
        self:show()
    end
    if self.currentPoints >= self.maxPoints then
        for i = 1, self.maxPoints do
            self.points[i]:drawAvailable(self.rFP, self.gFP, self.bFP)
        end
    else
        for i = 1, self.currentPoints do
            self.points[i]:drawAvailable(self.rFP, self.gFP, self.bFP)
        end
        local nxt = 1 + math.floor(self.currentPoints)
        if self.partialPoint > 0 then
            self.points[nxt]:drawFilling(self.partialPoint, self.rPP, self.gPP, self.bPP)
            for i = nxt + 1, self.maxPoints do
                self.points[i]:drawEmpty()
            end
        else
            for i = nxt, self.maxPoints do
                self.points[i]:drawEmpty()
            end
        end
    end
end

--#endregion
--------------------

-------------------
--#region POINT ---

---@class (exact) ERAHUDModulePointPartial
---@field private __index unknown
---@field private frame Frame
---@field private point Texture
---@field private circle Texture
---@field private wasAvailable boolean
---@field private wasFilling boolean
---@field private wasEmpty boolean
---@field private rP number
---@field private gP number
---@field private bP number
---@field private updatePointColor fun(this:ERAHUDModulePointPartial, r:number, g:number, b:number)
ERAHUDModulePointPartial = {}
ERAHUDModulePointPartial.__index = ERAHUDModulePointPartial

---@param owner ERAHUDModulePointsPartial
---@param parentFrame Frame
---@param rB number
---@param gB number
---@param bB number
---@return ERAHUDModulePointPartial
function ERAHUDModulePointPartial:create(owner, parentFrame, rB, gB, bB)
    local p = {}

    local frame = CreateFrame("Frame", nil, parentFrame, "ERAHUDModulePointsPartialFrame")
    local point = frame.FULL_POINT
    local circle = frame.AROUND

    p.size = ERAHUDModulePointsPartial_PointSize
    p.trt = frame.TRT
    p.trr = frame.TRR
    p.tlt = frame.TLT
    p.tlr = frame.TLR
    p.blr = frame.BLR
    p.blt = frame.BLT
    p.brt = frame.BRT
    p.brr = frame.BRR
    ERAPieControl_Init(p)

    ---@cast frame Frame
    frame:SetSize(ERAHUDModulePointsPartial_PointSize, ERAHUDModulePointsPartial_PointSize)

    setmetatable(p, ERAHUDModulePointPartial)
    ---@cast p ERAHUDModulePointPartial
    p.frame = frame
    p.point = point
    p.circle = circle
    p.circle:SetVertexColor(rB, gB, bB)

    p.wasAvailable = false
    p.wasFilling = false
    p.wasEmpty = false
    return p
end

function ERAHUDModulePointPartial:updateTalent(frame, index, maxPoints, x)
    if (index > maxPoints) then
        self.frame:Hide()
    else
        self.frame:SetPoint("CENTER", frame, "LEFT", x, 0)
        self.frame:Show()
    end
end

---@param r number
---@param g number
---@param b number
function ERAHUDModulePointPartial:drawAvailable(r, g, b)
    if (not self.wasAvailable) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = true
        self.wasFilling = false
    end
    self:updatePointColor(r, g, b)
    ERAPieControl_SetOverlayValue(self, 0)
end

---@param r number
---@param g number
---@param b number
function ERAHUDModulePointPartial:updatePointColor(r, g, b)
    if self.rP ~= r or self.gP ~= g or self.bP ~= b then
        self.rP = r
        self.gP = g
        self.bP = b
        self.point:SetVertexColor(r, g, b, 1)
    end
end

---@param part number
---@param r number
---@param g number
---@param b number
function ERAHUDModulePointPartial:drawFilling(part, r, g, b)
    if (not self.wasFilling) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = false
        self.wasFilling = true
    end
    self:updatePointColor(r, g, b)
    ERAPieControl_SetOverlayValue(self, 1 - part)
end

function ERAHUDModulePointPartial:drawEmpty()
    if (not self.wasEmpty) then
        self.wasAvailable = false
        self.wasFilling = false
        self.wasEmpty = true
        self.point:Hide()
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

--#endregion
-------------------

--#endregion
---------------------

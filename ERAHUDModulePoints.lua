ERAHUDModulePoints_PointSize = 22
ERAHUDModulePoints_PointSpacing = 4

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
---@field updateData fun(this:ERAHUDModulePoints, combat:boolean, t:number)
---@field updateDisplay fun(this:ERAHUDModulePoints, combat:boolean, t:number)
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
function ERAHUDModulePoints:updateData(combat, t)
    self:updateMaxPoints()
    self.currentPoints = self:getCurrentPoints()
end

---@param combat boolean
---@param t number
function ERAHUDModulePoints:updateDisplay(combat, t)
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

------------------
--- UNIT POWER ---
------------------

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

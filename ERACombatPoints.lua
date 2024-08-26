-- TODO
-- tout

ERACombatPoints_PointSize = 22

------------------------------------------------------------------------------------------------------------------------
---- POINTS ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatPoints = {}
ERACombatPoints.__index = ERACombatPoints
setmetatable(ERACombatPoints, { __index = ERACombatModule })

function ERACombatPoints:ConstructPoints(cFrame, x, y, maxPoints, rB, gB, bB, rP, gP, bP, talent, anchor, ...)
    self:construct(cFrame, 0.2, 0.02, false, ...)
    self.frame = CreateFrame("Frame", nil, UIParent, nil)
    self.frame:SetSize(ERACombatPoints_PointSize * maxPoints * 2, ERACombatPoints_PointSize)
    if (anchor == 0) then
        self.frame:SetPoint("LEFT", UIParent, "CENTER", x, y)
    elseif (anchor == 1) then
        self.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    elseif (anchor == 2) then
        self.frame:SetPoint("RIGHT", UIParent, "CENTER", x, y)
    end
    self.anchor = anchor
    self.currentPoints = 0
    self.maxPoints = maxPoints
    self.talent = talent
    self.points = {}
    self.idlePoints = 0
    self.talentIdle = nil
    self.talentedIdlePoints = 0
    for i = 1, maxPoints do
        table.insert(self.points, ERACombatPoint:create(self, i, rB, gB, bB, rP, gP, bP))
    end
    self:drawPoints()
    self.rB = rB
    self.gB = gB
    self.bB = bB
    self.rP = rP
    self.gP = gP
    self.bP = bP
end

function ERACombatPoints:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatPoints:EnterCombat(fromIdle)
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatPoints:ExitVehicle(toCombat)
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:ResetToIdle()
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:CheckTalents()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.talentActive = false
        self.frame:Hide()
    else
        self.talentActive = true
        self:UpdateMaxPoints()
    end
end
function ERACombatPoints:UpdateMaxPoints()
    local max = self:GetMaxPoints()
    if (max ~= self.maxPoints) then
        if (max > self.maxPoints) then
            for i = self.maxPoints + 1, max do
                table.insert(self.points, ERACombatPoint:create(self, i, self.rB, self.gB, self.bB, self.rP, self.gP, self.bP))
            end
        end
        self.maxPoints = max
        self:drawPoints()
    end
end
function ERACombatPoints:GetMaxPoints()
    return self.maxPoints
end
function ERACombatPoints:drawPoints()
    if (self.anchor == 0) then
        for i = 1, self.maxPoints do
            self.points[i].frame:Show()
            self.points[i].frame:SetPoint("CENTER", self.frame, "LEFT", (i - 0.5) * ERACombatPoints_PointSize, 0)
        end
    elseif (self.anchor == 1) then
        for i = 1, self.maxPoints do
            self.points[i].frame:Show()
            self.points[i].frame:SetPoint("CENTER", self.frame, "CENTER", (i - self.maxPoints / 2 - 0.5) * ERACombatPoints_PointSize, 0)
        end
    elseif (self.anchor == 2) then
        for i = 1, self.maxPoints do
            self.points[i].frame:Show()
            self.points[i].frame:SetPoint("CENTER", self.frame, "RIGHT", (i - self.maxPoints - 0.5) * ERACombatPoints_PointSize, 0)
        end
    end
    for i = self.maxPoints + 1, #(self.points) do
        self.points[i].frame:Hide()
    end
end

function ERACombatPoints:SetBorderColor(rB, gB, bB)
    if (self.rB ~= rB or self.gB ~= gB or self.bB ~= bB) then
        self.rB = rB
        self.gB = gB
        self.bB = bB
        for i = 1, #(self.points) do
            self.points[i].border:SetVertexColor(rB, gB, bB)
        end
    end
end
function ERACombatPoints:SetPointColor(rP, gP, bP)
    if (self.rP ~= rP or self.gP ~= gP or self.bP ~= bP) then
        self.rP = rP
        self.gP = gP
        self.bP = bP
        for i = 1, #(self.points) do
            self.points[i].point:SetVertexColor(rP, gP, bP)
        end
    end
end

function ERACombatPoints:UpdateIdle(t)
    if (self.talentActive) then
        self:update(t)
        if (self.currentPoints == self.idlePoints or (self.currentPoints == self.talentedIdlePoints and self.talentIdle and self.talentIdle:PlayerHasTalent())) then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end
end
function ERACombatPoints:UpdateCombat(t)
    if (self.talentActive) then
        self:update(t)
    end
end
function ERACombatPoints:update(t)
    local points = self:GetCurrentPoints()
    if (points ~= self.currentPoints) then
        self.currentPoints = points
        local cpt = #(self.points)
        local upperBound
        if (points > cpt) then
            upperBound = cpt
        else
            upperBound = points
        end
        for i = 1, upperBound do
            self.points[i].point:Show()
        end
        for i = upperBound + 1, cpt do
            self.points[i].point:Hide()
        end
    end
    self:PointsUpdated(t)
end
function ERACombatPoints:PointsUpdated(t)
end
-- abstract function GetCurrentPoints(t)

ERACombatPoint = {}
ERACombatPoint.__index = ERACombatPoint

function ERACombatPoint:create(group, index, rB, gB, bB, rP, gP, bP)
    local p = {}
    setmetatable(p, ERACombatPoint)
    p.index = index
    p.frame = CreateFrame("Frame", nil, group.frame, "ERACombatPointFrame")
    p.frame:SetSize(ERACombatPoints_PointSize, ERACombatPoints_PointSize)
    p.border = p.frame.Border
    p.border:SetVertexColor(rB, gB, bB)
    p.point = p.frame.Point
    p.point:SetVertexColor(rP, gP, bP)
    p.point:Hide()
    return p
end

------------------------------------------------------------------------------------------------------------------------
---- POINTS UNITPOWER --------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatPointsUnitPower = {}
ERACombatPointsUnitPower.__index = ERACombatPointsUnitPower
setmetatable(ERACombatPointsUnitPower, { __index = ERACombatPoints })

function ERACombatPointsUnitPower:Create(cFrame, x, y, powerType, maxPoints, rB, gB, bB, rP, gP, bP, talent, anchor, ...)
    local p = {}
    setmetatable(p, ERACombatPointsUnitPower)
    p:ConstructPoints(cFrame, x, y, maxPoints, rB, gB, bB, rP, gP, bP, talent, anchor, ...)
    p.powerType = powerType
    p.events = {}
    function p.events:UNIT_MAXPOWER(unit, pType)
        --print(unit, pType)
        if (unit == "player") then
            self:UpdateMaxPoints()
        end
    end
    p.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            p.events[event](p, ...)
        end
    )
    for k, v in pairs(p.events) do
        p.frame:RegisterEvent(k)
    end
    return p
end

function ERACombatPointsUnitPower:GetMaxPoints()
    return UnitPowerMax("player", self.powerType)
end

function ERACombatPointsUnitPower:GetCurrentPoints(t)
    return UnitPower("player", self.powerType)
end

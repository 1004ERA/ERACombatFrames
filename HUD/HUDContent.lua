----------------------------------------------------------------
--#region GENERIC DISPLAY --------------------------------------

---@class (exact) HUDDisplay
---@field private __index HUDDisplay
---@field protected constructDisplay fun(self:HUDDisplay, hud:HUDModule, talent:ERALIBTalent|nil)
---@field hud HUDModule
---@field private talent ERALIBTalent|nil
---@field talentActive boolean
---@field protected talentIsActive fun(self:HUDDisplay)
---@field protected Activate fun(self:HUDDisplay)
---@field protected Deactivate fun(self:HUDDisplay)
---@field Update fun(self:HUDDisplay, t:number, combat:boolean)
HUDDisplay = {}
HUDDisplay.__index = HUDDisplay

function HUDDisplay:constructDisplay(hud, talent)
    self.hud = hud
    self.talentActive = nil
    self.talent = talent
end

---comment
---@return boolean
function HUDDisplay:computeActive()
    local active = (not self.talent) or self.talent:PlayerHasTalent()
    if (self.talentActive == nil) then
        if (active) then
            self.talentActive = true
            self:Activate()
        else
            self.talentActive = false
            self:Deactivate()
        end
    else
        if (active) then
            if (not self.talentActive) then
                self.talentActive = true
                self:Activate()
            end
        else
            if (self.talentActive) then
                self.talentActive = false
                self:Deactivate()
            end
        end
    end
    if (active) then
        self:talentIsActive()
        return true
    else
        return false
    end
end
function HUDDisplay:talentIsActive()
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region ESSENTIALS SLOT --------------------------------------

---@class (exact) HUDEssentialsSlot
---@field private __index HUDEssentialsSlot
---@field icon HUDIcon
---@field hud HUDModule
---@field private bars HUDTimerBar[]
HUDEssentialsSlot = {}
HUDEssentialsSlot.__index = HUDEssentialsSlot

---@param icon HUDIcon
---@param hud HUDModule
---@return HUDEssentialsSlot
function HUDEssentialsSlot:create(icon, hud)
    local x = {}
    setmetatable(x, HUDEssentialsSlot)
    ---@cast x HUDEssentialsSlot
    x.icon = icon
    x.hud = hud
    x.bars = {}
    return x
end

---@param xMid number
---@param iconSize number
---@param timerBarFrame Frame
function HUDEssentialsSlot:setPosition(xMid, iconSize, timerBarFrame)
    self.icon:setPosition(xMid, 0)
    for _, tb in ipairs(self.bars) do
        if (tb.talentActive) then
            tb:updateLayout(xMid, iconSize, timerBarFrame)
        end
    end
end

---@param bar HUDTimerBar
function HUDEssentialsSlot:addBar(bar)
    table.insert(self.bars, bar)
end

---@param position number
---@param timer HUDTimer
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@return HUDTimerBar
function HUDEssentialsSlot:AddTimerBar(position, timer, talent, r, g, b)
    return HUDTimerBar:Create(self, position, timer, talent, r, g, b, self.hud:getTimerBarFrame())
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region RESOURCE SLOT ----------------------------------------

---@class (exact) HUDResourceSlot
---@field private __index HUDResourceSlot
---@field hud HUDModule
---@field private resources HUDResourceDisplay[]
HUDResourceSlot = {}
HUDResourceSlot.__index = HUDResourceSlot

---@param hud HUDModule
---@return HUDResourceSlot
function HUDResourceSlot:create(hud)
    local x = {}
    setmetatable(x, HUDResourceSlot)
    ---@cast x HUDResourceSlot
    x.hud = hud
    x.resources = {}
    return x
end

function HUDResourceSlot:computeTalents()
    for _, res in ipairs(self.resources) do
        if (res:computeActive()) then
            self.hud:addActiveResource(res)
        end
    end
end

---@param y number
---@param width number
---@param resourceFrame Frame
function HUDResourceSlot:updateLayout_returnHeight(y, width, resourceFrame)
    local height = 0
    for _, res in ipairs(self.resources) do
        if (res.talentActive) then
            local h = res:measure_returnHeight(y, width, resourceFrame)
            if (h > height) then
                height = h
            end
        end
    end
    for _, res in ipairs(self.resources) do
        if (res.talentActive) then
            res:arrange(y, width, height, resourceFrame)
        end
    end
    return height
end

---@param data HUDHealth
---@param isPet boolean
---@return HUDHealthDisplay
function HUDResourceSlot:AddHealth(data, isPet)
    local r = HUDHealthDisplay:create(self.hud, data, isPet, self.hud:getResourceFrame(), 1 + #self.resources)
    table.insert(self.resources, r)
    return r
end

---@param data HUDPower
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return HUDPowerBarPowerDisplay
function HUDResourceSlot:AddPowerValue(data, r, g, b, talent)
    local res = HUDPowerBarPowerDisplay:create(self.hud, data, r, g, b, talent, self.hud:getResourceFrame(), 1 + #self.resources, HUDPowerBarDisplayKindPowerValue:create())
    table.insert(self.resources, res)
    return res
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region TIMER BAR --------------------------------------------

---@class (exact) HUDTimerBar : HUDDisplay
---@field private __index HUDTimerBar
---@field private position number
---@field private timer HUDTimer
---@field private bar StatusBar
---@field doNotCutLongDuration boolean
HUDTimerBar = {}
HUDTimerBar.__index = HUDTimerBar
setmetatable(HUDTimerBar, { __index = HUDDisplay })

---@param placement HUDEssentialsSlot
---@param position number
---@param timer HUDTimer
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@param timerFrame Frame
---@return HUDTimerBar
function HUDTimerBar:Create(placement, position, timer, talent, r, g, b, timerFrame)
    local x = {}
    setmetatable(x, HUDTimerBar)
    ---@cast x HUDTimerBar
    x:constructDisplay(placement.hud, talent)
    x.timer = timer
    x.position = position
    placement.hud:addTimerBar(x)
    placement:addBar(x)

    x.bar = CreateFrame("StatusBar", nil, timerFrame)
    x.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar-Glow")
    x.bar:SetRotatesTexture(true)
    x.bar:SetStatusBarColor(r, g, b, 1.0)
    x.bar:SetHeight(ERA_HUDModule_TimerHeight)
    x.bar:SetFrameLevel(2)
    x.bar:SetOrientation("VERTICAL")

    return x
end

function HUDTimerBar:Activate()
    self.bar:Show()
end

function HUDTimerBar:Deactivate()
    self.bar:Hide()
end

---comment
---@param xMid number
---@param iconWidth number
---@param timerFrame Frame
function HUDTimerBar:updateLayout(xMid, iconWidth, timerFrame)
    self.bar:SetWidth(self.hud.options.essentialsTimerBarSize)
    self.bar:SetPoint("BOTTOM", timerFrame, "BOTTOM", xMid + (self.position - 0.5) * iconWidth, 0)
end

---comment
---@param maxTimer number
function HUDTimerBar:updateMaxDuration(maxTimer)
    self.bar:SetMinMaxValues(0, maxTimer)
end

---comment
---@param t number
---@param combat boolean
function HUDTimerBar:Update(t, combat)
    if (combat) then
        if (self.doNotCutLongDuration) then
            self.bar:SetValue(self.timer.timerDuration:GetRemainingDuration())
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            self.bar:SetValue(self.timer.timerDuration:EvaluateRemainingDuration(self.hud.curveTimer))
        end
    end
end

--#endregion
----------------------------------------------------------------

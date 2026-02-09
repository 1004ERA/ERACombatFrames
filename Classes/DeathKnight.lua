---@param cFrame ERACombatMainFrame
function ERACombatFrames_DeathKnightSetup(cFrame)
    ---@class DeathKnightTalents
    local talents = {
        fortitude = ERALIBTalent:Create(96210),
        ghoul = ERALIBTalent:Create(96201),
        kick = ERALIBTalent:Create(96213),
        blind = ERALIBTalent:Create(96172),
        walk = ERALIBTalent:Create(133518),
        pact = ERALIBTalent:Create(96204),
        amz = ERALIBTalent:Create(96194),
        vader = ERALIBTalent:Create(96193),
        icePrison = ERALIBTalent:Create(96215),
        chill = ERALIBTalent:Create(96179),
        draw = ERALIBTalent:Create(96184),
    }

    ERACombatFrames_DeathKnight_Blood(cFrame, talents)
    ERACombatFrames_DeathKnight_Frost(cFrame, talents)
    ERACombatFrames_DeathKnight_Unholy(cFrame, talents)
end

---@class (exact) HUDRuneItem
---@field private __index HUDRuneItem
---@field index number
---@field isReady boolean
---@field duration number
---@field startTime number
---@field remainingTime number
---@field startTimeMaybeSecret number
---@field durationMaybeSecret number
---@field isReadyMaybeSecret boolean
---@field somethingMayBeSecret boolean
HUDRuneItem = {}
HUDRuneItem.__index = HUDRuneItem

---@param index number
---@return HUDRuneItem
function HUDRuneItem:create(index)
    local x = {}
    setmetatable(x, HUDRuneItem)
    ---@cast x HUDRuneItem
    x.index = index
    x.isReady = true
    x.isReadyMaybeSecret = true
    x.somethingMayBeSecret = true
    x.duration = 10
    x.startTime = 0
    x.remainingTime = 0
    x.startTimeMaybeSecret = 0
    x.durationMaybeSecret = 0
    return x
end

---@param t number
---@return boolean
function HUDRuneItem:updateData_returnSecret(t)
    local startTime, duration, isRuneReady = GetRuneCooldown(self.index)
    self.startTimeMaybeSecret = startTime
    self.durationMaybeSecret = duration
    self.isReadyMaybeSecret = isRuneReady
    ---@diagnostic disable-next-line: param-type-mismatch
    if (issecretvalue(startTime) or issecretvalue(duration) or issecretvalue(isRuneReady)) then
        -- estimation
        self.remainingTime = self.duration - (t - self.startTime)
        if (self.remainingTime < 0) then self.remainingTime = 0 end
        self.somethingMayBeSecret = true
        return true
    else
        self.startTime = startTime
        self.duration = duration
        self.isReady = isRuneReady
        if (isRuneReady) then
            self.remainingTime = 0
        else
            self.remainingTime = duration - (t - startTime)
            if (self.remainingTime < 0) then self.remainingTime = 0 end
        end
        self.somethingMayBeSecret = false
        return false
    end
end

---@param r1 HUDRuneItem
---@param r2 HUDRuneItem
---@return boolean
function ECF_SortRunes(r1, r2)
    if (r1.remainingTime == r2.remainingTime) then
        return r1.index > r2.index
    else
        return r1.remainingTime > r2.remainingTime
    end
end

---@class (exact) HUDRunesData : HUDDataItem
---@field private __index HUDRunesData
---@field private runes HUDRuneItem[]
---@field runesOrdered HUDRuneItem[]
---@field maybeSecret boolean
---@field allRunesReady boolean
HUDRunesData = {}
HUDRunesData.__index = HUDRunesData
setmetatable(HUDRunesData, { __index = HUDDataItem })

---@param hud HUDModule
---@return HUDRunesData
function HUDRunesData:create(hud)
    local x = {}
    setmetatable(x, HUDRunesData)
    ---@cast x HUDRunesData
    x:constructItem(hud, nil)
    x.runes = {}
    x.runesOrdered = {}
    for i = 1, 6 do
        local rune = HUDRuneItem:create(i)
        table.insert(x.runes, rune)
        table.insert(x.runesOrdered, rune)
    end
    x.allRunesReady = true
    x.maybeSecret = true
    return x
end

---@param t number
---@param combat boolean
function HUDRunesData:Update(t, combat)
    self.maybeSecret = false
    for _, r in ipairs(self.runes) do
        if (r:updateData_returnSecret(t)) then
            self.maybeSecret = true
        end
    end
    if (not self.maybeSecret) then
        self.allRunesReady = true
        for _, r in ipairs(self.runes) do
            if (not r.isReady) then
                self.allRunesReady = false
                break
            end
        end
    end
    table.sort(self.runesOrdered, ECF_SortRunes)
end

---@class (exact) HUDRunesResource : HUDResourceDisplay
---@field private __index HUDRunesResource
---@field private data HUDRunesData
---@field private runeSize number
---@field private frame Frame
---@field private displays HUDRuneDisplayItem[]
---@field private frameVisible boolean
HUDRunesResource = {}
HUDRunesResource.__index = HUDRunesResource
setmetatable(HUDRunesResource, { __index = HUDResourceDisplay })

---comment
---@param hud HUDModule
---@param data HUDRunesData
---@param resourceFrame Frame
---@param frameLevel number
---@return HUDRunesResource
function HUDRunesResource:create(hud, data, resourceFrame, frameLevel)
    local x = {}
    setmetatable(x, HUDRunesResource)
    ---@cast x HUDRunesResource
    x:constructResource(hud, false)
    x.data = data

    x.frame = CreateFrame("Frame", nil, resourceFrame)
    x.displays = {}
    for _ = 1, 6 do
        local rd = HUDRuneDisplayItem:create(x.frame, hud.options.powerHeight)
        table.insert(x.displays, rd)
    end
    x.frameVisible = false
    x.frame:Hide()

    return x
end

function HUDRunesResource:Activate()
    self.frame:Hide()
    self.frameVisible = false
end
function HUDRunesResource:Deactivate()
    self.frame:Hide()
end

---@param y number
---@param width number
---@param resourceFrame Frame
---@return number
function HUDRunesResource:measure_returnHeight(y, width, resourceFrame)
    self.runeSize = math.min(self.hud.options.powerHeight, width / 6)
    return self.runeSize
end
---@param y number
---@param width number
---@param height number
---@param resourceFrame Frame
function HUDRunesResource:arrange(y, width, height, resourceFrame)
    self.frame:SetPoint("CENTER", resourceFrame, "TOP", 0, y - height / 2)
    self.frame:SetSize(width, height)
    for i, r in ipairs(self.displays) do
        r:updateLayout(self.frame, self.runeSize, (i - 3.5) * self.runeSize)
    end
end

---@param t number
---@param combat boolean
function HUDRunesResource:Update(t, combat)
    local mustShow
    if (combat) then
        mustShow = true
    else
        if (self.data.maybeSecret) then
            mustShow = true
        else
            mustShow = not self.data.allRunesReady
        end
    end
    if (mustShow) then
        if (not self.frameVisible) then
            self.frameVisible = true
            self.frame:Show()
        end
    else
        if (self.frameVisible) then
            self.frameVisible = false
            self.frame:Hide()
        end
        return
    end

    for i = 1, 6 do
        self.displays[i]:updateDisplay(self.data.runesOrdered[i])
    end
end

---@class (exact) HUDRuneDisplayItem
---@field private __index HUDRuneDisplayItem
---@field icon ERAPieIcon
HUDRuneDisplayItem = {}
HUDRuneDisplayItem.__index = HUDRuneDisplayItem

---@param parentFrame Frame
---@param initSize number
---@return HUDRuneDisplayItem
function HUDRuneDisplayItem:create(parentFrame, initSize)
    local x = {}
    setmetatable(x, HUDRuneDisplayItem)
    ---@cast x HUDRuneDisplayItem

    x.icon = ERAPieIcon:create(parentFrame, "CENTER", "CENTER", initSize, initSize)
    -- rune : 1121021
    -- rune violette forte : 252272
    -- rune violette faible : 1323037
    x.icon:SetIconTexture(1121021, true)

    return x
end

---@param parentFrame Frame
---@param size number
---@param x number
function HUDRuneDisplayItem:updateLayout(parentFrame, size, x)
    self.icon:SetSize(size)
    self.icon:SetPosition(x, 0)
end

---@param data HUDRuneItem
function HUDRuneDisplayItem:updateDisplay(data)
    self.icon:SetValue(data.startTime, data.duration)
    if (data.somethingMayBeSecret) then
        self.icon:ShowDefaultCountdown()
    else
        local iconID
        if (data.isReady) then
            iconID = 1121021
            self.icon:HideDefaultCountdown()
        else
            iconID = 1323037
            if (data.duration - data.remainingTime < 0.1) then
                self.icon:HideDefaultCountdown()
            else
                self.icon:ShowDefaultCountdown()
            end
        end
        self.icon:SetIconTexture(iconID, false)
    end
end

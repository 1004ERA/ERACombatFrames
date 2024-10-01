ERAHUDDOT_MainBarSize = ERAHUD_TimerBarDefaultSize + 4
ERAHUDDOT_SecondaryBarSize = ERAHUD_TimerBarDefaultSize - 4

ERAHUDDOT_alpha_LONG_TARGET = 0.6
ERAHUDDOT_alpha_REFRESH_TARGET = 1.0
ERAHUDDOT_alpha_LONG_SINGLE_INSTANCE = 0.6
ERAHUDDOT_alpha_REFRESH_SINGLE_INSTANCE = 0.8
ERAHUDDOT_alpha_LONG_OTHER = 0.1
ERAHUDDOT_alpha_REFRESH_OTHER = 0.6

---@class ERAHUDDOT : ERAHUDNestedModule
---@field private __index unknown
---@field private timerFrame Frame
---@field private defs ERAHUDDOTDefinition[]
---@field private activeDefs table<integer, ERAHUDDOTDefinition>
---@field private activeDefsArray ERAHUDDOTDefinition[]
---@field enemiesByGUID table<string, ERAHUDDOTEnemy>
---@field enemiesByPlate table<string, ERAHUDDOTEnemy>
---@field events unknown
---@field private evtFrame Frame
---@field enemiesCount integer
ERAHUDDOT = {}
ERAHUDDOT.__index = ERAHUDDOT
setmetatable(ERAHUDDOT, { __index = ERAHUDNestedModule })

---@param hud ERAHUD
---@return ERAHUDDOT
function ERAHUDDOT:Create(hud)
    local w = {}
    setmetatable(w, ERAHUDDOT)
    ---@cast w ERAHUDDOT
    w.defs = {}
    w.activeDefs = {}
    w.activeDefsArray = {}
    w.timerFrame = w:constructNested(hud, true)

    w.enemiesByGUID = {}
    w.enemiesByPlate = {}
    w.enemiesCount = 0

    w.evtFrame = CreateFrame("Frame", nil, w.timerFrame)

    -- évènements
    w.events = {}
    function w.events:NAME_PLATE_UNIT_ADDED(unitToken)
        local guid = UnitGUID(unitToken)
        if (guid ~= nil) then
            local e = ERAHUDDOTEnemy:create(w, guid, unitToken)
            w.enemiesByGUID[guid] = e
            w.enemiesByPlate[unitToken] = e
            w.enemiesCount = w.enemiesCount + 1
        end
    end
    function w.events:NAME_PLATE_UNIT_REMOVED(unitToken)
        local enemy = w.enemiesByPlate[unitToken]
        if (enemy) then
            w:removeEnemy(enemy)
        end
    end
    w.evtFrame:SetScript(
        "OnEvent",
        function(self, event, ...)
            w.events[event](self, ...)
        end
    )
    for k, _ in pairs(w.events) do
        w.evtFrame:RegisterEvent(k)
    end

    return w
end

---@param overlayFrame Frame
function ERAHUDDOT:createOverlay(overlayFrame)
    for _, def in ipairs(self.defs) do
        def:createOverlay(overlayFrame)
    end
end

function ERAHUDDOT:show()
    -- rien
end
function ERAHUDDOT:hide()
    -- rien
end

function ERAHUDDOT:checkTalents()
    table.wipe(self.activeDefs)
    table.wipe(self.activeDefsArray)
    for _, d in ipairs(self.defs) do
        if d.talent and not d.talent:PlayerHasTalent() then
            d:talentInactive()
        else
            self.activeDefs[d.onTarget.spellID] = d
            table.insert(self.activeDefsArray, d)
        end
    end
end

---@param t number
function ERAHUDDOT:CLEU(t)
    local _, evt, _, _, _, _, _, targetGUID = CombatLogGetCurrentEventInfo()
    if (evt == "UNIT_DIED" or evt == "UNIT_DESTROYED" or evt == "UNIT_DISSIPATES") then
        local tar = self.enemiesByGUID[targetGUID]
        if (tar) then
            self:removeEnemy(tar)
        end
    end
end

---@param e ERAHUDDOTEnemy
function ERAHUDDOT:removeEnemy(e)
    self.enemiesByGUID[e.guid] = nil
    self.enemiesByPlate[e.plateID] = nil
    self.enemiesCount = self.enemiesCount - 1
end

---@param t number
function ERAHUDDOT:updateData(t)
    for _, d in pairs(self.activeDefs) do
        d:prepareUpdateData(t)
    end
    local targetGUID = UnitGUID("target")
    for _, e in pairs(self.enemiesByPlate) do
        if targetGUID ~= e.guid then
            local i = 1
            while true do
                local auraInfo = C_UnitAuras.GetDebuffDataByIndex(e.plateID, i, "PLAYER")
                if auraInfo then
                    local def = self.activeDefs[auraInfo.spellId]
                    if def then
                        def:found(t, auraInfo, e)
                    end
                    i = i + 1
                else
                    break
                end
            end
        end
    end
    for _, d in ipairs(self.activeDefsArray) do
        d:computeUpdateData()
    end
end

---@param t number
---@param y number
---@param timerFrame Frame
---@param overlayFrame Frame
---@return number
function ERAHUDDOT:updateDisplay_returnHeight(t, y, timerFrame, overlayFrame)
    local height = 0
    for _, d in ipairs(self.activeDefsArray) do
        y = y + ERAHUD_TimerBarSpacing
        d:drawTarget(y, timerFrame, overlayFrame)
        y = y + ERAHUDDOT_MainBarSize
        height = height + ERAHUD_TimerBarSpacing + ERAHUDDOT_MainBarSize
    end
    if height > 0 then
        y = y + ERAHUD_TimerBarSpacing
        height = height + ERAHUD_TimerBarSpacing
    end
    for _, d in ipairs(self.activeDefsArray) do
        y = d:drawOthers_returnY(y, timerFrame)
    end
    return height
end

-----------------
--#region DOT ---

---@param spellID integer
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@param castTime number
---@param baseTotDuration number
---@return ERAHUDDOTDefinition
function ERAHUDDOT:AddDOT(spellID, iconID, r, g, b, talent, castTime, baseTotDuration)
    local d = ERAHUDDOTDefinition:create(self, self.timerFrame, spellID, iconID, r, g, b, talent, castTime, baseTotDuration)
    table.insert(self.defs, d)
    return d
end

---@class (exact) ERAHUDDOTDefinition
---@field private __index unknown
---@field talent ERALIBTalent|nil
---@field owner ERAHUDDOT
---@field onTarget ERAAura
---@field private onOthers ERAHUDDOTInstance[]
---@field private activeOnOthers ERAHUDDOTInstance[]
---@field private maxDurationIndex integer
---@field private foundCount integer
---@field mainBar ERAHUDDOTBar
---@field castTime number
---@field baseCastTime number
---@field baseTotDuration number
---@field refreshDuration number
---@field minActiveDuration number
---@field minActiveIsOnTarget boolean
---@field couldRefresh boolean
---@field singleInstance boolean
---@field private refreshLine Line
---@field private refreshLineVisible boolean
---@field ComputeRefreshDurationOverride fun(this:ERAHUDDOTDefinition, t:number): number
---@field ComputeCastTimeOverride fun(this:ERAHUDDOTDefinition, t:number): number
ERAHUDDOTDefinition = {}
ERAHUDDOTDefinition.__index = ERAHUDDOTDefinition

---@param owner ERAHUDDOT
---@param frame Frame
---@param spellID integer
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@param castTime number
---@param baseTotDuration number
---@return ERAHUDDOTDefinition
function ERAHUDDOTDefinition:create(owner, frame, spellID, iconID, r, g, b, talent, castTime, baseTotDuration)
    local d = {}
    setmetatable(d, ERAHUDDOTDefinition)
    ---@cast d ERAHUDDOTDefinition
    d.talent = talent
    d.owner = owner
    d.onTarget = owner.hud:AddTrackedDebuffOnTarget(spellID, talent)
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        iconID = spellInfo.iconID
    end
    d.mainBar = ERAHUDDOTBar:create(d, frame, r, g, b, iconID, ERAHUDDOT_MainBarSize, 1.0)

    d.onOthers = {}
    d.activeOnOthers = {}
    for i = 1, 3 do
        table.insert(d.onOthers, ERAHUDDOTInstance:create(d, frame, r, g, b, iconID))
    end
    d.maxDurationIndex = -1
    d.foundCount = 0

    d.castTime = castTime
    d.baseCastTime = castTime
    d.baseTotDuration = baseTotDuration
    d.refreshDuration = 0.3 * baseTotDuration
    d.minActiveDuration = 0
    d.minActiveIsOnTarget = false

    return d
end

---@param overlayFrame Frame
function ERAHUDDOTDefinition:createOverlay(overlayFrame)
    self.refreshLine = overlayFrame:CreateLine()
    self.refreshLine:SetColorTexture(1.0, 1.0, 1.0)
    self.refreshLineVisible = false
    self.refreshLine:Hide()
end

function ERAHUDDOTDefinition:talentInactive()
    self.refreshLine:Hide()
    self.refreshLineVisible = false
    self.mainBar:hide()
    for _, oo in ipairs(self.onOthers) do
        oo:hide()
    end
end

---@param t number
function ERAHUDDOTDefinition:prepareUpdateData(t)
    for _, i in ipairs(self.onOthers) do
        i:prepareUpdateData()
    end
    self.foundCount = 0
    self.refreshDuration = self:ComputeRefreshDurationOverride(t)
    self.castTime = self:ComputeCastTimeOverride(t) * self.owner.hud.hasteMultiplier
    if not self.singleInstance then
        if UnitExists("target") then
            self.couldRefresh = self.onTarget.remDuration - self.castTime < self.refreshDuration
        else
            self.couldRefresh = false
        end
    end
end
function ERAHUDDOTDefinition:ComputeRefreshDurationOverride(t)
    return 0.3 * self.baseTotDuration
end
function ERAHUDDOTDefinition:ComputeCastTimeOverride(t)
    return self.baseCastTime
end

---@param t number
---@param auraInfo AuraData
---@param e ERAHUDDOTEnemy
function ERAHUDDOTDefinition:found(t, auraInfo, e)
    local dur
    if auraInfo.expirationTime and auraInfo.expirationTime > 0 then
        dur = auraInfo.expirationTime - t
    else
        dur = self.baseTotDuration
    end

    if self.foundCount == 0 then
        self.maxDurationIndex = 1
        self.foundCount = 1
        self.onOthers[1]:assign(dur, e)
    else
        if self.foundCount < #(self.onOthers) then
            self.foundCount = self.foundCount + 1
            self.onOthers[self.foundCount]:assign(dur, e)
            local currentMax = self.onOthers[self.maxDurationIndex].duration
            if currentMax < dur then
                self.maxDurationIndex = self.foundCount
            end
        else
            local currentMax = self.onOthers[self.maxDurationIndex].duration
            if currentMax > dur then
                self.onOthers[self.maxDurationIndex]:assign(dur, e)
                currentMax = dur
                for i, instance in ipairs(self.onOthers) do
                    if instance.duration > currentMax then
                        currentMax = instance.duration
                        self.maxDurationIndex = i
                    end
                end
            end
        end
    end
end

function ERAHUDDOTDefinition:computeUpdateData()
    for _, i in ipairs(self.onOthers) do
        i:computeUpdateData()
    end
    local min
    if self.onTarget.remDuration > 0 then
        min = self.onTarget.remDuration
    else
        min = 0
    end
    self.minActiveIsOnTarget = true
    for _, i in ipairs(self.onOthers) do
        if i.duration > 0 and (min == 0 or i.duration < min) then
            min = i.duration
            self.minActiveIsOnTarget = false
        end
    end
    self.minActiveDuration = min
    if self.singleInstance then
        self.couldRefresh = min - self.castTime < self.refreshDuration
    end
end

---@param y number
---@param frame Frame
---@param overlayFrame Frame
function ERAHUDDOTDefinition:drawTarget(y, frame, overlayFrame)
    local stacks, dur, alpha, desat
    if self.singleInstance then
        dur = self.minActiveDuration
        stacks = 0
        if self.minActiveIsOnTarget then
            if self.couldRefresh then
                alpha = ERAHUDDOT_alpha_REFRESH_TARGET
                desat = false
            else
                alpha = ERAHUDDOT_alpha_LONG_TARGET
                desat = true
            end
        else
            desat = true
            if self.couldRefresh then
                alpha = ERAHUDDOT_alpha_REFRESH_SINGLE_INSTANCE
            else
                alpha = ERAHUDDOT_alpha_LONG_SINGLE_INSTANCE
            end
        end
    else
        dur = self.onTarget.remDuration
        stacks = self.onTarget.stacks
        if self.couldRefresh then
            alpha = ERAHUDDOT_alpha_REFRESH_TARGET
            desat = false
        else
            alpha = ERAHUDDOT_alpha_LONG_TARGET
            desat = true
        end
    end
    if stacks <= 1 then
        self.mainBar:SetText(nil)
    else
        self.mainBar:SetText(tostring(self.onTarget.stacks))
    end
    self.mainBar:draw(y, frame, dur, alpha, desat)
    if self.owner.hud.timerDuration > self.refreshDuration and self.refreshDuration < dur then
        local x = self.owner.hud:calcTimerPixel(self.refreshDuration)
        self.refreshLine:SetStartPoint("RIGHT", overlayFrame, x, y)
        self.refreshLine:SetEndPoint("RIGHT", overlayFrame, x, y + ERAHUDDOT_MainBarSize)
        if not self.refreshLineVisible then
            self.refreshLineVisible = true
            self.refreshLine:Show()
        end
    else
        if self.refreshLineVisible then
            self.refreshLineVisible = false
            self.refreshLine:Hide()
        end
    end
end

---@param y number
---@param frame Frame
---@return number
function ERAHUDDOTDefinition:drawOthers_returnY(y, frame)
    if not self.singleInstance then
        table.wipe(self.activeOnOthers)
        for _, i in ipairs(self.onOthers) do
            if i.duration > 0 then
                table.insert(self.activeOnOthers, i)
            else
                i:hide()
            end
        end
        table.sort(self.activeOnOthers, ERAHUDDOTInstance_sortDurations)
        for _, i in ipairs(self.activeOnOthers) do
            y = i:draw(y, frame)
        end
    end
    return y
end

--#endregion
-----------------

-----------------
--#region BAR ---

---@class (exact) ERAHUDDOTBar
---@field private __index unknown
---@field private definition ERAHUDDOTDefinition
---@field private display StatusBar
---@field private icon Texture
---@field private text FontString
---@field private textValue string|nil
---@field private y number
---@field private anim AnimationGroup
---@field private translation Translation
---@field private endAnimate fun(this:ERAHUDDOTBar, frame:Frame)
---@field private visible boolean
---@field private active boolean
---@field private alpha number
---@field private iconDesat boolean
ERAHUDDOTBar = {}
ERAHUDDOTBar.__index = ERAHUDDOTBar

---@param definition ERAHUDDOTDefinition
---@param frame Frame
---@param r number
---@param g number
---@param b number
---@param iconID integer
---@param size number
---@param iconAlpha number
---@return ERAHUDDOTBar
function ERAHUDDOTBar:create(definition, frame, r, g, b, iconID, size, iconAlpha)
    local bar = {}
    setmetatable(bar, ERAHUDDOTBar)
    ---@cast bar ERAHUDDOTBar

    bar.definition = definition

    local display = CreateFrame("StatusBar", nil, frame, "ERAHUDTimerBar")
    local icon = display.Icon
    local text = display.Text
    local anim = display.Anim
    local translation = anim.Translation
    ---@cast icon Texture
    ---@cast text FontString
    ---@cast anim AnimationGroup
    ---@cast translation Translation
    ---@cast display StatusBar
    bar.display = display
    bar.anim = anim
    bar.translation = translation
    local ea = bar.endAnimate
    translation:SetScript(
        "OnFinished",
        function()
            ea(bar, frame)
        end
    )
    bar.text = text
    bar.textValue = nil
    bar.icon = icon
    icon:SetSize(size, size)
    icon:SetTexture(iconID)
    if iconAlpha ~= 1 then
        icon:SetAlpha(iconAlpha)
    end
    bar.iconDesat = false
    bar.y = 0
    display:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    display:SetStatusBarColor(r, g, b, 1)
    display:SetWidth(1.5 * ERAHUD_TimerWidth)
    display:SetHeight(size)
    display:SetMinMaxValues(0, 1)
    text:SetHeight(size)
    ERALIB_SetFont(text, size * 0.8)

    bar.active = true
    bar.alpha = 1
    bar.visible = true
    bar:hide()

    return bar
end

function ERAHUDDOTBar:hide()
    if self.visible then
        self.visible = false
        self.display:Hide()
        self.text:Hide()
        self.icon:Hide()
    end
end

---@param y number
---@param frame Frame
---@param duration number
---@param alpha number
---@param iconDesat boolean
function ERAHUDDOTBar:draw(y, frame, duration, alpha, iconDesat)
    if self.visible then
        if self.y ~= y then
            self.translation:SetOffset(0, y - self.y)
            self.anim:Play()
        else
            self:endAnimate(frame)
        end
    else
        self.visible = true
        self.display:Show()
        self.text:Show()
        self.icon:Show()
    end
    self.y = y
    if duration > 0 then
        local hud = self.definition.owner.hud
        local max = hud.timerDuration
        self.display:SetMinMaxValues(0, 1.5 * max)
        if (duration > max) then
            self.display:SetValue(max * (1 + 0.5 * (1 - math.exp(-0.2 * (duration - max)))))
        else
            self.display:SetValue(duration)
        end
        if not self.active then
            self.active = true
            self.icon:SetVertexColor(1.0, 1.0, 1.0)
        end
    else
        if self.active then
            self.active = false
            self.icon:SetVertexColor(1.0, 0.0, 0.0)
        end
        self.display:SetValue(0)
    end
    if self.alpha ~= alpha then
        self.alpha = alpha
        self.display:SetAlpha(alpha)
    end
    if iconDesat then
        if not self.iconDesat then
            self.iconDesat = true
            self.icon:SetDesaturated(true)
        end
    else
        if self.iconDesat then
            self.iconDesat = false
            self.icon:SetDesaturated(false)
        end
    end
end

function ERAHUDDOTBar:endAnimate(frame)
    if self.definition.owner.hud.topdown then
        self.display:SetPoint("TOPRIGHT", frame, "RIGHT", 0, self.y)
    else
        self.display:SetPoint("BOTTOMRIGHT", frame, "RIGHT", 0, self.y)
    end
end

---@param txt string|nil
function ERAHUDDOTBar:SetText(txt)
    if txt ~= self.textValue then
        self.textValue = txt
        self.text:SetText(txt)
    end
end

--#endregion
-----------------

----------------------
--#region INSTANCE ---

---@class (exact) ERAHUDDOTInstance
---@field private __index unknown
---@field def ERAHUDDOTDefinition
---@field bar ERAHUDDOTBar
---@field duration number
---@field enemy ERAHUDDOTEnemy|nil
---@field couldRefresh boolean
ERAHUDDOTInstance = {}
ERAHUDDOTInstance.__index = ERAHUDDOTInstance

---@param def ERAHUDDOTDefinition
---@param frame Frame
---@param r number
---@param g number
---@param b number
---@param iconID integer
---@return ERAHUDDOTInstance
function ERAHUDDOTInstance:create(def, frame, r, g, b, iconID)
    local inst = {}
    setmetatable(inst, ERAHUDDOTInstance)
    ---@cast inst ERAHUDDOTInstance
    inst.def = def
    inst.bar = ERAHUDDOTBar:create(def, frame, r, g, b, iconID, ERAHUDDOT_SecondaryBarSize, 0.7)
    inst.duration = 0
    return inst
end

function ERAHUDDOTInstance:prepareUpdateData()
    self.duration = 0
    self.enemy = nil
end

---@param duration number
---@param enemy ERAHUDDOTEnemy
function ERAHUDDOTInstance:assign(duration, enemy)
    self.duration = duration
    self.enemy = enemy
end

function ERAHUDDOTInstance:computeUpdateData()
    if self.duration > 0 then
        self.couldRefresh = self.duration - self.def.castTime < self.def.refreshDuration
    else
        self.couldRefresh = false
    end
end

---@param y number
---@param frame Frame
---@return number
function ERAHUDDOTInstance:draw(y, frame)
    y = y + ERAHUD_TimerBarSpacing
    local alpha, desat
    if self.couldRefresh then
        alpha = ERAHUDDOT_alpha_REFRESH_OTHER
        desat = false
    else
        alpha = ERAHUDDOT_alpha_LONG_OTHER
        desat = true
    end
    self.bar:SetText(self.enemy.name)
    self.bar:draw(y, frame, self.duration, alpha, desat)
    return y + ERAHUDDOT_SecondaryBarSize
end
function ERAHUDDOTInstance:hide()
    self.bar:hide()
end

---@param i1 ERAHUDDOTInstance
---@param i2 ERAHUDDOTInstance
---@return boolean
function ERAHUDDOTInstance_sortDurations(i1, i2)
    return i1.duration < i2.duration
end

--#endregion
----------------------

--------------------
--#region TARGET ---

---@class (exact) ERAHUDDOTEnemy
---@field private __index unknown
---@field owner ERAHUDDOT
---@field plateID string
---@field guid string
---@field name string
ERAHUDDOTEnemy = {}
ERAHUDDOTEnemy.__index = ERAHUDDOTEnemy

---@param owner ERAHUDDOT
---@param guid string
---@param plateID string
---@return ERAHUDDOTEnemy
function ERAHUDDOTEnemy:create(owner, guid, plateID)
    local t = {}
    setmetatable(t, ERAHUDDOTEnemy)
    ---@cast t ERAHUDDOTEnemy
    t.guid = guid
    t.plateID = plateID
    t.owner = owner
    t.name = UnitName(plateID)
    return t
end

--#endregion
--------------------

ERAHUD_TimerWidth = 400
ERAHUD_TimerGCDCount = 5
ERAHUD_TimerBarDefaultSize = 22
ERAHUD_TimerBarSpacing = 4
ERAHUD_TimerIconSize = 22
ERAHUD_RotationIconSize = 44
ERAHUD_RotationIconSpacing = 4
ERAHUD_UtilityIconSize = 55

---@class (exact) ERAHUDHealth
---@field currentHealth number
---@field maxHealth number
---@field absorb number
---@field healAbsorb number
---@field bar ERAHUDStatusBar

---@class (exact) ERAHUDPower
---@field currentPower number
---@field maxPower number
---@field hideFullOutOfCombat boolean
---@field bar ERAHUDStatusBar

---@class (exact) ERAHUD
---@field private __index unknown
---@field private isHealer boolean
---@field topdown boolean
---@field barsWidth number
---@field private statusBaseX number
---@field private statusBaseY number
---@field private statusMaxY number
---@field healthHeight number
---@field petHeight number
---@field powerHeight number
---@field private statusSpacing number
---@field health ERAHUDHealth
---@field petHealth ERAHUDHealth
---@field private petHealthTalent ERALIBTalent
---@field private powerType integer
---@field power ERAHUDPower
---@field timerDuration number
---@field remGCD number
---@field totGCD number
---@field remCast number
---@field private totCast number
---@field occupied number
---@field hasteMultiplier number
---@field targetDispellableMagic boolean
---@field targetDispellableEnrage boolean
---@field targetCast number
---@field private channelingSpellID integer|nil
---@field private watchTargetDispellable boolean
---@field private baseGCD number
---@field private minGCD number
---@field private nested ERAHUDNestedModule[]
---@field private activeNested ERAHUDNestedModule[]
---@field private timers ERATimer[]
---@field private activeTimers ERATimer[]
---@field private buffs ERAAura[]
---@field private activeBuffs table<number, ERAAura>
---@field private hasBuffsAnyCaster boolean
---@field private debuffs ERAAura[]
---@field private activeDebuffs table<number, ERAAura>
---@field private updateData fun(this:ERAHUD, t:number, combat:boolean)
---@field private resetEmpower fun(this:ERAHUD)
---@field private updateHealthData fun(this:ERAHUD, h:ERAHUDHealth, unit:string)
---@field private EnterCombat fun(this:ERAHUD)
---@field private ExitCombat fun(this:ERAHUD)
---@field private ResetToIdle fun(this:ERAHUD)
---@field private CheckTalents fun(this:ERAHUD)
---@field private CLEU fun(this:ERAHUD, t:number)
---@field private updateHealthStatus fun(this:ERAHUD, h:ERAHUDHealth, t:number)
---@field private updateHealthStatusIdle fun(this:ERAHUD, h:ERAHUDHealth, t:number)
---@field private updatePowerStatus fun(this:ERAHUD, t:number)
---@field private empowerLevel integer
---@field private lastEmpowerStageTotal number
---@field private lastEmpowerEndAfterHold number
---@field private lastEmpowerStartMS number
---@field private lastEmpowerEndMS number
---@field private lastEmpowerID number
---@field private mainFrame Frame
---@field private timerFrame Frame
---@field private timerFrameOverlay Frame
---@field private timerMaxY number
---@field private channelInfo table<integer, number>
---@field private markers ERAHUDTimerMarker[]
---@field private activeMarkers ERAHUDTimerMarker[]
---@field private bars ERAHUDBar[]
---@field private activeBars ERAHUDBar[]
---@field private visibleBars ERAHUDBar[]
---@field private targetCastBar ERAHUDTargetCastBar
---@field private loc ERAHUDLOCBar[]
---@field private empowerLevels ERAHUDEmpowerLevel[]
---@field private channelTicksCount integer
---@field private channelTicks Line[]
---@field private gcdTicks Line[]
---@field private gcdBar Texture
---@field private gcdVisible boolean
---@field private castBar Texture
---@field private castBackground Texture
---@field private castVisible boolean
---@field private events unknown
---@field private rotation ERAHUDRotationIcon[]
---@field private activeRotation ERAHUDRotationIcon[]
---@field private timerItems ERAHUDTimerItem[]
---@field private activeTimerItems ERAHUDTimerItem[]
---@field private displayedTimerItems ERAHUDTimerItem[]
---@field private availablePriority ERAHUDTimerItem[]
---@field IsCombatPowerVisibleOverride fun(this:ERAHUD, t:number): boolean
---@field calcTimerPixel fun(this:ERAHUD, t:number): number

---@class ERAHUD : ERACombatModule
ERAHUD = {}
ERAHUD.__index = ERAHUD
setmetatable(ERAHUD, { __index = ERACombatModule })

--#region CSTR

---@param cFrame ERACombatFrame
---@param baseGCD number
---@param requireCLEU boolean
---@param powerType integer
---@param rPower number
---@param gPower number
---@param bPower number
---@param showPet ERALIBTalent|boolean
---@param spec integer
---@return ERAHUD
function ERAHUD:Create(cFrame, baseGCD, requireCLEU, isHealer, powerType, rPower, gPower, bPower, showPet, spec)
    local hud = {}
    setmetatable(hud, ERAHUD)
    ---@cast hud ERAHUD
    hud:construct(cFrame, 0.2, 0.02, requireCLEU, spec)

    if isHealer then
        hud.isHealer = true
        hud.topdown = true
    else
        hud.isHealer = false
        hud.topdown = false
    end

    -- data
    hud.timerDuration = baseGCD * ERAHUD_TimerGCDCount
    hud.remGCD = 0
    hud.totGCD = baseGCD
    hud.baseGCD = baseGCD
    if baseGCD > 1 then
        hud.minGCD = 0.75
    else
        baseGCD = 1
    end
    hud.remCast = 0
    hud.totCast = 1
    hud.occupied = 0

    hud.hasteMultiplier = 1
    hud.channelingSpellID = nil

    hud.targetCast = 0
    hud.targetDispellableEnrage = false
    hud.targetDispellableMagic = false
    hud.watchTargetDispellable = false

    hud.empowerLevel = 0
    hud.lastEmpowerStageTotal = 0
    hud.lastEmpowerEndAfterHold = 0
    hud.lastEmpowerStartMS = 0
    hud.lastEmpowerEndMS = 0
    hud.lastEmpowerID = 0
    hud.empowerLevels = {}

    -- data content
    hud.nested = {}
    hud.activeNested = {}
    hud.timers = {}
    hud.activeTimers = {}
    hud.buffs = {}
    hud.activeBuffs = {}
    hud.hasBuffsAnyCaster = false
    hud.debuffs = {}
    hud.activeDebuffs = {}

    -- display

    local mainFrame = CreateFrame("Frame", nil, UIParent, "ERAHUDFrame")
    ---@cast mainFrame Frame
    hud.mainFrame = mainFrame
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", -111, 0)

    hud.timerMaxY = 0
    local timerFrame = CreateFrame("Frame", nil, mainFrame, "ERAHUDFrame")
    ---@cast timerFrame Frame
    hud.timerFrame = timerFrame
    timerFrame:SetPoint("RIGHT", mainFrame, "CENTER", 0, 0)

    hud.castBackground = timerFrame:CreateTexture(nil, "BACKGROUND")
    hud.castBackground:SetColorTexture(0.0, 0.0, 0.0, 0.66)
    hud.castBar = timerFrame:CreateTexture(nil, "BORDER")
    hud.castBar:SetColorTexture(0.2, 0.8, 0.6, 0.77)
    if hud.topdown then
        hud.castBackground:SetPoint("TOPRIGHT", timerFrame, "RIGHT", 0, ERAHUD_TimerIconSize)
        hud.castBar:SetPoint("TOPRIGHT", timerFrame, "RIGHT", 0, ERAHUD_TimerIconSize)
    else
        hud.castBackground:SetPoint("BOTTOMRIGHT", timerFrame, "RIGHT", 0, -ERAHUD_TimerIconSize)
        hud.castBar:SetPoint("BOTTOMRIGHT", timerFrame, "RIGHT", 0, -ERAHUD_TimerIconSize)
    end
    hud.castBackground:Hide()
    hud.castBar:Hide()
    hud.castVisible = false

    hud.channelInfo = {}
    hud.channelTicks = {}
    hud.channelTicksCount = 0

    -- content
    hud.rotation = {}
    hud.activeRotation = {}
    hud.markers = {}
    hud.activeMarkers = {}
    hud.bars = {}
    hud.activeBars = {}
    hud.visibleBars = {}
    hud.timerItems = {}
    hud.activeTimerItems = {}
    hud.displayedTimerItems = {}
    hud.availablePriority = {}

    hud.targetCastBar = ERAHUDTargetCastBar:create(hud)

    -- status

    hud.powerType = powerType
    hud.barsWidth = 144
    if hud.isHealer then
        hud.statusBaseX = 0
        hud.statusBaseY = 0
    else
        hud.statusBaseX = -ERAHUD_TimerIconSize - hud.barsWidth / 2
        hud.statusBaseY = -1.5 * ERAHUD_TimerIconSize
    end
    hud.healthHeight = 22
    hud.petHeight = 11
    hud.powerHeight = 16
    hud.statusSpacing = 2
    local statusY = hud.statusBaseY
    hud.health = {
        maxHealth = 1,
        currentHealth = 0,
        absorb = 0,
        healAbsorb = 0,
        bar = ERAHUDStatusBar:create(mainFrame, hud.statusBaseX, statusY, hud.barsWidth, hud.healthHeight, 0.0, 1.0, 0.0)
    }
    statusY = statusY - hud.healthHeight - hud.statusSpacing
    if showPet == true then
        hud.petHealthTalent = ERALIBTalentTrue
    elseif showPet == false then
        hud.petHealthTalent = ERALIBTalentFalse
    else
        ---@cast showPet ERALIBTalent
        hud.petHealthTalent = showPet
    end
    hud.petHealth = {
        maxHealth = 1,
        currentHealth = 0,
        absorb = 0,
        healAbsorb = 0,
        bar = ERAHUDStatusBar:create(mainFrame, hud.statusBaseX, 0, hud.barsWidth, hud.petHeight, 0.0, 1.0, 0.0)
    }
    if powerType >= 0 then
        hud.power = {
            currentPower = 0,
            maxPower = 1,
            hideFullOutOfCombat = false,
            bar = ERAHUDStatusBar:create(mainFrame, hud.statusBaseX, statusY, hud.barsWidth, hud.powerHeight, rPower, gPower, bPower)
        }
        statusY = statusY - hud.powerHeight - hud.statusSpacing
    end
    hud.statusMaxY = statusY

    -- events

    hud.events = {}

    function hud.events:UNIT_SPELLCAST_EMPOWER_STOP(unit)
        if (unit == "player") then
            self:resetEmpower()
        end
    end
    function hud.events:UNIT_SPELLCAST_EMPOWER_UPDATE(unit)
        if (unit == "player") then
            self:resetEmpower()
        end
    end
    function hud.events:UNIT_SPELLCAST_STOP(unit)
        if (unit == "player") then
            self:resetEmpower()
        end
    end
    function hud.events:UNIT_SPELLCAST_SUCCEEDED(unit)
        if (unit == "player") then
            self:resetEmpower()
        end
    end
    local evts = hud.events
    mainFrame:SetScript(
        "OnEvent",
        function(self, event, ...)
            evts[event](hud, ...)
        end
    )

    return hud
end

function ERAHUD:Pack()
    self.timerFrameOverlay = CreateFrame("Frame", nil, self.timerFrame)
    self.timerFrameOverlay:SetFrameLevel(3)
    self.timerFrameOverlay:SetPoint("TOPLEFT", self.timerFrame, "TOPLEFT", 0, 0)
    self.timerFrameOverlay:SetPoint("BOTTOMRIGHT", self.timerFrame, "BOTTOMRIGHT", 0, 0)

    for _, m in ipairs(self.markers) do
        m:createDisplay(self.timerFrameOverlay)
    end

    self.gcdTicks = {}
    for i = 0, ERACombat_TimerGCDCount do
        local line = self.timerFrameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDVerticalTick")
        local x = 0 - i * (ERACombat_TimerWidth / ERACombat_TimerGCDCount)
        line:SetStartPoint("RIGHT", self.timerFrameOverlay, x, 0)
        line:SetEndPoint("RIGHT", self.timerFrameOverlay, x, 0)
        table.insert(self.gcdTicks, line)
    end

    self.targetCastBar = ERAHUDTargetCastBar:create(self)

    for lvl = 0, 4 do
        local x = ERAHUDEmpowerLevel:create(self, self.timerFrameOverlay, lvl)
        table.insert(self.empowerLevels, x)
    end

    self.gcdBar = self.timerFrameOverlay:CreateTexture(nil, "BACKGROUND")
    self.gcdBar:SetColorTexture(1.0, 1.0, 1.0, 0.8)
    if (self.topdown) then
        self.gcdBar:SetPoint("TOPRIGHT", self.timerFrameOverlay, "RIGHT", 0, 0)
    else
        self.gcdBar:SetPoint("BOTTOMRIGHT", self.timerFrameOverlay, "RIGHT", 0, 0)
    end
    self.gcdBar:Hide()
    self.gcdVisible = false

    local paradoxTimer = self:AddTrackedBuffAnyCaster(406732)
    self:AddBarWithID(paradoxTimer, nil, 1, 0.9, 0.7)

    for _, ti in ipairs(self.timerItems) do
        ti:constructOverlay(self.timerFrameOverlay)
    end

    self.timerFrame:Hide()
end

--#endregion

--#region MECHANICS

function ERAHUD:EnterCombat()
    self.timerFrame:Show()
    self.health.bar:show()
    if self.petHealthTalent:PlayerHasTalent() then
        self.petHealth.bar:show()
    end
    if self.power then
        self.power.bar:show()
    end
end

function ERAHUD:ExitCombat()
    self.timerFrame:Hide()
end

function ERAHUD:ResetToIdle()
    for k, v in pairs(self.events) do
        self.mainFrame:RegisterEvent(k)
    end
    self.mainFrame:Show()
    self:OnResetToIdleOverride()
end
function ERAHUD:OnResetToIdleOverride()
end

function ERAHUD:SpecInactive(wasActive)
    if (wasActive) then
        self.mainFrame:Hide()
        self.mainFrame:UnregisterAllEvents()
    end
end

function ERAHUD:CheckTalents()
    table.wipe(self.activeTimers)
    for _, t in ipairs(self.timers) do
        if (t:checkTalent()) then
            table.insert(self.activeTimers, t)
        end
    end
    table.wipe(self.activeBuffs)
    for _, a in ipairs(self.buffs) do
        if a.talentActive then
            self.activeBuffs[a.spellID] = a
        end
    end
    table.wipe(self.activeDebuffs)
    for _, a in ipairs(self.debuffs) do
        if a.talentActive then
            self.activeDebuffs[a.spellID] = a
        end
    end
    table.wipe(self.activeMarkers)
    for _, m in ipairs(self.markers) do
        if m:checkTalentsOrHide() then
            table.insert(self.activeMarkers, m)
        end
    end
    table.wipe(self.activeBars)
    for _, b in ipairs(self.bars) do
        if b:checkTalentsOrHide() then
            table.insert(self.activeBars, b)
        end
    end
    table.wipe(self.activeRotation)
    for _, r in ipairs(self.rotation) do
        if r:checkTalentOrHide() then
            table.insert(self.activeRotation, r)
        end
    end
    table.wipe(self.activeTimerItems)
    for _, ti in ipairs(self.timerItems) do
        if ti:checkTalentOrHide() then
            table.insert(self.activeTimerItems, ti)
        end
    end

    self.health.bar:checkTalents()
    self.health.bar:place(self.statusBaseX, self.statusBaseY, self.healthHeight, self.mainFrame)
    local statusY = self.statusBaseY - self.healthHeight - self.statusSpacing
    if self.petHealthTalent:PlayerHasTalent() then
        self.petHealth.bar:place(self.statusBaseX, statusY, self.petHeight, self.mainFrame)
        self.petHealth.bar:checkTalents()
        statusY = statusY - self.petHeight - self.statusSpacing
        if self.power then
            self.power.bar:checkTalents()
            self.power.bar:place(self.statusBaseX, statusY, self.powerHeight, self.mainFrame)
            statusY = statusY - self.powerHeight - self.statusSpacing
        end
    else
        self.petHealth.bar:hide()
        if self.power then
            self.power.bar:checkTalents()
            self.power.bar:place(self.statusBaseX, statusY, self.powerHeight, self.mainFrame)
            statusY = statusY - self.powerHeight - self.statusSpacing
        end
    end
    self.statusMaxY = statusY

    table.wipe(self.activeNested)
    for _, n in ipairs(self.nested) do
        if n.talent and not n.talent:PlayerHasTalent() then
            n:hide()
        else
            n:show()
            table.insert(self.activeNested, n)
        end
    end

    if self.isHealer then
        --#region HEALER ICONS



        --#endregion
    else
        --#region NON-HEALER ICONS

        local iconSpace = ERAHUD_RotationIconSize + ERAHUD_RotationIconSpacing
        local maxColumns = math.ceil(self.barsWidth / iconSpace)
        local xRotation = -ERAHUD_TimerIconSize - ERAHUD_RotationIconSize / 2
        local yRotation = statusY - ERAHUD_RotationIconSize / 2
        local largeRow = true
        local countInRow = 0
        local maxSpecial = math.ceil(1.5 * self.barsWidth / iconSpace)
        local xSpecial = 1.5 * ERAHUD_TimerIconSize + ERAHUD_RotationIconSize / 2
        local ySpecial = 0
        local highColumn = true
        local countInColumn = 0
        for _, i in ipairs(self.activeRotation) do
            if i.specialPosition then
                i.icon:Draw(xSpecial, ySpecial, false)
                countInColumn = countInColumn + 1
                local newColumn
                if highColumn then
                    if countInColumn >= maxSpecial then
                        highColumn = false
                        ySpecial = ERAHUD_RotationIconSize / 2
                        newColumn = true
                    else
                        newColumn = false
                    end
                else
                    if countInColumn + 1 >= maxSpecial then
                        highColumn = true
                        ySpecial = 0
                        newColumn = true
                    else
                        newColumn = false
                    end
                end
                if newColumn then
                    countInColumn = 0
                    xSpecial = xSpecial + iconSpace * 0.86 -- sqrt(0.75)
                else
                    ySpecial = ySpecial + iconSpace
                end
            else
                i.icon:Draw(xRotation, yRotation, false)
                countInRow = countInRow + 1
                local newRow
                if largeRow then
                    if countInRow >= maxColumns then
                        largeRow = false
                        xRotation = -ERAHUD_TimerIconSize - ERAHUD_RotationIconSize
                        newRow = true
                    else
                        newRow = false
                    end
                else
                    if countInRow + 1 >= maxColumns then
                        largeRow = true
                        xRotation = -ERAHUD_TimerIconSize - ERAHUD_RotationIconSize / 2
                        newRow = true
                    else
                        newRow = false
                    end
                end
                if newRow then
                    countInRow = 0
                    yRotation = yRotation + iconSpace * 0.86 -- sqrt(0.75)
                else
                    xRotation = xRotation - iconSpace
                end
            end
        end

        --#endregion
    end
end

---@param t number
function ERAHUD:CLEU(t)
    for _, n in ipairs(self.activeNested) do
        n:CLEU(t)
    end
    self:AdditionalCLEU(t)
end
function ERAHUD:AdditionalCLEU(t)
end

--#endregion

--#region UPDATE

---@param t number
function ERAHUD:UpdateIdle(t)
    self:updateData(t, false)

    self:updateHealthStatusIdle(self.health, t)
    if self.petHealthTalent:PlayerHasTalent() then
        self:updateHealthStatusIdle(self.petHealth, t)
    end
    if self.power then
        if
            (self.power.currentPower >= self.power.maxPower and self.power.hideFullOutOfCombat)
            or
            (self.power.currentPower == 0 and not self.power.hideFullOutOfCombat)
        then
            self.power.bar:hide()
        else
            self:updatePowerStatus(t)
            self.power.bar:show()
        end
    end

    --#region ROTATION

    for _, r in ipairs(self.activeRotation) do
        r:update(false, t)
    end

    --#endregion
end

---@param t number
function ERAHUD:UpdateCombat(t)
    self:updateData(t, true)

    --#region LOC

    local locCount = C_LossOfControl.GetActiveLossOfControlDataCount()
    for i = 1, locCount do
        ---@type ERAHUDLOCBar
        local locBar
        if (i > #(self.loc)) then
            locBar = ERAHUDLOCBar:create(self)
            --table.insert(self.bars, locBar) -- déjà fait dans le cstr
            table.insert(self.activeBars, locBar)
            table.insert(self.loc, locBar)
        else
            locBar = self.loc[i]
        end
        local locData = C_LossOfControl.GetActiveLossOfControlData(i)
        local remDurLoc
        local iconTexture
        local typeDescription
        if (locData) then
            local timeRemaining = locData.timeRemaining
            if timeRemaining and timeRemaining > 0 then
                remDurLoc = timeRemaining
                typeDescription = locData.locType
                if (typeDescription == "SCHOOL_INTERRUPT") then
                    local school = locData.lockoutSchool
                    if (school and school ~= 0) then
                        typeDescription = "ø " .. C_Spell.GetSchoolString(school)
                    else
                        typeDescription = "INTERRUPT"
                    end
                elseif (typeDescription == "STUN_MECHANIC") then
                    typeDescription = "STUN"
                elseif (typeDescription == "FEAR_MECHANIC") then
                    typeDescription = "FEAR"
                end
                iconTexture = locData.iconTexture
            else
                remDurLoc = 1024
                iconTexture = nil
                typeDescription = nil
            end
        else
            remDurLoc = 1024
            iconTexture = nil
            typeDescription = nil
        end
        locBar:found(typeDescription, remDurLoc, iconTexture)
    end

    --endregion

    --#region BARS

    table.wipe(self.visibleBars)
    for _, b in ipairs(self.activeBars) do
        if b:computeDurationAndHideIf0_return_visible(t) then
            table.insert(self.visibleBars, b)
        end
    end
    -- la plupart du temps les barres sont déjà triées ; vérifions
    local alreadySorted = true
    local prvBar = nil
    for _, b in ipairs(self.visibleBars) do
        if (prvBar and b.remDuration < prvBar.remDuration) then
            alreadySorted = false
            break
        else
            prvBar = b
        end
    end
    if (not alreadySorted) then
        table.sort(self.visibleBars, ERAHUDBar_compare)
    end

    local barsY = ERAHUD_TimerBarSpacing
    for _, b in ipairs(self.visibleBars) do
        local height = b:draw(barsY)
        if self.topdown then
            barsY = barsY - height - ERAHUD_TimerBarSpacing
        else
            barsY = barsY + height + ERAHUD_TimerBarSpacing
        end
    end

    --#endregion

    --#region NESTED

    local nestedHeight = 0
    local nestedY = barsY
    for _, n in ipairs(self.activeNested) do
        local nh = n:updateDisplay_returnHeight(t, nestedY)
        barsY = barsY + nh
        if n.includeInTimer then
            nestedHeight = nestedHeight + nh
        end
    end

    --#endregion

    --#region TIMER OVERLAY

    local timerMaxY = barsY
    if self.topdown then
        timerMaxY = barsY - nestedHeight
        if timerMaxY > -ERAHUD_TimerBarDefaultSize then
            timerMaxY = -ERAHUD_TimerBarDefaultSize - ERAHUD_TimerBarSpacing
        end
    else
        timerMaxY = barsY + nestedHeight
        if timerMaxY < ERAHUD_TimerBarDefaultSize then
            timerMaxY = ERAHUD_TimerBarDefaultSize + ERAHUD_TimerBarSpacing
        end
    end

    if self.timerMaxY ~= timerMaxY then
        self.timerMaxY = timerMaxY
        for i, g in ipairs(self.gcdTicks) do
            local x = 0 - (i - 1) * (ERACombat_TimerWidth / ERACombat_TimerGCDCount)
            g:SetEndPoint("RIGHT", self.timerFrameOverlay, x, timerMaxY)
        end
    end

    if self.remGCD > 0 then
        if not self.gcdVisible then
            self.gcdVisible = true
            self.gcdBar:Show()
        end
        if (self.topdown) then
            self.gcdBar:SetPoint("BOTTOMLEFT", self.timerFrameOverlay, "RIGHT", self:calcTimerPixel(self.remGCD), timerMaxY)
        else
            self.gcdBar:SetPoint("TOPLEFT", self.timerFrameOverlay, "RIGHT", self:calcTimerPixel(self.remGCD), timerMaxY)
        end
    else
        if self.gcdVisible then
            self.gcdVisible = false
            self.gcdBar:Hide()
        end
    end

    if self.remCast > 0 then
        if not self.castVisible then
            self.castVisible = true
            self.castBar:Show()
            self.castBackground:Show()
        end
        if self.topdown then
            local y = timerMaxY - ERAHUD_TimerBarSpacing
            self.castBar:SetPoint("BOTTOMLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.remCast), y)
            self.castBackground:SetPoint("BOTTOMLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.totCast), y)
        else
            local y = timerMaxY + ERAHUD_TimerBarSpacing
            self.castBar:SetPoint("TOPLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.remCast), y)
            self.castBackground:SetPoint("TOPLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.totCast), y)
        end
    else
        if self.castVisible then
            self.castVisible = false
            self.castBar:Hide()
            self.castBackground:Hide()
        end
    end

    local channelTickVisible = false
    if self.channelingSpellID then
        local tickInfo = self.channelInfo[self.channelingSpellID]
        if (tickInfo and tickInfo > 0) then
            tickInfo = tickInfo * self.hasteMultiplier
            local t_channelTick = t + self.remCast
            local i = 0
            while (t_channelTick > t) do
                i = i + 1
                local tickLine
                if (i > #(self.channelTicks)) then
                    tickLine = self.timerFrameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDChannelTick")
                    table.insert(self.channelTicks, tickLine)
                else
                    tickLine = self.channelTicks[i]
                end
                local x = self:calcTimerPixel(t_channelTick - t)
                tickLine:SetStartPoint("RIGHT", self.timerFrameOverlay, x, 0)
                tickLine:SetEndPoint("CENTER", self.timerFrameOverlay, x, timerMaxY)
                t_channelTick = t_channelTick - tickInfo
            end
            for j = self.channelTicksCount + 1, i do
                self.channelTicks[j]:Show()
            end
            for j = i + 1, self.channelTicksCount do
                self.channelTicks[j]:Hide()
            end
            self.channelTicksCount = i
            channelTickVisible = true
        end
    end
    if not channelTickVisible then
        for i = 1, self.channelTicksCount do
            self.channelTicks[i]:Hide()
        end
        self.channelTicksCount = 0
    end

    if (self.empowerLevel >= 0) then
        for _, lvl in ipairs(self.empowerLevels) do
            lvl:drawOrHideIfUnused(self.timerFrameOverlay, timerMaxY)
        end
    else
        for _, lvl in ipairs(self.empowerLevels) do
            lvl:hide()
        end
    end

    for _, m in ipairs(self.activeMarkers) do
        m:update(timerMaxY, t, self.timerFrameOverlay)
    end

    --#endregion

    --#region STATUS

    self:updateHealthStatus(self.health, t)
    if self.petHealthTalent:PlayerHasTalent() then
        self:updateHealthStatus(self.petHealth, t)
    end
    if self.power then
        if self:IsCombatPowerVisibleOverride(t) then
            self.power.bar:show()
            self:updatePowerStatus(t)
        else
            self.power.bar:hide()
        end
    end

    --#endregion

    --#region ROTATION

    for _, r in ipairs(self.activeRotation) do
        r:update(true, t)
    end

    table.wipe(self.availablePriority)
    table.wipe(self.displayedTimerItems)
    for _, ti in ipairs(self.activeTimerItems) do
        ti:update(t)
        if ti.priority > 0 then
            table.insert(self.availablePriority, ti)
        end
    end

    -- activeTimerItems est probablement déjà trié ; vérifions
    alreadySorted = true
    ---@type ERAHUDTimerItem|nil
    local prvTI = nil
    for _, ti in ipairs(self.activeTimerItems) do
        if (prvTI and ti.pixel < prvTI.pixel) then
            alreadySorted = false
            break
        else
            prvTI = ti
        end
    end
    if (not alreadySorted) then
        table.sort(self.activeTimerItems, ERAHUDTimerItem_comparePixel)
    end
    for _, ti in ipairs(self.activeTimerItems) do
        if ti.pixel < 0 then
            table.insert(self.displayedTimerItems, ti)
        end
    end

    prvTI = nil
    local prvTI_offset = false
    for _, ti in ipairs(self.displayedTimerItems) do
        local y
        if (not prvTI_offset) and (prvTI and ti.pixel - prvTI.pixel < ERAHUD_TimerIconSize) then
            if self.topdown then
                y = 2 * ERAHUD_TimerIconSize
            else
                y = -2 * ERAHUD_TimerIconSize
            end
            prvTI_offset = true
        else
            if self.topdown then
                y = ERAHUD_TimerIconSize
            else
                y = -ERAHUD_TimerIconSize
            end
            prvTI_offset = false
        end
        ti:drawOnTimer(y, timerMaxY, self.timerFrameOverlay)
        prvTI = ti
    end

    local yPrio
    if self.topdown then
        yPrio = -2 * ERAHUD_TimerIconSize
    else
        yPrio = 2 * ERAHUD_TimerIconSize
    end
    for _, ti in ipairs(self.availablePriority) do
        ti:drawPriority(yPrio)
        if self.topdown then
            yPrio = yPrio - 2 * ERAHUD_TimerIconSize
        else
            yPrio = yPrio + 2 * ERAHUD_TimerIconSize
        end
    end

    --#endregion
end

---@param t number
---@return boolean
function ERAHUD:IsCombatPowerVisibleOverride(t)
    return true
end

---@param h ERAHUDHealth
---@param t number
function ERAHUD:updateHealthStatusIdle(h, t)
    if h.currentHealth >= h.maxHealth then
        h.bar:hide()
    else
        self:updateHealthStatus(h, t)
        h.bar:show()
    end
end
---@param h ERAHUDHealth
---@param t number
function ERAHUD:updateHealthStatus(h, t)
    h.bar:SetAllExceptForecast(h.maxHealth, h.currentHealth, h.healAbsorb, h.absorb)
    h.bar:updateMarkings(t)
end
---@param t number
function ERAHUD:updatePowerStatus(t)
    self.power.bar:SetValueAndMax(self.power.currentPower, self.power.maxPower)
    self.power.bar:updateMarkings(t)
end

--#endregion

------------
--- DATA ---
------------

--#region DATA

---@param t ERATimer
function ERAHUD:addTimer(t)
    table.insert(self.timers, t)
end

---@param a ERAAura
function ERAHUD:addBuff(a)
    table.insert(self.buffs, a)
end
---@param a ERAAura
function ERAHUD:addDebuff(a)
    table.insert(self.debuffs, a)
end

---@param t number
---@param combat boolean
function ERAHUD:updateData(t, combat)
    self.hasteMultiplier = 1 / (1 + GetHaste() / 100)
    local cdInfo = C_Spell.GetSpellCooldown(61304)
    self.totGCD = math.max(self.minGCD, self.baseGCD * self.hasteMultiplier)
    if (cdInfo and cdInfo.startTime and cdInfo.startTime > 0) then
        self.remGCD = cdInfo.duration - (t - cdInfo.startTime)
    else
        self.remGCD = 0
    end
    self.timerDuration = self.totGCD * ERAHUD_TimerGCDCount

    --#region STATUS

    self:updateHealthData(self.health, "player")
    if self.petHealthTalent:PlayerHasTalent() then
        if UnitExists("pet") then
            self:updateHealthData(self.petHealth, "pet")
        else
            self.petHealth.absorb = 0
            self.petHealth.healAbsorb = 0
            self.petHealth.currentHealth = 0
            self.petHealth.maxHealth = 1
        end
    end
    if self.power then
        self.power.currentPower = UnitPower("player", self.powerType)
        self.power.maxPower = UnitPowerMax("player", self.powerType)
    end

    --#endregion

    --#region BUFF / DEBUFF

    for i = 1, 40 do
        local auraInfo = C_UnitAuras.GetDebuffDataByIndex("target", i, "PLAYER")
        if (auraInfo) then
            local a = self.activeDebuffs[auraInfo.spellId]
            if (a ~= nil) then
                a:auraFound(t, auraInfo)
            end
        else
            break
        end
    end
    if self.hasBuffsAnyCaster then
        for i = 1, 40 do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i)
            if (auraInfo) then
                local a = self.activeBuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo)
                end
            else
                break
            end
        end
    else
        for i = 1, 40 do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i, "PLAYER")
            if (auraInfo) then
                local a = self.activeBuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo)
                end
            else
                break
            end
        end
    end

    --endregion

    --#region TARGET

    if (self.watchTargetDispellable) then
        self.targetDispellableMagic = false
        self.targetDispellableEnrage = false
        for i = 1, 40 do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("target", i)
            if (auraInfo) then
                if (auraInfo.isStealable) then
                    self.targetDispellableMagic = true
                end
                if (auraInfo.dispelName == "Magic") then
                    self.targetDispellableMagic = true
                elseif (auraInfo.dispelName == "Enrage") then
                    self.targetDispellableEnrage = true
                end
            else
                break
            end
        end
    end

    self.targetCast = 0
    if (UnitIsEnemy("player", "target")) then
        local name, _, _, _, endTargetCastMS, _, _, notInterruptible = UnitCastingInfo("target")
        if (endTargetCastMS and endTargetCastMS > 0 and not notInterruptible) then
            self.targetCast = endTargetCastMS / 1000 - t
            if (self.targetCastBar) then
                self.targetCastBar:SetText(name)
            end
        else
            name, _, _, _, endTargetCastMS, _, notInterruptible = UnitChannelInfo("target")
            if (endTargetCastMS and endTargetCastMS > 0 and not notInterruptible) then
                self.targetCast = endTargetCastMS / 1000 - t
                if (self.targetCastBar) then
                    self.targetCastBar:SetText(name)
                end
            end
        end
    end

    --endregion

    --region CAST

    local _, _, _, startTimeMS, endCastMS = UnitCastingInfo("player")
    if endCastMS then
        self.remCast = (endCastMS / 1000) - t
        self.totCast = (endCastMS - startTimeMS) / 1000
        self.channelingSpellID = nil
        self:resetEmpower()
    else
        local _, _, _, startTimeMS, endCastMS, _, _, spellID, _, stageTotal = UnitChannelInfo("player")
        local recordEmpowerInfo
        if (stageTotal and stageTotal > 0) then
            recordEmpowerInfo = true
        else
            recordEmpowerInfo = false
            if (self.lastEmpowerEndAfterHold > t) then
                startTimeMS = self.lastEmpowerStartMS
                endCastMS = self.lastEmpowerEndMS
                spellID = self.lastEmpowerID
                stageTotal = self.lastEmpowerStageTotal
            end
        end
        if (endCastMS) then
            self.channelingSpellID = spellID
            if (stageTotal and stageTotal > 0) then
                local maxLevelHold = GetUnitEmpowerHoldAtMaxTime("player") / 1000
                local channelEnd = maxLevelHold + endCastMS / 1000
                self.remCast = channelEnd - t
                self.totCast = channelEnd - startTimeMS / 1000
                local acc = 0
                local alreadyCasted = self.totCast - self.remCast
                local empowerLevel = -1
                for s = 0, stageTotal do
                    local lvl
                    if (s + 1 > #(self.empowerLevels)) then
                        lvl = ERACombatTimersEmpowerLevel:Create(self, self.timerFrameOverlay, s)
                        table.insert(self.empowerLevels, lvl)
                    else
                        lvl = self.empowerLevels[s + 1]
                    end
                    local edur
                    if (s == stageTotal) then
                        edur = maxLevelHold
                    else
                        edur = GetUnitEmpowerStageDuration("player", s) / 1000
                    end
                    local nextAcc = acc + edur
                    if (empowerLevel >= 0) then
                        lvl:setFuture(acc - alreadyCasted, nextAcc - alreadyCasted)
                    else
                        if (nextAcc < alreadyCasted) then
                            lvl:setPast()
                        else
                            lvl:setCurrent(nextAcc - alreadyCasted)
                            empowerLevel = s
                        end
                    end
                    acc = nextAcc
                end
                self.empowerLevel = empowerLevel
                for s = stageTotal + 2, #self.empowerLevels do
                    self.empowerLevels[s]:setNotUsed()
                end
                if (recordEmpowerInfo) then
                    self.lastEmpowerStageTotal = stageTotal
                    self.lastEmpowerStartMS = startTimeMS
                    self.lastEmpowerEndMS = endCastMS
                    self.lastEmpowerEndAfterHold = channelEnd
                    self.lastEmpowerID = spellID
                end
            else
                self:resetEmpower()
                self.remCast = endCastMS / 1000 - t
                self.totCast = (endCastMS - startTimeMS) / 1000
            end
        else
            self:resetEmpower()
            self.remCast = 0
            self.totCast = 0
            self.channelingSpellID = nil
        end
    end

    --endregion

    self.occupied = math.max(self.remCast, self.remGCD)

    self:PreUpdateDataOverride(t, combat)

    for _, tim in ipairs(self.activeTimers) do
        tim:updateData(t)
    end

    for _, n in ipairs(self.activeNested) do
        n:updateData(t)
    end

    self:DataUpdatedOverride(t, combat)
end

---@param h ERAHUDHealth
---@param unit string
function ERAHUD:updateHealthData(h, unit)
    h.currentHealth = UnitHealth(unit)
    h.maxHealth = UnitHealthMax(unit)
    h.absorb = UnitGetTotalAbsorbs(unit)
    h.healAbsorb = UnitGetTotalHealAbsorbs(unit)
end

---@param t number
---@param inCombat boolean
function ERAHUD:PreUpdateDataOverride(t, inCombat)
end

---@param t number
---@param inCombat boolean
function ERAHUD:DataUpdatedOverride(t, inCombat)
end

function ERAHUD:resetEmpower()
    self.empowerLevel = 0
    self.lastEmpowerStageTotal = 0
    self.lastEmpowerEndAfterHold = 0
    self.lastEmpowerStartMS = 0
    self.lastEmpowerEndMS = 0
    self.lastEmpowerID = 0
end

--#endregion

---------------
--- DISPLAY ---
---------------

--#region DISPLAY

---@param b ERAHUDBar
---@return Frame
function ERAHUD:addBar(b)
    table.insert(self.bars, b)
    return self.timerFrame
end

---@param m ERAHUDTimerMarker
function ERAHUD:addMarker(m)
    table.insert(self.markers, m)
end

---@param t number
---@return number
function ERAHUD:calcTimerPixel(t)
    return -(t / self.totGCD) * (ERAHUD_TimerWidth / ERAHUD_TimerGCDCount)
end

---@param spellID integer
---@param tickTime number
function ERAHUD:AddChannelInfo(spellID, tickTime)
    self.channelInfo[spellID] = tickTime
end

---@param r ERAHUDRotationIcon
---@return Frame
function ERAHUD:addRotation(r)
    table.insert(self.rotation, r)
    return self.mainFrame
end

---@param i ERAHUDTimerItem
function ERAHUD:addTimerItem(i)
    table.insert(self.timerItems, i)
end

--#endregion

--------------
--- NESTED ---
--------------

--#region NESTED

---@param n ERAHUDNestedModule
function ERAHUD:addNested(n)
    table.insert(self.nested, n)
    return self.timerFrame
end

---@class (exact) ERAHUDNestedModule
---@field private __index unknown
---@field protected constructNested fun(this:ERAHUDNestedModule, hud:ERAHUD, includeInTimer:boolean, talent:ERALIBTalent|nil)
---@field hud ERAHUD
---@field hide fun(this:ERAHUDNestedModule)
---@field show fun(this:ERAHUDNestedModule)
---@field updateData fun(this:ERAHUDNestedModule, t:number)
---@field updateDisplay_returnHeight fun(this:ERAHUDNestedModule, t:number, baseY:number): number
---@field talent ERALIBTalent|nil
---@field includeInTimer boolean
---@field private timerFrame Frame
ERAHUDNestedModule = {}
ERAHUDNestedModule.__index = ERAHUDNestedModule

---@param hud ERAHUD
---@param includeInTimer boolean
---@param talent ERALIBTalent|nil
function ERAHUDNestedModule:constructNested(hud, includeInTimer, talent)
    self.hud = hud
    self.talent = talent
    self.timerFrame = hud:addNested(self)
    self.includeInTimer = includeInTimer
end

---@param t number
function ERAHUDNestedModule:CLEU(t)
end

--#endregion

---------------
--- CONTENT ---
---------------

--#region CONTENT

--#region DATA

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuff(spellID, talent, ...)
    return ERAAura:create(self, true, spellID, talent, ...)
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuffAnyCaster(spellID, talent, ...)
    local a = ERAAura:create(self, true, spellID, talent, ...)
    self.hasBuffsAnyCaster = true
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuff(spellID, talent, ...)
    return ERAAura:create(self, false, spellID, talent, ...)
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERACooldown
function ERAHUD:AddTrackedCooldown(spellID, talent, ...)
    return ERACooldown:create(self, spellID, talent, ...)
end

--#endregion

--#region DISPLAY

---@param timer ERATimerWithID
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDSpellIDBar
function ERAHUD:AddBarWithID(timer, iconID, r, g, b, talent)
    return ERAHUDSpellIDBar:create(timer, iconID, r, g, b, talent)
end

---@param data ERACooldownBase
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationCooldownIcon
function ERAHUD:AddRotationCooldown(data, talent)
    return ERAHUDRotationCooldownIcon:create(data, talent)
end

---@param data ERAAura
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationAuraIcon
function ERAHUD:AddRotationBuff(data, talent)
    return ERAHUDRotationAuraIcon:create(data, talent)
end

---@param data ERAAura
---@param maxStacks integer
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationStacksIcon
function ERAHUD:AddRotationStacks(data, maxStacks, talent)
    return ERAHUDRotationStacksIcon:create(data, maxStacks, talent)
end

---@param iconID integer
---@param talent ERALIBTalent|nil
---@return ERAHUDRawPriority
function ERAHUD:AddPriority(iconID, talent)
    return ERAHUDRawPriority:create(self, iconID, talent)
end

--#endregion

--#endregion

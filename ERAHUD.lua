--[[

TODO
- healer layout
- generic improvements
- reverse overlay for buffs

]]


ERAHUD_TimerWidth = 400
ERAHUD_TimerGCDCount = 5
ERAHUD_TimerBarDefaultSize = 22
ERAHUD_TimerBarSpacing = 4
ERAHUD_TimerIconSize = 22
ERAHUD_RotationIconSize = 42
ERAHUD_RotationIconSpacing = 2
ERAHUD_RotationSpecialX = ERAHUD_TimerIconSize + ERAHUD_RotationIconSize
ERAHUD_RotationSpecialY = 0
ERAHUD_RotationHealerY = -ERAHUD_RotationIconSize / 2
ERAHUD_RotationSpecialHealerX = 3 * ERAHUD_RotationIconSize
ERAHUD_RotationSpecialHealerY = 0
ERAHUD_UtilityIconSize = 50
ERAHUD_UtilityIconSpacing = 4
ERAHUD_UtilityGoupSpacing = 8
ERAHUD_UtilityGoupIconSize = 22
ERAHUD_UtilityGoupBorder = 2
ERAHUD_UtilityGoupPadding = 4
ERAHUD_UtilityMinBottomY = -202
ERAHUD_UtilityMinRightX = 272
ERAHUD_IconDeltaDiagonal = 0.86 -- sqrt(0.75)

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
---@field selfDispellableMagic boolean
---@field selfDispellablePoison boolean
---@field selfDispellableDisease boolean
---@field selfDispellableCurse boolean
---@field selfDispellableBleed boolean
---@field targetDispellableMagic boolean
---@field targetDispellableEnrage boolean
---@field targetCast number
---@field targetCastBar ERAHUDTargetCastBar
---@field private channelingSpellID integer|nil
---@field private watchTargetDispellable boolean
---@field private baseGCD number
---@field private minGCD number
---@field private nested ERAHUDNestedModule[]
---@field private activeNested ERAHUDNestedModule[]
---@field private dataItems ERADataItem[]
---@field private activeDataItems ERADataItem[]
---@field private buffs ERAAura[]
---@field private activeBuffs table<number, ERAAura>
---@field private hasBuffsAnyCaster boolean
---@field private debuffs ERAAura[]
---@field private activeDebuffs table<number, ERAAura>
---@field private debuffsOnSelf ERAAura[]
---@field private activeDebuffsOnSelf table<number, ERAAura>
---@field private bagItems ERACooldownBagItem[]
---@field private updateData fun(this:ERAHUD, t:number, combat:boolean)
---@field private resetEmpower fun(this:ERAHUD)
---@field private updateHealthData fun(this:ERAHUD, h:ERAHUDHealth, unit:string)
---@field private EnterCombat fun(this:ERAHUD)
---@field private ExitCombat fun(this:ERAHUD)
---@field private ResetToIdle fun(this:ERAHUD)
---@field private CheckTalents fun(this:ERAHUD)
---@field private CLEU fun(this:ERAHUD, t:number)
---@field AdditionalCLEU fun(this:ERAHUD, t:number)
---@field private updateHealthStatus fun(this:ERAHUD, h:ERAHUDHealth, t:number)
---@field private updateHealthStatusIdle fun(this:ERAHUD, h:ERAHUDHealth, t:number)
---@field private updatePowerStatus fun(this:ERAHUD, t:number)
---@field private updateIcons fun(this:ERAHUD, t:number, combat:boolean)
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
---@field private utilityIcons ERAHUDUtilityIcon[]
---@field private activeUtilityIcons ERAHUDUtilityIcon[]
---@field private outOfCombat ERAHUDUtilityIconOutOfCombat[]
---@field private utilityGroups ERAHUDUtilityGroup[]
---@field private must_update_utility_layout boolean
---@field mustUpdateUtilityLayout fun(this:ERAHUD)
---@field private updateUtilityLayout fun(this:ERAHUD)
---@field private updateUtilityLayoutIfNecessary fun(this:ERAHUD)
---@field maxRotationInRow integer
---@field maxRotationInHealerColumn integer
---@field powerUpGroup ERAHUDUtilityGroup
---@field healGroup ERAHUDUtilityGroup
---@field defenseGroup ERAHUDUtilityGroup
---@field specialGroup ERAHUDUtilityGroup
---@field controlGroup ERAHUDUtilityGroup
---@field movementGroup ERAHUDUtilityGroup
---@field IsCombatPowerVisibleOverride fun(this:ERAHUD, t:number): boolean
---@field calcTimerPixel fun(this:ERAHUD, t:number): number
---@field private modules ERAHUDResourceModule[]
---@field private activeModules ERAHUDResourceModule[]
---@field PreUpdateDataOverride fun(this:ERAHUD, t:number, combat:boolean)
---@field DataUpdatedOverride fun(this:ERAHUD, t:number, combat:boolean)
---@field PreUpdateDisplayOverride fun(this:ERAHUD, t:number, combat:boolean)
---@field DisplayUpdatedOverride fun(this:ERAHUD, t:number, combat:boolean)

---@class ERAHUD : ERACombatModule
ERAHUD = {}
ERAHUD.__index = ERAHUD
setmetatable(ERAHUD, { __index = ERACombatModule })

--#region CSTR

---@param cFrame ERACombatFrame
---@param baseGCD number
---@param requireCLEU boolean
---@param isHealer boolean
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
    hud.dataItems = {}
    hud.activeDataItems = {}
    hud.buffs = {}
    hud.activeBuffs = {}
    hud.hasBuffsAnyCaster = false
    hud.debuffs = {}
    hud.activeDebuffs = {}
    hud.debuffsOnSelf = {}
    hud.activeDebuffsOnSelf = {}
    hud.bagItems = {}

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

    hud.maxRotationInRow = 4
    hud.maxRotationInHealerColumn = 5

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
    hud.utilityIcons = {}
    hud.activeUtilityIcons = {}
    hud.utilityGroups = {}
    hud.outOfCombat = {}
    hud.modules = {}
    hud.activeModules = {}

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

    -- layout

    hud.must_update_utility_layout = true

    hud.healGroup = ERAHUDUtilityGroup:create(hud, "LEFT", "Interface/Addons/ERACombatFrames/textures/pharmacy.tga")
    hud.powerUpGroup = ERAHUDUtilityGroup:create(hud, "BOTTOM", "Interface/Addons/ERACombatFrames/textures/power-up.tga")
    hud.defenseGroup = ERAHUDUtilityGroup:create(hud, "BOTTOM", "Interface/Addons/ERACombatFrames/textures/shield.tga")
    hud.specialGroup = ERAHUDUtilityGroup:create(hud, "RIGHT", "Interface/Addons/ERACombatFrames/textures/cogs.tga")
    hud.controlGroup = ERAHUDUtilityGroup:create(hud, "RIGHT", "Interface/Addons/ERACombatFrames/textures/disruption.tga")
    hud.movementGroup = ERAHUDUtilityGroup:create(hud, "RIGHT", "Interface/Addons/ERACombatFrames/textures/movement.tga")

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
    function hud.events:BAG_UPDATE()
        for _, i in ipairs(self.bagItems) do
            i:bagUpdateOrReset()
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
        self.gcdBar:SetPoint("TOPRIGHT", self.timerFrameOverlay, "RIGHT", 0, ERAHUD_TimerIconSize)
    else
        self.gcdBar:SetPoint("BOTTOMRIGHT", self.timerFrameOverlay, "RIGHT", 0, -ERAHUD_TimerIconSize)
    end
    self.gcdBar:Hide()
    self.gcdVisible = false

    --#region COMMON/GENERIC CONTENT

    if self.isHealer then
        local paradoxTimer = self:AddTrackedBuffAnyCaster(406732)
        self:AddBarWithID(paradoxTimer, nil, 1, 0.9, 0.7)
    end

    -- warlock health stone
    self:AddBagItemIcon(self:AddBagItemCooldown(5512), self.healGroup, 538745, nil, ERACombatFrames_classID == 9)
    --warlock portal
    self:AddBagExternalTimerIcon(self:AddTrackedDebuffOnSelf(113942), self.movementGroup, 607512)

    -- racial

    local _, _, r = UnitRace("player")
    local racialSpellID = nil
    local racialGroup = nil
    if (r == 1 or r == 33) then
        -- human
        racialSpellID = 59752
        racialGroup = self.movementGroup
    elseif (r == 2) then
        -- orc
        racialSpellID = 33697
        racialGroup = self.powerUpGroup
    elseif (r == 3) then
        -- dwarf
        racialSpellID = 20594
        racialGroup = self.defenseGroup
    elseif (r == 4) then
        -- night elf
        racialSpellID = 58984
        racialGroup = self.specialGroup
    elseif (r == 5) then
        -- undead
        racialSpellID = 7744
        racialGroup = self.specialGroup
    elseif (r == 6) then
        -- tauren
        racialSpellID = 20549
        racialGroup = self.controlGroup
    elseif (r == 7) then
        -- gnome
        racialSpellID = 20589
        racialGroup = self.movementGroup
    elseif (r == 8) then
        -- troll
        racialSpellID = 26297
        racialGroup = self.powerUpGroup
    elseif (r == 9) then
        -- goblin
        racialSpellID = 69070
        racialGroup = self.movementGroup
    elseif (r == 10) then
        -- blood elf
        racialSpellID = 202719
        racialGroup = self.specialGroup
    elseif (r == 11) then
        -- draenei
        racialSpellID = 59542
        racialGroup = self.healGroup
    elseif (r == 22) then
        -- worgen
        racialSpellID = 68992
        racialGroup = self.movementGroup
    elseif (r == 24 or r == 25 or r == 26) then
        -- pandaren
        racialSpellID = 107079
        racialGroup = self.controlGroup
    elseif (r == 27) then
        -- nightborne
        racialSpellID = 260364
        racialGroup = self.powerUpGroup
    elseif (r == 28) then
        -- highmountain
        racialSpellID = 255654
        racialGroup = self.controlGroup
    elseif (r == 29) then
        -- void elf
        racialSpellID = 256948
        racialGroup = self.movementGroup
    elseif (r == 30) then
        -- lightforged
        racialSpellID = 255647
        racialGroup = self.powerUpGroup
    elseif (r == 31) then
        -- zandalari
        racialSpellID = 291944
        racialGroup = self.healGroup
    elseif (r == 32) then
        -- kul tiran
        racialSpellID = 287712
        racialGroup = self.controlGroup
    elseif (r == 34) then
        -- dark iron
        racialSpellID = 265221
        racialGroup = self.powerUpGroup
    elseif (r == 35) then
        -- vulpera
        racialSpellID = 312411
        racialGroup = self.powerUpGroup
    elseif (r == 36) then
        -- mag'har
        racialSpellID = 274738
        racialGroup = self.powerUpGroup
    elseif (r == 37) then
        -- mechagnome
        racialSpellID = 312924
        racialGroup = self.specialGroup
    elseif (r == 84 or r == 85) then
        -- earthen
        racialSpellID = 436344
        racialGroup = self.powerUpGroup
    end
    if (racialSpellID) then
        return self:AddUtilityCooldown(self:AddTrackedCooldown(racialSpellID), self.specialGroup)
    end

    -- equipment
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_TRINKET1), self.powerUpGroup, 465875)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_TRINKET2), self.powerUpGroup, 3610503)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_BACK), self.specialGroup, 530999)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_WAIST), self.specialGroup, 443322)

    --#endregion

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
    for _, g in ipairs(self.utilityGroups) do
        g:showIfHasContent()
    end
end

function ERAHUD:ExitCombat()
    self.timerFrame:Hide()
    for _, g in ipairs(self.utilityGroups) do
        g:hide()
    end
end

function ERAHUD:ResetToIdle()
    for k, v in pairs(self.events) do
        self.mainFrame:RegisterEvent(k)
    end
    for _, i in ipairs(self.bagItems) do
        i:bagUpdateOrReset()
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
    table.wipe(self.activeDataItems)
    for _, t in ipairs(self.dataItems) do
        if (t:checkTalent()) then
            table.insert(self.activeDataItems, t)
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
    table.wipe(self.activeDebuffsOnSelf)
    for _, a in ipairs(self.debuffsOnSelf) do
        if a.talentActive then
            self.activeDebuffsOnSelf[a.spellID] = a
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
    table.wipe(self.activeModules)
    for _, m in ipairs(self.modules) do
        if m:checkTalentOrHide(self.statusBaseX, statusY, self.mainFrame) then
            statusY = statusY - m.height - self.statusSpacing
            table.insert(self.activeModules, m)
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

    local iconSpace = ERAHUD_RotationIconSize + ERAHUD_RotationIconSpacing

    if self.isHealer then
        --#region HEALER ICONS

        local xRotation = 1.5 * ERAHUD_TimerIconSize + ERAHUD_RotationIconSize / 2
        local yRotation = ERAHUD_RotationHealerY
        local largeColumn = true
        local countInColumn = 0
        local maxSpecial = 4
        local xSpecial = ERAHUD_RotationSpecialHealerX
        local ySpecial = ERAHUD_RotationSpecialHealerY
        local largeSpecial = true
        local countSpecial = 0
        for _, i in ipairs(self.activeRotation) do
            if i.specialPosition then
                i.icon:Draw(xSpecial, ySpecial, false)
                countSpecial = countSpecial + 1
                local newRow
                if largeSpecial then
                    if countSpecial >= maxSpecial then
                        largeSpecial = false
                        xSpecial = ERAHUD_RotationSpecialHealerX + iconSpace / 2
                        newRow = true
                    else
                        newRow = false
                    end
                else
                    if countSpecial + 1 >= maxSpecial then
                        largeSpecial = true
                        xSpecial = ERAHUD_RotationSpecialHealerX
                        newRow = true
                    else
                        newRow = false
                    end
                end
                if newRow then
                    countSpecial = 0
                    ySpecial = ySpecial - iconSpace * ERAHUD_IconDeltaDiagonal
                else
                    xSpecial = xSpecial + iconSpace
                end
            else
                i.icon:Draw(xRotation, yRotation, false)
                countInColumn = countInColumn + 1
                local newColumn
                if largeColumn then
                    if countInColumn >= self.maxRotationInHealerColumn then
                        largeColumn = false
                        yRotation = ERAHUD_RotationHealerY + iconSpace / 2
                        newColumn = true
                    else
                        newColumn = false
                    end
                else
                    if countInColumn + 1 >= self.maxRotationInHealerColumn then
                        largeColumn = true
                        yRotation = ERAHUD_RotationHealerY
                        newColumn = true
                    else
                        newColumn = false
                    end
                end
                if newColumn then
                    countInColumn = 0
                    xRotation = xRotation + iconSpace * ERAHUD_IconDeltaDiagonal
                else
                    yRotation = yRotation + iconSpace
                end
            end
        end

        --#endregion
    else
        --#region NON-HEALER ICONS

        local xRotationInit = -ERAHUD_TimerIconSize - ERAHUD_RotationIconSize / 2
        local xRotation = xRotationInit
        local yRotation = statusY - ERAHUD_RotationIconSize / 2
        local largeRow = true
        local countInRow = 0
        local xSpecial = ERAHUD_RotationSpecialX
        local ySpecial = ERAHUD_RotationSpecialY
        local highColumn = true
        local countInColumn = 0
        for _, i in ipairs(self.activeRotation) do
            if i.specialPosition then
                i.icon:Draw(xSpecial, ySpecial, false)
                countInColumn = countInColumn + 1
                local newColumn
                if highColumn then
                    if countInColumn >= self.maxRotationInRow then
                        highColumn = false
                        ySpecial = ERAHUD_RotationSpecialY + iconSpace / 2
                        newColumn = true
                    else
                        newColumn = false
                    end
                else
                    if countInColumn + 1 >= self.maxRotationInRow then
                        highColumn = true
                        ySpecial = ERAHUD_RotationSpecialY
                        newColumn = true
                    else
                        newColumn = false
                    end
                end
                if newColumn then
                    countInColumn = 0
                    xSpecial = xSpecial + iconSpace * ERAHUD_IconDeltaDiagonal
                else
                    ySpecial = ySpecial + iconSpace
                end
            else
                i.icon:Draw(xRotation, yRotation, false)
                countInRow = countInRow + 1
                local newRow
                if largeRow then
                    if countInRow >= self.maxRotationInRow then
                        largeRow = false
                        xRotation = xRotationInit - iconSpace / 2
                        newRow = true
                    else
                        newRow = false
                    end
                else
                    if countInRow + 1 >= self.maxRotationInRow then
                        largeRow = true
                        xRotation = xRotationInit
                        newRow = true
                    else
                        newRow = false
                    end
                end
                if newRow then
                    countInRow = 0
                    yRotation = yRotation + iconSpace * ERAHUD_IconDeltaDiagonal
                else
                    xRotation = xRotation - iconSpace
                end
            end
        end

        --#endregion
    end

    self:updateUtilityLayout()
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

    self:PreUpdateDisplayOverride(t, false)

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

    self:updateIcons(t, false)

    for _, m in ipairs(self.activeModules) do
        m:updateDisplay(false, t)
    end

    self:DisplayUpdatedOverride(t, false)

    self:updateUtilityLayoutIfNecessary()
end

---@param t number
function ERAHUD:UpdateCombat(t)
    self:updateData(t, true)

    self:PreUpdateDisplayOverride(t, true)

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

    self:updateIcons(t, true)

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
        yPrio = 1.5 * ERAHUD_TimerIconSize
    else
        yPrio = -1.5 * ERAHUD_TimerIconSize
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

    for _, m in ipairs(self.activeModules) do
        m:updateDisplay(true, t)
    end

    self:DisplayUpdatedOverride(t, true)

    self:updateUtilityLayoutIfNecessary()
end

---@param t number
---@param combat boolean
function ERAHUD:updateIcons(t, combat)
    for _, r in ipairs(self.activeRotation) do
        r:update(combat, t)
    end
    for _, i in ipairs(self.activeUtilityIcons) do
        i:update(combat, t)
    end
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

---@param i ERADataItem
function ERAHUD:addDataItem(i)
    table.insert(self.dataItems, i)
end

---@param b ERACooldownBagItem
function ERAHUD:addBagItem(b)
    table.insert(self.bagItems, b)
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

    local i = 1
    while true do
        local auraInfo = C_UnitAuras.GetDebuffDataByIndex("target", i, "PLAYER")
        if (auraInfo) then
            local a = self.activeDebuffs[auraInfo.spellId]
            if (a ~= nil) then
                a:auraFound(t, auraInfo)
            end
            i = i + 1
        else
            break
        end
    end
    i = 1
    if self.hasBuffsAnyCaster then
        while true do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i)
            if (auraInfo) then
                local a = self.activeBuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo)
                end
                i = i + 1
            else
                break
            end
        end
    else
        while true do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i, "PLAYER")
            if (auraInfo) then
                local a = self.activeBuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo)
                end
                i = i + 1
            else
                break
            end
        end
    end
    self.selfDispellableBleed = false
    self.selfDispellableDisease = false
    self.selfDispellableCurse = false
    self.selfDispellableMagic = false
    self.selfDispellablePoison = false
    i = 1
    while true do
        local auraInfo = C_UnitAuras.GetDebuffDataByIndex("player", i)
        if (auraInfo) then
            if auraInfo.dispelName == "Magic" then
                self.selfDispellableMagic = true
            elseif auraInfo.dispelName == "Poison" then
                self.selfDispellablePoison = true
            elseif auraInfo.dispelName == "Curse" then
                self.selfDispellableCurse = true
            elseif auraInfo.dispelName == "Disease" then
                self.selfDispellableDisease = true
            elseif auraInfo.dispelName == "Bleed" then
                self.selfDispellableBleed = true
            end
            local a = self.activeDebuffsOnSelf[auraInfo.spellId]
            if (a ~= nil) then
                a:auraFound(t, auraInfo)
            end
            i = i + 1
        else
            break
        end
    end

    --endregion

    --#region TARGET

    if (self.watchTargetDispellable) then
        self.targetDispellableMagic = false
        self.targetDispellableEnrage = false
        i = 1
        while true do
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
                i = i + 1
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

    for _, tim in ipairs(self.activeDataItems) do
        tim:updateData(t)
    end

    for _, m in ipairs(self.activeModules) do
        m:updateData(combat, t)
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

---@param i ERAHUDUtilityIconOutOfCombat
function ERAHUD:addOutOfCombat(i)
    table.insert(self.outOfCombat, i)
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
--- UTILITY ---
---------------

--#region UTILITY

function ERAHUD:updateUtilityLayoutIfNecessary()
    if self.must_update_utility_layout then
        self:updateUtilityLayout()
    end
end
function ERAHUD:updateUtilityLayout()
    table.wipe(self.activeUtilityIcons)
    for _, i in ipairs(self.utilityIcons) do
        if i:checkTalentOrHide() then
            table.insert(self.activeUtilityIcons, i)
        end
    end

    for _, g in ipairs(self.utilityGroups) do
        g:measure()
    end

    if self.healGroup then
        --#region HEALER LAYOUT



        --#endregion
    else
        --#region NON-HEALER LAYOUT

        if self.healGroup.width > 0 and self.healGroup.height > 0 then
            local xMax = -2 * ERAHUD_TimerIconSize - self.maxRotationInRow
            self.healGroup:arrange(xMax - self.healGroup.width, self.statusBaseY, self.mainFrame)
        end

        local xBottom = self.statusBaseX + self.barsWidth / 2 + ERAHUD_RotationIconSize
        local y = ERAHUD_UtilityMinBottomY
        if self.powerUpGroup.width > 0 and self.powerUpGroup.height > 0 then
            self.powerUpGroup:arrange(xBottom, y, self.mainFrame)
            xBottom = xBottom + self.powerUpGroup.width + ERAHUD_UtilityGoupSpacing
        end
        if self.defenseGroup.width > 0 and self.defenseGroup.height > 0 then
            self.defenseGroup:arrange(xBottom, y, self.mainFrame)
            xBottom = xBottom + self.defenseGroup.width + ERAHUD_UtilityGoupSpacing
        end
        local xRight
        if xBottom < ERAHUD_UtilityMinRightX then
            xRight = ERAHUD_UtilityMinRightX
        else
            xRight = xBottom
        end
        if self.specialGroup.width > 0 and self.specialGroup.height > 0 then
            self.specialGroup:arrange(xBottom, y, self.mainFrame)
        end
        if self.controlGroup.width > 0 and self.controlGroup.height > 0 then
            y = y + self.controlGroup.height + ERAHUD_UtilityGoupSpacing
            self.controlGroup:arrange(xRight, y, self.mainFrame)
        end
        if self.movementGroup.width > 0 and self.movementGroup.height > 0 then
            self.movementGroup:arrange(xRight, y + self.movementGroup.height + ERAHUD_UtilityGoupSpacing, self.mainFrame)
        end

        local xOutOfCombat = -ERAHUD_UtilityIconSize
        local outOfCombatIconSize = ERAHUD_UtilityIconSize + ERAHUD_UtilityIconSpacing
        local yOutOfCombat = ERAHUD_UtilityIconSize / 2
        local largeRow = true
        local count = 0
        for _, i in ipairs(self.outOfCombat) do
            if i.talentActive then
                i.icon:Draw(xOutOfCombat, yOutOfCombat, false)
                count = count + 1
                local newRow
                if largeRow then
                    if count >= 5 then
                        xOutOfCombat = -1.5 * ERAHUD_UtilityIconSize
                        largeRow = false
                        newRow = true
                    else
                        newRow = false
                    end
                else
                    if count >= 4 then
                        xOutOfCombat = -ERAHUD_UtilityIconSize
                        largeRow = true
                        newRow = true
                    else
                        newRow = false
                    end
                end
                if newRow then
                    count = 0
                    yOutOfCombat = yOutOfCombat + outOfCombatIconSize * ERAHUD_IconDeltaDiagonal
                else
                    xOutOfCombat = xOutOfCombat - outOfCombatIconSize
                end
            end
        end

        --#endregion
    end

    self.must_update_utility_layout = false
end

---@param i ERAHUDUtilityIcon
---@return Frame
function ERAHUD:addUtilityIcon(i)
    table.insert(self.utilityIcons, i)
    return self.mainFrame
end

---@param g ERAHUDUtilityGroup
---@return Frame
function ERAHUD:addUtilityGroup(g)
    table.insert(self.utilityGroups, g)
    return self.mainFrame
end

---@alias ERAHUDUtilityGroupIconPosition "LEFT" | "BOTTOM" | "RIGHT"

---@class (exact) ERAHUDUtilityGroup
---@field hud ERAHUD
---@field private __index unknown
---@field private show fun(this:ERAHUDUtilityGroup)
---@field private frame Frame
---@field private iconPosition ERAHUDUtilityGroupIconPosition
---@field private icons ERAHUDUtilityIconInGroup[]
---@field width number
---@field height number
---@field private firstRowIsLarge boolean
---@field private maxColCount integer
---@field private aligned boolean
ERAHUDUtilityGroup = {}
ERAHUDUtilityGroup.__index = ERAHUDUtilityGroup

---@param hud ERAHUD
---@param iconPosition ERAHUDUtilityGroupIconPosition
---@param texture string
---@return ERAHUDUtilityGroup
function ERAHUDUtilityGroup:create(hud, iconPosition, texture)
    local g = {}
    setmetatable(g, ERAHUDUtilityGroup)
    ---@cast g ERAHUDUtilityGroup
    local parentFrame = hud:addUtilityGroup(g)
    local frame = CreateFrame("Frame", nil, parentFrame, "ERAHUDUtilityGroup" .. iconPosition)

    local icon = frame.Icon
    ---@cast icon Texture
    icon:SetSize(ERAHUD_UtilityGoupIconSize, ERAHUD_UtilityGoupIconSize)
    icon:SetTexture(texture)

    local separator = frame.Separator
    ---@cast separator Line
    local sepOffset = ERAHUD_UtilityGoupIconSize + 3.5 * ERAHUD_UtilityGoupBorder
    if iconPosition == "LEFT" then
        separator:SetStartPoint("TOPLEFT", frame, sepOffset, -ERAHUD_UtilityGoupBorder)
        separator:SetEndPoint("BOTTOMLEFT", frame, sepOffset, ERAHUD_UtilityGoupBorder)
    elseif iconPosition == "RIGHT" then
        separator:SetStartPoint("TOPRIGHT", frame, -sepOffset, -ERAHUD_UtilityGoupBorder)
        separator:SetEndPoint("BOTTOMRIGHT", frame, -sepOffset, ERAHUD_UtilityGoupBorder)
    else
        separator:SetStartPoint("BOTTOMLEFT", frame, ERAHUD_UtilityGoupBorder, sepOffset)
        separator:SetEndPoint("BOTTOMRIGHT", frame, -ERAHUD_UtilityGoupBorder, sepOffset)
    end

    g.frame = frame
    g.iconPosition = iconPosition
    g.hud = hud
    g.icons = {}
    g:hide()
    return g
end

---@param i ERAHUDUtilityIconInGroup
---@param givenDisplayOrder number|nil
---@return number
function ERAHUDUtilityGroup:addIcon(i, givenDisplayOrder)
    local maxDisplay = 0
    for _, existing in self.icons do
        ---@cast existing ERAHUDUtilityIconInGroup
        if existing.displayOrder > maxDisplay then
            maxDisplay = existing.displayOrder
        end
    end
    table.insert(self.icons, i)
    if givenDisplayOrder then
        return givenDisplayOrder
    else
        return maxDisplay + 1
    end
end

function ERAHUDUtilityGroup:show()
    self.frame:Show()
end
function ERAHUDUtilityGroup:showIfHasContent()
    self:show()
end

function ERAHUDUtilityGroup:hide()
    self.frame:Hide()
end

function ERAHUDUtilityGroup:measure()
    local count = 0
    for _, i in ipairs(self.icons) do
        if i.talentActive then
            count = count + 1
        end
    end
    if count > 0 then
        local iconSpace = ERAHUD_UtilityIconSize + ERAHUD_UtilityIconSpacing
        local rowCount
        self.aligned = false
        if count == 1 then
            self.firstRowIsLarge = true
            self.maxColCount = 1
            rowCount = 1
        elseif count == 2 then
            self.firstRowIsLarge = true
            self.maxColCount = 2
            rowCount = 1
        elseif count == 3 then
            self.firstRowIsLarge = true
            self.maxColCount = 2
            rowCount = 2
        elseif count == 4 then
            self.firstRowIsLarge = true
            self.maxColCount = 2
            rowCount = 2
            self.aligned = true
        elseif count == 5 then
            self.firstRowIsLarge = true
            self.maxColCount = 3
            rowCount = 2
        elseif count == 6 then
            self.firstRowIsLarge = true
            self.maxColCount = 3
            rowCount = 1
            self.aligned = true
        elseif count == 7 then
            self.firstRowIsLarge = false
            self.maxColCount = 3
            rowCount = 3
        elseif count == 8 then
            self.firstRowIsLarge = true
            self.maxColCount = 3
            rowCount = 3
        elseif count == 9 then
            self.firstRowIsLarge = false
            self.maxColCount = 5
            rowCount = 2
        elseif count == 10 then
            self.firstRowIsLarge = false
            self.maxColCount = 4
            rowCount = 3
        else
            self.firstRowIsLarge = true
            self.maxColCount = 5
            rowCount = math.ceil(count / 5)
            self.aligned = true
        end
        local borderAndPadding = ERAHUD_UtilityGoupBorder + ERAHUD_UtilityGoupPadding
        local iconPart = ERAHUD_UtilityGoupIconSize + 3 * ERAHUD_UtilityGoupBorder
        self.width = self.maxColCount * iconSpace + 2 * borderAndPadding
        if self.aligned then
            self.height = iconSpace * rowCount + 2 * borderAndPadding
        else
            self.height = iconSpace + ERAHUD_IconDeltaDiagonal * (rowCount - 1) + 2 * borderAndPadding
        end
        if self.iconPosition == "LEFT" or self.iconPosition == "RIGHT" then
            self.width = self.width + iconPart
        else
            self.height = self.height + iconPart
        end

        if self.hud.cFrame.inCombat then
            self:show()
        end
    else
        self:hide()
        self.width = 0
        self.height = 0
    end
end

---@param topLeftX number
---@param topLeftY number
---@param frame Frame
function ERAHUDUtilityGroup:arrange(topLeftX, topLeftY, frame)
    table.sort(self.icons, ERAHUDUtilityIconInGroup_compareDisplayOrder)

    self.frame:SetPoint("TOPLEFT", frame, "CENTER", topLeftX, topLeftY)
    self.frame:SetPoint("BOTTOMRIGHT", frame, "CENTER", topLeftX + self.width, topLeftY - self.height)
    local offsetX, offsetY
    local iconPart = ERAHUD_UtilityGoupIconSize + 3 * ERAHUD_UtilityGoupBorder
    local borderAndPadding = ERAHUD_UtilityGoupBorder + ERAHUD_UtilityGoupPadding
    if self.iconPosition == "LEFT" then
        offsetX = topLeftX + iconPart + borderAndPadding
        offsetY = topLeftY - borderAndPadding
    elseif self.iconPosition == "RIGHT" then
        offsetX = topLeftX + borderAndPadding
        offsetY = topLeftY - borderAndPadding
    elseif self.iconPosition == "BOTTOM" then
        offsetX = topLeftX + borderAndPadding
        offsetY = topLeftY - borderAndPadding
    else -- TOP
        offsetX = topLeftX + borderAndPadding
        offsetY = topLeftY - iconPart - borderAndPadding
    end
    local iconSpace = ERAHUD_UtilityIconSize + ERAHUD_UtilityIconSpacing
    local largeRow
    local x
    if self.aligned or self.firstRowIsLarge then
        x = offsetX + iconSpace / 2
        largeRow = true
    else
        x = offsetX + iconSpace
        largeRow = false
    end
    local y = offsetY - iconSpace / 2
    local count = 0
    for _, i in ipairs(self.icons) do
        if i.talentActive then
            i.icon:Draw(x, y, false)
            count = count + 1
            local newRow
            if largeRow then
                if count >= self.maxColCount then
                    if self.aligned then
                        x = offsetX + iconSpace / 2
                    else
                        x = offsetX + iconSpace
                        largeRow = false
                    end
                    newRow = true
                else
                    newRow = false
                end
            else
                if count + 1 >= self.maxColCount then
                    -- on a forcément !this.aligned
                    x = offsetX + iconSpace / 2
                    largeRow = true
                    newRow = true
                else
                    newRow = false
                end
            end
            if newRow then
                count = 0
                y = y + iconSpace * ERAHUD_IconDeltaDiagonal
            else
                x = x + iconSpace
            end
        end
    end
end

--#endregion

---------------
--- MODULES ---
---------------

--#region MODULES

---@param m ERAHUDResourceModule
---@return Frame
function ERAHUD:addModule(m)
    table.insert(self.modules, m)
    return self.mainFrame
end

---@class (exact) ERAHUDResourceModule
---@field private __index unknown
---@field protected constructModule fun(this:ERAHUDResourceModule, hud:ERAHUD, height:number, talent:ERALIBTalent|nil)
---@field private talent ERALIBTalent|nil
---@field protected frame Frame
---@field protected checkTalentOverride fun(this:ERAHUDResourceModule): boolean
---@field protected hide fun(this:ERAHUDResourceModule)
---@field protected show fun(this:ERAHUDResourceModule)
---@field private visible boolean
---@field height number
---@field updateData fun(this:ERAHUDResourceModule, combat:boolean, t:number)
---@field updateDisplay fun(this:ERAHUDResourceModule, combat:boolean, t:number)
---@field hud ERAHUD
ERAHUDResourceModule = {}
ERAHUDResourceModule.__index = ERAHUDResourceModule

---@param hud ERAHUD
---@param height number
---@param talent ERALIBTalent|nil
function ERAHUDResourceModule:constructModule(hud, height, talent)
    self.hud = hud
    self.talent = talent
    local parentFrame = hud:addModule(self)
    self.frame = CreateFrame("Frame", nil, parentFrame)
    self.frame:SetSize(hud.barsWidth, height)
    self.height = height
    self.visible = true
end

function ERAHUDResourceModule:hide()
    if self.visible then
        self.visible = false
        self.frame:Hide()
    end
end

function ERAHUDResourceModule:show()
    if not self.visible then
        self.visible = true
        self.frame:Show()
    end
end

---@param topX number
---@param topY number
---@param parentFrame Frame
---@return boolean
function ERAHUDResourceModule:checkTalentOrHide(topX, topY, parentFrame)
    if (self.talent and not self.talent:PlayerHasTalent()) or not self:checkTalentOverride() then
        self:hide()
        return false
    else
        self.frame:SetPoint("TOP", parentFrame, "CENTER", topX, topY)
        self:show()
        return true
    end
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
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.buffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuffAnyCaster(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    self.hasBuffsAnyCaster = true
    table.insert(self.buffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuffOnTarget(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.debuffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuffOnSelf(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.debuffsOnSelf, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERACooldownAdditionalID
---@return ERACooldown
function ERAHUD:AddTrackedCooldown(spellID, talent, ...)
    return ERACooldown:create(self, spellID, talent, ...)
end

---@param itemID integer
---@param talent ERALIBTalent|nil
---@return ERACooldownBagItem
function ERAHUD:AddBagItemCooldown(itemID, talent)
    return ERACooldownBagItem:create(self, itemID, talent)
end

---@param slotID integer
---@return ERACooldownEquipment
function ERAHUD:AddEquipmentCooldown(slotID)
    return ERACooldownEquipment:create(self, slotID)
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@return ERASpellStacks
function ERAHUD:AddSpellStacks(spellID, talent)
    return ERASpellStacks:create(self, spellID, talent)
end

--#endregion

--#region DISPLAY

--- rotation ---

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
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationCooldownIcon
function ERAHUD:AddRotationCooldown(data, iconID, talent)
    return ERAHUDRotationCooldownIcon:create(data, iconID, talent)
end

---@param data ERACooldownBase
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationKickIcon
function ERAHUD:AddKick(data, iconID, talent)
    return ERAHUDRotationKickIcon:create(data, iconID, talent)
end

---@param data ERACooldownBase
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param enrage boolean
---@return ERAHUDRotationOffensiveDispellIcon
function ERAHUD:AddOffensiveDispell(data, iconID, talent, magic, enrage)
    self.watchTargetDispellable = true
    return ERAHUDRotationOffensiveDispellIcon:create(data, iconID, talent, magic, enrage)
end

---@param data ERAAura
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationAuraIcon
function ERAHUD:AddRotationBuff(data, iconID, talent)
    return ERAHUDRotationAuraIcon:create(data, iconID, talent)
end

---@param data ERAStacks
---@param maxStacks integer
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationStacksIcon
function ERAHUD:AddRotationStacks(data, maxStacks, iconID, talent)
    return ERAHUDRotationStacksIcon:create(data, maxStacks, iconID, talent)
end

---@param iconID integer
---@param talent ERALIBTalent|nil
---@return ERAHUDRawPriority
function ERAHUD:AddPriority(iconID, talent)
    return ERAHUDRawPriority:create(self, iconID, talent)
end

--- utility ---

---@param data ERACooldownBase
---@param group ERAHUDUtilityGroup
---@param iconID integer|nil
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityCooldownInGroup
function ERAHUD:AddUtilityCooldown(data, group, iconID, displayOrder, talent)
    return ERAHUDUtilityCooldownInGroup:create(group, data, iconID, displayOrder, talent)
end

---@param data ERACooldownBase
---@param group ERAHUDUtilityGroup
---@param iconID integer|nil
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param poison boolean
---@param disease boolean
---@param curse boolean
---@param bleed boolean
---@return ERAHUDUtilityDispellInGroup
function ERAHUD:AddUtilityDispell(data, group, iconID, displayOrder, talent, magic, poison, disease, curse, bleed)
    return ERAHUDUtilityDispellInGroup:create(group, data, iconID, displayOrder, talent, magic, poison, disease, curse, bleed)
end

---@param aura ERAAura
---@param group ERAHUDUtilityGroup
---@param iconID integer|nil
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityGenericTimerInGroup
function ERAHUD:AddUtilityAura(aura, group, iconID, displayOrder, talent)
    if not iconID then
        local spellInfo = C_Spell.GetSpellInfo(aura.spellID)
        iconID = spellInfo.iconID
    end
    return ERAHUDUtilityGenericTimerInGroup:create(group, aura, iconID, displayOrder, talent)
end

---@param timer ERACooldownEquipment
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@return ERAHUDUtilityEquipmentInGroup
function ERAHUD:AddEquipmentIcon(timer, group, iconID, displayOrder)
    return ERAHUDUtilityEquipmentInGroup:create(group, timer, iconID, displayOrder)
end

---@param timer ERACooldownBagItem
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param warningIfMissing boolean
---@return ERAHUDUtilityBagItemInGroup
function ERAHUD:AddBagItemIcon(timer, group, iconID, displayOrder, warningIfMissing)
    return ERAHUDUtilityBagItemInGroup:create(group, timer, iconID, displayOrder, warningIfMissing)
end

---@param timer ERATimer
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityExternalTimerInGroup
function ERAHUD:AddBagExternalTimerIcon(timer, group, iconID, displayOrder, talent)
    return ERAHUDUtilityExternalTimerInGroup:create(group, timer, iconID, displayOrder, talent)
end

--#endregion

--#endregion

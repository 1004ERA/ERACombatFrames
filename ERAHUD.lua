--[[

TODO
- healer layout
- generic improvements
- reverse overlay for buffs
- improve spell overlay
- highlight max stacks

]]

ERAHUD_TimerWidth = 400
ERAHUD_TimerGCDCount = 5
ERAHUD_TimerBarDefaultSize = 22
ERAHUD_TimerBarSpacing = 4
ERAHUD_TimerIconSize = 22
ERAHUD_RotationIconSize = 42
ERAHUD_RotationIconSpacing = 2
ERAHUD_RotationHealerY = ERAHUD_RotationIconSize
ERAHUD_UtilityIconSize = 50
ERAHUD_UtilityIconSpacing = 4
ERAHUD_UtilityGoupSpacing = 8
ERAHUD_UtilityGoupIconSize = 22
ERAHUD_UtilityGoupBorder = 2
ERAHUD_UtilityGoupPadding = 4
ERAHUD_UtilityMinBottomY = -181
ERAHUD_UtilityMinRightX = 181
ERAHUD_OffsetX = -144
ERAHUD_OffsetY = 0
ERAHUD_HealerOffsetX = -181
ERAHUD_HealerTimerOffsetY = -64
ERAHUD_HealerMainOffsetY = -8
ERAHUD_IconDeltaDiagonal = 0.86 -- sqrt(0.75)

---@class (exact) ERAHUDHealth
---@field currentHealth number
---@field maxHealth number
---@field absorb number
---@field healAbsorb number
---@field bar ERAHUDStatusBar

---@class (exact) ERAHUD
---@field private __index unknown
---@field showUtility boolean
---@field showSAO boolean
---@field UtilityMinRightX number
---@field UtilityMinBottomY number
---@field private isHealer boolean
---@field topdown boolean
---@field barsWidth number
---@field private statusBaseX number
---@field private statusBaseY number
---@field private statusMaxY number
---@field healthHeight number
---@field petHeight number
---@field private statusSpacing number
---@field health ERAHUDHealth
---@field hasPet boolean
---@field petHealth ERAHUDHealth
---@field private petHealthTalent ERALIBTalent
---@field timerDuration number
---@field remGCD number
---@field totGCD number
---@field remCast number
---@field private totCast number
---@field private wasCasting boolean
---@field occupied number
---@field castingSpellID integer|nil
---@field hasteMultiplier number
---@field canAttackTarget boolean
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
---@field private buffsOnPet ERAAura[]
---@field private activeBuffsOnPet table<number, ERAAura>
---@field private hasActiveBuffsOnPet boolean
---@field private hasBuffsAnyCaster boolean
---@field private hasDebuffsAnyCaster boolean
---@field private debuffs ERAAura[]
---@field private activeDebuffs table<number, ERAAura>
---@field private debuffsOnSelf ERAAura[]
---@field private activeDebuffsOnSelf table<number, ERAAura>
---@field private buffsOnParty ERAAuraOnGroupMembers[]
---@field private activeBuffsOnParty table<number, ERAAuraOnGroupMembers>
---@field private hasActiveBuffsOnParty boolean
---@field private lastParseParty number
---@field otherTanksInGroup integer
---@field otherHealersInGroup integer
---@field otherDPSsInGroup integer
---@field isInGroup boolean
---@field groupMembersExcludingSelf integer
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
---@field private drawStatusAndRotation fun(this:ERAHUD)
---@field private updateResourceDisplay fun(this:ERAHUD, t:number, combat:boolean)
---@field private placePet fun(this:ERAHUD, statusY:number): number
---@field private updateHealthStatus fun(this:ERAHUD, h:ERAHUDHealth, t:number)
---@field private updateHealthStatusIdle fun(this:ERAHUD, h:ERAHUDHealth, t:number, checkPetMounted:boolean)
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
---@field private castLine Line
---@field private castBackground Texture
---@field private castVisible boolean
---@field private events unknown
---@field offsetX number
---@field offsetY number
---@field private SAO ERASAO[]
---@field private activeSAO ERASAO[]
---@field private rotation ERAHUDRotationIcon[]
---@field private activeRotation ERAHUDRotationIcon[]
---@field private timerItems ERAHUDTimerItem[]
---@field private activeTimerItems ERAHUDTimerItem[]
---@field private displayedTimerItems ERAHUDTimerItem[]
---@field private availablePriority ERAHUDTimerItem[]
---@field private utilityIcons ERAHUDUtilityIcon[]
---@field private activeUtilityIcons ERAHUDUtilityIcon[]
---@field private outOfCombat ERAHUDUtilityIconOutOfCombat[]
---@field private emptyUtility ERAHUDMissingUtility[]
---@field private utilityGroups ERAHUDUtilityGroup[]
---@field private must_update_utility_layout boolean
---@field mustUpdateUtilityLayout fun(this:ERAHUD)
---@field private updateUtilityLayout fun(this:ERAHUD)
---@field private updateUtilityLayoutIfNecessary fun(this:ERAHUD)
---@field maxRotationInRow integer
---@field maxRotationInHealerColumn integer
---@field healthstoneTalent ERALIBTalent|nil
---@field powerUpGroup ERAHUDUtilityGroup
---@field healGroup ERAHUDUtilityGroup
---@field defenseGroup ERAHUDUtilityGroup
---@field specialGroup ERAHUDUtilityGroup
---@field controlGroup ERAHUDUtilityGroup
---@field movementGroup ERAHUDUtilityGroup
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
---@param showPet ERALIBTalent|boolean
---@param spec integer
---@return ERAHUD
function ERAHUD:Create(cFrame, baseGCD, requireCLEU, isHealer, showPet, spec)
    local specOptions = ERACombatOptions_getOptionsForSpec(nil, spec)
    local hud = {}
    setmetatable(hud, ERAHUD)
    ---@cast hud ERAHUD
    hud:construct(cFrame, 0.2, 0.02, requireCLEU, spec)

    hud.showUtility = not specOptions.hideUtility
    hud.showSAO = not specOptions.hideSAO
    hud.UtilityMinRightX = specOptions.rightX
    if hud.UtilityMinRightX == nil then hud.UtilityMinRightX = ERAHUD_UtilityMinRightX end
    hud.UtilityMinBottomY = specOptions.bottomY
    if hud.UtilityMinBottomY == nil then hud.UtilityMinBottomY = ERAHUD_UtilityMinBottomY end

    hud.barsWidth = 144
    hud.offsetX = specOptions.leftX
    hud.offsetY = specOptions.offsetY
    if isHealer then
        hud.isHealer = true
        hud.topdown = true
        if hud.offsetX == nil then hud.offsetX = ERAHUD_HealerOffsetX end
        if hud.offsetY == nil then hud.offsetY = ERAHUD_HealerTimerOffsetY end
        hud.statusBaseX = 1.5 * ERAHUD_TimerIconSize + hud.barsWidth / 2
        hud.statusBaseY = ERAHUD_HealerMainOffsetY
    else
        hud.isHealer = false
        hud.topdown = false
        if hud.offsetX == nil then hud.offsetX = ERAHUD_OffsetX end
        if hud.offsetY == nil then hud.offsetY = ERAHUD_OffsetY end
        hud.statusBaseX = -ERAHUD_TimerIconSize - hud.barsWidth / 2
        hud.statusBaseY = -1.5 * ERAHUD_TimerIconSize
    end

    -- data
    hud.timerDuration = baseGCD * ERAHUD_TimerGCDCount
    hud.remGCD = 0
    hud.totGCD = baseGCD
    hud.baseGCD = baseGCD
    if baseGCD > 1 then
        hud.minGCD = 0.75
    else
        hud.minGCD = 1
    end
    hud.remCast = 0
    hud.totCast = 1
    hud.occupied = 0

    hud.hasteMultiplier = 1
    hud.channelingSpellID = nil
    hud.canAttackTarget = false

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
    hud.buffsOnPet = {}
    hud.activeBuffsOnPet = {}
    hud.hasActiveBuffsOnPet = false
    hud.hasBuffsAnyCaster = false
    hud.hasDebuffsAnyCaster = false
    hud.debuffs = {}
    hud.activeDebuffs = {}
    hud.debuffsOnSelf = {}
    hud.activeDebuffsOnSelf = {}
    hud.buffsOnParty = {}
    hud.activeBuffsOnParty = {}
    hud.hasActiveBuffsOnParty = false
    hud.otherTanksInGroup = 0
    hud.otherHealersInGroup = 0
    hud.otherDPSsInGroup = 0
    hud.lastParseParty = 0
    hud.isInGroup = false
    hud.groupMembersExcludingSelf = 0
    hud.bagItems = {}
    hud.loc = {}

    -- display

    local mainFrame = CreateFrame("Frame", nil, UIParent, "ERAHUDFrame")
    ---@cast mainFrame Frame
    hud.mainFrame = mainFrame
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", hud.offsetX, hud.offsetY)

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
    hud.wasCasting = false

    hud.channelInfo = {}
    hud.channelTicks = {}
    hud.channelTicksCount = 0

    -- content

    hud.maxRotationInRow = 4
    hud.maxRotationInHealerColumn = 5

    hud.SAO = {}
    hud.activeSAO = {}
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
    hud.emptyUtility = {}
    hud.modules = {}
    hud.activeModules = {}

    hud.targetCastBar = ERAHUDTargetCastBar:create(hud)

    -- status

    hud.healthHeight = 22
    hud.petHeight = 11
    hud.statusSpacing = 2
    local statusY = hud.statusBaseY
    hud.health = {
        maxHealth = 1,
        currentHealth = 0,
        absorb = 0,
        healAbsorb = 0,
        bar = ERAHUDStatusBar:create(mainFrame, 1004, 1004, hud.barsWidth, hud.healthHeight, 0.0, 1.0, 0.0)
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
        bar = ERAHUDStatusBar:create(mainFrame, 1004, 1004, hud.barsWidth, hud.petHeight, 0.0, 1.0, 0.0)
    }
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

    mainFrame:Hide()

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
    local tickStart
    if self.isHealer then
        tickStart = ERAHUD_TimerBarSpacing
    else
        tickStart = -ERAHUD_TimerBarSpacing
    end
    for i = 0, ERAHUD_TimerGCDCount do
        local line = self.timerFrameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDVerticalTick")
        local x = 0 - i * (ERAHUD_TimerWidth / ERAHUD_TimerGCDCount)
        line:SetStartPoint("RIGHT", self.timerFrameOverlay, x, tickStart)
        line:SetEndPoint("RIGHT", self.timerFrameOverlay, x, 0)
        table.insert(self.gcdTicks, line)
    end

    self.castLine = self.timerFrameOverlay:CreateLine(nil, "OVERLAY", "ERAHUDCastLine")
    self.castLine:Hide()

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
        self:AddAuraBar(paradoxTimer, nil, 1.0, 0.9, 0.7)
        local innervTimer = self:AddTrackedBuffAnyCaster(29166)
        self:AddAuraBar(innervTimer, nil, 0.0, 0.0, 0.7)
    end
    self:AddAuraBar(self:AddTrackedBuff(435493), nil, 0.5, 0.0, 0.2) -- antidote trinket

    -- warlock health stone
    self:AddBagItemIcon(self:AddBagItemCooldown(5512, self.healthstoneTalent), self.healGroup, 538745, nil, ERACombatFrames_classID == 9)
    --warlock portal
    local portalDebuff = self:AddTrackedDebuffOnSelf(113942, true)
    portalDebuff.updateUtilityLayoutIfChanged = true
    self:AddExternalTimerIcon(portalDebuff, self.movementGroup, 607512)

    --#region racial

    local _, _, r = UnitRace("player")
    local racialSpellID = nil
    local racialGroup = nil
    local racialTimer = false
    if (r == 1 or r == 33) then
        -- human
        racialSpellID = 59752
        racialGroup = self.movementGroup
    elseif (r == 2) then
        -- orc
        racialGroup = self.powerUpGroup
        racialTimer = true
        --#region by class
        if ERACombatFrames_classID == 1 or ERACombatFrames_classID == 3 or ERACombatFrames_classID == 4 or ERACombatFrames_classID == 6 then
            -- warrior, hunter, rogue, dk
            racialSpellID = 20572
        elseif ERACombatFrames_classID == 7 or ERACombatFrames_classID == 10 then
            -- shaman, monk
            racialSpellID = 33697
        elseif ERACombatFrames_classID == 5 or ERACombatFrames_classID == 8 or ERACombatFrames_classID == 9 then
            -- priest, mage, warlock
            racialSpellID = 33702
        end
        --#endregion
    elseif (r == 3) then
        -- dwarf
        self:AddUtilityDispell(self:AddTrackedCooldown(20594), self.defenseGroup, nil, nil, nil, true, true, true, true, true).alwaysShow = true
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
        racialTimer = true
    elseif (r == 9) then
        -- goblin
        racialSpellID = 69070
        racialGroup = self.movementGroup
    elseif (r == 10) then
        -- blood elf
        racialGroup = self.specialGroup
        --#region by class
        if ERACombatFrames_classID == 1 then
            -- warrior
            racialSpellID = 69179
        elseif ERACombatFrames_classID == 2 then
            -- paladin
            racialSpellID = 155145
        elseif ERACombatFrames_classID == 3 then
            -- hunter
            racialSpellID = 80483
        elseif ERACombatFrames_classID == 4 then
            -- rogue
            racialSpellID = 25046
        elseif ERACombatFrames_classID == 5 then
            -- priest
            racialSpellID = 232633
        elseif ERACombatFrames_classID == 6 then
            -- dk
            racialSpellID = 50613
        elseif ERACombatFrames_classID == 8 or ERACombatFrames_classID == 9 then
            -- mage, warlock
            racialSpellID = 28730
        elseif ERACombatFrames_classID == 10 then
            -- monk
            racialSpellID = 129597
        elseif ERACombatFrames_classID == 12 then
            -- dh
            racialSpellID = 202719
        end
        --#endregion
    elseif (r == 11) then
        -- draenei
        racialGroup = self.healGroup
        --#region by class
        if ERACombatFrames_classID == 1 then
            -- warrior
            racialSpellID = 28880
        elseif ERACombatFrames_classID == 2 then
            -- paladin
            racialSpellID = 59542
        elseif ERACombatFrames_classID == 3 then
            -- hunter
            racialSpellID = 59543
        elseif ERACombatFrames_classID == 4 then
            -- rogue
            racialSpellID = 370626
        elseif ERACombatFrames_classID == 5 then
            -- priest
            racialSpellID = 59544
        elseif ERACombatFrames_classID == 6 then
            -- dk
            racialSpellID = 59545
        elseif ERACombatFrames_classID == 7 then
            -- shaman
            racialSpellID = 59547
        elseif ERACombatFrames_classID == 8 then
            -- mage
            racialSpellID = 59548
        elseif ERACombatFrames_classID == 9 then
            -- warlock
            racialSpellID = 416250
        elseif ERACombatFrames_classID == 10 then
            -- monk
            racialSpellID = 121093
        end
        --#endregion
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
        racialTimer = true
    elseif (r == 31) then
        -- zandalari
        racialSpellID = 291944
        racialGroup = self.healGroup
    elseif (r == 32) then
        -- kul tiran
        racialSpellID = 287712
        racialGroup = self.controlGroup
    elseif (r == 34) then
        -- dark iron dwarf
        self:AddUtilityDispell(self:AddTrackedCooldown(265221), self.powerUpGroup, nil, nil, nil, true, true, true, true, true, true).alwaysShow = true
    elseif (r == 35) then
        -- vulpera
        racialSpellID = 312411
        racialGroup = self.powerUpGroup
        racialTimer = true
    elseif (r == 36) then
        -- mag'har
        racialSpellID = 274738
        racialGroup = self.powerUpGroup
        racialTimer = true
    elseif (r == 37) then
        -- mechagnome
        racialSpellID = 312924
        racialGroup = self.specialGroup
    elseif (r == 52 or r == 70) then
        -- dracthyr
        if ERACombatFrames_classID ~= 13 then
            -- tail swipe 368970
            racialSpellID = 357214
            racialGroup = self.controlGroup
            racialTimer = true
        end
    elseif (r == 84 or r == 85) then
        -- earthen
        racialSpellID = 436344
        racialGroup = self.controlGroup
    end
    if (racialSpellID and racialGroup) then
        self:AddUtilityCooldown(self:AddTrackedCooldown(racialSpellID), racialGroup, nil, nil, nil, racialTimer)
    end

    --#endregion

    -- equipment
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_TRINKET1), self.powerUpGroup, 465875, nil, true)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_TRINKET2), self.powerUpGroup, 3610503, nil, true)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_BACK), self.specialGroup, 530999, nil, false)
    self:AddEquipmentIcon(self:AddEquipmentCooldown(INVSLOT_WAIST), self.specialGroup, 443322, nil, false)

    --#endregion

    for _, ti in ipairs(self.timerItems) do
        ti:constructOverlay(self.timerFrameOverlay)
    end
    for _, n in ipairs(self.nested) do
        n:createOverlay(self.timerFrameOverlay)
    end

    self.timerFrame:Hide()
end

---@return number, number
function ERAHUD:GetAvailableRectangleInCenter()
    return 2 * math.min(-self.offsetX - ERAHUD_TimerIconSize, self.UtilityMinRightX), 2 * (-self.UtilityMinBottomY - self.offsetY)
end

--#endregion

--#region MECHANICS

function ERAHUD:EnterCombat()
    self.timerFrame:Show()
    self.health.bar:show()
    if self.petHealthTalent:PlayerHasTalent() then
        self.petHealth.bar:show()
    end
    if self.showUtility then
        for _, g in ipairs(self.utilityGroups) do
            g:showIfHasContent()
        end
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
    for _, n in ipairs(self.nested) do
        n:ResetToIdle()
    end
    self.mainFrame:Show()
end

function ERAHUD:SpecInactive(wasActive)
    if (wasActive) then
        self.mainFrame:Hide()
        self.mainFrame:UnregisterAllEvents()
        for _, n in ipairs(self.nested) do
            n:SpecInactive()
        end
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
    self.hasBuffsAnyCaster = false
    for _, a in ipairs(self.buffs) do
        if a.talentActive then
            if a.acceptAnyCaster then
                self.hasBuffsAnyCaster = true
            end
            self.activeBuffs[a.spellID] = a
        end
    end

    self.hasActiveBuffsOnPet = false
    table.wipe(self.activeBuffsOnPet)
    for _, a in ipairs(self.buffsOnPet) do
        if a.talentActive then
            self.hasActiveBuffsOnPet = true
            self.activeBuffsOnPet[a.spellID] = a
        end
    end

    table.wipe(self.activeDebuffs)
    for _, a in ipairs(self.debuffs) do
        if a.talentActive then
            self.activeDebuffs[a.spellID] = a
        end
    end

    table.wipe(self.activeDebuffsOnSelf)
    self.hasDebuffsAnyCaster = false
    for _, a in ipairs(self.debuffsOnSelf) do
        if a.talentActive then
            if a.acceptAnyCaster then
                self.hasDebuffsAnyCaster = true
            end
            self.activeDebuffsOnSelf[a.spellID] = a
        end
    end

    self.hasActiveBuffsOnParty = false
    for _, a in ipairs(self.buffsOnParty) do
        if a.talentActive then
            self.hasActiveBuffsOnParty = true
            for _, auraItem in ipairs(a.activeAuras) do
                self.activeBuffsOnParty[auraItem.spellID] = a
            end
        end
    end

    table.wipe(self.activeSAO)
    for _, s in ipairs(self.SAO) do
        if s:checkTalentOrHide() then
            table.insert(self.activeSAO, s)
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
    if self.petHealth then
        self.petHealth.bar:checkTalents()
    end
    table.wipe(self.activeModules)
    for _, m in ipairs(self.modules) do
        if m:checkTalent() then
            table.insert(self.activeModules, m)
        end
    end

    table.wipe(self.activeNested)
    for _, n in ipairs(self.nested) do
        if n.talent and not n.talent:PlayerHasTalent() then
            n:hide()
        else
            n:show()
            table.insert(self.activeNested, n)
            n:checkTalents()
        end
    end

    self:drawStatusAndRotation()

    self:updateUtilityLayout()
end

function ERAHUD:drawStatusAndRotation()
    self.health.bar:checkTalents()
    local statusY
    if self.isHealer then
        statusY = self.statusBaseY
        for _, m in ipairs(self.activeModules) do
            if m.occupySpace and not m.placeAtBottomIfHealer then
                m:place(self.statusBaseX, statusY, self.mainFrame)
                statusY = statusY - m.height - self.statusSpacing
            end
        end
        self.health.bar:place(self.statusBaseX, statusY, self.healthHeight, self.mainFrame)
        statusY = self:placePet(statusY - self.healthHeight - self.statusSpacing)
        for _, m in ipairs(self.activeModules) do
            if m.occupySpace and m.placeAtBottomIfHealer then
                m:place(self.statusBaseX, statusY, self.mainFrame)
                statusY = statusY - m.height - self.statusSpacing
            end
        end
    else
        self.health.bar:place(self.statusBaseX, self.statusBaseY, self.healthHeight, self.mainFrame)
        statusY = self:placePet(self.statusBaseY - self.healthHeight - self.statusSpacing)
        for _, m in ipairs(self.activeModules) do
            if m.occupySpace then
                m:place(self.statusBaseX, statusY, self.mainFrame)
                statusY = statusY - m.height - self.statusSpacing
            end
        end
    end
    self.statusMaxY = statusY

    local iconSpace = ERAHUD_RotationIconSize + ERAHUD_RotationIconSpacing

    local maxSpecial = 4
    local xSpecial = -self.offsetX
    local ySpecial = -self.offsetY
    local largeSpecial = true
    local countSpecial = 0
    for index, i in ipairs(self.activeRotation) do
        if i.specialPosition then
            i.icon:Draw(xSpecial, ySpecial, false)
            if index < #(self.activeRotation) and self.activeRotation[index + 1].overlapsPrevious ~= i then
                countSpecial = countSpecial + 1
                local newColumn
                if largeSpecial then
                    if countSpecial >= maxSpecial then
                        largeSpecial = false
                        ySpecial = -self.offsetY + iconSpace / 2
                        newColumn = true
                    else
                        newColumn = false
                    end
                else
                    if countSpecial + 1 >= maxSpecial then
                        largeSpecial = true
                        ySpecial = -self.offsetY
                        newColumn = true
                    else
                        newColumn = false
                    end
                end
                if newColumn then
                    countSpecial = 0
                    xSpecial = xSpecial + iconSpace * ERAHUD_IconDeltaDiagonal
                else
                    ySpecial = ySpecial + iconSpace
                end
            end
        end
    end

    if self.isHealer then
        --#region HEALER ICONS

        local xRotation = 1.5 * ERAHUD_TimerIconSize + ERAHUD_RotationIconSize / 2
        local yRotation = ERAHUD_RotationHealerY
        local largeColumn = true
        local countInColumn = 0
        for index, i in ipairs(self.activeRotation) do
            if not i.specialPosition then
                i.icon:Draw(xRotation, yRotation, false)
                if index < #(self.activeRotation) and self.activeRotation[index + 1].overlapsPrevious ~= i then
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
        end

        --#endregion
    else
        --#region NON-HEALER ICONS

        local xRotationInit = -ERAHUD_TimerIconSize - ERAHUD_RotationIconSize / 2
        local xRotation = xRotationInit
        local yRotation = statusY - ERAHUD_RotationIconSize / 2
        local largeRow = true
        local countInRow = 0
        for index, i in ipairs(self.activeRotation) do
            if not i.specialPosition then
                i.icon:Draw(xRotation, yRotation, false)
                if index < #(self.activeRotation) and self.activeRotation[index + 1].overlapsPrevious ~= i then
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
                        yRotation = yRotation - iconSpace * ERAHUD_IconDeltaDiagonal
                    else
                        xRotation = xRotation - iconSpace
                    end
                end
            end
        end

        --#endregion
    end
end

---@param statusY number
---@return number
function ERAHUD:placePet(statusY)
    if self.petHealthTalent:PlayerHasTalent() then
        self.petHealth.bar:place(self.statusBaseX, statusY, self.petHeight, self.mainFrame)
        self.petHealth.bar:checkTalents()
        statusY = statusY - self.petHeight - self.statusSpacing
    else
        self.petHealth.bar:hide()
    end
    return statusY
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

    self:updateHealthStatusIdle(self.health, t, false)
    if self.petHealthTalent:PlayerHasTalent() then
        self:updateHealthStatusIdle(self.petHealth, t, true)
    end

    for _, sao in ipairs(self.activeSAO) do
        sao:update(t, false)
    end

    self:updateIcons(t, false)

    self:updateResourceDisplay(t, false)

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

    local timersY = 0
    for _, b in ipairs(self.visibleBars) do
        local height = b:draw(timersY)
        if self.topdown then
            timersY = timersY - height - ERAHUD_TimerBarSpacing
        else
            timersY = timersY + height + ERAHUD_TimerBarSpacing
        end
    end
    if timersY == 0 then
        if self.topdown then
            timersY = -ERAHUD_TimerBarDefaultSize - ERAHUD_TimerBarSpacing
        else
            timersY = ERAHUD_TimerBarDefaultSize + ERAHUD_TimerBarSpacing
        end
    end

    --#endregion

    --#region NESTED

    local nestedY = timersY
    for _, n in ipairs(self.activeNested) do
        local nh = n:updateDisplay_returnHeight(t, nestedY, self.timerFrame, self.timerFrameOverlay)
        nestedY = nestedY + nh
        if n.includeInTimer then
            timersY = timersY + nh
        end
    end

    --#endregion

    --#region TIMER OVERLAY

    if self.timerMaxY ~= timersY then
        self.timerMaxY = timersY
        for i, g in ipairs(self.gcdTicks) do
            local x = 0 - (i - 1) * (ERAHUD_TimerWidth / ERAHUD_TimerGCDCount)
            g:SetEndPoint("RIGHT", self.timerFrameOverlay, x, timersY)
        end
    end

    if self.remGCD > 0 then
        if self.castingSpellID and self.castingSpellID > 0 then
            if not self.wasCasting then
                self.wasCasting = true
                self.gcdBar:SetVertexColor(1.0, 0.5, 0.0)
            end
        else
            if self.wasCasting then
                self.wasCasting = false
                self.gcdBar:SetVertexColor(1.0, 1.0, 1.0)
            end
        end
        if not self.gcdVisible then
            self.gcdVisible = true
            self.gcdBar:Show()
        end
        if (self.topdown) then
            self.gcdBar:SetPoint("BOTTOMLEFT", self.timerFrameOverlay, "RIGHT", self:calcTimerPixel(self.remGCD), timersY)
        else
            self.gcdBar:SetPoint("TOPLEFT", self.timerFrameOverlay, "RIGHT", self:calcTimerPixel(self.remGCD), timersY)
        end
    else
        if self.gcdVisible then
            self.gcdVisible = false
            self.gcdBar:Hide()
        end
    end

    if self.remCast > 0 then
        local castX = self:calcTimerPixel(self.remCast)
        local castY
        if self.topdown then
            castY = timersY - ERAHUD_TimerBarSpacing
            self.castBar:SetPoint("BOTTOMLEFT", self.timerFrame, "RIGHT", castX, castY)
            self.castBackground:SetPoint("BOTTOMLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.totCast), castY)
            self.castLine:SetStartPoint("RIGHT", self.timerFrameOverlay, castX, ERAHUD_TimerIconSize)
        else
            castY = timersY + ERAHUD_TimerBarSpacing
            self.castBar:SetPoint("TOPLEFT", self.timerFrame, "RIGHT", castX, castY)
            self.castBackground:SetPoint("TOPLEFT", self.timerFrame, "RIGHT", self:calcTimerPixel(self.totCast), castY)
            self.castLine:SetStartPoint("RIGHT", self.timerFrameOverlay, castX, -ERAHUD_TimerIconSize)
        end
        self.castLine:SetEndPoint("RIGHT", self.timerFrameOverlay, castX, castY)
        if not self.castVisible then
            self.castVisible = true
            self.castBar:Show()
            self.castLine:Show()
            self.castBackground:Show()
        end
    else
        if self.castVisible then
            self.castVisible = false
            self.castBar:Hide()
            self.castLine:Hide()
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
                if self.topdown then
                    tickLine:SetStartPoint("RIGHT", self.timerFrameOverlay, x, ERAHUD_TimerIconSize)
                else
                    tickLine:SetStartPoint("RIGHT", self.timerFrameOverlay, x, -ERAHUD_TimerIconSize)
                end
                tickLine:SetEndPoint("RIGHT", self.timerFrameOverlay, x, timersY)
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
            lvl:drawOrHideIfUnused(self.timerFrameOverlay, timersY)
        end
    else
        for _, lvl in ipairs(self.empowerLevels) do
            lvl:hide()
        end
    end

    for _, m in ipairs(self.activeMarkers) do
        m:update(timersY, t, self.timerFrameOverlay)
    end

    --#endregion

    --#region STATUS

    self:updateHealthStatus(self.health, t)
    if self.petHealthTalent:PlayerHasTalent() then
        self:updateHealthStatus(self.petHealth, t)
    end

    --#endregion

    for _, sao in ipairs(self.activeSAO) do
        sao:update(t, true)
    end

    self:updateIcons(t, true)

    --#region ROTATION

    for _, r in ipairs(self.activeRotation) do
        r:update(t, true)
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
        ti:drawOnTimer(y, timersY, self.timerFrameOverlay)
        prvTI = ti
    end

    table.sort(self.availablePriority, ERAHUDTimerItem_comparePriority)
    local yPrio
    if self.topdown then
        yPrio = 1.5 * ERAHUD_TimerIconSize
    else
        yPrio = -1.5 * ERAHUD_TimerIconSize
    end
    for _, ti in ipairs(self.availablePriority) do
        ti:drawPriority(yPrio)
        if self.topdown then
            yPrio = yPrio + ERAHUD_TimerIconSize
        else
            yPrio = yPrio - ERAHUD_TimerIconSize
        end
    end

    --#endregion

    self:updateResourceDisplay(t, true)

    self:DisplayUpdatedOverride(t, true)

    self:updateUtilityLayoutIfNecessary()
end

---@param t number
---@param combat boolean
function ERAHUD:updateIcons(t, combat)
    for _, r in ipairs(self.activeRotation) do
        r:update(t, combat)
    end
    for _, i in ipairs(self.activeUtilityIcons) do
        i:update(t, combat)
    end
end

---@param t number
---@param combat boolean
function ERAHUD:updateResourceDisplay(t, combat)
    local changed = false
    for _, m in ipairs(self.activeModules) do
        if m:updateDisplay_return_visibleChanged(t, combat) then
            changed = true
        end
    end
    if changed then
        self:drawStatusAndRotation()
    end
end

---@param h ERAHUDHealth
---@param t number
---@param checkPetMounted boolean
function ERAHUD:updateHealthStatusIdle(h, t, checkPetMounted)
    if h.currentHealth >= h.maxHealth then
        h.bar:hide()
    else
        if checkPetMounted and (not self.hasPet) and IsMounted() then
            h.bar:hide()
        else
            self:updateHealthStatus(h, t)
            h.bar:show()
        end
    end
end
---@param h ERAHUDHealth
---@param t number
function ERAHUD:updateHealthStatus(h, t)
    h.bar:SetAllExceptForecast(h.maxHealth, h.currentHealth, h.healAbsorb, h.absorb)
    h.bar:updateMarkings(t)
end

---@param t number
---@param combat boolean
function ERAHUD:PreUpdateDisplayOverride(t, combat)
end
---@param t number
---@param combat boolean
function ERAHUD:DisplayUpdatedOverride(t, combat)
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
            self.hasPet = true
        else
            self.petHealth.absorb = 0
            self.petHealth.healAbsorb = 0
            self.petHealth.currentHealth = 0
            self.petHealth.maxHealth = 1
            self.hasPet = false
        end
    else
        self.hasPet = UnitExists("pet")
    end

    --#endregion

    --#region BUFF / DEBUFF

    local i = 1
    if self.hasDebuffsAnyCaster then
        while true do
            local auraInfo = C_UnitAuras.GetDebuffDataByIndex("target", i)
            if (auraInfo) then
                local a = self.activeDebuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo, false, i, "target", nil)
                end
                i = i + 1
            else
                break
            end
        end
    else
        while true do
            local auraInfo = C_UnitAuras.GetDebuffDataByIndex("target", i, "PLAYER")
            if (auraInfo) then
                local a = self.activeDebuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo, true, i, "target", "PLAYER")
                end
                i = i + 1
            else
                break
            end
        end
    end
    i = 1
    if self.hasBuffsAnyCaster then
        while true do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("player", i)
            if (auraInfo) then
                local a = self.activeBuffs[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo, false, i, "player", nil)
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
                    a:auraFound(t, auraInfo, true, i, "player", "PLAYER")
                end
                i = i + 1
            else
                break
            end
        end
    end
    if self.hasActiveBuffsOnPet then
        i = 1
        while true do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("pet", i)
            if (auraInfo) then
                local a = self.activeBuffsOnPet[auraInfo.spellId]
                if (a ~= nil) then
                    a:auraFound(t, auraInfo, true, i, "pet", nil)
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
                a:auraFound(t, auraInfo, true, i, "player", nil)
            end
            i = i + 1
        else
            break
        end
    end

    local friendsCount = GetNumGroupMembers()
    if self.hasActiveBuffsOnParty then
        if t - self.lastParseParty < 2 then
            for _, v in pairs(self.activeBuffsOnParty) do
                v:notChecked()
            end
        else
            self.lastParseParty = t
            self.otherTanksInGroup = 0
            self.otherHealersInGroup = 0
            self.otherDPSsInGroup = 0
            local cpt = 0
            for _, v in pairs(self.activeBuffsOnParty) do
                v:parsingParty()
            end
            if friendsCount and friendsCount > 0 then
                local prefix
                if (IsInRaid()) then
                    prefix = "raid"
                else
                    prefix = "party"
                end
                for f = 1, friendsCount do
                    local unit = prefix .. f
                    if (not UnitIsUnit("player", unit)) and (not UnitIsDead(unit)) and UnitInRange(unit) then
                        cpt = cpt + 1
                        local role = UnitGroupRolesAssigned(unit)
                        if (role == "TANK") then
                            self.otherTanksInGroup = self.otherTanksInGroup + 1
                        elseif (role == "HEALER") then
                            self.otherHealersInGroup = self.otherHealersInGroup + 1
                        else
                            self.otherDPSsInGroup = self.otherDPSsInGroup + 1
                        end
                        i = 1
                        while true do
                            local auraInfo = C_UnitAuras.GetBuffDataByIndex(unit, i)
                            if (auraInfo) then
                                local a = self.activeBuffsOnParty[auraInfo.spellId]
                                if (a ~= nil) then
                                    a:auraFound(t, auraInfo)
                                end
                                i = i + 1
                            else
                                break
                            end
                        end
                        for _, v in pairs(self.activeBuffsOnParty) do
                            v:memberParsed()
                        end
                    end
                end
            end
            if cpt > 0 then
                self.groupMembersExcludingSelf = cpt
                self.isInGroup = true
            else
                self.groupMembersExcludingSelf = 0
                self.isInGroup = false
            end
            for _, v in pairs(self.activeBuffsOnParty) do
                v:partyParsed(cpt, t)
            end
        end
    else
        if friendsCount and friendsCount > 1 then
            self.groupMembersExcludingSelf = friendsCount - 1
            self.isInGroup = true
        else
            self.groupMembersExcludingSelf = 0
            self.isInGroup = false
        end
    end

    --endregion

    --#region TARGET

    self.canAttackTarget = UnitCanAttack("player", "target")

    self.targetDispellableMagic = false
    self.targetDispellableEnrage = false
    if self.watchTargetDispellable and self.canAttackTarget then
        i = 1
        while true do
            local auraInfo = C_UnitAuras.GetBuffDataByIndex("target", i)
            if (auraInfo) then
                if (auraInfo.isStealable) then
                    self.targetDispellableMagic = true
                end
                if (auraInfo.dispelName == "Magic") then
                    self.targetDispellableMagic = true
                elseif (auraInfo.dispelName == "") then -- bug blizzard api : enrage is ""
                    self.targetDispellableEnrage = true
                end
                i = i + 1
            else
                break
            end
        end
    end

    self.targetCast = 0
    if self.canAttackTarget then
        local name, _, _, _, endTargetCastMS, _, _, notInterruptible = UnitCastingInfo("target")
        if (endTargetCastMS and endTargetCastMS > 0 and not notInterruptible) then
            self.targetCast = endTargetCastMS / 1000 - t
            if (self.targetCastBar) then
                self.targetCastBar:SetText(name)
            end
        else
            name, _, _, _, endTargetCastMS, _, notInterruptible = UnitChannelInfo("target")
            if (endTargetCastMS ~= nil and not notInterruptible) then
                if endTargetCastMS == 0 then
                    self.targetCast = 1004
                    if (self.targetCastBar) then
                        self.targetCastBar:SetText(name)
                    end
                else
                    self.targetCast = endTargetCastMS / 1000 - t
                    if (self.targetCastBar) then
                        self.targetCastBar:SetText(name)
                    end
                end
            end
        end
    end

    --endregion

    --region CAST

    self.castingSpellID = nil
    local _, _, _, startTimeMS, endCastMS, _, _, _, castingSpellID = UnitCastingInfo("player")
    if endCastMS then
        self.remCast = (endCastMS / 1000) - t
        self.totCast = (endCastMS - startTimeMS) / 1000
        self.channelingSpellID = nil
        self.castingSpellID = castingSpellID
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
            self.castingSpellID = spellID
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
                        lvl = ERAHUDEmpowerLevel:create(self, self.timerFrameOverlay, s)
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
    for _, m in ipairs(self.activeModules) do
        if m.PreUpdateDataOverride then
            m:PreUpdateDataOverride(t, combat)
        end
    end

    for _, tim in ipairs(self.activeDataItems) do
        tim:updateData(t)
    end

    for _, m in ipairs(self.activeModules) do
        m:updateData(t, combat)
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

---@param sao ERASAO
---@return Frame
function ERAHUD:addSAO(sao)
    table.insert(self.SAO, sao)
    return self.mainFrame
end

---@param b ERAHUDBar
---@return Frame
function ERAHUD:addBar(b)
    table.insert(self.bars, b)
    return self.timerFrame
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

---@param i ERAHUDMissingUtility
function ERAHUD:addEmpty(i)
    table.insert(self.emptyUtility, i)
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
---@field protected constructNested fun(this:ERAHUDNestedModule, hud:ERAHUD, includeInTimer:boolean, talent:ERALIBTalent|nil): Frame
---@field hud ERAHUD
---@field ResetToIdle fun(this:ERAHUDNestedModule)
---@field SpecInactive fun(this:ERAHUDNestedModule)
---@field hide fun(this:ERAHUDNestedModule)
---@field show fun(this:ERAHUDNestedModule)
---@field checkTalents fun(this:ERAHUDNestedModule)
---@field createOverlay fun(this:ERAHUDNestedModule, overlayFrame:Frame)
---@field updateData fun(this:ERAHUDNestedModule, t:number)
---@field updateDisplay_returnHeight fun(this:ERAHUDNestedModule, t:number, baseY:number, timerFrame:Frame, overlayFrame:Frame): number
---@field talent ERALIBTalent|nil
---@field includeInTimer boolean
ERAHUDNestedModule = {}
ERAHUDNestedModule.__index = ERAHUDNestedModule

---@param hud ERAHUD
---@param includeInTimer boolean
---@param talent ERALIBTalent|nil
---@return Frame
function ERAHUDNestedModule:constructNested(hud, includeInTimer, talent)
    self.hud = hud
    self.talent = talent
    self.includeInTimer = includeInTimer
    return hud:addNested(self)
end

function ERAHUDNestedModule:SpecInactive()
end
function ERAHUDNestedModule:ResetToIdle()
end

---@param t number
function ERAHUDNestedModule:CLEU(t)
end

function ERAHUDNestedModule:checkTalents()
end

---@param overlayFrame Frame
function ERAHUDNestedModule:createOverlay(overlayFrame)
end

--#endregion

---------------
--- UTILITY ---
---------------

--#region UTILITY

function ERAHUD:mustUpdateUtilityLayout()
    self.must_update_utility_layout = true
end

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

    ---@type number, number
    local xMissing, yOutOfCombat

    if self.isHealer then
        yOutOfCombat = -ERAHUD_UtilityIconSize / 2
        --#region HEALER LAYOUT

        local x = ERAHUD_TimerIconSize
        local y = math.min(self.statusMaxY, self.UtilityMinBottomY)
        if self.healGroup.width > 0 and self.healGroup.height > 0 then
            self.healGroup:arrange(x, y, self.mainFrame)
            x = x + self.healGroup.width + ERAHUD_UtilityGoupSpacing
        end
        if self.powerUpGroup.width > 0 and self.powerUpGroup.height > 0 then
            self.powerUpGroup:arrange(x, y, self.mainFrame)
            x = x + self.powerUpGroup.width + ERAHUD_UtilityGoupSpacing
        end
        if self.defenseGroup.width > 0 and self.defenseGroup.height > 0 then
            self.defenseGroup:arrange(x, y, self.mainFrame)
            x = x + self.defenseGroup.width + ERAHUD_UtilityGoupSpacing
        end
        if self.specialGroup.width > 0 and self.specialGroup.height > 0 then
            self.specialGroup:arrange(x, y, self.mainFrame)
        end
        local xBottom = x + self.specialGroup.width
        if x < self.UtilityMinRightX - self.offsetX then
            x = self.UtilityMinRightX - self.offsetX
        end
        if self.controlGroup.width > 0 and self.controlGroup.height > 0 then
            y = y + self.controlGroup.height + ERAHUD_UtilityGoupSpacing
            self.controlGroup:arrange(x, y, self.mainFrame)
        end
        if self.movementGroup.width > 0 and self.movementGroup.height > 0 then
            self.movementGroup:arrange(x, y + self.movementGroup.height + ERAHUD_UtilityGoupSpacing, self.mainFrame)
        end

        xMissing = math.max(xBottom, x + math.max(self.controlGroup.width, self.movementGroup.width))

        --#endregion
    else
        yOutOfCombat = ERAHUD_UtilityIconSize / 2
        --#region NON-HEALER LAYOUT

        if self.healGroup.width > 0 and self.healGroup.height > 0 then
            local xMax = -ERAHUD_TimerIconSize - self.maxRotationInRow * (ERAHUD_RotationIconSize + ERAHUD_RotationIconSpacing)
            self.healGroup:arrange(xMax - self.healGroup.width, self.statusBaseY, self.mainFrame)
        end

        local xBottom = self.statusBaseX + self.barsWidth / 2 + ERAHUD_RotationIconSize
        local y = self.offsetY + self.UtilityMinBottomY
        if self.powerUpGroup.width > 0 and self.powerUpGroup.height > 0 then
            self.powerUpGroup:arrange(xBottom, y, self.mainFrame)
            xBottom = xBottom + self.powerUpGroup.width + ERAHUD_UtilityGoupSpacing
        end
        if self.defenseGroup.width > 0 and self.defenseGroup.height > 0 then
            self.defenseGroup:arrange(xBottom, y, self.mainFrame)
            xBottom = xBottom + self.defenseGroup.width + ERAHUD_UtilityGoupSpacing
        end
        local xRight
        if xBottom < self.UtilityMinRightX - self.offsetX then
            xRight = self.UtilityMinRightX - self.offsetX
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

        xMissing = math.max(xBottom + self.specialGroup.width, xRight + math.max(self.controlGroup.width, self.movementGroup.width))

        --#endregion
    end

    local utilityIconSize = ERAHUD_UtilityIconSize + ERAHUD_UtilityIconSpacing

    --#region out of combat

    local xOutOfCombat = -ERAHUD_UtilityIconSize
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
                yOutOfCombat = yOutOfCombat + utilityIconSize * ERAHUD_IconDeltaDiagonal
            else
                xOutOfCombat = xOutOfCombat - utilityIconSize
            end
        end
    end

    --#endregion

    --#region missing

    xMissing = xMissing + ERAHUD_UtilityGoupSpacing + ERAHUD_UtilityIconSize / 2
    local yMissing = self.UtilityMinBottomY
    local largeColumn = true
    count = 0
    for _, i in ipairs(self.emptyUtility) do
        if i.talentActive then
            i.icon:Draw(xMissing, yMissing, false)
            count = count + 1
            local newColumn
            if largeColumn then
                if count >= 5 then
                    yMissing = self.UtilityMinBottomY + utilityIconSize / 2
                    largeColumn = false
                    newColumn = true
                else
                    newColumn = false
                end
            else
                if count >= 4 then
                    yMissing = self.UtilityMinBottomY
                    largeColumn = true
                    newColumn = true
                else
                    newColumn = false
                end
            end
            if newColumn then
                count = 0
                xMissing = xMissing + utilityIconSize * ERAHUD_IconDeltaDiagonal
            else
                yMissing = yMissing + utilityIconSize
            end
        end
    end

    --#endregion

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
    if givenDisplayOrder ~= nil then
        table.insert(self.icons, i)
        return givenDisplayOrder
    else
        local maxDisplay = 0
        for _, existing in ipairs(self.icons) do
            ---@cast existing ERAHUDUtilityIconInGroup
            if existing.displayOrder > maxDisplay then
                maxDisplay = existing.displayOrder
            end
        end
        table.insert(self.icons, i)
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
            rowCount = 2
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
            self.height = iconSpace * (1 + ERAHUD_IconDeltaDiagonal * (rowCount - 1)) + 2 * borderAndPadding
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
                if self.aligned then
                    y = y - iconSpace
                else
                    y = y - iconSpace * ERAHUD_IconDeltaDiagonal
                end
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
---@field private hide fun(this:ERAHUDResourceModule)
---@field private show fun(this:ERAHUDResourceModule)
---@field private visible boolean
---@field occupySpace boolean
---@field height number
---@field PreUpdateDataOverride nil|fun(this:ERAHUDResourceModule, t:number, combat:boolean)
---@field updateData fun(this:ERAHUDResourceModule, t:number, combat:boolean)
---@field UpdateDisplayReturnVisibility fun(this:ERAHUDResourceModule, t:number, combat:boolean): nil|boolean
---@field hud ERAHUD
---@field placeAtBottomIfHealer boolean
---@field IsVisibleOverride nil|fun(this:ERAHUDResourceModule): boolean
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
    self.occupySpace = true
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

---@return boolean
function ERAHUDResourceModule:checkTalent()
    if (self.talent and not self.talent:PlayerHasTalent()) or not self:checkTalentOverride() then
        self:hide()
        return false
    else
        return true
    end
end

---@param t number
---@param combat boolean
---@return boolean
function ERAHUDResourceModule:updateDisplay_return_visibleChanged(t, combat)
    local visibility = self:UpdateDisplayReturnVisibility(t, combat)
    if visibility == false then
        self:hide()
        if self.occupySpace then
            self.occupySpace = false
            return true
        else
            return false
        end
    else
        if visibility then
            self:show()
        else
            self:hide()
        end
        if self.occupySpace then
            return false
        else
            self.occupySpace = true
            return true
        end
    end
end

---@param topX number
---@param topY number
---@param parentFrame Frame
function ERAHUDResourceModule:place(topX, topY, parentFrame)
    self.frame:SetPoint("TOP", parentFrame, "CENTER", topX, topY)
    self:show()
end

---@class (exact) ERAHUDPowerBarModule : ERAHUDResourceModule
---@field private __index unknown
---@field powerType Enum.PowerType
---@field currentPower number
---@field maxPower number
---@field bar ERAHUDStatusBar
---@field hideFullOutOfCombat boolean
---@field PreUpdatePowerOverride nil|fun(this:ERAHUDResourceModule, t:number, combat:boolean)
---@field ConfirmIsVisibleOverride nil|fun(this:ERAHUDResourceModule, t:number, combat:boolean): boolean
---@field CollapseIfTransparent nil|fun(this:ERAHUDResourceModule, t:number, combat:boolean): boolean
ERAHUDPowerBarModule = {}
ERAHUDPowerBarModule.__index = ERAHUDPowerBarModule
setmetatable(ERAHUDPowerBarModule, { __index = ERAHUDResourceModule })

---@param hud ERAHUD
---@param powerType Enum.PowerType
---@param height number
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDPowerBarModule
function ERAHUDPowerBarModule:Create(hud, powerType, height, r, g, b, talent)
    local x = {}
    setmetatable(x, ERAHUDPowerBarModule)
    ---@cast x ERAHUDPowerBarModule
    x.powerType = powerType
    x.currentPower = 0
    x.maxPower = 100
    x:constructModule(hud, height, talent)
    x.bar = ERAHUDStatusBar:create(x.frame, 0, 0, hud.barsWidth, height, r, g, b)
    x.bar:place(0, height / 2, height, x.frame)
    return x
end

---@return boolean
function ERAHUDPowerBarModule:checkTalentOverride()
    self.bar:checkTalents()
    return true
end

---@param t number
---@param combat boolean
function ERAHUDPowerBarModule:PreUpdateDataOverride(t, combat)
    self.currentPower = UnitPower("player", self.powerType)
    self.maxPower = UnitPowerMax("player", self.powerType)
    if self.PreUpdatePowerOverride then
        self:PreUpdatePowerOverride(t, combat)
    end
end

---@param t number
---@param combat boolean
function ERAHUDPowerBarModule:updateData(t, combat)
    -- fait dans PreUpdateDataOverride
end

---@param t number
---@param combat boolean
function ERAHUDPowerBarModule:UpdateDisplayReturnVisibility(t, combat)
    if (combat or (self.hideFullOutOfCombat and self.currentPower < self.maxPower) or ((not self.hideFullOutOfCombat) and self.currentPower > 0)) and ((not self.ConfirmIsVisibleOverride) or self:ConfirmIsVisibleOverride(t, combat)) then
        self.bar:SetValueAndMax(self.currentPower, self.maxPower)
        self.bar:updateMarkings(t)
        return true
    else
        if self.CollapseIfTransparent and self:CollapseIfTransparent(t, combat) then
            return false
        else
            return nil
        end
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
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuff(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.buffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuffOnPet(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.buffsOnPet, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedBuffAnyCaster(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    a.acceptAnyCaster = true
    table.insert(self.buffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuffOnTarget(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    table.insert(self.debuffs, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuffOnTargetAnyCaster(spellID, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    a.acceptAnyCaster = true
    table.insert(self.debuffs, a)
    return a
end

---@param spellID integer
---@param anyCaster boolean
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
---@return ERAAura
function ERAHUD:AddTrackedDebuffOnSelf(spellID, anyCaster, talent, ...)
    local a = ERAAura:create(self, spellID, talent, ...)
    a.acceptAnyCaster = anyCaster
    table.insert(self.debuffsOnSelf, a)
    return a
end

---@return ERATimerOr
function ERAHUD:AddSatedDebuff()
    return ERATimerOr:create(self, false,
        self:AddTrackedDebuffOnSelf(57723, true),
        self:AddTrackedDebuffOnSelf(57724, true),
        self:AddTrackedDebuffOnSelf(80354, true),
        self:AddTrackedDebuffOnSelf(288293, true),
        self:AddTrackedDebuffOnSelf(264689, true),
        self:AddTrackedDebuffOnSelf(390435, true)
    )
end

---@param talent ERALIBTalent|nil
---@param ... ERAAura
---@return ERAAuraOnAllGroupMembers
function ERAHUD:AddBuffOnAllPartyMembers(talent, ...)
    local a = ERAAuraOnAllGroupMembers:create(self, talent, ...)
    table.insert(self.buffsOnParty, a)
    return a
end

---@param talent ERALIBTalent|nil
---@param ... ERAAura
---@return ERAAuraOnFriendlyHealer
function ERAHUD:AddBuffOnFriendlyHealer(talent, ...)
    local a = ERAAuraOnFriendlyHealer:create(self, talent, ...)
    table.insert(self.buffsOnParty, a)
    return a
end

---@param spellID integer
---@param talent ERALIBTalent|nil
---@param ... ERASpellAdditionalID
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

---@param shortest boolean
---@param ... ERATimer
---@return ERATimerOr
function ERAHUD:AddOrTimer(shortest, ...)
    return ERATimerOr:create(self, shortest, ...)
end

---@param ... ERAMissingDataItem
---@return ERAAnyActive
function ERAHUD:AddAnyActive(...)
    return ERAAnyActive:create(self, ...)
end

--#endregion

--#region DISPLAY

--- SAO ---

---@param aura ERAAura
---@param minStacks integer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@return ERASAOAura
function ERAHUD:AddAuraOverlay(aura, minStacks, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent)
    return ERASAOAura:create(aura, minStacks, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, self.offsetX, self.offsetY)
end

---@param spellID integer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@return ERASAOActivation
function ERAHUD:AddOverlayBasedOnSpellActivation(spellID, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent)
    return ERASAOActivation:create(spellID, self, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, self.offsetX, self.offsetY)
end

---@param spellID integer
---@param iconID integer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@return ERASAOSpellIcon
function ERAHUD:AddOverlayBasedOnSpellIcon(spellID, iconID, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent)
    return ERASAOSpellIcon:create(spellID, iconID, self, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, self.offsetX, self.offsetY)
end

---@param timer ERATimer
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@return ERASAOTimer
function ERAHUD:AddTimerOverlay(timer, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent)
    return ERASAOTimer:create(timer, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, self.offsetX, self.offsetY)
end

---@param miss ERAMissingDataItem
---@param onlyIfHasTarget boolean
---@param texture string|integer
---@param isAtlas boolean
---@param position ERASAOPosition
---@param flipH boolean
---@param flipV boolean
---@param rotateLeft boolean
---@param rotateRight boolean
---@param talent ERALIBTalent|nil
---@return ERASAOMissingTimer
function ERAHUD:AddMissingOverlay(miss, onlyIfHasTarget, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent)
    return ERASAOMissingTimer:create(miss, onlyIfHasTarget, texture, isAtlas, position, flipH, flipV, rotateLeft, rotateRight, talent, self.offsetX, self.offsetY)
end

--- rotation ---

---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDTimerMarker
function ERAHUD:AddMarker(r, g, b, talent)
    local m = ERAHUDTimerMarker:create(self, r, g, b, talent)
    table.insert(self.markers, m)
    return m
end

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

---@param aura ERAAura
---@param iconID integer|nil
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDAuraBar
function ERAHUD:AddAuraBar(aura, iconID, r, g, b, talent)
    return ERAHUDAuraBar:create(aura, iconID, r, g, b, talent)
end

---@param timer ERATimer
---@param iconID integer
---@param r number
---@param g number
---@param b number
---@param talent ERALIBTalent|nil
---@return ERAHUDGenericBar
function ERAHUD:AddGenericBar(timer, iconID, r, g, b, talent)
    return ERAHUDGenericBar:create(timer, iconID, r, g, b, talent)
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
---@param highlightAt integer
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDRotationStacksIcon
function ERAHUD:AddRotationStacks(data, maxStacks, highlightAt, iconID, talent)
    return ERAHUDRotationStacksIcon:create(data, maxStacks, highlightAt, iconID, talent)
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
---@param showOnTimer boolean|nil|fun(cd:ERACooldownBase, t:number): boolean
---@return ERAHUDUtilityCooldownInGroup
function ERAHUD:AddUtilityCooldown(data, group, iconID, displayOrder, talent, showOnTimer)
    return ERAHUDUtilityCooldownInGroup:create(group, data, iconID, displayOrder, talent, showOnTimer)
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
---@param showOnTimer nil|boolean|fun(cd:ERACooldownBase, t:number): boolean
---@return ERAHUDUtilityDispellInGroup
function ERAHUD:AddUtilityDispell(data, group, iconID, displayOrder, talent, magic, poison, disease, curse, bleed, showOnTimer)
    return ERAHUDUtilityDispellInGroup:create(group, data, iconID, displayOrder, talent, magic, poison, disease, curse, bleed, showOnTimer)
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
---@param showOnTimer boolean
---@return ERAHUDUtilityEquipmentInGroup
function ERAHUD:AddEquipmentIcon(timer, group, iconID, displayOrder, showOnTimer)
    return ERAHUDUtilityEquipmentInGroup:create(group, timer, iconID, displayOrder, showOnTimer)
end

---@param timer ERACooldownBagItem
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param warningIfMissing boolean
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityBagItemInGroup
function ERAHUD:AddBagItemIcon(timer, group, iconID, displayOrder, warningIfMissing, talent)
    return ERAHUDUtilityBagItemInGroup:create(group, timer, iconID, displayOrder, warningIfMissing, talent)
end

---@param timer ERATimer
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityExternalTimerInGroup
function ERAHUD:AddExternalTimerIcon(timer, group, iconID, displayOrder, talent)
    return ERAHUDUtilityExternalTimerInGroup:create(group, timer, iconID, displayOrder, talent)
end

---@param aura ERAAura
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityAuraOutOfCombat
function ERAHUD:AddUtilityAuraOutOfCombat(aura, iconID, talent)
    return ERAHUDUtilityAuraOutOfCombat:create(aura, iconID, talent)
end

---@param miss ERAMissingDataItem
---@param fadeAfterSeconds number
---@param repeatAfterSeconds number
---@param iconID integer
---@param talent ERALIBTalent|nil
---@return ERAHUDMissingUtility
function ERAHUD:AddMissingUtility(miss, fadeAfterSeconds, repeatAfterSeconds, iconID, talent)
    return ERAHUDMissingUtility:create(miss, fadeAfterSeconds, repeatAfterSeconds, iconID, talent)
end

---@param timer ERATimer
---@param group ERAHUDUtilityGroup
---@param iconID integer
---@param displayOrder number|nil
---@param talent ERALIBTalent|nil
---@return ERAHUDUtilityGenericTimerInGroup
function ERAHUD:AddGenericTimer(timer, group, iconID, displayOrder, talent)
    return ERAHUDUtilityGenericTimerInGroup:create(group, timer, iconID, displayOrder, talent)
end

--#endregion

--#endregion

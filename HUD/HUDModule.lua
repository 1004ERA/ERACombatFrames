ERA_HUDModule_TimerHeight = 1004

--------------------------------------------------------------------------------------------------------------------------------
--#region CSTR -----------------------------------------------------------------------------------------------------------------

---@class (exact) HUDModule : ERACombatModule
---@field private __index HUDModule
---@field options ERACombatSpecOptions
---@field private rootFrames Frame[]
---@field private data HUDDataItem[]
---@field private dataActive HUDDataItem[]
---@field private displayActive HUDDisplay[]
---@field private essentialsFrame Frame
---@field private timerFrameBack Frame
---@field private timerFrameFront Frame
---@field private resourceFrame Frame
---@field movementGroup HUDUtilityGroup
---@field controlGroup HUDUtilityGroup
---@field powerboostGroup HUDUtilityGroup
---@field assistGroup HUDUtilityGroup
---@field defensiveGroup HUDUtilityGroup
---@field specialGroup HUDUtilityGroup
---@field buffGroup HUDUtilityGroup
---@field alertGroup HUDUtilityGroup
---@field private utilityGroups HUDUtilityGroup[]
---@field private essentialsIconsActiveCount number
---@field private essentialsIcons HUDEssentialsSlot[]
---@field private essentialsLeftSideIcons HUDIcon[]
---@field private essentialsRightSideIcons HUDIcon[]
---@field private timerBarsActive HUDTimerBar[]
---@field private alerts HUDAlert[]
---@field private alertsActive HUDAlert[]
---@field private healthBar ERAStatusBar
---@field private healthData HUDHealth
---@field private resourceBeforeHealth HUDResourceSlot[]
---@field private resourceAfterHealth HUDResourceSlot[]
---@field private resourceVisibilityChangedDynamic boolean
---@field private baseGCD number
---@field private totalGCD number
---@field private gcdBar StatusBar
---@field private gcdLines Line[]
---@field private baseLine Line
---@field private createGCDLine fun(self:HUDModule): Line
---@field private castBar StatusBar
---@field private castBarSecret StatusBar
---@field private castBarSecretVisible boolean
---@field private castBackground Texture
---@field private castBackgroundVisible boolean
---@field private castLine Line
---@field private castLineVisible boolean
---@field private empowers HUDEmpowerLevel[]
---@field private channelTicks Line[]
---@field private channelInfo { [number]: ChannelTickInfo }
---@field private isCasting boolean
---@field private targetCasting boolean
---@field private targetCasBar StatusBar
---@field private kicks HUDCooldown[]
---@field private bagItems HUDBagItem[]
---@field cdmAuraFetcher { [number]: HUDAura }
---@field private cdmParsedTime number
---@field private warnedMissingCDM boolean
---@field duration0 LuaDurationObject
---@field PreUpdateData nil|fun(self:HUDModule, t:number, combat:boolean)
---@field hasEnemyTarget boolean
---@field curveHide96pctFull LuaCurveObject
---@field curveHide4pctEmpty LuaCurveObject
---@field curveHideNoDuration LuaCurveObject
---@field curveTimer LuaCurveObject
---@field curvePandemic LuaCurveObject
---@field curveShowSoonAvailable LuaCurveObject
---@field curveHideLessThanOnePointFive LuaCurveObject
---@field curveHideLessThanTwo LuaCurveObject
---@field curveHideLessThanTen LuaCurveObject
---@field curveShowLessThanThirteen LuaCurveObject
---@field curveTrue0 LuaCurveObject
---@field curveFalse0 LuaCurveObject
---@field curveRedIf0 LuaColorCurveObject
---@field curveAlphaDuration LuaColorCurveObject
---@field colorVisible ColorMixin
---@field colorTransparent ColorMixin
HUDModule = {}
HUDModule.__index = HUDModule
setmetatable(HUDModule, { __index = ERACombatModule })

--------
--#region CURVES

HUDModule.curveHide96pctFull = C_CurveUtil:CreateCurve()
HUDModule.curveHide96pctFull:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHide96pctFull:AddPoint(0, 1)
HUDModule.curveHide96pctFull:AddPoint(0.98, 1)
HUDModule.curveHide96pctFull:AddPoint(0.981, 0)
HUDModule.curveHide96pctFull:AddPoint(1, 0)

HUDModule.curveHide4pctEmpty = C_CurveUtil:CreateCurve()
HUDModule.curveHide4pctEmpty:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHide4pctEmpty:AddPoint(0, 0)
HUDModule.curveHide4pctEmpty:AddPoint(0.04, 0)
HUDModule.curveHide4pctEmpty:AddPoint(0.041, 1)
HUDModule.curveHide4pctEmpty:AddPoint(1, 1)

HUDModule.curveHideNoDuration = C_CurveUtil:CreateCurve()
HUDModule.curveHideNoDuration:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideNoDuration:AddPoint(0, 0)
HUDModule.curveHideNoDuration:AddPoint(0.01, 0)
HUDModule.curveHideNoDuration:AddPoint(0.011, 1)
HUDModule.curveHideNoDuration:AddPoint(1, 1)

HUDModule.curveShowSoonAvailable = C_CurveUtil:CreateCurve()
HUDModule.curveShowSoonAvailable:SetType(Enum.LuaCurveType.Linear)
HUDModule.curveShowSoonAvailable:AddPoint(0, 1)
HUDModule.curveShowSoonAvailable:AddPoint(0.1618, 1)
HUDModule.curveShowSoonAvailable:AddPoint(0.24, 0.8)
HUDModule.curveShowSoonAvailable:AddPoint(0.3, 0.7)
HUDModule.curveShowSoonAvailable:AddPoint(0.5, 0)
HUDModule.curveShowSoonAvailable:AddPoint(1, 0)

HUDModule.curveHideLessThanOnePointFive = C_CurveUtil:CreateCurve()
HUDModule.curveHideLessThanOnePointFive:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideLessThanOnePointFive:AddPoint(0, 0)
HUDModule.curveHideLessThanOnePointFive:AddPoint(1.49, 0)
HUDModule.curveHideLessThanOnePointFive:AddPoint(1.5, 1)

HUDModule.curveHideLessThanTwo = C_CurveUtil:CreateCurve()
HUDModule.curveHideLessThanTwo:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideLessThanTwo:AddPoint(0, 0)
HUDModule.curveHideLessThanTwo:AddPoint(1.99, 0)
HUDModule.curveHideLessThanTwo:AddPoint(2.0, 1)

HUDModule.curveHideLessThanTen = C_CurveUtil:CreateCurve()
HUDModule.curveHideLessThanTen:SetType(Enum.LuaCurveType.Step)
HUDModule.curveHideLessThanTen:AddPoint(0, 0)
HUDModule.curveHideLessThanTen:AddPoint(9.99, 0)
HUDModule.curveHideLessThanTen:AddPoint(10, 1)

HUDModule.curveShowLessThanThirteen = C_CurveUtil:CreateCurve()
HUDModule.curveShowLessThanThirteen:SetType(Enum.LuaCurveType.Linear)
HUDModule.curveShowLessThanThirteen:AddPoint(0.0, 1.0)
HUDModule.curveShowLessThanThirteen:AddPoint(12, 1.0)
HUDModule.curveShowLessThanThirteen:AddPoint(13, 0.13)
HUDModule.curveShowLessThanThirteen:AddPoint(13.13, 0.0)

HUDModule.curveTrue0 = C_CurveUtil:CreateCurve()
HUDModule.curveTrue0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveTrue0:AddPoint(0, 1)
HUDModule.curveTrue0:AddPoint(0.001, 1)
HUDModule.curveTrue0:AddPoint(0.002, 0)
HUDModule.curveTrue0:AddPoint(1, 0)

HUDModule.curveFalse0 = C_CurveUtil:CreateCurve()
HUDModule.curveFalse0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveFalse0:AddPoint(0, 0)
HUDModule.curveFalse0:AddPoint(0.001, 0)
HUDModule.curveFalse0:AddPoint(0.002, 1)
HUDModule.curveFalse0:AddPoint(1, 1)

HUDModule.curveRedIf0 = C_CurveUtil:CreateColorCurve()
HUDModule.curveRedIf0:SetType(Enum.LuaCurveType.Step)
HUDModule.curveRedIf0:AddPoint(0, CreateColor(1.0, 0.0, 0.0, 1.0))
HUDModule.curveRedIf0:AddPoint(0.01, CreateColor(1.0, 1.0, 1.0, 1.0))

HUDModule.curvePandemic = C_CurveUtil:CreateCurve()
HUDModule.curvePandemic:SetType(Enum.LuaCurveType.Step)
HUDModule.curvePandemic:AddPoint(0, 1.0)
HUDModule.curvePandemic:AddPoint(0.29, 1.0)
HUDModule.curvePandemic:AddPoint(0.3, 0.0)
HUDModule.curvePandemic:AddPoint(1, 0.0)

HUDModule.curveAlphaDuration = C_CurveUtil:CreateCurve()
HUDModule.curveAlphaDuration:SetType(Enum.LuaCurveType.Step)
HUDModule.curveAlphaDuration:AddPoint(0, 1.0)
HUDModule.curveAlphaDuration:AddPoint(0.01, 1.0)
HUDModule.curveAlphaDuration:AddPoint(0.1, 0.5)

HUDModule.colorTransparent = CreateColor(1.0, 1.0, 1.0, 0.0)
HUDModule.colorVisible = CreateColor(1.0, 1.0, 1.0, 1.0)

--#endregion
--------

---comment
---@param cFrame ERACombatMainFrame
---@param baseGCD number
---@param spec number
---@return HUDModule
function HUDModule:Create(cFrame, baseGCD, spec)
    local x = {}
    setmetatable(x, HUDModule)
    ---@cast x HUDModule
    x:constructModule(cFrame, 0.1, 0.02, spec)

    x.options = ERACombatOptions_getForSpec(spec)

    x.data = {}
    x.essentialsFrame = CreateFrame("Frame", nil, UIParent)
    x.essentialsIcons = {}
    x.essentialsIconsActiveCount = 0
    x.essentialsLeftSideIcons = {}
    x.essentialsRightSideIcons = {}
    x.timerBarsActive = {}
    x.alerts = {}
    x.alertsActive = {}
    x.bagItems = {}

    x.timerFrameBack = CreateFrame("Frame", nil, x.essentialsFrame)
    x.timerFrameBack:SetPoint("BOTTOM", x.essentialsFrame, "CENTER", 0, 0)
    x.timerFrameFront = CreateFrame("Frame", nil, x.essentialsFrame)
    x.timerFrameFront:SetPoint("BOTTOM", x.essentialsFrame, "CENTER", 0, 0)
    x.baseGCD = baseGCD
    x.gcdLines = {}
    x.baseLine = x:createGCDLine()
    x.baseLine:SetStartPoint("BOTTOMLEFT", x.timerFrameFront, 0, 1)
    x.baseLine:SetEndPoint("BOTTOMRIGHT", x.timerFrameFront, 0, 1)
    x.gcdBar = x:createGCCBar(2, 1.0, 1.0, 1.0, 0.64, "Interface\\Buttons\\WHITE8x8")
    x:setupMiddleGCCBar(x.gcdBar)
    x.castBarSecret = x:createGCCBar(1, 0.2, 0.7, 0.2, 0.32, "Interface\\Buttons\\WHITE8x8")
    x:setupMiddleGCCBar(x.castBarSecret)
    x.castBarSecret:Hide()
    x.castBarSecretVisible = false
    x.castBar = x:createGCCBar(2, 1.0, 1.0, 1.0, 1.0, "Capacitance-Blacksmithing-TimerFill")
    --x.castBar = x:createGCCBar(2, 1.0, 1.0, 1.0, 1.0, "ChallengeMode-TimerFill")
    x.castBar:SetSize(x.options.castBarWidth, ERA_HUDModule_TimerHeight)
    x.castBar:SetPoint("BOTTOMLEFT", x.timerFrameBack, "BOTTOMLEFT", 0, 0)
    x.castBackground = x.timerFrameBack:CreateTexture(nil, "BACKGROUND", nil, 0)
    x.castBackground:SetColorTexture(0.0, 0.0, 0.0, 0.66)
    x.castBackground:SetPoint("BOTTOMLEFT", x.timerFrameBack, "BOTTOMLEFT", 0, 0)
    x.castBackground:Hide()
    x.castBackgroundVisible = false
    x.isCasting = false
    x.castBarSecret:Hide()
    x.channelInfo = {}
    x.channelTicks = {}
    x.empowers = {}
    x.castLine = x.timerFrameFront:CreateLine(nil, "ARTWORK", nil, 1)
    x.castLine:SetColorTexture(0.8, 0.6, 0.0, 1.0)
    x.castLine:SetThickness(2)
    x.castLine:Hide()
    x.castLineVisible = false
    x.kicks = {}
    x.targetCasBar = x:createGCCBar(1, 1.0, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleLegion")
    x.targetCasBar:SetRotatesTexture(true)
    x.targetCasBar:SetPoint("BOTTOMRIGHT", x.timerFrameBack, "BOTTOMRIGHT", 0, 0)
    x.targetCasBar:SetSize(x.options.castBarWidth, ERA_HUDModule_TimerHeight)
    x.targetCasBar:Hide()
    x.targetCasting = false

    x.cdmAuraFetcher = {}
    x.cdmParsedTime = -1

    x.resourceFrame = CreateFrame("Frame", nil, UIParent)
    x.resourceBeforeHealth = {}
    x.resourceAfterHealth = {}
    x.healthData = HUDHealth:Create(x, "player")
    x.resourceVisibilityChangedDynamic = false

    local healthSlot = HUDResourceSlot:create(x)
    table.insert(x.resourceAfterHealth, healthSlot)
    x.healthBar = healthSlot:AddHealth(x.healthData, false)

    x.specialGroup = HUDUtilityGroup:Create(x, "TOPLEFT", false, false, x.options.specialIconSize)
    x.movementGroup = HUDUtilityGroup:Create(x, "TOPLEFT", false, true, x.options.movementIconSize)
    x.controlGroup = HUDUtilityGroup:Create(x, "BOTTOMLEFT", false, true, x.options.controlIconSize)
    x.powerboostGroup = HUDUtilityGroup:Create(x, "TOPRIGHT", false, true, x.options.powerboostIconSize)
    x.buffGroup = HUDUtilityGroup:Create(x, "BOTTOMRIGHT", false, false, x.options.buffIconSize)
    x.assistGroup = HUDUtilityGroup:Create(x, "BOTTOMRIGHT", true, true, x.options.assistIconSize)
    x.defensiveGroup = HUDUtilityGroup:Create(x, "TOP", false, true, x.options.defensiveIconSize)
    x.alertGroup = HUDUtilityGroup:Create(x, "BOTTOM", false, false, x.options.alertGroupIconSize)
    x.utilityGroups = { x.specialGroup, x.movementGroup, x.controlGroup, x.powerboostGroup, x.buffGroup, x.assistGroup, x.defensiveGroup, x.alertGroup }

    x.duration0 = C_DurationUtil.CreateDuration()

    x.curveTimer = C_CurveUtil:CreateCurve()
    x.curveTimer:SetType(Enum.LuaCurveType.Linear)

    x.rootFrames = { x.essentialsFrame, x.resourceFrame }

    return x
end

---@private
---@param frameLevel number
---@param r number
---@param g number
---@param b number
---@param a number
---@param texture string
---@return StatusBar
function HUDModule:createGCCBar(frameLevel, r, g, b, a, texture)
    local bar = CreateFrame("StatusBar", nil, self.timerFrameBack)
    bar:SetStatusBarTexture(texture)
    bar:SetRotatesTexture(true)
    bar:SetStatusBarColor(r, g, b, a)
    bar:SetFrameLevel(frameLevel)
    bar:SetOrientation("VERTICAL")
    bar:SetMinMaxValues(0, 10)
    bar:SetValue(0)
    return bar
end

---@private
---@param bar StatusBar
function HUDModule:setupMiddleGCCBar(bar)
    bar:SetPoint("TOPLEFT", self.timerFrameBack, "TOPLEFT", self.options.castBarWidth, 0)
    bar:SetPoint("TOPRIGHT", self.timerFrameBack, "TOPRIGHT", -self.options.castBarWidth, 0)
    bar:SetPoint("BOTTOMRIGHT", self.timerFrameBack, "BOTTOMRIGHT", -self.options.castBarWidth, 0)
    bar:SetPoint("BOTTOMLEFT", self.timerFrameBack, "BOTTOMLEFT", self.options.castBarWidth, 0)
end

function HUDModule:Pack()
    ----------------
    --#region EQUIPMENT
    self.powerboostGroup:AddEquipment(INVSLOT_TRINKET1, 2000859)
    self.powerboostGroup:AddEquipment(INVSLOT_TRINKET2, 2000857)
    --#endregion
    ----------------

    ----------------
    --#region racial

    local _, _, r = UnitRace("player")
    local racialSpellID = nil
    ---@type HUDUtilityGroup
    local racialGroup = nil
    if (r == 1 or r == 33) then
        -- human
        racialSpellID = 59752
        racialGroup = self.controlGroup
    elseif (r == 2) then
        -- orc
        racialGroup = self.powerboostGroup
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
        racialSpellID = 20594
        racialGroup = self.defensiveGroup
    elseif (r == 4) then
        -- night elf
        racialSpellID = 58984
        racialGroup = self.specialGroup
    elseif (r == 5) then
        -- undead
        racialSpellID = 7744
        racialGroup = self.defensiveGroup
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
        racialGroup = self.powerboostGroup
    elseif (r == 9) then
        -- goblin
        racialSpellID = 69070
        racialGroup = self.movementGroup
    elseif (r == 10) then
        -- blood elf
        racialGroup = self.powerboostGroup
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
        racialGroup = self.defensiveGroup
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
        racialGroup = self.defensiveGroup
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
        racialGroup = self.powerboostGroup
    elseif (r == 31) then
        -- zandalari
        racialSpellID = 291944
        racialGroup = self.defensiveGroup
    elseif (r == 32) then
        -- kul tiran
        racialSpellID = 287712
        racialGroup = self.controlGroup
    elseif (r == 34) then
        -- dark iron dwarf
        racialSpellID = 265221
        racialGroup = self.defensiveGroup
    elseif (r == 35) then
        -- vulpera
        racialSpellID = 312411
        racialGroup = self.powerboostGroup
    elseif (r == 36) then
        -- mag'har
        racialSpellID = 274738
        racialGroup = self.powerboostGroup
    elseif (r == 37) then
        -- mechagnome
        racialSpellID = 312924
        racialGroup = self.defensiveGroup
    elseif (r == 52 or r == 70) then
        -- dracthyr
        if ERACombatFrames_classID ~= 13 then
            -- tail swipe 368970
            racialSpellID = 357214
            racialGroup = self.controlGroup
        end
    elseif (r == 84 or r == 85) then
        -- earthen
        racialSpellID = 436344
        racialGroup = self.powerboostGroup
    end
    if (racialSpellID and racialGroup) then
        racialGroup:AddCooldown(self:AddCooldown(racialSpellID))
    end

    --#endregion
    ----------------
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region ACTIVATION & LAYOUT --------------------------------------------------------------------------------------------------

function HUDModule:SpecInactive()
    for _, f in ipairs(self.rootFrames) do
        f:Hide()
    end
    for _, g in ipairs(self.utilityGroups) do
        g:moduleInactive()
    end
    self.cdmParsedTime = -1
    BuffIconCooldownViewer:SetAlpha(1.0)
    BuffBarCooldownViewer:SetAlpha(1.0)
    EssentialCooldownViewer:SetAlpha(1.0)
    UtilityCooldownViewer:SetAlpha(1.0)
end

function HUDModule:SpecActive()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
    for _, g in ipairs(self.utilityGroups) do
        g:moduleActive()
    end
    self.cdmParsedTime = -1
end

function HUDModule:ResetToIdle()
    self.timerFrameBack:Hide()
    self.timerFrameFront:Hide()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
    for _, g in ipairs(self.utilityGroups) do
        g:exitCombat()
    end
    BuffIconCooldownViewer:SetAlpha(0)
    BuffBarCooldownViewer:SetAlpha(0)
    EssentialCooldownViewer:SetAlpha(0)
    UtilityCooldownViewer:SetAlpha(0)
end

function HUDModule:EnterCombat()
    self.timerFrameBack:Show()
    self.timerFrameFront:Show()
    for _, g in ipairs(self.utilityGroups) do
        g:enterCombat()
    end
end

function HUDModule:ExitCombat()
    self.timerFrameBack:Hide()
    self.timerFrameFront:Hide()
    for _, g in ipairs(self.utilityGroups) do
        g:exitCombat()
    end
end

function HUDModule:BagUpdate()
    for _, i in ipairs(self.bagItems) do
        i:bagUpdate()
    end
end

function HUDModule:CheckTalents()
    self.cdmParsedTime = -1
    self.totalGCD = nil

    self.dataActive = {}
    self.cdmAuraFetcher = {}
    for _, d in ipairs(self.data) do
        if (d:computeTalentActive()) then
            table.insert(self.dataActive, d)
        end
    end

    self.displayActive = {}

    self.timerBarsActive = {}
    self.essentialsIconsActiveCount = 0
    for _, x in ipairs(self.essentialsIcons) do
        x:computeTalents()
    end
    self:checkTalentsIconsList(self.essentialsLeftSideIcons)
    self:checkTalentsIconsList(self.essentialsRightSideIcons)

    for _, g in ipairs(self.utilityGroups) do
        g:checkTalents(self.displayActive)
    end
    self.alertsActive = {}
    for _, a in ipairs(self.alerts) do
        if (a:computeActive()) then
            table.insert(self.alertsActive, a)
            table.insert(self.displayActive, a)
        end
    end

    for _, x in ipairs(self.resourceBeforeHealth) do
        x:computeTalents()
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        x:computeTalents()
    end

    --[[
    for _, tb in ipairs(self.timerBars) do
        if (tb:computeActive()) then
            table.insert(self.timerBarsActive, tb)
            table.insert(self.displayActive, tb)
        end
    end
    ]]

    self:updateLayout()
end

---@private
---@param list HUDIcon[]
---@return number
function HUDModule:checkTalentsIconsList(list)
    local cpt = 0
    for _, icon in ipairs(list) do
        if (icon:computeActive()) then
            table.insert(self.displayActive, icon)
            cpt = cpt + 1
        end
    end
    return cpt
end

function HUDModule:EnterVehicle()
    for _, f in ipairs(self.rootFrames) do
        f:Hide()
    end
end

function HUDModule:ExitVehicle()
    for _, f in ipairs(self.rootFrames) do
        f:Show()
    end
end

---@private
function HUDModule:updateLayout()
    local iCount = 0

    -- essentials & timer
    local iconSize = self.options.essentialsIconSize
    self.essentialsFrame:SetPoint("CENTER", UIParent, "CENTER", self.options.essentialsX, self.options.essentialsY)
    self.essentialsFrame:SetSize(iconSize * self.essentialsIconsActiveCount, 2 * ERA_HUDModule_TimerHeight)
    for _, x in ipairs(self.essentialsIcons) do
        if (x.talentActive) then
            iCount = iCount + 1
            x:setPosition(iconSize * (iCount - self.essentialsIconsActiveCount / 2 - 0.5), iconSize, self.timerFrameBack)
        end
    end

    self.timerFrameBack:SetSize(iconSize * self.essentialsIconsActiveCount + 2 * self.options.castBarWidth, ERA_HUDModule_TimerHeight)
    self.timerFrameFront:SetSize(iconSize * self.essentialsIconsActiveCount + 2 * self.options.castBarWidth, ERA_HUDModule_TimerHeight)
    if (self.options.gcdCount < #self.gcdLines) then
        repeat
            local removedLine = table.remove(self.gcdLines)
            removedLine:Hide()
        until self.options.gcdCount == #self.gcdLines
    else
        while (self.options.gcdCount > #self.gcdLines) do
            local newLine = self:createGCDLine()
            table.insert(self.gcdLines, newLine)
        end
    end
    for i, l in ipairs(self.gcdLines) do
        local yGCD = i * self.options.gcdHeight
        l:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, yGCD)
        l:SetEndPoint("BOTTOMRIGHT", self.timerFrameFront, 0, yGCD)
    end
    self.curveTimer:ClearPoints()
    self.curveTimer:AddPoint(0, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD, self.options.gcdCount * self.baseGCD)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 0.1, 0)
    self.curveTimer:AddPoint(self.options.gcdCount * self.baseGCD + 1, 0)

    self.targetCasBar:SetWidth(self.options.castBarWidth)
    self.castBar:SetWidth(self.options.castBarWidth)
    self.castBackground:SetWidth(self.options.castBarWidth)
    for _, emp in ipairs(self.empowers) do
        emp:updateSize(self)
    end

    -- resource
    local topResource, resourceWidth = self:prepareResourceLayout()
    self.resourceFrame:SetSize(iconSize * self.options.essentialsMinColumns - 2, 4 * (self.options.healthHeight + self.options.powerHeight))
    self.resourceFrame:SetPoint("TOP", UIParent, "CENTER", self.options.essentialsX, topResource)
    local yResource = 0
    for _, x in ipairs(self.resourceBeforeHealth) do
        local rh = x:updateLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        local rh = x:updateLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end

    -- side of essentials
    local sideLeftColumns, sideRightColumns
    if (self.options.essentialsMinColumns == self.essentialsIconsActiveCount) then
        sideLeftColumns = 1
    else
        sideLeftColumns = 1 + math.ceil(((resourceWidth - iconSize * self.essentialsIconsActiveCount) / iconSize) / 2)
    end
    sideRightColumns = 2
    local xSide = (-self.essentialsIconsActiveCount / 2 + 0.5) * iconSize
    local ySide = 0
    iCount = 0
    for i = #self.essentialsLeftSideIcons, 1, -1 do
        local s = self.essentialsLeftSideIcons[i]
        if (s.talentActive) then
            iCount = iCount + 1
            if (iCount > sideLeftColumns) then
                ySide = ySide - iconSize
            else
                xSide = xSide - iconSize
            end
        end
        s:setPosition(xSide, ySide)
    end
    xSide = (self.essentialsIconsActiveCount / 2 - 0.5) * iconSize
    ySide = 0
    iCount = 0
    for _, s in ipairs(self.essentialsRightSideIcons) do
        if (s.talentActive) then
            iCount = iCount + 1
            if (iCount > sideRightColumns) then
                ySide = ySide + iconSize
            else
                xSide = xSide + iconSize
            end
        end
        s:setPosition(xSide, ySide)
    end

    -- utility
    self.defensiveGroup:updateLayout(self.options.essentialsX, topResource + yResource - self.options.defensivePadding, self.options.defensiveIconSize, self.options.utilityIconPadding)
    self.alertGroup:updateLayout(self.options.alertGroupX, self.options.alertGroupY, self.options.alertGroupIconSize, self.options.utilityIconPadding)
    self.assistGroup:updateLayout(self.options.assistX, self.options.assistY, self.options.assistIconSize, self.options.utilityIconPadding)
    self.powerboostGroup:updateLayout(self.options.powerboostX, self.options.powerboostY, self.options.powerboostIconSize, self.options.utilityIconPadding)
    self.buffGroup:updateLayout(self.options.buffX, self.options.buffY --[[the vampire slayer]], self.options.buffIconSize, self.options.utilityIconPadding)
    self.controlGroup:updateLayout(self.options.controlX, self.options.controlY, self.options.controlIconSize, self.options.utilityIconPadding)
    self.movementGroup:updateLayout(self.options.movementX, self.options.movementY, self.options.movementIconSize, self.options.utilityIconPadding)
    self.specialGroup:updateLayout(self.options.specialX, self.options.specialY, self.options.specialIconSize, self.options.utilityIconPadding)

    -- alerts
    for _, a in ipairs(self.alertsActive) do
        a:updateLayout(self.options)
    end
end

---@private
---@return Line
function HUDModule:createGCDLine()
    local l = self.timerFrameFront:CreateLine(nil, "ARTWORK", nil, 2)
    l:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    l:SetThickness(1)
    return l
end

---@private
function HUDModule:prepareResourceLayout()
    local topResource = self.options.essentialsY - self.options.essentialsIconSize - self.options.resourcePadding
    local resourceWidth = self.options.essentialsIconSize * max(self.options.essentialsMinColumns, self.essentialsIconsActiveCount)
    return topResource, resourceWidth
end

---@private
function HUDModule:updateResourceLayoutDynamic()
    self.resourceVisibilityChangedDynamic = false
    local topResource, resourceWidth = self:prepareResourceLayout()
    local yResource = 0
    for _, x in ipairs(self.resourceBeforeHealth) do
        local rh = x:dynamicLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end
    for _, x in ipairs(self.resourceAfterHealth) do
        local rh = x:dynamicLayout_returnHeight(yResource, resourceWidth, self.resourceFrame)
        if (rh > 0) then
            yResource = yResource - rh - self.options.resourcePadding
        end
    end
    self.defensiveGroup:updateLayout(self.options.essentialsX, topResource + yResource - self.options.defensivePadding, self.options.defensiveIconSize, self.options.utilityIconPadding)
end

function HUDModule:dynamicResourceVisibilityChanged()
    self.resourceVisibilityChangedDynamic = true
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region CONTENT --------------------------------------------------------------------------------------------------------------

---@return Frame
function HUDModule:getTimerBarFrame()
    return self.timerFrameBack
end

---@return Frame
function HUDModule:getResourceFrame()
    return self.resourceFrame
end

---@return Frame
function HUDModule:getEssentialFrame()
    return self.essentialsFrame
end

---@param a HUDAura
---@param isTarget boolean
function HUDModule:addActiveAura(a, isTarget)
    self.cdmAuraFetcher[a.spellID] = a
end

---@param icon HUDIcon
---@param isFirstInSlot boolean
function HUDModule:addActiveEssentialIcon(icon, isFirstInSlot)
    table.insert(self.displayActive, icon)
    if (isFirstInSlot) then
        self.essentialsIconsActiveCount = self.essentialsIconsActiveCount + 1
    end
end

---@param tb HUDTimerBar
function HUDModule:addActiveTimerBar(tb)
    table.insert(self.timerBarsActive, tb)
    table.insert(self.displayActive, tb)
end

---@param r HUDResourceDisplay
function HUDModule:addActiveResource(r)
    table.insert(self.displayActive, r)
end

---@param d HUDDataItem
function HUDModule:addData(d)
    table.insert(self.data, d)
end

---@param i HUDBagItem
function HUDModule:addBagItem(i)
    table.insert(self.bagItems, i)
end

---@param tb HUDAlert
function HUDModule:addAlert(tb)
    table.insert(self.alerts, tb)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region UPDATE ---------------------------------------------------------------------------------------------------------------

---@param t number
function HUDModule:UpdateCombat(t)
    self.hasEnemyTarget = UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")

    self:updateData(t, true)

    local gcdDuration
    local pixelPerSecondWithoutHaste
    if (self.baseGCD == 1) then
        gcdDuration = 1
        pixelPerSecondWithoutHaste = self.options.gcdHeight
    else
        gcdDuration = self.baseGCD / (1 + GetHaste() / 100)
        pixelPerSecondWithoutHaste = self.options.gcdHeight / self.baseGCD
    end
    local pixelPerSecond = self.options.gcdHeight / gcdDuration
    if (gcdDuration ~= self.totalGCD) then
        self.totalGCD = gcdDuration
        local maxTimer = ERA_HUDModule_TimerHeight / pixelPerSecond
        self.gcdBar:SetMinMaxValues(0, maxTimer)
        self.castBar:SetMinMaxValues(0, maxTimer)
        self.castBarSecret:SetMinMaxValues(0, maxTimer)
        self.targetCasBar:SetMinMaxValues(0, maxTimer)
        for _, tb in ipairs(self.timerBarsActive) do
            tb:updateMaxDuration(maxTimer)
        end
    end
    local currentGCD = C_Spell.GetSpellCooldownDuration(61304)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.gcdBar:SetValue(currentGCD:EvaluateRemainingDuration(self.curveTimer))

    --#region CASTING

    local remainingCast = 0
    local totalTimeForCastBackground = 0
    ---@type LuaDurationObject
    local durationCastIfRemainingSecret = nil
    local _, _, _, startTimeMS, endTimeMS, _, _, channelID, isEmpowered, numEmpowerStages = UnitChannelInfo("player")
    if (channelID) then
        ---@diagnostic disable-next-line: param-type-mismatch
        local secret = issecretvalue(startTimeMS) or issecretvalue(endTimeMS)
        if (numEmpowerStages and numEmpowerStages > 0 and not secret) then
            if (self.isCasting) then
                self:hideChannelTicks(1)
            end
            local castProgress = t - (startTimeMS / 1000)
            local maxHold = GetUnitEmpowerHoldAtMaxTime("player") / 1000
            local acc = 0
            local yTop = pixelPerSecond * (maxHold + (endTimeMS - startTimeMS) / 1000)
            for i = 1, numEmpowerStages do
                local emp
                if (i > #self.empowers) then
                    emp = HUDEmpowerLevel:create(self, i, self.timerFrameFront)
                    table.insert(self.empowers, emp)
                else
                    emp = self.empowers[i]
                end
                local stageDuration
                if (i == numEmpowerStages) then
                    stageDuration = maxHold
                else
                    stageDuration = GetUnitEmpowerStageDuration("player", i) / 1000
                end
                acc = acc + stageDuration
                emp:draw(self.options.castBarWidth, yTop - acc * pixelPerSecond, castProgress > acc, self.timerFrameFront)
            end
            for i = numEmpowerStages + 1, #self.empowers do
                self.empowers[i]:hide()
            end
            remainingCast = maxHold + endTimeMS / 1000 - t
            totalTimeForCastBackground = maxHold + (endTimeMS - startTimeMS) / 1000
        else
            if (secret) then
                durationCastIfRemainingSecret = UnitChannelDuration("player")
                local ci = self.channelInfo[channelID]
                if (ci) then
                    for i = 1, ci.tickCount - 1 do
                        local line
                        if (i > #self.channelTicks) then
                            line = self:createTickLine()
                            table.insert(self.channelTicks, line)
                        else
                            line = self.channelTicks[i]
                            line:Show()
                        end
                        local yTick = i * ci.tickDelta * pixelPerSecondWithoutHaste
                        line:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, yTick)
                        line:SetEndPoint("BOTTOMLEFT", self.timerFrameFront, self.options.castBarWidth, yTick)
                    end
                    self:hideChannelTicks(ci.tickCount)
                else
                    self:hideChannelTicks(1)
                end
            else
                remainingCast = endTimeMS / 1000 - t
                local ci = self.channelInfo[channelID]
                if (ci) then
                    local tickCount = 0
                    local tickY = remainingCast * pixelPerSecond
                    repeat
                        tickCount = tickCount + 1
                        local line
                        if (tickCount > #self.channelTicks) then
                            line = self:createTickLine()
                            table.insert(self.channelTicks, line)
                        else
                            line = self.channelTicks[tickCount]
                            line:Show()
                        end
                        line:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, tickY)
                        line:SetEndPoint("BOTTOMLEFT", self.timerFrameFront, self.options.castBarWidth, tickY)
                        tickY = tickY - ci.tickDelta * pixelPerSecondWithoutHaste
                    until tickY <= 0
                    self:hideChannelTicks(tickCount + 1)
                else
                    self:hideChannelTicks(1)
                end
            end
            if (self.isCasting) then
                self:hideEmpowers()
            end
        end
    else
        local _, _, _, startTimeMS, endTimeMS, _, _, _, castID = UnitCastingInfo("player")
        if (castID) then
            ---@diagnostic disable-next-line: param-type-mismatch
            if (issecretvalue(endTimeMS)) then
                durationCastIfRemainingSecret = UnitCastingDuration("player")
            else
                remainingCast = endTimeMS / 1000 - t
            end
        end
        if (self.isCasting) then
            self:hideChannelTicks(1)
            self:hideEmpowers()
        end
    end
    if (durationCastIfRemainingSecret) then
        self.castBar:SetValue(durationCastIfRemainingSecret:GetRemainingDuration())
        ---@diagnostic disable-next-line: param-type-mismatch
        self.castBarSecret:SetValue(durationCastIfRemainingSecret:EvaluateRemainingDuration(self.curveTimer))
        if (not self.castBarSecretVisible) then
            self.castBarSecretVisible = true
            self.castBarSecret:Show()
        end
        if (self.castBackgroundVisible) then
            self.castBackgroundVisible = false
            self.castBackground:Hide()
        end
        if (self.castLineVisible) then
            self.castLineVisible = false
            self.castLine:Hide()
        end
        self.isCasting = true
    else
        if (self.castBarSecretVisible) then
            self.castBarSecretVisible = false
            self.castBarSecret:Hide()
        end
        if (remainingCast > 0) then
            self.castBar:SetValue(remainingCast)
            local yCast = remainingCast * pixelPerSecond
            self.castLine:SetStartPoint("BOTTOMLEFT", self.timerFrameFront, 0, yCast)
            self.castLine:SetEndPoint("BOTTOMRIGHT", self.timerFrameFront, 0, yCast)
            if (not self.castLineVisible) then
                self.castLineVisible = true
                self.castLine:Show()
            end
            self.isCasting = true
        else
            self.castBar:SetValue(0)
            if (self.castLineVisible) then
                self.castLineVisible = false
                self.castLine:Hide()
            end
            self.isCasting = false
        end
        if (totalTimeForCastBackground > 0) then
            self.castBackground:SetHeight(totalTimeForCastBackground * pixelPerSecond)
            if (not self.castBackgroundVisible) then
                self.castBackgroundVisible = true
                self.castBackground:Show()
            end
        else
            if (self.castBackgroundVisible) then
                self.castBackgroundVisible = false
                self.castBackground:Hide()
            end
        end
    end

    --#endregion

    --#region TARGET CASTING

    ---@type HUDCooldown
    local foundKick = nil
    for _, k in ipairs(self.kicks) do
        if (k.talentActive and ((not k.isSpecialIf) or k.isSpecialIf.value)) then
            foundKick = k
            break
        end
    end
    if (foundKick) then
        local targetCastDuration = nil
        ---@type ColorMixin
        local tarCastColor = nil
        local _, _, _, _, _, _, notInterruptible, tarCastlID = UnitChannelInfo("target")
        if (tarCastlID) then
            targetCastDuration = UnitChannelDuration("target")
            ---@diagnostic disable-next-line: param-type-mismatch
            tarCastColor = C_CurveUtil.EvaluateColorFromBoolean(notInterruptible, HUDModule.colorTransparent, HUDModule.colorVisible)
        else
            _, _, _, _, _, _, _, notInterruptible, tarCastlID = UnitCastingInfo("target")
            if (tarCastlID) then
                targetCastDuration = UnitCastingDuration("target")
                ---@diagnostic disable-next-line: param-type-mismatch
                tarCastColor = C_CurveUtil.EvaluateColorFromBoolean(notInterruptible, HUDModule.colorTransparent, HUDModule.colorVisible)
            end
        end
        if (targetCastDuration) then
            self.targetCasBar:SetValue(targetCastDuration:GetRemainingDuration())
            ---@diagnostic disable-next-line: param-type-mismatch
            self.targetCasBar:SetAlpha(foundKick.cooldownDuration:EvaluateRemainingDuration(self.curveTrue0))
            self.targetCasBar:SetStatusBarColor(tarCastColor.r, tarCastColor.g, tarCastColor.b, tarCastColor.a)
            if (not self.targetCasting) then
                self.targetCasting = true
                self.targetCasBar:Show()
            end
        else
            if (self.targetCasting) then
                self.targetCasting = false
                self.targetCasBar:Hide()
            end
        end
    end

    --#endregion

    for _, d in ipairs(self.displayActive) do
        d:updateDisplay(t, true)
    end
    if (self.resourceVisibilityChangedDynamic) then
        self:updateResourceLayoutDynamic()
    end
end

---comment
---@param t number
function HUDModule:UpdateIdle(t)
    self:updateData(t, false)
    for _, d in ipairs(self.displayActive) do
        d:updateDisplay(t, false)
    end
    if (self.resourceVisibilityChangedDynamic) then
        self:updateResourceLayoutDynamic()
    end
end

---@private
---@param t number
---@param combat boolean
function HUDModule:updateData(t, combat)
    self.duration0:Reset()

    if (self.PreUpdateData) then
        self:PreUpdateData(t, combat)
    end

    --#region AURAS

    if (self.cdmParsedTime < 0) then
        self.cdmParsedTime = t
    elseif (self.cdmParsedTime > 0 and t - self.cdmParsedTime >= 1.618) then
        self.cdmParsedTime = 0
        for _, aura in pairs(self.cdmAuraFetcher) do
            aura:prepareParseCDM()
        end
        self:parseCDMBuffDirect(BuffBarCooldownViewer)
        self:parseCDMBuffDirect(BuffIconCooldownViewer)
        self:parseCDMBuffLinked(BuffBarCooldownViewer)
        self:parseCDMBuffLinked(BuffIconCooldownViewer)
        if (not self.warnedMissingCDM) then
            self.warnedMissingCDM = true
            local missingCDM = nil
            for _, aura in pairs(self.cdmAuraFetcher) do
                if (not aura.cdmFrameFound) then
                    if (missingCDM) then
                        table.insert(missingCDM, aura)
                    else
                        missingCDM = { aura }
                    end
                end
            end
            if (missingCDM) then
                print("ECF WARNING : the following auras are not tracked by the Cooldown Manager :")
                for _, aura in ipairs(missingCDM) do
                    local description
                    local info = C_Spell.GetSpellInfo(aura.spellID)
                    if (info) then
                        description = info.name
                    else
                        description = "?"
                    end
                    print(aura.spellID, description)
                end
                print("Please enable these auras in the Cooldown Manager, then reload your UI.")
            end
        end
    end
    --[[
    for i = 1, 1000 do
        local auraData = C_UnitAuras.GetBuffDataByIndex("player", i, "PLAYER")
        if (auraData) then
            if (issecretvalue(auraData.spellId)) then
                -- ce hack ne marche plus
                local hackID = 0
                for j = 1, auraData.spellId do
                    hackID = hackID + 1
                end
            else
                local timer = self.playerAuraFetcher[auraData.spellId]
                if (timer) then
                    timer:auraFound(C_UnitAuras.GetAuraDuration("player", auraData.auraInstanceID), auraData)
                end
            end
        else
            break
        end
    end
    ]]
    --#endregion

    for _, d in ipairs(self.dataActive) do
        d:Update(t, combat)
    end
end

---@private
function HUDModule:parseCDMBuffDirect(frame)
    local buffFrames = { frame:GetChildren() }
    for _, c in ipairs(buffFrames) do
        local info = c.cooldownInfo
        if (c.cooldownInfo) then
            ---@cast info CooldownViewerCooldown
            if (info.spellID) then
                local aura = self.cdmAuraFetcher[info.spellID]
                if (aura) then
                    aura:setCDM(c)
                elseif (info.overrideSpellID) then
                    aura = self.cdmAuraFetcher[info.overrideSpellID]
                    if (aura) then
                        aura:setCDM(c)
                    end
                end
            end
        end
    end
end

function HUDModule:parseCDMBuffLinked(frame)
    local buffFrames = { frame:GetChildren() }
    for _, c in ipairs(buffFrames) do
        local info = c.cooldownInfo
        if (c.cooldownInfo) then
            ---@cast info CooldownViewerCooldown
            if (info.linkedSpellIDs) then
                for _, linked in ipairs(info.linkedSpellIDs) do
                    local aura = self.cdmAuraFetcher[linked]
                    if (aura and not aura.cdmFrameFound) then
                        aura:setCDM(c)
                        -- do not break
                    end
                end
            end
        end
    end
end

---@class CDMAuraFrame
---@field auraInstanceID number|nil
---@field auraDataUnit string|nil

--------
--#region CHANNEL TICKS

---@private
function HUDModule:createTickLine()
    local l = self.timerFrameFront:CreateLine(nil, "ARTWORK", nil, 7)
    l:SetColorTexture(0.4, 0.1, 1.0, 1.0)
    l:SetThickness(1)
    return l
end

---@private
---@param startIndex number
function HUDModule:hideChannelTicks(startIndex)
    for i = startIndex, #self.channelTicks do
        self.channelTicks[i]:Hide()
    end
end

--#endregion
--------

--------
--#region EMPOWER

---@private
function HUDModule:hideEmpowers()
    for _, emp in ipairs(self.empowers) do
        emp:hide()
    end
end

---@class (exact) HUDEmpowerLevel
---@field private __index HUDEmpowerLevel
---@field private frame Frame
---@field private line Line
---@field private text FontString
---@field private isVisible boolean
---@field private isActive boolean
HUDEmpowerLevel = {}
HUDEmpowerLevel.__index = HUDEmpowerLevel

---@param hud HUDModule
---@param level number
---@param parentFrame Frame
---@return HUDEmpowerLevel
function HUDEmpowerLevel:create(hud, level, parentFrame)
    local x = {}
    setmetatable(x, HUDEmpowerLevel)
    ---@cast x HUDEmpowerLevel

    x.line = parentFrame:CreateLine(nil, "OVERLAY", nil, 1)
    x.line:SetThickness(2)
    x.line:SetColorTexture(1.0, 1.0, 1.0, 1.0)
    x.line:Hide()

    x.frame = CreateFrame("Frame", nil, parentFrame)
    x.frame:Hide()
    local background = x.frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    background:SetAllPoints()
    background:SetColorTexture(0.0, 0.0, 0.0, 0.5)

    x.text = x.frame:CreateFontString(nil, "ARTWORK", nil)
    x.text:SetPoint("CENTER", x.frame, "CENTER", 0, 0)
    x.text:SetAllPoints()
    x.text:SetJustifyH("CENTER")
    x.text:SetJustifyV("MIDDLE")

    x:updateSize(hud)
    x.isVisible = false
    x.isActive = false

    if (level == 1) then
        x.text:SetText("I")
    elseif (level == 2) then
        x.text:SetText("II")
    elseif (level == 3) then
        x.text:SetText("III")
    elseif (level == 4) then
        x.text:SetText("IV")
    elseif (level == 5) then
        x.text:SetText("V")
    else
        x.text:SetText(tostring(level))
    end

    return x
end

---@param hud HUDModule
function HUDEmpowerLevel:updateSize(hud)
    local labelSize = 1.1 * hud.options.castBarWidth
    self.frame:SetSize(labelSize, labelSize)
    ERALIB_SetFont(self.text, labelSize * 0.7)
end

function HUDEmpowerLevel:hide()
    if (self.isVisible) then
        self.isVisible = false
        self.frame:Hide()
        self.line:Hide()
    end
end

---@param x number
---@param y number
---@param isActive boolean
---@param parentFrame Frame
function HUDEmpowerLevel:draw(x, y, isActive, parentFrame)
    self.frame:SetPoint("RIGHT", parentFrame, "BOTTOMLEFT", 0, y)
    self.line:SetStartPoint("BOTTOMLEFT", parentFrame, 0, y)
    self.line:SetEndPoint("BOTTOMLEFT", parentFrame, x, y)
    if (isActive) then
        if (not self.isActive) then
            self.isActive = true
            self.text:SetTextColor(0.0, 1.0, 0.0, 1.0)
            self.line:SetColorTexture(0.0, 1.0, 0.0, 1.0)
        end
    else
        if (self.isActive) then
            self.isActive = false
            self.text:SetTextColor(0.5, 0.5, 0.5, 1.0)
            self.line:SetColorTexture(1.0, 1.0, 1.0, 1.0)
        end
    end
    if (not self.isVisible) then
        self.isVisible = true
        self.frame:Show()
        self.line:Show()
    end
end

--#endregion
--------

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region UTILITY GROUP --------------------------------------------------------------------------------------------------------

---@alias HUDUtilityGroupAnchor "TOPLEFT"|"TOPRIGHT"|"BOTTOMLEFT"|"BOTTOMRIGHT"|"TOP"|"BOTTOM"

---@class (exact) HUDUtilityGroup
---@field private __index HUDUtilityGroup
---@field private hud HUDModule
---@field private anchor HUDUtilityGroupAnchor
---@field private directX number
---@field private directY number
---@field private frame Frame
---@field private background nil|Frame
---@field private icons HUDIcon[]
---@field private overlaps boolean[]
---@field private hasActive boolean
---@field private singleLine boolean
---@field private vertical boolean
---@field private iconSize number
---@field private currentFrameLevel number
HUDUtilityGroup = {}
HUDUtilityGroup.__index = HUDUtilityGroup

---@param hud HUDModule
---@param anchor HUDUtilityGroupAnchor
---@param vertical boolean
---@param hasBackground boolean
---@param iconSize number
---@return HUDUtilityGroup
function HUDUtilityGroup:Create(hud, anchor, vertical, hasBackground, iconSize)
    local x = {}
    setmetatable(x, HUDUtilityGroup)
    ---@cast x HUDUtilityGroup

    x.hud = hud
    x.vertical = vertical
    x.anchor = anchor
    if (anchor == "TOP") then
        x.directX = 1
        x.directY = -1
        x.singleLine = true
    elseif (anchor == "BOTTOM") then
        x.directX = 1
        x.directY = 1
        x.singleLine = true
    elseif (anchor == "TOPLEFT") then
        if (vertical) then
            x.directX = math.sqrt(3) / 2
            x.directY = -1
        else
            x.directX = 1
            x.directY = -math.sqrt(3) / 2
        end
    elseif (anchor == "TOPRIGHT") then
        if (vertical) then
            x.directX = -math.sqrt(3) / 2
            x.directY = -1
        else
            x.directX = -1
            x.directY = -math.sqrt(3) / 2
        end
    elseif (anchor == "BOTTOMRIGHT") then
        if (vertical) then
            x.directX = -math.sqrt(3) / 2
            x.directY = 1
        else
            x.directX = -1
            x.directY = math.sqrt(3) / 2
        end
    elseif (anchor == "BOTTOMLEFT") then
        if (vertical) then
            x.directX = math.sqrt(3) / 2
            x.directY = 1
        else
            x.directX = 1
            x.directY = math.sqrt(3) / 2
        end
    end

    if (hasBackground) then
        x.background = CreateFrame("Frame", nil, UIParent)
        local txbg = x.background:CreateTexture(nil, "BACKGROUND", nil, 0)
        txbg:SetAllPoints()
        txbg:SetColorTexture(0.0, 0.0, 0.0, 0.44)
        local thick = 3
        local lineLeft = self:createBorderLine(x.background, thick)
        local lineTop = self:createBorderLine(x.background, thick)
        local lineRight = self:createBorderLine(x.background, thick)
        local lineBottom = self:createBorderLine(x.background, thick)
        lineLeft:SetStartPoint("BOTTOMLEFT", x.background, thick / 2, thick / 4)
        lineLeft:SetEndPoint("TOPLEFT", x.background, thick / 2, -thick / 4)
        lineTop:SetStartPoint("TOPLEFT", x.background, thick / 4, -thick / 2)
        lineTop:SetEndPoint("TOPRIGHT", x.background, -thick / 4, -thick / 2)
        lineRight:SetStartPoint("TOPRIGHT", x.background, -thick / 2, -thick / 4)
        lineRight:SetEndPoint("BOTTOMRIGHT", x.background, -thick / 2, thick / 4)
        lineBottom:SetStartPoint("BOTTOMRIGHT", x.background, -thick / 4, thick / 2)
        lineBottom:SetEndPoint("BOTTOMLEFT", x.background, thick / 4, thick / 2)
        x.background:Hide()
    end

    x.frame = CreateFrame("Frame", nil, UIParent)
    x.frame:SetFrameLevel(4)
    x.frame:Hide()

    x.iconSize = iconSize
    x.icons = {}
    x.overlaps = {}
    x.currentFrameLevel = 1

    return x
end

---@private
---@param frame Frame
---@param thick number
---@return Line
function HUDUtilityGroup:createBorderLine(frame, thick)
    local line = frame:CreateLine(nil, "BORDER", nil, 1)
    line:SetColorTexture(0.66, 0.66, 0.66, 1.0)
    line:SetThickness(thick / 2)
    return line
end

function HUDUtilityGroup:moduleActive()
    self.frame:Show()
end

function HUDUtilityGroup:moduleInactive()
    self.frame:Hide()
    if (self.background) then
        self.background:Hide()
    end
end

function HUDUtilityGroup:enterCombat()
    if (self.hasActive and self.background) then
        self.background:Show()
    end
end

function HUDUtilityGroup:exitCombat()
    if (self.background) then
        self.background:Hide()
    end
end

---@param displayActive HUDDisplay[]
function HUDUtilityGroup:checkTalents(displayActive)
    self.hasActive = false
    for _, icon in ipairs(self.icons) do
        if (icon:computeActive()) then
            table.insert(displayActive, icon)
            self.hasActive = true
        end
    end
end

---@param offX number
---@param offY number
---@param iconSize number
---@param iconPadding number
function HUDUtilityGroup:updateLayout(offX, offY, iconSize, iconPadding)
    self.iconSize = iconSize
    for _, icon in ipairs(self.icons) do
        icon:setSize(iconSize)
    end
    local width, height
    if (self.hasActive) then
        if (self.singleLine) then
            local slotCount = 0
            for i, icon in ipairs(self.icons) do
                if (icon.talentActive and (slotCount == 0 or not self.overlaps[i])) then
                    slotCount = slotCount + 1
                end
            end
            local iCount = 0
            for i, icon in ipairs(self.icons) do
                if (icon.talentActive) then
                    if (iCount == 0 or not self.overlaps[i]) then
                        iCount = iCount + 1
                    end
                    icon:setPosition(iconSize * (iCount - slotCount / 2 - 0.5), self.directY * iconPadding)
                end
            end
            width = slotCount * (iconSize + iconPadding)
            height = iconSize + 2 * iconPadding
        else
            local x1
            if (self.directX >= 0) then
                x1 = iconPadding
            else
                x1 = -iconPadding
            end
            local y1
            if (self.directY >= 0) then
                y1 = iconPadding
            else
                y1 = -iconPadding
            end
            local x = x1
            local y = y1
            local previous_was_second_line = true
            local first_line_count = 0
            local has_second_line = false
            for i, icon in ipairs(self.icons) do
                if (icon.talentActive) then
                    if (first_line_count == 0 or previous_was_second_line or self.overlaps[i]) then
                        -- on le met sur la première ligne
                        if (first_line_count == 0) then
                            x = x1
                            y = y1
                            first_line_count = 1
                        else
                            if (self.vertical) then
                                x = x1
                                if (not self.overlaps[i]) then
                                    y = y + self.directY * (iconSize + iconPadding) / 2
                                    first_line_count = first_line_count + 1
                                end
                            else
                                if (not self.overlaps[i]) then
                                    x = x + self.directX * (iconSize + iconPadding) / 2
                                    first_line_count = first_line_count + 1
                                end
                                y = y1
                            end
                        end
                        previous_was_second_line = false
                    else
                        -- on le met sur la seconde ligne
                        if (self.vertical) then
                            x = x1 + self.directX * (iconSize + iconPadding)
                            if (not self.overlaps[i]) then
                                y = y + self.directY * (iconSize + iconPadding) / 2
                            end
                        else
                            if (not self.overlaps[i]) then
                                x = x + self.directX * (iconSize + iconPadding) / 2
                            end
                            y = y1 + self.directY * (iconSize + iconPadding)
                        end
                        has_second_line = true
                        previous_was_second_line = true
                    end
                    icon:setPosition(x, y)
                end
            end
            if (self.vertical) then
                if (has_second_line) then
                    width = iconPadding + (iconSize + iconPadding) * (1 + math.sqrt(3) / 2)
                else
                    width = iconSize + 2 * iconPadding
                end
                if (previous_was_second_line) then
                    height = iconPadding + (first_line_count + 0.5) * (iconSize + iconPadding)
                else
                    height = iconPadding + first_line_count * (iconSize + iconPadding)
                end
            else
                if (previous_was_second_line) then
                    width = iconPadding + (first_line_count + 0.5) * (iconSize + iconPadding)
                else
                    width = iconPadding + first_line_count * (iconSize + iconPadding)
                end
                if (has_second_line) then
                    height = iconPadding + (iconSize + iconPadding) * (1 + math.sqrt(3) / 2)
                else
                    height = iconSize + 2 * iconPadding
                end
            end
        end
        self.frame:SetSize(width, height)
        self.frame:SetPoint(self.anchor, UIParent, "CENTER", offX, offY)
        if (self.background) then
            self.background:SetSize(width, height)
            self.background:SetPoint(self.anchor, UIParent, "CENTER", offX, offY)
        end
    end
end

---@private
---@param overlapPrevious boolean|nil
---@return number
function HUDUtilityGroup:manageOverlap_returnFrameLevel(overlapPrevious)
    if (overlapPrevious) then
        self.currentFrameLevel = self.currentFrameLevel + 1
        table.insert(self.overlaps, true)
    else
        self.currentFrameLevel = 1
        table.insert(self.overlaps, false)
    end
    return self.currentFrameLevel
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param overlapPrevious boolean|nil
---@return HUDCooldownIcon
function HUDUtilityGroup:AddCooldown(data, iconID, talent, overlapPrevious)
    local frameLevel = self:manageOverlap_returnFrameLevel(overlapPrevious)
    local icon = HUDCooldownIcon:create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, data, iconID, talent)
    table.insert(self.icons, icon)
    return icon
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param overlapPrevious boolean|nil
---@param displayAsCooldown boolean|nil
---@return HUDAuraIcon
function HUDUtilityGroup:AddAura(data, iconID, talent, overlapPrevious, displayAsCooldown)
    local frameLevel = self:manageOverlap_returnFrameLevel(overlapPrevious)
    local icon = HUDAuraIcon:create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, data, iconID, talent, displayAsCooldown)
    table.insert(self.icons, icon)
    return icon
end

---@param slot unknown
---@param initIconID number
function HUDUtilityGroup:AddEquipment(slot, initIconID)
    local frameLevel = self:manageOverlap_returnFrameLevel(false)
    local data = HUDEquipmentCooldown:create(slot, self.hud)
    local icon = HUDEquipmentIcon:Create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, data, initIconID)
    table.insert(self.icons, icon)
    return icon
end

---@param data HUDBagItem
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
function HUDUtilityGroup:AddBagItem(data, iconID, talent)
    local frameLevel = self:manageOverlap_returnFrameLevel(false)
    local icon = HUDBagItemIcon:create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, data, iconID, talent)
    table.insert(self.icons, icon)
    return icon
end

---@param data HUDAura
---@param iconID integer|nil
---@param talent ERALIBTalent|nil
---@return HUDIconMissingAuraAlert
function HUDUtilityGroup:AddMissingAuraAlert(data, iconID, talent)
    local frameLevel = self:manageOverlap_returnFrameLevel(false)
    local icon = HUDIconMissingAuraAlert:create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, talent, iconID, data)
    table.insert(self.icons, icon)
    return icon
end

---@param data HUDPublicBoolean
---@param iconID integer
---@param talent ERALIBTalent|nil
---@return HUDIconBooleanAlert
function HUDUtilityGroup:AddBooleanAlert(data, iconID, talent)
    local frameLevel = self:manageOverlap_returnFrameLevel(false)
    local icon = HUDIconBooleanAlert:create(self.frame, frameLevel, self.anchor, self.anchor, self.iconSize, talent, iconID, data)
    table.insert(self.icons, icon)
    return icon
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region CONSTRUCTORS ---------------------------------------------------------------------------------------------------------

---@class ChannelTickInfo
---@field tickCount number
---@field tickDelta number

---@param tickCount number
---@param tickDelta number
function HUDModule:AddChannelInfo(spellID, tickCount, tickDelta)
    local info = {}
    info.tickCount = tickCount
    info.tickDelta = tickDelta
    self.channelInfo[spellID] = info
end

---@param cd HUDCooldown
function HUDModule:AddKickInfo(cd)
    table.insert(self.kicks, cd)
end

---@param spellID number
---@param talent ERALIBTalent|nil
---@return HUDCooldown
function HUDModule:AddCooldown(spellID, talent)
    return HUDCooldown:Create(spellID, self, talent)
end

---@param spellID number
---@param isTarget boolean
---@param talent ERALIBTalent|nil
---@return HUDAura
function HUDModule:AddAuraByPlayer(spellID, isTarget, talent)
    return HUDAura:createAura(spellID, self, talent, isTarget)
end

---@param itemID number
---@param talent ERALIBTalent|nil
---@return HUDBagItem
function HUDModule:AddBagItem(itemID, talent)
    return HUDBagItem:create(itemID, self, talent)
end

---@return HUDHealth
function HUDModule:AddPetHealth()
    return HUDHealth:Create(self, "pet")
end

---@param spellID number
---@param talent ERALIBTalent|nil
---@return HUDPublicBooleanSpellOverlay
function HUDModule:AddSpellOverlayBoolean(spellID, talent)
    return HUDPublicBooleanSpellOverlay:create(self, talent, spellID)
end

---@param aura HUDAura
---@return HUDPublicBooleanAuraActive
function HUDModule:AddAuraBoolean(aura)
    return HUDPublicBooleanAuraActive:create(self, aura)
end

---@param b1 HUDPublicBoolean
---@param b2 HUDPublicBoolean
---@return HUDPublicBooleanAnd
function HUDModule:AddPublicBooleanAnd(b1, b2)
    return HUDPublicBooleanAnd:create(self, b1, b2)
end

---@param b1 HUDPublicBoolean
---@param b2 HUDPublicBoolean
---@return HUDPublicBooleanOr
function HUDModule:AddPublicBooleanOr(b1, b2)
    return HUDPublicBooleanOr:create(self, b1, b2)
end

---@param spellID number
---@param iconID number
---@param talent ERALIBTalent|nil
---@return HUDPublicBooleanSpellIcon
function HUDModule:AddIconBoolean(spellID, iconID, talent)
    return HUDPublicBooleanSpellIcon:create(self, talent, spellID, iconID)
end

---@param shapeshiftIndex number
---@return HUDPublicBooleanShapeshift
function HUDModule:AddShapeshiftBoolean(shapeshiftIndex)
    return HUDPublicBooleanShapeshift:create(self, shapeshiftIndex)
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param r number
---@param g number
---@param b number
---@param addTimerBar nil|boolean
---@return HUDCooldownIcon, HUDEssentialsSlot, nil|HUDTimerBar
function HUDModule:AddEssentialsCooldown(data, iconID, talent, r, g, b, addTimerBar)
    local icon = HUDCooldownIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    icon:SetBorderColor(r, g, b)
    local placement = HUDEssentialsSlot:create(icon, self)
    table.insert(self.essentialsIcons, placement)
    if (addTimerBar == true or not (addTimerBar == false)) then
        local bar = HUDTimerBar:create(placement, 0.5, data, talent, r, g, b, self.timerFrameBack)
        return icon, placement, bar
    else
        return icon, placement, nil
    end
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param rBar number|nil
---@param gBar number|nil
---@param bBar number|nil
---@return HUDAuraIcon, HUDEssentialsSlot, nil|HUDTimerBar
function HUDModule:AddEssentialsAura(data, iconID, talent, rBar, gBar, bBar)
    local icon = HUDAuraIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    local placement = HUDEssentialsSlot:create(icon, self)
    table.insert(self.essentialsIcons, placement)
    if (rBar and gBar and bBar) then
        local bar = HUDTimerBar:create(placement, 0.5, data, talent, rBar, gBar, bBar, self.timerFrameBack)
        icon:SetBorderColor(rBar, gBar, bBar)
        return icon, placement, bar
    else
        return icon, placement, nil
    end
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@param rBar number
---@param gBar number
---@param bBar number
---@return HUDAuraIcon, HUDEssentialsSlot, HUDTimerBar
function HUDModule:AddDOT(data, iconID, talent, rBar, gBar, bBar)
    local icon = HUDAuraIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    icon:SetBorderColor(rBar, gBar, bBar)
    local placement = HUDEssentialsSlot:create(icon, self)
    table.insert(self.essentialsIcons, placement)
    local bar = HUDTimerBar:create(placement, 0.5, data, talent, rBar, gBar, bBar, self.timerFrameBack)
    bar.showPandemic = true
    icon.showRedIfMissingInCombat = true
    return icon, placement, bar
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddEssentialsLeftCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsLeftSideIcons, icon)
    return icon
end

---@param data HUDCooldown
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDCooldownIcon
function HUDModule:AddEssentialsRightCooldown(data, iconID, talent)
    local icon = HUDCooldownIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsRightSideIcons, icon)
    return icon
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon
function HUDModule:AddEssentialsLeftAura(data, iconID, talent)
    local icon = HUDAuraIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsLeftSideIcons, icon)
    return icon
end

---@param data HUDAura
---@param iconID number|nil
---@param talent ERALIBTalent|nil
---@return HUDAuraIcon
function HUDModule:AddEssentialsRightAura(data, iconID, talent)
    local icon = HUDAuraIcon:create(self.essentialsFrame, 1, "TOP", "CENTER", self.options.essentialsIconSize, data, iconID, talent)
    table.insert(self.essentialsRightSideIcons, icon)
    return icon
end

---@param afterHealth boolean
---@return HUDResourceSlot
function HUDModule:AddResourceSlot(afterHealth)
    local slot = HUDResourceSlot:create(self)
    if (afterHealth) then
        table.insert(self.resourceAfterHealth, slot)
    else
        table.insert(self.resourceBeforeHealth, slot)
    end
    return slot
end

---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerLowIdle
function HUDModule:AddPowerLowIdle(powerType, talent)
    return HUDPowerLowIdle:Create(self, powerType, talent)
end

---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerHighIdle
function HUDModule:AddPowerHighIdle(powerType, talent)
    return HUDPowerHighIdle:Create(self, powerType, talent)
end

---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@param targetPercent fun(self:HUDPowerTargetIdle): number
---@return HUDPowerTargetIdle
function HUDModule:AddPowerTargetIdle(powerType, talent, targetPercent)
    return HUDPowerTargetIdle:create(self, powerType, talent, targetPercent)
end

---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertAura
function HUDModule:AddAuraOverlayAlert(data, talent, texture, isAtlas, transform, position)
    return HUDSAOAlertAura:create(self, data, talent, texture, isAtlas, transform, position)
end

---@param data HUDAura
---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param showOutOfCombat boolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertMissingAura
function HUDModule:AddMissingAuraOverlayAlert(data, talent, texture, isAtlas, showOutOfCombat, transform, position)
    return HUDSAOAlertMissingAura:create(self, data, talent, texture, isAtlas, showOutOfCombat, transform, position)
end

---@param talent ERALIBTalent|nil
---@param texture string|number
---@param isAtlas boolean
---@param data HUDPublicBoolean
---@param transform SAOTransform
---@param position SAOPosition
---@return HUDSAOAlertPublicBoolean
function HUDModule:AddPublicBooleanOverlayAlert(talent, texture, isAtlas, data, transform, position)
    return HUDSAOAlertPublicBoolean:create(self, talent, texture, isAtlas, data, transform, position)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

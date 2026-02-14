----------------------------------------------------------------
--#region GENERIC DATA -----------------------------------------

---@class (exact) HUDDataItem
---@field private __index HUDDataItem
---@field talent ERALIBTalent|nil
---@field talentActive boolean
---@field hud HUDModule
---@field Update fun(self:HUDDataItem, t:number, combat:boolean)
---@field protected constructItem fun(self:HUDDataItem, hud:HUDModule, talent:ERALIBTalent|nil)
---@field protected talentIsActive fun(self:HUDDataItem)
HUDDataItem = {}
HUDDataItem.__index = HUDDataItem

function HUDDataItem:constructItem(hud, talent)
    self.talent = talent
    self.hud = hud
    hud:addData(self)
end

---comment
---@return boolean
function HUDDataItem:computeTalentActive()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.talentActive = false
        self:talentIsNotActive()
        return false
    else
        self.talentActive = true
        self:talentIsActive()
        return true
    end
end
function HUDDataItem:talentIsActive()
end
function HUDDataItem:talentIsNotActive()
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region HEALTH -----------------------------------------------

---@class (exact) HUDHealth : HUDDataItem
---@field private __index HUDHealth
---@field unit "player"|"pet"
---@field health number
---@field maxHealth number
---@field healthPercent100 number
---@field goodAbsorb number
---@field badAbsorb number
---@field unitExists boolean
---@field private calc UnitHealPredictionCalculator
HUDHealth = {}
HUDHealth.__index = HUDHealth
setmetatable(HUDHealth, { __index = HUDDataItem })

---comment
---@param hud HUDModule
---@param unit "player"|"pet"
---@return HUDHealth
function HUDHealth:Create(hud, unit)
    local x = {}
    setmetatable(x, HUDHealth)
    ---@cast x HUDHealth
    x:constructItem(hud)
    x.unit = unit
    x.health = 1
    x.maxHealth = 2
    x.healthPercent100 = 50
    x.goodAbsorb = 0
    x.badAbsorb = 0
    x.calc = CreateUnitHealPredictionCalculator()
    x.calc:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.MaximumHealth)
    x.calc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth)
    return x
end

function HUDHealth:Update()
    if (UnitExists(self.unit)) then
        self.unitExists = true
        self.health = UnitHealth(self.unit)
        self.maxHealth = UnitHealthMax(self.unit)
        self.healthPercent100 = UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)
        UnitGetDetailedHealPrediction(self.unit, nil, self.calc)
        --self.goodAbsorb = UnitGetTotalAbsorbs(self.unit)
        --self.badAbsorb = UnitGetTotalHealAbsorbs(self.unit)
        self.goodAbsorb = self.calc:GetDamageAbsorbs()
        self.badAbsorb = self.calc:GetHealAbsorbs()
    else
        self.unitExists = false
        self.health = 0
        self.maxHealth = 1
        self.healthPercent100 = 0
        self.goodAbsorb = 0
        self.badAbsorb = 0
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region POWER ------------------------------------------------

---@class (exact) HUDPower : HUDDataItem
---@field private __index HUDPower
---@field powerType Enum.PowerType
---@field current number
---@field max number
---@field maxNotSecret number
---@field percent100 number
---@field idleAlphaOOC number
---@field protected updateIdleAlpha fun(self:HUDPower): number
---@field protected powerTalentIsActive nil|fun(self:HUDPower): number
HUDPower = {}
HUDPower.__index = HUDPower
setmetatable(HUDPower, { __index = HUDDataItem })

---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
function HUDPower:constructPower(hud, powerType, talent)
    self.current = 0
    self.max = 100
    self.maxNotSecret = 100
    self.powerType = powerType
    self:constructItem(hud, talent)
end

function HUDPower:talentIsActive()
    self.maxNotSecret = UnitPowerMax("player", self.powerType)
    if (self.maxNotSecret < 1) then
        self.maxNotSecret = 1
    end
    if (self.powerTalentIsActive) then
        self:powerTalentIsActive()
    end
end

---comment
---@param t number
---@param combat boolean
function HUDPower:Update(t, combat)
    self.current = UnitPower("player", self.powerType)
    self.max = UnitPowerMax("player", self.powerType)
    self.percent100 = UnitPowerPercent("player", self.powerType, false, CurveConstants.ScaleTo100)
    if (not combat) then
        self.idleAlphaOOC = self:updateIdleAlpha()
    end
end

---@class (exact) HUDPowerLowIdle : HUDPower
---@field private __index HUDPowerLowIdle
HUDPowerLowIdle = {}
HUDPowerLowIdle.__index = HUDPowerLowIdle
setmetatable(HUDPowerLowIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerLowIdle
function HUDPowerLowIdle:Create(hud, powerType, talent)
    local x = {}
    setmetatable(x, HUDPowerLowIdle)
    ---@cast x HUDPowerLowIdle
    x:constructPower(hud, powerType, talent)
    return x
end
function HUDPowerLowIdle:updateIdleAlpha()
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.hud.curveHide4pctEmpty)
end

---@class (exact) HUDPowerHighIdle : HUDPower
---@field private __index HUDPowerHighIdle
HUDPowerHighIdle = {}
HUDPowerHighIdle.__index = HUDPowerHighIdle
setmetatable(HUDPowerHighIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@return HUDPowerHighIdle
function HUDPowerHighIdle:Create(hud, powerType, talent)
    local x = {}
    setmetatable(x, HUDPowerHighIdle)
    ---@cast x HUDPowerHighIdle
    x:constructPower(hud, powerType, talent)
    return x
end
function HUDPowerHighIdle:updateIdleAlpha()
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.hud.curveHide96pctFull)
end

---@class (exact) HUDPowerTargetIdle : HUDPower
---@field private __index HUDPowerTargetIdle
---@field private idleCurve LuaCurveObject
---@field private idleValueGetter fun(): number
---@field private idleValueResult number
---@field private idlePercent number
HUDPowerTargetIdle = {}
HUDPowerTargetIdle.__index = HUDPowerTargetIdle
setmetatable(HUDPowerTargetIdle, { __index = HUDPower })
---comment
---@param hud HUDModule
---@param powerType Enum.PowerType
---@param talent ERALIBTalent|nil
---@param idleValue fun(): number
---@return HUDPowerTargetIdle
function HUDPowerTargetIdle:create(hud, powerType, talent, idleValue)
    local x = {}
    setmetatable(x, HUDPowerTargetIdle)
    ---@cast x HUDPowerTargetIdle
    x:constructPower(hud, powerType, talent)
    x.idleCurve = C_CurveUtil:CreateCurve()
    x.idleCurve:SetType(Enum.LuaCurveType.Step)
    x.idleValueGetter = idleValue
    return x
end
function HUDPowerTargetIdle:powerTalentIsActive()
    self.idleValueResult = self.idleValueGetter()
end
function HUDPowerTargetIdle:updateIdleAlpha()
    local pct = self.idleValueResult / self.max
    if (pct ~= self.idlePercent) then
        self.idlePercent = pct
        self.idleCurve:ClearPoints()
        self.idleCurve:AddPoint(pct - 1, 1)
        self.idleCurve:AddPoint(pct - 0.011, 1)
        self.idleCurve:AddPoint(pct - 0.01, 0)
        self.idleCurve:AddPoint(pct + 0.01, 0)
        self.idleCurve:AddPoint(pct + 0.011, 1)
        self.idleCurve:AddPoint(pct + 1, 1)
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    return UnitPowerPercent("player", self.powerType, false, self.idleCurve)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region GENERIC TIMER ----------------------------------------

---@class (exact) HUDTimer : HUDDataItem
---@field private __index HUDTimer
---@field protected constructTimer fun(self:HUDTimer, hud:HUDModule, talent:ERALIBTalent|nil)
---@field protected updateTimerDuration fun(self:HUDTimer, t:number): LuaDurationObject
---@field timerDuration LuaDurationObject
---@field alphaDuration nil|LuaDurationObject
HUDTimer = {}
HUDTimer.__index = HUDTimer
setmetatable(HUDTimer, { __index = HUDDataItem })

function HUDTimer:constructTimer(hud, talent)
    self:constructItem(hud, talent)
end

function HUDTimer:Update(t)
    self.timerDuration = self:updateTimerDuration(t)
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region COOLDOWN ---------------------------------------------

---@class (exact) HUDCooldown : HUDTimer
---@field private __index HUDCooldown
---@field spellID number
---@field private cdData SpellCooldownInfo|nil
---@field cooldownDuration LuaDurationObject
---@field swipeDuration LuaDurationObject
---@field maxCharges number
---@field currentCharges number
---@field hasCharges boolean
---@field isSpecialIf HUDPublicBoolean|nil
---@field private must_update_max_charges boolean
---@field alphaDuration nil|LuaDurationObject -- inherited
HUDCooldown = {}
HUDCooldown.__index = HUDCooldown
setmetatable(HUDCooldown, { __index = HUDTimer })

---comment
---@param spellID number
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@return HUDCooldown
function HUDCooldown:Create(spellID, hud, talent)
    local x = {}
    setmetatable(x, HUDCooldown)
    ---@cast x HUDCooldown
    x:constructTimer(hud, talent)

    x.spellID = spellID
    x.must_update_max_charges = true

    return x
end

function HUDCooldown:talentIsActive()
    local charges = C_Spell.GetSpellCharges(self.spellID)
    ---@diagnostic disable-next-line: param-type-mismatch
    if (charges and issecretvalue(charges.maxCharges)) then
        self.must_update_max_charges = true
    else
        self.must_update_max_charges = false
        if (charges and charges.maxCharges > 1) then
            self.hasCharges = true
            self.maxCharges = charges.maxCharges
        else
            self.hasCharges = false
            self.maxCharges = 1
        end
    end
end

function HUDCooldown:updateTimerDuration(t)
    self.cdData = C_Spell.GetSpellCooldown(self.spellID)

    local charges

    if (self.must_update_max_charges) then
        charges = C_Spell.GetSpellCharges(self.spellID)
        if (charges) then
            ---@diagnostic disable-next-line: param-type-mismatch
            if (issecretvalue(charges.maxCharges)) then
                -- on suppose qu'il y a des charges > 1
                self.hasCharges = true
                self.maxCharges = charges.maxCharges
            else
                self.hasCharges = charges.maxCharges > 1
                self.maxCharges = charges.maxCharges
                self.must_update_max_charges = false
            end
        else
            self.hasCharges = false
        end
    end

    if (self.hasCharges) then
        if (not charges) then
            charges = C_Spell.GetSpellCharges(self.spellID)
        end
        if (charges) then
            self.hasCharges = true
            self.maxCharges = charges.maxCharges
            self.currentCharges = charges.currentCharges
            self.swipeDuration = C_Spell.GetSpellChargeDuration(self.spellID)
            if ((not self.cdData) or self.cdData.isOnGCD == true) then
                self.cooldownDuration = self.hud.duration0
            else
                self.cooldownDuration = C_Spell.GetSpellCooldownDuration(self.spellID)
                if (not self.cooldownDuration) then
                    self.cooldownDuration = self.hud.duration0
                end
            end
            self.alphaDuration = self.cooldownDuration
            return self.swipeDuration
        end
    end
    self.alphaDuration = nil
    self.maxCharges = 1
    if ((not self.cdData) or self.cdData.isOnGCD == true) then
        self.swipeDuration = self.hud.duration0
    else
        self.swipeDuration = C_Spell.GetSpellCooldownDuration(self.spellID)
        if (not self.swipeDuration) then
            self.swipeDuration = self.hud.duration0
        end
    end
    self.cooldownDuration = self.swipeDuration
    return self.swipeDuration
end

--#endregion
----------------------------------------------------------------

---------------------------------------------------------------
--#region EQUIPMENT COOLDOWN ----------------------------------

---@class (exact) HUDEquipmentCooldown : HUDTimer
---@field private __index HUDCooldown
---@field slot unknown
---@field start number
---@field duration number
HUDEquipmentCooldown = {}
HUDEquipmentCooldown.__index = HUDEquipmentCooldown
setmetatable(HUDEquipmentCooldown, { __index = HUDTimer })

---comment
---@param slot unknown
---@param hud HUDModule
---@return HUDEquipmentCooldown
function HUDEquipmentCooldown:create(slot, hud)
    local x = {}
    setmetatable(x, HUDEquipmentCooldown)
    ---@cast x HUDEquipmentCooldown
    x:constructTimer(hud, ERALIBTalent:CreateEquipmentCD(slot))

    x.slot = slot

    return x
end

function HUDEquipmentCooldown:updateTimerDuration(t)
    local s, d, enabled = GetInventoryItemCooldown("player", self.slot)
    if (enabled) then
        self.start = s
        self.duration = d
    else
        self.start = 0
        self.duration = 1
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region AURA -------------------------------------------------

---@class (exact) HUDAura : HUDTimer
---@field private __index HUDAura
---@field spellID number
---@field isTarget boolean
---@field private unit string
---@field stacks number
---@field stacksDisplay string|nil
---@field auraIsPresent boolean
---@field cdmFrameFound boolean
---@field useUnitCDM boolean
---@field icon number
---@field playSoundWhenApperars nil|number
---@field private cdmFrame CDMAuraFrame
HUDAura = {}
HUDAura.__index = HUDAura
setmetatable(HUDAura, { __index = HUDTimer })

---comment
---@param spellID number
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param isTarget boolean
---@return HUDAura
function HUDAura:createAura(spellID, hud, talent, isTarget)
    local x = {}
    setmetatable(x, HUDAura)
    ---@cast x HUDAura
    x:constructTimer(hud, talent)
    x.spellID = spellID
    x.isTarget = isTarget
    x.stacks = 0
    x.auraIsPresent = false
    if (isTarget) then
        x.unit = "target"
    else
        x.unit = "player"
    end
    return x
end

function HUDAura:talentIsActive()
    self.hud:addActiveAura(self, self.isTarget)
end
function HUDAura:talentIsNotActive()
    self.stacks = 0
    self.stacksDisplay = nil
    self.auraIsPresent = false
end

function HUDAura:prepareParseCDM()
    self.cdmFrame = nil
    self.cdmFrameFound = false
end
---@param frame CDMAuraFrame
function HUDAura:setCDM(frame)
    self.cdmFrame = frame
    self.cdmFrameFound = true
end

--[[
---@param dur LuaDurationObject
---@param a AuraData
function HUDAura:auraFound(dur, a)
    self.auraDuration = dur
    self.stacks = a.charges
    if (self.isTarget) then
        self.stacksDisplay = C_UnitAuras.GetAuraApplicationDisplayCount("target", a.auraInstanceID)
    else
        self.stacksDisplay = C_UnitAuras.GetAuraApplicationDisplayCount("player", a.auraInstanceID)
    end
    self.found = true
end
]]

function HUDAura:updateTimerDuration(t)
    if (self.cdmFrame and self.cdmFrame.auraInstanceID) then
        local unit
        if (self.useUnitCDM) then
            unit = self.cdmFrame.auraDataUnit
        else
            unit = self.unit
        end
        ---@cast unit unknown
        local cdmData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, self.cdmFrame.auraInstanceID)
        if (not self.auraIsPresent) then
            self.auraIsPresent = true
            if (self.playSoundWhenApperars) then
                ---@diagnostic disable-next-line: param-type-mismatch
                C_Sound.PlaySound(self.playSoundWhenApperars, "SFX", true)
            end
        end
        if (cdmData) then
            self.stacks = cdmData.applications
            self.stacksDisplay = C_UnitAuras.GetAuraApplicationDisplayCount(unit, self.cdmFrame.auraInstanceID)
            self.icon = cdmData.icon
            local result = C_UnitAuras.GetAuraDuration(unit, self.cdmFrame.auraInstanceID)
            if (result) then
                return result
            else
                return self.hud.duration0
            end
        else
            self.stacks = 0
            self.stacksDisplay = nil
            return self.hud.duration0
        end
    else
        self.stacks = 0
        self.stacksDisplay = nil
        self.auraIsPresent = false
        return self.hud.duration0
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region BAG ITEM ---------------------------------------------

---@class (exact) HUDBagItem : HUDTimer
---@field private __index HUDBagItem
---@field itemID integer
---@field stacks integer
---@field stacksDisplay string|nil
---@field hasItem boolean
---@field private bagID integer
---@field private slot integer
---@field private duration LuaDurationObject
HUDBagItem = {}
HUDBagItem.__index = HUDBagItem
setmetatable(HUDBagItem, { __index = HUDTimer })

---comment
---@param itemID integer
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@return HUDBagItem
function HUDBagItem:create(itemID, hud, talent)
    local x = {}
    setmetatable(x, HUDBagItem)
    ---@cast x HUDBagItem
    x:constructTimer(hud, talent)
    x.itemID = itemID
    x.stacks = 0
    x.bagID = -1
    x.slot = -1
    x.hasItem = false
    x.duration = C_DurationUtil.CreateDuration()
    hud:addBagItem(x)
    return x
end

function HUDBagItem:talentIsActive()
    self:bagUpdate()
end
function HUDBagItem:talentIsNotActive()
    self.stacks = 0
    self.stacksDisplay = nil
    self.hasItem = false
end

function HUDBagItem:bagUpdate()
    if (self.talentActive) then
        self.bagID = -1
        self.slot = -1
        for i = 0, NUM_BAG_SLOTS do
            local cpt = C_Container.GetContainerNumSlots(i)
            for j = 1, cpt do
                local id = C_Container.GetContainerItemID(i, j)
                if (id == self.itemID) then
                    self.bagID = i
                    self.slot = j
                    break
                end
            end
            if (self.bagID >= 0) then
                break
            end
        end
        self.hasItem = self.bagID >= 0
    end
end

function HUDBagItem:updateTimerDuration(t)
    if (self.hasItem) then
        self.stacks = C_Item.GetItemCount(self.itemID, false, true, false, false)
        -- voir aussi : C_Container.GetItemCooldown et C_Item.GetItemCooldown
        local start, duration, enable = C_Container.GetContainerItemCooldown(self.bagID, self.slot)
        if (start and duration and enable) then
            self.duration:SetTimeFromStart(start, duration)
            return self.duration
        else
            return self.hud.duration0
        end
    else
        self.stacks = 0
        return self.hud.duration0
    end
end

--#endregion
----------------------------------------------------------------

----------------------------------------------------------------
--#region PUBLIC BOOLEAN DATA ----------------------------------

---@class (exact) HUDPublicBoolean : HUDDataItem
---@field private __index HUDPublicBoolean
---@field value boolean
---@field reverse boolean
---@field protected getValue fun(self:HUDPublicBoolean, t:number, combat:boolean): boolean
HUDPublicBoolean = {}
HUDPublicBoolean.__index = HUDPublicBoolean
setmetatable(HUDPublicBoolean, { __index = HUDDataItem })

---comment
---@param hud HUDModule
---@param talent ERALIBTalent|nil
function HUDPublicBoolean:constructBoolean(hud, talent)
    self:constructItem(hud, talent)
end

function HUDPublicBoolean:talentIsNotActive()
    self.value = false
end

---comment
---@param t number
---@param combat boolean
function HUDPublicBoolean:Update(t, combat)
    self.value = self:getValue(t, combat)
    if (self.reverse) then
        self.value = not self.value
    end
end

---@class (exact) HUDPublicBooleanSpellIcon : HUDPublicBoolean
---@field private __index HUDPublicBooleanSpellIcon
---@field private spellID number
---@field private iconID number
HUDPublicBooleanSpellIcon = {}
HUDPublicBooleanSpellIcon.__index = HUDPublicBooleanSpellIcon
setmetatable(HUDPublicBooleanSpellIcon, { __index = HUDPublicBoolean })
---comment
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param spellID number
---@param iconID number
function HUDPublicBooleanSpellIcon:create(hud, talent, spellID, iconID)
    local x = {}
    setmetatable(x, HUDPublicBooleanSpellIcon)
    ---@cast x HUDPublicBooleanSpellIcon
    x:constructBoolean(hud, talent)
    x.spellID = spellID
    x.iconID = iconID
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanSpellIcon:getValue(t, combat)
    local info = C_Spell.GetSpellInfo(self.spellID)
    if (info) then
        return info.iconID == self.iconID
    else
        return false
    end
end

---@class (exact) HUDPublicBooleanSpellOverlay : HUDPublicBoolean
---@field private __index HUDPublicBooleanSpellOverlay
---@field private spellID number
HUDPublicBooleanSpellOverlay = {}
HUDPublicBooleanSpellOverlay.__index = HUDPublicBooleanSpellOverlay
setmetatable(HUDPublicBooleanSpellOverlay, { __index = HUDPublicBoolean })
---@param hud HUDModule
---@param talent ERALIBTalent|nil
---@param spellID number
function HUDPublicBooleanSpellOverlay:create(hud, talent, spellID)
    local x = {}
    setmetatable(x, HUDPublicBooleanSpellOverlay)
    ---@cast x HUDPublicBooleanSpellOverlay
    x:constructBoolean(hud, talent)
    x.spellID = spellID
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanSpellOverlay:getValue(t, combat)
    return C_SpellActivationOverlay.IsSpellOverlayed(self.spellID)
end

---@class (exact) HUDPublicBooleanAuraActive : HUDPublicBoolean
---@field private __index HUDPublicBooleanAuraActive
---@field private aura HUDAura
HUDPublicBooleanAuraActive = {}
HUDPublicBooleanAuraActive.__index = HUDPublicBooleanAuraActive
setmetatable(HUDPublicBooleanAuraActive, { __index = HUDPublicBoolean })
---@param hud HUDModule
---@param aura HUDAura
function HUDPublicBooleanAuraActive:create(hud, aura)
    local x = {}
    setmetatable(x, HUDPublicBooleanAuraActive)
    ---@cast x HUDPublicBooleanAuraActive
    x:constructBoolean(hud, aura.talent)
    x.aura = aura
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanAuraActive:getValue(t, combat)
    return self.aura.auraIsPresent
end

---@class (exact) HUDPublicBooleanShapeshift : HUDPublicBoolean
---@field private __index HUDPublicBooleanShapeshift
---@field private shapeshiftIndex number
HUDPublicBooleanShapeshift = {}
HUDPublicBooleanShapeshift.__index = HUDPublicBooleanShapeshift
setmetatable(HUDPublicBooleanShapeshift, { __index = HUDPublicBoolean })
---@param hud HUDModule
---@param shapeshiftIndex number
function HUDPublicBooleanShapeshift:create(hud, shapeshiftIndex)
    local x = {}
    setmetatable(x, HUDPublicBooleanShapeshift)
    ---@cast x HUDPublicBooleanShapeshift
    x:constructBoolean(hud, nil)
    x.shapeshiftIndex = shapeshiftIndex
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanShapeshift:getValue(t, combat)
    return self.shapeshiftIndex == GetShapeshiftForm()
end

---@class (exact) HUDPublicBooleanAnd : HUDPublicBoolean
---@field private __index HUDPublicBooleanAnd
---@field private shapeshiftIndex number
---@field private b1 HUDPublicBoolean
---@field private b2 HUDPublicBoolean
HUDPublicBooleanAnd = {}
HUDPublicBooleanAnd.__index = HUDPublicBooleanAnd
setmetatable(HUDPublicBooleanAnd, { __index = HUDPublicBoolean })
---@param hud HUDModule
---@param b1 HUDPublicBoolean
---@param b2 HUDPublicBoolean
function HUDPublicBooleanAnd:create(hud, b1, b2)
    local x = {}
    setmetatable(x, HUDPublicBooleanAnd)
    ---@cast x HUDPublicBooleanAnd
    x:constructBoolean(hud, nil)
    x.b1 = b1
    x.b2 = b2
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanAnd:getValue(t, combat)
    return self.b1.value and self.b2.value
end

---@class (exact) HUDPublicBooleanOr : HUDPublicBoolean
---@field private __index HUDPublicBooleanOr
---@field private shapeshiftIndex number
---@field private b1 HUDPublicBoolean
---@field private b2 HUDPublicBoolean
HUDPublicBooleanOr = {}
HUDPublicBooleanOr.__index = HUDPublicBooleanOr
setmetatable(HUDPublicBooleanOr, { __index = HUDPublicBoolean })
---@param hud HUDModule
---@param b1 HUDPublicBoolean
---@param b2 HUDPublicBoolean
function HUDPublicBooleanOr:create(hud, b1, b2)
    local x = {}
    setmetatable(x, HUDPublicBooleanOr)
    ---@cast x HUDPublicBooleanOr
    x:constructBoolean(hud, nil)
    x.b1 = b1
    x.b2 = b2
    return x
end
---@param t number
---@param combat boolean
---@return boolean
function HUDPublicBooleanOr:getValue(t, combat)
    return self.b1.value or self.b2.value
end

--#endregion
----------------------------------------------------------------

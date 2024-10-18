ERAGroupFrame_DispellSize = 10
ERAGroupFrame_AuraSize = 20
ERAGroupFrame_CellPadding = 2
ERAGroupFrame_UnitPadding = 1
ERAGroupFrame_UnitBorderThickness = 2
ERAGroupFrame_HealthOffsetFromMainFrame = ERAGroupFrame_UnitBorderThickness + ERAGroupFrame_UnitPadding
ERAGroupFrame_HealthOffsetFromCell = ERAGroupFrame_CellPadding + ERAGroupFrame_HealthOffsetFromMainFrame
ERAGroupFrame_HealthWidth = math.max(105, 5 * ERAGroupFrame_AuraSize)
ERAGroupFrame_CellWidth = ERAGroupFrame_HealthWidth + 2 * ERAGroupFrame_HealthOffsetFromCell
ERAGroupFrame_CellHeight = 44
ERAGroupFrame_HealthHeight = ERAGroupFrame_CellHeight - 2 * ERAGroupFrame_HealthOffsetFromCell
ERAGroupFrame_MainFrameWidthIncludingBorder = ERAGroupFrame_CellWidth - 2 * ERAGroupFrame_CellPadding

---@class ERAGroupFrame : ERACombatModule
---@field private __index unknown
---@field private enabledView boolean
---@field private groupEvents unknown
---@field private containerFrame Frame
---@field private combinedFrame ERAGroupSecureFrame
---@field private groupFrames ERAGroupSecureFrame[]
---@field private activeIsCombined boolean
---@field private byGroups boolean
---@field private unitByID table<string, ERAGroupUnitFrame>
---@field private iunits ERAGroupInvisibleUnit[]
---@field private iunitsCount integer
---@field private updateGroup fun(this:ERAGroupFrame)
---@field private updateBorders fun(this:ERAGroupFrame)
---@field private updateHealth fun(this:ERAGroupFrame, unitID:string)
---@field private hasBuffsAnyCaster boolean
---@field private buffs ERAGroupAuraDefinition[]
---@field private activeBuffs table<integer, ERAGroupAuraDefinition>
---@field private debuffs ERAGroupAuraDefinition[]
---@field private activeDebuffs table<integer, ERAGroupAuraDefinition>
---@field private displays ERAGroupAuraDisplay[]
---@field private activeDisplays ERAGroupAuraDisplay[]
---@field private dispells ERAGroupDispell[]
---@field private activeDispells ERAGroupDispell[]
---@field private update fun(this:ERAGroupFrame, t:number)
---@field private UpdateIdle fun(this:ERAGroupFrame, t:number)
---@field private UpdateCombat fun(this:ERAGroupFrame, t:number)
---@field UpdatedOverride fun(this:ERAGroupFrame, t:number, combat:boolean)
---@field isSolo boolean
ERAGroupFrame = {}
ERAGroupFrame.__index = ERAGroupFrame
setmetatable(ERAGroupFrame, { __index = ERACombatModule })

---------------------
--#region CONTENT ---

---@param spellID integer
---@param anyCaster boolean
---@param talent ERALIBTalent|nil
---@return ERAGroupAuraDefinition
function ERAGroupFrame:AddBuff(spellID, anyCaster, talent)
    local a = ERAGroupAuraDefinition:create(spellID, true, anyCaster, talent)
    table.insert(self.buffs, a)
    return a
end

---@param spellID integer
---@param anyCaster boolean
---@param talent ERALIBTalent|nil
---@return ERAGroupAuraDefinition
function ERAGroupFrame:AddDebuff(spellID, anyCaster, talent)
    local a = ERAGroupAuraDefinition:create(spellID, false, anyCaster, talent)
    table.insert(self.debuffs, a)
    return a
end

---@param aura ERAGroupAuraDefinition
---@param position integer
---@param priority number
---@param rC number
---@param gC number
---@param bC number
---@param rB number
---@param gB number
---@param bB number
---@param talent ERALIBTalent|nil
---@param displayAsMaxStacks integer|nil
---@return ERAGroupAuraDisplay
function ERAGroupFrame:AddDisplay(aura, position, priority, rC, gC, bC, rB, gB, bB, talent, displayAsMaxStacks)
    local d = ERAGroupAuraDisplay:create(aura, position, priority, rC, gC, bC, rB, gB, bB, talent, displayAsMaxStacks)
    table.insert(self.displays, d)
    return d
end

---@param hudCD ERACooldownBase
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param poison boolean
---@param disease boolean
---@param curse boolean
---@param bleed boolean
---@param r number|nil
---@param g number|nil
---@param b number|nil
---@param rCD number|nil
---@param gCD number|nil
---@param bCD number|nil
---@return ERAGroupDispell
function ERAGroupFrame:AddDispell(hudCD, talent, magic, poison, disease, curse, bleed, r, g, b, rCD, gCD, bCD)
    if r == nil then r = 1.0 end
    if g == nil then g = 1.0 end
    if b == nil then b = 1.0 end
    if rCD == nil then rCD = 0.5 end
    if gCD == nil then gCD = 0.5 end
    if bCD == nil then bCD = 0.5 end
    local d = ERAGroupDispell:create(hudCD, talent, magic, poison, disease, curse, bleed, r, g, b, rCD, gCD, bCD)
    table.insert(self.dispells, d)
    return d
end

--#endregion
---------------------

------------------
--#region MAIN ---

---@param cFrame ERACombatFrame
---@param hud ERAHUD
---@param spec integer
---@param options ERACombatGroupFrameOptions
---@return ERAGroupFrame
function ERAGroupFrame:Create(cFrame, hud, options, spec)
    --_G["ERAGroupPlayerFrame"]:SetSize(ERAGroupFrame_CellWidth, ERAGroupFrame_CellHeight)

    local x = {}
    setmetatable(x, ERAGroupFrame)
    ---@cast x ERAGroupFrame
    x:construct(cFrame, 0.25, 0.1, false, spec)

    x.enabledView = not options.disabled
    x.unitByID = {}
    x.iunits = {}
    x.iunitsCount = 0
    x.activeIsCombined = true
    x.byGroups = options.byGroup

    x.hasBuffsAnyCaster = false
    x.buffs = {}
    x.activeBuffs = {}
    x.debuffs = {}
    x.activeDebuffs = {}
    x.displays = {}
    x.activeDisplays = {}
    x.dispells = {}
    x.activeDispells = {}

    x.isSolo = true

    if not options.disabled then
        local xRight = hud.offsetX - ERAHUD_TimerIconSize
        local yBottom = hud.offsetY + 2 * ERAHUD_TimerIconSize
        x.containerFrame = CreateFrame("Frame", nil, UIParent)
        x.containerFrame:SetSize(1004, 1004)
        x.containerFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", xRight, yBottom)
        x.combinedFrame = ERAGroupSecureFrame:create(x, x.containerFrame, nil, false, options.showRaid, 0, 0)
        x.groupFrames = {}
        if options.showRaid and options.byGroup then
            xRight = 0
            yBottom = 0
            if options.horizontalGroups then
                for i = 1, 8 do
                    table.insert(x.groupFrames, ERAGroupSecureFrame:create(x, x.containerFrame, i, true, true, xRight, yBottom))
                    yBottom = yBottom + ERAGroupFrame_CellHeight
                end
            else
                for i = 1, 8 do
                    table.insert(x.groupFrames, ERAGroupSecureFrame:create(x, x.containerFrame, i, false, true, xRight, yBottom))
                    xRight = xRight - ERAGroupFrame_CellWidth
                end
            end
        end

        --------------------
        --#region EVENTS ---

        x.groupEvents = {}
        local ug_tmp = x.updateGroup
        local ug = function() ug_tmp(x) end
        local ub_tmp = x.updateBorders
        local ub = function() ub_tmp(x) end
        local uh_tmp = x.updateHealth
        local uh = function(unitID) uh_tmp(x, unitID) end
        function x.groupEvents:PLAYER_TARGET_CHANGED()
            ub()
        end
        function x.groupEvents:UNIT_HEALTH(unitID)
            uh(unitID)
        end
        function x.groupEvents:UNIT_MAXHEALTH(unitID)
            uh(unitID)
        end
        function x.groupEvents:UNIT_ABSORB_AMOUNT_CHANGED(unitID)
            uh(unitID)
        end
        function x.groupEvents:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unitID)
            uh(unitID)
        end
        function x.groupEvents:GROUP_ROSTER_UPDATE()
            ug()
        end
        function x.groupEvents:RAID_ROSTER_UPDATE()
            ug()
        end
        function x.groupEvents:PLAYER_ROLES_ASSIGNED()
            ug()
        end
        function x.groupEvents:ROLE_CHANGED_INFORM()
            ug()
        end
        local evts = x.groupEvents
        x.containerFrame:SetScript(
            "OnEvent",
            function(self, event, ...)
                evts[event](self, ...)
            end
        )

        --#endregion
        --------------------
    end

    return x
end

-----------------------
--#region MECHANICS ---

function ERAGroupFrame:ResetToIdle()
    if self.enabledView then
        self.containerFrame:Show()
        for k, v in pairs(self.groupEvents) do
            self.containerFrame:RegisterEvent(k)
        end
    end
    self:updateGroup()
end

function ERAGroupFrame:SpecInactive(wasActive)
    if (wasActive) then
        if self.enabledView then
            self.containerFrame:Hide()
            self.containerFrame:UnregisterAllEvents()
        end
    end
end

function ERAGroupFrame:CheckTalents()
    table.wipe(self.activeBuffs)
    self.hasBuffsAnyCaster = false
    for _, a in ipairs(self.buffs) do
        if a:hasTalent() then
            self.activeBuffs[a.spellID] = a
            if a.anyCaster then self.hasBuffsAnyCaster = true end
        end
    end

    table.wipe(self.activeDebuffs)
    for _, a in ipairs(self.debuffs) do
        if a:hasTalent() then
            self.activeDebuffs[a.spellID] = a
        end
    end

    table.wipe(self.activeDisplays)
    for _, d in ipairs(self.displays) do
        if d:hasTalent() then
            table.insert(self.activeDisplays, d)
        end
    end

    table.wipe(self.activeDispells)
    local index = 1
    for _, d in ipairs(self.dispells) do
        if d:checkTalent(index) then
            index = index + 1
            table.insert(self.activeDispells, d)
        end
    end
end

function ERAGroupFrame:Pack()
    if self.enabledView then
        self:AddDisplay(self:AddDebuff(434705, true, ERALIBTalent_NerubAr), -1, 1, 1.0, 0.0, 0.0, 1.0, 0.5, 0.5, nil, 20) -- tenderized
        self:AddDisplay(self:AddDebuff(441362, true, ERALIBTalent_NerubAr), -1, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0)          -- ovinax
        self:AddDisplay(self:AddDebuff(438708, true, ERALIBTalent_NerubAr), -1, 1, 1.0, 0.0, 0.0, 0.3, 0.5, 0.0)          -- anubarash stinging swarm
    end
end

--#endregion
-----------------------

------------------------------
--#region UNITS MANAGEMENT ---

function ERAGroupFrame:updateGroup()
    if self.enabledView then
        if IsInRaid() then
            if self.byGroups then
                if self.activeIsCombined then
                    self.activeIsCombined = false
                    self.combinedFrame.frame:Hide()
                    for _, g in ipairs(self.groupFrames) do
                        g.frame:Show()
                    end
                end
            else
                if not self.activeIsCombined then
                    self.activeIsCombined = true
                    self.combinedFrame.frame:Show()
                    for _, g in ipairs(self.groupFrames) do
                        g.frame:Hide()
                    end
                end
            end
        else
            if not self.activeIsCombined then
                self.activeIsCombined = true
                self.combinedFrame.frame:Show()
                for _, g in ipairs(self.groupFrames) do
                    g.frame:Hide()
                end
            end
        end
        table.wipe(self.unitByID)
        if self.activeIsCombined then
            self.combinedFrame:populateOwnerUnits()
        else
            for _, g in ipairs(self.groupFrames) do
                g:populateOwnerUnits()
            end
        end
        for _, u in pairs(self.unitByID) do
            u:updateMemberStatus()
        end
    end
end

---@param triggeredBy ERAGroupSecureFrame
---@param unit ERAGroupUnitFrame
---@param unitID string
function ERAGroupFrame:unitRemoved(triggeredBy, unit, unitID)
    if triggeredBy == self.combinedFrame then
        if not self.activeIsCombined then return end
    else
        if self.activeIsCombined then return end
    end
    if self.unitByID[unitID] == unit then
        self.unitByID[unitID] = nil
    end
end
---@param triggeredBy ERAGroupSecureFrame
---@param unit ERAGroupUnitFrame
function ERAGroupFrame:unitAdded(triggeredBy, unit)
    if triggeredBy == self.combinedFrame then
        if not self.activeIsCombined then return end
    else
        if self.activeIsCombined then return end
    end
    self.unitByID[unit.unit] = unit
end

function ERAGroupFrame:updateBorders()
    for _, u in pairs(self.unitByID) do
        u:updateBorder()
    end
end

function ERAGroupFrame:updateHealth(unitID)
    local u = self.unitByID[unitID]
    if u then
        u:updateHealth()
    end
end

--#endregion
------------------------------

--------------------
--#region UPDATE ---

---@param t number
---@param combat boolean
function ERAGroupFrame:UpdatedOverride(t, combat)
end
function ERAGroupFrame:UpdateIdle(t)
    self:update(t)
    self:UpdatedOverride(t, false)
end
function ERAGroupFrame:UpdateCombat(t)
    self:update(t)
    self:UpdatedOverride(t, true)
end
---@param t number
function ERAGroupFrame:update(t)
    for _, a in pairs(self.activeBuffs) do
        a:prepareUpdate()
    end
    for _, a in pairs(self.activeDebuffs) do
        a:prepareUpdate()
    end
    if self.enabledView then
        local inRangeCount = 0
        for _, u in pairs(self.unitByID) do
            u:updateHealth()
            u:prepareUpdate()
            self:parseAuras(t, u, true)
            for _, disp in pairs(self.activeDispells) do
                disp:unitParsed(u)
            end
            if u:updateDisplay_returnInRange(self.activeDisplays) then
                inRangeCount = inRangeCount + 1
            end
        end
        self.isSolo = inRangeCount > 1
    else
        local prefix
        if IsInRaid() then
            prefix = "raid"
        else
            prefix = "party"
        end
        local num = GetNumGroupMembers()
        if num and num > 0 then
            for memberIndex = 1, num do
                local unitID = prefix .. memberIndex
                ---@type ERAGroupInvisibleUnit
                local u
                if memberIndex > #(self.iunits) then
                    u = ERAGroupInvisibleUnit:create(unitID)
                    table.insert(self.iunits, u)
                else
                    u = self.iunits[memberIndex]
                    u.unit = unitID
                end
                u:prepareUpdate()
                self:parseAuras(t, u, false)
            end
            self.isSolo = num > 1
        else
            self.isSolo = true
        end
    end
end

---@param t number
---@param u ERAGroupUnit
---@param checkDispell boolean
function ERAGroupFrame:parseAuras(t, u, checkDispell)
    local i = 1
    while true do
        ---@type AuraData|nil
        local auraInfo
        if self.hasBuffsAnyCaster then
            auraInfo = C_UnitAuras.GetBuffDataByIndex(u.unit, i)
        else
            auraInfo = C_UnitAuras.GetBuffDataByIndex(u.unit, i, "PLAYER")
        end
        if auraInfo then
            local def = self.activeBuffs[auraInfo.spellId]
            if def then
                def:auraFound_returnRemDur(auraInfo, t)
            end
            i = i + 1
        else
            break
        end
    end
    i = 1
    while true do
        ---@type AuraData|nil
        local auraInfo = C_UnitAuras.GetDebuffDataByIndex(u.unit, i)
        if auraInfo then
            local def = self.activeDebuffs[auraInfo.spellId]
            local remDur = nil
            if def then
                remDur = def:auraFound_returnRemDur(auraInfo, t)
            end
            if checkDispell and auraInfo.dispelName then
                if not remDur then
                    if auraInfo.expirationTime and auraInfo.expirationTime > 0 then
                        remDur = math.max(0, auraInfo.expirationTime - t)
                    else
                        remDur = 1004
                    end
                end
                for _, disp in ipairs(self.activeDispells) do
                    disp:checkType(auraInfo.dispelName, remDur)
                end
            end
            i = i + 1
        else
            break
        end
    end
    for _, a in pairs(self.activeBuffs) do
        a:unitParsed(u)
    end
    for _, a in pairs(self.activeDebuffs) do
        a:unitParsed(u)
    end
end

--#endregion
--------------------

--#endregion
------------------

------------------
--#region UNIT ---

---@class ERAGroupUnit
---@field unit string|nil
---@field currentDamageAbsorb number
---@field currentHealAbsorb number
---@field currentHealth number
---@field maxHealth number
---@field dead boolean
---@field auras ERAGroupAuraInstance[]

---@class ERAGroupInvisibleUnit : ERAGroupUnit
---@field private __index unknown
ERAGroupInvisibleUnit = {}
ERAGroupInvisibleUnit.__index = ERAGroupInvisibleUnit

---@param unitID string
---@return ERAGroupInvisibleUnit
function ERAGroupInvisibleUnit:create(unitID)
    local x = {}
    setmetatable(x, ERAGroupInvisibleUnit)
    ---@cast x ERAGroupInvisibleUnit

    x.currentDamageAbsorb = 0
    x.currentHealAbsorb = 0
    x.currentHealth = 0
    x.maxHealth = 1
    x.dead = false
    x.auras = {}
    x.unit = unitID

    return x
end

function ERAGroupInvisibleUnit:prepareUpdate()
    table.wipe(self.auras)
    if UnitIsDeadOrGhost(self.unit) then
        if not self.dead then
            self.dead = true
            self.maxHealth = UnitHealthMax(self.unit) or 1
            self.currentDamageAbsorb = 0
            self.currentHealAbsorb = 0
            self.currentHealth = 0
        end
    else
        self.dead = false
        self.currentHealth = UnitHealth(self.unit)
        self.maxHealth = UnitHealthMax(self.unit)
        self.currentDamageAbsorb = UnitGetTotalAbsorbs(self.unit)
        self.currentHealAbsorb = UnitGetTotalHealAbsorbs(self.unit)
    end
end

--#endregion
------------------

--------------------------
--#region SECURE FRAME ---

---@class (exact) ERAGroupSecureFrame
---@field private __index unknown
---@field owner ERAGroupFrame
---@field visible boolean
---@field frame Frame
---@field private unitByID table<string, ERAGroupUnitFrame>
ERAGroupSecureFrame = {}
ERAGroupSecureFrame.__index = ERAGroupSecureFrame

ERAGroupFrame_counter = 1

---@param owner ERAGroupFrame
---@param containerFrame Frame
---@param groupFilter integer|nil
---@param horizontalGroups boolean
---@param showRaid boolean
---@param xRight number
---@param yBottom number
---@return ERAGroupSecureFrame
function ERAGroupSecureFrame:create(owner, containerFrame, groupFilter, horizontalGroups, showRaid, xRight, yBottom)
    local x = {}
    setmetatable(x, ERAGroupSecureFrame)
    ---@cast x ERAGroupSecureFrame

    x.owner = owner
    x.unitByID = {}

    local frame = CreateFrame("Frame", "ERAGroupSecureFrameHeader" .. ERAGroupFrame_counter, containerFrame, "SecureGroupHeaderTemplate")
    ERAGroupFrame_counter = ERAGroupFrame_counter + 1
    frame.initialConfigFunction = function(gFrame, unitframeName)
        ERAGroupFrame_initialConfigFunction(gFrame, _G[unitframeName])
    end
    frame.era_secure = x
    ---@cast frame Frame
    x.frame = frame
    frame:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", xRight, yBottom)

    if groupFilter then
        frame:SetAttribute("groupFilter", groupFilter)
        frame:SetAttribute("groupBy", "GROUP")
        frame:SetAttribute("maxColumns", 8)
        frame:SetAttribute("unitsPerColumn", 5)
        if horizontalGroups then
            frame:SetAttribute("point", "RIGHT")
            frame:SetSize(1004, ERAGroupFrame_CellHeight)
        else
            frame:SetAttribute("point", "BOTTOM")
            frame:SetSize(ERAGroupFrame_CellWidth, 1004)
        end
    else
        frame:SetSize(1004, 1004)
        frame:SetAttribute("point", "BOTTOM")
        frame:SetAttribute("groupBy", "ASSIGNEDROLE")
        frame:SetAttribute("maxColumns", 8)
        frame:SetAttribute("unitsPerColumn", 8)
    end
    frame:SetAttribute("template", "ERAGroupPlayerFrame")
    frame:SetAttribute("groupingOrder", "MAINTANK,TANK,HEALER,MAINASSIST,DAMAGER,NONE")
    frame:SetAttribute("sortMethod", "INDEX")
    frame:SetAttribute("columnAnchorPoint", "RIGHT")
    frame:SetAttribute("showParty", not groupFilter)
    frame:SetAttribute("showRaid", showRaid)
    frame:SetAttribute("showPlayer", true)
    frame:SetAttribute("showSolo", false)
    frame:SetAttribute(
        "initialConfigFunction",
        [[
        RegisterUnitWatch(self);
        self:SetAttribute("type", "target");
        self:SetAttribute("initial-width", ]] .. ERAGroupFrame_CellWidth .. [[);
        self:SetAttribute("initial-height", ]] .. ERAGroupFrame_CellHeight .. [[);
        self:GetParent():CallMethod("initialConfigFunction", self:GetName());]]
    )
    frame:Show()

    return x
end

---@param unit ERAGroupUnitFrame
function ERAGroupSecureFrame:removeUnit(unit)
    if self.unitByID[unit.unit] == unit then
        self.unitByID[unit.unit] = nil
        self.owner:unitRemoved(self, unit, unit.unit)
    end
end

---@param unit ERAGroupUnitFrame
---@param oldID string|nil
function ERAGroupSecureFrame:setUnit(unit, oldID)
    if oldID and self.unitByID[oldID] == unit then
        self.unitByID[oldID] = nil
        self.owner:unitRemoved(self, unit, oldID)
    end
    self.unitByID[unit.unit] = unit
    self.owner:unitAdded(self, unit)
end

function ERAGroupSecureFrame:populateOwnerUnits()
    for _, u in pairs(self.unitByID) do
        self.owner:unitAdded(self, u)
    end
end

--#endregion
--------------------------

------------------------
--#region UNIT FRAME ---

ERAGroupFrameUnitEvents = {}
function ERAGroupFrameUnitEvents:OnShow()
    self.owner.owner:updateGroup()
end
function ERAGroupFrameUnitEvents:OnHide()
    self.owner.owner:updateGroup()
end

function ERAGroupFrameUnitEvents:OnAttributeChanged(name, value)
    if (name == "unit") then
        local this = self
        ---@cast this ERAGroupUnitFrame
        if (value == nil) then
            if (this.unit ~= nil) then
                this.owner:removeUnit(this)
                this.unit = nil
            end
        else
            local oldID = this.unit
            this:setUnit(value)
            this.owner:setUnit(this, oldID)
        end
    end
end

---@class ERAGroupUnitFrame : Frame, ERAGroupUnit
---@field private __index unknown
---@field owner ERAGroupSecureFrame
---@field private mainFrame BackdropTemplate
---@field private borderR number
---@field private borderG number
---@field private borderB number
---@field private updateHealthColor_returnInRange fun(this:ERAGroupUnitFrame, force:boolean): boolean
---@field private setBorderColor fun(this:ERAGroupUnitFrame, r:number, g:number, b:number)
---@field private nameBlock FontString
---@field private roleIcon Texture
---@field private healthBar Texture
---@field private healthR number
---@field private healthG number
---@field private healthB number
---@field private absorbHealBar Texture
---@field private absorbDamageBar Texture
---@field private deadLine1 Line
---@field private deadLine2 Line
---@field private isThisPlayer boolean
---@field private inRange boolean
---@field private auraFrames ERAGroupAuraFrame[]
---@field private dispellMarks table<integer,ERAGroupDispellMark>
ERAGroupUnitFrame = {}
ERAGroupUnitFrame.__index = ERAGroupUnitFrame

function ERAGroupFrame_initialConfigFunction(era_secure, unitframe)
    local owner = era_secure.era_secure
    ---@cast owner ERAGroupSecureFrame
    ---@cast unitframe ERAGroupUnitFrame
    for name, value in pairs(ERAGroupUnitFrame) do
        unitframe[name] = value
    end
    for event, handler in pairs(ERAGroupFrameUnitEvents) do
        unitframe:HookScript(event, handler)
    end
    unitframe:initialize(owner)
end

---@param owner ERAGroupSecureFrame
function ERAGroupUnitFrame:initialize(owner)
    self:SetSize(ERAGroupFrame_CellWidth, ERAGroupFrame_CellHeight)
    self.owner = owner
    self.inRange = true
    self.isThisPlayer = false
    self.dead = false
    self.currentDamageAbsorb = 0
    self.currentHealAbsorb = 0
    self.currentHealth = 0
    self.maxHealth = 1
    self.auras = {}
    self.auraFrames = {}
    self.dispellMarks = {}

    local mf = CreateFrame("Frame", nil, self, "BackdropTemplate")
    ---@cast mf BackdropTemplate
    self.mainFrame = mf

    mf:SetBackdrop(
        {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = ERAGroupFrame_UnitBorderThickness
        }
    )
    self.borderR = 0.3
    self.borderG = 0.3
    self.borderB = 0.3
    mf:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    mf:SetBackdropColor(0.0, 0.0, 0.0, 1.0)

    ---@cast mf Frame
    mf:SetFrameStrata("LOW")
    mf:SetPoint("TOPLEFT", self, "TOPLEFT", ERAGroupFrame_CellPadding, -ERAGroupFrame_CellPadding)
    mf:SetPoint("TOPRIGHT", self, "TOPRIGHT", -ERAGroupFrame_CellPadding, -ERAGroupFrame_CellPadding)
    mf:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -ERAGroupFrame_CellPadding, ERAGroupFrame_CellPadding)
    mf:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", ERAGroupFrame_CellPadding, ERAGroupFrame_CellPadding)

    self.healthBar = mf:CreateTexture(nil, "BORDER")
    self.healthR = 0.0
    self.healthG = 1.0
    self.healthB = 0.0
    self.healthBar:SetColorTexture(0.0, 1.0, 0.0, 1.0)
    self.healthBar:SetPoint("TOPLEFT", mf, "TOPLEFT", ERAGroupFrame_HealthOffsetFromMainFrame, -ERAGroupFrame_HealthOffsetFromMainFrame)
    self.healthBar:SetPoint("BOTTOMLEFT", mf, "BOTTOMLEFT", ERAGroupFrame_HealthOffsetFromMainFrame, ERAGroupFrame_HealthOffsetFromMainFrame)
    self.healthBar:SetWidth(ERAGroupFrame_HealthWidth)

    self.absorbHealBar = mf:CreateTexture(nil, "BORDER")
    self.absorbHealBar:SetHeight(ERAGroupFrame_HealthHeight)
    self.absorbHealBar:SetColorTexture(1.0, 0.0, 0.0, 1.0)
    self.absorbDamageBar = mf:CreateTexture(nil, "BORDER")
    self.absorbDamageBar:SetHeight(ERAGroupFrame_HealthHeight)
    self.absorbDamageBar:SetColorTexture(0.0, 0.0, 1.0, 1.0)

    self.nameBlock = self:CreateFontString(nil, "HIGHLIGHT")
    ERALIB_SetFont(self.nameBlock, ERAGroupFrame_CellHeight * 0.25)
    self.nameBlock:SetPoint("TOPLEFT", self, "TOPLEFT", 1.5 * ERAGroupFrame_DispellSize + ERAGroupFrame_HealthOffsetFromCell, -ERAGroupFrame_HealthOffsetFromCell)

    self.roleIcon = mf:CreateTexture(nil, "ARTWORK")
    self.roleIcon:SetSize(16, 16)
    self.roleIcon:SetPoint("TOPRIGHT", mf, "TOPRIGHT", 0, 0)

    self.deadLine1 = mf:CreateLine(nil, "OVERLAY", "ERAGroupDeadLine")
    self.deadLine1:SetStartPoint("BOTTOMLEFT", mf, ERAGroupFrame_HealthOffsetFromMainFrame, ERAGroupFrame_HealthOffsetFromMainFrame)
    self.deadLine1:SetEndPoint("TOPRIGHT", mf, -ERAGroupFrame_HealthOffsetFromMainFrame, -ERAGroupFrame_HealthOffsetFromMainFrame)
    self.deadLine1:Hide()
    self.deadLine2 = mf:CreateLine(nil, "OVERLAY", "ERAGroupDeadLine")
    self.deadLine2:SetStartPoint("TOPLEFT", mf, ERAGroupFrame_HealthOffsetFromMainFrame, -ERAGroupFrame_HealthOffsetFromMainFrame)
    self.deadLine2:SetEndPoint("BOTTOMRIGHT", mf, -ERAGroupFrame_HealthOffsetFromMainFrame, ERAGroupFrame_HealthOffsetFromMainFrame)
    self.deadLine2:Hide()
end

---@param unitID string
function ERAGroupUnitFrame:setUnit(unitID)
    self.unit = unitID
    self.isThisPlayer = UnitIsUnit(unitID, "player")
    self.inRange = true
    self.nameBlock:SetText(UnitName(unitID))
    local _, className = UnitClass(unitID)
    local r, g, b = GetClassColor(className)
    self:SetAlpha(1.0)
    self.healthR = r
    self.healthG = g
    self.healthB = b
    self:updateHealthColor_returnInRange(true)
    self:updateMemberStatus()
    self:updateBorder()
    self:updateHealth()
end

function ERAGroupUnitFrame:updateMemberStatus()
    local role = UnitGroupRolesAssigned(self.unit)
    ---@type Texture
    if (self.isThisPlayer) then
        self.roleIcon:SetAtlas("Icon-WoW")
    else
        if (role == "TANK") then
            self.roleIcon:SetAtlas("GM-icon-role-tank")
        elseif (role == "HEALER") then
            self.roleIcon:SetAtlas("GM-icon-role-healer")
        else
            self.roleIcon:SetTexture(nil)
        end
    end
end

function ERAGroupUnitFrame:setBorderColor(r, g, b)
    if r ~= self.borderR or g ~= self.borderG or b ~= self.borderB then
        self.borderR = r
        self.borderG = g
        self.borderB = b
        self.mainFrame:SetBackdropBorderColor(r, g, b, 1.0)
    end
end
function ERAGroupUnitFrame:updateBorder()
    local threat = UnitThreatSituation(self.unit)
    local isTanking = threat and threat >= 2
    if (UnitIsUnit("target", self.unit)) then
        if (isTanking) then
            self:setBorderColor(1.0, 0.6, 0.6)
        else
            self:setBorderColor(1.0, 1.0, 1.0)
        end
    else
        if (isTanking) then
            self:setBorderColor(1.0, 0.0, 0.0)
        else
            self:setBorderColor(0.3, 0.3, 0.3)
        end
    end
end

function ERAGroupUnitFrame:updateHealth()
    if UnitIsDeadOrGhost(self.unit) then
        if not self.dead then
            self.dead = true
            self.maxHealth = UnitHealthMax(self.unit) or 1
            self.currentDamageAbsorb = 0
            self.currentHealAbsorb = 0
            self.currentHealth = 0
            self.deadLine1:Show()
            self.deadLine2:Show()
            self.healthBar:SetWidth(0)
            self.absorbDamageBar:Hide()
            self.absorbHealBar:Hide()
        end
    else
        if self.dead then
            self.dead = false
            self.deadLine1:Hide()
            self.deadLine2:Hide()
        end
        local c = UnitHealth(self.unit)
        local m = UnitHealthMax(self.unit)
        local aH = UnitGetTotalHealAbsorbs(self.unit)
        local aD = UnitGetTotalAbsorbs(self.unit)
        if (c ~= self.currentHealth or m ~= self.maxHealth or aH ~= self.currentHealAbsorb or aD ~= self.currentDamageAbsorb) then
            self.currentHealth = c
            self.maxHealth = m
            local ratio = ERAGroupFrame_HealthWidth / m
            local x
            if (aH > c) then
                self.healthBar:SetWidth(0)
                x = c * ratio
                self.absorbHealBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", ERAGroupFrame_HealthOffsetFromMainFrame, -ERAGroupFrame_HealthOffsetFromMainFrame)
                self.absorbHealBar:SetWidth(x)
                x = x + ERAGroupFrame_HealthOffsetFromMainFrame
                if (self.currentHealAbsorb <= 0) then
                    self.absorbHealBar:Show()
                end
            else
                if (aH > 0) then
                    x = (c - aH) * ratio
                    self.healthBar:SetWidth(x)
                    x = x + ERAGroupFrame_HealthOffsetFromMainFrame
                    self.absorbHealBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", x, -ERAGroupFrame_HealthOffsetFromMainFrame)
                    local aHwidth = aH * ratio
                    self.absorbHealBar:SetWidth(aHwidth)
                    x = x + aHwidth
                    if (self.currentHealAbsorb <= 0) then
                        self.absorbHealBar:Show()
                    end
                else
                    x = c * ratio
                    self.healthBar:SetWidth(x)
                    x = x + ERAGroupFrame_HealthOffsetFromMainFrame
                    if (self.currentHealAbsorb > 0) then
                        self.absorbHealBar:Hide()
                    end
                end
            end
            if (aD > 0) then
                self.absorbDamageBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", x, -ERAGroupFrame_HealthOffsetFromMainFrame)
                self.absorbDamageBar:SetWidth(ratio * math.min(aD, m - c))
                if (self.currentDamageAbsorb <= 0) then
                    self.absorbDamageBar:Show()
                end
            elseif (self.currentDamageAbsorb > 0) then
                self.absorbDamageBar:Hide()
            end
            self.currentDamageAbsorb = aD
            self.currentHealAbsorb = aH
        end
    end
end

function ERAGroupUnitFrame:prepareUpdate()
    table.wipe(self.auras)
end

---@param index integer
---@param r number
---@param g number
---@param b number
function ERAGroupUnitFrame:dispellActive(index, r, g, b)
    local dm = self.dispellMarks[index]
    if not dm then
        dm = ERAGroupDispellMark:create(self.mainFrame, r, g, b)
        self.dispellMarks[index] = dm
    end
    dm:show(self.mainFrame, ERAGroupFrame_HealthOffsetFromMainFrame + (index - 1) * ERAGroupFrame_DispellSize, -ERAGroupFrame_HealthOffsetFromMainFrame, r, g, b)
end

---@param force boolean
---@return boolean
function ERAGroupUnitFrame:updateHealthColor_returnInRange(force)
    if self.isThisPlayer or UnitInRange(self.unit) then
        if force or not self.inRange then
            self.inRange = true
            self.healthBar:SetColorTexture(self.healthR, self.healthG, self.healthB, 1.0)
            self:SetAlpha(1.0)
        end
        return true
    else
        if force or self.inRange then
            self.inRange = false
            self.healthBar:SetColorTexture(0.3, 0.3, 0.3, 1.0)
            self:SetAlpha(0.5)
        end
        return false
    end
end

---@param displayedAuras ERAGroupAuraDisplay[]
---@return boolean
function ERAGroupUnitFrame:updateDisplay_returnInRange(displayedAuras)
    --#region auras
    ---@type ERAGroupAuraDisplay[]
    local posPositions = {}
    ---@type ERAGroupAuraDisplay[]
    local negPositions = {}
    local cpt = 0
    for _, d in ipairs(displayedAuras) do
        local ignore = false
        ---@type ERAGroupAuraDisplay|nil
        local already
        if d.position < 0 then
            already = negPositions[d.position]
            if already and already.priority > d.priority then
                ignore = true
            end
        else
            already = posPositions[d.position]
            if already and already.priority > d.priority then
                ignore = true
            end
        end
        if not ignore then
            for _, a in ipairs(self.auras) do
                ---@cast a ERAGroupAuraInstance
                if a.definition == d.definition then
                    if d.position < 0 then
                        negPositions[d.position] = d
                    else
                        posPositions[d.position] = d
                    end
                    if already then
                        d.frame_temp = already.frame_temp
                        already.instance_temp = nil
                        already.frame_temp = nil
                    else
                        cpt = cpt + 1
                        ---@type ERAGroupAuraFrame
                        local af
                        if cpt > #(self.auraFrames) then
                            af = ERAGroupAuraFrame:create(self.mainFrame)
                            table.insert(self.auraFrames, af)
                        else
                            af = self.auraFrames[cpt]
                        end
                        d.frame_temp = af
                    end
                    d.instance_temp = a
                    break
                end
            end
        end
    end
    for _, d in ipairs(displayedAuras) do
        if d.frame_temp then
            local inst = d.instance_temp
            ---@cast inst ERAGroupAuraInstance
            local x
            if d.position < 0 then
                x = ERAGroupFrame_HealthOffsetFromMainFrame + ERAGroupFrame_HealthWidth + d.position * ERAGroupFrame_AuraSize
            else
                x = ERAGroupFrame_HealthOffsetFromMainFrame + d.position * ERAGroupFrame_AuraSize
            end
            d.frame_temp:show(self.mainFrame, x, ERAGroupFrame_HealthOffsetFromMainFrame, inst.remDuration, inst.totDuration, inst.stacks, d)
            d.frame_temp = nil
            d.instance_temp = nil
        end
    end
    for i = cpt + 1, #(self.auraFrames) do
        self.auraFrames[i]:hide()
    end
    --#endregion

    --#region dispell
    for _, dm in pairs(self.dispellMarks) do
        if dm.active then
            dm.active = false
        else
            dm:hide()
        end
    end
    --#endregion

    --#region status
    self:updateBorder()

    return self:updateHealthColor_returnInRange(false)
    --#endregion
end

---@class ERAGroupDispellMark
---@field private __index unknown
---@field private r number
---@field private g number
---@field private b number
---@field private x number
---@field private y number
---@field active boolean
---@field private asFrame Frame
---@field private asBackdrop BackdropTemplate
---@field private visible boolean
ERAGroupDispellMark = {}
ERAGroupDispellMark.__index = ERAGroupDispellMark

---@param parentFrame BackdropTemplate
---@param r number
---@param g number
---@param b number
---@return ERAGroupDispellMark
function ERAGroupDispellMark:create(parentFrame, r, g, b)
    local x = {}
    setmetatable(x, ERAGroupDispellMark)
    ---@cast x ERAGroupDispellMark
    x.r = r
    x.g = g
    x.b = b
    x.x = -1004
    x.y = -1004
    x.visible = true

    local frame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    ---@cast frame Frame
    x.asFrame = frame
    frame:SetSize(ERAGroupFrame_DispellSize, ERAGroupFrame_DispellSize)
    frame:SetFrameLevel(10)
    frame:Show()
    ---@cast frame BackdropTemplate
    x.asBackdrop = frame
    frame:SetBackdrop(
        {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 2
        }
    )
    frame:SetBackdropColor(r, g, b, 1.0)
    frame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

    return x
end

function ERAGroupDispellMark:hide()
    if self.visible then
        self.visible = false
        self.asFrame:Hide()
    end
end

---@param parentFrame BackdropTemplate
---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
function ERAGroupDispellMark:show(parentFrame, x, y, r, g, b)
    if self.x ~= x or self.y ~= y then
        self.x = x
        self.y = y
        self.asFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
    end
    if r ~= self.r or g ~= self.g or b ~= self.b then
        self.r = r
        self.g = g
        self.b = b
        self.asBackdrop:SetBackdropColor(r, g, b, 1.0)
    end
    self.active = true
    if not self.visible then
        self.visible = true
        self.asFrame:Show()
    end
end

--#endregion
------------------------

------------------
--#region AURA ---

---@class (exact) ERAGroupAuraDefinition
---@field private __index unknown
---@field spellID integer
---@field anyCaster boolean
---@field isBuff boolean
---@field private talent ERALIBTalent|nil
---@field private foundTotDuration number
---@field private foundRemDuration number
---@field private foundStacks integer
---@field private foundByPlayer boolean
---@field private instanceCache ERAGroupAuraInstance[]
---@field activeInstances ERAGroupAuraInstance[]
ERAGroupAuraDefinition = {}
ERAGroupAuraDefinition.__index = ERAGroupAuraDefinition

---@param spellID integer
---@param isBuff boolean
---@param anyCaster boolean
---@param talent ERALIBTalent|nil
---@return ERAGroupAuraDefinition
function ERAGroupAuraDefinition:create(spellID, isBuff, anyCaster, talent)
    local x = {}
    setmetatable(x, ERAGroupAuraDefinition)
    ---@cast x ERAGroupAuraDefinition

    x.spellID = spellID
    x.isBuff = isBuff
    x.anyCaster = anyCaster
    x.talent = talent
    x.foundByPlayer = false
    x.foundStacks = 0
    x.foundRemDuration = 0
    x.foundTotDuration = 1
    x.instanceCache = {}
    x.activeInstances = {}

    return x
end

---@return boolean
function ERAGroupAuraDefinition:hasTalent()
    table.wipe(self.activeInstances)
    return (not self.talent) or self.talent:PlayerHasTalent()
end

function ERAGroupAuraDefinition:prepareUpdate()
    table.wipe(self.activeInstances)
end

---@param data AuraData
---@param t number
---@return number|nil
function ERAGroupAuraDefinition:auraFound_returnRemDur(data, t)
    local byPlayer = data.sourceUnit == "player"
    if self.anyCaster or byPlayer then
        if byPlayer then self.foundByPlayer = true end
        local remDur
        local totDur
        if data.expirationTime and data.expirationTime > 0 then
            remDur = math.max(0, data.expirationTime - t)
            if data.duration and data.duration > 0 and data.duration > remDur then
                totDur = data.duration
            else
                totDur = math.max(1, remDur)
            end
        else
            remDur = 1004
            totDur = 1004
        end
        self.foundStacks = math.max(self.foundStacks, data.applications, 1)
        if remDur > self.foundRemDuration then
            self.foundRemDuration = remDur
            self.foundTotDuration = totDur
        end
        return remDur
    else
        return nil
    end
end

---@param u ERAGroupUnit
function ERAGroupAuraDefinition:unitParsed(u)
    if self.foundStacks > 0 then
        ---@type ERAGroupAuraInstance
        local inst
        local index = 1 + #(self.activeInstances)
        if index > #(self.instanceCache) then
            inst = ERAGroupAuraInstance:create(self)
            table.insert(self.instanceCache, inst)
        else
            inst = self.instanceCache[index]
        end
        table.insert(self.activeInstances, inst)
        inst:setup(u, self.foundRemDuration, self.foundTotDuration, self.foundStacks, self.foundByPlayer)
        table.insert(u.auras, inst)
    end
    self.foundRemDuration = 0
    self.foundStacks = 0
    self.foundByPlayer = false
end

---@class (exact) ERAGroupAuraInstance
---@field private __index unknown
---@field definition ERAGroupAuraDefinition
---@field unit ERAGroupUnit
---@field remDuration number
---@field totDuration number
---@field stacks integer
---@field byPlayer boolean
ERAGroupAuraInstance = {}
ERAGroupAuraInstance.__index = ERAGroupAuraInstance

---@param definition ERAGroupAuraDefinition
---@return ERAGroupAuraInstance
function ERAGroupAuraInstance:create(definition)
    local x = {}
    setmetatable(x, ERAGroupAuraInstance)
    ---@cast x ERAGroupAuraInstance
    x.definition = definition
    return x
end

---@param unit ERAGroupUnit
---@param remDuration number
---@param totDuration number
---@param stacks integer
---@param byPlayer boolean
function ERAGroupAuraInstance:setup(unit, remDuration, totDuration, stacks, byPlayer)
    self.unit = unit
    self.remDuration = remDuration
    self.totDuration = totDuration
    self.stacks = stacks
    self.byPlayer = byPlayer
end

--#endregion
------------------

------------------------
--#region AURA FRAME ---

---@class (exact) ERAGroupAuraFrame
---@field private __index unknown
---@field private frame Frame
---@field private visible boolean
---@field private x number
---@field private y number
---@field private stacksDisplayed integer
---@field private text FontString
---@field private center Texture
---@field private border Texture
---@field private rC number
---@field private gC number
---@field private bC number
---@field private rB number
---@field private gB number
---@field private bB number
ERAGroupAuraFrame = {}
ERAGroupAuraFrame.__index = ERAGroupAuraFrame

---@param parentFrame BackdropTemplate
---@return ERAGroupAuraFrame
function ERAGroupAuraFrame:create(parentFrame)
    local x = {}
    setmetatable(x, ERAGroupAuraFrame)
    local frame = CreateFrame("Frame", nil, parentFrame, "ERAGroupAuraFrame")
    frame:SetSize(ERAGroupFrame_AuraSize, ERAGroupFrame_AuraSize)
    frame:SetFrameLevel(5)
    x.trt = frame.TRT
    x.trr = frame.TRR
    x.tlt = frame.TLT
    x.tlr = frame.TLR
    x.blr = frame.BLR
    x.blt = frame.BLT
    x.brt = frame.BRT
    x.brr = frame.BRR
    x.size = ERAGroupFrame_AuraSize
    ERAPieControl_Init(x)
    ERAPieControl_SetOverlayAlpha(x, 1.0)
    local txt = frame.Text
    local center = frame.CENTER
    local border = frame.BORDER
    ---@cast txt FontString
    ---@cast border Texture
    ---@cast center Texture
    ---@cast x ERAGroupAuraFrame
    ---@cast frame Frame

    x.x = -1004
    x.y = -1004
    x.rC = -1004
    x.gC = -1004
    x.bC = -1004
    x.rB = -1004
    x.gB = -1004
    x.bB = -1004
    x.stacksDisplayed = -1004

    ERALIB_SetFont(txt, ERAGroupFrame_AuraSize * 0.8)
    x.text = txt
    x.center = center
    x.border = border

    x.frame = frame

    x.visible = true

    return x
end

function ERAGroupAuraFrame:hide()
    if self.visible then
        self.visible = false
        self.frame:Hide()
    end
end

---@param parentFrame BackdropTemplate
---@param x number
---@param y number
---@param remDur number
---@param totDur number
---@param stacks integer
---@param display ERAGroupAuraDisplay
function ERAGroupAuraFrame:show(parentFrame, x, y, remDur, totDur, stacks, display)
    if self.x ~= x or self.y ~= y then
        self.x = x
        self.y = y
        self.frame:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", x, y)
    end
    if display.rC ~= self.rC or display.gC ~= self.gC or display.bC ~= self.bC then
        self.rC = display.rC
        self.gC = display.gC
        self.bC = display.bC
        self.center:SetVertexColor(display.rC, display.gC, display.bC, 1.0)
    end
    if display.rB ~= self.rB or display.gB ~= self.gB or display.bB ~= self.bB then
        self.rB = display.rB
        self.gB = display.gB
        self.bB = display.bB
        self.border:SetVertexColor(display.rB, display.gB, display.bB, 1.0)
    end
    if display.displayAsMaxStacks then
        ERAPieControl_SetOverlayValue(self, 1 - (stacks / display.displayAsMaxStacks))
        if self.stacksDisplayed > 1 then
            self.stacksDisplayed = -1004
            self.text:SetText(nil)
        end
    else
        ERAPieControl_SetOverlayValue(self, 1 - remDur / totDur)
        if self.stacksDisplayed ~= stacks then
            self.stacksDisplayed = stacks
            if stacks > 1 then
                self.text:SetText(tostring(stacks))
            else
                self.text:SetText(nil)
            end
        end
    end
    if not self.visible then
        self.visible = true
        self.frame:Show()
    end
end

--#endregion
--------------------------

--------------------------
--#region AURA DISPLAY ---

---@class (exact) ERAGroupAuraDisplay
---@field private __index unknown
---@field private talent ERALIBTalent|nil
---@field definition ERAGroupAuraDefinition
---@field position integer
---@field priority number
---@field rC number
---@field gC number
---@field bC number
---@field rB number
---@field gB number
---@field bB number
---@field displayAsMaxStacks integer|nil
---@field instance_temp ERAGroupAuraInstance|nil
---@field frame_temp ERAGroupAuraFrame|nil
ERAGroupAuraDisplay = {}
ERAGroupAuraDisplay.__index = ERAGroupAuraDisplay

---@param def ERAGroupAuraDefinition
---@param position integer
---@param priority number
---@param rC number
---@param gC number
---@param bC number
---@param rB number
---@param gB number
---@param bB number
---@param talent ERALIBTalent|nil
---@param displayAsMaxStacks integer|nil
---@return ERAGroupAuraDisplay
function ERAGroupAuraDisplay:create(def, position, priority, rC, gC, bC, rB, gB, bB, talent, displayAsMaxStacks)
    local x = {}
    setmetatable(x, ERAGroupAuraDisplay)
    ---@cast x ERAGroupAuraDisplay
    x.definition = def
    x.position = position
    x.priority = priority
    x.rC = rC
    x.gC = gC
    x.bC = bC
    x.rB = rB
    x.gB = gB
    x.bB = bB
    x.talent = talent
    x.displayAsMaxStacks = displayAsMaxStacks
    return x
end

---@return boolean
function ERAGroupAuraDisplay:hasTalent()
    return ((not self.talent) or self.talent:PlayerHasTalent()) and self.definition:hasTalent()
end

--#endregion
--------------------------

---------------------
--#region DISPELL ---

---@class (exact) ERAGroupDispell
---@field private __index unknown
---@field private hudCD ERACooldownBase
---@field private talent ERALIBTalent|nil
---@field private magic boolean
---@field private poison boolean
---@field private disease boolean
---@field private curse boolean
---@field private bleed boolean
---@field private r number
---@field private g number
---@field private b number
---@field private rCD number
---@field private gCD number
---@field private bCD number
---@field private index integer
---@field activeForCurrentUnit boolean
ERAGroupDispell = {}
ERAGroupDispell.__index = ERAGroupDispell

---@param hudCD ERACooldownBase
---@param talent ERALIBTalent|nil
---@param magic boolean
---@param poison boolean
---@param disease boolean
---@param curse boolean
---@param bleed boolean
---@param r number
---@param g number
---@param b number
---@param rCD number
---@param gCD number
---@param bCD number
---@return ERAGroupDispell
function ERAGroupDispell:create(hudCD, talent, magic, poison, disease, curse, bleed, r, g, b, rCD, gCD, bCD)
    local x = {}
    setmetatable(x, ERAGroupDispell)
    ---@cast x ERAGroupDispell
    x.hudCD = hudCD
    x.talent = talent
    x.magic = magic
    x.poison = poison
    x.disease = disease
    x.curse = curse
    x.bleed = bleed
    x.r = r
    x.g = g
    x.b = b
    x.rCD = rCD
    x.gCD = gCD
    x.bCD = bCD
    x.index = -1
    return x
end

---@param i integer
---@return boolean
function ERAGroupDispell:checkTalent(i)
    if (not self.talent) or self.talent:PlayerHasTalent() then
        self.index = i
        return true
    else
        self.index = -1
        return false
    end
end

---@param type string
---@param remDuration number
function ERAGroupDispell:checkType(type, remDuration)
    if remDuration <= self.hudCD.remDuration then
        return
    end
    local active = false
    if type == "Magic" then
        active = self.magic
    elseif type == "Poison" then
        active = self.poison
    elseif type == "Disease" then
        active = self.disease
    elseif type == "Curse" then
        active = self.curse
    elseif type == "Bleed" then
        active = self.bleed
    end
    if active then
        self.activeForCurrentUnit = true
    end
end

---@param unit ERAGroupUnitFrame
function ERAGroupDispell:unitParsed(unit)
    --self.activeForCurrentUnit = math.floor(GetTime() / 2) == math.floor(GetTime()) / 2 -- for tests
    if self.activeForCurrentUnit then
        if self.hudCD.remDuration <= self.hudCD.hud.remGCD + 0.1 then
            unit:dispellActive(self.index, self.r, self.g, self.b)
        else
            unit:dispellActive(self.index, self.rCD, self.gCD, self.bCD)
        end
        self.activeForCurrentUnit = false
    end
end

--#endregion
---------------------

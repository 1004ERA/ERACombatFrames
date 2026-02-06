if ERACombatMainFrame then
    return
end

--------------------------------------------------------------------------------------------------------------------------------
--#region MAIN COMBAT FRAME ----------------------------------------------------------------------------------------------------

---@class ERACombatMainFrame
---@field frame unknown
---@field Pack function
---@field playerGUID string
---@field private inCombat boolean
---@field private inVehicle boolean
---@field hideAlertsForSpec (ERACombatSpecOptions|nil)[]
---@field private talents_changed number
---@field private modules ERACombatModule[]
---@field private activeModules ERACombatModule[]
---@field private updateableModules ERACombatModule[]
ERACombatMainFrame = {}
ERACombatMainFrame.__index = ERACombatMainFrame

---comment
---@return ERACombatMainFrame
function ERACombatMainFrame:Create()
    local c = {}
    setmetatable(c, ERACombatMainFrame)
    c.playerGUID = UnitGUID("player")
    c.inCombat = false
    c.inVehicle = false
    c.frame = CreateFrame("Frame", nil, UIParent, nil)

    -- contenu
    c.modules = {}
    c.activeModules = {}
    c.updateableModules = {}

    c.talents_changed = 0

    -- évènements
    local events = {}
    function events:PLAYER_REGEN_ENABLED()
        c.inCombat = false
        if (not c.inVehicle) then
            c:exitCombat(true)
            c:enterIdle(true)
        end
    end

    function events:PLAYER_REGEN_DISABLED()
        c.inCombat = true
        if (not c.inVehicle) then
            c:exitIdle(true)
            c:enterCombat(true)
        end
    end

    function events:UNIT_ENTERED_VEHICLE(guid)
        if (guid == "player") then
            c.inVehicle = true
            if (c.inCombat) then
                c:exitCombat(false)
                c:enterVehicle(true)
            else
                c:exitIdle(false)
                c:enterVehicle(false)
            end
        end
    end

    function events:UNIT_EXITED_VEHICLE(guid)
        if (guid == "player") then
            c.inVehicle = false
            if (c.inCombat) then
                c:exitVehicle(true)
                c:enterCombat(false)
            else
                c:exitVehicle(false)
                c:enterIdle(false)
            end
        end
    end

    function events:PLAYER_SPECIALIZATION_CHANGED(arg)
        if (arg == "player") then
            c:resetToIdle(false)
        end
    end

    function events:PLAYER_TALENT_UPDATE()
        c:updateTalents()
    end
    function events:ACTIVE_COMBAT_CONFIG_CHANGED()
        ERACombatOptions_close()
        c:updateTalents()
    end
    function events:ACTIVE_PLAYER_SPECIALIZATION_CHANGED()
        ERACombatOptions_close()
        c:updateTalents()
    end
    function events:TRAIT_CONFIG_UPDATED()
        c:updateTalents()
    end
    function events:TRAIT_NODE_CHANGED()
        c:updateTalents()
    end
    function events:TRAIT_NODE_CHANGED_PARTIAL()
        c:updateTalents()
    end
    function events:PLAYER_LEVEL_UP()
        c:updateTalents()
    end
    function events:PLAYER_EQUIPMENT_CHANGED()
        c:updateTalents()
    end

    function events:PLAYER_ENTERING_WORLD(arg)
        c:resetToIdle(true)
    end

    c.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            events[event](self, ...)
        end
    )
    for k, v in pairs(events) do
        c.frame:RegisterEvent(k)
    end

    c.frame:SetScript(
        "OnUpdate",
        function(self, elapsed)
            if (#c.updateableModules > 0) then
                local t = GetTime()
                c:checkReset(t)
                if c.talents_changed > 0 then
                    c:checkModuleTalents()
                end
                if (c.inCombat) then
                    for _, m in ipairs(c.updateableModules) do
                        m:updateCombat(t, elapsed)
                    end
                else
                    for _, m in ipairs(c.updateableModules) do
                        m:updateIdle(t, elapsed)
                    end
                end
                c:UpdateCombat(t, elapsed)
            end
        end
    )

    return c
end

function ERACombatMainFrame:Pack()
    for _, m in ipairs(self.modules) do
        m:Pack()
    end
    self:resetToIdle(true)
end

function ERACombatMainFrame:updateTalents()
    ERACombatMainFrame_updateComputeTalents()
    self:checkModuleTalents()
    self.talents_changed = GetTime()
end
function ERACombatMainFrame:checkModuleTalents()
    self.talents_changed = 0
    for _, m in ipairs(self.activeModules) do
        m:CheckTalents()
    end
end

function ERACombatMainFrame_updateComputeTalents()
    local selectedTalentsById = {}
    local configId = C_ClassTalents.GetActiveConfigID()
    if configId then
        local configInfo = C_Traits.GetConfigInfo(configId)
        if configInfo then
            for _, treeId in ipairs(configInfo.treeIDs) do
                local nodes = C_Traits.GetTreeNodes(treeId)
                for _, nodeId in ipairs(nodes) do
                    local node = C_Traits.GetNodeInfo(configId, nodeId)
                    if node.ID ~= 0 then
                        for _, talentId in ipairs(node.entryIDs) do
                            local entryInfo = C_Traits.GetEntryInfo(configId, talentId)
                            if entryInfo.definitionID then
                                local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                                local spellID = definitionInfo.spellID
                                local rank = node.activeRank
                                if node.activeEntry then
                                    rank = node.activeEntry.entryID == talentId and node.activeEntry.rank or 0
                                end
                                if node.subTreeID then
                                    local subTreeInfo = C_Traits.GetSubTreeInfo(configId, node.subTreeID)
                                    if not subTreeInfo.isActive then
                                        rank = 0
                                    end
                                end
                                if (rank > 0) then
                                    selectedTalentsById[talentId] = rank
                                end
                                ----[[
                                if (spellID and not ERA_TALENTS_PRINTED) then
                                    local spellInfo = C_Spell.GetSpellInfo(spellID)
                                    table.insert(ERA_TALENTS_TO_PRINT, { talentId = talentId, name = spellInfo.name })
                                end
                                --]]
                            end
                        end
                    end
                end
            end
        end
    end

    if not ERA_TALENTS_PRINTED then
        ERA_TALENTS_PRINTED = true
        table.sort(ERA_TALENTS_TO_PRINT, ERAPrintTalents_sort)
    end

    for _, t in ipairs(ERALIBTalent_all_talents) do
        t:update(selectedTalentsById)
    end
end

ERA_TALENTS_PRINTED = false
ERA_TALENTS_TO_PRINT = {}
function ERAPrintTalents_sort(t1, t2)
    if (t1.name) then
        if (t2.name) then
            return t1.name < t2.name
        else
            return false
        end
    else
        return true
    end
end

---@param startIndexInclusive integer|nil
---@param endIndexInclusive integer|nil
---@param firstLetter string|nil
function ECF_PRINT_TALENTS(startIndexInclusive, endIndexInclusive, firstLetter)
    for i, t in ipairs(ERA_TALENTS_TO_PRINT) do
        if ((not startIndexInclusive) or i >= startIndexInclusive) and ((not endIndexInclusive) or i <= endIndexInclusive) and (((not firstLetter) or firstLetter == '') or string.lower(string.sub(t.name, 1, 1)) == string.lower(firstLetter)) then
            --if t.talentId ==  then
            print(t.talentId, t.name)
        end
    end
end


function ERACombatMainFrame:resetToIdle(fullReset)
    ERACombatMainFrame_updateComputeTalents()
    self.activeModules = {}
    local specID = GetSpecialization()
    --[[
    if (self.hideAlertsForSpec) then
        local hideA = false
        for _, specOptions in ipairs(self.hideAlertsForSpec) do
            ---@cast specOptions ERACombatSpecOptions|nil
            if (specOptions and specOptions.specID == specID and not specOptions.hideSAO) then
                hideA = true
                break
            end
        end
        if (hideA) then
            SetCVar("displaySpellActivationOverlays", 0)
        else
            SetCVar("displaySpellActivationOverlays", 1)
        end
    end
    ]]
    for _, m in ipairs(self.modules) do
        m:updateSpec(specID, fullReset)
        if (m.specActive) then
            table.insert(self.activeModules, m)
        end
    end
    for _, m in ipairs(self.activeModules) do
        m:ResetToIdle()
    end
    self:registerUpdateIdle()
    self.lastReset = GetTime()
end

function ERACombatMainFrame:checkReset(t)
    if (self.lastReset and t - self.lastReset >= 4) then
        self.lastReset = nil
        for _, m in ipairs(self.activeModules) do
            m:UpdateAfterReset(t)
        end
    end
end

function ERACombatMainFrame:enterCombat(fromIdle)
    self.updateableModules = {}
    for _, m in ipairs(self.activeModules) do
        if (m.combatUpdate >= 0) then
            table.insert(self.updateableModules, m)
        end
    end
    for _, m in ipairs(self.activeModules) do
        m:EnterCombat(fromIdle)
    end
    self:EnterCombat(fromIdle)
end

function ERACombatMainFrame:EnterCombat(fromIdle)
end

function ERACombatMainFrame:UpdateCombat(t, elapsed)
end

function ERACombatMainFrame:exitCombat(toIdle)
    for _, m in ipairs(self.activeModules) do
        m:ExitCombat(toIdle)
    end
end

function ERACombatMainFrame:registerUpdateIdle()
    self.updateableModules = {}
    for _, m in ipairs(self.activeModules) do
        if (m.idleUpdate >= 0) then
            table.insert(self.updateableModules, m)
        end
    end
end

function ERACombatMainFrame:enterIdle(fromCombat)
    self:registerUpdateIdle()
    for _, m in ipairs(self.activeModules) do
        m:EnterIdle(fromCombat)
    end
end

function ERACombatMainFrame:exitIdle(toCombat)
    for _, m in ipairs(self.activeModules) do
        m:ExitIdle(toCombat)
    end
end

function ERACombatMainFrame:enterVehicle(fromCombat)
    for _, m in ipairs(self.activeModules) do
        m:EnterVehicle(fromCombat)
    end
    self:EnterVehicle(fromCombat)
end

function ERACombatMainFrame:EnterVehicle(fromCombat)
end

function ERACombatMainFrame:exitVehicle(toCombat)
    for _, m in ipairs(self.activeModules) do
        m:ExitVehicle(toCombat)
    end
    self:ExitVehicle(toCombat)
end

function ERACombatMainFrame:ExitVehicle(toCombat)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--#region COMBAT MODULE ----------------------------------------------------------------------------------------------------------

---@class ERACombatModule
---@field cFrame ERACombatMainFrame
---@field protected construct fun(this:ERACombatModule, cFrame:ERACombatMainFrame, idleUpdate:number, combatUpdate:number, ...:number)
---@field protected UpdateIdle fun(this:ERACombatModule, t:number, elapsed:number): nil
---@field protected UpdateCombat fun(this:ERACombatModule, t:number, elapsed:number): nil
ERACombatModule = {}
ERACombatModule.__index = ERACombatModule

---comment
---@param cFrame ERACombatMainFrame
---@param idleUpdate number
---@param combatUpdate number
---@param ... number
function ERACombatModule:constructModule(cFrame, idleUpdate, combatUpdate, ...)
    self.cFrame = cFrame
    self.idleUpdate = idleUpdate
    self.combatUpdate = combatUpdate
    self.lastIdleUpdate = 0
    self.lastCombatUpdate = 0
    self.specActive = false
    self.specs = {}
    for i, s in ipairs { ... } do
        if (s) then
            table.insert(self.specs, s)
        end
    end
    ---@cast cFrame unknown
    table.insert(cFrame.modules, self)
end

function ERACombatModule:updateSpec(specID, fullReset)
    local old = fullReset or self.specActive
    self.specActive = false
    for i, s in ipairs(self.specs) do
        if (s == specID) then
            self.specActive = true
            break
        end
    end
    if (self.specActive) then
        self:SpecActive(old)
        self:CheckTalents()
    else
        self:SpecInactive(old)
    end
end

function ERACombatModule:CheckTalents()
end

function ERACombatModule:SpecActive(wasActive)
end
function ERACombatModule:SpecInactive(wasActive)
end

function ERACombatModule:ResetToIdle()
end

function ERACombatModule:Pack()
end

function ERACombatModule:UpdateAfterReset(t)
end

---comment
---@param fromCombat boolean
function ERACombatModule:EnterIdle(fromCombat)
end

---comment
---@param toCombat boolean
function ERACombatModule:ExitIdle(toCombat)
end

---comment
---@param fromIdle boolean
function ERACombatModule:EnterCombat(fromIdle)
end

---comment
---@param toIdle boolean
function ERACombatModule:ExitCombat(toIdle)
end

---comment
---@param fromCombat boolean
function ERACombatModule:EnterVehicle(fromCombat)
end

---comment
---@param toCombat boolean
function ERACombatModule:ExitVehicle(toCombat)
end

function ERACombatModule:updateCombat(t, elapsed)
    if (t - self.lastCombatUpdate < self.combatUpdate) then
        return
    end
    self.lastCombatUpdate = t
    self:UpdateCombat(t, elapsed)
end

function ERACombatModule:updateIdle(t, elapsed)
    if (t - self.lastIdleUpdate < self.idleUpdate) then
        return
    end
    self.lastIdleUpdate = t
    self:UpdateIdle(t, elapsed)
end

--#endregion
--------------------------------------------------------------------------------------------------------------------------------

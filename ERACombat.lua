if ERACombatFrame then
    return
end

-- TODO
-- rien

--------------------------------------------------------------------------------------------------------------------------------
-- COMBAT FRAME ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatFrame = {}
ERACombatFrame.__index = ERACombatFrame

function ERACombatFrame:Create()
    local c = {}
    setmetatable(c, ERACombatFrame)
    c.playerGUID = UnitGUID("player")
    c.inCombat = false
    c.inVehicle = false
    c.frame = CreateFrame("Frame", nil, UIParent, nil)

    -- contenu
    c.modules = {}
    c.activeModules = {}
    c.updateableModules = {}
    c.cleuModules = {}

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
        c:updateTalents()
    end
    function events:ACTIVE_PLAYER_SPECIALIZATION_CHANGED()
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

    function events:PLAYER_ENTERING_WORLD(arg)
        c:resetToIdle(true)
    end

    c.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
                local t = GetTime()
                for i, m in ipairs(c.cleuModules) do
                    m:CLEU(t)
                end
            else
                events[event](self, ...)
            end
        end
    )
    for k, v in pairs(events) do
        c.frame:RegisterEvent(k)
    end

    return c
end

function ERACombatFrame:newModule(m)
    table.insert(self.modules, m)
end

function ERACombatFrame:Pack()
    for _, m in ipairs(self.modules) do
        m:Pack()
    end
    self:resetToIdle(true)
end

function ERACombatFrame:updateTalents()
    ERACombatFrame_updateComputeTalents()
    for _, m in ipairs(self.activeModules) do
        m:CheckTalents()
    end
end

function ERACombatFrame_updateComputeTalents()
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

    if (ERA_TALENTS_DO_PRINT_N > 0 and not ERA_TALENTS_PRINTED) then
        ERA_TALENTS_PRINTED = true
        table.sort(ERA_TALENTS_TO_PRINT, ERAPrintTalents_sort)
        for i, t in ipairs(ERA_TALENTS_TO_PRINT) do
            if (i < ERA_TALENTS_DO_PRINT_N) then
                print(t.talentId, t.name)
            end
        end
    end

    for _, t in ipairs(ERALIBTalent_all_talents) do
        t:update(selectedTalentsById)
    end
end

ERA_TALENTS_DO_PRINT_N = 0
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


function ERACombatFrame:resetToIdle(fullReset)
    ERACombatFrame_updateComputeTalents()
    self.activeModules = {}
    self.cleuModules = {}
    local specID = GetSpecialization()
    if (self.hideAlertsForSpec) then
        local hideA = false
        for _, hfs in ipairs(self.hideAlertsForSpec) do
            if (hfs == specID) then
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
    for _, m in ipairs(self.modules) do
        m:updateSpec(specID, fullReset)
        if (m.specActive) then
            table.insert(self.activeModules, m)
            if (m.requiresCLEU) then
                table.insert(self.cleuModules, m)
            end
        end
    end
    for _, m in ipairs(self.activeModules) do
        m:ResetToIdle()
    end
    self:registerUpdateIdle()
    self.lastReset = GetTime()
end

function ERACombatFrame:checkReset(t)
    if (self.lastReset and t - self.lastReset >= 4) then
        self.lastReset = nil
        for _, m in ipairs(self.activeModules) do
            m:UpdateAfterReset(t)
        end
    end
end

function ERACombatFrame:enterCombat(fromIdle)
    self.updateableModules = {}
    for _, m in ipairs(self.activeModules) do
        if (m.combatUpdate >= 0) then
            table.insert(self.updateableModules, m)
        end
    end
    if (#self.updateableModules > 0) then
        local thisself = self
        self.frame:SetScript(
            "OnUpdate",
            function(self, elapsed)
                local t = GetTime()
                thisself:checkReset(t)
                for _, m in ipairs(thisself.updateableModules) do
                    m:updateCombat(t, elapsed)
                end
                thisself:UpdateCombat(t, elapsed)
            end
        )
    else
        self.frame:SetScript("OnUpdate", nil)
    end
    if (#self.cleuModules > 0) then
        self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    for _, m in ipairs(self.activeModules) do
        m:EnterCombat(fromIdle)
    end
    self:EnterCombat(fromIdle)
end

function ERACombatFrame:EnterCombat(fromIdle)
end

function ERACombatFrame:UpdateCombat(t, elapsed)
end

function ERACombatFrame:exitCombat(toIdle)
    self.frame:SetScript("OnUpdate", nil)
    if (#self.cleuModules > 0) then
        self.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    for _, m in ipairs(self.activeModules) do
        m:ExitCombat(toIdle)
    end
end

function ERACombatFrame:registerUpdateIdle()
    self.updateableModules = {}
    for _, m in ipairs(self.activeModules) do
        if (m.idleUpdate >= 0) then
            table.insert(self.updateableModules, m)
        end
    end
    if (#self.updateableModules > 0) then
        local thisself = self
        self.frame:SetScript(
            "OnUpdate",
            function(self, elapsed)
                local t = GetTime()
                thisself:checkReset(t)
                for _, m in ipairs(thisself.updateableModules) do
                    m:updateIdle(t, elapsed)
                end
            end
        )
    else
        self.frame:SetScript("OnUpdate", nil)
    end
end

function ERACombatFrame:enterIdle(fromCombat)
    self:registerUpdateIdle()
    for _, m in ipairs(self.activeModules) do
        m:EnterIdle(fromCombat)
    end
end

function ERACombatFrame:exitIdle(toCombat)
    self.frame:SetScript("OnUpdate", nil)
    for _, m in ipairs(self.activeModules) do
        m:ExitIdle(toCombat)
    end
end

function ERACombatFrame:enterVehicle(fromCombat)
    for _, m in ipairs(self.activeModules) do
        m:EnterVehicle(fromCombat)
    end
    self:EnterVehicle(fromCombat)
end

function ERACombatFrame:EnterVehicle(fromCombat)
end

function ERACombatFrame:exitVehicle(toCombat)
    for _, m in ipairs(self.activeModules) do
        m:ExitVehicle(toCombat)
    end
    self:ExitVehicle(toCombat)
end

function ERACombatFrame:ExitVehicle(toCombat)
end

--------------------------------------------------------------------------------------------------------------------------------
-- COMBAT MODULE ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatModule = {}
ERACombatModule.__index = ERACombatModule

function ERACombatModule:construct(cFrame, idleUpdate, combatUpdate, requiresCLEU, ...)
    self.cFrame = cFrame
    self.idleUpdate = idleUpdate
    self.combatUpdate = combatUpdate
    self.lastIdleUpdate = 0
    self.lastCombatUpdate = 0
    self.requiresCLEU = requiresCLEU
    self.specActive = false
    self.specs = {}
    for i, s in ipairs { ... } do
        if (s) then
            table.insert(self.specs, s)
        end
    end
    cFrame:newModule(self)
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
        self:CheckTalents()
    else
        self:SpecInactive(old)
    end
end

function ERACombatModule:CheckTalents()
end

function ERACombatModule:SpecInactive(wasActive)
end

function ERACombatModule:ResetToIdle()
end

function ERACombatModule:Pack()
end

function ERACombatModule:UpdateAfterReset(t)
end

function ERACombatModule:EnterIdle(fromCombat)
end

function ERACombatModule:ExitIdle(toCombat)
end

function ERACombatModule:EnterCombat(fromIdle)
end

function ERACombatModule:ExitCombat(toIdle)
end

function ERACombatModule:EnterVehicle(fromCombat)
end

function ERACombatModule:ExitVehicle(toCombat)
end

function ERACombatModule:updateCombat(t, elapsed)
    if (t - self.lastCombatUpdate < self.combatUpdate) then
        return
    end
    self.lastCombatUpdate = t
    self:UpdateCombat(t, elapsed)
end

function ERACombatModule:UpdateCombat(t, elapsed)
end

function ERACombatModule:updateIdle(t, elapsed)
    if (t - self.lastIdleUpdate < self.idleUpdate) then
        return
    end
    self.lastIdleUpdate = t
    self:UpdateIdle(t, elapsed)
end

function ERACombatModule:UpdateIdle(t, elapsed)
end

function ERACombatModule:CLEU(t)
end

--------------------------------------------------------------------------------------------------------------------------------
-- PSEUDO RESOURCE BAR ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatFrames_PseudoResourceBar = {}
ERACombatFrames_PseudoResourceBar.__index = ERACombatFrames_PseudoResourceBar
setmetatable(ERACombatFrames_PseudoResourceBar, { __index = ERACombatModule })

function ERACombatFrames_PseudoResourceBar:constructPseudoResource(cFrame, x, y, length, thickness, margin, anchor, showText, spec)
    self:construct(cFrame, -1, 0.1, false, spec)

    self.length = length

    self.frame = CreateFrame("Frame", nil, UIParent, nil)
    self.frame:SetSize(length, thickness)
    if (anchor == 1) then
        self.frame:SetPoint("RIGHT", UIParent, "CENTER", x, y)
    else
        self.frame:SetPoint("LEFT", UIParent, "CENTER", x, y)
    end
    self.frame:Hide()
    self.visible = false

    self.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.background:SetColorTexture(0, 0, 0, 0.5)
    self.background:SetAllPoints() -- CHANGE 11 GetNumRaidMembers()SetAllPoints(true)

    self.bar = self.frame:CreateTexture(nil, "ARTWORK")
    self.bar:SetColorTexture(1, 0, 0, 1)
    if (anchor == 1) then
        self.bar:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, -margin)
        self.bar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, margin)
    else
        self.bar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -margin)
        self.bar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, margin)
    end
    self.bar:SetWidth(0)

    self.text = self.frame:CreateFontString(nil, "OVERLAY")
    ERALIB_SetFont(self.text, 16)
    if (anchor == 1) then
        self.text:SetPoint("RIGHT", self.frame, "RIGHT", -2, 0)
    else
        self.text:SetPoint("LEFT", self.frame, "LEFT", 2, 0)
    end

    self.rB = 1.0
    self.gB = 0.0
    self.bB = 0.0

    self.showText = showText
    self.value = -1
    self.max = 0
end

function ERACombatFrames_PseudoResourceBar:Show(wasActive)
    if (not self.visible) then
        self.visible = true
        self.frame:Show()
    end
end
function ERACombatFrames_PseudoResourceBar:Hide(wasActive)
    if (self.visible) then
        self.visible = false
        self.frame:Hide()
    end
end

function ERACombatFrames_PseudoResourceBar:SpecInactive(wasActive)
    self:Hide()
end

function ERACombatFrames_PseudoResourceBar:ResetToIdle()
    self:Hide()
    self:OnResetToIdle()
end

function ERACombatFrames_PseudoResourceBar:OnResetToIdle()
end

function ERACombatFrames_PseudoResourceBar:EnterCombat(fromIdle)
    self:Show()
end

function ERACombatFrames_PseudoResourceBar:ExitCombat(toIdle)
    self:Hide()
end

function ERACombatFrames_PseudoResourceBar:UpdateCombat(t)
    local val = self:GetValue(t)
    local max = self:GetMax(t)
    if (self.value ~= val or self.max ~= max) then
        self.value = val
        self.max = max
        if (self.showText) then
            self.text:SetText(tostring(math.floor(val)))
        end
        self.bar:SetWidth(self.length * val / max)
    end
    self:Updated(t)
end
function ERACombatFrames_PseudoResourceBar:Updated(t)
end

function ERACombatFrames_PseudoResourceBar:SetBarColor(r, g, b)
    if (r ~= self.rB or g ~= self.gB or b ~= self.bB) then
        self.rB = r
        self.gB = g
        self.bB = b
        self.bar:SetColorTexture(r, g, b, 1)
    end
end

-- abstract function ERACombatFrames_PseudoResourceBar:GetValue(t)
-- abstract function ERACombatFrames_PseudoResourceBar:GetMax(t)

--------------------------------------------------------------------------------------------------------------------------------
-- ENEMIES ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatEnemies = {}
ERACombatEnemies.__index = ERACombatEnemies
setmetatable(ERACombatEnemies, { __index = ERACombatModule })

function ERACombatEnemies:Create(cFrame, ...)
    local e = {}
    setmetatable(e, ERACombatEnemies)
    e.enemies = {}
    e.eCount = 0
    e:construct(cFrame, -1, 1, true, ...)
    return e
end

function ERACombatEnemies:GetCount()
    return self.eCount
end

function ERACombatEnemies:ResetToIdle()
    self.enemies = {}
    self.eCount = 0
end

function ERACombatEnemies:SpecInactive(wasActive)
    if (wasActive) then
        self.enemies = {}
        self.eCount = 0
    end
end

function ERACombatEnemies:EnterCombat()
    self.enemies = {}
    self.eCount = 0
end

function ERACombatEnemies:ExitCombat()
    self.enemies = {}
    self.eCount = 0
end

function ERACombatEnemies:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, targetGUY = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_DAMAGE" or evt == "SWING_DAMAGE" or evt == "SPELL_PERIODIC_DAMAGE" or evt == "SWING_MISSED" or evt == "SPELL_MISSED") then
        if (sourceGUY == self.cFrame.playerGUID) then
            local already = self.enemies[targetGUY]
            if (not already) then
                self.eCount = self.eCount + 1
            end
            self.enemies[targetGUY] = t
        end
    elseif (evt == "UNIT_DIED" or evt == "UNIT_DESTROYED" or evt == "UNIT_DISSIPATES") then
        if (self.enemies[targetGUY]) then
            self.enemies[targetGUY] = nil
            self.eCount = self.eCount - 1
        end
    end
end

function ERACombatEnemies:UpdateCombat(t, elapsed)
    local toRemove = {}
    for id, lastHit in pairs(self.enemies) do
        if (t - lastHit > 13) then
            table.insert(toRemove, id)
        end
    end
    for _, id in ipairs(toRemove) do
        self.enemies[id] = nil
    end
    self.eCount = self.eCount - #toRemove
end

--------------------------------------------------------------------------------------------------------------------------------
-- FRIENDS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatFriends = {}
ERACombatFriends.__index = ERACombatFriends

function ERACombatFriends:Create()
    local f = {}
    setmetatable(f, ERACombatFriends)
    f.maxFriends = 0
    f.prefix = nil
    f.lastCombatUpdate = 0
    return f
end

function ERACombatFriends:updateGroupType(t)
    self.lastGroupType = t
    if (IsInRaid()) then
        self.prefix = "raid"
        self.maxFriends = GetNumGroupMembers() -- CHANGE 11 GetNumRaidMembers()
    elseif (IsInGroup()) then
        self.prefix = "party"
        self.maxFriends = GetNumGroupMembers()
    else
        self.maxFriends = 0
        self.prefix = nil
    end
end

function ERACombatFriends:ParseFriends(t)
    if (t - self.lastCombatUpdate >= 1) then
        self:updateGroupType(t)
    end
    if (self.maxFriends > 0) then
        -- note : UnitIsUnit(unit, "player")
        for i = 1, self.maxFriends do
            if (not self:ParseFriend(t, self.prefix .. i)) then
                break
            end
        end
    else
        self:ParseFriend(t, "player")
    end
end

function ERACombatFriends:ParseFriend(t, unitID)
    return false
end

ERACombatFriendsModule = {}
ERACombatFriendsModule.__index = ERACombatFriendsModule
setmetatable(ERACombatFriendsModule, { __index = ERACombatModule })

function ERACombatFriendsModule:constructFriends(cFrame, updateTime, ...)
    self:construct(cFrame, -1, updateTime, true, ...)
    self.friends = ERACombatFriends:Create()
    function self.friends:ParseFriend(t, unitID)
        return self:ParseFriend(t, unitID)
    end
end

function ERACombatFriendsModule:EnterCombat()
    self.friends.lastGroupType = 0
end

function ERACombatFriendsModule:UpdateCombat(t, elapsed)
    self:StartParse(t)
    self.friends:ParseFriends(t)
    self:EndParse(t)
end

function ERACombatFriendsModule:StartParse(t)
end

function ERACombatFriendsModule:ParseFriend(t, unitID)
    return false
end

function ERACombatFriendsModule:EndParse(t)
end

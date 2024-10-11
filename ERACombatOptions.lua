SLASH_ECF1 = "/ECF"
SlashCmdList["ECF"] = function(msg)
    --ERACombatOptionsFrame:Show()
    ERACombatOptions_open()
end

---@class ERACombatSpecOptions
---@field specID integer
---@field disabled boolean|nil
---@field offsetY number|nil
---@field leftX number|nil
---@field rightX number|nil
---@field bottomY number|nil
---@field hideSAO boolean|nil
---@field hideUtility boolean|nil

---@class OptionSliderFrame
---@field Slider Slider

---@class (exact) ERACombatOptionsSlider
---@field SliderFrame OptionSliderFrame
---@field Label FontString
---@field Result FontString

---@class (exact) ERACombatOptionsWindow : Frame
---@field CBX CheckButton
---@field YSlider ERACombatOptionsSlider
---@field LeftSlider ERACombatOptionsSlider
---@field RightSlider ERACombatOptionsSlider
---@field BottomSlider ERACombatOptionsSlider
---@field Utility CheckButton
---@field SAO CheckButton
---@field Grid CheckButton
---@field GridByRole CheckButton
---@field TankWindow CheckButton
---@field currentSpec ERACombatSpecOptions|nil

BINDING_HEADER_ERACOMBATFRAMES = "ERACombatFrames"
BINDING_NAME_ERACOMBATFRAMES_RELOADUI = "Reload UI"
BINDING_NAME_ERACOMBATFRAMES_SPEC1 = "spec 1"
BINDING_NAME_ERACOMBATFRAMES_SPEC2 = "spec 2"
BINDING_NAME_ERACOMBATFRAMES_SPEC3 = "spec 3"
BINDING_NAME_ERACOMBATFRAMES_SPEC4 = "spec 4"
BINDING_NAME_ERACOMBATFRAMES_LOOTSPEC1 = "loot spec 1"
BINDING_NAME_ERACOMBATFRAMES_LOOTSPEC2 = "loot spec 2"
BINDING_NAME_ERACOMBATFRAMES_LOOTSPEC3 = "loot spec 3"
BINDING_NAME_ERACOMBATFRAMES_LOOTSPEC4 = "loot spec 4"

ERACombatGlobals_SpecID1 = 0
ERACombatGlobals_SpecID2 = 0
ERACombatGlobals_SpecID3 = 0
ERACombatGlobals_SpecID4 = 0

ERACombatOptions_FrameContentOffset = 32
ERACombatOptions_FrameContentWidth = 1004

ERACombatOptions_TankWindow = "damage chart"
ERACombatOptions_Grid = "group/raid frames"
ERACombatOptions_GridByRole = "grfbr"

---@param classID integer
---@param specID integer
---@param optionName string
function ERACombatOptions_addSpecOption(classID, specID, optionName)
    local class = ERACombatOptionsVariables[classID]
    if (not class) then
        class = {}
        ERACombatOptionsVariables[classID] = class
    end
    local spec = class[specID]
    if (not spec) then
        spec = {}
        class[specID] = spec
    end
    spec.specID = specID
    if (spec[optionName] == nil) then
        spec[optionName] = true
    end
end
---@param classID integer
---@param specID integer
function ERACombatOptions_addGridOption(classID, specID)
    ERACombatOptions_addSpecOption(classID, specID, ERACombatOptions_Grid)
    ERACombatOptions_addSpecOption(classID, specID, ERACombatOptions_GridByRole)
end

---@param spec ERACombatSpecOptions
---@return boolean
function ERACombatOptions_isHealer(spec)
    return spec[ERACombatOptions_Grid] ~= nil
end

---@param classID integer
function ERACombatOptions_setup(classID)
    if ERACombatOptionsVariables == nil then
        ERACombatOptionsVariables = {}
    end

    ERACombatOptions_addGridOption(2, 1)                               -- paladin holy
    ERACombatOptions_addGridOption(5, 1)                               -- priest disc
    ERACombatOptions_addGridOption(5, 2)                               -- priest holy
    ERACombatOptions_addSpecOption(6, 1, ERACombatOptions_TankWindow)  -- dk blood
    ERACombatOptions_addGridOption(10, 2)                              -- monk heal
    ERACombatOptions_addGridOption(11, 4)                              -- druid heal
    ERACombatOptions_addSpecOption(12, 2, ERACombatOptions_TankWindow) -- dh vengeance
    ERACombatOptions_addGridOption(13, 2)                              -- evo heal

    local classOptions = ERACombatOptionsVariables[classID]
    if (not classOptions) then
        classOptions = {}
        ERACombatOptionsVariables[classID] = class
    end

    local w = ERACombatOptionsWindow
    local txt = w.CBX.Text
    ---@cast w ERACombatOptionsWindow
    ---@cast txt FontString

    ERALIB_SetFont(txt, 22)

    ERACombatOptions_initializeSlider(w.YSlider, "Y offset", -333, 333, ERAHUD_OffsetY)
    ERACombatOptions_initializeSlider(w.LeftSlider, "left offset (timers)", -444, -111, -ERAHUD_OffsetX)
    ERACombatOptions_initializeSlider(w.RightSlider, "right offset (utility cooldowns/icons)", 111, 444, ERAHUD_UtilityMinRightX)
    ERACombatOptions_initializeSlider(w.BottomSlider, "bottom offset (utility cooldowns/icons)", -333, -111, -ERAHUD_UtilityMinBottomY)

    local cbxUtility = w.Utility
    local cbxSAO = w.SAO
    local cbxGrid = w.Grid
    local cbxGridByRole = w.GridByRole
    local cbxTankWindow = w.TankWindow
    ---@cast cbxUtility unknown
    ---@cast cbxSAO unknown
    ---@cast cbxGrid unknown
    ---@cast cbxGridByRole unknown
    ---@cast cbxTankWindow unknown
    cbxUtility.Text:SetText("utility cooldowns and icons")
    cbxSAO.Text:SetText("spell activation overlay")
    cbxGrid.Text:SetText("group/raid frame")
    cbxGridByRole.Text:SetText("group/raid frame : display by role rather than by groups")
    cbxTankWindow.Text:SetText("damage taken chart")
end

---@param s ERACombatOptionsSlider
---@param label string
---@param minValue number
---@param maxValue number
---@param defaultValue number
function ERACombatOptions_initializeSlider(s, label, minValue, maxValue, defaultValue)
    s.Label:SetText(label)
    s.SliderFrame.Slider:SetMinMaxValues(minValue, maxValue)
    s.SliderFrame.Slider:SetValueStep(1)
    s.SliderFrame.Slider:SetScript("OnValueChanged", function(self, value, userInput)
        s.Result:SetText(tostring(math.floor(value)))
    end)
    s.SliderFrame.Slider:SetValue(defaultValue, false)
end

---@param s ERACombatOptionsSlider
---@param value number|nil
---@param defaultValue number
function ERACombatOptions_setupSlider(s, value, defaultValue)
    if value == nil then value = defaultValue end
    s.SliderFrame.Slider:SetValue(value)
end

function ERACombatOptions_close()
    ERACombatOptionsWindow.currentSpec = nil
    ERACombatOptionsWindow:Hide()
end
function ERACombatOptions_open()
    local _, _, classID = UnitClass("player")
    local specID = GetSpecialization()
    local _, name = GetSpecializationInfoForClassID(classID, specID)

    local w = ERACombatOptionsWindow
    local txt = w.CBX.Text
    ---@cast w ERACombatOptionsWindow
    ---@cast txt FontString
    txt:SetText("enable for specialization : " .. name)

    local specOptions = ERACombatOptions_getOptionsForSpec(classID, specID)

    w.CBX:SetChecked(not specOptions.disabled)

    local leftX, offY
    if ERACombatOptions_isHealer(specOptions) then
        leftX = ERAHUD_HealerOffsetX
        offY = ERAHUD_HealerTimerOffsetY
    else
        leftX = ERAHUD_OffsetX
        offY = ERAHUD_OffsetY
    end
    ERACombatOptions_setupSlider(w.YSlider, specOptions.offsetY, offY)
    ERACombatOptions_setupSlider(w.LeftSlider, specOptions.leftX, leftX)
    ERACombatOptions_setupSlider(w.RightSlider, specOptions.rightX, ERAHUD_UtilityMinRightX)
    ERACombatOptions_setupSlider(w.BottomSlider, specOptions.bottomY, ERAHUD_UtilityMinBottomY)

    w.Utility:SetChecked(not specOptions.hideUtility)
    w.SAO:SetChecked(not specOptions.hideSAO)

    local grid = specOptions[ERACombatOptions_Grid]
    if grid == nil then
        w.Grid:Hide()
        w.GridByRole:Hide()
    else
        w.Grid:SetChecked(grid)
        w.Grid:Show()
        local GridByRoles = specOptions[ERACombatOptions_GridByRole]
        if GridByRoles == nil then
            w.GridByRole:Hide()
        else
            w.GridByRole:SetChecked(GridByRoles)
            w.GridByRole:Show()
        end
    end

    local tw = specOptions[ERACombatOptions_TankWindow]
    if tw == nil then
        w.TankWindow:Hide()
    else
        w.TankWindow:SetChecked(tw)
        w.TankWindow:Show()
    end

    w.currentSpec = specOptions

    w:Show()
end

function ERACombatOptions_confirmAndReload()
    local w = ERACombatOptionsWindow
    ---@cast w ERACombatOptionsWindow
    if w.currentSpec ~= nil then
        w.currentSpec.disabled = not w.CBX:GetChecked()
        w.currentSpec.offsetY = w.YSlider.SliderFrame.Slider:GetValue()
        w.currentSpec.leftX = w.LeftSlider.SliderFrame.Slider:GetValue()
        w.currentSpec.rightX = w.RightSlider.SliderFrame.Slider:GetValue()
        w.currentSpec.bottomY = w.BottomSlider.SliderFrame.Slider:GetValue()
        w.currentSpec.hideUtility = not w.Utility:GetChecked()
        w.currentSpec.hideSAO = not w.SAO:GetChecked()
        if w.currentSpec[ERACombatOptions_Grid] ~= nil then
            w.currentSpec[ERACombatOptions_Grid] = w.Grid:GetChecked()
            w.currentSpec[ERACombatOptions_GridByRole] = w.GridByRole:GetChecked()
        end
        if w.currentSpec[ERACombatOptions_TankWindow] ~= nil then
            w.currentSpec[ERACombatOptions_TankWindow] = w.TankWindow:GetChecked()
        end
    end
    C_UI.Reload()
end

---@param classID integer|nil
---@param specID integer|nil
---@return ERACombatSpecOptions
function ERACombatOptions_getOptionsForSpec(classID, specID)
    if classID == nil then
        _, _, classID = UnitClass("player")
    end
    if specID == nil then
        specID = GetSpecialization()
    end
    local classData = ERACombatOptionsVariables[classID]
    if classData == nil then
        classData = {}
        ERACombatOptionsVariables[classID] = classData
    end
    local specData = classData[specID]
    if specData == nil then
        specData = {}
        classData[specID] = specData
    end
    specData.specID = specID
    return specData
end

---@param specID integer
---@param moduleName string
---@return boolean
function ERACombatOptions_IsSpecModuleActive(specID, moduleName)
    local c = ERACombatOptionsVariables[ERACombatFrames_classID]
    if (c) then
        local s = c[specID]
        if (s) then
            return s[moduleName]
        else
            return true
        end
    else
        return true
    end
end

---@param specOptions ERACombatSpecOptions
---@return integer|nil
function ERACombatOptions_specIDOrNilIfDisabled(specOptions)
    if specOptions.disabled then
        return nil
    else
        return specOptions.specID
    end
end

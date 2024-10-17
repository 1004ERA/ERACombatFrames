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
---@field damageTakenWindow boolean|nil
---@field healerOptions ERACombatGroupFrameOptions|nil

---@class (exact) ERACombatGroupFrameOptions
---@field disabled boolean
---@field byGroup boolean
---@field horizontalGroups boolean
---@field showRaid boolean

---@class OptionSliderFrame
---@field Slider Slider

---@class (exact) ERACombatOptionsSlider
---@field SliderFrame OptionSliderFrame
---@field Label FontString
---@field Result FontString

---@class (exact) ERACombatOptionsWindow : Frame
---@field eventMasque boolean
---@field CBX CheckButton
---@field YSlider ERACombatOptionsSlider
---@field LeftSlider ERACombatOptionsSlider
---@field RightSlider ERACombatOptionsSlider
---@field BottomSlider ERACombatOptionsSlider
---@field Utility CheckButton
---@field SAO CheckButton
---@field GRFrame CheckButton
---@field GRFrameHideRaid CheckButton
---@field GRFrameByGroups CheckButton
---@field GRFrameHorizontalGroups CheckButton
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

---@param classID integer
---@param specID integer
function ERACombatOptions_addDamageTakenWindowOption(classID, specID)
    local spec = ERACombatOptions_getOptionsForSpec(classID, specID)
    if spec.damageTakenWindow == nil then
        spec.damageTakenWindow = true
    end
end

---@param spec ERACombatSpecOptions
---@return boolean
function ERACombatOptions_isHealer(spec)
    return spec.healerOptions ~= nil
end
---@param classID integer
---@param specID integer
function ERACombatOptions_setHealer(classID, specID)
    local spec = ERACombatOptions_getOptionsForSpec(classID, specID)
    if spec.healerOptions == nil then
        spec.healerOptions = {
            disabled = false,
            byGroup = false,
            horizontalGroups = false,
            showRaid = true,
        }
    end
end

---@param classID integer
function ERACombatOptions_setup(classID)
    if ERACombatOptionsVariables == nil then
        ERACombatOptionsVariables = {}
    end

    ERACombatOptions_setHealer(2, 1)                   -- paladin holy
    ERACombatOptions_setHealer(5, 1)                   -- priest disc
    ERACombatOptions_setHealer(5, 2)                   -- priest holy
    ERACombatOptions_addDamageTakenWindowOption(6, 1)  -- dk blood
    ERACombatOptions_setHealer(10, 2)                  -- monk heal
    ERACombatOptions_setHealer(11, 4)                  -- druid heal
    ERACombatOptions_addDamageTakenWindowOption(12, 2) -- dh vengeance
    ERACombatOptions_setHealer(13, 2)                  -- evo heal

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
    local cbxGR = w.GRFrame
    local cbxGRHideRaid = w.GRFrameHideRaid
    local cbxGRByGroups = w.GRFrameByGroups
    local cbxGRHorizontalGroups = w.GRFrameHorizontalGroups
    local cbxTankWindow = w.TankWindow
    ---@cast cbxUtility unknown
    ---@cast cbxSAO unknown
    ---@cast cbxGR unknown
    ---@cast cbxGRHideRaid unknown
    ---@cast cbxGRByGroups unknown
    ---@cast cbxGRHorizontalGroups unknown
    ---@cast cbxTankWindow unknown
    cbxUtility.Text:SetText("utility cooldowns and icons")
    cbxSAO.Text:SetText("spell activation overlay")
    cbxGR.Text:SetText("group/raid frame")
    cbxGRHideRaid.Text:SetText("hide in raid")
    cbxGRByGroups.Text:SetText("separate by groups")
    cbxGRHorizontalGroups.Text:SetText("horizontal groups")
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
    ERACombatOptionsWindow.eventMasque = false
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
    w.eventMasque = false

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

    if specOptions.healerOptions == nil then
        w.GRFrame:Hide()
        w.GRFrameHideRaid:Hide()
        w.GRFrameByGroups:Hide()
        w.GRFrameHorizontalGroups:Hide()
    else
        w.GRFrame:SetChecked(not specOptions.healerOptions.disabled)
        w.GRFrame:Show()
        w.GRFrameHideRaid:SetChecked(not specOptions.healerOptions.showRaid)
        w.GRFrameByGroups:SetChecked(specOptions.healerOptions.byGroup)
        w.GRFrameHorizontalGroups:SetChecked(specOptions.healerOptions.horizontalGroups)
        ERACombatOptions_updateGRFrame()
    end

    if specOptions.damageTakenWindow == nil then
        w.TankWindow:Hide()
    else
        w.TankWindow:SetChecked(specOptions.damageTakenWindow)
        w.TankWindow:Show()
    end

    w.currentSpec = specOptions

    w:Show()
    w.eventMasque = true
end

function ERACombatOptions_updateGRFrame()
    local w = ERACombatOptionsWindow
    ---@cast w ERACombatOptionsWindow
    local remember_masque = w.eventMasque
    w.eventMasque = false
    if w.GRFrame:GetChecked() then
        w.GRFrameHideRaid:Show()
        if w.GRFrameHideRaid:GetChecked() then
            w.GRFrameByGroups:Hide()
            w.GRFrameHorizontalGroups:Hide()
        else
            w.GRFrameByGroups:Show()
            if w.GRFrameByGroups:GetChecked() then
                w.GRFrameHorizontalGroups:Show()
            else
                w.GRFrameHorizontalGroups:Hide()
            end
        end
    else
        w.GRFrameHideRaid:Hide()
        w.GRFrameByGroups:Hide()
        w.GRFrameHorizontalGroups:Hide()
    end
    w.eventMasque = remember_masque
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
        if w.currentSpec.healerOptions ~= nil then
            w.currentSpec.healerOptions.disabled = not w.GRFrame:GetChecked()
            w.currentSpec.healerOptions.showRaid = not w.GRFrameHideRaid:GetChecked()
            w.currentSpec.healerOptions.byGroup = w.GRFrameByGroups:GetChecked()
            w.currentSpec.healerOptions.horizontalGroups = w.GRFrameHorizontalGroups:GetChecked()
        end
        if w.currentSpec.damageTakenWindow ~= nil then
            w.currentSpec.damageTakenWindow = w.TankWindow:GetChecked()
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

---@param specOptions ERACombatSpecOptions
---@return integer|nil
function ERACombatOptions_specIDOrNilIfDisabled(specOptions)
    if specOptions.disabled then
        return nil
    else
        return specOptions.specID
    end
end

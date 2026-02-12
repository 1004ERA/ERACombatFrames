---@class (exact) HUDModuleDruid : HUDModule
---@field shapeshiftIndex number
---@field catForm HUDPublicBooleanShapeshift
---@field bearForm HUDPublicBooleanShapeshift

---@param cFrame ERACombatMainFrame
function ERACombatFrames_DruidSetup(cFrame)
    ---@class DruidTalents
    local talents = {
        regen = ERALIBTalent:Create(103298),
        dispell = ERALIBTalent:Create(103320),
        starsurge = ERALIBTalent:Create(103278),
        sunfire = ERALIBTalent:Create(116102),
        rake = ERALIBTalent:Create(103277),
        rip = ERALIBTalent:Create(103300),
        maim = ERALIBTalent:Create(103299),
        wgrowth = ERALIBTalent:Create(103283),
        kick = ERALIBTalent:Create(103322),
        charge = ERALIBTalent:Create(103276),
        tigerdash = ERALIBTalent:Create(103275),
        stampede = ERALIBTalent:Create(103312),
        typhoon = ERALIBTalent:Create(103287),
        vortex = ERALIBTalent:Create(128589),
        entangle = ERALIBTalent:Create(103285),
        bash = ERALIBTalent:Create(103315),
        incapacitating = ERALIBTalent:Create(103316),
        innervate = ERALIBTalent:Create(103324),
        wild = ERALIBTalent:Create(103309),
    }
    talents.dash = ERALIBTalent:CreateNot(talents.tigerdash)

    ERACombatFrames_Druid_Balance(cFrame, talents)
    ERACombatFrames_Druid_Feral(cFrame, talents)
    ERACombatFrames_Druid_Guardian(cFrame, talents)
    ERACombatFrames_Druid_Restoration(cFrame, talents)
end

---@class (exact) DruidCommonSpells
---@field regen HUDCooldown
---@field dispell HUDCooldown
---@field starsurge HUDCooldown
---@field mangle HUDCooldown
---@field thrash HUDCooldown
---@field maim HUDCooldown
---@field kick HUDCooldown
---@field charge HUDCooldown
---@field tigerdash HUDCooldown
---@field stampede HUDCooldown
---@field typhoon HUDCooldown
---@field vortex HUDCooldown
---@field entangle HUDCooldown
---@field bash HUDCooldown
---@field incapacitating HUDCooldown
---@field innervate HUDCooldown
---@field wild HUDCooldown

---@param hud HUDModuleDruid
---@param talents DruidTalents
---@param isBalance boolean
---@param isFeral boolean
---@param isGuardian boolean
---@param isRestoration boolean
---@return DruidCommonSpells
function ERACombatFrames_DruidCommonSpells(hud, talents, isBalance, isFeral, isGuardian, isRestoration)
    hud:AddChannelInfo(234153, 5, 0.5)
    hud.shapeshiftIndex = 0
    hud.bearForm = hud:AddShapeshiftBoolean(1)
    hud.catForm = hud:AddShapeshiftBoolean(2)
    function hud:PreUpdateData(t, combat)
        self.shapeshiftIndex = GetShapeshiftForm()
    end

    ---@type DruidCommonSpells
    local commonSpells = {
        barkskin = hud:AddCooldown(22812),
        mangle = hud:AddCooldown(33917),
        thrash = hud:AddCooldown(77758),
        prowl = hud:AddCooldown(5215),
        regen = hud:AddCooldown(22842, talents.regen),
        dispell = hud:AddCooldown(2782, talents.dispell),
        starsurge = hud:AddCooldown(197626, talents.starsurge),
        maim = hud:AddCooldown(22570, talents.maim),
        wgrowth = hud:AddCooldown(48438, talents.wgrowth),
        kick = hud:AddCooldown(106839, talents.kick),
        charge = hud:AddCooldown(102401, talents.charge),
        dash = hud:AddCooldown(1850, talents.dash),
        tigerdash = hud:AddCooldown(252216, talents.tigerdash),
        stampede = hud:AddCooldown(106898, talents.stampede),
        typhoon = hud:AddCooldown(132469, talents.typhoon),
        vortex = hud:AddCooldown(102793, talents.vortex),
        entangle = hud:AddCooldown(102359, talents.entangle),
        bash = hud:AddCooldown(5211, talents.bash),
        incapacitating = hud:AddCooldown(99, talents.incapacitating),
        innervate = hud:AddCooldown(29166, talents.innervate),
        wild = hud:AddCooldown(1261867, talents.wild),
    }

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.barkskin)
    if (not isGuardian) then
        hud.defensiveGroup:AddCooldown(commonSpells.regen)
    end

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.charge, 538771)
    hud.movementGroup:AddCooldown(commonSpells.tigerdash)
    hud.movementGroup:AddCooldown(commonSpells.stampede)

    -- special
    if (not isRestoration) then
        hud.specialGroup:AddCooldown(commonSpells.dispell)
        hud.specialGroup:AddCooldown(commonSpells.wgrowth)
    end
    hud.specialGroup:AddCooldown(commonSpells.innervate)
    hud.specialGroup:AddCooldown(commonSpells.wild, 135879)
    hud.specialGroup:AddCooldown(commonSpells.prowl)

    -- control
    hud.controlGroup:AddCooldown(commonSpells.kick)
    hud:AddKickInfo(commonSpells.kick)
    hud.controlGroup:AddCooldown(commonSpells.typhoon)
    hud.controlGroup:AddCooldown(commonSpells.vortex)
    hud.controlGroup:AddCooldown(commonSpells.entangle)
    hud.controlGroup:AddCooldown(commonSpells.bash)
    hud.controlGroup:AddCooldown(commonSpells.incapacitating)
    hud.controlGroup:AddCooldown(commonSpells.maim)

    return commonSpells
end

---@param hud HUDModuleDruid
function ERACombatFrames_Druid_FeralOffSpec_step1(hud)
    local combo = hud:AddPowerLowIdle(Enum.PowerType.ComboPoints)
    local comboDisplay = hud:AddResourceSlot(false):AddPowerPoints(combo, 0.6, 0.8, 0.0, 1.0, 0.0, 0.0, nil, function() return 0 end)
    function comboDisplay:DynamicVisibility()
        return hud.shapeshiftIndex == 2
    end
    local nrj = hud:AddPowerHighIdle(Enum.PowerType.Energy)
    local nrjBar = hud:AddResourceSlot(false):AddPowerValue(nrj, 1.0, 1.0, 0.0)
    nrjBar:AddTick(136231, nil, function() return 40 end)
    nrjBar:AddTick(132127, nil, function() return 50 end)
    function nrjBar:DynamicVisibility()
        return hud.shapeshiftIndex == 2
    end
end
---@param hud HUDModuleDruid
---@param talents DruidTalents
---@param rakeSlot HUDEssentialsSlot|nil
---@param ripSlot HUDEssentialsSlot|nil
function ERACombatFrames_Druid_FeralOffSpec_step2(hud, talents, rakeSlot, ripSlot)
    if (rakeSlot) then
        local rake = hud:AddAuraByPlayer(1822, true, talents.rake)
        rakeSlot:AddOverlapingAura(rake).showOnlyIf = hud.catForm
    end
    if (ripSlot) then
        local rip = hud:AddAuraByPlayer(1079, true, talents.rip)
        ripSlot:AddOverlapingAura(rip).showOnlyIf = hud.catForm
    end
end

---@param hud HUDModuleDruid
function ERACombatFrames_Druid_GuardianOffSpec_step1(hud)
    local rage = hud:AddPowerLowIdle(Enum.PowerType.Rage)
    local rageBar = hud:AddResourceSlot(false):AddPowerValue(rage, 1.0, 0.0, 0.0)
    rageBar:AddTick(132276, nil, function() return 40 end)
    function rageBar:DynamicVisibility()
        return hud.shapeshiftIndex == 1
    end
end
---@param hud HUDModuleDruid
---@param talents DruidTalents
---@param spells DruidCommonSpells
---@param mangleSlot HUDEssentialsSlot
---@param thrashSlot HUDEssentialsSlot
function ERACombatFrames_Druid_GuardianOffSpec_step2(hud, talents, spells, mangleSlot, thrashSlot)
    local mangleIcon = mangleSlot:AddOverlapingCooldown(spells.mangle)
    mangleIcon.showOnlyIf = hud.bearForm
    local thrashIcon = thrashSlot:AddOverlapingCooldown(spells.thrash)
    thrashIcon.showOnlyIf = hud.bearForm
end

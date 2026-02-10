---@param cFrame ERACombatMainFrame
---@param talents WarlockTalents
function ERACombatFrames_Warlock_Destruction(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 3)

    --------------------------------
    --#region TALENTS

    local talent_wither = ERALIBTalent:Create(117437)
    local talent_malevolence = ERALIBTalent:Create(117439)
    local talent_immo = ERALIBTalent:CreateNot(talent_wither)
    local talent_cata = ERALIBTalent:Create(91488)
    local talent_havoc = ERALIBTalent:Create(91493)
    local talent_mayhem = ERALIBTalent:Create(91494)
    local talent_shadowburn = ERALIBTalent:Create(91582)
    local talent_infernal = ERALIBTalent:Create(91502)
    local talent_soulfire = ERALIBTalent:Create(134221)
    local talent_demonfire = ERALIBTalent:Create(128599)
    local talent_sacrifice = ERALIBTalent:Create(125618)
    local talent_backdraft = ERALIBTalent:Create(91590)
    local talent_backlash = ERALIBTalent:Create(91500)
    local talent_crashing = ERALIBTalent:Create(91473)
    local talent_inferno = ERALIBTalent:Create(91583)
    local talent_instarof = ERALIBTalent:Create(91423)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local commonSpells = ERACombatFrames_WarlockCommonSpells(hud, talents)
    local conflag = hud:AddCooldown(17962)
    local demonfire = hud:AddCooldown(196447, talent_demonfire)
    local infernal = hud:AddCooldown(1122, talent_infernal)
    local malevolence = hud:AddCooldown(442726, talent_malevolence)
    local cata = hud:AddCooldown(152108, talent_cata)
    local soulfire = hud:AddCooldown(6353, talent_soulfire)
    local havoc = hud:AddCooldown(80240, talent_havoc)
    local shadowburn = hud:AddCooldown(17877, talent_shadowburn)

    local immo_wither = hud:AddAuraByPlayer(157736, true)
    --local inferno = hud:AddAuraByPlayer(?, false,talent_inferno)
    --local instarof = hud:AddAuraByPlayer(?, false,talent_instarof)
    local backdraft = hud:AddAuraByPlayer(117828, false, talent_backdraft)
    local backlash = hud:AddAuraByPlayer(387384, false, talent_backlash)
    local crashing = hud:AddAuraByPlayer(417282, false, talent_crashing)
    local sacriBuff = hud:AddAuraByPlayer(196099, false, talent_sacrifice)
    local havocBuff = hud:AddAuraByPlayer(80240, true, talent_havoc)
    local mayhem = hud:AddAuraByPlayer(394087, true, talent_mayhem)
    local infernalBuff = hud:AddAuraByPlayer(1122, false, talent_infernal)
    local malevolenceBuff = hud:AddAuraByPlayer(442726, false, talent_malevolence)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- essentials


    local _, malevoSlot = hud:AddEssentialsCooldown(malevolence, nil, nil, 0.7, 0.1, 0.8)
    malevoSlot:AddTimerBar(0.75, malevolenceBuff, nil, 1.0, 1.0, 1.0)

    local immoIcon, _, immoBar = hud:AddEssentialsAura(immo_wither, nil, nil, 0.8, 0.6, 0.0)
    immoIcon.showRedIfMissingInCombat = true
    immoBar.showPandemic = true

    hud:AddEssentialsCooldown(cata, nil, nil, 0.7, 0.1, 0.0)

    local _, conflagSlot = hud:AddEssentialsCooldown(conflag, nil, nil, 1.0, 0.0, 1.0)
    conflagSlot:AddTimerBar(0.75, infernalBuff, nil, 0.5, 1.0, 0.1)

    --hud:AddEssentialsAura(backdraft):ShowStacksRatherThanDuration()

    hud:AddEssentialsCooldown(soulfire, nil, nil, 0.0, 0.0, 1.0)

    hud:AddEssentialsCooldown(demonfire, nil, nil, 0.7, 1.0, 0.1)

    local _, havocSlot = hud:AddEssentialsCooldown(havoc, nil, nil, 0.8, 0.3, 0.7)
    havocSlot:AddTimerBar(0.25, havocBuff, nil, 1.0, 0.5, 0.9)

    local _, mayhemSlot = hud:AddEssentialsAura(mayhem, nil, nil, 1.0, 0.5, 0.9)

    hud:AddEssentialsRightCooldown(shadowburn).showOnlyWhenUsableOrOverlay = true

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.pact)

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.teleport)
    hud.movementGroup:AddCooldown(commonSpells.gateway)

    -- special
    hud.specialGroup:AddCooldown(commonSpells.instapet)
    --hud.specialGroup:AddCooldown(commonSpells.soulburn)

    -- control
    hud.controlGroup:AddCooldown(commonSpells.coil)
    hud.controlGroup:AddCooldown(commonSpells.shadowfury)
    hud.controlGroup:AddCooldown(commonSpells.howl)
    hud.controlGroup:AddCooldown(commonSpells.bweakness)
    hud.controlGroup:AddCooldown(commonSpells.btongues)

    -- powerboost
    hud.powerboostGroup:AddCooldown(infernal)

    -- buff
    hud.buffGroup:AddAura(crashing):ShowStacksRatherThanDuration()

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(backlash, nil, "dreamsurge_fire-portal-icon", true)

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    hud:AddResourceSlot(false):AddDestroShards()

    local petHealth = hud:AddPetHealth()
    local petBar = hud:AddResourceSlot(true):AddHealth(petHealth, true)
    function petBar:ShowIfNoUnit(t, combat)
        return (not talent_sacrifice:PlayerHasTalent()) or not sacriBuff.auraIsPresent
    end

    --#endregion
    --------------------------------
end

---@class (exact) HUDWarlockEmbers : HUDResourcePartialPoints
---@field private __index HUDWarlockEmbers
HUDWarlockEmbers = {}
HUDWarlockEmbers.__index = HUDWarlockEmbers
setmetatable(HUDWarlockEmbers, HUDResourcePartialPoints)

---@param hud HUDModule
---@param resourceFrame Frame
---@param frameLevel number
---@return HUDWarlockEmbers
function HUDWarlockEmbers:create(hud, resourceFrame, frameLevel)
    local x = {}
    setmetatable(x, HUDWarlockEmbers)
    ---@cast x HUDWarlockEmbers
    x:constructPoints(hud, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, nil, resourceFrame, frameLevel)
    return x
end

function HUDWarlockEmbers:getMaxPointsOnTalentCheck()
    return 5
end

---@param t number
---@return number
function HUDWarlockEmbers:getCurrentValue(t)
    local val = UnitPower("player", Enum.PowerType.SoulShards, true)
    if (val) then
        return val / 10
    else
        return 0
    end
end

---@param t number
---@param currentValue number
function HUDWarlockEmbers:getVisibilityAlphaOOC(t, currentValue)
    if (2.95 <= currentValue and currentValue <= 3.05) then
        return 0.0
    else
        return 1.0
    end
end

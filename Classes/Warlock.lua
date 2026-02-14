---@param cFrame ERACombatMainFrame
function ERACombatFrames_WarlockSetup(cFrame)
    ---@class WarlockTalents
    local talents = {
        instapet = ERALIBTalent:Create(91439),
        rush = ERALIBTalent:Create(91460),
        cexhaustion = ERALIBTalent:Create(136107),
        ctongues = ERALIBTalent:Create(136106),
        coil = ERALIBTalent:Create(91452),
        teleport = ERALIBTalent:Create(124694),
        pact = ERALIBTalent:Create(91444),
        gateway = ERALIBTalent:Create(91466),
        shadowfury = ERALIBTalent:Create(91457),
        howl = ERALIBTalent:Create(91458),
        soulburn = ERALIBTalent:Create(91469),
        bweakness = ERALIBTalent:Create(136108),
        btongues = ERALIBTalent:Create(136738),
        demonicHStone = ERALIBTalent:Create(91434),
    }

    ERACombatFrames_Warlock_Affliction(cFrame, talents)
    ERACombatFrames_Warlock_Demonology(cFrame, talents)
    ERACombatFrames_Warlock_Destruction(cFrame, talents)
end

---@class (exact) WarlockCommonSpells
---@field commandDemonIsKick HUDPublicBooleanSpellIcon
---@field commandDemonKick HUDCooldown
---@field resolve HUDCooldown
---@field instapet HUDCooldown
---@field pact HUDCooldown
---@field bweakness HUDCooldown
---@field btongues HUDCooldown
---@field teleport HUDCooldown
---@field teleportPlacement HUDCooldown
---@field coil HUDCooldown
---@field shadowfury HUDCooldown
---@field howl HUDCooldown
---@field gateway HUDCooldown
---@field soulburn HUDCooldown
---@field demonicHStone HUDBagItem

---@param hud HUDModule
---@param talents WarlockTalents
---@return WarlockCommonSpells
function ERACombatFrames_WarlockCommonSpells(hud, talents)
    hud:AddChannelInfo(234153, 5, 0.5)

    ---@type WarlockCommonSpells
    local commonSpells = {
        commandDemonIsKick = hud:AddIconBoolean(119898, 136174),
        commandDemonKick = hud:AddCooldown(132409),
        resolve = hud:AddCooldown(104773),
        instapet = hud:AddCooldown(333889, talents.instapet),
        pact = hud:AddCooldown(108416, talents.pact),
        bweakness = hud:AddCooldown(1271748, talents.bweakness),
        btongues = hud:AddCooldown(1271802, talents.btongues),
        teleport = hud:AddCooldown(48020, talents.teleport),
        teleportPlacement = hud:AddCooldown(48018, talents.teleport),
        coil = hud:AddCooldown(6789, talents.coil),
        shadowfury = hud:AddCooldown(30283, talents.shadowfury),
        howl = hud:AddCooldown(5484, talents.howl),
        gateway = hud:AddCooldown(111771, talents.gateway),
        soulburn = hud:AddCooldown(385899, talents.soulburn),
        demonicHStone = hud:AddBagItem(224464, talents.demonicHStone)
    }
    commonSpells.commandDemonKick.isSpecialIf = commonSpells.commandDemonIsKick
    hud:AddKickInfo(commonSpells.commandDemonKick)

    return commonSpells
end

---@class (exact) HUDWarlockDiabolist
---@field clovenSoul HUDAura
---@field infernalBolt HUDAura
---@field ruination HUDAura
---@field buildingDemon HUDAuraIcon
---@field summoningDemon HUDAuraIcon
---@field slot HUDEssentialsSlot

---@param hud HUDModule
---@param talent ERALIBTalent
---@return HUDWarlockDiabolist
function ERACombatFrames_WarlockDiabolist(hud, talent)
    local cloven = hud:AddAuraByPlayer(434424, true, talent)
    local building = hud:AddAuraByPlayer(432816, false, talent)
    local summoning = hud:AddAuraByPlayer(432795, false, talent)

    local buildingIcon, slot = hud:AddEssentialsAura(building)
    local summoningIcon = slot:AddOverlapingAura(summoning)
    buildingIcon.watchIconChange = true
    summoningIcon.watchIconChange = true

    local infernalBolt = hud:AddAuraByPlayer(433891, false, talent)
    local ruination = hud:AddAuraByPlayer(433885, false, talent)

    slot:AddTimerBar(0.5, cloven, nil, 0.6, 0.0, 0.6).doNotCutLongDuration = true

    hud:AddAuraOverlayAlert(infernalBolt, nil, "Interface/Addons/ERACombatFrames/textures/alerts/OLDEclipse_Sun.tga", false, "NONE", "CENTER")
    hud:AddAuraOverlayAlert(ruination, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Fury_of_Stormrage.tga", false, "NONE", "TOP")

    ---@type HUDWarlockDiabolist
    return {
        clovenSoul = cloven,
        infernalBolt = infernalBolt,
        ruination = ruination,
        buildingDemon = buildingIcon,
        summoningDemon = summoningIcon,
        slot = slot
    }
end

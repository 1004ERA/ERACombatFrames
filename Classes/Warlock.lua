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
    }

    ERACombatFrames_Warlock_Affliction(cFrame, talents)
    ERACombatFrames_Warlock_Demonology(cFrame, talents)
    ERACombatFrames_Warlock_Destruction(cFrame, talents)
end

---@class (exact) WarlockCommonSpells
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

---@param hud HUDModule
---@param talents WarlockTalents
---@return WarlockCommonSpells
function ERACombatFrames_WarlockCommonSpells(hud, talents)
    hud:AddChannelInfo(234153, 5, 0.5)

    return {
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
    }
end

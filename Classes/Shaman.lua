---@param cFrame ERACombatMainFrame
function ERACombatFrames_ShamanSetup(cFrame)
    local talent_grab = ERALIBTalent:Create(127902)
    local talent_bind = ERALIBTalent:CreateNot(talent_grab)
    ---@class ShamanTalents
    local talents = {
        walk = ERALIBTalent:Create(127865),
        gust = ERALIBTalent:Create(127864),
        ashift = ERALIBTalent:Create(127893),
        long_frshock = ERALIBTalent:Create(135719),
        kick = ERALIBTalent:Create(127892),
        heal_totem = ERALIBTalent:Create(127863),
        grab_totem = talent_grab,
        bind_totem = talent_bind,
        capa_totem = ERALIBTalent:Create(127851),
        wind_totem = ERALIBTalent:Create(127909),
        tank_totem = ERALIBTalent:Create(127858),
        dispell_def = ERALIBTalent:Create(127884),
        dispell_off = ERALIBTalent:Create(127904),
        hex = ERALIBTalent:Create(127903),
        spiritwalk = ERALIBTalent:Create(127857),
        tremor = ERALIBTalent:Create(127874),
        poison_cleansing = ERALIBTalent:Create(136567),
        swift = ERALIBTalent:Create(127899),
        relocation = ERALIBTalent:Create(135590),
    }
    ERACombatFrames_Shaman_Elemental(cFrame, talents)
    ERACombatFrames_Shaman_Enhancement(cFrame, talents)
    ERACombatFrames_Shaman_Restoration(cFrame, talents)
end

---@param hud HUDModule
---@param talents ShamanTalents
---@param isHealer boolean
---@param talent_ancestral_swiftness ERALIBTalent|nil
---@return ShamanCommonSpells
function ERACombatFrames_ShamanCommonSpells(hud, talents, isHealer, talent_ancestral_swiftness)
    local talent_swift
    if (talent_ancestral_swiftness) then
        talent_swift = ERALIBTalent:CreateAnd(talents.swift, ERALIBTalent:CreateNot(talent_ancestral_swiftness))
    else
        talent_swift = talents.swift
    end
    ---@class ShamanCommonSpells
    local spells = {
        walk = hud:AddCooldown(58875, talents.walk),
        gust = hud:AddCooldown(192063, talents.gust),
        ashift = hud:AddCooldown(108271, talents.ashift),
        frshock = hud:AddCooldown(196840, talents.long_frshock),
        kick = hud:AddCooldown(57994, talents.kick),
        heal_totem = hud:AddCooldown(5394, talents.heal_totem),
        bind_totem = hud:AddCooldown(2484, talents.bind_totem),
        grab_totem = hud:AddCooldown(51485, talents.grab_totem),
        capa_totem = hud:AddCooldown(192058, talents.capa_totem),
        wind_totem = hud:AddCooldown(192077, talents.wind_totem),
        tank_totem = hud:AddCooldown(198103, talents.tank_totem),
        dispell_def = hud:AddCooldown(51886, talents.dispell_def),
        dispell_off = hud:AddCooldown(378773, talents.dispell_off),
        hex = hud:AddCooldown(51514, talents.hex),
        spiritwalk = hud:AddCooldown(79206, talents.spiritwalk),
        tremor = hud:AddCooldown(8143, talents.tremor),
        poison_cleansing = hud:AddCooldown(383013, talents.poison_cleansing),
        swift = hud:AddCooldown(378081, talent_swift),
        relocation = hud:AddCooldown(108287, talents.relocation),
    }

    hud.movementGroup:AddCooldown(spells.swift)
    hud.movementGroup:AddCooldown(spells.spiritwalk)
    hud.movementGroup:AddCooldown(spells.walk)
    hud.movementGroup:AddCooldown(spells.gust)
    hud.movementGroup:AddCooldown(spells.wind_totem)

    hud.defensiveGroup:AddCooldown(spells.ashift)
    if (not isHealer) then
        hud.defensiveGroup:AddCooldown(spells.heal_totem)
    end

    hud.controlGroup:AddCooldown(spells.kick)
    hud:AddKickInfo(spells.kick)
    hud.controlGroup:AddCooldown(spells.frshock)
    hud.controlGroup:AddCooldown(spells.hex)
    hud.controlGroup:AddCooldown(spells.dispell_off)
    hud.controlGroup:AddCooldown(spells.grab_totem)
    hud.controlGroup:AddCooldown(spells.bind_totem)
    hud.controlGroup:AddCooldown(spells.capa_totem)

    if (not isHealer) then
        hud.specialGroup:AddCooldown(spells.dispell_def)
    end
    hud.specialGroup:AddCooldown(spells.tank_totem)
    hud.specialGroup:AddCooldown(spells.tremor)
    hud.specialGroup:AddCooldown(spells.poison_cleansing)

    local missingSkyfury = hud:AddSpellOverlayBoolean(462854)
    hud.alertGroup:AddBooleanAlert(missingSkyfury, 4630367)

    return spells
end

---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Discipline(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_oracle = ERALIBTalent:Create()
    local talent_voidweaver = ERALIBTalent:Create(117287)
    local talent_painsup = ERALIBTalent:Create()
    local talent_pwRadiance = ERALIBTalent:Create()
    local talent_ulti = ERALIBTalent:Create()
    local talent_barrier = ERALIBTalent:Create()
    local talent_harsh = ERALIBTalent:Create()
    local talent_evangelism = ERALIBTalent:Create()
    local talent_shadowmend = ERALIBTalent:Create()

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local pws = hud:AddCooldown(17)
    local penance = hud:AddCooldown(x)
    local pwRadiance = hud:AddCooldown(x, talent_pwRadiance)
    local torrent = hud:AddCooldown(263165, talent_voidweaver)
    local painsup = hud:AddCooldown(x, talent_painsup)
    local ulti = hud:AddCooldown(x, talent_ulti)
    local barrier = hud:AddCooldown(x, talent_barrier)
    local evangelism = hud:AddCooldown(x, talent_evangelism)

    local swp = hud:AddAuraByPlayer(589, true)
    local rift = hud:AddAuraByPlayer(450193, false, talent_voidweaver)
    local darkside = hud:AddAuraByPlayer(x, false)
    local harsh = hud:AddAuraByPlayer(x, false, talent_harsh)
    local shadowmend = hud:AddAuraByPlayer(x, false, talent_shadowmend)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DISPLAY

    -- defensive
    hud.defensiveGroup:AddCooldown(painsup)
    hud.defensiveGroup:AddCooldown(barrier)

    -- movement

    -- control

    -- buffs

    -- powerboost
    hud.powerboostGroup:AddCooldown(penance)
    hud.powerboostGroup:AddCooldown(evangelism)
    hud.powerboostGroup:AddCooldown(ulti)

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, false)

    -- assist
    hud.assistGroup:AddCooldown(pws)
    hud.assistGroup:AddCooldown(pwRadiance)

    -- essentials

    hud:AddEssentialsLeftAura(harsh):ShowStacksRatherThanDuration()

    hud:AddDOT(swp, nil, nil, 1.0, 0.8, 0.0)

    hud:AddEssentialsCooldown(penance, nil, nil, 1.0, 1.0, 0.6)

    hud:AddEssentialsCooldown(commonSpells.mBlast, nil, nil, 1.0, 0.0, 0.0)

    ERACombatFrames_PriestSWDeath(hud, nil, commonSpells)

    local _, torrentSlot = hud:AddEssentialsCooldown(torrent, nil, nil, 0.8, 0.7, 0.7)
    torrentSlot:AddTimerBar(0.25, rift, nil, 0.2, 0.0, 0.5).doNotCutLongDuration = true

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end

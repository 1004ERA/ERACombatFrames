---@param cFrame ERACombatMainFrame
---@param talents PriestTalents
function ERACombatFrames_Priest_Discipline(cFrame, talents)
    local hud = HUDModule:Create(cFrame, 1.5, 1)

    --------------------------------
    --#region TALENTS

    local talent_oracle = ERALIBTalent:Create(117286)
    local talent_voidweaver = ERALIBTalent:Create(136498)
    local talent_painsup = ERALIBTalent:Create(103713)
    local talent_pwRadiance = ERALIBTalent:Create(103722)
    local talent_ulti = ERALIBTalent:Create(116182)
    local talent_pwBarrier = ERALIBTalent:Create(103687)
    local talent_harsh = ERALIBTalent:Create(103729)
    local talent_evangelism = ERALIBTalent:Create(103702)
    local talent_shadowmend = ERALIBTalent:Create(103692)
    local talent_wealwoe = ERALIBTalent:Create(103698)

    --#endregion
    --------------------------------

    --------------------------------
    --#region DATA

    local mana = hud:AddPowerHighIdle(Enum.PowerType.Mana)

    local pws = hud:AddCooldown(17)
    local penance = hud:AddCooldown(47540)
    local pwRadiance = hud:AddCooldown(194509, talent_pwRadiance)
    local painsup = hud:AddCooldown(33206, talent_painsup)
    local ulti = hud:AddCooldown(421453, talent_ulti)
    local barrier = hud:AddCooldown(62618, talent_pwBarrier)
    local evangelism = hud:AddCooldown(472433, talent_evangelism)
    local dispell = hud:AddCooldown(527)

    local swp = hud:AddAuraByPlayer(589, true)
    local rift = hud:AddAuraByPlayer(450193, false, talent_voidweaver)
    --local darkside = hud:AddAuraByPlayer(198068, false)
    local harsh = hud:AddAuraByPlayer(373180, false, talent_harsh)
    local shadowmend = hud:AddAuraByPlayer(186440, false, talent_shadowmend)
    --local wealwoe = hud:AddAuraByPlayer(390786, false, talent_wealwoe)

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
    hud.powerboostGroup:AddCooldown(evangelism)
    hud.powerboostGroup:AddCooldown(ulti)

    local commonSpells = ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, false)

    -- assist
    hud.assistGroup:AddCooldown(pws)
    hud.assistGroup:AddCooldown(penance)
    hud.assistGroup:AddCooldown(pwRadiance)
    hud.assistGroup:AddCooldown(dispell)
    hud.assistGroup:AddCooldown(commonSpells.nova)

    -- essentials

    hud:AddEssentialsLeftAura(harsh):ShowStacksRatherThanDuration()

    hud:AddDOT(swp, nil, nil, 1.0, 0.8, 0.0)

    hud:AddEssentialsCooldown(penance, nil, nil, 1.0, 1.0, 0.6)

    local _, blastSlot = hud:AddEssentialsCooldown(commonSpells.mBlast, nil, nil, 1.0, 0.0, 0.0)
    blastSlot:AddTimerBar(0.25, rift, nil, 0.2, 0.0, 0.5).doNotCutLongDuration = true

    ERACombatFrames_PriestSWDeath(hud, nil, commonSpells)

    --#endregion
    --------------------------------

    --------------------------------
    --#region ALERTS

    hud:AddAuraOverlayAlert(shadowmend, nil, "Interface/Addons/ERACombatFrames/textures/alerts/Nightfall.tga", false, "ROTATE_RIGHT", "TOP").playSoundWhenApperars = SOUNDKIT.ALARM_CLOCK_WARNING_2

    --#endregion
    --------------------------------

    --------------------------------
    --#region RESOURCE

    local manaBar = hud:AddResourceSlot(false):AddPowerPercent(mana, hud.options.manaR, hud.options.manaG, hud.options.manaB)

    --#endregion
    --------------------------------
end

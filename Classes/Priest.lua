---@param cFrame ERACombatMainFrame
function ERACombatFrames_PriestSetup(cFrame)
    ---@class PriestTalents
    local talents = {
        novaCD = ERALIBTalent:Create(103871),
        leap = ERALIBTalent:Create(103867),
        infu = ERALIBTalent:Create(103834),
        mBlast = ERALIBTalent:Create(103865),
        scream = ERALIBTalent:Create(103851),
        feather = ERALIBTalent:Create(103853),
        mass = ERALIBTalent:Create(136157),
        dominate = ERALIBTalent:Create(103678),
        swDeath = ERALIBTalent:Create(103864),
        fade = ERALIBTalent:Create(134849),
        desperate = ERALIBTalent:Create(134846),
        twist = ERALIBTalent:Create(103833),
    }
    ERACombatFrames_Priest_Shadow(cFrame, talents)
end

---@param cFrame ERACombatMainFrame
---@param hud HUDModule
---@param talents PriestTalents
---@param isShadow boolean
---@return PriestCommonSpells
function ERACombatFrames_PriestCommonSpells(cFrame, hud, talents, isShadow)
    ---@class PriestCommonSpells
    local commonSpells = {
        nova = hud:AddCooldown(132157, talents.novaCD),
        leap = hud:AddCooldown(73325, talents.leap),
        infu = hud:AddCooldown(10060, talents.infu),
        mBlast = hud:AddCooldown(8092, talents.mBlast),
        scream = hud:AddCooldown(8122, talents.scream),
        feather = hud:AddCooldown(121536, talents.feather),
        mass = hud:AddCooldown(32375, talents.mass),
        dominate = hud:AddCooldown(205364, talents.dominate),
        swDeath = hud:AddCooldown(32379, talents.swDeath),
        fade = hud:AddCooldown(586, talents.fade),
        desperate = hud:AddCooldown(19236, talents.desperate),
        twist = hud:AddAuraByPlayer(390972, true, talents.twist),
    }

    -- defensive
    hud.defensiveGroup:AddCooldown(commonSpells.fade)
    hud.defensiveGroup:AddCooldown(commonSpells.desperate)

    -- movement
    hud.movementGroup:AddCooldown(commonSpells.feather)
    hud.movementGroup:AddCooldown(commonSpells.leap)

    -- special
    hud.specialGroup:AddCooldown(commonSpells.mass)

    -- control
    hud.controlGroup:AddCooldown(commonSpells.scream)
    hud.controlGroup:AddCooldown(commonSpells.dominate)

    -- powerboost
    hud.powerboostGroup:AddCooldown(commonSpells.infu)

    return commonSpells
end

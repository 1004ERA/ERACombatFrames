---@param cFrame ERACombatFrame
---@param talents WarlockCommonTalents
function ERACombatFrames_WarlockDemonologySetup(cFrame, talents)
    local talent_dogs = ERALIBTalent:Create(125837)
    local talent_soulstrike = ERALIBTalent:Create(125844)
    local talent_soulstrike_shard = ERALIBTalent:Create(125842)
    local talent_bombers = ERALIBTalent:Create(125833)
    local talent_felstorm = ERALIBTalent:Create(125832)
    local talent_siphon = ERALIBTalent:Create(125862)
    local talent_tyrant = ERALIBTalent:Create(125850)
    local talent_felguard = ERALIBTalent:Create(125852)
    local talent_shatug = ERALIBTalent:Create(125839)
    local talent_fharg = ERALIBTalent:Create(125838)
    local talent_vilefiend = ERALIBTalent:CreateAnd(ERALIBTalent:Create(125845), ERALIBTalent:CreateNOR(talent_shatug, talent_fharg))
    local talent_guillotine = ERALIBTalent:Create(125840)
    local talent_doom = ERALIBTalent:Create(125865)

    local hud = ERACombatFrames_WarlockCommonSetup(cFrame, 2, false, talents, ERALIBTalentTrue, ERALIBTalentFalse)
    ---@cast hud WarlockWholeHUD
    hud.shards = ERAHUDWarlockWholeShards:create(hud)

    local dogs = hud:AddTrackedCooldown(104316, talent_dogs)
    local soulstrike = hud:AddTrackedCooldown(264057, talent_soulstrike)
    soulstrike.isPetSpell = true

    function hud.shards:PreUpdateDisplayOverride(t, combat)
        if talent_soulstrike_shard:PlayerHasTalent() and soulstrike.remDuration < hud.occupied + hud.totGCD then
            self:SetPointColor(0.0, 1.0, 0.0)
        else
            self:SetPointColor(1.0, 0.0, 1.0)
        end
    end

    local enemies = ERACombatEnemies:Create(cFrame, 2)

    local imps = ERAHUD_WarlockImps:create(hud, ERALIBTalent:Create(125854))

    --- SAO ---

    local instabolt = hud:AddTrackedBuff(264173)
    hud:AddAuraOverlay(instabolt, 1, 2888300, false, "LEFT", false, false, false, false)
    hud:AddAuraOverlay(instabolt, 2, 2888300, false, "RIGHT", true, false, false, false)

    local instadogs = hud:AddTrackedBuff(205146)
    local instadogsOverlay = hud:AddAuraOverlay(instadogs, 1, 510822, false, "TOP", false, false, false, false)
    function instadogsOverlay:ConfirmIsActiveOverride(t)
        return dogs.remDuration <= 0 or dogs.remDuration < 5
    end

    --- bars ---

    local instaboltBar = hud:AddAuraBar(instabolt, nil, 1.0, 0.8, 1.0)
    function instaboltBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration or self.aura.stacks > 2 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(146739), nil, 1.0, 0.3, 0.3)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(460553, talent_doom), nil, 0.0, 0.6, 0.0)

    --- rotation ---

    local dogsIcon = hud:AddRotationCooldown(dogs)

    --local soulstrikeIcon = hud:AddRotationCooldown(soulstrike)

    local vilefiendIcons = {}
    table.insert(vilefiendIcons, hud:AddRotationCooldown(hud:AddTrackedCooldown(264119, talent_vilefiend)))
    table.insert(vilefiendIcons, hud:AddRotationCooldown(hud:AddTrackedCooldown(455465, talent_shatug)))
    table.insert(vilefiendIcons, hud:AddRotationCooldown(hud:AddTrackedCooldown(455476, talent_fharg)))

    local bombers = hud:AddRotationCooldown(hud:AddTrackedCooldown(267211, talent_bombers))
    local felstorm = hud:AddRotationCooldown(hud:AddTrackedCooldown(267171, talent_felstorm))

    local guillotine = hud:AddRotationCooldown(hud:AddTrackedCooldown(386833, talent_guillotine))

    local siphon = hud:AddRotationCooldown(hud:AddTrackedCooldown(264130, talent_siphon))

    --[[

    prio

    1 - soul strike
    2 - dogs
    3 - vilefiend
    4 - felstorm
    5 - guillotine
    6 - bombers
    7 - siphon

    function soulstrikeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    ]]

    local soulstrikeTimer = hud:AddPriority(1452864, talent_soulstrike)
    function soulstrikeTimer:ComputeDurationOverride(t)
        if soulstrike.remDuration < 2 * self.hud.totGCD then
            return soulstrike.remDuration
        else
            return -1
        end
    end
    function soulstrikeTimer:ComputeAvailablePriorityOverride(t)
        return 1
    end

    function dogsIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    for _, i in ipairs(vilefiendIcons) do
        function i.onTimer:ComputeAvailablePriorityOverride(t)
            return 3
        end
    end

    function felstorm.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function guillotine.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function bombers.onTimer:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() > 1 then
            return 6
        else
            return 0
        end
    end

    --- utility ---

    local felguardStun = hud:AddTrackedCooldown(89766)
    felguardStun.isPetSpell = true
    --hud:AddUtilityCooldown(felguardStun, hud.controlGroup, nil, -1)
    hud:AddKick(felguardStun)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(265187, talent_tyrant), hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(111898, talent_felguard), hud.powerUpGroup)
end

---@class (exact) ERAHUD_WarlockImps : ERAHUD_PseudoResourceBar
---@field private __index unknown
---@field talentManyImps ERALIBTalent
---@field stacks ERASpellStacks
ERAHUD_WarlockImps = {}
ERAHUD_WarlockImps.__index = ERAHUD_WarlockImps
setmetatable(ERAHUD_WarlockImps, { __index = ERAHUD_PseudoResourceBar })

---@param hud WarlockHUD
---@param talentManyImps ERALIBTalent
---@return ERAHUD_WarlockImps
function ERAHUD_WarlockImps:create(hud, talentManyImps)
    local wi = {}
    setmetatable(wi, ERAHUD_WarlockImps)
    ---@cast wi ERAHUD_WarlockImps
    wi:constructPseudoResource(hud, 12, 2, 1.0, 1.0, 0.0, false)
    wi.talentManyImps = talentManyImps
    wi.stacks = hud:AddSpellStacks(196277)
    wi.showOutOfCombat = false
    return wi
end

function ERAHUD_WarlockImps:getValue(t, combat)
    return self.stacks.stacks
end

function ERAHUD_WarlockImps:getMax(t, combat)
    if self.talentManyImps:PlayerHasTalent() then
        return 15
    else
        return 10
    end
end

function ERAHUD_WarlockImps:DisplayUpdatedOverride(t, combat)
    self:SetText(tostring(self.stacks.stacks))
end

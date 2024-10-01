---@class WDemonoHUD : WarlockWholeHUD
---@field dogsEnd number
---@field fiendEnd number

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
    local talent_any_vilefiend = ERALIBTalent:Create(125845)
    local talent_shatug = ERALIBTalent:Create(125839)
    local talent_fharg = ERALIBTalent:Create(125838)
    local talent_vilefiend = ERALIBTalent:CreateAnd(talent_any_vilefiend, ERALIBTalent:CreateNOR(talent_shatug, talent_fharg))
    local talent_guillotine = ERALIBTalent:Create(125840)
    local talent_doom = ERALIBTalent:Create(125865)

    local hud, succulent = ERACombatFrames_WarlockWholeShards(cFrame, 2, ERALIBTalentTrue, ERALIBTalentFalse, talents)
    ---@cast hud WDemonoHUD
    hud.dogsEnd = 0
    hud.fiendEnd = 0

    local superbolt, ruination = ERACombatFrames_WarlockDiabolist(hud, talents)

    local dogs = hud:AddTrackedCooldown(104316, talent_dogs)
    local soulstrike = hud:AddTrackedCooldown(264057, talent_soulstrike)
    soulstrike.isPetSpell = true

    function hud.shards:PreUpdateDisplayOverride(t, combat)
        if superbolt.remDuration > 0 then
            self:SetPointColor(1.0, 1.0, 1.0)
        elseif talent_soulstrike_shard:PlayerHasTalent() and soulstrike.remDuration < hud.occupied + hud.totGCD then
            self:SetPointColor(0.0, 1.0, 0.0)
        else
            self:SetPointColor(1.0, 0.0, 1.0)
        end
        if ruination.remDuration > 0 or succulent.remDuration > 0 then
            self:SetBorderColor(1.0, 1.0, 1.0)
        else
            self:SetBorderColor(1.0, 0.0, 0.0)
        end
    end

    local enemies = ERACombatEnemies:Create(cFrame, 2)

    local imps = ERAHUD_WarlockImps:create(hud, ERALIBTalent:Create(125854))

    local tyrantCooldown = hud:AddTrackedCooldown(265187, talent_tyrant)

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

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUID == self.cFrame.playerGUID and evt == "SPELL_CAST_SUCCESS") then
            if spellID == 104316 then
                self.dogsEnd = t + 12
            elseif spellID == 264119 or spellID == 455465 or spellID == 455476 then
                self.fiendEnd = t + 15
            elseif spellID == 265187 then
                if t < self.dogsEnd then
                    self.dogsEnd = self.dogsEnd + 15
                end
                if t < self.fiendEnd then
                    self.fiendEnd = self.fiendEnd + 15
                end
            end
        end
    end

    local summonBars = {}
    local dogsTimer = ERAHUD_Warlock_DogsTimer:create(hud, talent_dogs)
    table.insert(summonBars, hud:AddGenericBar(dogsTimer, 1378282, 0.7, 0.2, 0.1))
    local fiendTimer = ERAHUD_Warlock_FiendTimer:create(hud, talent_any_vilefiend)
    table.insert(summonBars, hud:AddGenericBar(fiendTimer, 1616211, 0.5, 0.7, 0.1))
    for _, sb in ipairs(summonBars) do
        function sb:ConfirmDurationOverride(t, dur)
            if self.hud.castingSpellID == tyrantCooldown.spellID or dur + self.hud.remGCD > tyrantCooldown.remDuration + 2 then
                return dur
            else
                return 0
            end
        end
    end

    local instaboltBar = hud:AddAuraBar(instabolt, nil, 1.0, 0.8, 1.0)
    function instaboltBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.hud.timerDuration or self.aura.stacks > 2 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(146739), nil, 1.0, 0.3, 0.3) -- corruption

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
    4 - tyrant (both summons active)
    5 - felstorm (demonic strength)
    6 - guillotine
    7 - bombers
    8 - siphon
    9 - felstorm

    function soulstrikeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
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

    local felstormTimer = hud:AddPriority(236303)
    local petFelstorm = hud:AddTrackedCooldown(89751)
    petFelstorm.isPetSpell = true
    function felstormTimer:ComputeDurationOverride(t)
        if petFelstorm.isKnown then
            return petFelstorm.remDuration
        else
            return -1
        end
    end
    function felstormTimer:ComputeAvailablePriorityOverride(t)
        return 9
    end

    function dogsIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    for _, i in ipairs(vilefiendIcons) do
        function i.onTimer:ComputeAvailablePriorityOverride(t)
            return 3
        end
    end

    local tyrantTimer = hud:AddPriority(2065628, talent_tyrant)
    function tyrantTimer:ComputeDurationOverride(t)
        if dogsTimer.remDuration > tyrantCooldown.remDuration + 2 and ((not talent_any_vilefiend:PlayerHasTalent()) or fiendTimer.remDuration > tyrantCooldown.remDuration + 2) then
            return tyrantCooldown.remDuration
        else
            return -1
        end
    end
    function tyrantTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function felstorm.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function guillotine.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function bombers.onTimer:ComputeAvailablePriorityOverride(t)
        if enemies:GetCount() > 1 then
            return 7
        else
            return 0
        end
    end

    function siphon.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    --- utility ---

    local felguardStun = hud:AddTrackedCooldown(89766)
    felguardStun.isPetSpell = true
    --hud:AddUtilityCooldown(felguardStun, hud.controlGroup, nil, -1)
    hud:AddKick(felguardStun)

    hud:AddUtilityCooldown(tyrantCooldown, hud.powerUpGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(111898, talent_felguard), hud.powerUpGroup)
end

-------------------
--#region HAVOC ---

---@class ERAHUD_Warlock_SummonedTimer : ERATimer
---@field private __index unknown
---@field protected wdhud WDemonoHUD
---@field private talent_summon ERALIBTalent
---@field protected constructSummonTimer fun(this:ERAHUD_Warlock_SummonedTimer, hud:WDemonoHUD, talent_summon:ERALIBTalent)
ERAHUD_Warlock_SummonedTimer = {}
ERAHUD_Warlock_SummonedTimer.__index = ERAHUD_Warlock_SummonedTimer
setmetatable(ERAHUD_Warlock_SummonedTimer, { __index = ERATimer })

---@param hud WDemonoHUD
---@param talent_summon ERALIBTalent
function ERAHUD_Warlock_SummonedTimer:constructSummonTimer(hud, talent_summon)
    self.wdhud = hud
    self.talent_summon = talent_summon
    self:constructTimer(hud)
    self.totDuration = 15
    self.remDuration = 0
end

function ERAHUD_Warlock_SummonedTimer:checkDataItemTalent()
    return self.talent_summon:PlayerHasTalent()
end

---@class ERAHUD_Warlock_DogsTimer : ERAHUD_Warlock_SummonedTimer
---@field private __index unknown
ERAHUD_Warlock_DogsTimer = {}
ERAHUD_Warlock_DogsTimer.__index = ERAHUD_Warlock_DogsTimer
setmetatable(ERAHUD_Warlock_DogsTimer, { __index = ERAHUD_Warlock_SummonedTimer })

---@param hud WDemonoHUD
---@param talent_summon ERALIBTalent
---@return ERAHUD_Warlock_DogsTimer
function ERAHUD_Warlock_DogsTimer:create(hud, talent_summon)
    local x = {}
    setmetatable(x, ERAHUD_Warlock_DogsTimer)
    ---@cast x ERAHUD_Warlock_DogsTimer
    x:constructSummonTimer(hud, talent_summon)
    return x
end

---@param t number
function ERAHUD_Warlock_DogsTimer:updateData(t)
    if self.wdhud.dogsEnd > t then
        self.remDuration = self.wdhud.dogsEnd - t
    else
        self.remDuration = 0
    end
end

---@class ERAHUD_Warlock_FiendTimer : ERAHUD_Warlock_SummonedTimer
---@field private __index unknown
ERAHUD_Warlock_FiendTimer = {}
ERAHUD_Warlock_FiendTimer.__index = ERAHUD_Warlock_FiendTimer
setmetatable(ERAHUD_Warlock_FiendTimer, { __index = ERAHUD_Warlock_SummonedTimer })

---@param hud WDemonoHUD
---@param talent_summon ERALIBTalent
---@return ERAHUD_Warlock_FiendTimer
function ERAHUD_Warlock_FiendTimer:create(hud, talent_summon)
    local x = {}
    setmetatable(x, ERAHUD_Warlock_FiendTimer)
    ---@cast x ERAHUD_Warlock_FiendTimer
    x:constructSummonTimer(hud, talent_summon)
    return x
end

---@param t number
function ERAHUD_Warlock_FiendTimer:updateData(t)
    if self.wdhud.fiendEnd > t then
        self.remDuration = self.wdhud.fiendEnd - t
    else
        self.remDuration = 0
    end
end

--#endregion
-------------------

------------------
--#region IMPS ---

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

--#endregion
------------------

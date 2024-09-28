---@class WDestructionHUD : WarlockHUD
---@field lastHavoc number

---@param cFrame ERACombatFrame
---@param talents WarlockCommonTalents
function ERACombatFrames_WarlockDestructionSetup(cFrame, talents)
    local talent_sacrifice = ERALIBTalent:Create(125618)
    local talent_not_sacrifice = ERALIBTalent:CreateNotTalent(125618)
    local talent_backlash = ERALIBTalent:Create(91500)
    local talent_blaze = ERALIBTalent:Create(91588)
    local talent_havoc = ERALIBTalent:Create(91493)
    local talent_mayhem = ERALIBTalent:Create(91494)
    local talent_cata = ERALIBTalent:Create(91487)
    local talent_shadowburn = ERALIBTalent:Create(91582)
    local talent_shadowburn_conflag = ERALIBTalent:Create(91538)
    local talent_demonfire = ERALIBTalent:Create(91586)
    local talent_infernal = ERALIBTalent:Create(91502)
    local talent_eradication = ERALIBTalent:Create(91501)
    local talent_ritualist = ERALIBTalent:Create(91475)
    local talent_ritualruin = ERALIBTalent:CreateAnd(ERALIBTalent:Create(91483), ERALIBTalent:CreateNot(talent_ritualist))
    local talent_soulfire = ERALIBTalent:Create(91492)
    local talent_soulfireproc = ERALIBTalent:Create(126007)
    local talent_rift = ERALIBTalent:Create(91423)

    local hud = ERACombatFrames_WarlockCommonSetup(cFrame, 3, true, talents, talent_not_sacrifice, talent_sacrifice)
    ---@cast hud WDestructionHUD
    hud.lastHavoc = 0

    local dots = ERAHUDDOT:Create(hud)
    local immo = dots:AddDOT(157736, nil, 1.0, 1.0, 0.0, nil, 1.5, 21)

    local conflagCooldown = hud:AddTrackedCooldown(17962)
    local shadowBurnCooldown = hud:AddTrackedCooldown(17877, talent_shadowburn)
    local conflag_ShadowConflag = hud:AddTrackedBuff(387109, talent_shadowburn_conflag)
    local burn_ShadowConflag = hud:AddTrackedBuff(387110, talent_shadowburn_conflag)

    --- SAO ---

    local backdraft = hud:AddTrackedBuff(117828)
    hud:AddAuraOverlay(backdraft, 1, 449491, false, "LEFT", false, false, false, false)
    hud:AddAuraOverlay(backdraft, 2, 449491, false, "RIGHT", true, false, false, false)

    hud:AddAuraOverlay(hud:AddTrackedBuff(387385, talent_backlash), 1, 460830, false, "BOTTOM", false, true, false, false)

    hud:AddAuraOverlay(conflag_ShadowConflag, 1, 457658, false, "TOP", false, false, false, false)
    hud:AddAuraOverlay(burn_ShadowConflag, 1, 627609, false, "TOP", false, false, false, false)

    --- bars ---

    local backdraftBar = hud:AddAuraBar(backdraft, nil, 0.0, 1.0, 0.0)
    function backdraftBar:ComputeDurationOverride(t)
        if self.aura.remDuration < self.aura.stacks * 2.5 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local blaze = hud:AddTrackedDebuffOnTarget(265931, talent_blaze)
    hud:AddAuraBar(blaze, nil, 1.0, 0.8, 0.0)

    function hud:AdditionalCLEU(t)
        local _, evt, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUID == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED" and spellID == 80240) then
            self.lastHavoc = t
        end
    end

    local havocDuration = ERAHUD_Warlock_DestructionHavocDuration:create(hud, talent_havoc, talent_mayhem)
    hud:AddGenericBar(havocDuration, 460695, 0.7, 0.2, 0.1)

    local shadowconflagBars = {}
    table.insert(shadowconflagBars, hud:AddAuraBar(conflag_ShadowConflag, nil, 0.2, 0.5, 1.0))
    table.insert(shadowconflagBars, hud:AddAuraBar(burn_ShadowConflag, nil, 0.2, 0.5, 1.0))
    for _, b in ipairs(shadowconflagBars) do
        function b:ComputeDurationOverride(t)
            if self.aura.remDuration < 5 then
                return self.aura.remDuration
            else
                return 0
            end
        end
    end

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(196414, talent_eradication), nil, 1.0, 0.0, 1.1)

    local decimation = hud:AddTrackedBuff(457555, talent_soulfireproc)

    --- rotation ---

    local shadowburn = hud:AddRotationCooldown(shadowBurnCooldown)

    local conflag = hud:AddRotationCooldown(conflagCooldown)

    local havoc = hud:AddRotationCooldown(hud:AddTrackedCooldown(80240, talent_havoc))

    local demonfire = hud:AddRotationCooldown(hud:AddTrackedCooldown(196447, talent_demonfire))

    local cata = hud:AddRotationCooldown(hud:AddTrackedCooldown(152108, talent_cata))

    local rift = hud:AddRotationCooldown(hud:AddTrackedCooldown(387976, talent_rift))

    local soulfire = hud:AddRotationCooldown(hud:AddTrackedCooldown(6353, talent_soulfire))

    --[[

    prio

    1 - havoc
    2 - conflag full charges
    3 - shadowburn
    4 - soulfire proc
    5 - conflag
    6 - demonfire
    7 - cata
    8 - soulfire with backdraft or blaze
    9 - rift
    10 - shadowburn full charges
    11 - soulfire raw

    ]]

    function havoc.onTimer:ComputeAvailablePriorityOverride(t)
        if dots.enemiesCount > 1 then
            return 1
        else
            return 0
        end
    end

    function conflag.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function shadowburn.onTimer:ComputeAvailablePriorityOverride(t)
        if hud.shards.currentPoints >= 1 then
            if burn_ShadowConflag.remDuration > self.hud.occupied then
                return 3
            else
                if UnitExists("target") then
                    if UnitHealth("target") / UnitHealthMax("target") <= 0.3 then
                        return 3
                    else
                        return 10
                    end
                else
                    return 0
                end
            end
        else
            return 0
        end
    end
    function shadowburn.availableChargePriority:ComputeAvailablePriorityOverride(t)
        if hud.shards.currentPoints >= 1 then
            if burn_ShadowConflag.remDuration > self.hud.occupied then
                return 3
            else
                if UnitExists("target") then
                    if UnitHealth("target") / UnitHealthMax("target") <= 0.3 then
                        return 3
                    else
                        return 0
                    end
                else
                    return 0
                end
            end
        else
            return 0
        end
    end



    function conflag.availableChargePriority:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function demonfire.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function soulfire.onTimer:ComputeAvailablePriorityOverride(t)
        local castTime = 4 * self.hud.hasteMultiplier
        if backdraft.remDuration > self.hud.occupied then
            castTime = castTime * 0.7
        end
        if decimation.remDuration > self.hud.occupied then
            castTime = castTime * 0.2
        end
        if decimation.remDuration > castTime then
            return 4
        elseif backdraft.remDuration > castTime or blaze.remDuration - 0.5 > castTime then
            return 8
        else
            return 11
        end
    end

    function cata.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    function rift.onTimer:ComputeAvailablePriorityOverride(t)
        return 9
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(1122, talent_infernal), hud.powerUpGroup)
end

---@class ERAHUD_Warlock_DestructionHavocDuration : ERATimer
---@field private __index unknown
---@field private wdhud WDestructionHUD
---@field private talent_havoc ERALIBTalent
---@field private talent_mayhem ERALIBTalent
ERAHUD_Warlock_DestructionHavocDuration = {}
ERAHUD_Warlock_DestructionHavocDuration.__index = ERAHUD_Warlock_DestructionHavocDuration
setmetatable(ERAHUD_Warlock_DestructionHavocDuration, { __index = ERATimer })

---@param hud WDestructionHUD
---@param talent_havoc ERALIBTalent
---@param talent_mayhem ERALIBTalent
---@return ERAHUD_Warlock_DestructionHavocDuration
function ERAHUD_Warlock_DestructionHavocDuration:create(hud, talent_havoc, talent_mayhem)
    local x = {}
    setmetatable(x, ERAHUD_Warlock_DestructionHavocDuration)
    ---@cast x ERAHUD_Warlock_DestructionHavocDuration
    x.wdhud = hud
    x.talent_havoc = talent_havoc
    x.talent_mayhem = talent_mayhem
    x:constructTimer(hud)
    x.totDuration = 12
    x.remDuration = 0
    return x
end

function ERAHUD_Warlock_DestructionHavocDuration:checkDataItemTalent()
    return self.talent_havoc:PlayerHasTalent() or self.talent_mayhem:PlayerHasTalent()
end

---@param t number
function ERAHUD_Warlock_DestructionHavocDuration:updateData(t)
    if self.talent_mayhem:PlayerHasTalent() then
        self.totDuration = 5
    else
        self.totDuration = 12
    end
    self.remDuration = self.totDuration - (t - self.wdhud.lastHavoc)
    if self.remDuration < 0 then
        self.remDuration = 0
    end
end
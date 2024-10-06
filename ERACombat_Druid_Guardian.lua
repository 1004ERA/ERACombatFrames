---@class DruidGuardianHUD : DruidHUD
---@field furCost number
---@field mangleCost number

---@param cFrame ERACombatFrame
---@param talents DruidCommonTalents
function ERACombatFrames_DruidGuardianSetup(cFrame, talents)
    local talent_survival = ERALIBTalent:Create(103193)
    local talent_cenarius = ERALIBTalent:Create(103218)
    local talent_bristling = ERALIBTalent:Create(103230)
    local talent_sleeper = ERALIBTalent:Create(103207)
    local talent_pulver = ERALIBTalent:Create(103222)
    local talent_beam = ERALIBTalent:Create(114700)
    local talent_ironfur_25pct = ERALIBTalent:Create(103196)
    local talent_incarnation = ERALIBTalent:Create(103201)
    local talent_berszerk_cooldowns = ERALIBTalent:Create(103216)
    local talent_berszerk_maul = ERALIBTalent:Create(103224)
    local talent_berszerk_ironfur = ERALIBTalent:Create(103211)
    local talent_berszerk = ERALIBTalent:CreateAnd(ERALIBTalent:CreateOr(talent_berszerk_cooldowns, talent_berszerk_maul, talent_berszerk_ironfur), ERALIBTalent:CreateNot(talent_incarnation))
    local talent_convoke = ERALIBTalent:Create(103200)
    local talent_proc_maulraze = ERALIBTalent:Create(103197)
    local talent_not_proc_maulraze = ERALIBTalent:CreateNotTalent(103197)
    local talent_proc_moonfire = ERALIBTalent:Create(103212)
    local talent_raze = ERALIBTalent:Create(114701)
    local htalent_ravage = ERALIBTalent:Create(117206)
    local htalent_wildpower = ERALIBTalent:Create(117209)

    local hud = ERACombatFrames_Druid_CommonSetup(cFrame, 3, talents, ERALIBTalent:Create(103293), nil)
    ---@cast hud DruidGuardianHUD
    hud.furCost = 40
    hud.mangleCost = 40

    ERACombatFrames_Druid_NonBalance(hud, talents, ERALIBTalentFalse)
    ERACombatFrames_Druid_NonFeral(hud, talents)
    ERACombatFrames_Druid_NonRestoration(hud, talents)

    local enemies = ERACombatEnemies:Create(cFrame, 3)

    local dots = ERAHUDDOT:Create(hud)
    dots:AddDOT(164812, nil, ERA_Druid_MoonF_R, ERA_Druid_MoonF_G, ERA_Druid_MoonF_B, nil, 0, 18)

    local ironfur_proc_25pct = hud:AddTrackedBuff(201671, talent_ironfur_25pct)
    local berserkDuration = hud:AddTrackedBuff(50334, talent_berszerk)
    local incarnationDuration = hud:AddTrackedBuff(102558, talent_incarnation)
    local berserkOrIncarnationDuration = hud:AddOrTimer(false, berserkDuration, incarnationDuration)

    function hud:DataUpdatedOverride(t)
        self.furCost = 40
        self.mangleCost = 40
        if ironfur_proc_25pct.remDuration > 0 then
            self.furCost = self.furCost * 0.75
        end
        if berserkOrIncarnationDuration.remDuration > 0 then
            if talent_berszerk_ironfur:PlayerHasTalent() then
                self.furCost = self.furCost / 2
            end
            if talent_berszerk_maul:PlayerHasTalent() then
                self.mangleCost = self.mangleCost / 2
            end
        end
    end

    function hud.rageMark:ComputeValueOverride(t)
        if hud.furCost ~= 40 and hud.mangleCost ~= 40 then
            return 40
        else
            return -1
        end
    end

    local ironMark = hud.rage.bar:AddMarkingFrom0(40, talents.ironfur)
    function ironMark:ComputeValueOverride(t)
        if hud.furCost == 40 then
            ironMark:SetInsufficientColor(1.0, 1.0, 1.0)
            ironMark:SetAvailableColor(0.0, 1.0, 0.0)
        else
            ironMark:SetInsufficientColor(1.0, 0.0, 0.0)
            ironMark:SetAvailableColor(ERA_Druid_IrFur_R, ERA_Druid_IrFur_G, ERA_Druid_IrFur_B)
        end
        return hud.furCost
    end

    local mangleMark = hud.rage.bar:AddMarkingFrom0(40)
    function mangleMark:ComputeValueOverride(t)
        if hud.mangleCost ~= hud.furCost then
            if hud.mangleCost == 40 then
                ironMark:SetAvailableColor(0.0, 1.0, 0.0)
            else
                ironMark:SetAvailableColor(0.0, 0.0, 1.0)
            end
            return hud.mangleCost
        else
            return -1
        end
    end

    --- SAO ---

    local procMangle = hud:AddTrackedBuff(93622)
    hud:AddAuraOverlay(procMangle, 1, 510822, false, "TOP", false, false, false, false)

    local freeMaulRaze = hud:AddTrackedBuff(135286, talent_proc_maulraze)
    hud:AddAuraOverlay(freeMaulRaze, 1, 774420, false, "LEFT", false, false, false, false)
    local ravage = hud:AddTrackedBuff(441602, htalent_ravage)
    --hud:AddAuraOverlay(ravage, 1, "CovenantChoice-Celebration-Venthyr-DetailLine", true, "MIDDLE", false, false, false, false)
    hud:AddAuraOverlay(ravage, 1, "CovenantChoice-Celebration-Venthyr-DetailLine", true, "LEFT", false, false, true, false, talent_not_proc_maulraze)

    local freeRegrowth = hud:AddTrackedBuff(372152, talent_cenarius)
    hud:AddAuraOverlay(freeRegrowth, 1, 450929, false, "RIGHT", true, false, false, false)

    local moonfireProc = hud:AddTrackedBuff(213708, talent_proc_moonfire)
    hud:AddAuraOverlay(moonfireProc, 1, 450914, false, "BOTTOM", false, false, true, false)

    --- bars ---

    hud:AddAuraBar(berserkDuration, nil, 1.0, 0.0, 1.0)
    hud:AddAuraBar(incarnationDuration, nil, 1.0, 0.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedBuff(200851, talent_sleeper), nil, 0.0, 0.0, 1.0)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(80313, talent_pulver), nil, 1.0, 0.8, 0.8)

    hud:AddAuraBar(hud:AddTrackedBuff(61336, talent_survival), nil, 0.5, 0.4, 0.0)

    --- rotation ---

    local mangle = hud:AddRotationCooldown(hud.mangleCooldown)

    local regen = hud:AddRotationCooldown(hud:AddTrackedCooldown(22842))

    local beam = hud:AddRotationCooldown(hud:AddTrackedCooldown(204066, talent_beam))

    local wildpowerDuration = hud:AddTrackedBuff(441701, htalent_wildpower)
    hud:AddRotationStacks(wildpowerDuration, 6, 6).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    local pulver = hud:AddRotationCooldown(hud:AddTrackedCooldown(80313, talent_pulver))

    local bristling = hud:AddRotationCooldown(hud:AddTrackedCooldown(155835, talent_bristling))

    --[[

    prio

    1 - mangle or thrash depending on number of targets
    2 - thrash or mangle depending on number of targets
    3 - ravage if maul or raze proc
    4 - maul proc
    5 - raze proc
    6 - regen
    7 - beam
    8 - pulver
    9 - bristling

    ]]

    function mangle.onTimer:ComputeAvailablePriorityOverride(t)
        if hud.bearForm.remDuration > 0 then
            if enemies:GetCount() > 2 then
                return 2
            else
                return 1
            end
        else
            return 0
        end
    end

    local thrashPrio = hud:AddPriority(451161)
    function thrashPrio:ComputeDurationOverride(t)
        return hud.thrashCooldown.remDuration
    end
    function thrashPrio:ComputeAvailablePriorityOverride(t)
        if hud.bearForm.remDuration > 0 then
            if enemies:GetCount() > 2 then
                return 1
            else
                return 2
            end
        else
            return 0
        end
    end

    local ravagePrio = hud:AddPriority(5927623, htalent_ravage)
    function ravagePrio:ComputeAvailablePriorityOverride(t)
        if hud.bearForm.remDuration > 0 and freeMaulRaze.remDuration > self.hud.occupied and ravage.remDuration > self.hud.occupied then
            return 3
        else
            return 0
        end
    end

    local maulPrio = hud:AddPriority(132136)
    function maulPrio:ComputeAvailablePriorityOverride(t)
        if hud.bearForm.remDuration > 0 and freeMaulRaze.remDuration > self.hud.occupied and ravage.remDuration <= self.hud.occupied and (enemies:GetCount() < 3 or not talent_raze:PlayerHasTalent()) then
            return 4
        else
            return 0
        end
    end

    local razePrio = hud:AddPriority(132131, talent_raze)
    function razePrio:ComputeAvailablePriorityOverride(t)
        if hud.bearForm.remDuration > 0 and freeMaulRaze.remDuration > self.hud.occupied and ravage.remDuration <= self.hud.occupied and enemies:GetCount() >= 3 then
            return 5
        else
            return 0
        end
    end

    function regen.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function beam.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    function pulver.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    function bristling.onTimer:ComputeAvailablePriorityOverride(t)
        return 9
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(50334, talent_berszerk), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102558, talent_incarnation), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(391528, talent_convoke), hud.powerUpGroup, nil, nil, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(200851, talent_sleeper), hud.defenseGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(61336, talent_survival), hud.defenseGroup)
end

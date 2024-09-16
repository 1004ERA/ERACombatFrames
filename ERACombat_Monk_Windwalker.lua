---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param talents MonkCommonTalents
function ERACombatFrames_MonkWindwalkerSetup(cFrame, enemies, talents)
    local talent_whirling = ERALIBTalent:Create(125011)
    local talent_not_whirling = ERALIBTalent:CreateNotTalent(125011)
    local talent_windlord = ERALIBTalent:Create(125022)
    local talent_fae_active = ERALIBTalent:Create(126026)
    local talent_fae_passive = ERALIBTalent:Create(124816)
    local talent_fae_any = ERALIBTalent:CreateOr(talent_fae_active, talent_fae_passive)
    local talent_chib = ERALIBTalent:Create(124952)
    local talent_sef = ERALIBTalent:Create(124826)
    local talent_inner_peace = ERALIBTalent:Create(125021)
    local talent_capacitor = ERALIBTalent:Create(124832)
    local talent_spinning_ignition = ERALIBTalent:Create(124822)
    local talent_combat_wisdom = ERALIBTalent:Create(125025)
    local talent_freespinning = ERALIBTalent:Create(124834)
    local talent_xuen = ERALIBTalent:Create(125013)
    local talent_teachings = ERALIBTalent:Create(124827)
    local talent_knowledge = ERALIBTalent:Create(125009)
    local talent_not_knowledge = ERALIBTalent:CreateAnd(talent_teachings, ERALIBTalent:CreateNotTalent(125009))
    local talent_galeforce = ERALIBTalent:Create(124817)
    local talent_xuensbattlegear = ERALIBTalent:Create(125017)
    local htalent_conduit = ERALIBTalent:Create(125062)

    local hud = ERAHUD:Create(cFrame, 1.0, true, false, 3, 1.0, 1.0, 0.0, false, 3)
    ---@cast hud MonkHUD
    hud.power.hideFullOutOfCombat = true

    ERACombatFrames_MonkCommonSetup(hud, talents, 1.4, ERALIBTalent:Create(124941))

    local chi = ERAHUDModulePointsUnitPower:Create(hud, 12, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil)
    function chi:GetIdlePointsOverride()
        if talent_combat_wisdom:PlayerHasTalent() then
            return 2
        else
            return 0
        end
    end

    hud.power.bar:AddMarkingFrom0(55, talent_inner_peace)
    hud.power.bar:AddMarkingFrom0(60, ERALIBTalent:CreateNot(talent_inner_peace))

    -------------
    --- PROCS ---
    -------------

    local freebok = hud:AddTrackedBuff(116768)
    hud:AddAuraOverlay(freebok, 1, 1001511, false, "TOP", false, false, false, true, nil)

    local freespinning = hud:AddTrackedBuff(325202, talent_freespinning)
    hud:AddAuraOverlay(freespinning, 1, 1001512, false, "LEFT", false, false, false, false, nil)
    hud:AddAuraOverlay(freespinning, 2, 1001512, false, "RIGHT", true, false, false, false, nil)

    local chib = hud:AddTrackedBuff(460490, talent_chib)
    hud:AddAuraOverlay(chib, 1, "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)

    ----------------
    --- ROTATION ---
    ----------------

    local rsk = hud:AddTrackedCooldown(107428)
    local rskIcon = hud:AddRotationCooldown(rsk)

    local fof = hud:AddTrackedCooldown(113656)
    local fofIcon = hud:AddRotationCooldown(fof)

    local whirling = hud:AddTrackedCooldown(152175, talent_whirling)
    local whirlingIcon = hud:AddRotationCooldown(whirling)

    local spinningStacks = hud:AddSpellStacks(101546)
    hud:AddRotationStacks(spinningStacks, 5, 1004, 606543).minStacksToShowOutOfCombat = 2

    local windlord = hud:AddTrackedCooldown(392983, talent_windlord)
    local windlordIcon = hud:AddRotationCooldown(windlord)

    local faeCooldown = hud:AddTrackedCooldown(388193, talent_fae_active)
    local faeIcon = hud:AddRotationCooldown(faeCooldown)

    local teachings = hud:AddTrackedBuff(202090)
    hud:AddRotationStacks(teachings, 4, 4, nil, talent_not_knowledge).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2
    hud:AddRotationStacks(teachings, 8, 7, nil, talent_knowledge).soundOnHighlight = SOUNDKIT.ALARM_CLOCK_WARNING_2

    local capacitor = hud:AddTrackedBuff(393039, talent_capacitor)
    hud:AddRotationStacks(capacitor, 20, 18).soundOnHighlight = SOUNDKIT.UI_VOID_STORAGE_UNLOCK

    local spinningIgnition = hud:AddTrackedBuff(393057, talent_spinning_ignition)
    hud:AddRotationStacks(spinningIgnition, 30, 30, 988193)


    local fofMarker = hud:AddMarker(0.8, 0.0, 1.0)
    function fofMarker:ComputeTimeOr0IfInvisibleOverride(t)
        if fof.remDuration < self.hud.timerDuration then
            return 4 * self.hud.hasteMultiplier
        else
            return 0
        end
    end

    --[[

    PRIO

    1 - touch of death
    2 - rsk
    3 - bok consume TotM
    4 - windlord
    5 - fae exposure
    6 - fof
    7 - whirling
    8 - CJL
    9 - sck (TODO)
    10 : chi burst

    ]]

    function rskIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    local bokPrioTotM = hud:AddPriority(574575)
    function bokPrioTotM:ComputeAvailablePriorityOverride(t)
        if
            (teachings.stacks >= 4 and talent_not_knowledge:PlayerHasTalent())
            or
            (teachings.stacks >= 8 and talent_knowledge:PlayerHasTalent())
        then
            return 3
        else
            return 0
        end
    end

    function windlordIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    function faeIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function fofIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end

    function whirlingIcon.onTimer:ComputeAvailablePriorityOverride(t)
        if C_Spell.IsSpellUsable(self.cd.data.spellID) then
            self.icon:SetDesaturated(false)
        else
            self.icon:SetDesaturated(true)
        end
        return 7
    end

    local cjlPrio = hud:AddPriority(606542)
    function cjlPrio:ComputeAvailablePriorityOverride(t)
        if capacitor.stacks >= 20 then
            return 8
        else
            return 0
        end
    end

    local chibPrio = hud:AddPriority(135734)
    function chibPrio:ComputeAvailablePriorityOverride(t)
        if (chib.remDuration > 0) then
            return 10
        else
            return 0
        end
    end

    ------------
    --- BARS ---
    ------------

    hud:AddChannelInfo(113656, 1)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(451582, talent_galeforce), nil, 0.0, 0.6, 0.2)
    local battelgearBar = hud:AddAuraBar(hud:AddTrackedBuff(393053, talent_xuensbattlegear), nil, 1.0, 1.0, 0.6)
    function battelgearBar:ComputeDurationOverride(t)
        if self.aura.remDuration > rsk.remDuration and self.aura.remDuration > self.hud.remGCD then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local freebokBar = hud:AddAuraBar(freebok, nil, 0.7, 0.0, 0.1)
    function freebokBar:ComputeDurationOverride(t)
        if self.timer.remDuration < self.hud.timerDuration then
            return self.timer.remDuration
        else
            return 0
        end
    end

    local karmaBuff = hud:AddTrackedBuff(125174)
    hud:AddAuraBar(karmaBuff, nil, 1.0, 1.0, 1.0)

    local sefBuff = hud:AddTrackedBuff(137639, talent_sef)
    hud:AddAuraBar(sefBuff, nil, 1.0, 0.0, 1.0)

    local freespinningBar = hud:AddAuraBar(freespinning, 606543, 0.0, 0.8, 0.2)
    function freespinningBar:ComputeDurationOverride(t)
        if self.timer.remDuration < self.hud.timerDuration then
            return self.timer.remDuration
        else
            return 0
        end
    end

    local ignitionBar = hud:AddAuraBar(spinningIgnition, 988193, 0.5, 1.0, 0.2)
    function ignitionBar:ComputeDurationOverride(t)
        if self.timer.remDuration < self.hud.timerDuration then
            return self.timer.remDuration
        else
            return 0
        end
    end

    local chibBar = hud:AddAuraBar(chib, nil, 1.0, 0.2, 0.8)
    function chibBar:ComputeDurationOverride(t)
        if chib.stacks > 1 or self.timer.remDuration < self.hud.timerDuration then
            return self.timer.remDuration
        else
            return 0
        end
    end

    ---------------
    --- UTILITY ---
    ---------------

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(101545), hud.movementGroup, nil, 2.5) -- fsk
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(137639, talent_sef), hud.powerUpGroup, nil, -3)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(123904, talent_xuen), hud.powerUpGroup, nil, -2)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(443028, htalent_conduit), hud.powerUpGroup, nil, -1)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(122470), hud.defenseGroup, nil, 0) -- karma
end

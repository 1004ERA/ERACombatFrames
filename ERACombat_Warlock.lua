---@class (exact) WarlockCommonTalents
---@field instademon ERALIBTalent
---@field rush ERALIBTalent
---@field curses ERALIBTalent
---@field amplicurse ERALIBTalent
---@field selfPortal ERALIBTalent
---@field groupPortal ERALIBTalent
---@field howl ERALIBTalent
---@field coil ERALIBTalent
---@field pact ERALIBTalent
---@field shadowfury ERALIBTalent
---@field shadowflame ERALIBTalent
---@field gluttony ERALIBTalent
---@field healthstone ERALIBTalent
---@field succulent ERALIBTalent
---@field diabolist ERALIBTalent
---@field satyr ERALIBTalent
---@field wither ERALIBTalent
---@field not_wither ERALIBTalent
---@field short_wither ERALIBTalent
---@field malevolence ERALIBTalent

---@class WarlockHUD : ERAHUD

---@class WarlockWholeHUD : WarlockHUD
---@field shards ERAHUDWarlockWholeShards

---@param cFrame ERACombatFrame
function ERACombatFrames_WarlockSetup(cFrame)
    ERACombatGlobals_SpecID1 = 265
    ERACombatGlobals_SpecID2 = 266
    ERACombatGlobals_SpecID3 = 267

    local affliOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local demonOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local destrOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { affliOptions, demonOptions, destrOptions }

    ---@type WarlockCommonTalents
    local talents = {
        instademon = ERALIBTalent:Create(91439),
        rush = ERALIBTalent:Create(91460),
        curses = ERALIBTalent:Create(91462),
        amplicurse = ERALIBTalent:Create(91442),
        selfPortal = ERALIBTalent:Create(124694),
        groupPortal = ERALIBTalent:Create(91466),
        howl = ERALIBTalent:Create(91458),
        coil = ERALIBTalent:Create(91457),
        pact = ERALIBTalent:Create(91444),
        shadowfury = ERALIBTalent:Create(91452),
        shadowflame = ERALIBTalent:Create(91450),
        gluttony = ERALIBTalent:Create(91434),
        healthstone = ERALIBTalent:CreateNotTalent(91434),
        succulent = ERALIBTalent:Create(117448),
        diabolist = ERALIBTalent:Create(117452),
        satyr = ERALIBTalent:Create(117419),
        wither = ERALIBTalent:Create(117437),
        not_wither = ERALIBTalent:CreateNotTalent(117437),
        short_wither = ERALIBTalent:Create(117451),
        malevolence = ERALIBTalent:Create(117439),
    }

    if (not affliOptions.disabled) then
        ERACombatFrames_WarlockAfflictionSetup(cFrame, talents)
    end
    if (not demonOptions.disabled) then
        ERACombatFrames_WarlockDemonologySetup(cFrame, talents)
    end
    if (not destrOptions.disabled) then
        ERACombatFrames_WarlockDestructionSetup(cFrame, talents)
    end
end

---@param cFrame ERACombatFrame
---@param spec integer
---@param requireCLEU boolean
---@param talents WarlockCommonTalents
---@param talent_pet ERALIBTalent
---@param talent_sacrifice ERALIBTalent
---@return WarlockHUD
function ERACombatFrames_WarlockCommonSetup(cFrame, spec, requireCLEU, talents, talent_pet, talent_sacrifice)
    local hud = ERAHUD:Create(cFrame, 1.5, requireCLEU, false, -1, 1.0, 1.0, 1.0, talent_pet, spec)
    ---@cast hud WarlockHUD

    hud.healthstoneTalent = talents.healthstone

    hud:AddChannelInfo(234153, 1)

    hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(334275, talents.curses), nil, 0.3, 0.3, 0.3)

    --- SAO ---

    ---@class MissingWarlockCurse : ERASAOMissingTimer
    ---@field lastTriggered number|nil
    ---@field lastTarGUID string|nil

    local anyCurseByAnyone = hud:AddOrTimer(true, hud:AddTrackedDebuffOnTargetAnyCaster(334275, talents.curses), hud:AddTrackedDebuffOnTargetAnyCaster(1714, talents.curses), hud:AddTrackedDebuffOnTargetAnyCaster(702),
        hud:AddTrackedDebuffOnTargetAnyCaster(442804, talents.satyr))
    local missingCurse = hud:AddMissingTimerOverlay(anyCurseByAnyone, true, 461878, false, "BOTTOM", false, true, false, false)
    ---@cast missingCurse MissingWarlockCurse
    function missingCurse:ConfirmIsActiveOverride(t, combat)
        local tarHealth = UnitHealth("target")
        if tarHealth and tarHealth > 0 then
            if UnitCanAttack("player", "target") and (UnitIsPlayer("target") or tarHealth > 2 * self.hud.health.maxHealth) then
                local tarGUID = UnitGUID("target")
                if self.lastTriggered and tarGUID == self.lastTarGUID and t - self.lastTriggered < 42 then
                    return t - self.lastTriggered < 3
                else
                    self.lastTarGUID = tarGUID
                    self.lastTriggered = t
                    return true
                end
            else
                self.lastTriggered = nil
                return false
            end
        else
            return false
        end
    end
    ---@param combat boolean
    ---@param t number
    function missingCurse:DeactivatedOverride(t, combat)
        self.lastTarGUID = nil
        self.lastTriggered = nil
    end

    local sacriCooldown = hud:AddTrackedCooldown(108503, talent_sacrifice)
    local sacriBuff = hud:AddTrackedBuff(196099, talent_sacrifice)
    local sacriMissing = hud:AddMissingTimerOverlay(sacriBuff, false, "CovenantSanctum-Reservoir-Idle-NightFae-Spiral1", true, "MIDDLE", false, false, false, false)
    function sacriMissing:ConfirmIsActiveOverride(t)
        return sacriCooldown.remDuration <= self.hud.occupied
    end

    local rushTimer = hud:AddTrackedBuff(111400, talents.rush)
    function hud:PreUpdateDisplayOverride(t, combat)
        if rushTimer.remDuration > 0 then
            self.health.bar:SetBorderColor(1.0, 0.0, 0.0)
        else
            self.health.bar:SetBorderColor(1.0, 1.0, 1.0)
        end
    end

    --- utility ---

    local singeImp, singeSacrifice = ERACombatFrames_WarlockCommandDemon(hud, 89808, 132411, sacriBuff, talent_sacrifice)
    hud:AddUtilityDispell(singeImp, hud.specialGroup, nil, nil, nil, true, false, false, false, false)
    hud:AddUtilityDispell(singeSacrifice, hud.specialGroup, nil, nil, nil, true, false, false, false, false)

    local kickStalker, kickSacrifice = ERACombatFrames_WarlockCommandDemon(hud, 19647, 132409, sacriBuff, talent_sacrifice)
    local ksIcon = hud:AddKick(kickStalker)
    hud:AddKick(kickSacrifice).overlapsPrevious = ksIcon

    local bulwarkWalker, bulwarkSacrifice = ERACombatFrames_WarlockCommandDemon(hud, 17767, 132413, sacriBuff, talent_sacrifice)
    hud:AddUtilityCooldown(bulwarkWalker, hud.defenseGroup)
    hud:AddUtilityCooldown(bulwarkSacrifice, hud.defenseGroup)

    hud:AddBagItemIcon(hud:AddBagItemCooldown(224464, talents.gluttony), hud.healGroup, 135230, nil, true)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(108416, talents.pact), hud.defenseGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(104773), hud.defenseGroup) -- resolve

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(328774, talents.amplicurse), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(333889, talents.instademon), hud.specialGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(20707), hud.specialGroup) -- rez

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(384069, talents.shadowflame), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(6789, talents.coil), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(5484, talents.howl), hud.controlGroup)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(30283, talents.shadowfury), hud.controlGroup)

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(48020, talents.selfPortal), hud.movementGroup)

    return hud
end

---@param cFrame ERACombatFrame
---@param spec integer
---@param talent_pet ERALIBTalent
---@param talent_sacrifice ERALIBTalent
---@param talents WarlockCommonTalents
---@return WarlockWholeHUD, ERAAura
function ERACombatFrames_WarlockWholeShards(cFrame, spec, talent_pet, talent_sacrifice, talents)
    local hud = ERACombatFrames_WarlockCommonSetup(cFrame, spec, true, talents, talent_pet, talent_sacrifice)
    ---@cast hud WarlockWholeHUD
    hud.shards = ERAHUDWarlockWholeShards:create(hud)

    local succulent = hud:AddTrackedBuff(449793, talents.succulent)

    return hud, succulent
end

---@param hud WarlockHUD
---@param talents WarlockCommonTalents
---@param prio number
function ERACombatFrames_WarlockMalevolence(hud, talents, prio)
    local bar = hud:AddAuraBar(hud:AddTrackedBuff(442726, talents.malevolence), nil, 0.0, 0.7, 0.2)
    --[[
    function bar:ComputeDurationOverride(t)
        if self.aura.remDuration >= self.hud.timerDuration then
            return -1
        else
            return self.aura.remDuration
        end
    end
    ]]

    local cd = hud:AddRotationCooldown(hud:AddTrackedCooldown(442726, talents.malevolence))
    function cd.onTimer:ComputeAvailablePriorityOverride(t)
        return prio
    end
end

---@param hud WarlockHUD
---@param talents WarlockCommonTalents
---@return ERAAura, ERAAura, ERATimer
function ERACombatFrames_WarlockDiabolist(hud, talents)
    local overlordRitual = hud:AddTrackedBuff(431944, talents.diabolist)
    local overlordProc = hud:AddTrackedBuff(428524, talents.diabolist)
    local mocRitual = hud:AddTrackedBuff(432815, talents.diabolist)
    local mocProc = hud:AddTrackedBuff(432794, talents.diabolist)
    local pitRitual = hud:AddTrackedBuff(432816, talents.diabolist)
    local pitProc = hud:AddTrackedBuff(432795, talents.diabolist)

    local summonIcons = {}

    hud:AddAuraBar(overlordRitual, 1388064, 0.0, 1.0, 1.0)
    local overlordIcon = hud:AddRotationBuff(overlordProc, 1388064)
    table.insert(summonIcons, overlordIcon)

    hud:AddAuraBar(mocRitual, 1711332, 1.0, 0.7, 0.7)
    local mocIcon = hud:AddRotationBuff(mocProc, 1711332)
    table.insert(summonIcons, mocIcon)
    mocIcon.overlapsPrevious = overlordIcon

    hud:AddAuraBar(pitRitual, 1117878, 0.5, 1.0, 0.0)
    local pitIcon = hud:AddRotationBuff(pitProc, 1117878)
    table.insert(summonIcons, pitIcon)
    pitIcon.overlapsPrevious = mocIcon

    for _, icon in ipairs(summonIcons) do
        icon.specialPosition = true
        function icon.ShowWhenMissing()
            return false
        end
    end

    local cloven = hud:AddTrackedDebuffOnTarget(434424, talents.diabolist)
    hud:AddAuraBar(cloven, nil, 0.4, 0.0, 0.7)

    local boltTimer = hud:AddTrackedBuff(433891, talents.diabolist)

    local ruinationTimer = hud:AddTrackedBuff(433885, talents.diabolist)

    return boltTimer, ruinationTimer, hud:AddOrTimer(false, overlordProc, mocProc, pitProc)
end

---@param hud WarlockHUD
---@param petSpellID integer
---@param sacrificeSpellID integer
---@param sacriBuff ERAAura
---@param talent_sacrifice ERALIBTalent
---@return ERACooldown, ERACooldown
function ERACombatFrames_WarlockCommandDemon(hud, petSpellID, sacrificeSpellID, sacriBuff, talent_sacrifice)
    local cdPet = hud:AddTrackedCooldown(petSpellID)
    cdPet.isPetSpell = true

    local iconID = C_Spell.GetSpellTexture(sacrificeSpellID)

    local cdSacrifice = hud:AddTrackedCooldown(sacrificeSpellID, talent_sacrifice)
    function cdSacrifice:CustomCheckIsKnown()
        return sacriBuff.remDuration > 0 and C_Spell.GetSpellTexture(119898) == iconID
    end

    return cdPet, cdSacrifice
end

--------------------
--#region SHARDS ---

---@class (exact) ERAHUDWarlockWholeShards : ERAHUDModulePoints
---@field private __index unknown
ERAHUDWarlockWholeShards = {}
ERAHUDWarlockWholeShards.__index = ERAHUDWarlockWholeShards
setmetatable(ERAHUDWarlockWholeShards, { __index = ERAHUDModulePoints })

---@param hud ERAHUD
---@return ERAHUDWarlockWholeShards
function ERAHUDWarlockWholeShards:create(hud)
    local e = {}
    setmetatable(e, ERAHUDWarlockWholeShards)
    ---@cast e ERAHUDWarlockWholeShards
    e:constructPoints(hud, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, nil)
    return e
end

function ERAHUDWarlockWholeShards:GetIdlePointsOverride()
    return 3
end

function ERAHUDWarlockWholeShards:getMaxPoints()
    return UnitPowerMax("player", 7)
end

function ERAHUDWarlockWholeShards:getCurrentPoints()
    return UnitPower("player", 7)
end

--#endregion
--------------------

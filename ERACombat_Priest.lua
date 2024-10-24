---@class PriestHUD : ERAHUD

---@class (exact) ERACombat_PriestCommonTalents

---@param cFrame ERACombatFrame
function ERACombatFrames_PriestSetup(cFrame)
    ERACombatGlobals_SpecID1 = 256
    ERACombatGlobals_SpecID2 = 257
    ERACombatGlobals_SpecID3 = 258

    ---@type ERACombat_PriestCommonTalents
    local talents = {

    }

    local disciplineOptions = ERACombatOptions_getOptionsForSpec(nil, 1)
    local holyOptions = ERACombatOptions_getOptionsForSpec(nil, 2)
    local shadowOptions = ERACombatOptions_getOptionsForSpec(nil, 3)

    cFrame.hideAlertsForSpec = { disciplineOptions, holyOptions, shadowOptions }

    if (not disciplineOptions.disabled) then
        ERACombatFrames_PriestDisciplineSetup(cFrame, talents)
    end
    if (not holyOptions.disabled) then
        ERACombatFrames_PriestHolySetup(cFrame, talents)
    end
    if (not shadowOptions.disabled) then
        ERACombatFrames_PriestShadowSetup(cFrame, talents)
    end
end

---@param cFrame ERACombatFrame
---@param talents ERACombat_PriestCommonTalents
---@param spec integer
---@return PriestHUD
function ERACombatFrames_PriestCommonSetup(cFrame, talents, spec)
    local hud = ERAHUD:Create(cFrame, 1.5, false, spec ~= 3, false, spec)
    ---@cast hud PriestHUD
    return hud
end

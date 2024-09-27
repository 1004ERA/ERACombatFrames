---@class (exact) PaladinCommonTalents

function ERACombatFrames_PaladinSetup(cFrame)
    ERACombatGlobals_SpecID1 = 65
    ERACombatGlobals_SpecID2 = 66
    ERACombatGlobals_SpecID3 = 70

    local holyActive = ERACombatOptions_IsSpecActive(1)
    local protActive = ERACombatOptions_IsSpecActive(2)
    local retrActive = ERACombatOptions_IsSpecActive(3)

    ---@type PaladinCommonTalents
    local talents = {

    }

    local enemies = ERACombatEnemies:Create(cFrame, protActive, retrActive)

    if (retrActive) then
        ERACombatFrames_PaladinRetributionSetup(cFrame, enemies, talents)
    end
end

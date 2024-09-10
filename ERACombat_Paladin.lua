---@class (exact) PaladinCommonTalents

function ERACombatFrames_PaladinSetup(cFrame)
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

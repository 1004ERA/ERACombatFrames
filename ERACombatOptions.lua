SLASH_ECF1 = "/ECF"
SlashCmdList["ECF"] = function(msg)
    --ERACombatOptionsFrame:Show()
    ERACombatOptions_open()
end

---@class (exact) ERACombatSpecOptions
---@field private __index ERACombatSpecOptions
---@field essentialsX number
---@field essentialsY number
---@field essentialsMinColumns number
---@field essentialsIconSize number
---@field essentialsTimerBarSize number
---@field resourcePadding number
---@field healthHeight number
---@field powerHeight number
---@field gcdHeight number
---@field gcdCount number
---@field castBarWidth number
---@field defensivePadding number
---@field defensiveIconSize number
---@field powerboostX number
---@field powerboostY number
---@field powerboostIconSize number
---@field controlX number
---@field controlY number
---@field controlIconSize number
---@field utilityIconPadding number
---@field alertX number
---@field alertY number
---@field alertWidth number
---@field alertHeight number
ERACombatSpecOptions = {}
ERACombatSpecOptions.__index = ERACombatSpecOptions

---create options for one spec
---@return ERACombatSpecOptions
function ERACombatSpecOptions:Create()
    local x = {}
    setmetatable(x, ERACombatSpecOptions)
    ---@cast x ERACombatSpecOptions

    x.essentialsX = 0
    x.essentialsY = -128
    x.essentialsMinColumns = 7
    x.essentialsIconSize = 42
    x.essentialsTimerBarSize = 8
    x.resourcePadding = 2
    x.healthHeight = 31
    x.powerHeight = 31
    x.gcdHeight = 64
    x.gcdCount = 4
    x.castBarWidth = 16
    x.defensivePadding = 4
    x.defensiveIconSize = 55
    x.powerboostX = -200
    x.powerboostY = -32
    x.powerboostIconSize = 55
    x.controlX = 200
    x.controlY = 64
    x.controlIconSize = 55
    x.utilityIconPadding = 4
    x.alertX = 0
    x.alertY = 88
    x.alertWidth = 128
    x.alertHeight = 64

    return x
end

---comment
---@param specID number
---@return ERACombatSpecOptions
function ERACombatOptions_getForSpec(specID)
    return ERACombatSpecOptions:Create()
end

---comment
---@param classID number
function ERACombatOptions_setup(classID)
    -- TODO
end

function ERACombatOptions_open()
    print("ECF OPTIONS NOT YET IMPLEMENTED")
end
function ERACombatOptions_close()
    -- TODO
end

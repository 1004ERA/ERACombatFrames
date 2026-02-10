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
---@field defensiveIconSize number
---@field defensivePadding number
---@field assistX number
---@field assistY number
---@field assistIconSize number
---@field powerboostX number
---@field powerboostY number
---@field powerboostIconSize number
---@field buffX number
---@field buffY number -- the vampire slayer
---@field buffIconSize number
---@field movementX number
---@field movementY number
---@field movementIconSize number
---@field specialX number
---@field specialY number
---@field specialIconSize number
---@field controlX number
---@field controlY number
---@field controlIconSize number
---@field utilityIconPadding number
---@field alertGroupX number
---@field alertGroupY number
---@field alertGroupIconSize number
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
    x.assistX = -200
    x.assistY = -32
    x.assistIconSize = 55
    x.powerboostX = -200
    x.powerboostY = -88
    x.powerboostIconSize = 55
    x.buffX = -200
    x.buffY = 42
    x.buffIconSize = 55
    x.movementX = 200
    x.movementY = 32
    x.movementIconSize = 55
    x.specialX = 200
    x.specialY = -88
    x.specialIconSize = 55
    x.alertGroupX = 0
    x.alertGroupY = 64
    x.alertGroupIconSize = 64
    x.controlX = 200
    x.controlY = 66
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

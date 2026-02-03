SLASH_ECF1 = "/ECF"
SlashCmdList["ECF"] = function(msg)
    --ERACombatOptionsFrame:Show()
    ERACombatOptions_open()
end

---@class (exact) ERACombatSpecOptions
---@field private __index ERACombatSpecOptions
---@field essentialsX number
---@field essentialsY number
---@field essentialsIconCount number
---@field essentialsIconSize number
---@field essentialsBarSize number
---@field resourcePadding number
---@field healthHeight number
---@field powerHeight number
---@field gcdHeight number
---@field gcdCount number
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
    x.essentialsIconCount = 7
    x.essentialsIconSize = 44
    x.essentialsBarSize = 8
    x.resourcePadding = 2
    x.healthHeight = 31
    x.powerHeight = 31
    x.gcdHeight = 64
    x.gcdCount = 4

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

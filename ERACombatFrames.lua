ERACombatFrames_initialized = false

--[[
ERA_Debug = function()
    local _, _, _, _, _, _, _, _, castID = UnitCastingInfo("player")
    if (castID and castID > 0) then
        print("CASTING")
    end
    --local spell, _, icon, startTime, endTime, _, interruptible, spellId, _, stageTotal = WeakAuras.UnitChannelInfo("player")
    local spell, _, icon, startTime, endTime, _, interruptible, spellId, _, stageTotal = UnitChannelInfo("player")
    local dur0 = GetUnitEmpowerStageDuration("player", 0)
    local dur1 = GetUnitEmpowerStageDuration("player", 1)
    local dur2 = GetUnitEmpowerStageDuration("player", 2)
    local dur3 = GetUnitEmpowerStageDuration("player", 3)
    local dur4 = GetUnitEmpowerStageDuration("player", 4)
    local min = GetUnitEmpowerMinHoldTime("player")
    local max = GetUnitEmpowerHoldAtMaxTime("player")
    print(spell)
    print("start :", startTime)
    print("end :", endTime)
    print("stages :", stageTotal)
    print("0 :", dur0)
    print("1 :", dur1)
    print("2 :", dur2)
    print("3 :", dur3)
    print("4 :", dur4)
    print("min :", min)
    print("max :", max)
    print("totdur :", (endTime - startTime))
    print("calcdur :", dur0 + dur1 + dur2 + dur3 + dur4)
end
--]]

function ERACombatFrames_loaded()
    ERACombatFrameMain:RegisterEvent("ADDON_LOADED")
end

function ERACombatFrames_event(event, ...)
    local addonName = ...
    if (addonName == "ERACombatFrames") then
        ERACombatFrames_PlayerIsNotMaxLevel = UnitLevel("player") < 70
        local _, _, classID = UnitClass("player")
        ERACombatFrames_classID = classID
        ERACombatOptions_initialize()
        local cFrame = ERACombatFrame:Create()
        if (classID == 9) then
            ERACombatFrames_WarlockSetup(cFrame)
        elseif (classID == 10) then
            ERACombatFrames_MonkSetup(cFrame)
        elseif (classID == 12) then
            ERACombatFrames_DemonHunterSetup(cFrame)
        elseif (classID == 13) then
            ERACombatFrames_EvokerSetup(cFrame)
        end
        cFrame:Pack()
    end
end

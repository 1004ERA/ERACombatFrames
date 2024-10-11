ERACombatFrames_initialized = false

--[[

TODO
- debuffs raid
- améliorer les charges de brez
- ? icone trinket ?
- special orbital strike

ERA_Debug = function()

end

/run print(C_Spell.GetSpellInfo("").spellID)
-- buff player
/run local i=1; while true do local ai=C_UnitAuras.GetBuffDataByIndex("player",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end
-- debuff target
/run local i=1; while true do local ai=C_UnitAuras.GetDebuffDataByIndex("target",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end
-- debuff player
/run local i=1; while true do local ai=C_UnitAuras.GetDebuffDataByIndex("player",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end

/run PlaySound(SOUNDKIT.UI_CORRUPTED_ITEM_LOOT_TOAST)
/run PlaySound(SOUNDKIT.)

]]

ERA_TALENTS_DO_PRINT_N = 0

function ERACombatFrames_loaded()
    ERACombatFrameMain:RegisterEvent("ADDON_LOADED")
end

function ERACombatFrames_event(event, ...)
    local addonName = ...
    if (addonName == "ERACombatFrames") then
        --ERACombatFrames_PlayerIsNotMaxLevel = UnitLevel("player") < 70
        local _, _, classID = UnitClass("player")
        ERACombatFrames_classID = classID
        ERACombatOptions_setup(classID)
        --ERACombatOptions_initialize()
        local cFrame = ERACombatFrame:Create()
        if (classID == 2) then
            --ERACombatFrames_PaladinSetup(cFrame)
        elseif (classID == 6) then
            ERACombatFrames_DeathKnightSetup(cFrame)
        elseif (classID == 9) then
            ERACombatFrames_WarlockSetup(cFrame)
        elseif (classID == 10) then
            ERACombatFrames_MonkSetup(cFrame)
        elseif (classID == 11) then
            ERACombatFrames_DruidSetup(cFrame)
        elseif (classID == 12) then
            --ERACombatFrames_DemonHunterSetup(cFrame)
        elseif (classID == 13) then
            ERACombatFrames_EvokerSetup(cFrame)
        end
        cFrame:Pack()
        print("Welcome to ERACombatFrames. Enter the /ecf command for options.")
    end
end

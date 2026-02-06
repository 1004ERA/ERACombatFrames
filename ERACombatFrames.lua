ERACombatFrames_initialized = false

--[[

TODO
- debuffs nerubar & mm+
- améliorer les charges de brez
- ? icone trinket ?
- paladin steed (lightforged)
- dracthyr racial for 11.0.5
- ? mage arcane supernova/gravity prio
- ? mage arcane spark

ERA_Debug = function()

end

/run ECF_print_talents(nil,nil,'')

/run print(C_Spell.GetSpellInfo("").spellID)
-- buff player
/run local i=1; while true do local ai=C_UnitAuras.GetBuffDataByIndex("player",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end
/run local i=1; while true do local ai=C_UnitAuras.GetBuffDataByIndex("target",i);if ai then print(ai.spellId, ai.name);i=i+1 else break end end
-- debuff target
/run local i=1; while true do local ai=C_UnitAuras.GetDebuffDataByIndex("target",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end
-- debuff player
/run local i=1; while true do local ai=C_UnitAuras.GetDebuffDataByIndex("player",i,"PLAYER");if ai then print(ai.spellId, ai.name);i=i+1 else break end end

/run PlaySound(SOUNDKIT.UI_CORRUPTED_ITEM_LOOT_TOAST)
/run PlaySound(SOUNDKIT.)

]]

function ECF_TEST()
    --[[
    for k, v in pairs(CooldownViewerDataProvider) do
        --print(k, v)
    end
    for _, cid in ipairs(C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff)) do
        --print("---- ID ", cid, " ----")
        local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cid)
        info = CooldownViewerDataProvider:GetCooldownInfoForID(cid)
        if (info) then
            for k, v in pairs(info) do
                if (issecretvalue(v) or issecrettable(v)) then
                    --print("SECRET", k, v)
                else
                    --print("PUBLIC", k, v)
                end
            end
        else
            --print("NO INFO")
        end
    end
    ]]
    --[[
    local count = C_Spell.GetSpellCastCount(247454)
    if (issecretvalue(count)) then
        print("SECRET", count)
    else
        print("PUBLIC", count)
    end
    ]]
    local vmet = 1217605
    local coll = 1221150 --1221167
    local vmetinfo = C_Spell.GetSpellInfo(vmet)
    local collinfo = C_Spell.GetSpellInfo(coll)
    local infoString = C_Spell.GetSpellInfo("Collapsing star")
    if (infoString) then
        if (infoString.spellID == coll) then
            print("found ID", infoString.spellID, "same")
        else
            print("found ID", infoString.spellID, "DIFFERENT")
        end
    else
        print("no info from string")
    end
    print(vmetinfo and vmetinfo.name or "??", C_SpellActivationOverlay.IsSpellOverlayed(vmet))
    print(collinfo and collinfo.name or "??", C_SpellActivationOverlay.IsSpellOverlayed(coll))
    local metUsable = C_Spell.IsSpellUsable(vmet)
    local colUsable = C_Spell.IsSpellUsable(coll)
    print("useable ?", metUsable, colUsable)
    print("cast count", C_Spell.GetSpellCastCount(vmet), C_Spell.GetSpellCastCount(coll))
end

function ECF_PRINT_CDM()
    local printFrame = function(frame)
        local auraFrames = { frame:GetChildren() }
        for _, c in ipairs(auraFrames) do
            if (c.cooldownInfo) then
                print(c.cooldownInfo.spellID, C_Spell.GetSpellInfo(c.cooldownInfo.spellID).name, c.auraInstanceID)
            end
        end
    end
    printFrame(BuffIconCooldownViewer)
    printFrame(BuffBarCooldownViewer)
end

---@class UnitHealPredictionCalculator
---@field GetHealAbsorbs fun(self:UnitHealPredictionCalculator): number
---@field GetDamageAbsorbs fun(self:UnitHealPredictionCalculator): number
---@field SetHealAbsorbClampMode fun(self:UnitHealPredictionCalculator, mode:Enum.UnitHealAbsorbClampMode): number
---@field SetDamageAbsorbClampMode fun(self:UnitHealPredictionCalculator, mode:Enum.UnitDamageAbsorbClampMode): number

---@class LuaCurveObject
---@field SetType fun(self:LuaCurveObject, type:Enum.LuaCurveType)
---@field AddPoint fun(self:LuaCurveObject, pointX:number, pointY:number)
---@field ClearPoints fun(self:LuaCurveObject)

---@class LuaColorCurveObject
---@field SetType fun(self:LuaColorCurveObject, type:Enum.LuaCurveType)
---@field AddPoint fun(self:LuaColorCurveObject, pointX:number, pointY:ColorMixin)
---@field ClearPoints fun(self:LuaColorCurveObject)

---@class LuaDurationObject
---@field Reset fun(self:LuaDurationObject)
---@field IsZero fun(self:LuaDurationObject): boolean
---@field EvaluateRemainingDuration fun(self:LuaDurationObject, curve:LuaCurveObject|LuaColorCurveObject): number|ColorMixin
---@field EvaluateRemainingPercent fun(self:LuaDurationObject, curve:LuaCurveObject|LuaColorCurveObject): number|ColorMixin
---@field GetStartTime fun(self:LuaDurationObject): number
---@field GetTotalDuration fun(self:LuaDurationObject): number
---@field GetRemainingDuration fun(self:LuaDurationObject): number

function ERACombatFrames_loaded()
    ERACombatFrameMain:RegisterEvent("ADDON_LOADED")
end

function ERACombatFrames_event(event, ...)
    local addonName = ...
    if (addonName == "ERACombatFrames") then
        --ERACombatFrames_PlayerIsNotMaxLevel = UnitLevel("player") < 80
        local _, _, classID = UnitClass("player")
        ERACombatFrames_classID = classID
        ERACombatOptions_setup(classID)
        --ERACombatOptions_initialize()
        local cFrame = ERACombatMainFrame:Create()
        if (classID == 2) then
            --ERACombatFrames_PaladinSetup(cFrame)
        elseif (classID == 5) then
            ERACombatFrames_PriestSetup(cFrame)
        elseif (classID == 6) then
            --ERACombatFrames_DeathKnightSetup(cFrame)
        elseif (classID == 8) then
            --ERACombatFrames_MageSetup(cFrame)
        elseif (classID == 9) then
            --ERACombatFrames_WarlockSetup(cFrame)
        elseif (classID == 10) then
            --ERACombatFrames_MonkSetup(cFrame)
        elseif (classID == 11) then
            --ERACombatFrames_DruidSetup(cFrame)
        elseif (classID == 12) then
            ERACombatFrames_DemonHunterSetup(cFrame)
        elseif (classID == 13) then
            --ERACombatFrames_EvokerSetup(cFrame)
        end
        cFrame:Pack()
        print("Welcome to ERACombatFrames. Type the \"/ecf\" command for options.")
    end
end

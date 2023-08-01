-- TODO
-- tout

function ERACombatFrames_MonkSetup(cFrame)
    ERACombatGlobals_SpecID1 = 268
    ERACombatGlobals_SpecID2 = 270
    ERACombatGlobals_SpecID3 = 269

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mwActive = ERACombatOptions_IsSpecActive(2)
    local wwActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 3, true, 1, 1, 0, false, bmActive, wwActive)
    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 0, true, 0.1, 0.1, 1.0, false, mwActive)

    if (bmActive) then
        --ERACombatFrames_MonkBrewmasterSetup(cFrame)
    end
    if (mwActive) then
        --ERACombatFrames_MonkMistweaverSetup(cFrame)
    end
    if (wwActive) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- WW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkWindwalkerSetup(cFrame)
    ERACombatPointsUnitPower:Create(cFrame, -144, -28, 12, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil, 3)

    local nrg = ERACombatPower:Create(cFrame, -155, -51, 155, 22, 3, false, 1.0, 1.0, 0.0, 3)
    local tigerPalmConsumer = nrg:AddConsumer(50, 606551)

    local health = ERACombatHealth:Create(cFrame, -155, -77, 155, 22, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -89, 32, 1, 3)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(107428), nil, -1, 0.5, true, false) -- rsk
    timers:AddCooldownIcon(timers:AddTrackedCooldown(113656), nil, -2, 0.5, true, false) -- fof
    timers:AddCooldownIcon(timers:AddTrackedCooldown(322101), nil, -4, 0.5, true, false) -- EH
end

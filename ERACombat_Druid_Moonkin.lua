---@alias BalanceMoonType "NEW" | "HALF" | "FULL"
---@class MoonsIcon : ERAHUDRotationCooldownIcon
---@field moonType BalanceMoonType

---@class DruidBalanceHUD : DruidHUD
---@field wrathStacks ERASpellStacks
---@field starStacks ERASpellStacks
---@field moons MoonsIcon

---@param cFrame ERACombatFrame
---@param talents DruidCommonTalents
function ERACombatFrames_DruidMoonkinSetup(cFrame, talents)
    --local talent_short_dots = ERALIBTalent:Create(109863)
    local talent_cheap_spenders = ERALIBTalent:Create(109872)
    local talent_cheap_spenders_during_incarnation = ERALIBTalent:Create(109864)
    local talent_flare = ERALIBTalent:Create(109841)
    local talent_balanced_power = ERALIBTalent:Create(109862)
    local talent_starfall = ERALIBTalent:Create(109833)
    local talent_beam = ERALIBTalent:Create(109867)
    local talent_treants = ERALIBTalent:Create(109844)
    local talent_warrior = ERALIBTalent:Create(114648)
    local talent_dreamstate = ERALIBTalent:Create(109857)
    local talent_shroom = ERALIBTalent:Create(117100)
    local talent_incarnation = ERALIBTalent:Create(109839)
    local talent_alignment = ERALIBTalent:CreateAnd(ERALIBTalent:Create(109849), ERALIBTalent:CreateNot(talent_incarnation))
    local talent_convoke = ERALIBTalent:Create(109838)
    local talent_fury = ERALIBTalent:Create(109859)
    local talent_moons = ERALIBTalent:Create(109860)
    --local talent_amplification = ERALIBTalent:Create(109865)
    local talent_cosmos = ERALIBTalent:Create(123859)
    local talent_starweaver = ERALIBTalent:Create(109873)
    local talent_orbital_strike = ERALIBTalent:Create(109855)
    local talent_not_orbital_strike = ERALIBTalent:CreateNotTalent(109855)
    local talent_alignment_with_orbital_strike = ERALIBTalent:CreateAnd(talent_alignment, talent_orbital_strike)
    local talent_alignment_without_orbital_strike = ERALIBTalent:CreateAnd(talent_alignment, talent_not_orbital_strike)
    local htalent_blooming = ERALIBTalent:Create(117196)

    local enemies = ERACombatEnemies:Create(cFrame, 1)

    local hud = ERACombatFrames_Druid_CommonSetup(cFrame, 1, talents, ERALIBTalent:Create(103283), nil)
    ---@cast hud DruidBalanceHUD
    hud.wrathStacks = hud:AddSpellStacks(190984)
    hud.starStacks = hud:AddSpellStacks(194153)

    ERACombatFrames_Druid_NonFeral(hud, talents)
    ERACombatFrames_Druid_NonGuardian(hud, talents)
    ERACombatFrames_Druid_NonRestoration(hud, talents)

    ERADruidEclipse:Create(cFrame, hud)

    local incarnationDuration = hud:AddTrackedBuff(102560, talent_incarnation)
    local starfallDuration = hud:AddTrackedBuff(191034, talent_starfall)

    local power = ERAHUDPowerBarModule:Create(hud, Enum.PowerType.LunarPower, 14, 0.7, 0.3, 1.0, nil)
    function power:ConfirmIsVisibleOverride(t, combat)
        return combat or (talent_balanced_power:PlayerHasTalent() and math.abs(self.currentPower - 50) < 2) or ((not talent_balanced_power:PlayerHasTalent()) and self.currentPower > 0)
    end
    local surgeMark = power.bar:AddMarkingFrom0(40)
    function surgeMark:ComputeValueOverride(t)
        local cost
        if talent_cheap_spenders:PlayerHasTalent() then
            cost = 36
        else
            cost = 40
        end
        if talent_cheap_spenders_during_incarnation:PlayerHasTalent() and incarnationDuration.remDuration > hud.occupied then
            cost = cost - 10
        end
        return cost
    end
    local fallMark = power.bar:AddMarkingFrom0(50, talent_starfall)
    function fallMark:PreUpdateDisplayOverride(t)
        if starfallDuration.remDuration > 0 and starfallDuration.remDuration >= starfallDuration.hud.occupied then
            self:SetAvailableColor(1.0, 0.6, 0.0)
            self:SetInsufficientColor(1.0, 0.0, 0.0)
        else
            self:SetAvailableColor(0.0, 1.0, 0.0)
            self:SetInsufficientColor(1.0, 1.0, 1.0)
        end
    end
    function fallMark:ComputeValueOverride(t)
        if enemies:GetCount() > 1 then
            local cost
            if talent_cheap_spenders:PlayerHasTalent() then
                cost = 45
            else
                cost = 50
            end
            if talent_cheap_spenders_during_incarnation:PlayerHasTalent() and incarnationDuration.remDuration > hud.occupied then
                cost = cost - 12
            end
            return cost
        else
            return -1
        end
    end

    local dots = ERAHUDDOT:Create(hud)

    local flare = dots:AddDOT(202347, nil, 1.0, 1.0, 1.0, talent_flare, 1.5, 24)
    local moonFire = dots:AddDOT(164812, nil, ERA_Druid_MoonF_R, ERA_Druid_MoonF_G, ERA_Druid_MoonF_B, nil, 0, 22)
    local sunFire = dots:AddDOT(164815, nil, ERA_Druid_SunF_R, ERA_Druid_SunF_G, ERA_Druid_SunF_B, nil, 0, 18)

    --[[
    ---@type ERAHUDDOTDefinition[]
    local dotsArray = {}
    table.insert(dotsArray, flare)
    table.insert(dotsArray, moonFire)
    table.insert(dotsArray, sunFire)
    for _, dot in ipairs(dotsArray) do
        function dot:ComputeRefreshDurationOverride(t)
            return (1 - 0.125 * talent_short_dots.rank) * self.baseTotDuration * 0.3
        end
    end
    ]]

    local solarEclipse = hud:AddTrackedBuff(48517)
    local lunarEclipse = hud:AddTrackedBuff(48518)

    local fasterFiller = hud:AddTrackedBuff(450346, talent_dreamstate)

    local starfireCastMarker = hud:AddMarker(0.0, 0.0, 1.0)
    function starfireCastMarker:ComputeTimeOr0IfInvisibleOverride(t)
        local castTime = 2.25 * self.hud.hasteMultiplier
        if fasterFiller.remDuration + 0.1 > self.hud.occupied then
            castTime = castTime * 0.6
        end
        if castTime + self.hud.occupied < lunarEclipse.remDuration then
            return castTime
        else
            return 0
        end
    end

    --- SAO ---

    local cosmos_starsurge = hud:AddTrackedBuff(450360, talent_cosmos)
    local starweaver_starsurge = hud:AddTrackedBuff(393944, talent_starweaver)
    hud:AddTimerOverlay(hud:AddOrTimer(false, cosmos_starsurge, starweaver_starsurge), "ChallengeMode-Runes-BackgroundBurst", true, "MIDDLE", false, false, false, false)

    local cosmos_starfall = hud:AddTrackedBuff(450361, talent_cosmos)
    local starweaver_starfall = hud:AddTrackedBuff(393942, talent_starweaver)
    hud:AddTimerOverlay(hud:AddOrTimer(false, cosmos_starfall, starweaver_starfall), 463452, false, "TOP", false, false, false, false)

    local instaRegrowth = hud:AddTrackedBuff(429438, htalent_blooming)
    hud:AddAuraOverlay(instaRegrowth, 1, 450929, false, "RIGHT", true, false, false, false)

    local instaFiller = hud:AddTrackedBuff(429474, htalent_blooming)
    hud:AddAuraOverlay(instaFiller, 1, 460831, false, "BOTTOM", false, true, false, false)
    local instaStarfire = hud:AddTrackedBuff(157228)
    local frenzySAO = hud:AddAuraOverlay(instaStarfire, 1, 460831, false, "BOTTOM", false, true, false, false)
    frenzySAO:SetVertexColor(0.0, 0.0, 1.0)
    function frenzySAO:ConfirmIsActiveOverride(t)
        return instaFiller.remDuration <= 0
    end

    --- bars ---

    hud:AddAuraBar(solarEclipse, nil, 0.7, 0.5, 0.0)
    hud:AddAuraBar(lunarEclipse, nil, 0.0, 0.2, 1.0)

    hud:AddAuraBar(starfallDuration, nil, 1.0, 1.0, 1.0)

    local cosmos_starsurge_bar = hud:AddAuraBar(cosmos_starsurge, nil, 1.0, 0.7, 1.0)
    function cosmos_starsurge_bar:ComputeDurationOverride(t)
        if self.aura.remDuration < 5 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local cosmos_starfall_bar = hud:AddAuraBar(cosmos_starfall, nil, 0.5, 0.5, 1.0)
    function cosmos_starfall_bar:ComputeDurationOverride(t)
        if self.aura.remDuration < 5 then
            return self.aura.remDuration
        else
            return 0
        end
    end

    --hud:AddAuraBar(hud:AddTrackedDebuffOnTarget(450214, talent_amplification), nil, 1.0, 0.0, 1.0)

    --hud:AddAuraBar(hud:AddTrackedBuff(194223, talent_alignment_without_orbital_strike), nil, 1.0, 0.0, 1.0)
    --hud:AddAuraBar(hud:AddTrackedBuff(383410, talent_alignment_with_orbital_strike), nil, 1.0, 0.0, 1.0)
    --hud:AddAuraBar(hud:AddTrackedBuff(102560, talent_incarnation), nil, 1.0, 0.0, 1.0)

    --- rotation ---

    hud:AddKick(hud:AddTrackedCooldown(78675, talent_beam))

    local shroom = hud:AddRotationCooldown(hud:AddTrackedCooldown(88747, talent_shroom))

    -------------------
    --#region moons ---

    local moons = hud:AddRotationCooldown(hud:AddTrackedCooldown(274281, talent_moons))
    ---@cast moons  MoonsIcon
    hud.moons = moons
    function hud:DataUpdatedOverride(t)
        local requiredIconID = C_Spell.GetSpellInfo(274281).iconID
        ---@type BalanceMoonType
        local moonType
        if requiredIconID == 1392542 then
            moonType = "FULL"
        elseif requiredIconID == 1392543 then
            moonType = "HALF"
        else
            -- 1392545
            moonType = "NEW"
        end
        if moonType ~= self.moons.moonType then
            self.moons.moonType = moonType
            self.moons.icon:SetIconTexture(requiredIconID)
            self.moons.onTimer.icon:SetIconTexture(requiredIconID)
            self.moons.availableChargePriority.icon:SetIconTexture(requiredIconID)
        end
    end

    --#endregion
    -------------------

    local treants = hud:AddRotationCooldown(hud:AddTrackedCooldown(205636, talent_treants))
    local warrior = hud:AddRotationCooldown(hud:AddTrackedCooldown(202425, talent_warrior))

    local fury = hud:AddRotationCooldown(hud:AddTrackedCooldown(202770, talent_fury))

    --[[

    prio

    1 - surge proc
    2 - fall proc
    3 - moons
    4 - starfall
    5 - shroom
    6 - treants
    7 - warrior of elune
    8 - fury

    ]]

    local starsurgePrio = hud:AddPriority(135730)
    function starsurgePrio:ComputeAvailablePriorityOverride(t)
        if cosmos_starsurge.remDuration > self.hud.occupied then
            return 1
        else
            return 0
        end
    end

    local starfallPrio = hud:AddPriority(236168, talent_starfall)
    function starfallPrio:ComputeAvailablePriorityOverride(t)
        if cosmos_starfall.remDuration > self.hud.occupied then
            return 2
        elseif starfallDuration.remDuration <= self.hud.occupied and enemies:GetCount() > 1 then
            return 4
        else
            return 0
        end
    end

    function moons.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function shroom.onTimer:ComputeAvailablePriorityOverride(t)
        return 5
    end

    function treants.onTimer:ComputeAvailablePriorityOverride(t)
        return 6
    end
    function warrior.onTimer:ComputeAvailablePriorityOverride(t)
        return 7
    end

    function fury.onTimer:ComputeAvailablePriorityOverride(t)
        return 8
    end

    --- utility ---

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(391528, talent_convoke), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(194223, talent_alignment_without_orbital_strike), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(383410, talent_alignment_with_orbital_strike), hud.powerUpGroup, nil, nil, nil, true)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(102560, talent_incarnation), hud.powerUpGroup, nil, nil, nil, true)
end

---@class ERADruidEclipse : ERACombatModule
---@field private hud DruidBalanceHUD
---@field private isHidden boolean
---@field private frame Frame
---@field private wrath1 Texture
---@field private wrath2 Texture
---@field private star1 Texture
---@field private star2 Texture
---@field private lastW integer
---@field private lastS integer
---@field private lastChange number
---@field private allHidden boolean
ERADruidEclipse = {}
ERADruidEclipse.__index = ERADruidEclipse
setmetatable(ERADruidEclipse, { __index = ERACombatModule })

---@param cFrame ERACombatFrame
---@param hud DruidBalanceHUD
---@return ERADruidEclipse
function ERADruidEclipse:Create(cFrame, hud)
    local x = {}
    setmetatable(x, ERADruidEclipse)
    ---@cast x ERADruidEclipse
    x:construct(cFrame, 0.5, 0.02, false, 1)
    x.hud = hud

    local width, height = hud:GetAvailableRectangleInCenter()
    local widthExt = 4 * width / 20
    local heightExt = 2 * widthExt
    if heightExt > height then
        heightExt = height
        widthExt = height / 2
    end
    if widthExt < 10 then
        self.isHidden = true
        return x
    end
    local widthInt = 0.75 * widthExt
    local heightInt = 2 * widthInt

    x.frame = CreateFrame("Frame", nil, UIParent)
    x.frame:SetSize(width, height)
    x.frame:SetPoint("CENTER")

    x.wrath1 = x.frame:CreateTexture()
    x.wrath1:SetSize(widthExt, heightExt)
    x.wrath1:SetPoint("CENTER", -8 * width / 20, 0)
    x.wrath1:SetTexture(450915)
    x.wrath2 = x.frame:CreateTexture()
    x.wrath2:SetSize(widthInt, heightInt)
    x.wrath2:SetPoint("CENTER", -4.5 * width / 20, 0)
    x.wrath2:SetTexture(450915)

    x.star1 = x.frame:CreateTexture()
    x.star1:SetSize(widthExt, heightExt)
    x.star1:SetPoint("CENTER", 8 * width / 20, 0)
    x.star1:SetTexture(450914)
    x.star1:SetTexCoord(1, 0, 0, 1)
    x.star2 = x.frame:CreateTexture()
    x.star2:SetSize(widthInt, heightInt)
    x.star2:SetPoint("CENTER", 4.5 * width / 20, 0)
    x.star2:SetTexture(450914)
    x.star2:SetTexCoord(1, 0, 0, 1)

    x.lastW = 2
    x.lastS = 2
    x.lastChange = 0
    x.allHidden = false

    return x
end

function ERADruidEclipse:ResetToIdle()
    self.frame:Show()
end

function ERADruidEclipse:SpecInactive(wasActive)
    if (wasActive) then
        self.frame:Hide()
    end
end

function ERADruidEclipse:UpdateIdle(t, elapsed)
    if self.isHidden then return end
    local changed = self:updateData(t)
    if changed then
        self.allHidden = false
        self:updateDisplay()
    elseif t - self.lastChange > 4 then
        if not self.allHidden then
            self.allHidden = true
            self.wrath1:Hide()
            self.wrath2:Hide()
            self.star1:Hide()
            self.star2:Hide()
        end
    end
end
function ERADruidEclipse:UpdateCombat(t, elapsed)
    if self.isHidden then return end
    local changed = self:updateData(t)
    if self.allHidden then
        self.allHidden = false
        self:updateDisplay()
    elseif changed then
        self:updateDisplay()
    end
end

function ERADruidEclipse:updateData(t)
    local changed = false
    if self.hud.starStacks.stacks ~= self.lastS then
        changed = true
        self.lastS = self.hud.starStacks.stacks
    end
    if self.hud.wrathStacks.stacks ~= self.lastW then
        changed = true
        self.lastW = self.hud.wrathStacks.stacks
    end
    if changed then
        self.lastChange = t
        return true
    else
        return false
    end
end

function ERADruidEclipse:updateDisplay()
    if self.hud.wrathStacks.stacks >= 1 then
        self.wrath1:Show()
        if self.hud.wrathStacks.stacks >= 2 then
            self.wrath2:Show()
        else
            self.wrath2:Hide()
        end
    else
        self.wrath1:Hide()
        self.wrath2:Hide()
    end
    if self.hud.starStacks.stacks >= 1 then
        self.star1:Show()
        if self.hud.starStacks.stacks >= 2 then
            self.star2:Show()
        else
            self.star2:Hide()
        end
    else
        self.star1:Hide()
        self.star2:Hide()
    end
end

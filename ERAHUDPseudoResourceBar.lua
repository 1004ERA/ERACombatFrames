---@class ERAHUD_PseudoResourceBar : ERAHUDResourceModule
---@field private __index unknown
---@field private bar Texture
---@field private text FontString
---@field private margin number
---@field value number
---@field max number
---@field getValue fun(this:ERAHUD_PseudoResourceBar, t:number, combat:boolean)
---@field getMax fun(this:ERAHUD_PseudoResourceBar, t:number, combat:boolean)
---@field DisplayUpdatedOverride fun(this:ERAHUD_PseudoResourceBar, t:number, combat:boolean)
---@field showEmptyOutOfCombat boolean
ERAHUD_PseudoResourceBar = {}
ERAHUD_PseudoResourceBar.__index = ERAHUD_PseudoResourceBar
setmetatable(ERAHUD_PseudoResourceBar, { __index = ERAHUDResourceModule })

---@param hud ERAHUD
---@param height number
---@param margin number
---@param r number
---@param g number
---@param b number
---@param showEmptyOutOfCombat boolean
---@param talent ERALIBTalent|nil
function ERAHUD_PseudoResourceBar:constructPseudoResource(hud, height, margin, r, g, b, showEmptyOutOfCombat, talent)
    self:constructModule(hud, height, talent)
    self.margin = margin
    self.showEmptyOutOfCombat = showEmptyOutOfCombat

    local background = self.frame:CreateTexture(nil, "BACKGROUND")
    background:SetColorTexture(0, 0, 0, 0.5)
    background:SetAllPoints()

    self.bar = self.frame:CreateTexture(nil, "ARTWORK")
    self.bar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", margin, -margin)
    self.bar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", margin, margin)
    self.bar:SetColorTexture(r, g, b, 1.0)
    self.bar:SetWidth(0)

    self.text = self.frame:CreateFontString(nil, "OVERLAY")
    ERALIB_SetFont(self.text, 16)
    self.text:SetPoint("LEFT", self.frame, "LEFT", 2 * margin, 0)
end

function ERAHUD_PseudoResourceBar:checkTalentOverride()
    return true
end

---@param combat boolean
---@param t number
function ERAHUD_PseudoResourceBar:updateData(t, combat)
    self.value = self:getValue(t, combat)
    self.max = self:getMax(t, combat)
end

---@param combat boolean
---@param t number
function ERAHUD_PseudoResourceBar:updateDisplay(t, combat)
    if self.value > 0 then
        local ratio = self.value / self.max
        if ratio > 1 then ratio = 1 end
        self.bar:SetWidth((self.hud.barsWidth - 2 * self.margin) * ratio)
        self:show()
    else
        if combat or self.showEmptyOutOfCombat then
            self.bar:SetWidth(0)
            self:show()
        else
            self:hide()
        end
    end
    self:DisplayUpdatedOverride(t, combat)
end
function ERAHUD_PseudoResourceBar:DisplayUpdatedOverride(t, combat)
end

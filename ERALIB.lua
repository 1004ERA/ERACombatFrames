function ERALIB_SetFont(fs, size)
    fs:SetFont("Fonts\\FRIZQT__.TTF", size, "THICKOUTLINE")
end

--------------------------------------------------------------------------------------------------------------------------------
-- TALENTS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERALIBTalent_all_talents = {}

ERALIBTalent = {}
ERALIBTalent.__index = ERALIBTalent

function ERALIBTalent:Create(talentID)
    return ERALIBTalentYes:create(talentID)
end

function ERALIBTalent:CreateRank(talentID, rank)
    return ERALIBTalentRank:create(talentID, rank)
end

function ERALIBTalent:CreateLevel(lvl)
    return ERALIBTalentLevel:create(lvl)
end

function ERALIBTalent:CreateInstance(iid)
    return ERALIBTalentInstance:create(iid)
end

function ERALIBTalent:CreateNotTalent(talentID, lvl)
    return ERALIBTalentNotTalent:create(talentID, lvl)
end

function ERALIBTalent:CreateNot(cdt)
    return ERALIBTalentNot:create(cdt)
end

function ERALIBTalent:CreateAnd(...)
    return ERALIBTalentAnd:create(...)
end

function ERALIBTalent:CreateOr(...)
    return ERALIBTalentOr:create(...)
end

function ERALIBTalent:CreateCount(count, ...)
    return ERALIBTalentCount:create(count, ...)
end

function ERALIBTalent:CreateXOR(t1, t2)
    return ERALIBTalentXOR:create(t1, t2)
end

function ERALIBTalent:CreateNOR(t1, t2)
    return ERALIBTalentNOR:create(t1, t2)
end

function ERALIBTalent_MakeAnd(t1, t2)
    if (t1) then
        if (t2) then
            if (t1 == t2) then
                return t1
            else
                return ERALIBTalentAnd:create(t1, t2)
            end
        else
            return t1
        end
    else
        if (t2) then
            return t2
        else
            return nil
        end
    end
end

function ERALIBTalent:PlayerHasTalent()
    return self.talentActive
end

function ERALIBTalent:construct()
    table.insert(ERALIBTalent_all_talents, self)
end

function ERALIBTalent:update(selectedTalentsById)
    self.talentActive = self:computeHasTalent(selectedTalentsById)
end

-- abstract function computeHasTalent()

ERALIBTalentLevel = {}
ERALIBTalentLevel.__index = ERALIBTalentLevel
setmetatable(ERALIBTalentLevel, { __index = ERALIBTalent })
function ERALIBTalentLevel:create(lvl)
    local t = {}
    setmetatable(t, ERALIBTalentLevel)
    t.lvl = lvl
    t:construct()
    return t
end

function ERALIBTalentLevel:computeHasTalent(selectedTalentsById)
    return self.lvl <= UnitLevel("player")
end

ERALIBTalentInstance = {}
ERALIBTalentInstance.__index = ERALIBTalentInstance
setmetatable(ERALIBTalentInstance, { __index = ERALIBTalent })
function ERALIBTalentInstance:create(iid)
    local t = {}
    setmetatable(t, ERALIBTalentInstance)
    t.iid = iid
    t:construct()
    return t
end

function ERALIBTalentInstance:computeHasTalent(selectedTalentsById)
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
    return instanceID == self.iid
end

ERALIBTalentYes = {}
ERALIBTalentYes.__index = ERALIBTalentYes
setmetatable(ERALIBTalentYes, { __index = ERALIBTalent })
function ERALIBTalentYes:create(talentID)
    local t = {}
    setmetatable(t, ERALIBTalentYes)
    t.talentID = talentID
    t.rank = 0
    t:construct()
    return t
end

function ERALIBTalentYes:computeHasTalent(selectedTalentsById)
    local rank = selectedTalentsById[self.talentID]
    if (rank and rank > 0) then
        self.rank = rank
        return true
    else
        self.rank = 0
        return false
    end
end

ERALIBTalentRank = {}
ERALIBTalentRank.__index = ERALIBTalentRank
setmetatable(ERALIBTalentRank, { __index = ERALIBTalent })
function ERALIBTalentRank:create(talentID, targetRank)
    local t = {}
    setmetatable(t, ERALIBTalentYes)
    t.talentID = talentID
    t.rank = 0
    t.targetRank = targetRank
    t:construct()
    return t
end

function ERALIBTalentRank:computeHasTalent(selectedTalentsById)
    local rank = selectedTalentsById[self.talentID]
    if (rank and rank > 0) then
        self.rank = rank
        return rank == self.targetRank
    else
        self.rank = 0
        return self.targetRank == 0
    end
end

ERALIBTalentNotTalent = {}
ERALIBTalentNotTalent.__index = ERALIBTalentNotTalent
setmetatable(ERALIBTalentNotTalent, { __index = ERALIBTalent })
function ERALIBTalentNotTalent:create(talentID, lvl)
    local t = {}
    setmetatable(t, ERALIBTalentNotTalent)
    t.talentID = talentID
    t.rank = 0
    t.lvl = lvl
    t:construct()
    return t
end

function ERALIBTalentNotTalent:computeHasTalent(selectedTalentsById)
    local rank = selectedTalentsById[self.talentID]
    if (rank and rank > 0) then
        self.rank = rank
    else
        self.rank = 0
    end
    if (self.lvl and self.lvl > UnitLevel("player")) then
        return false
    else
        return self.rank <= 0
    end
end

ERALIBTalentNot = {}
ERALIBTalentNot.__index = ERALIBTalentNot
setmetatable(ERALIBTalentNot, { __index = ERALIBTalent })
function ERALIBTalentNot:create(cdt)
    local t = {}
    setmetatable(t, ERALIBTalentNot)
    t.cdt = cdt
    t:construct()
    return t
end

function ERALIBTalentNot:computeHasTalent(selectedTalentsById)
    return not self.cdt:computeHasTalent(selectedTalentsById)
end

ERALIBTalentAnd = {}
ERALIBTalentAnd.__index = ERALIBTalentAnd
setmetatable(ERALIBTalentAnd, { __index = ERALIBTalent })
function ERALIBTalentAnd:create(...)
    local t = {}
    setmetatable(t, ERALIBTalentAnd)
    t.conditions = { ... }
    t:construct()
    return t
end

function ERALIBTalentAnd:computeHasTalent(selectedTalentsById)
    for i, t in ipairs(self.conditions) do
        if (not t:computeHasTalent(selectedTalentsById)) then
            return false
        end
    end
    return true
end

ERALIBTalentOr = {}
ERALIBTalentOr.__index = ERALIBTalentOr
setmetatable(ERALIBTalentOr, { __index = ERALIBTalent })
function ERALIBTalentOr:create(...)
    local t = {}
    setmetatable(t, ERALIBTalentOr)
    t.conditions = { ... }
    t:construct()
    return t
end

function ERALIBTalentOr:computeHasTalent(selectedTalentsById)
    for i, t in ipairs(self.conditions) do
        if (t:computeHasTalent(selectedTalentsById)) then
            return true
        end
    end
    return false
end

ERALIBTalentCount = {}
ERALIBTalentCount.__index = ERALIBTalentCount
setmetatable(ERALIBTalentCount, { __index = ERALIBTalent })
function ERALIBTalentCount:create(count, ...)
    local t = {}
    setmetatable(t, ERALIBTalentCount)
    t.conditions = { ... }
    t.count = count
    t:construct()
    return t
end

function ERALIBTalentCount:computeHasTalent(selectedTalentsById)
    local cpt = 0
    for i, t in ipairs(self.conditions) do
        if (t:computeHasTalent(selectedTalentsById)) then
            cpt = cpt + 1
        end
    end
    return cpt == self.count
end

ERALIBTalentXOR = {}
ERALIBTalentXOR.__index = ERALIBTalentXOR
setmetatable(ERALIBTalentXOR, { __index = ERALIBTalent })
function ERALIBTalentXOR:create(t1, t2)
    local t = {}
    setmetatable(t, ERALIBTalentXOR)
    t.t1 = t1
    t.t2 = t2
    t:construct()
    return t
end

function ERALIBTalentXOR:computeHasTalent(selectedTalentsById)
    local t1v = self.t1:computeHasTalent(selectedTalentsById)
    local t2v = self.t2:computeHasTalent(selectedTalentsById)
    return (t1v or t2v) and not (t1v and t2v)
end

ERALIBTalentNOR = {}
ERALIBTalentNOR.__index = ERALIBTalentNOR
setmetatable(ERALIBTalentNOR, { __index = ERALIBTalent })
function ERALIBTalentNOR:create(t1, t2)
    local t = {}
    setmetatable(t, ERALIBTalentNOR)
    t.t1 = t1
    t.t2 = t2
    t:construct()
    return t
end

function ERALIBTalentNOR:computeHasTalent(selectedTalentsById)
    local t1v = self.t1:computeHasTalent(selectedTalentsById)
    local t2v = self.t2:computeHasTalent(selectedTalentsById)
    return not (t1v or t2v)
end

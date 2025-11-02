local Helpers = {}

function Helpers:TableCombine(tbl1, ...)
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            tbl1[k] = v
        end
    end
end

function Helpers:TableOverwrite(orig, overwrite)
    local tbl = {}
    for k,v in pairs(orig) do
        tbl[k] = v
    end
    for k,v in pairs(overwrite) do
        tbl[k] = v
    end
    return tbl
end

function Helpers:Weld(p1: BasePart, p2: BasePart): WeldConstraint
	local weld = Instance.new("WeldConstraint")
	weld.Name = p1.Name .. "Weld"
	weld.Part0 = p1
	weld.Part1 = p2
	weld.Parent = p1
	return weld
end

function Helpers:ToConfigTable(folder)
    assert(folder:IsA("Folder"), "foldeer attempted to be converted into config, but wasn't a folder... idiot....")
    local cfg = {}
    for _, v in pairs(folder:GetChildren()) do
        cfg[v.Name] = v.Value
    end
    return cfg
end

function Helpers:Switch(value)
    return function(cases)
        return (cases[value] or cases.default)(value)
    end
end

function Helpers:GenInaccuracy(value)
    value *= 100000
    local inaccX = math.random(-value, value) / 100000
    local inaccY = math.random(-value, value) / 100000
    local inaccZ = math.random(-value, value) / 100000
    return CFrame.Angles(math.rad(inaccX), math.rad(inaccY), math.rad(inaccZ))
end

return Helpers
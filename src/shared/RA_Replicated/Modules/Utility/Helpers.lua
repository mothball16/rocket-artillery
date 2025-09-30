local Helpers = {}

-- (tbl1, ...)
function Helpers:TableCombine(tbl1, ...)
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            tbl1[k] = v
        end
    end
end

-- (p1: BasePart, p2: BasePart)
function Helpers:Weld(p1: BasePart, p2: BasePart): WeldConstraint
	local weld = Instance.new("WeldConstraint")
	weld.Name = p1.Name .. "Weld"
	weld.Part0 = p1
	weld.Part1 = p2
	weld.Parent = p1
	return weld
end

-- (tbl, main, required)
function Helpers:ExecuteClient(tbl, main, required)
    for _, v in pairs(tbl) do
        if v["ExecuteClient"] then
            v:ExecuteClient(main, required)
        else
            v:Execute(main, required)
        end
    end
end

-- (tbl, main, required)
function Helpers:ExecuteServer(tbl, main, required)
    for _, v in pairs(tbl) do
        if v["ExecuteServer"] then
            v:ExecuteServer(main, required)
        else
            v:Execute(main, required)
        end
    end
end

function Helpers:ToConfigTable(folder)
    assert(folder:IsA("Folder"), "pass a folder to Helpers:ToConfigTable()!!!")
    local cfg = {}
    for _, v in pairs(folder:GetChildren()) do
        cfg[v.Name] = v.Value
    end
    return cfg
end

return Helpers
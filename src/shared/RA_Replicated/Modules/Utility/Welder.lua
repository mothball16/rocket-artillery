-- some module from the toolbox for easy welding

local Welder = {}

--- simple func to weld one part to another.
--- @param p1 BasePart: The origin part. NOTE: The weld will be parented here
--- @param p2 BasePart: The target part. 
--- @return WeldConstraint
function Welder:Weld(p1: BasePart, p2: BasePart): WeldConstraint
	local weld = Instance.new("WeldConstraint")
	weld.Name = p1.Name .. "Weld"
	weld.Part0 = p1
	weld.Part1 = p2
	weld.Parent = p1
	return weld
end

-- (model)
function Welder:WeldM(model)
	if model:IsA("Model") then
		if model.PrimaryPart ~= nil then
			for _, descendant in pairs(model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if descendant ~= model.PrimaryPart then
						local weld = Instance.new("WeldConstraint")
						weld.Name = model.PrimaryPart.Name
						weld.Part0 = model.PrimaryPart
						weld.Part1 = descendant
						weld.Parent = descendant
					end
				end
			end
			
			for _, descendant in pairs(model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Anchored = false
				end
			end
		else
			warn("Model must have a PrimaryPart.")
		end
	elseif model:IsA("Tool") then
		local handle = model:FindFirstChild("Handle")
		
		if handle then
			if handle:IsA("BasePart") then
				for _, descendant in pairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if descendant ~= handle then
							local weld = Instance.new("WeldConstraint")
							weld.Name = handle.Name
							weld.Part0 = handle
							weld.Part1 = descendant
							weld.Parent = descendant
						end
					end
				end
				
				for _, descendant in pairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.Anchored = false
					end
				end
			else
				warn("Handle must be a BasePart")
			end
		else
			warn("Tool must have a Handle.")
		end
	else
		warn("Object must be a Model or a Tool.")
	end
end

-- (model)
function Welder:UnweldM(model)
	if model:IsA("Model") then
		if model.PrimaryPart ~= nil then
			for _, descendant in pairs(model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					local weld = descendant:FindFirstChildWhichIsA("WeldConstraint")
					
					if weld then
						if weld.Name == model.PrimaryPart.Name then
							weld:Destroy()
						end
					end
				end
			end
		else
			warn("Model must have a PrimaryPart.")
		end
	elseif model:IsA("Tool") then
		local handle = model:FindFirstChild("Handle")
		
		if handle then
			if handle:IsA("BasePart") then
				for _, descendant in pairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") then
						local weld = descendant:FindFirstChildWhichIsA("WeldConstraint")
						
						if weld then
							if weld.Name == "Handle" then
								weld:Destroy()
							end
						end
					end
				end
			else
				warn("Handle must be a BasePart")
			end
		else
			warn("Tool must have a Handle.")
		end
	else
		warn("Object must be a Model or a Tool.")
	end
end

-- (model)
function Welder:WeldKeepAnchoredState(model)
	if model:IsA("Model") then
		if model.PrimaryPart ~= nil then
			for _, descendant in pairs(model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if descendant ~= model.PrimaryPart then
						local weld = Instance.new("WeldConstraint")
						weld.Name = model.PrimaryPart.Name
						weld.Part0 = model.PrimaryPart
						weld.Part1 = descendant
						weld.Parent = descendant
					end
				end
			end
		else
			warn("Model must have a PrimaryPart")
		end
	elseif model:IsA("Tool") then
		local handle = model:FindFirstChild("Handle")
		
		if handle then
			if handle:IsA("BasePart") then
				for _, descendant in pairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if descendant ~= handle then
							local weld = Instance.new("WeldConstraint")
							weld.Name = handle.Name
							weld.Part0 = handle
							weld.Part1 = descendant
							weld.Parent = descendant
						end
					end
				end
			else
				warn("Handle must be a BasePart")
			end
		else
			warn("Tool must have a Handle.")
		end
	else
		warn("Object must be a Model or a Tool.")
	end
end

return Welder
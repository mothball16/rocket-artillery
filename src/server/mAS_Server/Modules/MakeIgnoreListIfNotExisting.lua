-- literally just makes a folder named IgnoreList if not already made
-- this is to make this whole thing more portable instead of having to drag stuff out
-- for no-code friendly setup


return function()
    if not game.Workspace:FindFirstChild("IgnoreList") then
        local f = Instance.new("Folder", game.Workspace)
        f.Name = "IgnoreList"
    end
end
--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local ProjectileRegistry = require(dir.Modules.Core.ProjectileRegistry)
local validator = dir.Validator.new(script.Name)
local template = dir.Assets.UI.RangeSheet_Looseleaf
--#endregion required
--[[
doesn't calculate for you, but gives you dists from theta 0 to 45.
]]

-- this is cached outside so that each projectile type won't be calculated more than once
local dataByProjectileType = {}
local RangeSheet = {}
RangeSheet.__index = RangeSheet
export type RangeSheet = {
    rangeSheet: {
        name: string,
        ranges: { { Angle: number, Magnitude: number, Lifetime: number } },
    },
    maid: typeof(dir.Maid),
    ui: ScreenGui,

    Toggle: (self: RangeSheet) -> (),
    Display: (self: RangeSheet) -> (),
    Hide: (self: RangeSheet) -> (),
    Destroy: (self: RangeSheet) -> (),
}

local function _checkArgs(args)
    local controller = validator:Exists(args.controller, "controller type")
    validator:Exists(controller.Simulate, "simulate method of controller")
    local projectileName = validator:Exists(args.projectile)

    local rangeSheet = dataByProjectileType[projectileName]
    if not rangeSheet then
        local config = ProjectileRegistry:GetProjectile(projectileName).Config
        local flightPath = validator:Exists(config.FlightPathArgs, "flight path of projectile")
        
        dataByProjectileType[projectileName] = {
            ["name"] = config.name or "<unnnamed>",
            ["ranges"] = {}
        }
        for i = 0, 45, 1 do
            local theta = math.rad(i)
            local simFire = Vector3.new(0, math.sin(theta), math.cos(theta)).Unit
            --print(simFire)
            local mag, life = controller:Simulate(flightPath, simFire)
            table.insert(dataByProjectileType[projectileName]["ranges"], {
                Angle = i,
                Magnitude = mag,
                Lifetime = life
            })
            --print(mag, life)
        end
        rangeSheet = dataByProjectileType[projectileName]
    end

    return rangeSheet
end

function RangeSheet.new(args, required)
    local self = setmetatable({}, RangeSheet) :: RangeSheet
    self.rangeSheet = _checkArgs(args)
    self.maid = dir.Maid.new()
    self.open = false
    return self
end

function RangeSheet:Toggle()
    if self.open then
       self:Hide()
    else
        self:Display()
    end
end

function RangeSheet:Display()
    self.open = true
    self.ui = template:Clone()
    self.ui.Main.Desc.Text = self.rangeSheet.name
    for _, v in pairs(self.rangeSheet.ranges) do
        local rangeTemplate = self.ui.Main.RangeTemplate:Clone()
        rangeTemplate.Text = tostring(v.Angle) .. "° -> " .. tostring(math.floor(v.Magnitude))
        rangeTemplate.Parent = self.ui.Main.Ranges
        rangeTemplate.Visible = true
    end
    self.ui.Parent = game.Players.LocalPlayer.PlayerGui
end

function RangeSheet:Hide()
    self.open = false
    self.ui:Destroy()
end

function RangeSheet:Destroy()
    if self.ui then self.ui:Destroy() end
    self.maid:DoCleaning()
end

return RangeSheet
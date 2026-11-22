local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Montagem da Casa 27. A ordem constrói primeiro a casca e depois os
    ambientes, mantendo tudo dentro de um único Model chamado "Casa27".
]]

local Kit = require("./Kit")
local Layout = require("./Layout")
local Architecture = require("./Architecture")
local Kitchen = require("./Kitchen")
local Living = require("./Living")
local Bedroom = require("./Bedroom")
local Bathroom = require("./Bathroom")
local Dining = require("./Dining")
local Entry = require("./Entry")
local Exterior = require("./Exterior")

local House = {}

local function addSpawn(root: Instance)
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Spawn da entrada"
    spawn.Size = Vector3.new(3.2, 0.4, 3.2)
    spawn.CFrame = CFrame.lookAt(
        Layout.spawn.position,
        Vector3.new(Layout.spawn.lookAt.X, Layout.spawn.position.Y, Layout.spawn.lookAt.Z)
    )
    spawn.Anchored = true
    spawn.CanCollide = false
    spawn.CanQuery = false
    spawn.CanTouch = false
    spawn.Transparency = 1
    spawn.Neutral = true
    spawn.Enabled = true
    spawn.Duration = 0
    spawn.TopSurface = Enum.SurfaceType.Smooth
    spawn.BottomSurface = Enum.SurfaceType.Smooth
    spawn.Parent = root
    return spawn
end

function House.build(parent: Instance?): Model
    local root = Architecture.build(parent)
    root.Name = "Casa27"

    local ambient = Kit.folder(root, "Ambientes")
    Living.build(ambient)
    Kitchen.build(ambient)
    Bedroom.build(ambient)
    Bathroom.build(ambient)
    Dining.build(ambient)
    Entry.build(ambient)
    Exterior.build(root)

    addSpawn(root)

    -- Metadados úteis para quem for continuar a casa no Studio.
    root:SetAttribute("AreaInternaM2", 44)
    root:SetAttribute("EscalaStudsPorMetro", Layout.studsPerMeter)
    root:SetAttribute("AlturaDoPeDireitoStuds", Layout.height)
    root:SetAttribute("Versao", "1.0.0")

    return root
end

return House

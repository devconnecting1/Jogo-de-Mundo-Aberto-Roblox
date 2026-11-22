local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

local Kit = require("./Kit")
local Layout = require("./Layout")
local Architecture = require("./Architecture")
local Hall = require("./Hall")
local Cells = require("./Cells")
local Refeitorio = require("./Refeitorio")
local Cozinha = require("./Cozinha")
local Lavanderia = require("./Lavanderia")
local Enfermaria = require("./Enfermaria")
local Visitas = require("./Visitas")
local Triagem = require("./Triagem")
local Administracao = require("./Administracao")
local Biblioteca = require("./Biblioteca")
local Capela = require("./Capela")
local Oficina = require("./Oficina")
local Patio = require("./Patio")
local Grounds = require("./Grounds")

--[[
    Presídio Central.
    Um showcase estático de arquitetura prisional clássica, com três
    pavimentos, 28 celas nas galerias, duas celas de triagem, refeitório,
    cozinha, lavanderia, enfermaria, administração, biblioteca, capela,
    oficina, pátio murado e torre de vigia.

    O modelo é 100% Parts retangulares. Não há NPCs, scripts, interfaces de
    gameplay, veículos ou assets de terceiros.
]]

local Prison = {}

local function addSpawn(root: Instance)
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Spawn da entrada"
    spawn.Size = Vector3.new(3.4, 0.4, 3.4)
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
    spawn.Shape = Enum.PartType.Block
    spawn.Parent = root
    return spawn
end

function Prison.build(parent: Instance?): Model
    local root = Architecture.build(parent)
    root.Name = Layout.name

    local ambient = Kit.folder(root, "Ambientes")
    Hall.build(ambient)
    Cells.build(ambient)
    Cozinha.build(ambient)
    Lavanderia.build(ambient)
    Enfermaria.build(ambient)
    Visitas.build(ambient)
    Triagem.build(ambient)
    Administracao.build(ambient)
    Biblioteca.build(ambient)
    Capela.build(ambient)
    Oficina.build(ambient)
    Refeitorio.build(ambient)

    local exterior = Kit.folder(root, "Exterior")
    Grounds.build(exterior)
    Patio.build(ambient, exterior)

    addSpawn(root)

    root:SetAttribute("Pavimentos", 3)
    root:SetAttribute("Celas", 28)
    root:SetAttribute("CelasDeTriagem", 2)
    root:SetAttribute("RefeitorioLugares", 48)
    root:SetAttribute("AreaEdificioM2", math.floor(Layout.areaCellHouseM2 * 3))
    root:SetAttribute("AreaRefeitorioM2", math.floor(Layout.areaRefeitorioM2))
    root:SetAttribute("AreaPatioM2", math.floor(Layout.areaYardM2))
    root:SetAttribute("AreaTerrenoM2", math.floor(Layout.areaSiteM2))
    root:SetAttribute("EscalaStudsPorMetro", Layout.studsPerMeter)
    root:SetAttribute("Versao", "1.0.0")
    root:SetAttribute(
        "Descricao",
        "Complexo prisional clássico em três pavimentos, somente Parts retangulares."
    )
    return root
end

return Prison

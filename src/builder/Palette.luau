local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Casa 27 — paleta material
    Toda a casa usa uma paleta fechada para manter coerência entre os cômodos.
    As cores são propositalmente dessaturadas, como materiais naturais sob luz quente.
]]

local Palette = {}

local function rgb(r: number, g: number, b: number): Color3
    return Color3.fromRGB(r, g, b)
end

-- Arquitetura ---------------------------------------------------------------
Palette.Plaster = rgb(226, 214, 197)
Palette.PlasterWarm = rgb(234, 223, 207)
Palette.PlasterCool = rgb(215, 214, 202)
Palette.CeilingPaint = rgb(240, 234, 222)
Palette.Trim = rgb(241, 233, 219)
Palette.TrimShadow = rgb(222, 211, 193)
Palette.BathPaint = rgb(205, 213, 199)

-- Madeiras -----------------------------------------------------------------
Palette.Oak = rgb(170, 119, 75)
Palette.OakLight = rgb(191, 144, 98)
Palette.OakPale = rgb(207, 166, 120)
Palette.OakDark = rgb(128, 86, 54)
Palette.Walnut = rgb(104, 71, 49)
Palette.WalnutDeep = rgb(78, 52, 36)
Palette.WoodGrain = rgb(150, 105, 69)

-- Têxteis ------------------------------------------------------------------
Palette.Olive = rgb(100, 107, 83)
Palette.OliveDeep = rgb(74, 81, 61)
Palette.Sage = rgb(132, 143, 119)
Palette.SagePale = rgb(183, 192, 169)
Palette.Linen = rgb(214, 201, 178)
Palette.LinenLight = rgb(232, 222, 204)
Palette.Cream = rgb(244, 236, 221)
Palette.Clay = rgb(177, 107, 81)
Palette.Terracotta = rgb(164, 88, 60)
Palette.Mustard = rgb(196, 150, 71)
Palette.Charcoal = rgb(53, 50, 45)
Palette.Ink = rgb(38, 35, 32)
Palette.Blush = rgb(207, 170, 150)

-- Cozinha ------------------------------------------------------------------
Palette.Cabinet = rgb(126, 139, 119)
Palette.CabinetHighlight = rgb(143, 154, 134)
Palette.CabinetShade = rgb(104, 118, 99)
Palette.Marble = rgb(230, 224, 210)
Palette.MarbleVein = rgb(196, 191, 179)
Palette.TileCream = rgb(220, 211, 195)
Palette.TileSage = rgb(157, 169, 147)
Palette.TileOlive = rgb(112, 124, 104)
Palette.Grout = rgb(177, 169, 153)
Palette.Brass = rgb(180, 140, 77)
Palette.BrassDark = rgb(135, 99, 49)
Palette.Chrome = rgb(185, 190, 190)
Palette.Steel = rgb(127, 132, 130)
Palette.SteelDark = rgb(82, 85, 83)
Palette.BlackGlass = rgb(35, 36, 34)
Palette.Enamel = rgb(240, 235, 223)

-- Louças e vegetação -------------------------------------------------------
Palette.CeramicWhite = rgb(241, 237, 227)
Palette.CeramicSpeckle = rgb(217, 209, 194)
Palette.CeramicClay = rgb(195, 137, 107)
Palette.CeramicBlue = rgb(124, 148, 151)
Palette.GlassClear = rgb(198, 215, 214)
Palette.GlassGreen = rgb(164, 187, 172)
Palette.GlassSmoke = rgb(95, 104, 101)
Palette.Water = rgb(154, 190, 190)
Palette.Leaf = rgb(74, 100, 62)
Palette.LeafLight = rgb(110, 133, 82)
Palette.LeafDeep = rgb(52, 76, 49)
Palette.LeafOlive = rgb(129, 141, 91)
Palette.Stem = rgb(87, 77, 54)
Palette.Soil = rgb(73, 57, 43)
Palette.Flower = rgb(199, 147, 135)

-- Exterior -----------------------------------------------------------------
Palette.Grass = rgb(98, 116, 80)
Palette.GrassDark = rgb(77, 96, 65)
Palette.Hedge = rgb(74, 95, 64)
Palette.Bark = rgb(91, 70, 53)
Palette.Stone = rgb(143, 136, 124)
Palette.StoneDark = rgb(103, 97, 88)
Palette.Path = rgb(184, 172, 151)
Palette.Exterior = rgb(126, 125, 108)

-- Materiais ----------------------------------------------------------------
Palette.Materials = {
    plaster = Enum.Material.Plaster,
    paint = Enum.Material.SmoothPlastic,
    wood = Enum.Material.Wood,
    planks = Enum.Material.WoodPlanks,
    marble = Enum.Material.Marble,
    tile = Enum.Material.CeramicTiles,
    fabric = Enum.Material.Fabric,
    carpet = Enum.Material.Carpet,
    metal = Enum.Material.Metal,
    glass = Enum.Material.Glass,
    neon = Enum.Material.Neon,
    ceramic = Enum.Material.SmoothPlastic,
    grass = Enum.Material.Grass,
    leaf = Enum.Material.SmoothPlastic,
    concrete = Enum.Material.Concrete,
    slate = Enum.Material.Slate,
    brick = Enum.Material.Brick,
}

return Palette

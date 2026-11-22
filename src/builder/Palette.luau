local Compat = require("./Compat")
local Color3 = Compat.Color3
local Enum = Compat.Enum

--[[
    Presídio Central — paleta material.
    A construção é clássica e institucional: cantaria de calcário, tijolo
    escuro, ferro fundido preto, madeira de lei e pintura verde de repartição.
    A paleta é fechada e dessaturada para o conjunto parecer um só edifício.
]]

local Palette = {}

local function rgb(r: number, g: number, b: number): Color3
    return Color3.fromRGB(r, g, b)
end

-- Cantaria e alvenaria ------------------------------------------------------
Palette.Stone = rgb(196, 188, 170)
Palette.StoneLight = rgb(219, 212, 196)
Palette.StoneDark = rgb(160, 152, 136)
Palette.StoneBase = rgb(174, 166, 150)
Palette.StoneWarm = rgb(205, 194, 174)
Palette.Brick = rgb(139, 94, 75)
Palette.BrickDark = rgb(112, 73, 58)
Palette.RoofSlate = rgb(69, 74, 75)
Palette.RoofSlateLight = rgb(87, 92, 92)

-- Pintura institucional -----------------------------------------------------
Palette.Paint = rgb(231, 225, 210)
Palette.PaintWarm = rgb(238, 232, 218)
Palette.PaintShadow = rgb(207, 200, 184)
Palette.Ceiling = rgb(240, 236, 225)
Palette.Green = rgb(71, 91, 77)
Palette.GreenDark = rgb(50, 67, 57)
Palette.GreenLight = rgb(92, 112, 94)
Palette.Ochre = rgb(170, 133, 76)
Palette.OchreDark = rgb(132, 100, 54)

-- Ferro, aço e latão --------------------------------------------------------
Palette.Iron = rgb(43, 46, 44)
Palette.IronLight = rgb(61, 64, 61)
Palette.Steel = rgb(116, 121, 118)
Palette.SteelLight = rgb(156, 161, 157)
Palette.SteelDark = rgb(77, 81, 79)
Palette.Brass = rgb(163, 128, 70)
Palette.BrassDark = rgb(119, 90, 46)
Palette.Rust = rgb(125, 78, 56)

-- Madeiras ------------------------------------------------------------------
Palette.Oak = rgb(119, 86, 55)
Palette.OakLight = rgb(148, 109, 70)
Palette.OakDark = rgb(82, 57, 37)
Palette.Walnut = rgb(72, 50, 34)
Palette.WalnutDeep = rgb(54, 38, 27)
Palette.Plywood = rgb(158, 121, 80)

-- Pisos e revestimentos -----------------------------------------------------
Palette.Marble = rgb(221, 216, 203)
Palette.Concrete = rgb(163, 160, 151)
Palette.Wood = rgb(119, 86, 55)
Palette.Terrazzo = rgb(186, 180, 165)
Palette.TerrazzoLight = rgb(207, 201, 187)
Palette.TerrazzoDark = rgb(132, 129, 119)
Palette.TileCream = rgb(215, 208, 192)
Palette.TileGray = rgb(138, 139, 132)
Palette.TileDark = rgb(86, 89, 85)
Palette.TileWhite = rgb(232, 229, 220)
Palette.Grout = rgb(174, 170, 158)
Palette.Carpet = rgb(101, 92, 76)
Palette.CarpetDark = rgb(78, 70, 58)

-- Vidro e iluminação --------------------------------------------------------
Palette.Glass = rgb(173, 198, 200)
Palette.GlassFrost = rgb(202, 214, 211)
Palette.GlassColored = rgb(154, 174, 143)
Palette.GlassAmber = rgb(190, 159, 109)
Palette.GlassSmoke = rgb(90, 103, 102)
Palette.NeonWarm = rgb(255, 216, 164)
Palette.NeonCool = rgb(211, 228, 237)
Palette.NeonGreen = rgb(194, 219, 186)

-- Têxteis e objetos ---------------------------------------------------------
Palette.Linen = rgb(225, 220, 205)
Palette.LinenWhite = rgb(240, 237, 229)
Palette.BlanketRust = rgb(143, 86, 61)
Palette.BlanketOlive = rgb(96, 103, 75)
Palette.BlanketNavy = rgb(63, 76, 94)
Palette.BlanketGrey = rgb(123, 125, 117)
Palette.Leather = rgb(102, 69, 46)
Palette.Paper = rgb(226, 218, 198)
Palette.BookRed = rgb(119, 61, 53)
Palette.BookGreen = rgb(74, 93, 70)
Palette.BookBlue = rgb(66, 80, 102)
Palette.BookTan = rgb(155, 126, 86)
Palette.Ceramic = rgb(231, 228, 219)
Palette.CeramicBlue = rgb(129, 150, 156)
Palette.Water = rgb(145, 178, 180)
Palette.MetalTray = rgb(149, 153, 148)
Palette.Terracotta = rgb(160, 93, 66)
Palette.Leaf = rgb(74, 100, 62)
Palette.LeafLight = rgb(110, 133, 82)
Palette.Stem = rgb(87, 77, 54)

-- Exterior ------------------------------------------------------------------
Palette.Grass = rgb(87, 103, 70)
Palette.GrassDark = rgb(71, 87, 60)
Palette.Hedge = rgb(66, 84, 58)
Palette.Leafless = rgb(93, 78, 61)
Palette.Gravel = rgb(154, 148, 134)
Palette.Asphalt = rgb(86, 87, 82)
Palette.Path = rgb(188, 179, 162)
Palette.Soil = rgb(90, 76, 59)

-- Materiais ----------------------------------------------------------------
Palette.Materials = {
    stone = Enum.Material.Limestone,
    stoneBlock = Enum.Material.Concrete,
    stoneSmooth = Enum.Material.SmoothPlastic,
    brick = Enum.Material.Brick,
    plaster = Enum.Material.Plaster,
    paint = Enum.Material.SmoothPlastic,
    plastic = Enum.Material.SmoothPlastic,
    concrete = Enum.Material.Concrete,
    pavement = Enum.Material.Pavement,
    slate = Enum.Material.Slate,
    roof = Enum.Material.RoofShingles,
    wood = Enum.Material.Wood,
    planks = Enum.Material.WoodPlanks,
    metal = Enum.Material.Metal,
    iron = Enum.Material.CorrodedMetal,
    steel = Enum.Material.Metal,
    diamond = Enum.Material.DiamondPlate,
    glass = Enum.Material.Glass,
    neon = Enum.Material.Neon,
    ceramic = Enum.Material.CeramicTiles,
    marble = Enum.Material.Marble,
    fabric = Enum.Material.Fabric,
    carpet = Enum.Material.Carpet,
    grass = Enum.Material.Grass,
    ground = Enum.Material.Ground,
    gravel = Enum.Material.Pebble,
    asphalt = Enum.Material.Asphalt,
    leather = Enum.Material.Leather,
    paper = Enum.Material.SmoothPlastic,
}

return Palette

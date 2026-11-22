local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Canto de jantar: mesa redonda de nogueira para duas pessoas, cadeiras de
    palhinha, pendente de linho, aparato de mesa e uma estante aberta que faz
    a transição entre a área social e o quarto.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")
local Layout = require("./Layout")

local Dining = {}

local TABLE_X = Layout.dining.centerX
local TABLE_Z = Layout.dining.centerZ

local function buildRug(parent: Instance)
    local model = Kit.model(parent, "Tapete de jantar")
    Kit.cylinder(
        model,
        "Tapete redondo",
        CFrame.new(TABLE_X, 0.035, TABLE_Z),
        0.055,
        6.0,
        Palette.SagePale,
        Palette.Materials.carpet,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Borda do tapete",
        CFrame.new(TABLE_X, 0.068, TABLE_Z),
        0.02,
        5.5,
        Palette.Linen,
        Palette.Materials.carpet,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Centro do tapete",
        CFrame.new(TABLE_X, 0.078, TABLE_Z),
        0.015,
        4.9,
        Palette.Sage,
        Palette.Materials.carpet,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for side = -1, 1 do
        for fringe = 1, 20 do
            local angle = math.rad(18) + (fringe - 1) * math.rad(18)
            local x = TABLE_X + math.cos(angle) * 3.06
            local z = TABLE_Z + math.sin(angle) * 3.06
            Kit.box(
                model,
                "Franja",
                Kit.rotated(x, 0.03, z, 0, math.deg(angle), 0),
                Vector3.new(0.16, 0.02, 0.06),
                Palette.Linen,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

local function buildTable(parent: Instance)
    local model = Kit.model(parent, "Mesa de jantar")

    Kit.cylinder(
        model,
        "Tampo",
        CFrame.new(TABLE_X, 2.93, TABLE_Z),
        0.18,
        4.1,
        Palette.Walnut,
        Palette.Materials.wood,
        "y",
        { collide = true, query = true }
    )
    Kit.cylinder(
        model,
        "Borda do tampo",
        CFrame.new(TABLE_X, 3.04, TABLE_Z),
        0.07,
        4.18,
        Palette.OakDark,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Saia da mesa",
        CFrame.new(TABLE_X, 2.62, TABLE_Z),
        0.34,
        2.1,
        Palette.Walnut,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Pedestal",
        CFrame.new(TABLE_X, 1.35, TABLE_Z),
        2.5,
        0.42,
        Palette.Walnut,
        Palette.Materials.wood,
        "y",
        { collide = true, query = true }
    )
    for arm = 1, 4 do
        local angle = (arm - 1) * math.pi * 0.5 + math.pi * 0.25
        local x = TABLE_X + math.cos(angle) * 0.8
        local z = TABLE_Z + math.sin(angle) * 0.8
        Kit.rodBetween(
            model,
            "Pé da mesa",
            Vector3.new(TABLE_X, 0.28, TABLE_Z),
            Vector3.new(x, 0.28, z),
            0.18,
            Palette.WalnutDeep,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Sapatilha",
            CFrame.new(x, 0.14, z),
            0.16,
            0.3,
            Palette.BrassDark,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Louça e centerpiece.
    for _, sideX in { -1, 1 } do
        local placeX = TABLE_X + sideX * 1.33
        Kit.cylinder(
            model,
            "Prato de jantar",
            CFrame.new(placeX, 3.05, TABLE_Z),
            0.045,
            1.12,
            Palette.CeramicWhite,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Prato de sobremesa",
            CFrame.new(placeX, 3.085, TABLE_Z - 0.03),
            0.035,
            0.73,
            Palette.CeramicSpeckle,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Guardanapo",
            Kit.rotated(placeX, 3.1, TABLE_Z + 0.66, 0, sideX * 8, 0),
            Vector3.new(0.3, 0.02, 0.54),
            if sideX < 0 then Palette.Sage else Palette.Clay,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
        for cutlery = -1, 1, 2 do
            Kit.box(
                model,
                "Talher",
                CFrame.new(placeX + cutlery * 0.68, 3.09, TABLE_Z - 0.32),
                Vector3.new(0.035, 0.02, 0.68),
                Palette.Brass,
                Palette.Materials.metal,
                { collide = false, query = false, shadow = false }
            )
        end
        Kit.cylinder(
            model,
            "Taça de vinho",
            CFrame.new(placeX + 0.48, 3.3, TABLE_Z - 0.53),
            0.34,
            0.3,
            Palette.GlassClear,
            Palette.Materials.glass,
            "y",
            { collide = false, query = false, shadow = false, transparency = 0.72 }
        )
        Kit.cylinder(
            model,
            "Haste da taça",
            CFrame.new(placeX + 0.48, 3.12, TABLE_Z - 0.53),
            0.34,
            0.045,
            Palette.GlassClear,
            Palette.Materials.glass,
            "y",
            { collide = false, query = false, shadow = false, transparency = 0.72 }
        )
    end

    Kit.cylinder(
        model,
        "Vaso do centro",
        CFrame.new(TABLE_X, 3.38, TABLE_Z),
        0.62,
        0.46,
        Palette.CeramicBlue,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for flower = 1, 5 do
        local angle = flower * 1.42
        local height = 4.08 + (flower % 3) * 0.22
        local x = TABLE_X + math.cos(angle) * 0.32
        local z = TABLE_Z + math.sin(angle) * 0.32
        Kit.rodBetween(
            model,
            "Haste de flor",
            Vector3.new(TABLE_X, 3.55, TABLE_Z),
            Vector3.new(x, height, z),
            0.022,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Flor",
            CFrame.new(x, height, z),
            Vector3.new(0.23, 0.3, 0.23),
            if flower % 2 == 0 then Palette.Blush else Palette.Cream,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Vela do centro",
        CFrame.new(TABLE_X, 3.25, TABLE_Z + 0.9),
        0.34,
        0.28,
        Palette.Cream,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.sphere(
        model,
        "Chama da vela",
        CFrame.new(TABLE_X, 3.5, TABLE_Z + 0.9),
        Vector3.new(0.06, 0.17, 0.06),
        Color3.fromRGB(255, 189, 94),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildChair(parent: Instance, name: string, x: number, z: number, facing: number)
    local model = Kit.model(parent, name)
    local seatY = 1.52
    local width = 1.6
    local depth = 1.6

    Kit.box(
        model,
        "Assento",
        CFrame.new(x, seatY, z),
        Vector3.new(width, 0.16, depth),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Almofada da cadeira",
        CFrame.new(x, seatY + 0.15, z),
        Vector3.new(width - 0.18, 0.14, depth - 0.18),
        Palette.LinenLight,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    for _, side in { -1, 1 } do
        for _, depthSide in { -1, 1 } do
            Kit.cylinder(
                model,
                "Pé da cadeira",
                CFrame.new(
                    x + side * (width * 0.5 - 0.18),
                    0.77,
                    z + depthSide * (depth * 0.5 - 0.18)
                ),
                1.55,
                0.12,
                Palette.Walnut,
                Palette.Materials.wood,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Encosto curvo de ripas na parte de trás da cadeira.
    local backX = x - facing * (depth * 0.5 - 0.12)
    for slat = 1, 5 do
        local slatZ = z - width * 0.5 + 0.28 + (slat - 1) * (width - 0.56) / 4
        Kit.box(
            model,
            "Ripa do encosto",
            Kit.rotated(backX, 2.55, slatZ, -6, 0, 0),
            Vector3.new(0.09, 1.85, 0.11),
            Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Travessa superior do encosto",
        CFrame.new(backX, 3.48, z),
        Vector3.new(0.12, 0.2, width - 0.18),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Travessa inferior do encosto",
        CFrame.new(backX, 1.82, z),
        Vector3.new(0.1, 0.12, width - 0.18),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for _, side in { -1, 1 } do
        Kit.rodBetween(
            model,
            "Travessa do pé",
            Vector3.new(
                x + side * (width * 0.5 - 0.18),
                0.62,
                z - depth * 0.5 + 0.18
            ),
            Vector3.new(
                x + side * (width * 0.5 - 0.18),
                0.62,
                z + depth * 0.5 - 0.18
            ),
            0.07,
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    return model
end

local function buildPendant(parent: Instance)
    local model = Kit.model(parent, "Pendente de jantar")
    local x = TABLE_X
    local z = TABLE_Z

    Kit.cylinder(
        model,
        "Roseta",
        CFrame.new(x, 9.16, z),
        0.08,
        0.38,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cordão",
        CFrame.new(x, 8.28, z),
        1.8,
        0.04,
        Palette.Ink,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cúpula de linho",
        CFrame.new(x, 7.28, z),
        1.0,
        2.1,
        Palette.LinenLight,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Borda de latão",
        CFrame.new(x, 6.76, z),
        0.08,
        2.14,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local bulb = Kit.sphere(
        model,
        "Lâmpada",
        CFrame.new(x, 6.92, z),
        Vector3.new(0.28, 0.32, 0.28),
        Color3.fromRGB(255, 226, 180),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(bulb, Color3.fromRGB(255, 202, 139), {
        name = "Luz do jantar",
        brightness = 0.95,
        range = 11,
        shadows = false,
    })
    return model
end

local function buildBookcase(parent: Instance)
    local model = Kit.model(parent, "Estante da passagem")
    local x = 13.35
    local z = -0.3
    local height = 7.2
    local depth = 1.1
    local width = 3.4

    Kit.box(
        model,
        "Fundo da estante",
        CFrame.new(x + 0.42, height * 0.5 + 0.15, z),
        Vector3.new(0.1, height, width),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for _, sideZ in { -1, 1 } do
        Kit.box(
            model,
            "Lateral da estante",
            CFrame.new(x, height * 0.5 + 0.15, z + sideZ * width * 0.5),
            Vector3.new(depth, height, 0.18),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = true, query = true }
        )
    end
    for shelf = 0, 4 do
        local y = 0.38 + shelf * 1.42
        Kit.box(
            model,
            "Prateleira",
            CFrame.new(x, y, z),
            Vector3.new(depth, 0.14, width - 0.12),
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false }
        )
    end

    -- Livros em alturas, larguras e tons diferentes.
    local spineColors = {
        Palette.Clay,
        Palette.Olive,
        Palette.Cream,
        Palette.Mustard,
        Palette.CeramicBlue,
        Palette.Terracotta,
        Palette.Sage,
    }
    for row = 0, 3 do
        local shelfY = 0.38 + row * 1.42 + 0.11
        local cursorZ = z - width * 0.5 + 0.25
        local bookIndex = 1
        while cursorZ < z + width * 0.5 - 0.35 do
            local bookWidth = 0.13 + (bookIndex % 3) * 0.045
            local bookHeight = 0.9 + (bookIndex * 7 + row * 3) % 5 * 0.12
            local bookDepth = 0.72 + (bookIndex % 2) * 0.08
            local lean = if bookIndex % 9 == 0 then -8 else 0
            Kit.box(
                model,
                "Livro",
                Kit.rotated(
                    x - 0.08,
                    shelfY + bookHeight * 0.5,
                    cursorZ + bookWidth * 0.5,
                    0,
                    0,
                    lean
                ),
                Vector3.new(bookDepth, bookHeight, bookWidth),
                spineColors[(bookIndex + row) % #spineColors + 1],
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            Kit.box(
                model,
                "Páginas",
                Kit.rotated(
                    x + 0.32,
                    shelfY + bookHeight * 0.5,
                    cursorZ + bookWidth * 0.5,
                    0,
                    0,
                    lean
                ),
                Vector3.new(0.03, bookHeight - 0.1, bookWidth - 0.035),
                Palette.Cream,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            cursorZ += bookWidth + 0.035
            bookIndex += 1
        end
    end

    -- Objetos entre os livros.
    Kit.cylinder(
        model,
        "Vaso da estante",
        CFrame.new(x - 0.02, 5.34, z + 1.15),
        0.7,
        0.5,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for leaf = 1, 4 do
        Kit.sphere(
            model,
            "Planta da estante",
            CFrame.new(
                x - 0.02 + math.cos(leaf * 1.8) * 0.18,
                5.9 + (leaf % 2) * 0.2,
                z + 1.15 + math.sin(leaf * 1.8) * 0.18
            ) * CFrame.Angles(0, leaf * 1.2, math.rad(20)),
            Vector3.new(0.18, 0.48, 0.26),
            Palette.Leaf,
            Palette.Materials.leaf,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Prato na estante",
        CFrame.new(x - 0.02, 4.65, z - 1.4),
        0.05,
        0.7,
        Palette.CeramicSpeckle,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Vela na estante",
        CFrame.new(x - 0.02, 4.6, z - 0.35),
        0.5,
        0.2,
        Palette.Mustard,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Caixa na estante",
        CFrame.new(x - 0.02, 6.27, z + 1.0),
        Vector3.new(0.75, 0.48, 0.82),
        Palette.Linen,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    return model
end

local function buildArtAndPlant(parent: Instance)
    local model = Kit.model(parent, "Arte e planta do jantar")

    -- Gravura grande na parede leste.
    Kit.box(
        model,
        "Moldura da gravura",
        CFrame.new(13.94, 5.75, TABLE_Z + 0.25),
        Vector3.new(0.09, 2.35, 1.8),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Passe-partout",
        CFrame.new(13.88, 5.75, TABLE_Z + 0.25),
        Vector3.new(0.02, 2.06, 1.52),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Gravura",
        CFrame.new(13.865, 5.75, TABLE_Z + 0.25),
        Vector3.new(0.012, 1.8, 1.28),
        Palette.Linen,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    for shape = 1, 4 do
        Kit.sphere(
            model,
            "Forma botânica",
            CFrame.new(
                13.85,
                5.55 + (shape % 2) * 0.36,
                TABLE_Z + 0.1 + shape * 0.18
            ) * CFrame.Angles(0, 0, shape * 0.4),
            Vector3.new(0.012, 0.65, 0.22),
            if shape % 2 == 0 then Palette.Olive else Palette.Clay,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Planta de chão entre a estante e a mesa.
    Kit.cylinder(
        model,
        "Cachepô do jantar",
        CFrame.new(13.15, 0.6, 3.0),
        1.2,
        1.1,
        Palette.CeramicSpeckle,
        Palette.Materials.ceramic,
        "y",
        { collide = true, query = true }
    )
    Kit.cylinder(
        model,
        "Terra",
        CFrame.new(13.15, 1.17, 3.0),
        0.1,
        1.0,
        Palette.Soil,
        Palette.Materials.leaf,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for stem = 1, 4 do
        local angle = stem * 1.7
        local top = Vector3.new(13.15 + math.cos(angle) * 0.47, 4.0 + (stem % 2) * 0.4, 3.0 + math.sin(angle) * 0.47)
        Kit.rodBetween(
            model,
            "Caule do jantar",
            Vector3.new(13.15, 1.2, 3.0),
            top,
            0.05,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        for leaf = 1, 3 do
            Kit.sphere(
                model,
                "Folha do jantar",
                CFrame.new(
                    top.X + math.cos(angle + leaf) * 0.28,
                    top.Y + (leaf % 2) * 0.28,
                    top.Z + math.sin(angle + leaf) * 0.28
                ) * CFrame.Angles(math.rad(30), angle, math.rad(20)),
                Vector3.new(0.24, 0.7, 0.4),
                if leaf % 2 == 0 then Palette.LeafLight else Palette.LeafDeep,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    return model
end

function Dining.build(parent: Instance)
    local model = Kit.model(parent, "Jantar")
    buildRug(model)
    buildTable(model)
    buildChair(model, "Cadeira oeste", TABLE_X - 2.55, TABLE_Z, 1)
    buildChair(model, "Cadeira leste", TABLE_X + 2.55, TABLE_Z, -1)
    buildPendant(model)
    buildBookcase(model)
    buildArtAndPlant(model)
    return model
end

return Dining

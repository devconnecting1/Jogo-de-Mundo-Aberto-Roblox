local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Sala de estar: sofá de linho, mesa de centro, tapete, parede ripada de
    nogueira, TV, aparador com toca-discos, luminária de pé e plantas.
    É o coração da casa e o principal ponto de contemplação da claraboia.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")

local Living = {}

local TV_WALL_Z = 3.4
local SOFA_X = -10.7

local function buildRug(parent: Instance)
    local model = Kit.model(parent, "Tapete da sala")
    local x = SOFA_X
    local z = 0.1

    Kit.box(
        model,
        "Tapete",
        CFrame.new(x, 0.035, z),
        Vector3.new(6.4, 0.06, 5.5),
        Palette.Linen,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Borda do tapete",
        CFrame.new(x, 0.07, z),
        Vector3.new(5.9, 0.012, 4.95),
        Palette.Clay,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Campo do tapete",
        CFrame.new(x, 0.08, z),
        Vector3.new(5.6, 0.012, 4.65),
        Palette.LinenLight,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    for stripe = -1, 1 do
        Kit.box(
            model,
            "Listra do tapete",
            CFrame.new(x, 0.092, z + stripe * 1.3),
            Vector3.new(5.5, 0.01, 0.12),
            Palette.Sage,
            Palette.Materials.carpet,
            { collide = false, query = false, shadow = false }
        )
    end
    for side = -1, 1 do
        for index = 1, 18 do
            Kit.box(
                model,
                "Franja do tapete",
                CFrame.new(x - 2.95 + (index - 1) * 0.347, 0.03, z + side * 2.82),
                Vector3.new(0.055, 0.025, 0.22),
                Palette.LinenLight,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    return model
end

local function buildSofa(parent: Instance)
    local model = Kit.model(parent, "Sofá")
    local x = SOFA_X
    local z = -1.55
    local width = 5.8
    local depth = 2.7
    local seatY = 1.35

    -- Estrutura e pés.
    Kit.box(
        model,
        "Base do sofá",
        CFrame.new(x, 0.72, z),
        Vector3.new(width, 0.68, depth - 0.2),
        Palette.OliveDeep,
        Palette.Materials.fabric,
        { collide = true, query = true }
    )
    for _, sx in { -1, 1 } do
        for _, sz in { -1, 1 } do
            Kit.cylinder(
                model,
                "Pé do sofá",
                CFrame.new(x + sx * (width * 0.5 - 0.38), 0.18, z + sz * (depth * 0.5 - 0.34)),
                0.36,
                0.18,
                Palette.Walnut,
                Palette.Materials.wood,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Assento macio em duas almofadas.
    for seat = -1, 1 do
        local seatX = x + seat * 1.37
        Kit.box(
            model,
            "Almofada do assento",
            CFrame.new(seatX, seatY, z - 0.02),
            Vector3.new(2.58, 0.62, 2.16),
            Palette.Olive,
            Palette.Materials.fabric,
            { collide = true, query = true }
        )
        Kit.box(
            model,
            "Pesponto do assento",
            CFrame.new(seatX, seatY + 0.33, z - 0.02),
            Vector3.new(2.42, 0.04, 1.98),
            Palette.OliveDeep,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Encosto.
    Kit.box(
        model,
        "Encosto do sofá",
        CFrame.new(x, 2.0, z - depth * 0.5 + 0.32),
        Vector3.new(width, 2.85, 0.62),
        Palette.OliveDeep,
        Palette.Materials.fabric,
        { collide = true, query = true }
    )
    for cushion = -1, 1 do
        Kit.box(
            model,
            "Almofada do encosto",
            Kit.rotated(x + cushion * 1.4, 2.25, z - depth * 0.5 + 0.78, -8, 0, 0),
            Vector3.new(2.48, 1.54, 0.55),
            Palette.Olive,
            Palette.Materials.fabric,
            { collide = false, query = false }
        )
        Kit.box(
            model,
            "Pesponto do encosto",
            Kit.rotated(x + cushion * 1.4, 2.99, z - depth * 0.5 + 0.77, -8, 0, 0),
            Vector3.new(2.29, 0.035, 0.38),
            Palette.Sage,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Braços, com uma curva suave em cilindros sobrepostos.
    for side = -1, 1 do
        local armX = x + side * (width * 0.5 - 0.32)
        Kit.box(
            model,
            "Braço do sofá",
            CFrame.new(armX, 1.62, z),
            Vector3.new(0.64, 1.8, depth - 0.12),
            Palette.Olive,
            Palette.Materials.fabric,
            { collide = true, query = true }
        )
        Kit.cylinder(
            model,
            "Topo do braço",
            CFrame.new(armX, 2.51, z - 0.02),
            2.45,
            0.65,
            Palette.Sage,
            Palette.Materials.fabric,
            "z",
            { collide = false, query = false }
        )
        Kit.box(
            model,
            "Pé do braço",
            CFrame.new(armX, 0.18, z + depth * 0.5 - 0.15),
            Vector3.new(0.58, 0.36, 0.2),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Almofadas soltas.
    local loose = {
        { x = x - 1.7, y = 2.15, z = z - 0.35, color = Palette.Mustard, angle = 10 },
        { x = x + 1.75, y = 2.1, z = z - 0.3, color = Palette.Cream, angle = -12 },
        { x = x + 0.85, y = 2.08, z = z - 0.42, color = Palette.Clay, angle = 4 },
    }
    for index, pillow in loose do
        Kit.box(
            model,
            "Almofada solta",
            Kit.rotated(pillow.x, pillow.y, pillow.z, -7, pillow.angle, pillow.angle * 0.3),
            Vector3.new(1.02, 0.95, 0.27),
            pillow.color,
            Palette.Materials.fabric,
            { collide = false, query = false }
        )
        for stripe = 1, 3 do
            if index == 2 then
                Kit.box(
                    model,
                    "Listra da almofada",
                    Kit.rotated(pillow.x, pillow.y - 0.24 + stripe * 0.16, pillow.z - 0.16, -7, pillow.angle, pillow.angle * 0.3),
                    Vector3.new(0.88, 0.055, 0.012),
                    Palette.Terracotta,
                    Palette.Materials.fabric,
                    { collide = false, query = false, shadow = false }
                )
            end
        end
    end

    -- Manta jogada sobre o braço direito.
    for fold = 1, 4 do
        Kit.box(
            model,
            "Manta",
            Kit.rotated(
                x + width * 0.5 - 0.25 + fold * 0.08,
                2.2 - fold * 0.4,
                z + 0.15 + fold * 0.12,
                6,
                10 + fold * 3,
                2
            ),
            Vector3.new(0.7, 1.55, 0.08),
            if fold % 2 == 0 then Palette.Cream else Palette.LinenLight,
            Palette.Materials.fabric,
            { collide = false, query = false }
        )
    end
    for fringe = 1, 8 do
        Kit.box(
            model,
            "Franja da manta",
            Kit.rotated(x + 2.25, 0.7, z + 1.15 - fringe * 0.07, 0, 0, 12),
            Vector3.new(0.08, 0.34, 0.025),
            Palette.Cream,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cesto ao lado do sofá.
    Kit.cylinder(
        model,
        "Cesto de fibras",
        CFrame.new(x + width * 0.5 + 0.8, 0.65, z - 0.75),
        1.25,
        1.1,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Cobertor no cesto",
        Kit.rotated(x + width * 0.5 + 0.8, 1.34, z - 0.75, 0, 18, 0),
        Vector3.new(0.72, 0.2, 0.82),
        Palette.Sage,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildCoffeeTable(parent: Instance)
    local model = Kit.model(parent, "Mesa de centro")
    local x = SOFA_X
    local z = 1.1
    local topY = 1.2

    Kit.cylinder(
        model,
        "Tampo redondo",
        CFrame.new(x, topY, z),
        0.22,
        2.15,
        Palette.Walnut,
        Palette.Materials.wood,
        "y",
        { collide = true, query = true }
    )
    Kit.cylinder(
        model,
        "Borda do tampo",
        CFrame.new(x, topY + 0.13, z),
        0.07,
        2.22,
        Palette.OakDark,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 3 do
        local angle = (index - 1) * math.pi * 2 / 3 + 0.35
        local legX = x + math.cos(angle) * 0.86
        local legZ = z + math.sin(angle) * 0.86
        Kit.cylinder(
            model,
            "Pé da mesa",
            CFrame.new(legX, 0.57, legZ),
            1.25,
            0.15,
            Palette.WalnutDeep,
            Palette.Materials.wood,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.rodBetween(
            model,
            "Travessa da mesa",
            Vector3.new(x, 0.38, z),
            Vector3.new(legX, 0.38, legZ),
            0.09,
            Palette.WalnutDeep,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Bandeja, livros, caneca e vaso.
    Kit.cylinder(
        model,
        "Bandeja",
        CFrame.new(x + 0.28, topY + 0.22, z + 0.08),
        0.06,
        1.3,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false, reflectance = 0.22 }
    )
    Kit.box(
        model,
        "Livro",
        Kit.rotated(x - 0.55, topY + 0.22, z + 0.4, 0, 8, 0),
        Vector3.new(0.92, 0.12, 0.64),
        Palette.Sage,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Livro",
        Kit.rotated(x - 0.5, topY + 0.34, z + 0.38, 0, -5, 0),
        Vector3.new(0.8, 0.1, 0.54),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Caneca",
        CFrame.new(x + 0.75, topY + 0.34, z - 0.5),
        0.44,
        0.34,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Alça da caneca",
        Vector3.new(x + 0.92, topY + 0.42, z - 0.5),
        Vector3.new(x + 1.02, topY + 0.3, z - 0.5),
        0.045,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Vaso pequeno",
        CFrame.new(x - 0.65, topY + 0.38, z - 0.55),
        0.52,
        0.38,
        Palette.CeramicSpeckle,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for stem = 1, 3 do
        local top = Vector3.new(x - 0.65 + (stem - 2) * 0.12, topY + 1.25, z - 0.55 + (stem % 2) * 0.08)
        Kit.rodBetween(
            model,
            "Haste seca",
            Vector3.new(x - 0.65, topY + 0.55, z - 0.55),
            top,
            0.025,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Flor seca",
            CFrame.new(top),
            Vector3.new(0.13, 0.24, 0.13),
            Palette.DryFlower or Palette.Blush,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Vela",
        CFrame.new(x + 0.25, topY + 0.24, z + 0.45),
        0.22,
        0.24,
        Palette.Cream,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.sphere(
        model,
        "Chama",
        CFrame.new(x + 0.25, topY + 0.46, z + 0.45),
        Vector3.new(0.06, 0.16, 0.06),
        Color3.fromRGB(255, 191, 96),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildTVWall(parent: Instance)
    local model = Kit.model(parent, "Parede da TV")
    local x = -10.65
    local slatTop = 7.25
    local slatBottom = 0.35

    Kit.box(
        model,
        "Fundo ripado",
        CFrame.new(x, (slatTop + slatBottom) * 0.5, TV_WALL_Z + 0.01),
        Vector3.new(5.95, slatTop - slatBottom, 0.08),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    for slat = 1, 24 do
        local slatX = -13.43 + (slat - 1) * 0.238
        Kit.box(
            model,
            "Ripa de nogueira",
            CFrame.new(slatX, (slatTop + slatBottom) * 0.5, TV_WALL_Z - 0.06),
            Vector3.new(0.17, slatTop - slatBottom, 0.12),
            if slat % 3 == 0 then Palette.OakDark else Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- TV suspensa.
    Kit.box(
        model,
        "Moldura da TV",
        CFrame.new(x, 5.25, TV_WALL_Z - 0.2),
        Vector3.new(4.6, 2.72, 0.16),
        Palette.Ink,
        Palette.Materials.metal,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Tela da TV",
        CFrame.new(x, 5.25, TV_WALL_Z - 0.29),
        Vector3.new(4.4, 2.52, 0.04),
        Color3.fromRGB(20, 25, 26),
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, reflectance = 0.22, transparency = 0.03 }
    )
    Kit.box(
        model,
        "Reflexo na tela",
        Kit.rotated(x - 0.9, 5.45, TV_WALL_Z - 0.315, 0, 0, -24),
        Vector3.new(1.35, 0.7, 0.01),
        Palette.BlueGlass or Palette.CeramicBlue,
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, transparency = 0.82 }
    )
    Kit.box(
        model,
        "Led da TV",
        CFrame.new(x + 2.03, 3.92, TV_WALL_Z - 0.31),
        Vector3.new(0.055, 0.055, 0.02),
        Color3.fromRGB(219, 91, 67),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Barra de som",
        CFrame.new(x, 3.65, TV_WALL_Z - 0.38),
        Vector3.new(3.0, 0.28, 0.38),
        Palette.Charcoal,
        Palette.Materials.fabric,
        { collide = false, query = false }
    )

    -- Aparador sob a TV.
    Kit.box(
        model,
        "Aparador da TV",
        CFrame.new(x, 1.45, TV_WALL_Z - 0.55),
        Vector3.new(5.0, 0.18, 0.9),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Corpo do aparador",
        CFrame.new(x, 0.86, TV_WALL_Z - 0.55),
        Vector3.new(4.75, 0.96, 0.78),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    for door = -1, 1 do
        Kit.box(
            model,
            "Porta de palha",
            CFrame.new(x + door * 1.55, 0.9, TV_WALL_Z - 0.96),
            Vector3.new(1.42, 0.78, 0.055),
            Palette.OakPale,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Puxador",
            CFrame.new(x + door * 0.9, 0.9, TV_WALL_Z - 1.01),
            Vector3.new(0.1, 0.22, 0.04),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, side in { -1, 1 } do
        for _, depthSign in { -1, 1 } do
            Kit.cylinder(
                model,
                "Pé do aparador",
                CFrame.new(
                    x + side * 2.22,
                    0.18,
                    TV_WALL_Z - 0.55 + depthSign * 0.28
                ),
                0.35,
                0.12,
                Palette.BrassDark,
                Palette.Materials.metal,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Toca-discos, discos e cerâmica sobre o aparador.
    Kit.box(
        model,
        "Toca-discos",
        CFrame.new(x - 1.35, 1.66, TV_WALL_Z - 0.55),
        Vector3.new(1.15, 0.22, 0.78),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    Kit.cylinder(
        model,
        "Pratos do toca-discos",
        CFrame.new(x - 1.35, 1.8, TV_WALL_Z - 0.55),
        0.11,
        0.68,
        Palette.Ink,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Disco",
        CFrame.new(x - 1.35, 1.86, TV_WALL_Z - 0.55),
        0.025,
        0.6,
        Palette.Ink,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Selo do disco",
        CFrame.new(x - 1.35, 1.88, TV_WALL_Z - 0.55),
        0.012,
        0.2,
        Palette.Clay,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Braço do toca-discos",
        Vector3.new(x - 0.95, 1.92, TV_WALL_Z - 0.35),
        Vector3.new(x - 0.55, 1.92, TV_WALL_Z - 0.78),
        0.025,
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    for record = 1, 5 do
        Kit.box(
            model,
            "Capa de disco",
            Kit.rotated(x + 1.35, 1.82, TV_WALL_Z - 0.55 + record * 0.055, 0, 0, 4),
            Vector3.new(0.8, 0.55, 0.025),
            if record % 2 == 0 then Palette.Mustard else Palette.Olive,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Vaso do aparador",
        CFrame.new(x + 2.2, 1.79, TV_WALL_Z - 0.6),
        0.48,
        0.4,
        Palette.CeramicBlue,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for leaf = 1, 5 do
        local angle = leaf * 1.7
        Kit.sphere(
            model,
            "Folha",
            CFrame.new(
                x + 2.2 + math.cos(angle) * 0.3,
                2.2 + (leaf % 2) * 0.24,
                TV_WALL_Z - 0.6 + math.sin(angle) * 0.24
            ) * CFrame.Angles(math.rad(22), angle, math.rad(28)),
            Vector3.new(0.12, 0.5, 0.28),
            Palette.LeafLight,
            Palette.Materials.leaf,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Cesto sob o aparador",
        CFrame.new(x + 1.2, 0.32, TV_WALL_Z - 0.48),
        0.55,
        0.82,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )

    -- Arandelas ladeando a TV.
    for side = -1, 1 do
        local sconceX = x + side * 2.95
        Kit.cylinder(
            model,
            "Arandela - base",
            CFrame.new(sconceX, 6.45, TV_WALL_Z - 0.12),
            0.1,
            0.38,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Arandela - braço",
            CFrame.new(sconceX, 6.45, TV_WALL_Z - 0.35),
            0.5,
            0.07,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
        local bulb = Kit.sphere(
            model,
            "Arandela - cúpula",
            CFrame.new(sconceX, 6.45, TV_WALL_Z - 0.64),
            Vector3.new(0.34, 0.5, 0.34),
            Palette.Cream,
            Palette.Materials.glass,
            { collide = false, query = false, shadow = false, transparency = 0.25 }
        )
        Kit.pointLight(bulb, Color3.fromRGB(255, 198, 137), {
            name = "Luz da arandela",
            brightness = 0.55,
            range = 7,
            shadows = false,
        })
    end

    return model
end

local function buildFloorLamp(parent: Instance)
    local model = Kit.model(parent, "Luminária de pé")
    local x = -6.95
    local z = 2.35

    Kit.cylinder(
        model,
        "Base da luminária",
        CFrame.new(x, 0.14, z),
        0.28,
        0.8,
        Palette.BrassDark,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Haste da luminária",
        CFrame.new(x, 2.9, z),
        5.5,
        0.1,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cúpula da luminária",
        CFrame.new(x, 5.88, z),
        1.1,
        1.35,
        Palette.LinenLight,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cúpula - borda",
        CFrame.new(x, 5.35, z),
        0.08,
        1.38,
        Palette.Linen,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local bulb = Kit.sphere(
        model,
        "Lâmpada",
        CFrame.new(x, 5.65, z),
        Vector3.new(0.28, 0.32, 0.28),
        Color3.fromRGB(255, 228, 183),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(bulb, Color3.fromRGB(255, 202, 142), {
        name = "Luz da sala",
        brightness = 0.9,
        range = 10,
        shadows = false,
    })
    return model
end

local function buildPlant(parent: Instance)
    local model = Kit.model(parent, "Planta grande")
    local x = -13.25
    local z = -4.15

    Kit.cylinder(
        model,
        "Cachepô",
        CFrame.new(x, 0.66, z),
        1.25,
        1.25,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = true, query = true }
    )
    Kit.cylinder(
        model,
        "Terra",
        CFrame.new(x, 1.24, z),
        0.12,
        1.12,
        Palette.Soil,
        Palette.Materials.leaf,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local stems = {
        { top = Vector3.new(x - 0.45, 4.2, z + 0.2), leaf = 1 },
        { top = Vector3.new(x + 0.35, 4.7, z - 0.2), leaf = 2 },
        { top = Vector3.new(x - 0.1, 4.3, z - 0.4), leaf = 3 },
        { top = Vector3.new(x + 0.5, 3.9, z + 0.45), leaf = 4 },
        { top = Vector3.new(x - 0.55, 3.7, z - 0.3), leaf = 5 },
    }
    for _, stem in stems do
        Kit.rodBetween(
            model,
            "Caule",
            Vector3.new(x, 1.25, z),
            stem.top,
            0.06,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        for leaf = 1, 4 do
            local angle = leaf * 1.9
            Kit.sphere(
                model,
                "Folha de monstera",
                CFrame.new(
                    stem.top.X + math.cos(angle) * 0.42,
                    stem.top.Y + (leaf % 2) * 0.3,
                    stem.top.Z + math.sin(angle) * 0.42
                ) * CFrame.Angles(math.rad(28), angle, math.rad(34)),
                Vector3.new(0.3, 1.0, 0.62),
                if (leaf + stem.leaf) % 2 == 0 then Palette.Leaf else Palette.LeafDeep,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

local function buildWallArt(parent: Instance)
    local model = Kit.model(parent, "Quadro abstrato")
    local x = -13.94
    local z = -0.9
    local y = 5.45

    Kit.box(
        model,
        "Moldura",
        CFrame.new(x, y, z),
        Vector3.new(0.1, 2.2, 1.6),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Passe-partout",
        CFrame.new(x + 0.065, y, z),
        Vector3.new(0.03, 1.92, 1.32),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    local art = {
        { color = Palette.Clay, size = Vector3.new(0.01, 1.1, 0.5), pos = Vector3.new(x + 0.085, y + 0.05, z - 0.25) },
        { color = Palette.OliveDeep, size = Vector3.new(0.01, 0.55, 0.85), pos = Vector3.new(x + 0.087, y - 0.35, z + 0.23) },
        { color = Palette.Mustard, size = Vector3.new(0.012, 0.3, 0.3), pos = Vector3.new(x + 0.09, y + 0.62, z + 0.35) },
    }
    for index, piece in art do
        Kit.box(
            model,
            "Forma " .. index,
            CFrame.new(piece.pos),
            piece.size,
            piece.color,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildCeilingSpots(parent: Instance)
    local model = Kit.model(parent, "Luzes da sala")
    for index, z in { -1.1, 1.9 } do
        Kit.cylinder(
            model,
            "Spot embutido",
            CFrame.new(SOFA_X - 2.0, 9.14, z),
            0.08,
            0.46,
            Palette.Trim,
            Palette.Materials.paint,
            "y",
            { collide = false, query = false, shadow = false }
        )
        local bulb = Kit.cylinder(
            model,
            "Lâmpada do spot",
            CFrame.new(SOFA_X - 2.0, 9.09, z),
            0.025,
            0.33,
            Color3.fromRGB(255, 226, 181),
            Palette.Materials.neon,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.pointLight(bulb, Color3.fromRGB(255, 209, 155), {
            name = "Luz de destaque " .. index,
            brightness = 0.45,
            range = 7,
            shadows = false,
        })
    end
    return model
end

function Living.build(parent: Instance)
    local model = Kit.model(parent, "Sala")
    buildRug(model)
    buildSofa(model)
    buildCoffeeTable(model)
    buildTVWall(model)
    buildFloorLamp(model)
    buildPlant(model)
    buildWallArt(model)
    buildCeilingSpots(model)
    return model
end

return Living

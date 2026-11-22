local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Banheiro de 3,2 m²: box de vidro, revestimento zellige, cuba de cerâmica,
    espelho, toalheiro, sanitário e uma porta de correr embutida. Cada
    centímetro foi desenhado para a casa pequena continuar funcional.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")

local Bathroom = {}

local BATH_MIN_X = -14
local BATH_MAX_X = -7.6
local BATH_MIN_Z = 3.8
local BATH_MAX_Z = 10

local function tileTone(row: number, column: number, accent: boolean?): Color3
    if accent then
        if (row + column) % 5 == 0 then
            return Palette.TileOlive
        elseif (row + column) % 3 == 0 then
            return Palette.TileSage
        end
        return Kit.tint(Palette.SagePale, -0.06 + ((row * 3 + column) % 3) * 0.02)
    end

    if (row + column) % 7 == 0 then
        return Palette.TileSage
    elseif (row + column) % 4 == 0 then
        return Palette.TileCream
    end
    return Kit.tint(Palette.SagePale, 0.02 + ((row + column) % 3) * 0.025)
end

local function tiledWallX(
    parent: Instance,
    name: string,
    planeX: number,
    normalSign: number,
    z1: number,
    z2: number,
    y1: number,
    y2: number,
    accent: boolean?
)
    local tileZ = 0.94
    local tileY = 0.58
    local gap = 0.045
    local cols = math.ceil((z2 - z1) / tileZ)
    local rows = math.ceil((y2 - y1) / tileY)
    local cellZ = (z2 - z1) / cols
    local cellY = (y2 - y1) / rows

    Kit.box(
        parent,
        name .. " - rejunte",
        CFrame.new(planeX - normalSign * 0.035, (y1 + y2) * 0.5, (z1 + z2) * 0.5),
        Vector3.new(0.045, y2 - y1, z2 - z1),
        Palette.Grout,
        Palette.Materials.tile,
        { collide = false, query = false, shadow = false }
    )

    for row = 1, rows do
        for column = 1, cols do
            local offset = if row % 2 == 0 then cellZ * 0.5 else 0
            local z = z1 + (column - 0.5) * cellZ + offset
            if z + cellZ * 0.5 <= z2 + 0.001 then
                Kit.box(
                    parent,
                    name .. " - pastilha",
                    CFrame.new(planeX, y1 + (row - 0.5) * cellY, z),
                    Vector3.new(0.06, cellY - gap, cellZ - gap),
                    tileTone(row, column, accent),
                    Palette.Materials.tile,
                    {
                        collide = false,
                        query = false,
                        shadow = false,
                        reflectance = 0.035 + (row + column) % 3 * 0.015,
                    }
                )
            end
        end
    end
end

local function tiledWallZ(
    parent: Instance,
    name: string,
    planeZ: number,
    normalSign: number,
    x1: number,
    x2: number,
    y1: number,
    y2: number,
    accent: boolean?
)
    local tileX = 0.94
    local tileY = 0.58
    local gap = 0.045
    local cols = math.ceil((x2 - x1) / tileX)
    local rows = math.ceil((y2 - y1) / tileY)
    local cellX = (x2 - x1) / cols
    local cellY = (y2 - y1) / rows

    Kit.box(
        parent,
        name .. " - rejunte",
        CFrame.new((x1 + x2) * 0.5, (y1 + y2) * 0.5, planeZ - normalSign * 0.035),
        Vector3.new(x2 - x1, y2 - y1, 0.045),
        Palette.Grout,
        Palette.Materials.tile,
        { collide = false, query = false, shadow = false }
    )

    for row = 1, rows do
        for column = 1, cols do
            local offset = if row % 2 == 0 then cellX * 0.5 else 0
            local x = x1 + (column - 0.5) * cellX + offset
            if x + cellX * 0.5 <= x2 + 0.001 then
                Kit.box(
                    parent,
                    name .. " - pastilha",
                    CFrame.new(x, y1 + (row - 0.5) * cellY, planeZ),
                    Vector3.new(cellX - gap, cellY - gap, 0.06),
                    tileTone(row, column, accent),
                    Palette.Materials.tile,
                    {
                        collide = false,
                        query = false,
                        shadow = false,
                        reflectance = 0.035 + (row + column) % 3 * 0.015,
                    }
                )
            end
        end
    end
end

local function buildTiles(parent: Instance)
    local model = Kit.model(parent, "Revestimento do banheiro")

    -- Banheiro inteiro: meia parede de zellige e faixa de acabamento.
    tiledWallX(model, "Parede oeste", BATH_MIN_X + 0.055, 1, BATH_MIN_Z + 0.08, BATH_MAX_Z - 0.08, 0.08, 4.9)
    tiledWallX(
        model,
        "Parede leste - vanity",
        BATH_MAX_X - 0.055,
        -1,
        BATH_MIN_Z + 0.08,
        6.55,
        0.08,
        5.2
    )
    tiledWallX(
        model,
        "Parede leste - canto",
        BATH_MAX_X - 0.055,
        -1,
        9.4,
        BATH_MAX_Z - 0.08,
        0.08,
        4.9
    )
    tiledWallZ(
        model,
        "Parede norte",
        BATH_MIN_Z + 0.055,
        1,
        BATH_MIN_X + 0.08,
        BATH_MAX_X - 0.08,
        0.08,
        4.9
    )
    tiledWallZ(
        model,
        "Parede da entrada",
        BATH_MAX_Z - 0.055,
        -1,
        BATH_MIN_X + 0.08,
        BATH_MAX_X - 0.08,
        0.08,
        4.9
    )

    -- Interior do box: mais alto e em tom oliva.
    tiledWallX(
        model,
        "Box - parede oeste",
        BATH_MIN_X + 0.07,
        1,
        BATH_MIN_Z + 0.1,
        6.9,
        4.9,
        8.1,
        true
    )
    tiledWallZ(
        model,
        "Box - parede norte",
        BATH_MIN_Z + 0.07,
        1,
        BATH_MIN_X + 0.1,
        -10.75,
        4.9,
        8.1,
        true
    )
    tiledWallZ(
        model,
        "Box - parede norte baixa",
        BATH_MIN_Z + 0.07,
        1,
        BATH_MIN_X + 0.1,
        -10.75,
        0.08,
        4.9,
        true
    )

    -- Faixa de remate superior e rodapé em pedra.
    local trimY = 4.98
    Kit.box(
        model,
        "Remate dos azulejos",
        CFrame.new(BATH_MIN_X + 0.08, trimY, 6.94),
        Vector3.new(0.14, 0.11, 6.0),
        Palette.Trim,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Remate dos azulejos",
        CFrame.new(-10.8, trimY, BATH_MAX_Z - 0.08),
        Vector3.new(6.2, 0.11, 0.14),
        Palette.Trim,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Rodapé de pedra",
        CFrame.new(BATH_MIN_X + 0.1, 0.2, 6.94),
        Vector3.new(0.16, 0.34, 6.0),
        Palette.StoneDark,
        Palette.Materials.slate,
        { collide = false, query = false, shadow = false }
    )

    -- Segundo remate no box, sobre a faixa branca.
    Kit.box(
        model,
        "Remate do box",
        CFrame.new(BATH_MIN_X + 0.1, 8.14, 5.35),
        Vector3.new(0.17, 0.12, 3.05),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Remate do box",
        CFrame.new(-12.3, 8.14, BATH_MIN_Z + 0.1),
        Vector3.new(3.05, 0.12, 0.17),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildShower(parent: Instance)
    local model = Kit.model(parent, "Box de vidro")
    local x1, x2 = -13.9, -10.85
    local z1, z2 = 3.9, 6.9
    local cx = (x1 + x2) * 0.5

    -- Base e ralo.
    Kit.box(
        model,
        "Base do box",
        CFrame.new(cx, 0.15, (z1 + z2) * 0.5),
        Vector3.new(x2 - x1, 0.22, z2 - z1),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Canaleta da base",
        CFrame.new(cx, 0.27, z2 - 0.2),
        Vector3.new(x2 - x1 - 0.25, 0.04, 0.2),
        Palette.SteelDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Ralo",
        CFrame.new(cx, 0.275, (z1 + z2) * 0.5),
        0.015,
        0.24,
        Palette.Steel,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )

    -- Vidro fixo, ferragens e uma abertura para entrar.
    Kit.box(
        model,
        "Vidro fixo do box",
        CFrame.new(x2, 3.7, 5.25),
        Vector3.new(0.06, 6.4, 2.55),
        Palette.GlassClear,
        Palette.Materials.glass,
        {
            collide = true,
            query = false,
            shadow = false,
            transparency = 0.78,
            reflectance = 0.12,
        }
    )
    Kit.box(
        model,
        "Perfil de alumínio",
        CFrame.new(x2, 3.7, 3.98),
        Vector3.new(0.09, 6.8, 0.1),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Perfil de alumínio",
        CFrame.new(x2, 3.7, 6.53),
        Vector3.new(0.09, 6.8, 0.1),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Perfil superior do box",
        CFrame.new(x2, 6.86, 5.25),
        Vector3.new(0.09, 0.09, 2.64),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Barra de toalha do box",
        CFrame.new(x2 + 0.015, 4.1, 5.25),
        2.2,
        0.08,
        Palette.Brass,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )

    -- Chuveiro de teto e misturador.
    Kit.rodBetween(
        model,
        "Braço do chuveiro",
        Vector3.new(-12.35, 7.85, BATH_MIN_Z + 0.08),
        Vector3.new(-12.35, 7.85, 4.55),
        0.09,
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Chuveiro de teto",
        CFrame.new(-12.35, 7.8, 4.55),
        0.08,
        1.35,
        Palette.Chrome,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false, reflectance = 0.4 }
    )
    Kit.cylinder(
        model,
        "Chuveiro - base do braço",
        CFrame.new(-12.35, 7.85, BATH_MIN_Z + 0.12),
        0.12,
        0.28,
        Palette.Chrome,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Misturador",
        CFrame.new(-12.35, 4.1, BATH_MIN_Z + 0.115),
        Vector3.new(0.55, 0.24, 0.09),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for side = -1, 1 do
        Kit.cylinder(
            model,
            "Registro",
            CFrame.new(-12.35 + side * 0.38, 4.1, BATH_MIN_Z + 0.15),
            0.16,
            0.23,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.rodBetween(
        model,
        "Ducha higiênica",
        Vector3.new(-11.8, 4.35, BATH_MIN_Z + 0.12),
        Vector3.new(-11.62, 4.8, 4.15),
        0.04,
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Nicho aberto na parede do box.
    Kit.box(
        model,
        "Nicho do box",
        CFrame.new(-13.35, 5.15, BATH_MIN_Z + 0.115),
        Vector3.new(0.85, 1.1, 0.1),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Prateleira do nicho",
        CFrame.new(-13.35, 5.12, BATH_MIN_Z + 0.2),
        Vector3.new(0.8, 0.06, 0.28),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = false, query = false, shadow = false }
    )
    for index, bottle in { -0.2, 0.1, 0.35 } do
        Kit.cylinder(
            model,
            "Frasco do nicho",
            CFrame.new(-13.35 + bottle, 5.35, BATH_MIN_Z + 0.2),
            0.38 + index * 0.06,
            0.17,
            if index % 2 == 0 then Palette.CeramicClay else Palette.GlassGreen,
            if index % 2 == 0 then Palette.Materials.ceramic else Palette.Materials.glass,
            "y",
            { collide = false, query = false, shadow = false, transparency = 0.15 }
        )
    end

    -- Frasco de shampoo no chão e banco simples.
    Kit.cylinder(
        model,
        "Shampoo",
        CFrame.new(-13.55, 0.58, 4.25),
        0.67,
        0.3,
        Palette.OakPale,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Condicionador",
        CFrame.new(-13.2, 0.51, 4.12),
        0.53,
        0.27,
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Assento de madeira do box",
        CFrame.new(-12.4, 1.27, 6.35),
        Vector3.new(1.35, 0.16, 0.62),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    for _, legX in { -12.9, -11.9 } do
        Kit.box(
            model,
            "Pé do assento",
            CFrame.new(legX, 0.65, 6.35),
            Vector3.new(0.14, 1.0, 0.48),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    return model
end

local function buildVanity(parent: Instance)
    local model = Kit.model(parent, "Cuba e espelho")
    local x = -8.27
    local z = 5.35

    Kit.box(
        model,
        "Gabinete da cuba",
        CFrame.new(x, 2.05, z),
        Vector3.new(1.4, 1.32, 2.15),
        Palette.Cabinet,
        Palette.Materials.paint,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Tampo da cuba",
        CFrame.new(x, 2.78, z),
        Vector3.new(1.52, 0.16, 2.3),
        Palette.Marble,
        Palette.Materials.marble,
        { collide = true, query = true }
    )
    for door = -1, 1 do
        Kit.box(
            model,
            "Porta do gabinete",
            CFrame.new(x - 0.72, 2.02, z + door * 0.52),
            Vector3.new(0.06, 1.02, 0.94),
            Palette.CabinetHighlight,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Puxador do gabinete",
            CFrame.new(x - 0.79, 2.15, z + door * 0.14),
            Vector3.new(0.13, 0.13, 0.13),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cuba de cerâmica e torneira.
    Kit.cylinder(
        model,
        "Cuba",
        CFrame.new(x - 0.02, 2.98, z),
        0.4,
        1.22,
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false }
    )
    Kit.cylinder(
        model,
        "Água da cuba",
        CFrame.new(x - 0.02, 3.14, z),
        0.02,
        1.03,
        Color3.fromRGB(205, 220, 214),
        Palette.Materials.glass,
        "y",
        { collide = false, query = false, shadow = false, transparency = 0.45 }
    )
    Kit.cylinder(
        model,
        "Base da torneira",
        CFrame.new(x + 0.42, 2.98, z),
        0.08,
        0.24,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Torneira",
        Vector3.new(x + 0.42, 3.02, z),
        Vector3.new(x + 0.42, 3.92, z),
        0.075,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Bica da torneira",
        Vector3.new(x + 0.42, 3.92, z),
        Vector3.new(x + 0.12, 3.92, z),
        0.075,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Bica",
        CFrame.new(x + 0.12, 3.84, z),
        0.15,
        0.06,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )

    -- Espelho com moldura de nogueira.
    Kit.box(
        model,
        "Moldura do espelho",
        CFrame.new(BATH_MAX_X - 0.035, 5.65, z),
        Vector3.new(0.07, 2.78, 1.88),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Espelho",
        CFrame.new(BATH_MAX_X - 0.085, 5.65, z),
        Vector3.new(0.035, 2.52, 1.62),
        Palette.GlassSmoke,
        Palette.Materials.glass,
        {
            collide = false,
            query = false,
            shadow = false,
            transparency = 0.18,
            reflectance = 0.52,
        }
    )
    Kit.box(
        model,
        "Brilho do espelho",
        Kit.rotated(BATH_MAX_X - 0.11, 5.86, z - 0.34, 0, 0, -10),
        Vector3.new(0.012, 1.5, 0.18),
        Palette.LinenLight,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false, transparency = 0.75 }
    )

    -- Arandela espelhada.
    Kit.rodBetween(
        model,
        "Arandela do espelho",
        Vector3.new(BATH_MAX_X - 0.06, 7.28, z - 0.55),
        Vector3.new(BATH_MAX_X - 0.06, 7.28, z + 0.55),
        0.07,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for side = -1, 1 do
        local globe = Kit.sphere(
            model,
            "Cúpula da arandela",
            CFrame.new(BATH_MAX_X - 0.12, 7.28, z + side * 0.55),
            Vector3.new(0.3, 0.42, 0.3),
            Palette.Cream,
            Palette.Materials.glass,
            { collide = false, query = false, shadow = false, transparency = 0.2 }
        )
        Kit.pointLight(globe, Color3.fromRGB(255, 206, 150), {
            name = "Luz do espelho",
            brightness = 0.45,
            range = 6,
            shadows = false,
        })
    end

    -- Objetos da cuba.
    Kit.cylinder(
        model,
        "Saboneteira",
        CFrame.new(x + 0.35, 2.96, z - 0.76),
        0.08,
        0.36,
        Palette.CeramicSpeckle,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Sabonete",
        CFrame.new(x + 0.35, 3.02, z - 0.76),
        Vector3.new(0.24, 0.08, 0.16),
        Palette.Sage,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    for brush = -1, 1 do
        Kit.rodBetween(
            model,
            "Escova de dentes",
            Vector3.new(x + 0.3 + brush * 0.12, 2.9, z + 0.72),
            Vector3.new(x + 0.3 + brush * 0.18, 3.62, z + 0.66),
            0.045,
            if brush == 0 then Palette.CeramicClay else Palette.CeramicBlue,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Copo de escova",
        CFrame.new(x + 0.3, 3.04, z + 0.72),
        0.3,
        0.26,
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Creme",
        CFrame.new(x + 0.34, 3.02, z + 0.92),
        0.26,
        0.22,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Vaso de eucalipto",
        CFrame.new(x - 0.5, 3.02, z + 0.78),
        0.35,
        0.24,
        Palette.GlassGreen,
        Palette.Materials.glass,
        "y",
        { collide = false, query = false, shadow = false, transparency = 0.3 }
    )
    for stem = 1, 5 do
        local top = Vector3.new(x - 0.5 + (stem - 3) * 0.13, 4.5 + (stem % 3) * 0.2, z + 0.78)
        Kit.rodBetween(
            model,
            "Haste de eucalipto",
            Vector3.new(x - 0.5, 3.2, z + 0.78),
            top,
            0.028,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        for leaf = 1, 4 do
            local t = leaf / 5
            Kit.sphere(
                model,
                "Folha de eucalipto",
                CFrame.new(
                    x - 0.5 + (top.X - (x - 0.5)) * t,
                    3.2 + (top.Y - 3.2) * t,
                    z + 0.78 + (top.Z - (z + 0.78)) * t
                ) * CFrame.Angles(0, stem, math.rad(24)),
                Vector3.new(0.11, 0.3, 0.15),
                if leaf % 2 == 0 then Palette.LeafLight else Palette.Sage,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Toalha dobrada e cesto.
    Kit.box(
        model,
        "Toalha dobrada",
        CFrame.new(x - 0.1, 2.99, z - 1.03),
        Vector3.new(0.6, 0.24, 0.5),
        Palette.LinenLight,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Listra da toalha",
        CFrame.new(x - 0.1, 3.115, z - 1.03),
        Vector3.new(0.6, 0.02, 0.08),
        Palette.Sage,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cesto sob o gabinete",
        CFrame.new(x + 0.1, 0.62, z),
        0.9,
        1.0,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildToilet(parent: Instance)
    local model = Kit.model(parent, "Sanitário")
    local z = 8.55
    local x = -13.2

    Kit.cylinder(
        model,
        "Base do vaso",
        CFrame.new(x + 0.35, 0.75, z),
        1.3,
        1.05,
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false }
    )
    Kit.sphere(
        model,
        "Cuba do vaso",
        CFrame.new(x + 0.38, 1.56, z),
        Vector3.new(1.85, 0.72, 1.34),
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        { collide = true, query = true }
    )
    Kit.sphere(
        model,
        "Assento",
        CFrame.new(x + 0.38, 1.87, z),
        Vector3.new(1.65, 0.2, 1.24),
        Palette.Enamel,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Tanque",
        CFrame.new(x - 0.55, 2.27, z),
        Vector3.new(0.62, 1.72, 1.7),
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Tampa do tanque",
        CFrame.new(x - 0.55, 3.17, z),
        Vector3.new(0.68, 0.14, 1.76),
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Botão de descarga",
        CFrame.new(x - 0.55, 3.26, z),
        0.06,
        0.3,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )

    Kit.cylinder(
        model,
        "Porta-rolo",
        CFrame.new(BATH_MIN_X + 0.17, 2.35, z - 1.1),
        0.45,
        0.07,
        Palette.Brass,
        Palette.Materials.metal,
        "x",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Papel higiênico",
        CFrame.new(BATH_MIN_X + 0.17, 2.35, z - 1.1),
        0.38,
        0.4,
        Palette.Cream,
        Palette.Materials.fabric,
        "x",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Lixeira do banheiro",
        CFrame.new(-13.45, 0.6, 9.45),
        1.18,
        0.7,
        Palette.Steel,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildPocketDoor(parent: Instance)
    local model = Kit.model(parent, "Porta de correr")

    Kit.rodBetween(
        model,
        "Trilho da porta",
        Vector3.new(BATH_MAX_X + 0.06, 7.25, 6.45),
        Vector3.new(BATH_MAX_X + 0.06, 7.25, 9.55),
        0.1,
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for _, bracketZ in { 6.6, 9.4 } do
        Kit.rodBetween(
            model,
            "Suporte do trilho",
            Vector3.new(BATH_MAX_X + 0.06, 7.25, bracketZ),
            Vector3.new(BATH_MAX_X + 0.36, 7.25, bracketZ),
            0.06,
            Palette.BrassDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- A porta embutida deixa apenas a borda de vidro aparecendo.
    Kit.box(
        model,
        "Porta de vidro fosco",
        CFrame.new(BATH_MAX_X + 0.19, 3.48, 9.04),
        Vector3.new(0.08, 6.72, 0.62),
        Palette.CeramicWhite,
        Palette.Materials.glass,
        {
            collide = false,
            query = false,
            shadow = false,
            transparency = 0.48,
            reflectance = 0.06,
        }
    )
    Kit.box(
        model,
        "Moldura da porta",
        CFrame.new(BATH_MAX_X + 0.19, 3.48, 8.74),
        Vector3.new(0.11, 6.85, 0.1),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Puxador da porta",
        CFrame.new(BATH_MAX_X + 0.12, 3.45, 9.4),
        0.7,
        0.05,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildAccessories(parent: Instance)
    local model = Kit.model(parent, "Acessórios do banheiro")

    -- Tapete e passadeira.
    Kit.box(
        model,
        "Tapete do banheiro",
        CFrame.new(-9.35, 0.08, 7.9),
        Vector3.new(1.65, 0.06, 2.35),
        Palette.Sage,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Borda do tapete",
        CFrame.new(-9.35, 0.11, 7.9),
        Vector3.new(1.4, 0.012, 2.05),
        Palette.Linen,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Tapete de madeira",
        CFrame.new(-11.0, 0.055, 7.55),
        Vector3.new(2.2, 0.08, 1.3),
        Palette.OakPale,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for slat = 1, 5 do
        Kit.box(
            model,
            "Ripa do tapete",
            CFrame.new(-11.0, 0.1, 7.0 + slat * 0.2),
            Vector3.new(2.05, 0.02, 0.1),
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Toalheiro com toalhas.
    Kit.rodBetween(
        model,
        "Toalheiro",
        Vector3.new(-9.7, 4.2, BATH_MIN_Z + 0.15),
        Vector3.new(-8.0, 4.2, BATH_MIN_Z + 0.15),
        0.07,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for index = 0, 2 do
        Kit.box(
            model,
            "Toalha pendurada",
            CFrame.new(-9.4 + index * 0.42, 3.28, BATH_MIN_Z + 0.3),
            Vector3.new(0.38, 1.65, 0.16),
            if index % 2 == 0 then Palette.LinenLight else Palette.SagePale,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Prateleiras acima do vaso.
    for shelf = 1, 2 do
        local y = 5.25 + shelf * 1.05
        Kit.box(
            model,
            "Prateleira de toalhas",
            CFrame.new(BATH_MIN_X + 0.5, y, 8.35),
            Vector3.new(0.95, 0.1, 2.2),
            Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Toalha na prateleira",
            CFrame.new(BATH_MIN_X + 0.5, y + 0.26, 7.8 + shelf * 0.35),
            Vector3.new(0.75, 0.38, 0.7),
            if shelf == 1 then Palette.Linen else Palette.SagePale,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Vela na prateleira",
            CFrame.new(BATH_MIN_X + 0.5, y + 0.28, 8.85),
            0.36,
            0.2,
            Palette.Cream,
            Palette.Materials.paint,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Banco e cesto perto da porta.
    Kit.box(
        model,
        "Banquinho",
        CFrame.new(-9.4, 1.22, 9.45),
        Vector3.new(1.3, 0.14, 0.64),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for _, legX in { -9.9, -8.9 } do
        for _, legZ in { 9.2, 9.7 } do
            Kit.box(
                model,
                "Pé do banquinho",
                CFrame.new(legX, 0.61, legZ),
                Vector3.new(0.12, 1.2, 0.12),
                Palette.Walnut,
                Palette.Materials.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Kit.box(
        model,
        "Toalha no banquinho",
        CFrame.new(-9.4, 1.39, 9.45),
        Vector3.new(0.85, 0.24, 0.5),
        Palette.CeramicBlue,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cesto de roupa",
        CFrame.new(-8.1, 0.65, 9.3),
        1.25,
        0.9,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Roupa no cesto",
        CFrame.new(-8.1, 1.32, 9.3),
        Vector3.new(0.7, 0.18, 0.6),
        Palette.LinenLight,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildLighting(parent: Instance)
    local model = Kit.model(parent, "Luz do banheiro")
    Kit.cylinder(
        model,
        "Luminária de teto",
        CFrame.new(-10.8, 9.1, 7.1),
        0.1,
        0.9,
        Palette.Trim,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local bulb = Kit.sphere(
        model,
        "Cúpula de luz",
        CFrame.new(-10.8, 8.96, 7.1),
        Vector3.new(0.8, 0.26, 0.8),
        Palette.Cream,
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, transparency = 0.25 }
    )
    Kit.pointLight(bulb, Color3.fromRGB(255, 209, 153), {
        name = "Luz do banheiro",
        brightness = 0.85,
        range = 9,
        shadows = false,
    })

    -- Exaustor e detalhe de teto.
    Kit.cylinder(
        model,
        "Exaustor",
        CFrame.new(-13.15, 9.14, 9.0),
        0.08,
        0.72,
        Palette.Enamel,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for grill = 1, 5 do
        Kit.box(
            model,
            "Grade do exaustor",
            CFrame.new(-13.15, 9.09, 9.24 - grill * 0.11),
            Vector3.new(0.45, 0.015, 0.03),
            Palette.SteelDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildWallDecor(parent: Instance)
    local model = Kit.model(parent, "Quadro do banheiro")

    Kit.box(
        model,
        "Moldura do quadro",
        CFrame.new(-9.0, 5.95, BATH_MIN_Z + 0.07),
        Vector3.new(1.25, 1.55, 0.08),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Passe-partout",
        CFrame.new(-9.0, 5.95, BATH_MIN_Z + 0.115),
        Vector3.new(1.05, 1.35, 0.015),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Gravura botânica",
        Kit.rotated(-9.0, 5.92, BATH_MIN_Z + 0.13, 0, 0, 8),
        Vector3.new(0.56, 0.78, 0.012),
        Palette.Sage,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Caule da gravura",
        Vector3.new(-9.0, 5.55, BATH_MIN_Z + 0.145),
        Vector3.new(-9.0, 6.32, BATH_MIN_Z + 0.145),
        0.018,
        Palette.LeafDeep,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    for leaf = 1, 4 do
        Kit.sphere(
            model,
            "Folha da gravura",
            CFrame.new(
                -9.0 + (leaf % 2 == 0 and 0.17 or -0.17),
                5.68 + leaf * 0.16,
                BATH_MIN_Z + 0.15
            ) * CFrame.Angles(0, 0, leaf * 0.5),
            Vector3.new(0.16, 0.3, 0.01),
            Palette.Olive,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    return model
end

function Bathroom.build(parent: Instance)
    local model = Kit.model(parent, "Banheiro")
    buildTiles(model)
    buildShower(model)
    buildPocketDoor(model)
    buildVanity(model)
    buildToilet(model)
    buildAccessories(model)
    buildLighting(model)
    buildWallDecor(model)
    return model
end

return Bathroom

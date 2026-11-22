local Compat = require("./Compat")
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

local Kit = require("./Kit")
local Palette = require("./Palette")
local Layout = require("./Layout")
local Furniture = require("./Furniture")

--[[
    Capela e arquivo morto do segundo pavimento.
    A capela tem altar de pedra, cruz de madeira, bancos em duas filas,
    vitrais coloridos, castiçais e um confessionário discreto. O arquivo
    guarda caixas de processos em estantes de ferro.
]]

local Capela = {}
local P = Palette
local M = P.Materials

local function box(
    parent: Instance,
    name: string,
    minX: number,
    maxX: number,
    minY: number,
    maxY: number,
    minZ: number,
    maxZ: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    return Kit.span(parent, name, minX, maxX, minY, maxY, minZ, maxZ, color, material, options)
end

local function stainedGlassX(
    parent: Instance,
    name: string,
    z: number,
    x1: number,
    x2: number,
    y1: number,
    y2: number
)
    local colors =
        { P.GlassColored, P.GlassAmber, P.BookRed, P.BookBlue, P.GlassFrost, P.GreenLight }
    local columns = 4
    local rows = 6
    for row = 1, rows do
        for column = 1, columns do
            local x = x1 + (x2 - x1) * (column - 0.5) / columns
            local y = y1 + (y2 - y1) * (row - 0.5) / rows
            box(
                parent,
                string.format("%s vitral %d-%d", name, row, column),
                x - (x2 - x1) / columns * 0.5 + 0.06,
                x + (x2 - x1) / columns * 0.5 - 0.06,
                y - (y2 - y1) / rows * 0.5 + 0.06,
                y + (y2 - y1) / rows * 0.5 - 0.06,
                z - 0.04,
                z + 0.04,
                colors[(row * 2 + column) % #colors + 1],
                M.glass,
                { transparency = 0.3, collide = false, query = false, shadow = false }
            )
        end
    end
    for index = 1, columns - 1 do
        local x = x1 + (x2 - x1) * index / columns
        box(
            parent,
            name .. " chumbo vertical " .. index,
            x - 0.04,
            x + 0.04,
            y1,
            y2,
            z - 0.06,
            z + 0.06,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for index = 1, rows - 1 do
        local y = y1 + (y2 - y1) * index / rows
        box(
            parent,
            name .. " chumbo horizontal " .. index,
            x1,
            x2,
            y - 0.04,
            y + 0.04,
            z - 0.06,
            z + 0.06,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function stainedGlassZ(
    parent: Instance,
    name: string,
    x: number,
    z1: number,
    z2: number,
    y1: number,
    y2: number
)
    local colors =
        { P.GlassAmber, P.BookBlue, P.BookRed, P.GlassColored, P.GreenLight, P.GlassFrost }
    local columns = 4
    local rows = 6
    for row = 1, rows do
        for column = 1, columns do
            local z = z1 + (z2 - z1) * (column - 0.5) / columns
            local y = y1 + (y2 - y1) * (row - 0.5) / rows
            box(
                parent,
                string.format("%s vitral %d-%d", name, row, column),
                x - 0.04,
                x + 0.04,
                y - (y2 - y1) / rows * 0.5 + 0.06,
                y + (y2 - y1) / rows * 0.5 - 0.06,
                z - (z2 - z1) / columns * 0.5 + 0.06,
                z + (z2 - z1) / columns * 0.5 - 0.06,
                colors[(row * 3 + column) % #colors + 1],
                M.glass,
                { transparency = 0.3, collide = false, query = false, shadow = false }
            )
        end
    end
    for index = 1, columns - 1 do
        local z = z1 + (z2 - z1) * index / columns
        box(
            parent,
            name .. " chumbo vertical " .. index,
            x - 0.06,
            x + 0.06,
            y1,
            y2,
            z - 0.04,
            z + 0.04,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for index = 1, rows - 1 do
        local y = y1 + (y2 - y1) * index / rows
        box(
            parent,
            name .. " chumbo horizontal " .. index,
            x - 0.06,
            x + 0.06,
            y - 0.04,
            y + 0.04,
            z1,
            z2,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function buildChapel(parent: Instance)
    local root = Kit.model(parent, "Capela")
    local y0 = 26
    local x1, x2, z1, z2 = -38.5, -22, -46, -27
    root:SetAttribute("Bancos", 8)
    root:SetAttribute("Vitrais", 2)

    box(root, "Piso da capela", x1, x2, y0 + 0.02, y0 + 0.1, z1, z2, P.Stone, M.stone, nil)
    box(
        root,
        "Passadeira do altar",
        -34.0,
        -26.5,
        y0 + 0.1,
        y0 + 0.16,
        z1 + 1.0,
        z2 - 1.0,
        P.CarpetDark,
        M.carpet,
        { collide = false, query = false, shadow = false }
    )

    -- Plataforma e altar.
    box(
        root,
        "Plataforma do altar",
        -36.5,
        -24.0,
        y0 + 0.1,
        y0 + 1.1,
        z1 + 0.5,
        z1 + 5.0,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        root,
        "Base do altar",
        -33.8,
        -26.7,
        y0 + 1.1,
        y0 + 3.4,
        z1 + 1.4,
        z1 + 3.6,
        P.Stone,
        M.stone,
        nil
    )
    box(
        root,
        "Tampo do altar",
        -34.1,
        -26.4,
        y0 + 3.4,
        y0 + 3.7,
        z1 + 1.1,
        z1 + 3.9,
        P.Marble,
        M.marble,
        nil
    )
    box(
        root,
        "Toalha do altar",
        -34.3,
        -26.2,
        y0 + 3.7,
        y0 + 4.1,
        z1 + 1.0,
        z1 + 4.0,
        P.LinenWhite,
        M.fabric,
        nil
    )
    Kit.block(
        root,
        "Cruz vertical",
        CFrame.new(-30.4, y0 + 11.0, z1 + 1.0),
        Vector3.new(0.55, 5.5, 0.35),
        P.WalnutDeep,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Cruz horizontal",
        CFrame.new(-30.4, y0 + 12.4, z1 + 1.0),
        Vector3.new(3.0, 0.55, 0.35),
        P.WalnutDeep,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Bíblia",
        CFrame.new(-30.5, y0 + 4.5, z1 + 2.4),
        Vector3.new(1.5, 0.3, 1.0),
        P.WalnutDeep,
        M.leather,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Cálice",
        CFrame.new(-28.3, y0 + 4.3, z1 + 2.4),
        Vector3.new(0.3, 0.9, 0.3),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Castiçais.
    for index, x in { -34.0, -32.1, -28.7, -26.8 } do
        box(
            root,
            "Castiçal " .. index,
            x - 0.18,
            x + 0.18,
            y0 + 3.8,
            y0 + 6.2,
            z1 + 1.6,
            z1 + 1.95,
            P.Brass,
            M.metal,
            nil
        )
        box(
            root,
            "Vela " .. index,
            x - 0.13,
            x + 0.13,
            y0 + 6.2,
            y0 + 7.2,
            z1 + 1.65,
            z1 + 1.9,
            P.LinenWhite,
            M.plastic,
            nil
        )
        Kit.block(
            root,
            "Chama " .. index,
            CFrame.new(x, y0 + 7.35, z1 + 1.78),
            Vector3.new(0.1, 0.25, 0.1),
            P.NeonWarm,
            M.neon,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.pointLight(
        root:FindFirstChild("Chama 1"),
        P.NeonWarm,
        { name = "Luz das velas", brightness = 0.7, range = 9, shadows = false }
    )

    -- Genuflexório e grade do altar.
    box(
        root,
        "Genuflexório",
        -36.0,
        -24.5,
        y0 + 0.1,
        y0 + 1.0,
        z1 + 5.5,
        z1 + 6.4,
        P.Walnut,
        M.wood,
        nil
    )
    box(
        root,
        "Grade do altar",
        -36.0,
        -24.5,
        y0 + 0.1,
        y0 + 1.0,
        z1 + 7.0,
        z1 + 7.25,
        P.Walnut,
        M.wood,
        nil
    )
    for index = 1, 9 do
        local x = -35.5 + (index - 1) * 1.35
        Kit.block(
            root,
            "Balaústre do altar " .. index,
            CFrame.new(x, y0 + 1.6, z1 + 7.12),
            Vector3.new(0.12, 3.2, 0.12),
            P.Oak,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        root,
        "Corrimão do altar",
        -36.0,
        -24.5,
        y0 + 3.1,
        y0 + 3.35,
        z1 + 7.0,
        z1 + 7.25,
        P.Oak,
        M.wood,
        nil
    )

    -- Bancos em duas filas, virados para o altar.
    for row = 1, 3 do
        local z = z1 + 9.5 + (row - 1) * 3.0
        for column = 1, 2 do
            local x = if column == 1 then -34.5 else -26.0
            Furniture.bench(
                root,
                string.format("Banco da capela %d-%d", row, column),
                CFrame.new(x, y0 + 0.1, z) * CFrame.Angles(0, math.rad(180), 0),
                6.0,
                P.Oak,
                M.wood
            )
            Kit.block(
                root,
                string.format("Almofada %d-%d", row, column),
                CFrame.new(x, y0 + 2.05, z - 0.25),
                Vector3.new(5.4, 0.18, 0.95),
                P.BookRed,
                M.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Vitrais.
    stainedGlassX(root, "Vitral norte", z1 + 1.55, -34.2, -29.8, y0 + 4.2, y0 + 10.2)
    stainedGlassZ(root, "Vitral oeste", x1 + 0.08, -38.0, -34.0, y0 + 4.1, y0 + 10.0)

    -- Mesa lateral, mural de hinos e relógio.
    Furniture.table(
        root,
        "Mesa dos hinos",
        CFrame.new(-23.2, y0 + 0.1, -34.0) * CFrame.Angles(0, math.rad(90), 0),
        3.0,
        1.6,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.noticeBoard(
        root,
        "Mural de hinos",
        CFrame.new(-22.15, y0 + 6.2, -34.0) * CFrame.Angles(0, math.rad(-90), 0),
        4.0,
        2.8
    )
    Furniture.wallClock(
        root,
        "Relógio da capela",
        CFrame.new(-22.15, y0 + 8.0, -28.5) * CFrame.Angles(0, math.rad(-90), 0),
        1
    )
    Furniture.plant(root, "Planta da capela", CFrame.new(-23.0, y0 + 0.1, -44.0), 0.5)

    -- Iluminação.
    for index, spec in
        {
            { x = -34.0, z = -37.0 },
            { x = -27.0, z = -37.0 },
            { x = -30.5, z = -30.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da capela " .. index,
            CFrame.new(spec.x, y0 + 12.0, spec.z),
            3.6,
            1.1,
            P.NeonWarm,
            0.8,
            11
        )
    end
    Furniture.wallSconce(
        root,
        "Arandela da capela oeste",
        CFrame.new(x1 + 0.2, y0 + 6.4, -39.0) * CFrame.Angles(0, math.rad(90), 0),
        P.NeonWarm,
        0.5,
        7
    )
    Furniture.wallSconce(
        root,
        "Arandela da capela leste",
        CFrame.new(x2 - 0.2, y0 + 6.4, -39.0) * CFrame.Angles(0, math.rad(-90), 0),
        P.NeonWarm,
        0.5,
        7
    )
    return root
end

local function buildArchive(parent: Instance)
    local root = Kit.model(parent, "ArquivoMorto")
    local y0 = 26
    local x1, x2, z1, z2 = 22, 38.5, -46, -27
    box(
        root,
        "Piso do arquivo morto",
        x1,
        x2,
        y0 + 0.02,
        y0 + 0.1,
        z1,
        z2,
        P.Concrete,
        M.concrete,
        nil
    )

    for row = 1, 3 do
        local z = -42.0 + (row - 1) * 4.0
        Furniture.shelf(
            root,
            "Estante do arquivo morto " .. row,
            CFrame.new(30.0, y0 + 0.1, z),
            10.0,
            8.5,
            1.5,
            5,
            P.Iron,
            M.metal,
            false
        )
        for column = 1, 5 do
            Kit.block(
                root,
                string.format("Caixa do arquivo morto %d-%d", row, column),
                CFrame.new(27.0 + (column - 1) * 1.6, y0 + 1.1, z + 0.25),
                Vector3.new(1.2, 1.1, 1.1),
                if (row + column) % 2 == 0 then P.OakDark else P.Oak,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Furniture.desk(
        root,
        "Mesa do arquivo morto",
        CFrame.new(35.8, y0 + 0.1, -31.0) * CFrame.Angles(0, math.rad(-90), 0),
        4.0,
        2.0,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do arquivo morto",
        CFrame.new(34.0, y0 + 0.1, -31.0) * CFrame.Angles(0, math.rad(90), 0),
        P.Walnut,
        M.wood
    )
    Furniture.cabinet(
        root,
        "Mapoteca do arquivo",
        CFrame.new(34.0, y0 + 0.1, -44.0),
        3.0,
        4.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Kit.block(
        root,
        "Escada do arquivo morto",
        CFrame.new(33.0, y0 + 3.8, -39.0),
        Vector3.new(0.7, 7.4, 0.6),
        P.OakDark,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Desumidificador",
        CFrame.new(37.6, y0 + 2.0, -35.0),
        Vector3.new(1.1, 3.4, 0.9),
        P.Steel,
        M.metal,
        nil
    )
    Furniture.ceilingLight(
        root,
        "Luz do arquivo morto",
        CFrame.new(30.0, y0 + 12.0, -36.0),
        4.2,
        1.2,
        P.NeonCool,
        0.65,
        10
    )
    return root
end

function Capela.build(parent: Instance)
    buildChapel(parent)
    buildArchive(parent)
    return parent:FindFirstChild("Capela") :: Model
end

return Capela

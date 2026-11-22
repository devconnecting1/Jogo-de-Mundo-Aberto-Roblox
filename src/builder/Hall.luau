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
    Hall central de convivência.
    O térreo é o coração do presídio: um salão de 52 × 54 studs sob o átrio de
    três pavimentos, com bancos, mesas de jogos, posto de guarda, detector de
    metais e acesso controlado a todas as alas.
]]

local Hall = {}
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

local function checkerBoard(
    parent: Instance,
    name: string,
    centerX: number,
    centerZ: number,
    size: number,
    y: number
)
    local squares = 4
    local step = size / squares
    for row = 1, squares do
        for column = 1, squares do
            local x = centerX - size * 0.5 + step * (column - 0.5)
            local z = centerZ - size * 0.5 + step * (row - 0.5)
            Kit.block(
                parent,
                string.format("%s casa %d-%d", name, row, column),
                CFrame.new(x, y + 0.025, z),
                Vector3.new(step - 0.05, 0.05, step - 0.05),
                if (row + column) % 2 == 0 then P.OakDark else P.Paper,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for index, spec in
        {
            {
                axis = "X",
                from = centerX - size * 0.5,
                to = centerX + size * 0.5,
                fixed = centerZ - size * 0.5,
            },
            {
                axis = "X",
                from = centerX - size * 0.5,
                to = centerX + size * 0.5,
                fixed = centerZ + size * 0.5,
            },
            {
                axis = "Z",
                from = centerZ - size * 0.5,
                to = centerZ + size * 0.5,
                fixed = centerX - size * 0.5,
            },
            {
                axis = "Z",
                from = centerZ - size * 0.5,
                to = centerZ + size * 0.5,
                fixed = centerX + size * 0.5,
            },
        }
    do
        if spec.axis == "X" then
            box(
                parent,
                "Moldura do tabuleiro " .. index,
                spec.from,
                spec.to,
                y + 0.01,
                y + 0.07,
                spec.fixed - 0.15,
                spec.fixed + 0.15,
                P.Walnut,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        else
            box(
                parent,
                "Moldura do tabuleiro " .. index,
                spec.fixed - 0.15,
                spec.fixed + 0.15,
                y + 0.01,
                y + 0.07,
                spec.from,
                spec.to,
                P.Walnut,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
end

local function gameTable(parent: Instance, name: string, x: number, z: number)
    Furniture.table(parent, name, CFrame.new(x, 0.08, z), 5.6, 3.2, 3.0, P.Oak, M.wood)
    checkerBoard(parent, name .. " tabuleiro", x, z, 2.2, 3.05)
    for index, spec in
        {
            { x = x - 1.5, z = z - 2.6 },
            { x = x + 1.5, z = z - 2.6 },
            { x = x - 1.5, z = z + 2.6 },
            { x = x + 1.5, z = z + 2.6 },
        }
    do
        Furniture.stool(
            parent,
            string.format("%s banco %d", name, index),
            CFrame.new(spec.x, 0.08, spec.z),
            P.Walnut,
            M.wood
        )
    end
end

local function wainscotWest(parent: Instance)
    local segments = {
        { -27, -22.2 },
        { -15.8, 7.8 },
        { 14.2, 17.8 },
        { 24.2, 27 },
    }
    for index, segment in segments do
        box(
            parent,
            "Lambri oeste " .. index,
            -26.05,
            -25.7,
            0.35,
            3.35,
            segment[1],
            segment[2],
            P.Green,
            M.paint,
            { collide = false, query = false, shadow = false }
        )
        box(
            parent,
            "Chair rail oeste " .. index,
            -25.85,
            -25.55,
            3.38,
            3.6,
            segment[1],
            segment[2],
            P.OakDark,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function wainscotEast(parent: Instance)
    local segments = {
        { -27, -20.2 },
        { -13.8, 6.8 },
        { 13.2, 17.8 },
        { 24.2, 27 },
    }
    for index, segment in segments do
        box(
            parent,
            "Lambri leste " .. index,
            25.7,
            26.05,
            0.35,
            3.35,
            segment[1],
            segment[2],
            P.Green,
            M.paint,
            { collide = false, query = false, shadow = false }
        )
        box(
            parent,
            "Chair rail leste " .. index,
            25.55,
            25.85,
            3.38,
            3.6,
            segment[1],
            segment[2],
            P.OakDark,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Hall.build(parent: Instance): Model
    local root = Kit.model(parent, "HallCentral")
    root:SetAttribute("AreaM2", math.floor((52 * 54) / (Layout.studsPerMeter ^ 2)))

    -- Piso e tapete central de cantaria.
    box(root, "Piso do hall", -26, 26, 0.01, 0.08, -27, 27, P.TerrazzoLight, M.ceramic, nil)
    box(
        root,
        "Faixa perimetral sul",
        -26,
        26,
        0.02,
        0.1,
        22.5,
        24.5,
        P.GreenDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Faixa perimetral norte",
        -26,
        26,
        0.02,
        0.1,
        -24.5,
        -22.5,
        P.GreenDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Faixa perimetral oeste",
        -24.5,
        -22.5,
        0.02,
        0.1,
        -22.5,
        22.5,
        P.GreenDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Faixa perimetral leste",
        22.5,
        24.5,
        0.02,
        0.1,
        -22.5,
        22.5,
        P.GreenDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Medalhão central",
        -10,
        10,
        0.025,
        0.11,
        -7,
        7,
        P.Stone,
        M.stone,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Moldura do medalhão",
        -11,
        11,
        0.03,
        0.12,
        -8,
        8,
        P.StoneDark,
        M.stone,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Interior do medalhão",
        -9.5,
        9.5,
        0.04,
        0.13,
        -6.5,
        6.5,
        P.StoneLight,
        M.stone,
        { collide = false, query = false, shadow = false }
    )

    wainscotWest(root)
    wainscotEast(root)

    -- Bancos junto às paredes, fora do eixo das portas.
    for index, spec in
        {
            { x = -21.5, z = -17.5, length = 7 },
            { x = -21.5, z = 3.5, length = 7 },
            { x = 21.5, z = -16.5, length = 7 },
            { x = 21.5, z = 3.0, length = 7 },
            { x = -8.5, z = 24.8, length = 9 },
            { x = 8.5, z = 24.8, length = 9 },
            { x = -8.5, z = -24.8, length = 9 },
            { x = 8.5, z = -24.8, length = 9 },
        }
    do
        Furniture.bench(
            root,
            "Banco do hall " .. index,
            CFrame.new(spec.x, 0.08, spec.z)
                * CFrame.Angles(
                    0,
                    math.rad(
                        if spec.z > 20
                            then 180
                            elseif spec.z < -20 then 0
                            elseif spec.x > 0 then -90
                            else 90
                    ),
                    0
                ),
            spec.length,
            P.Oak,
            M.wood
        )
    end

    -- Mesas de jogos no centro do salão.
    gameTable(root, "Mesa de damas 1", -8, -8)
    gameTable(root, "Mesa de damas 2", 8, -8)
    gameTable(root, "Mesa de dominó 1", -8, 8)
    gameTable(root, "Mesa de dominó 2", 8, 8)

    -- Posto de guarda junto à entrada.
    box(root, "Plataforma do posto de guarda", -5, 5, 0.08, 0.7, 15.5, 19.5, P.OakDark, M.wood, nil)
    box(root, "Balcão do posto", -5, 5, 0.7, 3.4, 15.2, 16.0, P.Oak, M.wood, nil)
    box(root, "Frente do balcão", -5, 5, 0.7, 3.0, 19.0, 19.5, P.Oak, M.wood, nil)
    Kit.block(
        root,
        "Campainha do posto",
        CFrame.new(3.8, 3.65, 15.6),
        Vector3.new(0.5, 0.2, 0.5),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Livro de registro",
        CFrame.new(-2.3, 3.6, 15.6),
        Vector3.new(1.5, 0.22, 0.9),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Rádio do posto",
        CFrame.new(1.6, 3.9, 15.6),
        Vector3.new(1.0, 0.8, 0.7),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Antena do rádio",
        CFrame.new(1.6, 4.6, 15.6),
        Vector3.new(0.08, 1.1, 0.08),
        P.Steel,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Furniture.chair(
        root,
        "Cadeira do posto",
        CFrame.new(0, 0.7, 17.0) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    -- Quadro de chaves atrás do posto.
    box(root, "Quadro de chaves", -4.5, 4.5, 4.5, 8.0, 18.7, 19.0, P.Walnut, M.wood, nil)
    for row = 1, 5 do
        for column = 1, 7 do
            Kit.block(
                root,
                string.format("Chave %d-%d", row, column),
                CFrame.new(-3.7 + (column - 1) * 1.23, 6.9 - (row - 1) * 0.5, 18.62),
                Vector3.new(0.16, 0.28, 0.1),
                P.Brass,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Detector de metais antes da porta interna.
    for _, x in { -2.6, 2.6 } do
        box(
            root,
            "Coluna do detector",
            x - 0.25,
            x + 0.25,
            0.1,
            8.6,
            21.2,
            21.7,
            P.Iron,
            M.metal,
            nil
        )
        box(root, "Pé do detector", x - 0.7, x + 0.7, 0.1, 0.45, 21.0, 21.9, P.Iron, M.metal, nil)
    end
    box(root, "Travessa do detector", -3.1, 3.1, 8.3, 8.7, 21.2, 21.7, P.Iron, M.metal, nil)
    Kit.block(
        root,
        "Luz do detector",
        CFrame.new(0, 8.5, 21.4),
        Vector3.new(0.4, 0.22, 0.18),
        P.NeonGreen,
        M.neon,
        { collide = false, query = false, shadow = false }
    )

    -- Quadros de avisos e relógio.
    Furniture.noticeBoard(
        root,
        "Mural de avisos oeste",
        CFrame.new(-25.85, 6.0, -3.0) * CFrame.Angles(0, math.rad(90), 0),
        6.5,
        3.4
    )
    Furniture.noticeBoard(
        root,
        "Mural de avisos leste",
        CFrame.new(25.85, 6.0, -4.0) * CFrame.Angles(0, math.rad(-90), 0),
        6.0,
        3.2
    )
    Furniture.noticeBoard(
        root,
        "Mural de avisos sul",
        CFrame.new(0, 6.4, 25.85) * CFrame.Angles(0, math.rad(180), 0),
        5.5,
        3.0
    )
    Furniture.wallClock(
        root,
        "Relógio do hall",
        CFrame.new(0, 9.0, 26.1) * CFrame.Angles(0, math.rad(180), 0)
    )

    -- Fonte de água, lixeiras e extintores.
    box(root, "Fonte de água", -24.5, -23.5, 0.1, 3.0, -19.0, -17.6, P.StoneLight, M.stone, nil)
    box(root, "Cuba da fonte", -24.35, -23.65, 2.7, 3.1, -18.7, -17.9, P.SteelLight, M.metal, nil)
    Kit.block(
        root,
        "Botão da fonte",
        CFrame.new(-23.55, 2.9, -18.3),
        Vector3.new(0.16, 0.16, 0.16),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    for index, spec in
        {
            { x = -24.4, z = -13.5 },
            { x = 24.4, z = -13.5 },
            { x = -24.4, z = 13.5 },
            { x = 24.4, z = 13.5 },
            { x = -10.5, z = 26.0 },
            { x = 10.5, z = 26.0 },
        }
    do
        Kit.block(
            root,
            "Lixeira " .. index,
            CFrame.new(spec.x, 1.0, spec.z),
            Vector3.new(1.1, 2.0, 1.1),
            P.Iron,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Tampa da lixeira " .. index,
            CFrame.new(spec.x, 2.06, spec.z),
            Vector3.new(1.2, 0.14, 1.2),
            P.SteelDark,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, spec in
        {
            { name = "Extintor oeste", x = -25.4, z = -20.3, ry = 90 },
            { name = "Extintor leste", x = 25.4, z = -20.3, ry = -90 },
            { name = "Extintor sul", x = 5.5, z = 26.4, ry = 180 },
        }
    do
        Kit.block(
            root,
            spec.name,
            CFrame.new(spec.x, 3.0, spec.z) * CFrame.Angles(0, math.rad(spec.ry), 0),
            Vector3.new(0.6, 1.9, 0.45),
            P.BookRed,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Iluminação sob as galerias, onde o pé-direito é menor.
    for _, spec in
        {
            { x = -16, z = -23.5 },
            { x = 16, z = -23.5 },
            { x = -16, z = 23.5 },
            { x = 16, z = 23.5 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz do hall " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 12.0, spec.z),
            4.0,
            1.2,
            P.NeonWarm,
            1.0,
            15
        )
    end
    for _, spec in
        {
            { x = -18, z = 0 },
            { x = 18, z = 0 },
        }
    do
        Furniture.wallSconce(
            root,
            "Arandela do hall " .. spec.x,
            CFrame.new(spec.x, 7.2, spec.z)
                * CFrame.Angles(0, math.rad(if spec.x > 0 then -90 else 90), 0),
            P.NeonWarm,
            0.8,
            10
        )
    end

    return root
end

return Hall

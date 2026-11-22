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
    Biblioteca e sala de aula do primeiro pavimento.
    A biblioteca tem estantes de madeira, mesas de leitura, fichário e escada
    de bibliotecário. A sala de aula conserva carteiras enfileiradas, quadro
    negro, mesa do professor e material didático.
]]

local Biblioteca = {}
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

local function buildLibrary(parent: Instance)
    local root = Kit.model(parent, "Biblioteca")
    local y0 = 13
    local x1, x2, z1, z2 = -38.5, -22, -46, -27
    root:SetAttribute("VolumesAproximados", 620)
    root:SetAttribute("MesasDeLeitura", 2)

    box(root, "Piso da biblioteca", x1, x2, y0 + 0.02, y0 + 0.1, z1, z2, P.Oak, M.planks, nil)
    box(
        root,
        "Passadeira central",
        -33,
        -27,
        y0 + 0.1,
        y0 + 0.16,
        z1 + 1.0,
        z2 - 1.0,
        P.Carpet,
        M.carpet,
        { collide = false, query = false, shadow = false }
    )

    -- Estantes.
    Furniture.shelf(
        root,
        "Estante oeste",
        CFrame.new(x1 + 0.9, y0 + 0.1, -37.0) * CFrame.Angles(0, math.rad(90), 0),
        14.5,
        9.5,
        1.8,
        4,
        P.Walnut,
        M.wood,
        true
    )
    Furniture.shelf(
        root,
        "Estante norte",
        CFrame.new(-31.0, y0 + 0.1, z1 + 0.9),
        12.0,
        9.5,
        1.8,
        4,
        P.Walnut,
        M.wood,
        true
    )
    Furniture.shelf(
        root,
        "Estante leste",
        CFrame.new(x2 - 0.8, y0 + 0.1, -37.5) * CFrame.Angles(0, math.rad(-90), 0),
        11.0,
        8.5,
        1.6,
        4,
        P.Walnut,
        M.wood,
        false
    )
    for row = 1, 3 do
        Kit.block(
            root,
            "Livro de apoio " .. row,
            CFrame.new(x2 - 1.1, y0 + 2.0 + row * 1.6, -40.0 + row * 1.5),
            Vector3.new(1.0, 2.5, 1.0),
            if row % 2 == 0 then P.BookBlue else P.BookTan,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Mesas de leitura.
    for index, spec in
        {
            { x = -30.0, z = -39.0 },
            { x = -30.0, z = -34.5 },
        }
    do
        Furniture.table(
            root,
            "Mesa de leitura " .. index,
            CFrame.new(spec.x, y0 + 0.1, spec.z),
            7.0,
            3.0,
            3.1,
            P.Oak,
            M.wood
        )
        for _, sideSpec in { { side = 1, sign = -1 }, { side = 2, sign = 1 } } do
            for seat = 1, 2 do
                Furniture.chair(
                    root,
                    string.format("Cadeira da mesa %d — %d-%d", index, sideSpec.side, seat),
                    CFrame.new(
                        spec.x - 2.0 + (seat - 1) * 4.0,
                        y0 + 0.1,
                        spec.z + sideSpec.sign * 2.6
                    )
                        * CFrame.Angles(0, math.rad(if sideSpec.sign > 0 then 180 else 0), 0),
                    P.Walnut,
                    M.wood
                )
            end
        end
        Kit.block(
            root,
            "Luminária da mesa " .. index,
            CFrame.new(spec.x, y0 + 3.9, spec.z),
            Vector3.new(2.2, 0.55, 0.55),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.pointLight(
            root:FindFirstChild("Luminária da mesa " .. index),
            P.NeonWarm,
            { name = "Luz de leitura", brightness = 0.5, range = 8, shadows = false }
        )
        Kit.block(
            root,
            "Livro aberto " .. index,
            CFrame.new(spec.x - 1.4, y0 + 3.35, spec.z),
            Vector3.new(1.8, 0.16, 1.2),
            P.Paper,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Balcão do bibliotecário e fichário.
    Furniture.desk(
        root,
        "Balcão do bibliotecário",
        CFrame.new(-24.5, y0 + 0.1, -35.0) * CFrame.Angles(0, math.rad(90), 0),
        5.0,
        2.2,
        3.2,
        P.Walnut,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do bibliotecário",
        CFrame.new(-26.3, y0 + 0.1, -35.0) * CFrame.Angles(0, math.rad(-90), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Livro de registro da biblioteca",
        CFrame.new(-25.5, y0 + 3.6, -31.5),
        Vector3.new(1.4, 0.2, 0.9),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Carimbo da biblioteca",
        CFrame.new(-25.5, y0 + 3.55, -29.1),
        Vector3.new(0.3, 0.35, 0.3),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Corpo do fichário",
        CFrame.new(-24.6, y0 + 2.9, -43.9),
        Vector3.new(2.0, 5.8, 1.0),
        P.Walnut,
        M.wood,
        nil
    )
    for drawer = 1, 8 do
        Kit.block(
            root,
            "Gaveta do fichário " .. drawer,
            CFrame.new(-24.6, y0 + 0.9 + (drawer - 1) * 0.62, -43.25),
            Vector3.new(1.5, 0.5, 0.2),
            P.OakDark,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Puxador do fichário " .. drawer,
            CFrame.new(-24.6, y0 + 0.9 + (drawer - 1) * 0.62, -43.1),
            Vector3.new(0.3, 0.08, 0.08),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Escada de bibliotecário.
    box(
        root,
        "Trilho da escada",
        x1 + 2.0,
        x1 + 2.2,
        y0 + 9.4,
        y0 + 9.6,
        -44.0,
        -30.0,
        P.Iron,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Escada de bibliotecário",
        CFrame.new(x1 + 2.6, y0 + 4.7, -42.0),
        Vector3.new(0.6, 9.0, 1.2),
        P.OakDark,
        M.wood,
        nil
    )
    for step = 1, 6 do
        Kit.block(
            root,
            "Degrau da escada " .. step,
            CFrame.new(x1 + 2.6, y0 + 1.0 + (step - 1) * 1.5, -42.0),
            Vector3.new(1.0, 0.16, 0.9),
            P.Oak,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Murais e relógio.
    Furniture.noticeBoard(
        root,
        "Mural da biblioteca",
        CFrame.new(-31.0, y0 + 6.2, z1 + 0.05),
        6.0,
        3.0
    )
    Furniture.wallClock(root, "Relógio da biblioteca", CFrame.new(-35.0, y0 + 7.0, z1 + 0.05), 1)
    Furniture.plant(root, "Planta da biblioteca", CFrame.new(x2 - 1.5, y0 + 0.1, z1 + 1.4), 0.55)

    for index, spec in
        {
            { x = -31.0, z = -41.0 },
            { x = -28.0, z = -33.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da biblioteca " .. index,
            CFrame.new(spec.x, y0 + 12.0, spec.z),
            4.2,
            1.2,
            P.NeonWarm,
            0.9,
            12
        )
    end
    return root
end

local function buildClassroom(parent: Instance)
    local root = Kit.model(parent, "SalaDeAula")
    local y0 = 13
    local x1, x2, z1, z2 = 22, 38.5, -46, -27
    root:SetAttribute("Carteiras", 10)

    box(root, "Piso da sala de aula", x1, x2, y0 + 0.02, y0 + 0.1, z1, z2, P.Oak, M.planks, nil)
    box(
        root,
        "Corredor central",
        29.2,
        31.3,
        y0 + 0.1,
        y0 + 0.16,
        z1 + 1.0,
        z2 - 1.0,
        P.TerrazzoLight,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )

    -- Quadro-negro e mapa.
    box(
        root,
        "Quadro-negro",
        25.0,
        35.0,
        y0 + 2.0,
        y0 + 8.0,
        z1 + 0.05,
        z1 + 0.2,
        P.GreenDark,
        M.planks,
        nil
    )
    box(
        root,
        "Moldura do quadro",
        24.7,
        35.3,
        y0 + 1.7,
        y0 + 8.3,
        z1 + 0.02,
        z1 + 0.28,
        P.OakDark,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Giz",
        CFrame.new(34.0, y0 + 2.1, z1 + 0.35),
        Vector3.new(0.4, 0.12, 0.12),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Mapa-múndi",
        22.7,
        24.1,
        y0 + 3.0,
        y0 + 7.8,
        z1 + 0.02,
        z1 + 0.2,
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 5 do
        box(
            root,
            "Continente " .. index,
            22.8,
            23.9,
            y0 + 3.3 + (index - 1) * 0.85,
            y0 + 3.8 + (index - 1) * 0.85,
            z1 + 0.2,
            z1 + 0.25,
            if index % 2 == 0 then P.Grass else P.Ochre,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Carteiras enfileiradas.
    for row = 1, 4 do
        local z = -42.0 + (row - 1) * 3.0
        for column = 1, 2 do
            local x = 29.5 + (column - 1) * 6.5
            Furniture.table(
                root,
                string.format("Carteira %d-%d", row, column),
                CFrame.new(x, y0 + 0.1, z),
                3.4,
                1.9,
                2.8,
                P.Oak,
                M.wood
            )
            Furniture.chair(
                root,
                string.format("Cadeira da carteira %d-%d", row, column),
                CFrame.new(x, y0 + 0.1, z + 2.1) * CFrame.Angles(0, math.rad(180), 0),
                P.Walnut,
                M.wood
            )
            Kit.block(
                root,
                string.format("Caderno %d-%d", row, column),
                CFrame.new(x, y0 + 2.95, z),
                Vector3.new(1.3, 0.08, 1.0),
                P.Paper,
                M.paper,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Mesa do professor, estante e relógio.
    Furniture.desk(
        root,
        "Mesa do professor",
        CFrame.new(30.0, y0 + 0.1, -44.0) * CFrame.Angles(0, math.rad(180), 0),
        5.5,
        2.2,
        3.2,
        P.Walnut,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do professor",
        CFrame.new(30.0, y0 + 0.1, -42.0) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Livro do professor",
        CFrame.new(30.0, y0 + 3.55, -44.2),
        Vector3.new(1.5, 0.2, 1.0),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Furniture.shelf(
        root,
        "Estante da sala de aula",
        CFrame.new(x2 - 0.8, y0 + 0.1, -34.0) * CFrame.Angles(0, math.rad(-90), 0),
        9.0,
        8.0,
        1.5,
        3,
        P.Walnut,
        M.wood,
        false
    )
    for index = 1, 12 do
        Kit.block(
            root,
            "Livro didático " .. index,
            CFrame.new(
                x2 - 1.1,
                y0 + 1.0 + math.floor((index - 1) / 6) * 2.2,
                -38.0 + ((index - 1) % 6) * 1.0
            ),
            Vector3.new(0.75, 1.7, 0.85),
            if index % 3 == 0 then P.BookRed elseif index % 3 == 1 then P.BookBlue else P.BookGreen,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end
    Furniture.noticeBoard(
        root,
        "Mural da sala de aula",
        CFrame.new(25.0, y0 + 6.0, z2 - 0.05) * CFrame.Angles(0, math.rad(180), 0),
        5.0,
        2.8
    )
    Furniture.wallClock(
        root,
        "Relógio da sala de aula",
        CFrame.new(35.0, y0 + 7.0, z2 - 0.05) * CFrame.Angles(0, math.rad(180), 0),
        1
    )

    for index, spec in
        {
            { x = 27.0, z = -39.0 },
            { x = 34.0, z = -33.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da sala de aula " .. index,
            CFrame.new(spec.x, y0 + 12.0, spec.z),
            4.2,
            1.2,
            P.NeonCool,
            0.95,
            12
        )
    end
    return root
end

function Biblioteca.build(parent: Instance)
    buildLibrary(parent)
    buildClassroom(parent)
    return parent:FindFirstChild("Biblioteca") :: Model
end

return Biblioteca

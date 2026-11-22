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
    Cozinha industrial e copa.
    Galeria de cocção com três fogões, coifa, ilha de preparo, câmara fria,
    passagem aquecida para o refeitório, lava-louças, tríplice cuba e
    despensa. Piso de ladrilho industrial e paredes de azulejo até 1,5 m.
]]

local Cozinha = {}
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

local function range(parent: Instance, name: string, z: number)
    box(parent, name .. " corpo", -38.25, -35.1, 0.1, 3.3, z - 2.2, z + 2.2, P.Iron, M.iron, nil)
    box(
        parent,
        name .. " tampo",
        -38.35,
        -35.0,
        3.3,
        3.55,
        z - 2.3,
        z + 2.3,
        P.SteelDark,
        M.steel,
        nil
    )
    for row = 1, 2 do
        for column = 1, 2 do
            Kit.block(
                parent,
                string.format("%s queimador %d-%d", name, row, column),
                CFrame.new(-37.5 + (column - 1) * 1.35, 3.62, z - 0.8 + (row - 1) * 1.6),
                Vector3.new(0.95, 0.1, 0.95),
                P.SteelDark,
                M.steel,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for index = 1, 3 do
        box(
            parent,
            string.format("%s forno %d", name, index),
            -35.15,
            -35.0,
            0.7 + (index - 1) * 0.85,
            1.35 + (index - 1) * 0.85,
            z - 1.65,
            z + 1.65,
            P.SteelDark,
            M.steel,
            nil
        )
        Kit.block(
            parent,
            string.format("%s puxador %d", name, index),
            CFrame.new(-34.9, 1.03 + (index - 1) * 0.85, z),
            Vector3.new(0.12, 0.12, 2.4),
            P.SteelLight,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        parent,
        name .. " painel",
        -34.98,
        -34.86,
        3.55,
        4.3,
        z - 2.0,
        z + 2.0,
        P.SteelLight,
        M.steel,
        nil
    )
    for index = 1, 5 do
        Kit.block(
            parent,
            string.format("%s botão %d", name, index),
            CFrame.new(-34.8, 3.9, z - 1.2 + (index - 1) * 0.6),
            Vector3.new(0.12, 0.18, 0.18),
            P.Iron,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Cozinha.build(parent: Instance): Model
    local root = Kit.model(parent, "Cozinha")
    root:SetAttribute("AreaM2", math.floor((12.5 * 35) / (Layout.studsPerMeter ^ 2)))

    -- Piso de ladrilho cinza com canaleta de drenagem.
    for row = 1, 8 do
        for column = 1, 3 do
            local x = -38.5 + 12.5 / 3 * (column - 0.5)
            local z = -27 + 35 / 8 * (row - 0.5)
            box(
                root,
                string.format("Ladrilho da cozinha %d-%d", row, column),
                x - 12.5 / 6 + 0.05,
                x + 12.5 / 6 - 0.05,
                0.02,
                0.09,
                z - 35 / 16 + 0.05,
                z + 35 / 16 - 0.05,
                if (row + column) % 2 == 0 then P.TileGray else P.TileDark,
                M.ceramic,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(
        root,
        "Canaleta de drenagem",
        -36.0,
        -27.2,
        0.1,
        0.16,
        -17.5,
        -16.5,
        P.SteelDark,
        M.diamond,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 14 do
        box(
            root,
            "Grade da canaleta " .. index,
            -35.8 + index * 0.6,
            -35.65 + index * 0.6,
            0.16,
            0.2,
            -17.4,
            -16.6,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Azulejo branco nas paredes, até 1,5 m.
    box(
        root,
        "Azulejo oeste",
        -38.45,
        -38.2,
        0.35,
        6.0,
        -26.8,
        7.8,
        P.TileWhite,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Azulejo norte",
        -38.2,
        -26.4,
        0.35,
        6.0,
        -26.85,
        -26.6,
        P.TileWhite,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        box(
            root,
            "Junto do azulejo oeste " .. index,
            -38.2,
            -38.12,
            0.35 + index * 1.4,
            0.38 + index * 1.4,
            -26.8,
            7.8,
            P.Grout,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Linha de cocção: três fogões e coifa.
    for index, z in { -20.4, -14.4, -8.4 } do
        range(root, "Fogão " .. index, z)
    end
    box(root, "Coifa", -38.45, -34.2, 7.6, 10.8, -24.5, -6.6, P.Steel, M.steel, nil)
    box(root, "Filtros da coifa", -38.2, -34.4, 7.3, 7.65, -24.2, -6.9, P.SteelDark, M.diamond, nil)
    for index = 1, 7 do
        Kit.block(
            root,
            "Luz da coifa " .. index,
            CFrame.new(-36.3, 7.2, -23 + (index - 1) * 2.75),
            Vector3.new(2.7, 0.16, 0.5),
            P.NeonWarm,
            M.neon,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Duto da coifa", -37.2, -35.6, 10.8, 12.9, -18.5, -15.5, P.SteelDark, M.steel, nil)

    -- Ilha de preparo.
    Furniture.table(
        root,
        "Ilha de preparo",
        CFrame.new(-31.9, 0.09, -15.5) * CFrame.Angles(0, math.rad(90), 0),
        10.0,
        3.0,
        3.05,
        P.SteelLight,
        M.steel
    )
    for index, z in { -19.4, -16.9, -14.4, -11.9 } do
        Kit.block(
            root,
            "Tábua de corte " .. index,
            CFrame.new(-32.0, 3.35, z),
            Vector3.new(2.2, 0.15, 1.4),
            P.OakLight,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    for index = 1, 5 do
        Kit.block(
            root,
            "Tigela " .. index,
            CFrame.new(-31.4 + (index % 2) * 1.4, 3.6, -20.5 + index * 1.6),
            Vector3.new(0.75, 0.55, 0.75),
            P.SteelLight,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    -- Prateleira suspensa de panelas.
    box(root, "Prateleira de panelas", -33.4, -30.4, 8.2, 8.38, -19.5, -11.5, P.Iron, M.iron, nil)
    for index = 1, 6 do
        local x = -33.0 + ((index - 1) % 3) * 1.1
        local z = -18.5 + math.floor((index - 1) / 3) * 1.9
        Kit.block(
            root,
            "Panela " .. index,
            CFrame.new(x, 8.8, z),
            Vector3.new(0.85, 1.0, 0.85),
            P.Steel,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cuba dupla e bancada de lavagem.
    box(root, "Bancada de lavagem", -27.0, -26.15, 0.2, 3.1, -8.0, 2.0, P.SteelLight, M.steel, nil)
    for index, z in { -6.2, -3.0 } do
        box(
            root,
            "Cuba " .. index,
            -26.9,
            -26.25,
            2.95,
            3.15,
            z - 1.2,
            z + 1.2,
            P.Water,
            M.glass,
            { transparency = 0.22, collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Torneira da cuba " .. index,
            CFrame.new(-26.45, 3.75, z),
            Vector3.new(0.15, 1.25, 0.15),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Bica da cuba " .. index,
            CFrame.new(-26.8, 4.3, z),
            Vector3.new(0.7, 0.12, 0.12),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Câmara fria no extremo norte.
    box(root, "Câmara fria", -38.4, -31.0, 0.1, 8.8, -26.85, -23.1, P.SteelLight, M.metal, nil)
    box(
        root,
        "Porta da câmara fria",
        -31.2,
        -30.95,
        0.2,
        7.8,
        -25.8,
        -24.0,
        P.Steel,
        M.diamond,
        nil
    )
    Kit.block(
        root,
        "Puxador da câmara fria",
        CFrame.new(-30.8, 4.0, -24.9),
        Vector3.new(0.18, 1.4, 0.2),
        P.Iron,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Termômetro da câmara fria",
        CFrame.new(-30.78, 6.8, -25.8),
        Vector3.new(0.12, 0.5, 0.5),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )

    -- Prateleiras de utensílios e secagem.
    for index = 1, 4 do
        box(
            root,
            "Prateleira de utensílios " .. index,
            -38.2,
            -37.4,
            5.2 + index * 1.05,
            5.32 + index * 1.05,
            -4.0,
            6.0,
            P.Steel,
            M.metal,
            nil
        )
    end
    for index = 1, 8 do
        Kit.block(
            root,
            "Pote " .. index,
            CFrame.new(-37.7, 5.8 + (index % 4) * 1.05, -2.5 + math.floor((index - 1) / 4) * 1.4),
            Vector3.new(0.65, 0.8, 0.65),
            if index % 2 == 0 then P.Ceramic else P.SteelLight,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Passagem aquecida para o refeitório.
    box(root, "Bancada de passagem", -38.4, -37.2, 0.2, 3.3, -0.4, 4.4, P.SteelLight, M.steel, nil)
    for index, z in { 0.2, 1.8, 3.4 } do
        Kit.block(
            root,
            "Lâmpada da passagem " .. index,
            CFrame.new(-37.6, 6.2, z),
            Vector3.new(0.7, 0.16, 1.1),
            P.NeonWarm,
            M.neon,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.block(
        root,
        "Prateleira da passagem",
        CFrame.new(-37.7, 4.2, 2.0),
        Vector3.new(1.1, 0.16, 4.0),
        P.Steel,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Mesa do chefe de cozinha e quadro de ferramentas.
    Furniture.desk(
        root,
        "Mesa do chefe de cozinha",
        CFrame.new(-28.4, 0.09, 4.5) * CFrame.Angles(0, math.rad(-90), 0),
        4.2,
        2.0,
        3.1,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do chefe de cozinha",
        CFrame.new(-30.7, 0.09, 4.5) * CFrame.Angles(0, math.rad(90), 0),
        P.Walnut,
        M.wood
    )
    box(root, "Quadro de facas", -26.55, -26.45, 4.8, 7.3, -14.0, -9.0, P.SteelDark, M.diamond, nil)
    for index = 1, 5 do
        Kit.block(
            root,
            "Faca " .. index,
            CFrame.new(-26.4, 5.5, -13.4 + (index - 1) * 1.05),
            Vector3.new(0.06, 1.4, 0.22),
            P.SteelLight,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.block(
        root,
        "Extintor da cozinha",
        CFrame.new(-26.45, 2.7, 6.8),
        Vector3.new(0.55, 1.8, 0.45),
        P.BookRed,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Copa e lava-louças.
    for row = 1, 3 do
        for column = 1, 3 do
            local x = -38.5 + 12.5 / 3 * (column - 0.5)
            local z = 14 + 13 / 3 * (row - 0.5)
            box(
                root,
                string.format("Ladrilho da copa %d-%d", row, column),
                x - 12.5 / 6 + 0.05,
                x + 12.5 / 6 - 0.05,
                0.02,
                0.09,
                z - 13 / 6 + 0.05,
                z + 13 / 6 - 0.05,
                if (row + column) % 2 == 0 then P.TileGray else P.TileCream,
                M.ceramic,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(root, "Lava-louças", -38.35, -34.8, 0.1, 5.6, 15.0, 20.0, P.SteelLight, M.metal, nil)
    box(
        root,
        "Porta do lava-louças",
        -34.85,
        -34.72,
        1.2,
        4.9,
        15.6,
        19.4,
        P.SteelDark,
        M.diamond,
        nil
    )
    for index = 1, 3 do
        Kit.block(
            root,
            "Cesto de pratos " .. index,
            CFrame.new(-36.3, 5.9, 16.2 + (index - 1) * 1.4),
            Vector3.new(2.5, 0.7, 1.1),
            P.MetalTray,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Bancada da copa", -27.0, -26.15, 0.2, 3.0, 21.0, 26.5, P.SteelLight, M.steel, nil)
    for index, z in { 22.0, 24.3 } do
        box(
            root,
            "Cuba da copa " .. index,
            -26.9,
            -26.3,
            2.85,
            3.05,
            z - 0.9,
            z + 0.9,
            P.Water,
            M.glass,
            { transparency = 0.22, collide = false, query = false, shadow = false }
        )
    end
    for index = 1, 5 do
        box(
            root,
            "Prateleira da copa " .. index,
            -38.3,
            -37.6,
            1.6 + index * 0.9,
            1.7 + index * 0.9,
            21.0,
            26.4,
            P.Steel,
            M.metal,
            nil
        )
    end
    for index = 1, 10 do
        Kit.block(
            root,
            "Prato " .. index,
            CFrame.new(
                -37.9,
                2.55 + math.floor((index - 1) / 5) * 0.9,
                21.8 + ((index - 1) % 5) * 1.05
            ),
            Vector3.new(0.9, 0.12, 0.9),
            P.Ceramic,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        root,
        "Mesa de apoio da copa",
        -32.5,
        -28.0,
        0.2,
        3.05,
        22.0,
        24.0,
        P.SteelLight,
        M.steel,
        nil
    )
    for index = 1, 3 do
        Kit.block(
            root,
            "Pote de mantimentos " .. index,
            CFrame.new(-31.0 + index * 1.0, 3.6, 23.0),
            Vector3.new(0.8, 1.1, 0.8),
            P.CeramicBlue,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Lixeira da copa", -27.4, -26.4, 0.1, 2.6, 18.0, 19.0, P.Iron, M.metal, nil)
    Kit.block(
        root,
        "Vassoura",
        CFrame.new(-26.5, 3.6, 26.0),
        Vector3.new(0.14, 4.5, 0.14),
        P.Oak,
        M.wood,
        { collide = false, query = false, shadow = false }
    )

    -- Iluminação.
    for _, spec in
        {
            { x = -32.5, z = -22 },
            { x = -32.5, z = -12 },
            { x = -32.5, z = 0 },
            { x = -33.0, z = 20 },
            { x = -33.0, z = 25 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da cozinha " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 12.0, spec.z),
            4.2,
            1.2,
            P.NeonCool,
            1.05,
            13
        )
    end

    return root
end

return Cozinha

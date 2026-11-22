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
    Lavanderia industrial.
    Quatro máquinas de lavar de carga frontal, mesas de triagem, carrinhos,
    prateleiras de roupa de cama, caldeiras de vapor e bancada de costura.
]]

local Lavanderia = {}
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

local function washer(parent: Instance, name: string, z: number, twin: boolean?)
    local x1 = 34.6
    local x2 = 38.3
    box(parent, name .. " corpo", x1, x2, 0.15, 6.0, z - 2.3, z + 2.3, P.SteelLight, M.metal, nil)
    box(parent, name .. " rodapé", x1, x2 + 0.05, 0.15, 0.6, z - 2.2, z + 2.2, P.Iron, M.iron, nil)
    box(
        parent,
        name .. " porta",
        x1 - 0.12,
        x1 + 0.08,
        1.1,
        4.6,
        z - 1.45,
        z + 1.45,
        P.SteelDark,
        M.steel,
        nil
    )
    box(
        parent,
        name .. " vigia",
        x1 - 0.17,
        x1 - 0.08,
        1.7,
        4.0,
        z - 1.0,
        z + 1.0,
        P.GlassSmoke or P.Glass,
        M.glass,
        { transparency = 0.42, collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " puxador",
        CFrame.new(x1 - 0.25, 2.85, z + 1.75),
        Vector3.new(0.12, 0.6, 0.12),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    box(
        parent,
        name .. " painel",
        x1 + 0.02,
        x1 + 0.14,
        4.9,
        5.7,
        z - 1.8,
        z + 1.8,
        P.Steel,
        M.steel,
        nil
    )
    for index = 1, 4 do
        Kit.block(
            parent,
            string.format("%s botão %d", name, index),
            CFrame.new(x1 - 0.02, 5.35, z - 1.3 + (index - 1) * 0.85),
            Vector3.new(0.08, 0.2, 0.2),
            if index == 1 then P.NeonGreen else P.Iron,
            if index == 1 then M.neon else M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    if twin then
        box(parent, name .. " secadora", x1, x2, 6.2, 10.8, z - 2.1, z + 2.1, P.Steel, M.metal, nil)
        box(
            parent,
            name .. " porta da secadora",
            x1 - 0.1,
            x1 + 0.05,
            7.0,
            9.9,
            z - 1.3,
            z + 1.3,
            P.SteelDark,
            M.diamond,
            nil
        )
        box(
            parent,
            name .. " vigia da secadora",
            x1 - 0.16,
            x1 - 0.1,
            7.5,
            9.4,
            z - 0.8,
            z + 0.8,
            P.GlassSmoke or P.Glass,
            M.glass,
            { transparency = 0.5, collide = false, query = false, shadow = false }
        )
    end
end

function Lavanderia.build(parent: Instance): Model
    local root = Kit.model(parent, "Lavanderia")
    root:SetAttribute("AreaM2", math.floor((12.5 * 34) / (Layout.studsPerMeter ^ 2)))

    -- Piso lavável com ralos.
    for row = 1, 9 do
        for column = 1, 3 do
            local x = 26 + 12.5 / 3 * (column - 0.5)
            local z = -27 + 34 / 9 * (row - 0.5)
            box(
                root,
                string.format("Ladrilho da lavanderia %d-%d", row, column),
                x - 12.5 / 6 + 0.05,
                x + 12.5 / 6 - 0.05,
                0.02,
                0.08,
                z - 34 / 18 + 0.05,
                z + 34 / 18 - 0.05,
                if (row + column) % 2 == 0 then P.TileGray else P.TileCream,
                M.ceramic,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for index, spec in
        {
            { x = 30.0, z = -18.0 },
            { x = 36.0, z = 2.0 },
        }
    do
        box(
            root,
            "Ralo " .. index,
            spec.x - 1.0,
            spec.x + 1.0,
            0.08,
            0.13,
            spec.z - 1.0,
            spec.z + 1.0,
            P.SteelDark,
            M.diamond,
            { collide = false, query = false, shadow = false }
        )
        for bar = 1, 4 do
            box(
                root,
                string.format("Grade do ralo %d-%d", index, bar),
                spec.x - 0.9,
                spec.x + 0.9,
                0.13,
                0.17,
                spec.z - 0.9 + bar * 0.45,
                spec.z - 0.8 + bar * 0.45,
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Quatro lavadoras, duas com secadora empilhada.
    washer(root, "Lavadora 1", -22.0, true)
    washer(root, "Lavadora 2", -15.7, false)
    washer(root, "Lavadora 3", -9.4, true)
    washer(root, "Lavadora 4", -3.1, false)

    -- Mesas de triagem.
    for index, z in { -22.0, -10.0, 1.0 } do
        Furniture.table(
            root,
            "Mesa de triagem " .. index,
            CFrame.new(31.5, 0.08, z),
            5.2,
            2.4,
            3.0,
            P.SteelLight,
            M.steel
        )
        for pile = 1, 3 do
            Kit.block(
                root,
                string.format("Pilha de roupa %d-%d", index, pile),
                CFrame.new(30.4 + (pile - 1) * 1.4, 3.45, z + 0.2),
                Vector3.new(1.0, 0.75, 1.8),
                if pile % 2 == 0 then P.Linen else P.LinenWhite,
                M.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Prateleiras de roupa limpa na parede oeste, com vão para a porta.
    for index = 1, 4 do
        box(
            root,
            "Prateleira de roupa norte " .. index,
            26.2,
            28.2,
            1.2 + index * 1.55,
            1.32 + index * 1.55,
            -25.5,
            -22.5,
            P.Steel,
            M.metal,
            nil
        )
        box(
            root,
            "Prateleira de roupa sul " .. index,
            26.2,
            28.2,
            1.2 + index * 1.55,
            1.32 + index * 1.55,
            -13.0,
            5.5,
            P.Steel,
            M.metal,
            nil
        )
        for pile = 1, 4 do
            Kit.block(
                root,
                string.format("Lençol norte %d-%d", index, pile),
                CFrame.new(27.2, 1.85 + index * 1.55, -24.8 + (pile - 1) * 0.9),
                Vector3.new(1.6, 0.6, 0.75),
                if pile % 2 == 0 then P.Linen else P.LinenWhite,
                M.fabric,
                { collide = false, query = false, shadow = false }
            )
            Kit.block(
                root,
                string.format("Lençol sul %d-%d", index, pile),
                CFrame.new(27.2, 1.85 + index * 1.55, -11.8 + (pile - 1) * 4.0),
                Vector3.new(1.6, 0.6, 2.3),
                if pile % 2 == 0 then P.Linen else P.LinenWhite,
                M.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Carrinhos de roupa.
    for index, spec in
        {
            { x = 30.0, z = -25.0 },
            { x = 30.0, z = -7.8 },
            { x = 33.0, z = -25.0 },
        }
    do
        box(
            root,
            "Carrinho " .. index,
            spec.x - 1.8,
            spec.x + 1.8,
            0.3,
            1.0,
            spec.z - 1.2,
            spec.z + 1.2,
            P.SteelDark,
            M.metal,
            nil
        )
        for _, corner in
            {
                { x = spec.x - 1.5, z = spec.z - 0.9 },
                { x = spec.x + 1.5, z = spec.z - 0.9 },
                { x = spec.x - 1.5, z = spec.z + 0.9 },
                { x = spec.x + 1.5, z = spec.z + 0.9 },
            }
        do
            box(
                root,
                "Roda " .. index,
                corner.x - 0.22,
                corner.x + 0.22,
                0.1,
                0.34,
                corner.z - 0.22,
                corner.z + 0.22,
                P.Iron,
                M.metal,
                nil
            )
        end
        box(
            root,
            "Carga do carrinho " .. index,
            spec.x - 1.6,
            spec.x + 1.6,
            1.0,
            3.1,
            spec.z - 1.0,
            spec.z + 1.0,
            P.Linen,
            M.fabric,
            nil
        )
    end

    -- Caldeira e tubulação de vapor.
    box(root, "Caldeira da lavanderia", 33.5, 38.2, 0.2, 5.6, 3.0, 6.6, P.Steel, M.metal, nil)
    box(root, "Porta da caldeira", 33.4, 33.55, 1.0, 4.4, 4.0, 5.8, P.SteelDark, M.diamond, nil)
    for index = 1, 3 do
        box(
            root,
            "Tubulação de vapor " .. index,
            26.4,
            38.2,
            10.0 + index * 0.7,
            10.3 + index * 0.7,
            -23.0,
            -22.6,
            P.Steel,
            M.metal,
            nil
        )
    end
    for index, z in { -18.0, -7.0, 3.5 } do
        box(
            root,
            "Coluna de vapor " .. index,
            26.4,
            26.7,
            3.0,
            11.2,
            z - 0.15,
            z + 0.15,
            P.Steel,
            M.metal,
            nil
        )
        Kit.block(
            root,
            "Válvula " .. index,
            CFrame.new(27.0, 6.0, z),
            Vector3.new(0.8, 0.3, 0.3),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Bancada de costura e utensílios.
    Furniture.table(
        root,
        "Bancada de costura",
        CFrame.new(33.0, 0.08, 0.0) * CFrame.Angles(0, math.rad(90), 0),
        6.0,
        2.2,
        3.1,
        P.Oak,
        M.wood
    )
    Kit.block(
        root,
        "Máquina de costura",
        CFrame.new(33.2, 3.8, -0.5),
        Vector3.new(1.7, 1.2, 1.1),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    -- Armário de produtos e lavatório de serviço.
    Furniture.cabinet(
        root,
        "Armário de produtos",
        CFrame.new(30.5, 0.08, 3.6),
        4.0,
        6.0,
        2.0,
        P.SteelDark,
        M.metal
    )
    Furniture.sink(
        root,
        "Lavatório de serviço",
        CFrame.new(31.0, 0.08, 6.2) * CFrame.Angles(0, math.rad(180), 0)
    )
    Kit.block(
        root,
        "Balde de limpeza",
        CFrame.new(29.0, 1.2, 6.2),
        Vector3.new(1.1, 2.2, 1.1),
        P.Ochre,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Ventilação e iluminação.
    for index, z in { -21.0, -9.0, 2.0 } do
        box(
            root,
            "Grelha de ventilação " .. index,
            38.0,
            38.3,
            10.8,
            12.2,
            z - 1.4,
            z + 1.4,
            P.Iron,
            M.metal,
            nil
        )
        for bar = 1, 5 do
            box(
                root,
                string.format("Aleta %d-%d", index, bar),
                37.97,
                38.02,
                10.9 + bar * 0.22,
                11.0 + bar * 0.22,
                z - 1.3,
                z + 1.3,
                P.Steel,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for _, spec in
        {
            { x = 32.0, z = -22.0 },
            { x = 32.0, z = -10.0 },
            { x = 32.0, z = 2.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da lavanderia " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 12.0, spec.z),
            4.4,
            1.2,
            P.NeonCool,
            1.0,
            13
        )
    end

    return root
end

return Lavanderia

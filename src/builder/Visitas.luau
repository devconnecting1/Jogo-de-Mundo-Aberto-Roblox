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
    Sala de visitas.
    Quatro cabines com vidro de segurança, balcões de ambos os lados,
    telefones, banco de espera, armários para visitantes e posto de guarda.
    O público entra pela recepção; o detento entra pela galeria do hall.
]]

local Visitas = {}
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

function Visitas.build(parent: Instance): Model
    local root = Kit.model(parent, "Visitas")
    local y0 = 0
    root:SetAttribute("Cabines", 4)

    -- Piso diferenciado para público e detentos.
    box(root, "Piso do público", -38.5, -10, 0.02, 0.1, 32.1, 36.5, P.TileCream, M.ceramic, nil)
    box(root, "Piso dos detentos", -38.5, -10, 0.02, 0.1, 27, 31.9, P.TileGray, M.ceramic, nil)
    box(
        root,
        "Faixa de divisa",
        -38.5,
        -10,
        0.1,
        0.16,
        31.9,
        32.1,
        P.GreenDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )

    -- Divisória de vidro e balcões.
    box(root, "Balcão baixo", -36, -12, 0.2, 3.0, 31.6, 32.4, P.Walnut, M.wood, nil)
    box(root, "Tampo do balcão", -36.2, -11.8, 3.0, 3.25, 31.5, 32.5, P.Marble, M.marble, nil)
    local boothXs = { -33.0, -27.0, -21.0, -15.0 }
    for index, x in boothXs do
        for _, xPost in { x - 2.6, x + 2.6 } do
            box(
                root,
                string.format("Montante de vidro %d", xPost),
                xPost - 0.12,
                xPost + 0.12,
                3.25,
                9.6,
                31.94,
                32.06,
                P.Iron,
                M.iron,
                nil
            )
        end
        box(
            root,
            "Vidro da cabine " .. index,
            x - 2.45,
            x + 2.45,
            3.4,
            9.4,
            31.95,
            32.05,
            P.Glass,
            M.glass,
            { transparency = 0.6, collide = false, query = false, shadow = false }
        )
        box(
            root,
            "Travessa da cabine " .. index,
            x - 2.5,
            x + 2.5,
            6.2,
            6.4,
            31.92,
            32.08,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        for _, phone in { { label = "detento", z = 31.62 }, { label = "público", z = 32.38 } } do
            Kit.block(
                root,
                string.format("Telefone da cabine %d — %s", index, phone.label),
                CFrame.new(x, 3.95, phone.z),
                Vector3.new(0.45, 0.55, 0.45),
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
            Kit.block(
                root,
                string.format("Fone da cabine %d — %s", index, phone.label),
                CFrame.new(x, 4.35, phone.z),
                Vector3.new(0.7, 0.18, 0.18),
                P.IronLight,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
        Kit.block(
            root,
            "Abertura de documentos " .. index,
            CFrame.new(x, 3.85, 32.0),
            Vector3.new(1.0, 0.16, 0.1),
            P.WalnutDeep,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
        Furniture.stool(
            root,
            "Banco do público " .. index,
            CFrame.new(x, 0.1, 33.0),
            P.Oak,
            M.wood
        )
        Furniture.stool(
            root,
            "Banco do detento " .. index,
            CFrame.new(x, 0.1, 30.7) * CFrame.Angles(0, math.rad(180), 0),
            P.Walnut,
            M.wood
        )
        Kit.block(
            root,
            "Número da cabine " .. index,
            CFrame.new(x, 8.8, 32.12),
            Vector3.new(0.8, 0.8, 0.06),
            P.Paper,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Barreira de segurança acima dos vidros.
    box(
        root,
        "Travessa superior de segurança",
        -36,
        -12,
        9.5,
        9.9,
        31.9,
        32.1,
        P.Iron,
        M.iron,
        nil
    )
    for x = -35, -13, 2 do
        box(
            root,
            "Grade superior " .. x,
            x - 0.06,
            x + 0.06,
            9.5,
            12.1,
            31.96,
            32.04,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Mesa de cadastro no lado público; o banco de espera fica na entrada.
    Furniture.table(
        root,
        "Mesa de cadastro",
        CFrame.new(-33.5, 0.1, 35.1),
        4.0,
        1.8,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(root, "Cadeira do cadastro", CFrame.new(-33.5, 0.1, 33.7), P.Walnut, M.wood)
    Kit.block(
        root,
        "Livro de visitas",
        CFrame.new(-34.2, 3.4, 35.1),
        Vector3.new(1.2, 0.2, 0.8),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Carimbo de visitas",
        CFrame.new(-32.8, 3.4, 35.1),
        Vector3.new(0.3, 0.35, 0.3),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Posto de guarda no lado dos detentos.
    Furniture.desk(
        root,
        "Posto do guarda de visitas",
        CFrame.new(-36.2, 0.1, 29.5) * CFrame.Angles(0, math.rad(90), 0),
        4.0,
        2.0,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do guarda de visitas",
        CFrame.new(-34.4, 0.1, 29.5) * CFrame.Angles(0, math.rad(-90), 0),
        P.Leather,
        M.leather
    )
    Kit.block(
        root,
        "Rádio do guarda de visitas",
        CFrame.new(-36.2, 3.4, 30.2),
        Vector3.new(0.9, 0.6, 0.6),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Murais, relógio e sinalização.
    Furniture.noticeBoard(root, "Mural de visitas", CFrame.new(-24.0, 6.0, 27.15), 7.0, 3.2)
    Furniture.wallClock(root, "Relógio de visitas", CFrame.new(-18.0, 7.6, 27.1), 1)
    Furniture.portrait(root, "Normas de visita", CFrame.new(-31.0, 6.2, 27.1), 3.6, 2.6)

    -- Iluminação.
    for _, spec in
        {
            { x = -32.0, z = 30.0 },
            { x = -22.0, z = 30.0 },
            { x = -32.0, z = 34.5 },
            { x = -22.0, z = 34.5 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz de visitas " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 11.9, spec.z),
            3.8,
            1.1,
            P.NeonCool,
            0.9,
            10
        )
    end
    Furniture.wallSconce(
        root,
        "Arandela de visitas",
        CFrame.new(-38.35, 6.2, 34.0) * CFrame.Angles(0, math.rad(90), 0),
        P.NeonWarm,
        0.5,
        7
    )

    return root
end

return Visitas

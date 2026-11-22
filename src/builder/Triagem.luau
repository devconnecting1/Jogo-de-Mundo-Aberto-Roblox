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
    Triagem e cela de espera.
    Balcão de registro com ficha, quadro de altura, câmera, armários de
    pertences e duas celas curtas para detentos à espera de classificação.
]]

local Triagem = {}
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

local function holdingCell(parent: Instance, name: string, x1: number, x2: number)
    box(
        parent,
        name .. " piso",
        x1 + 0.1,
        x2 - 0.1,
        0.02,
        0.1,
        31.4,
        36.4,
        P.TileDark,
        M.ceramic,
        nil
    )
    -- Cama baixa e sanitário.
    box(
        parent,
        name .. " cama",
        x1 + 0.2,
        x2 - 0.2,
        0.1,
        1.55,
        34.9,
        36.3,
        P.BlanketGrey,
        M.fabric,
        nil
    )
    box(
        parent,
        name .. " colchão",
        x1 + 0.35,
        x2 - 0.35,
        1.55,
        1.85,
        35.1,
        36.15,
        P.Linen,
        M.fabric,
        nil
    )
    Kit.block(
        parent,
        name .. " sanitário",
        CFrame.new(x1 + 1.2, 1.0, 32.3),
        Vector3.new(1.4, 1.8, 1.8),
        P.Ceramic,
        M.ceramic,
        nil
    )
    Kit.block(
        parent,
        name .. " lavatório",
        CFrame.new(x2 - 0.8, 1.5, 32.3),
        Vector3.new(0.8, 0.6, 1.2),
        P.Ceramic,
        M.ceramic,
        nil
    )
    Kit.block(
        parent,
        name .. " espelho",
        CFrame.new(x2 - 0.06, 3.2, 32.3),
        Vector3.new(0.08, 1.2, 1.0),
        P.SteelLight,
        M.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.2 }
    )
    for _, spec in
        {
            { z = 31.55, w = 5.0 },
        }
    do
        box(
            parent,
            name .. " grade de ventilação",
            x1 + 0.5,
            x2 - 0.5,
            8.8,
            10.6,
            31.42,
            31.5,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        for index = 1, 5 do
            box(
                parent,
                name .. " barra de ventilação " .. index,
                x1 + 0.7 + (index - 1) * (x2 - x1 - 1.2) / 5,
                x1 + 0.78 + (index - 1) * (x2 - x1 - 1.2) / 5,
                8.9,
                10.5,
                31.46,
                31.56,
                P.IronLight,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end
end

local function steelDoor(parent: Instance, name: string, x1: number, x2: number)
    local z = 31.2
    box(
        parent,
        name .. " folha",
        x1 + 0.15,
        x2 - 0.15,
        0.1,
        8.7,
        z - 0.14,
        z + 0.14,
        P.SteelDark,
        M.iron,
        nil
    )
    box(
        parent,
        name .. " janela",
        x1 + 0.8,
        x2 - 0.8,
        5.7,
        7.9,
        z + 0.14,
        z + 0.2,
        P.Iron,
        M.steel,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        box(
            parent,
            name .. " grade " .. index,
            x1 + 0.9 + (index - 1) * (x2 - x1 - 1.8) / 4,
            x1 + 0.98 + (index - 1) * (x2 - x1 - 1.8) / 4,
            5.8,
            7.8,
            z + 0.21,
            z + 0.27,
            P.IronLight,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        parent,
        name .. " seteira",
        x1 + 0.9,
        x2 - 0.9,
        3.3,
        3.62,
        z + 0.15,
        z + 0.22,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    box(
        parent,
        name .. " marco esquerdo",
        x1 - 0.18,
        x1 + 0.08,
        0,
        9.0,
        z - 0.22,
        z + 0.22,
        P.Iron,
        M.iron,
        nil
    )
    box(
        parent,
        name .. " marco direito",
        x2 - 0.08,
        x2 + 0.18,
        0,
        9.0,
        z - 0.22,
        z + 0.22,
        P.Iron,
        M.iron,
        nil
    )
    box(
        parent,
        name .. " padieira",
        x1 - 0.18,
        x2 + 0.18,
        8.7,
        9.0,
        z - 0.22,
        z + 0.22,
        P.Iron,
        M.iron,
        nil
    )
    Kit.block(
        parent,
        name .. " puxador",
        CFrame.new(x2 - 0.55, 4.3, z + 0.22),
        Vector3.new(0.16, 0.7, 0.14),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
end

function Triagem.build(parent: Instance): Model
    local root = Kit.model(parent, "Triagem")
    root:SetAttribute("CelasDeEspera", 2)

    box(root, "Piso da triagem", 10, 38.5, 0.02, 0.1, 27, 36.5, P.Terrazzo, M.ceramic, nil)
    box(
        root,
        "Corredor das celas",
        22,
        38.5,
        0.1,
        0.14,
        27.2,
        30.9,
        P.TileDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )

    -- Balcão de registro.
    Furniture.desk(
        root,
        "Balcão de triagem",
        CFrame.new(15.0, 0.1, 28.8),
        5.5,
        2.2,
        3.2,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira da triagem",
        CFrame.new(15.0, 0.1, 30.8) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Ficha de triagem",
        CFrame.new(15.0, 3.6, 28.4),
        Vector3.new(1.5, 0.18, 1.0),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Carimbo",
        CFrame.new(16.0, 3.55, 28.4),
        Vector3.new(0.3, 0.35, 0.3),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Telefone da triagem",
        CFrame.new(13.6, 3.55, 28.4),
        Vector3.new(0.8, 0.5, 0.6),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Quadro de altura e câmera.
    box(
        root,
        "Quadro de altura",
        10.15,
        10.25,
        0.4,
        8.0,
        27.5,
        28.9,
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 12 do
        box(
            root,
            "Marca de altura " .. index,
            10.12,
            10.2,
            0.6 + index * 0.55,
            0.65 + index * 0.55,
            27.55,
            28.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        box(
            root,
            "Marca de altura direita " .. index,
            10.12,
            10.2,
            0.6 + index * 0.55,
            0.65 + index * 0.55,
            28.3,
            28.8,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Número de altura " .. index,
            CFrame.new(10.22, 1.0 + index * 0.55, 28.2),
            Vector3.new(0.04, 0.18, 0.4),
            P.Iron,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Camera de triagem", 10.15, 10.45, 8.2, 8.8, 28.0, 28.7, P.Iron, M.iron, nil)
    Kit.block(
        root,
        "Lente da câmera",
        CFrame.new(10.5, 8.5, 28.35),
        Vector3.new(0.25, 0.3, 0.3),
        P.Glass,
        M.glass,
        { collide = false, query = false, shadow = false }
    )

    -- Banco e caixa de pertences.
    Furniture.bench(
        root,
        "Banco da triagem",
        CFrame.new(19.5, 0.1, 34.5) * CFrame.Angles(0, math.rad(180), 0),
        4.5,
        P.Oak,
        M.wood
    )
    Kit.block(
        root,
        "Caixa de pertences",
        CFrame.new(19.0, 1.8, 29.8),
        Vector3.new(2.2, 2.8, 1.8),
        P.OakDark,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Etiqueta da caixa",
        CFrame.new(19.0, 3.0, 30.7),
        Vector3.new(0.9, 0.45, 0.05),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )

    -- Posto do guarda da triagem.
    Furniture.table(
        root,
        "Mesa do guarda da triagem",
        CFrame.new(36.0, 0.1, 28.7),
        3.2,
        1.8,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do guarda da triagem",
        CFrame.new(36.0, 0.1, 30.2) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Rádio da triagem",
        CFrame.new(36.0, 3.4, 28.7),
        Vector3.new(0.9, 0.6, 0.6),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Portas das celas e interiores.
    local cellOne = Kit.model(root, "Cela de espera 1")
    local cellTwo = Kit.model(root, "Cela de espera 2")
    cellOne:SetAttribute("Tipo", "Triagem")
    cellTwo:SetAttribute("Tipo", "Triagem")
    steelDoor(cellOne, "Porta da cela de espera 1", 24.0, 27.0)
    steelDoor(cellTwo, "Porta da cela de espera 2", 32.0, 35.0)
    holdingCell(cellOne, "Cela de espera 1", 22.2, 30.0)
    holdingCell(cellTwo, "Cela de espera 2", 30.4, 38.3)

    -- Murais, relógio e iluminação.
    Furniture.noticeBoard(root, "Mural da triagem", CFrame.new(29.0, 5.8, 27.15), 5.0, 2.8)
    Furniture.wallClock(root, "Relógio da triagem", CFrame.new(21.0, 7.0, 27.1), 1)
    for _, spec in
        {
            { x = 14.0, z = 31.8 },
            { x = 20.0, z = 29.0 },
            { x = 29.0, z = 29.0 },
            { x = 35.0, z = 29.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da triagem " .. spec.x .. "/" .. spec.z,
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
        "Arandela da triagem",
        CFrame.new(38.35, 6.5, 29.0) * CFrame.Angles(0, math.rad(-90), 0),
        P.NeonWarm,
        0.5,
        7
    )

    return root
end

return Triagem

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
    Refeitório grande.
    Um salão de 58 × 56 studs com pé-direito de 5,6 m, piso xadrez, mesas de
    carvalho para 48 pessoas, balcão de serviço, passagem aquecida da cozinha,
    tesouras metálicas aparentes e três lanternins de vidro.
]]

local Refeitorio = {}
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

local function placeSetting(parent: Instance, name: string, x: number, z: number, y: number)
    Kit.block(
        parent,
        name .. " bandeja",
        CFrame.new(x, y + 0.1, z),
        Vector3.new(2.0, 0.08, 1.35),
        P.MetalTray,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " copo",
        CFrame.new(x + 0.6, y + 0.55, z + 0.35),
        Vector3.new(0.32, 0.55, 0.32),
        P.Ceramic,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " guardanapo",
        CFrame.new(x - 0.62, y + 0.2, z - 0.25),
        Vector3.new(0.55, 0.04, 0.55),
        P.LinenWhite,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )
end

local function truss(parent: Instance, name: string, x: number)
    local z1 = -22
    local z2 = 30
    local yBase = 16.4
    local yTop = 19.4
    box(
        parent,
        name .. " banzo inferior",
        x - 0.18,
        x + 0.18,
        yBase,
        yBase + 0.36,
        z1,
        z2,
        P.Iron,
        M.iron,
        nil
    )
    box(
        parent,
        name .. " banzo superior",
        x - 0.18,
        x + 0.18,
        yTop,
        yTop + 0.36,
        z1,
        z2,
        P.Iron,
        M.iron,
        nil
    )
    for index = 1, 9 do
        local z = z1 + (z2 - z1) * (index - 0.5) / 9
        box(
            parent,
            name .. " montante " .. index,
            x - 0.14,
            x + 0.14,
            yBase,
            yTop + 0.36,
            z - 0.14,
            z + 0.14,
            P.Iron,
            M.iron,
            nil
        )
    end
    for index = 1, 8 do
        local z = z1 + (z2 - z1) * index / 9
        local centerY = (yBase + yTop) * 0.5
        Kit.block(
            parent,
            name .. " diagonal " .. index,
            CFrame.new(x, centerY, z)
                * CFrame.Angles(math.rad(if index % 2 == 0 then 34 else -34), 0, 0),
            Vector3.new(0.16, 0.16, 6.4),
            P.Iron,
            M.iron,
            nil
        )
    end
end

function Refeitorio.build(parent: Instance): Model
    local root = Kit.model(parent, "Refeitorio")
    local r = Layout.refeitorio
    local xMin = r.inner.minX
    local xMax = r.inner.maxX
    local zMin = r.inner.minZ
    local zMax = r.inner.maxZ
    local y = 0.08

    root:SetAttribute("Lugares", 48)
    root:SetAttribute("Mesas", 6)

    -- Piso xadrez de 4 studs, com borda de pedra.
    local tile = 4
    local startX = -94
    local startZ = -20
    local columns = 12
    local rows = 12
    for row = 1, rows do
        for column = 1, columns do
            local x = startX + tile * (column - 0.5)
            local z = startZ + tile * (row - 0.5)
            box(
                root,
                string.format("Ladrilho %d-%d", row, column),
                x - tile * 0.5,
                x + tile * 0.5,
                y,
                y + 0.06,
                z - tile * 0.5,
                z + tile * 0.5,
                if (row + column) % 2 == 0 then P.TileCream else P.TileGray,
                M.ceramic,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(root, "Borda do piso norte", xMin, xMax, y, y + 0.08, zMin, -20, P.Stone, M.stone, nil)
    box(root, "Borda do piso sul", xMin, xMax, y, y + 0.08, 28, zMax, P.Stone, M.stone, nil)
    box(root, "Borda do piso oeste", xMin, -94, y, y + 0.08, -20, 28, P.Stone, M.stone, nil)
    box(root, "Borda do piso leste", -46, xMax, y, y + 0.08, -20, 28, P.Stone, M.stone, nil)

    -- Lambril verde e cadeira de madeira nas paredes.
    box(
        root,
        "Lambril oeste",
        xMin + 0.02,
        xMin + 0.25,
        0.35,
        3.3,
        zMin,
        zMax,
        P.Green,
        M.paint,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Cadeira oeste",
        xMin + 0.02,
        xMin + 0.35,
        3.3,
        3.58,
        zMin,
        zMax,
        P.OakDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Lambril norte",
        xMin,
        xMax,
        0.35,
        3.3,
        zMin + 0.02,
        zMin + 0.25,
        P.Green,
        M.paint,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Cadeira norte",
        xMin,
        xMax,
        3.3,
        3.58,
        zMin + 0.02,
        zMin + 0.35,
        P.OakDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Lambril sul",
        xMin,
        xMax,
        0.35,
        3.3,
        zMax - 0.25,
        zMax - 0.02,
        P.Green,
        M.paint,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Cadeira sul",
        xMin,
        xMax,
        3.3,
        3.58,
        zMax - 0.35,
        zMax - 0.02,
        P.OakDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )

    -- Mesas e bancos: duas fileiras de três mesas longas.
    local tableXs = { -85, -69, -53 }
    local tableZs = { -8, 12 }
    local tableIndex = 1
    for _, tableZ in tableZs do
        for _, tableX in tableXs do
            local tableName = "Mesa do refeitório " .. tableIndex
            Furniture.table(
                root,
                tableName,
                CFrame.new(tableX, y, tableZ),
                14,
                3.8,
                3.0,
                P.Oak,
                M.planks
            )
            Furniture.bench(
                root,
                tableName .. " banco norte",
                CFrame.new(tableX, y, tableZ - 3.1),
                14,
                P.Oak,
                M.planks
            )
            Furniture.bench(
                root,
                tableName .. " banco sul",
                CFrame.new(tableX, y, tableZ + 3.1) * CFrame.Angles(0, math.rad(180), 0),
                14,
                P.Oak,
                M.planks
            )
            for seat = 1, 4 do
                local seatX = tableX - 5.25 + (seat - 1) * 3.5
                placeSetting(
                    root,
                    string.format("%s lugar norte %d", tableName, seat),
                    seatX,
                    tableZ - 1.55,
                    3.1
                )
                placeSetting(
                    root,
                    string.format("%s lugar sul %d", tableName, seat),
                    seatX,
                    tableZ + 1.55,
                    3.1
                )
            end
            Kit.block(
                root,
                tableName .. " jarra",
                CFrame.new(tableX, 3.65, tableZ),
                Vector3.new(0.9, 1.1, 0.9),
                P.SteelLight,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
            Kit.block(
                root,
                tableName .. " jarra boca",
                CFrame.new(tableX, 4.25, tableZ),
                Vector3.new(1.05, 0.16, 1.05),
                P.Steel,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
            tableIndex += 1
        end
    end

    -- Balcão de serviço ao longo da parede leste.
    local counterX1 = -47.8
    local counterX2 = -45.0
    local counterZ1 = -17
    local counterZ2 = 18
    box(
        root,
        "Base do balcão",
        counterX1,
        counterX2,
        0.2,
        3.1,
        counterZ1,
        counterZ2,
        P.GreenDark,
        M.wood,
        nil
    )
    box(
        root,
        "Tampo do balcão",
        counterX1 - 0.3,
        counterX2 + 0.2,
        3.1,
        3.35,
        counterZ1 - 0.3,
        counterZ2 + 0.3,
        P.SteelLight,
        M.steel,
        nil
    )
    box(
        root,
        "Rodapé do balcão",
        counterX1,
        counterX2 + 0.05,
        0.15,
        0.6,
        counterZ1,
        counterZ2,
        P.Iron,
        M.iron,
        nil
    )
    for index, z in { -14, -8, -2, 8, 14 } do
        box(
            root,
            string.format("Porta do balcão %d", index),
            counterX2 - 0.06,
            counterX2 + 0.02,
            0.7,
            2.8,
            z - 2.0,
            z + 2.0,
            P.Green,
            M.wood,
            nil
        )
        Kit.block(
            root,
            "Puxador do balcão " .. index,
            CFrame.new(counterX2 + 0.06, 1.8, z + 1.45),
            Vector3.new(0.08, 0.55, 0.12),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    for index, z in { -12, -6, 0, 6, 12 } do
        box(
            root,
            "Poste da proteção " .. index,
            counterX1 - 0.1,
            counterX1 + 0.1,
            3.35,
            7.3,
            z - 0.1,
            z + 0.1,
            P.Iron,
            M.iron,
            nil
        )
    end
    box(
        root,
        "Travessa da proteção",
        counterX1 - 0.12,
        counterX1 + 0.12,
        7.15,
        7.35,
        counterZ1,
        counterZ2,
        P.Iron,
        M.iron,
        nil
    )
    for index, z in { -15, -9, -3, 3, 9, 15 } do
        box(
            root,
            "Vidro da proteção " .. index,
            counterX1 - 0.05,
            counterX1 + 0.05,
            3.55,
            7.1,
            z - 2.8,
            z + 2.8,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
    end
    box(
        root,
        "Prateleira de bandejas",
        counterX1 - 1.2,
        counterX1 - 0.1,
        3.35,
        3.55,
        counterZ1,
        counterZ2,
        P.Steel,
        M.metal,
        nil
    )
    for index, z in { -16, -12, -8, -4, 0, 4, 8, 12, 16 } do
        Kit.block(
            root,
            "Bandeja " .. index,
            CFrame.new(counterX1 - 0.6, 3.65, z),
            Vector3.new(1.0, 0.05, 2.6),
            P.MetalTray,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    for index, z in { -13, -5, 5, 13 } do
        Kit.block(
            root,
            "Lâmpada de calor " .. index,
            CFrame.new(counterX1 - 0.85, 7.6, z),
            Vector3.new(0.65, 0.18, 2.6),
            P.NeonWarm,
            M.neon,
            { collide = false, query = false, shadow = false }
        )
        Kit.pointLight(
            root:FindFirstChild("Lâmpada de calor " .. index),
            P.NeonWarm,
            { name = "Luz de serviço", brightness = 0.5, range = 9, shadows = false }
        )
    end

    -- Passagem aquecida da cozinha.
    box(root, "Balcão de passagem", -42.2, -40.5, 2.9, 3.25, 0.2, 3.8, P.SteelLight, M.steel, nil)
    box(
        root,
        "Protetor da passagem",
        -42.2,
        -41.2,
        3.3,
        5.4,
        0.2,
        3.8,
        P.Glass,
        M.glass,
        { transparency = 0.62, collide = false, query = false, shadow = false }
    )
    for _, z in { 0.4, 3.6 } do
        box(
            root,
            "Poste da passagem",
            -42.3,
            -42.0,
            3.25,
            5.4,
            z - 0.1,
            z + 0.1,
            P.Iron,
            M.iron,
            nil
        )
    end

    -- Estação de lavagem de mãos, junto à devolução de bandejas.
    box(root, "Lavatório coletivo", -44.6, -43.2, 0.2, 2.9, 28.0, 30.2, P.SteelLight, M.steel, nil)
    box(
        root,
        "Bacia coletiva",
        -44.45,
        -43.35,
        2.7,
        3.0,
        28.15,
        30.05,
        P.Water,
        M.glass,
        { transparency = 0.25, collide = false, query = false, shadow = false }
    )
    for index, z in { 28.6, 29.1, 29.6 } do
        Kit.block(
            root,
            "Torneira " .. index,
            CFrame.new(-43.15, 3.4, z),
            Vector3.new(0.14, 0.9, 0.14),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Tesouras metálicas aparentes.
    for index, x in { -88, -72, -56 } do
        truss(root, "Tesoura do refeitório " .. index, x)
    end

    -- Pendentes sobre as mesas.
    for index, spec in
        {
            { x = -85, z = -8 },
            { x = -69, z = -8 },
            { x = -53, z = -8 },
            { x = -85, z = 12 },
            { x = -69, z = 12 },
            { x = -53, z = 12 },
        }
    do
        Furniture.pendantLamp(
            root,
            "Pendente do refeitório " .. index,
            CFrame.new(spec.x, 19.7, spec.z),
            9.5,
            4.4,
            4.4,
            P.NeonWarm,
            1.25,
            18
        )
    end

    -- Relógio, murais e quadros de cardápio.
    Furniture.wallClock(root, "Relógio do refeitório", CFrame.new(-69, 10.5, zMin + 0.1))
    Furniture.noticeBoard(root, "Mural do refeitório", CFrame.new(-82, 7.2, zMin + 0.1), 8.0, 3.7)
    box(
        root,
        "Quadro de cardápio",
        -57,
        -47,
        5.0,
        10.5,
        zMin + 0.03,
        zMin + 0.2,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        box(
            root,
            "Cartaz de cardápio " .. index,
            -56.2 + (index - 1) * 2.35,
            -54.5 + (index - 1) * 2.35,
            6.0,
            9.6,
            zMin + 0.2,
            zMin + 0.24,
            P.Paper,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Local de devolução de bandejas, junto à saída.
    box(
        root,
        "Balcão de devolução",
        -46.5,
        -42.5,
        0.2,
        3.0,
        22.2,
        25.0,
        P.GreenDark,
        M.wood,
        nil
    )
    box(
        root,
        "Tampo de devolução",
        -46.7,
        -42.3,
        3.0,
        3.22,
        22.0,
        25.2,
        P.SteelLight,
        M.steel,
        nil
    )
    for index = 1, 3 do
        Kit.block(
            root,
            "Caixa de bandejas " .. index,
            CFrame.new(-44.5, 3.65, 22.7 + (index - 1) * 0.8),
            Vector3.new(2.6, 0.9, 0.65),
            P.MetalTray,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Pontos de luz sob o balcão e junto à entrada.
    for _, spec in
        {
            { x = -44, z = -12 },
            { x = -44, z = 14 },
            { x = -62, z = 28 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz de serviço " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 19.8, spec.z),
            4.0,
            1.2,
            P.NeonCool,
            1.0,
            13
        )
    end

    return root
end

return Refeitorio

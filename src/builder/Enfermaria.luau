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
    Enfermaria.
    Três leitos hospitalares com cortinas de privacidade, posto de enfermagem,
    armário de medicamentos com vidro, lavatório, cadeira de rodas e iluminação
    fria e difusa. O piso claro e a janela fosca mantêm o ambiente calmo.
]]

local Enfermaria = {}
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

local function bed(parent: Instance, name: string, cf: CFrame)
    Furniture.bed(parent, name, cf, 6.2, 2.8, P.Linen)
    Kit.block(
        parent,
        name .. " cabeceira",
        cf * CFrame.new(-3.05, 2.7, 0),
        Vector3.new(0.18, 3.2, 2.7),
        P.SteelLight,
        M.metal,
        nil
    )
    Kit.block(
        parent,
        name .. " pés",
        cf * CFrame.new(3.05, 1.5, 0),
        Vector3.new(0.18, 0.9, 2.7),
        P.SteelLight,
        M.metal,
        nil
    )
    Kit.block(
        parent,
        name .. " grade lateral",
        cf * CFrame.new(0.4, 3.2, -1.35),
        Vector3.new(4.6, 0.18, 0.12),
        P.SteelLight,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " grade lateral oposta",
        cf * CFrame.new(0.4, 3.2, 1.35),
        Vector3.new(4.6, 0.18, 0.12),
        P.SteelLight,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
end

function Enfermaria.build(parent: Instance): Model
    local root = Kit.model(parent, "Enfermaria")
    root:SetAttribute("Leitos", 3)
    root:SetAttribute("AreaM2", math.floor((12.5 * 14) / (Layout.studsPerMeter ^ 2)))

    -- Piso claro com borda verde.
    box(root, "Piso da enfermaria", 26.2, 38.3, 0.02, 0.1, 13.2, 26.8, P.TileWhite, M.ceramic, nil)
    box(
        root,
        "Borda do piso",
        26.2,
        38.3,
        0.02,
        0.12,
        13.2,
        14.0,
        P.Green,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Eixo de circulação",
        28.0,
        32.0,
        0.02,
        0.13,
        14.0,
        26.8,
        P.TileCream,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )

    -- Leitos.
    bed(root, "Leito 1", CFrame.new(35.2, 0.08, 15.5) * CFrame.Angles(0, math.rad(180), 0))
    bed(root, "Leito 2", CFrame.new(35.2, 0.08, 20.0) * CFrame.Angles(0, math.rad(180), 0))
    bed(root, "Leito 3", CFrame.new(35.2, 0.08, 24.5) * CFrame.Angles(0, math.rad(180), 0))

    -- Cortinas de privacidade.
    for index, spec in
        {
            { x = 35.2, z = 15.5, width = 5.0 },
            { x = 35.2, z = 20.0, width = 5.0 },
            { x = 35.2, z = 24.5, width = 5.0 },
        }
    do
        if spec.rotated then
            box(
                root,
                "Trilho da cortina " .. index,
                spec.x - 3.8,
                spec.x + 3.8,
                9.8,
                10.0,
                spec.z - 0.1,
                spec.z + 0.1,
                P.Steel,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
            for curtain = 1, 4 do
                box(
                    root,
                    string.format("Cortina %d-%d", index, curtain),
                    spec.x - 3.4 + (curtain - 1) * 1.7,
                    spec.x - 2.9 + (curtain - 1) * 1.7,
                    2.0,
                    9.8,
                    spec.z - 2.0,
                    spec.z + 2.0,
                    if curtain % 2 == 0 then P.Linen else P.LinenWhite,
                    M.fabric,
                    { transparency = 0.08, collide = false, query = false, shadow = false }
                )
            end
        else
            box(
                root,
                "Trilho da cortina " .. index,
                spec.x - 0.1,
                spec.x + 0.1,
                9.8,
                10.0,
                spec.z - spec.width * 0.5,
                spec.z + spec.width * 0.5,
                P.Steel,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
            for curtain = 1, 4 do
                box(
                    root,
                    string.format("Cortina %d-%d", index, curtain),
                    spec.x - 2.0,
                    spec.x + 2.0,
                    2.0,
                    9.8,
                    spec.z - spec.width * 0.5 + (curtain - 1) * 2.0,
                    spec.z - spec.width * 0.5 + (curtain - 1) * 2.0 + 1.7,
                    if curtain % 2 == 0 then P.Linen else P.LinenWhite,
                    M.fabric,
                    { transparency = 0.08, collide = false, query = false, shadow = false }
                )
            end
        end
    end

    -- Mesinhas de cabeceira, campainhas e copos.
    for index, spec in
        {
            { x = 37.4, z = 17.75 },
            { x = 37.4, z = 22.25 },
        }
    do
        Furniture.table(
            root,
            "Mesa de cabeceira " .. index,
            CFrame.new(spec.x, 0.08, spec.z),
            1.8,
            1.6,
            2.7,
            P.SteelLight,
            M.steel
        )
        Kit.block(
            root,
            "Jarra de água " .. index,
            CFrame.new(spec.x, 3.35, spec.z),
            Vector3.new(0.45, 0.9, 0.45),
            P.Glass,
            M.glass,
            { transparency = 0.3, collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Copo " .. index,
            CFrame.new(spec.x + 0.45, 3.05, spec.z + 0.3),
            Vector3.new(0.24, 0.35, 0.24),
            P.Ceramic,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Posto de enfermagem.
    Furniture.desk(
        root,
        "Posto de enfermagem",
        CFrame.new(29.0, 0.08, 15.4) * CFrame.Angles(0, math.rad(-90), 0),
        5.0,
        2.2,
        3.1,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do posto",
        CFrame.new(26.9, 0.08, 15.4) * CFrame.Angles(0, math.rad(90), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Ficha clínica",
        CFrame.new(29.2, 3.4, 14.4),
        Vector3.new(1.4, 0.16, 1.0),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Telefone do posto",
        CFrame.new(30.0, 3.55, 14.5),
        Vector3.new(0.8, 0.5, 0.6),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Luminária do posto",
        CFrame.new(27.5, 4.4, 14.5),
        Vector3.new(0.45, 0.7, 0.45),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Armário de medicamentos e material esterilizado.
    box(
        root,
        "Armário de medicamentos",
        26.1,
        26.9,
        0.1,
        8.5,
        14.3,
        16.7,
        P.SteelLight,
        M.metal,
        nil
    )
    box(
        root,
        "Porta de vidro do armário",
        26.92,
        27.05,
        0.8,
        7.9,
        14.5,
        16.5,
        P.Glass,
        M.glass,
        { transparency = 0.3, collide = false, query = false, shadow = false }
    )
    for shelf = 1, 4 do
        box(
            root,
            "Prateleira do armário " .. shelf,
            26.2,
            26.9,
            1.2 + shelf * 1.6,
            1.3 + shelf * 1.6,
            14.4,
            16.6,
            P.Steel,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
        for bottle = 1, 3 do
            Kit.block(
                root,
                string.format("Frasco %d-%d", shelf, bottle),
                CFrame.new(26.5, 1.65 + shelf * 1.6, 14.7 + (bottle - 1) * 0.55),
                Vector3.new(0.28, 0.55, 0.28),
                if bottle % 2 == 0 then P.CeramicBlue else P.Ceramic,
                M.ceramic,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Kit.block(
        root,
        "Cadeado do armário",
        CFrame.new(27.08, 4.1, 15.5),
        Vector3.new(0.12, 0.5, 0.3),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Lavatório e balança.
    Furniture.sink(
        root,
        "Lavatório da enfermaria",
        CFrame.new(27.0, 0.08, 25.8) * CFrame.Angles(0, math.rad(90), 0)
    )
    box(root, "Balança", 26.8, 28.2, 0.1, 0.5, 16.8, 18.4, P.SteelLight, M.steel, nil)
    Kit.block(
        root,
        "Coluna da balança",
        CFrame.new(27.5, 2.4, 17.6),
        Vector3.new(0.2, 4.2, 0.2),
        P.Steel,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Mostrador da balança",
        CFrame.new(27.5, 4.5, 17.6),
        Vector3.new(0.7, 0.5, 0.3),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )

    -- Suporte de soro.
    Kit.block(
        root,
        "Suporte de soro",
        CFrame.new(31.5, 5.2, 22.0),
        Vector3.new(0.14, 10.0, 0.14),
        P.Steel,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Bolsa de soro",
        CFrame.new(31.5, 9.8, 22.0),
        Vector3.new(0.5, 1.1, 0.18),
        P.LinenWhite,
        M.glass,
        { transparency = 0.3, collide = false, query = false, shadow = false }
    )

    -- Lixeira, hamper e avisos.
    Kit.block(
        root,
        "Lixeira hospitalar",
        CFrame.new(30.9, 1.2, 26.2),
        Vector3.new(1.1, 2.2, 1.1),
        P.SteelDark,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Hamper de roupa",
        CFrame.new(33.6, 1.5, 26.2),
        Vector3.new(2.0, 2.8, 1.4),
        P.Linen,
        M.fabric,
        nil
    )
    Furniture.noticeBoard(
        root,
        "Mural da enfermaria",
        CFrame.new(32.0, 6.2, 26.95) * CFrame.Angles(0, math.rad(180), 0),
        5.0,
        2.8
    )
    Kit.block(
        root,
        "Álcool em gel",
        CFrame.new(28.2, 3.7, 14.2),
        Vector3.new(0.35, 0.7, 0.35),
        P.Glass,
        M.glass,
        { transparency = 0.22, collide = false, query = false, shadow = false }
    )

    -- Iluminação fria e difusa.
    for _, spec in
        {
            { x = 30.0, z = 16.0 },
            { x = 34.0, z = 20.0 },
            { x = 30.0, z = 25.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da enfermaria " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 12.0, spec.z),
            4.2,
            1.2,
            P.NeonCool,
            0.95,
            12
        )
    end
    Furniture.wallSconce(
        root,
        "Arandela da enfermaria",
        CFrame.new(26.15, 6.5, 21.5) * CFrame.Angles(0, math.rad(90), 0),
        P.NeonWarm,
        0.45,
        7
    )

    return root
end

return Enfermaria

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
    Pátio de exercícios e torre de vigia.
    O pátio é fechado por muros altos de alvenaria, com quadra de handebol,
    abrigo de sombra, equipamentos de ginástica, bancos de pedra e guarita.
    A torre de vigia tem base de cantaria, cabine envidraçada, refletor e
    passadiço com guarda-corpo.
]]

local Patio = {}
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

local function buildWatchtower(parent: Instance)
    local tower = parent
    local t = Layout.yard.tower
    local x1, x2, z1, z2 = t.minX, t.maxX, t.minZ, t.maxZ
    local midX = (x1 + x2) * 0.5
    local midZ = (z1 + z2) * 0.5
    tower:SetAttribute("AlturaStuds", 30)

    -- Base de cantaria.
    box(parent, "Base da torre", x1, x2, 0, 20.0, z1, z2, P.Stone, M.stone, nil)
    for index = 1, 6 do
        box(
            parent,
            "Faixa da torre " .. index,
            x1 - 0.15,
            x2 + 0.15,
            index * 3.0,
            index * 3.3,
            z1 - 0.15,
            z2 + 0.15,
            P.StoneLight,
            M.stone,
            nil
        )
    end
    for _, corner in
        {
            { x = x1 + 0.6, z = z1 + 0.6 },
            { x = x2 - 0.6, z = z1 + 0.6 },
            { x = x1 + 0.6, z = z2 - 0.6 },
            { x = x2 - 0.6, z = z2 - 0.6 },
        }
    do
        for index = 1, 5 do
            local w = if index % 2 == 0 then 1.4 else 2.0
            box(
                parent,
                "Quina da torre " .. index,
                corner.x - w * 0.5,
                corner.x + w * 0.5,
                2.0 + (index - 1) * 3.4,
                4.4 + (index - 1) * 3.4,
                corner.z - w * 0.5,
                corner.z + w * 0.5,
                P.StoneLight,
                M.stone,
                nil
            )
        end
    end

    -- Portal de acesso e escada de serviço.
    box(
        parent,
        "Portal da torre",
        x1 - 0.05,
        x1 + 0.05,
        0,
        9.0,
        midZ - 2.0,
        midZ + 2.0,
        P.WalnutDeep,
        M.wood,
        nil
    )
    box(
        parent,
        "Portal da torre escuro",
        x1 - 0.12,
        x1 - 0.05,
        0.2,
        8.6,
        midZ - 1.8,
        midZ + 1.8,
        P.Iron,
        M.iron,
        nil
    )
    Kit.block(
        parent,
        "Puxador do portal",
        CFrame.new(x1 - 0.2, 4.0, midZ + 1.1),
        Vector3.new(0.14, 0.7, 0.14),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 8 do
        box(
            parent,
            "Degrau da torre " .. index,
            x2 + 0.2,
            x2 + 1.2,
            index * 2.2,
            index * 2.2 + 0.3,
            midZ - 1.2,
            midZ + 1.2,
            P.Iron,
            M.iron,
            nil
        )
    end

    -- Balcão e guarda-corpo.
    box(
        parent,
        "Balcão da torre",
        x1 - 1.4,
        x2 + 1.4,
        20.0,
        20.8,
        z1 - 1.4,
        z2 + 1.4,
        P.StoneLight,
        M.stone,
        nil
    )
    Kit.railingX(
        parent,
        "Guarda-corpo sul da torre",
        x1 - 1.4,
        x2 + 1.4,
        z2 + 1.2,
        20.8,
        3.2,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.railingX(
        parent,
        "Guarda-corpo norte da torre",
        x1 - 1.4,
        x2 + 1.4,
        z1 - 1.2,
        20.8,
        3.2,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.railingZ(
        parent,
        "Guarda-corpo oeste da torre",
        z1 - 1.2,
        z2 + 1.2,
        x1 - 1.2,
        20.8,
        3.2,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.railingZ(
        parent,
        "Guarda-corpo leste da torre",
        z1 - 1.2,
        z2 + 1.2,
        x2 + 1.2,
        20.8,
        3.2,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Cabine envidraçada.
    local cabInset = 0.8
    for _, corner in
        {
            { x = x1 + cabInset, z = z1 + cabInset },
            { x = x2 - cabInset, z = z1 + cabInset },
            { x = x1 + cabInset, z = z2 - cabInset },
            { x = x2 - cabInset, z = z2 - cabInset },
        }
    do
        box(
            parent,
            "Montante da cabine",
            corner.x - 0.18,
            corner.x + 0.18,
            20.8,
            28.6,
            corner.z - 0.18,
            corner.z + 0.18,
            P.Iron,
            M.iron,
            nil
        )
    end
    for _, spec in
        {
            { name = "norte", x1 = x1 + cabInset, x2 = x2 - cabInset, z = z1 + cabInset },
            { name = "sul", x1 = x1 + cabInset, x2 = x2 - cabInset, z = z2 - cabInset },
        }
    do
        box(
            parent,
            "Peitoril da cabine " .. spec.name,
            spec.x1,
            spec.x2,
            20.8,
            23.2,
            spec.z - 0.15,
            spec.z + 0.15,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Vidro da cabine " .. spec.name,
            spec.x1 + 0.2,
            spec.x2 - 0.2,
            23.2,
            28.0,
            spec.z - 0.05,
            spec.z + 0.05,
            P.Glass,
            M.glass,
            { transparency = 0.55, collide = false, query = false, shadow = false }
        )
        for index = 1, 4 do
            local x = spec.x1 + 0.3 + (index - 1) * ((spec.x2 - spec.x1 - 0.6) / 4)
            box(
                parent,
                "Montante do vidro " .. spec.name .. index,
                x - 0.06,
                x + 0.06,
                23.2,
                28.0,
                spec.z - 0.1,
                spec.z + 0.1,
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for _, spec in
        {
            { name = "oeste", z1 = z1 + cabInset, z2 = z2 - cabInset, x = x1 + cabInset },
            { name = "leste", z1 = z1 + cabInset, z2 = z2 - cabInset, x = x2 - cabInset },
        }
    do
        box(
            parent,
            "Peitoril da cabine " .. spec.name,
            spec.x - 0.15,
            spec.x + 0.15,
            20.8,
            23.2,
            spec.z1,
            spec.z2,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Vidro da cabine " .. spec.name,
            spec.x - 0.05,
            spec.x + 0.05,
            23.2,
            28.0,
            spec.z1 + 0.2,
            spec.z2 - 0.2,
            P.Glass,
            M.glass,
            { transparency = 0.55, collide = false, query = false, shadow = false }
        )
        for index = 1, 4 do
            local z = spec.z1 + 0.3 + (index - 1) * ((spec.z2 - spec.z1 - 0.6) / 4)
            box(
                parent,
                "Montante do vidro " .. spec.name .. index,
                spec.x - 0.1,
                spec.x + 0.1,
                23.2,
                28.0,
                z - 0.06,
                z + 0.06,
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(
        parent,
        "Porta da cabine",
        x1 + cabInset - 0.2,
        x1 + cabInset + 0.2,
        21.0,
        27.0,
        midZ - 1.1,
        midZ + 1.1,
        P.Iron,
        M.iron,
        nil
    )

    -- Cobertura e refletor.
    box(
        parent,
        "Cobertura da torre",
        x1 - 0.6,
        x2 + 0.6,
        28.6,
        29.4,
        z1 - 0.6,
        z2 + 0.6,
        P.RoofSlate,
        M.slate,
        nil
    )
    box(
        parent,
        "Parapeto da torre",
        x1 - 0.7,
        x2 + 0.7,
        29.4,
        30.2,
        z1 - 0.7,
        z1 - 0.2,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        parent,
        "Parapeto da torre sul",
        x1 - 0.7,
        x2 + 0.7,
        29.4,
        30.2,
        z2 + 0.2,
        z2 + 0.7,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        parent,
        "Parapeto da torre oeste",
        x1 - 0.7,
        x1 - 0.2,
        29.4,
        30.2,
        z1 - 0.7,
        z2 + 0.7,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        parent,
        "Parapeto da torre leste",
        x2 + 0.2,
        x2 + 0.7,
        29.4,
        30.2,
        z1 - 0.7,
        z2 + 0.7,
        P.StoneLight,
        M.stone,
        nil
    )
    local searchlight = Kit.block(
        parent,
        "Refletor da torre",
        CFrame.new(x1 + 1.2, 30.6, midZ) * CFrame.Angles(0, math.rad(-90), 0),
        Vector3.new(1.3, 1.2, 1.5),
        P.SteelDark,
        M.metal,
        nil
    )
    Kit.spotLight(searchlight, P.NeonWarm, {
        name = "Refletor do pátio",
        brightness = 3.0,
        range = 95,
        angle = 46,
        face = Enum.NormalId.Front,
        shadows = true,
    })
    Kit.block(
        parent,
        "Luz vermelha da torre",
        CFrame.new(midX, 30.5, z1 - 0.2),
        Vector3.new(0.6, 0.4, 0.6),
        P.NeonWarm,
        M.neon,
        { collide = false, query = false, shadow = false }
    )
    Furniture.ceilingLight(
        parent,
        "Luz interna da torre",
        CFrame.new(midX, 28.4, midZ),
        3.0,
        1.0,
        P.NeonWarm,
        0.8,
        9
    )
    return tower
end

local function buildYardFurniture(parent: Instance)
    local root = Kit.model(parent, "Patio")
    root:SetAttribute("AreaM2", math.floor(Layout.areaYardM2))

    -- Piso de concreto com pista pintada.
    box(root, "Piso do pátio", 45.5, 108.5, 0.02, 0.1, -34.5, 36.5, P.Concrete, M.concrete, nil)
    for _, spec in
        {
            { name = "norte", x1 = 50, x2 = 104, z1 = -29, z2 = -28.4 },
            { name = "sul", x1 = 50, x2 = 104, z1 = 30.4, z2 = 31 },
            { name = "oeste", x1 = 49.4, x2 = 50, z1 = -29, z2 = 31 },
            { name = "leste", x1 = 104, x2 = 104.6, z1 = -29, z2 = 31 },
        }
    do
        box(
            root,
            "Pista do pátio " .. spec.name,
            spec.x1,
            spec.x2,
            0.1,
            0.16,
            spec.z1,
            spec.z2,
            P.PaintWarm,
            M.concrete,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        root,
        "Linha central do pátio",
        49.4,
        104.6,
        0.1,
        0.16,
        0.8,
        1.4,
        P.PaintWarm,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )

    -- Abrigo de sombra.
    for _, x in { 54, 62, 70, 78 } do
        box(
            root,
            "Poste do abrigo " .. x,
            x - 0.25,
            x + 0.25,
            0.1,
            9.5,
            -33.5,
            -33.0,
            P.Iron,
            M.metal,
            nil
        )
        box(
            root,
            "Sapata do abrigo " .. x,
            x - 0.8,
            x + 0.8,
            0.1,
            0.6,
            -34.0,
            -32.5,
            P.StoneDark,
            M.stone,
            nil
        )
    end
    box(root, "Cobertura do abrigo", 52.5, 79.5, 9.5, 10.2, -34.3, -30.8, P.RoofSlate, M.slate, nil)
    box(root, "Viga do abrigo", 52.5, 79.5, 9.0, 9.5, -34.2, -33.9, P.Iron, M.iron, nil)
    for _, x in { 57, 65, 73 } do
        Furniture.bench(
            root,
            "Banco do abrigo " .. x,
            CFrame.new(x, 0.1, -32.4) * CFrame.Angles(0, math.rad(180), 0),
            5.5,
            P.Oak,
            M.wood
        )
    end

    -- Quadra de handebol.
    box(root, "Muro da quadra", 59, 77, 0, 8.0, 31.0, 32.2, P.Concrete, M.concrete, nil)
    box(
        root,
        "Alvo da quadra",
        66.0,
        70.0,
        3.0,
        6.0,
        30.85,
        31.0,
        P.PaintWarm,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Linha de fundo da quadra",
        59,
        77,
        0.1,
        0.16,
        24.0,
        24.5,
        P.PaintWarm,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Linha lateral oeste",
        59,
        59.5,
        0.1,
        0.16,
        24.0,
        31.0,
        P.PaintWarm,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Linha lateral leste",
        76.5,
        77,
        0.1,
        0.16,
        24.0,
        31.0,
        P.PaintWarm,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )

    -- Equipamentos de ginástica.
    for _, x in { 84, 90 } do
        box(
            root,
            "Poste da barra " .. x,
            x - 0.2,
            x + 0.2,
            0.1,
            8.0,
            -4.0,
            -3.6,
            P.Iron,
            M.metal,
            nil
        )
    end
    box(root, "Barra fixa", 83.6, 90.4, 7.6, 7.95, -3.85, -3.75, P.SteelLight, M.metal, nil)
    for _, z in { -20, -14 } do
        box(
            root,
            "Poste das paralelas " .. z,
            86.0,
            86.4,
            0.1,
            4.3,
            z - 0.2,
            z + 0.2,
            P.Iron,
            M.metal,
            nil
        )
        box(
            root,
            "Poste das paralelas 2 " .. z,
            89.0,
            89.4,
            0.1,
            4.3,
            z - 0.2,
            z + 0.2,
            P.Iron,
            M.metal,
            nil
        )
        box(
            root,
            "Barra paralela " .. z,
            85.8,
            89.6,
            4.0,
            4.25,
            z - 0.12,
            z + 0.12,
            P.SteelLight,
            M.metal,
            nil
        )
    end
    Furniture.bench(root, "Banco de peso", CFrame.new(86.8, 0.1, 6.0), 5.0, P.Iron, M.metal)
    box(root, "Barra de peso", 85.0, 88.5, 0.2, 2.6, 7.2, 7.5, P.SteelLight, M.metal, nil)
    for _, x in { 85.2, 88.3 } do
        box(root, "Anilha " .. x, x - 0.3, x + 0.3, 0.2, 2.6, 6.9, 7.8, P.Iron, M.iron, nil)
    end

    -- Mesas e bancos de pedra.
    for index, spec in
        {
            { x = 55.0, z = 12.0 },
            { x = 96.0, z = 15.0 },
            { x = 66.0, z = -16.0 },
        }
    do
        Furniture.table(
            root,
            "Mesa do pátio " .. index,
            CFrame.new(spec.x, 0.1, spec.z),
            5.0,
            2.4,
            3.0,
            P.StoneLight,
            M.stone
        )
        Furniture.bench(
            root,
            "Banco do pátio A " .. index,
            CFrame.new(spec.x, 0.1, spec.z - 2.0),
            5.0,
            P.StoneLight,
            M.stone
        )
        Furniture.bench(
            root,
            "Banco do pátio B " .. index,
            CFrame.new(spec.x, 0.1, spec.z + 2.0) * CFrame.Angles(0, math.rad(180), 0),
            5.0,
            P.StoneLight,
            M.stone
        )
    end
    for index, spec in
        {
            { x = 47.0, z = -20.0, ry = 270 },
            { x = 47.0, z = 20.0, ry = 270 },
            { x = 106.0, z = 25.0, ry = -90 },
            { x = 106.0, z = 4.0, ry = -90 },
        }
    do
        Furniture.bench(
            root,
            "Banco de parede " .. index,
            CFrame.new(spec.x, 0.1, spec.z) * CFrame.Angles(0, math.rad(spec.ry), 0),
            7.0,
            P.StoneLight,
            M.stone
        )
    end

    -- Guarita do portão.
    box(root, "Base da guarita", 46.5, 53.0, 0.1, 0.7, 15.0, 21.5, P.Stone, M.stone, nil)
    box(root, "Corpo da guarita", 47.0, 52.5, 0.7, 8.5, 15.5, 21.0, P.StoneLight, M.stone, nil)
    box(root, "Cobertura da guarita", 46.5, 53.0, 8.5, 9.2, 15.0, 21.5, P.RoofSlate, M.slate, nil)
    box(
        root,
        "Janela da guarita",
        47.0,
        47.2,
        4.0,
        6.8,
        16.5,
        20.0,
        P.Glass,
        M.glass,
        { transparency = 0.55, collide = false, query = false, shadow = false }
    )
    box(root, "Porta da guarita", 47.0, 47.2, 0.8, 7.0, 16.0, 17.6, P.WalnutDeep, M.wood, nil)
    Kit.block(
        root,
        "Luz da guarita",
        CFrame.new(49.5, 8.8, 18.2),
        Vector3.new(0.6, 0.2, 0.6),
        P.NeonWarm,
        M.neon,
        { collide = false, query = false, shadow = false }
    )
    Furniture.ceilingLight(
        root,
        "Luz interna da guarita",
        CFrame.new(49.7, 8.0, 18.2),
        2.0,
        0.8,
        P.NeonWarm,
        0.7,
        7
    )

    -- Drenagem central e lixeiras.
    box(
        root,
        "Ralo central do pátio",
        76.0,
        78.0,
        0.1,
        0.16,
        -1.0,
        1.0,
        P.SteelDark,
        M.diamond,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        box(
            root,
            "Grade do ralo central " .. index,
            76.1,
            77.9,
            0.16,
            0.2,
            -0.8 + (index - 1) * 0.45,
            -0.65 + (index - 1) * 0.45,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, spec in
        {
            { x = 48.0, z = 33.0 },
            { x = 105.0, z = 33.0 },
            { x = 105.0, z = -32.0 },
        }
    do
        Kit.block(
            root,
            "Lixeira do pátio",
            CFrame.new(spec.x, 1.2, spec.z),
            Vector3.new(1.2, 2.2, 1.2),
            P.Iron,
            M.metal,
            nil
        )
    end

    -- Iluminação do pátio.
    for _, spec in
        {
            { x = 50.0, z = -32.0 },
            { x = 106.0, z = -32.0 },
            { x = 50.0, z = 34.0 },
        }
    do
        Furniture.lampPost(
            root,
            "Poste do pátio " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 0.1, spec.z),
            15.0,
            P.NeonCool,
            1.4,
            28
        )
    end

    return root
end

function Patio.build(parent: Instance, exteriorParent: Instance)
    local towerParent = Kit.model(exteriorParent, "TorreDeVigia")
    buildWatchtower(towerParent)
    local yard = buildYardFurniture(parent)
    return yard
end

return Patio

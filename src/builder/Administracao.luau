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
    Ala administrativa e de comando.
      • Entrada pública com detector, balcão de recepção e banco de espera.
      • Gabinete do diretor, escritório de pessoal e sala de controle.
      • Alojamento de plantão, arquivo e registro de detentos.
      • Sala de guarda no térreo e posto do chefe de guarda no 1º pavimento.
    Tudo modelado como mobiliário estático, sem NPCs e sem interfaces.
]]

local Administracao = {}
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

local function blinds(
    parent: Instance,
    name: string,
    x: number,
    z: number,
    y0: number,
    width: number
)
    box(
        parent,
        name .. " caixa",
        x - width * 0.5,
        x + width * 0.5,
        y0 + 10.0,
        y0 + 10.4,
        z - 0.18,
        z + 0.18,
        P.Iron,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 12 do
        box(
            parent,
            string.format("%s lâmina %d", name, index),
            x - width * 0.5 + 0.15,
            x + width * 0.5 - 0.15,
            y0 + 3.1 + (index - 1) * 0.58,
            y0 + 3.2 + (index - 1) * 0.58,
            z - 0.05,
            z + 0.03,
            if index % 2 == 0 then P.Paper else P.Linen,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function wainscot(
    parent: Instance,
    name: string,
    minX: number,
    maxX: number,
    z: number,
    y0: number
)
    box(
        parent,
        name .. " lambri",
        minX,
        maxX,
        y0 + 0.35,
        y0 + 3.4,
        z - 0.08,
        z + 0.08,
        P.GreenDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )
    box(
        parent,
        name .. " cadeira",
        minX,
        maxX,
        y0 + 3.4,
        y0 + 3.65,
        z - 0.14,
        z + 0.14,
        P.OakDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, math.floor((maxX - minX) / 2.2) do
        local x = minX + 1.1 + (index - 1) * 2.2
        box(
            parent,
            name .. " painel " .. index,
            x - 1.0,
            x + 1.0,
            y0 + 0.7,
            y0 + 3.1,
            z - 0.12,
            z - 0.08,
            P.Green,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function files(parent: Instance, name: string, cf: CFrame, count: number)
    for index = 1, count do
        Kit.block(
            parent,
            string.format("%s pasta %d", name, index),
            cf * CFrame.new(0, 0.35 + (index - 1) * 0.42, 0),
            Vector3.new(1.5, 0.36, 0.9),
            if index % 2 == 0 then P.BookTan else P.Paper,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.block(
        parent,
        name .. " caixa",
        cf * CFrame.new(0, 1.05, 0),
        Vector3.new(1.8, 1.6, 1.2),
        P.OakDark,
        M.wood,
        nil
    )
end

local function buildEntrance(parent: Instance)
    local root = Kit.model(parent, "Entrada")
    local y0 = 0
    -- Piso de mármore e tapete de entrada.
    box(root, "Piso da entrada", -10, 10, 0.02, 0.12, 27, 36.5, P.Marble, M.marble, nil)
    box(
        root,
        "Tapete da entrada",
        -5.5,
        5.5,
        0.12,
        0.18,
        28.5,
        35.2,
        P.CarpetDark,
        M.carpet,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Borda do tapete",
        -5.8,
        5.8,
        0.12,
        0.2,
        28.2,
        28.5,
        P.OchreDark,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Borda do tapete 2",
        -5.8,
        5.8,
        0.12,
        0.2,
        35.2,
        35.5,
        P.OchreDark,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )

    -- Balcão de recepção.
    box(root, "Balcão da recepção", 4.0, 9.2, 0.15, 3.5, 29.6, 31.4, P.Oak, M.wood, nil)
    box(root, "Tampo da recepção", 3.8, 9.4, 3.5, 3.8, 29.4, 31.6, P.Marble, M.marble, nil)
    box(root, "Frontal da recepção", 4.0, 9.2, 0.2, 3.2, 31.2, 31.6, P.OakDark, M.wood, nil)
    for index = 1, 4 do
        box(
            root,
            "Painel da recepção " .. index,
            4.5 + (index - 1) * 1.15,
            5.2 + (index - 1) * 1.15,
            0.7,
            2.7,
            31.15,
            31.2,
            P.Green,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    Furniture.chair(
        root,
        "Cadeira da recepção",
        CFrame.new(7.0, 0.12, 32.5) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Kit.block(
        root,
        "Livro de visitas",
        CFrame.new(6.3, 3.95, 30.5),
        Vector3.new(1.3, 0.18, 0.9),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Carimbo",
        CFrame.new(7.4, 4.0, 30.5),
        Vector3.new(0.3, 0.35, 0.3),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Telefone da recepção",
        CFrame.new(8.5, 4.0, 30.5),
        Vector3.new(0.8, 0.5, 0.6),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Luminária da recepção",
        CFrame.new(4.6, 4.2, 30.5),
        Vector3.new(0.4, 0.65, 0.4),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Banco de espera.
    Furniture.bench(
        root,
        "Banco de espera",
        CFrame.new(-5.5, 0.12, 29.4) * CFrame.Angles(0, math.rad(180), 0),
        8.0,
        P.Oak,
        M.wood
    )
    for _, spec in
        {
            { x = -8.6, z = 35.6 },
            { x = 8.6, z = 35.6 },
            { x = -3.6, z = 27.5 },
            { x = 3.6, z = 27.5 },
        }
    do
        Furniture.plant(root, "Planta da entrada", CFrame.new(spec.x, 0.12, spec.z), 0.55)
    end

    -- Quadro de avisos, relógio e placa de identificação.
    Furniture.noticeBoard(
        root,
        "Mural da entrada",
        CFrame.new(-9.85, 5.8, 32.0) * CFrame.Angles(0, math.rad(90), 0),
        5.0,
        3.0
    )
    Furniture.wallClock(
        root,
        "Relógio da entrada",
        CFrame.new(0, 8.0, 36.35) * CFrame.Angles(0, math.rad(180), 0)
    )
    Furniture.portrait(root, "Placa de identificação", CFrame.new(0, 7.0, 27.4), 5.5, 1.8)
    box(
        root,
        "Guarda-corpo da entrada",
        -10,
        10,
        8.8,
        9.2,
        28.0,
        28.2,
        P.StoneLight,
        M.stone,
        { collide = false, query = false, shadow = false }
    )

    -- Iluminação.
    for _, spec in
        {
            { x = -4.0, z = 31.0 },
            { x = 4.0, z = 31.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz da entrada " .. spec.x,
            CFrame.new(spec.x, y0 + 11.9, spec.z),
            4.0,
            1.2,
            P.NeonWarm,
            1.0,
            12
        )
    end
    Furniture.wallSconce(
        root,
        "Arandela da entrada oeste",
        CFrame.new(-9.85, 6.0, 30.0) * CFrame.Angles(0, math.rad(90), 0),
        P.NeonWarm,
        0.6,
        8
    )
    Furniture.wallSconce(
        root,
        "Arandela da entrada leste",
        CFrame.new(9.85, 6.0, 30.0) * CFrame.Angles(0, math.rad(-90), 0),
        P.NeonWarm,
        0.6,
        8
    )
    return root
end

local function buildWarden(parent: Instance)
    local root = Kit.model(parent, "Administracao")
    local y0 = 13
    local x1, x2, z1, z2 = -38.5, -10, 27, 36.5
    box(root, "Piso do gabinete", x1, x2, y0 + 0.02, y0 + 0.12, z1, z2, P.Oak, M.planks, nil)
    box(
        root,
        "Tapete do gabinete",
        -34,
        -20,
        y0 + 0.12,
        y0 + 0.2,
        29.5,
        34.5,
        P.Carpet,
        M.carpet,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Borda do tapete",
        -34.3,
        -19.7,
        y0 + 0.12,
        y0 + 0.22,
        29.2,
        29.5,
        P.OchreDark,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )
    box(
        root,
        "Borda do tapete 2",
        -34.3,
        -19.7,
        y0 + 0.12,
        y0 + 0.22,
        34.5,
        34.8,
        P.OchreDark,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )
    wainscot(root, "Lambri do gabinete", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)
    for _, x in { -30, -20 } do
        blinds(root, "Persiana do gabinete " .. x, x, z2 - 0.25, y0, 4.6)
    end

    Furniture.desk(
        root,
        "Mesa do diretor",
        CFrame.new(-25.0, y0 + 0.12, 32.0),
        7.0,
        3.4,
        3.2,
        P.Walnut,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do diretor",
        CFrame.new(-25.0, y0 + 0.12, 34.2) * CFrame.Angles(0, math.rad(180), 0),
        P.Leather,
        M.leather
    )
    for index, spec in
        {
            { x = -28.6, z = 30.4, ry = 0 },
            { x = -21.4, z = 30.4, ry = 0 },
        }
    do
        Furniture.chair(
            root,
            "Cadeira de visita " .. index,
            CFrame.new(spec.x, y0 + 0.12, spec.z) * CFrame.Angles(0, math.rad(spec.ry), 0),
            P.Walnut,
            M.wood
        )
    end
    Kit.block(
        root,
        "Abajur do diretor",
        CFrame.new(-22.0, y0 + 4.1, 31.4),
        Vector3.new(0.65, 1.0, 0.65),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(
        root:FindFirstChild("Abajur do diretor"),
        P.NeonWarm,
        { name = "Luz do abajur", brightness = 0.6, range = 7, shadows = false }
    )
    Kit.block(
        root,
        "Telefone do diretor",
        CFrame.new(-26.8, y0 + 3.75, 31.3),
        Vector3.new(0.9, 0.55, 0.7),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Livro do diretor",
        CFrame.new(-24.4, y0 + 3.6, 31.2),
        Vector3.new(1.6, 0.2, 1.0),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )

    -- Estante, cofre e arquivo.
    Furniture.shelf(
        root,
        "Estante do gabinete",
        CFrame.new(x1 + 0.8, y0 + 0.12, 32.0) * CFrame.Angles(0, math.rad(90), 0),
        7.0,
        9.5,
        1.7,
        5,
        P.Walnut,
        M.wood,
        true
    )
    box(root, "Cofre", -35.4, -32.4, y0 + 0.15, y0 + 4.0, 34.0, 35.5, P.Iron, M.iron, nil)
    Kit.block(
        root,
        "Roda do cofre",
        CFrame.new(-35.15, y0 + 2.1, 33.9),
        Vector3.new(0.7, 0.7, 0.16),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Furniture.lockerBank(
        root,
        "Armário de processos",
        CFrame.new(x2 - 3.0, y0 + 0.12, 33.0) * CFrame.Angles(0, math.rad(-90), 0),
        3,
        2.0,
        7.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.portrait(
        root,
        "Retrato do diretor",
        CFrame.new(-33.0, y0 + 6.3, z2 - 0.15) * CFrame.Angles(0, math.rad(180), 0),
        2.4,
        3.2
    )
    Furniture.portrait(
        root,
        "Retrato institucional",
        CFrame.new(-17.0, y0 + 6.3, z1 + 0.15),
        3.0,
        2.4
    )
    Furniture.plant(root, "Planta do gabinete", CFrame.new(x2 - 1.8, y0 + 0.12, 35.0), 0.8)
    Furniture.wallClock(root, "Relógio do gabinete", CFrame.new(-33.0, y0 + 7.0, z1 + 0.1), 1)
    Furniture.noticeBoard(
        root,
        "Mural do gabinete",
        CFrame.new(-25.0, y0 + 5.8, z1 + 0.1),
        4.5,
        2.6
    )

    Furniture.ceilingLight(
        root,
        "Luz do gabinete",
        CFrame.new(-25.0, y0 + 12.0, 32.0),
        5.0,
        1.4,
        P.NeonWarm,
        1.0,
        14
    )
    return root
end

local function buildStaffOffice(parent: Instance)
    local root = Kit.model(parent, "Escritorio")
    local y0 = 13
    local x1, x2, z1, z2 = 10, 38.5, 27, 36.5
    box(
        root,
        "Piso do escritório",
        x1,
        x2,
        y0 + 0.02,
        y0 + 0.12,
        z1,
        z2,
        P.Terrazzo,
        M.ceramic,
        nil
    )
    wainscot(root, "Lambri do escritório", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)
    for _, x in { 20, 30 } do
        blinds(root, "Persiana do escritório " .. x, x, z2 - 0.25, y0, 4.6)
    end

    for index, spec in
        {
            { x = 16.0, z = 32.6 },
            { x = 23.0, z = 32.6 },
            { x = 30.0, z = 32.6 },
        }
    do
        Furniture.desk(
            root,
            "Mesa administrativa " .. index,
            CFrame.new(spec.x, y0 + 0.12, spec.z),
            5.2,
            2.4,
            3.0,
            P.Oak,
            M.wood
        )
        Furniture.chair(
            root,
            "Cadeira administrativa " .. index,
            CFrame.new(spec.x, y0 + 0.12, spec.z + 2.2) * CFrame.Angles(0, math.rad(180), 0),
            P.Walnut,
            M.wood
        )
        Kit.block(
            root,
            "Máquina de escrever " .. index,
            CFrame.new(spec.x - 1.0, y0 + 3.55, spec.z),
            Vector3.new(1.4, 0.75, 1.0),
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            root,
            "Pilha de papéis " .. index,
            CFrame.new(spec.x + 1.2, y0 + 3.45, spec.z + 0.2),
            Vector3.new(1.0, 0.5, 0.8),
            P.Paper,
            M.paper,
            { collide = false, query = false, shadow = false }
        )
    end

    Furniture.lockerBank(
        root,
        "Armário do escritório",
        CFrame.new(x2 - 0.9, y0 + 0.12, 32.0) * CFrame.Angles(0, math.rad(-90), 0),
        4,
        2.0,
        8.0,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.cabinet(
        root,
        "Arquivo do escritório",
        CFrame.new(34.5, y0 + 0.12, 30.2),
        2.6,
        6.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.noticeBoard(
        root,
        "Mural do escritório",
        CFrame.new(30.0, y0 + 6.0, z1 + 0.1),
        5.5,
        3.0
    )
    Furniture.wallClock(root, "Relógio do escritório", CFrame.new(23.0, y0 + 7.0, z1 + 0.1), 1)

    -- Bebedouro e cabideiro.
    Kit.block(
        root,
        "Bebedouro",
        CFrame.new(35.0, y0 + 1.7, 31.0),
        Vector3.new(1.2, 3.4, 1.2),
        P.SteelLight,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Galão de água",
        CFrame.new(35.0, y0 + 3.8, 31.0),
        Vector3.new(0.8, 1.2, 0.8),
        P.Glass,
        M.glass,
        { transparency = 0.3, collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Cabideiro",
        CFrame.new(12.0, y0 + 3.4, 29.5),
        Vector3.new(0.18, 6.8, 0.18),
        P.Walnut,
        M.wood,
        nil
    )
    Kit.block(
        root,
        "Gancho do cabideiro",
        CFrame.new(12.0, y0 + 6.4, 30.0),
        Vector3.new(0.8, 0.18, 0.18),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    for index, spec in
        {
            { x = 18.0, z = 32.5 },
            { x = 28.0, z = 32.5 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz do escritório " .. index,
            CFrame.new(spec.x, y0 + 12.0, spec.z),
            4.4,
            1.2,
            P.NeonCool,
            1.0,
            13
        )
    end
    return root
end

local function buildControl(parent: Instance)
    local root = Kit.model(parent, "Controle")
    local y0 = 13
    local x1, x2, z1, z2 = -10, 10, 27, 36.5
    box(root, "Piso do controle", x1, x2, y0 + 0.02, y0 + 0.12, z1, z2, P.TileDark, M.ceramic, nil)
    wainscot(root, "Lambri do controle", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)

    -- Mesa de controle e painel de comunicação.
    Furniture.desk(
        root,
        "Mesa de controle",
        CFrame.new(0, y0 + 0.12, 32.0),
        7.0,
        2.8,
        3.2,
        P.IronLight,
        M.metal
    )
    Furniture.chair(
        root,
        "Cadeira de controle",
        CFrame.new(0, y0 + 0.12, 33.9) * CFrame.Angles(0, math.rad(180), 0),
        P.Leather,
        M.leather
    )
    Kit.block(
        root,
        "Rádio de controle",
        CFrame.new(-1.2, y0 + 3.8, 32.0),
        Vector3.new(1.2, 0.7, 0.8),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Antena de controle",
        CFrame.new(-1.2, y0 + 6.3, 32.0),
        Vector3.new(0.08, 4.8, 0.08),
        P.Steel,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Livro de ocorrências",
        CFrame.new(1.6, y0 + 3.7, 32.0),
        Vector3.new(1.6, 0.22, 1.0),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )

    -- Painel de chaves e quadro de plantão.
    box(
        root,
        "Painel de chaves",
        -8.8,
        8.8,
        y0 + 4.5,
        y0 + 8.2,
        z2 - 0.25,
        z2 - 0.05,
        P.Walnut,
        M.wood,
        nil
    )
    for row = 1, 5 do
        for column = 1, 10 do
            Kit.block(
                root,
                string.format("Chave do controle %d-%d", row, column),
                CFrame.new(-7.6 + (column - 1) * 1.7, y0 + 7.4 - (row - 1) * 0.65, z2 - 0.34),
                Vector3.new(0.22, 0.35, 0.08),
                P.Brass,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Furniture.noticeBoard(
        root,
        "Quadro de plantão",
        CFrame.new(-6.0, y0 + 6.0, z1 + 0.1),
        4.2,
        2.8
    )
    Furniture.wallClock(root, "Relógio do controle", CFrame.new(5.0, y0 + 7.0, z1 + 0.1), 1)

    -- Armários e mesa auxiliar.
    Furniture.lockerBank(
        root,
        "Armários do controle",
        CFrame.new(x2 - 0.9, y0 + 0.12, 31.0) * CFrame.Angles(0, math.rad(-90), 0),
        3,
        2.0,
        7.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.cabinet(
        root,
        "Arquivo do controle",
        CFrame.new(x1 + 1.3, y0 + 0.12, 35.0) * CFrame.Angles(0, math.rad(90), 0),
        3.0,
        6.0,
        1.8,
        P.GreenDark,
        M.metal
    )

    Furniture.ceilingLight(
        root,
        "Luz do controle",
        CFrame.new(0, y0 + 12.0, 31.5),
        4.6,
        1.2,
        P.NeonCool,
        1.0,
        13
    )
    return root
end

local function buildBreakRoom(parent: Instance)
    local root = Kit.model(parent, "Alojamento")
    local y0 = 26
    local x1, x2, z1, z2 = -38.5, -10, 27, 36.5
    box(root, "Piso do alojamento", x1, x2, y0 + 0.02, y0 + 0.12, z1, z2, P.Wood, M.planks, nil)
    box(
        root,
        "Tapete do alojamento",
        -30,
        -18,
        y0 + 0.12,
        y0 + 0.2,
        30,
        35,
        P.Carpet,
        M.carpet,
        { collide = false, query = false, shadow = false }
    )
    wainscot(root, "Lambri do alojamento", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)

    Furniture.table(
        root,
        "Mesa do plantão",
        CFrame.new(-24.0, y0 + 0.12, 32.5),
        6.5,
        3.2,
        3.0,
        P.Oak,
        M.wood
    )
    for index, spec in
        {
            { x = -26.5, z = 30.0 },
            { x = -21.5, z = 30.0 },
            { x = -26.5, z = 35.0, ry = 180 },
            { x = -21.5, z = 35.0, ry = 180 },
        }
    do
        Furniture.chair(
            root,
            "Cadeira do plantão " .. index,
            CFrame.new(spec.x, y0 + 0.12, spec.z) * CFrame.Angles(0, math.rad(spec.ry or 0), 0),
            P.Walnut,
            M.wood
        )
    end
    Kit.block(
        root,
        "Cafeteira",
        CFrame.new(-24.0, y0 + 3.6, 32.5),
        Vector3.new(1.1, 1.0, 1.0),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        Kit.block(
            root,
            "Caneca do plantão " .. index,
            CFrame.new(-25.5 + (index - 1) * 0.8, y0 + 3.45, 33.5),
            Vector3.new(0.3, 0.45, 0.3),
            P.Ceramic,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Dois camastros para o plantão noturno.
    for index, z in { 29.5, 33.0 } do
        Furniture.bed(
            root,
            "Cama do plantão " .. index,
            CFrame.new(-33.0, y0 + 0.12, z),
            5.6,
            2.4,
            P.BlanketNavy
        )
    end
    Furniture.lockerBank(
        root,
        "Armários do plantão",
        CFrame.new(x1 + 1.0, y0 + 0.12, 31.8) * CFrame.Angles(0, math.rad(90), 0),
        3,
        2.0,
        7.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.cabinet(
        root,
        "Armário de mantimentos",
        CFrame.new(x1 + 1.3, y0 + 0.12, 35.0) * CFrame.Angles(0, math.rad(90), 0),
        3.0,
        6.0,
        1.8,
        P.GreenDark,
        M.metal
    )
    Furniture.noticeBoard(
        root,
        "Mural do plantão",
        CFrame.new(-30.0, y0 + 6.0, z1 + 0.1),
        5.0,
        2.8
    )
    Furniture.wallClock(root, "Relógio do plantão", CFrame.new(-14.0, y0 + 7.0, z1 + 0.1), 1)
    Furniture.plant(root, "Planta do plantão", CFrame.new(x2 - 1.8, y0 + 0.12, 35.0), 0.6)

    for index, spec in
        {
            { x = -28.0, z = 31.0 },
            { x = -18.0, z = 31.0 },
        }
    do
        Furniture.ceilingLight(
            root,
            "Luz do alojamento " .. index,
            CFrame.new(spec.x, y0 + 12.0, spec.z),
            4.2,
            1.2,
            P.NeonWarm,
            0.95,
            12
        )
    end
    return root
end

local function buildRecords(parent: Instance)
    local root = Kit.model(parent, "Registro")
    local y0 = 26
    local x1, x2, z1, z2 = -10, 10, 27, 36.5
    box(root, "Piso do registro", x1, x2, y0 + 0.02, y0 + 0.12, z1, z2, P.Terrazzo, M.ceramic, nil)
    wainscot(root, "Lambri do registro", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)

    for row = 1, 3 do
        local z = 30.8 + (row - 1) * 2.35
        Furniture.shelf(
            root,
            "Estante de registro " .. row,
            CFrame.new(0, y0 + 0.12, z),
            14.0,
            7.5,
            1.3,
            4,
            P.IronLight,
            M.metal,
            false
        )
        for column = 1, 6 do
            Kit.block(
                root,
                string.format("Caixa de registro %d-%d", row, column),
                CFrame.new(-5.8 + (column - 1) * 2.3, y0 + 1.5, z + 0.2),
                Vector3.new(1.7, 1.3, 1.0),
                if (row + column) % 2 == 0 then P.OakLight else P.Oak,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Furniture.desk(
        root,
        "Mesa de consulta",
        CFrame.new(8.2, y0 + 0.12, 35.0),
        4.0,
        2.0,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(root, "Cadeira de consulta", CFrame.new(8.2, y0 + 0.12, 33.3), P.Walnut, M.wood)
    Kit.block(
        root,
        "Luminária de consulta",
        CFrame.new(9.7, y0 + 4.0, 35.0),
        Vector3.new(0.5, 0.8, 0.5),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Escada de arquivo",
        CFrame.new(-8.5, y0 + 4.0, 33.0),
        Vector3.new(0.8, 7.8, 0.5),
        P.OakDark,
        M.wood,
        nil
    )
    for step = 1, 5 do
        Kit.block(
            root,
            "Degrau de arquivo " .. step,
            CFrame.new(-8.5, y0 + 1.0 + (step - 1) * 1.5, 33.0),
            Vector3.new(1.2, 0.18, 0.7),
            P.Oak,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    Furniture.noticeBoard(root, "Mural do registro", CFrame.new(0, y0 + 6.0, z1 + 0.1), 5.0, 2.8)
    Furniture.ceilingLight(
        root,
        "Luz do registro",
        CFrame.new(0, y0 + 12.0, 31.5),
        4.6,
        1.2,
        P.NeonWarm,
        0.85,
        12
    )
    return root
end

local function buildArchive(parent: Instance)
    local root = Kit.model(parent, "Arquivo")
    local y0 = 26
    local x1, x2, z1, z2 = 10, 38.5, 27, 36.5
    box(root, "Piso do arquivo", x1, x2, y0 + 0.02, y0 + 0.1, z1, z2, P.Concrete, M.concrete, nil)
    wainscot(root, "Lambri do arquivo", x1 + 0.05, x2 - 0.05, z2 - 0.15, y0)

    for row = 1, 2 do
        local z = 32.0 + (row - 1) * 3.3
        Furniture.shelf(
            root,
            "Estante do arquivo " .. row,
            CFrame.new(23.0, y0 + 0.1, z),
            18.0,
            8.0,
            1.5,
            5,
            P.Iron,
            M.metal,
            false
        )
        for column = 1, 9 do
            Kit.block(
                root,
                string.format("Caixa do arquivo %d-%d", row, column),
                CFrame.new(15.0 + (column - 1) * 2.0, y0 + 1.0, z + 0.3),
                Vector3.new(1.4, 1.2, 1.1),
                if (row + column) % 2 == 0 then P.OakDark else P.Oak,
                M.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Furniture.desk(
        root,
        "Mesa do arquivo",
        CFrame.new(34.0, y0 + 0.1, 33.0) * CFrame.Angles(0, math.rad(-90), 0),
        4.5,
        2.2,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        root,
        "Cadeira do arquivo",
        CFrame.new(32.3, y0 + 0.1, 33.0) * CFrame.Angles(0, math.rad(90), 0),
        P.Walnut,
        M.wood
    )
    Furniture.cabinet(
        root,
        "Mapoteca",
        CFrame.new(12.5, y0 + 0.1, 35.0),
        3.0,
        4.5,
        1.8,
        P.GreenDark,
        M.metal
    )
    Kit.block(
        root,
        "Desumidificador",
        CFrame.new(36.8, y0 + 2.0, 35.5),
        Vector3.new(1.2, 3.6, 1.0),
        P.Steel,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Escada do arquivo",
        CFrame.new(31.5, y0 + 3.8, 29.5),
        Vector3.new(0.7, 7.4, 0.6),
        P.OakDark,
        M.wood,
        nil
    )
    Furniture.ceilingLight(
        root,
        "Luz do arquivo",
        CFrame.new(24.0, y0 + 12.0, 31.5),
        4.6,
        1.2,
        P.NeonCool,
        0.75,
        12
    )
    return root
end

local function buildNorthRooms(parent: Instance)
    local guard = Kit.model(parent, "SalaDeGuarda")
    local y0 = 0
    box(guard, "Piso da sala de guarda", -6, 6, 0.02, 0.1, -46, -27, P.TileDark, M.ceramic, nil)
    Furniture.lockerBank(
        guard,
        "Armários da guarda",
        CFrame.new(-5.1, 0.1, -36.0) * CFrame.Angles(0, math.rad(90), 0),
        3,
        1.9,
        7.2,
        1.7,
        P.GreenDark,
        M.metal
    )
    Furniture.table(
        guard,
        "Mesa da guarda",
        CFrame.new(0, 0.1, -38.0),
        5.5,
        2.6,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        guard,
        "Cadeira da guarda",
        CFrame.new(0, 0.1, -40.0) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Furniture.chair(guard, "Cadeira da guarda 2", CFrame.new(0, 0.1, -35.8), P.Walnut, M.wood)
    box(
        guard,
        "Quadro de chaves da guarda",
        3.5,
        5.7,
        4.4,
        8.0,
        -45.8,
        -45.55,
        P.Walnut,
        M.wood,
        nil
    )
    for row = 1, 4 do
        for column = 1, 5 do
            Kit.block(
                guard,
                string.format("Chave da guarda %d-%d", row, column),
                CFrame.new(4.0 + (column - 1) * 0.38, 7.2 - (row - 1) * 0.7, -45.5),
                Vector3.new(0.12, 0.3, 0.1),
                P.Brass,
                M.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Kit.block(
        guard,
        "Rádio da guarda",
        CFrame.new(-1.4, 3.7, -38.0),
        Vector3.new(1.1, 0.7, 0.7),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        guard,
        "Cafeteira da guarda",
        CFrame.new(1.6, 3.7, -38.0),
        Vector3.new(0.9, 0.9, 0.8),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Furniture.noticeBoard(guard, "Mural da guarda", CFrame.new(0, 5.8, -45.85), 5.0, 2.8)
    Furniture.ceilingLight(
        guard,
        "Luz da guarda",
        CFrame.new(0, 11.9, -36.5),
        4.2,
        1.2,
        P.NeonCool,
        1.0,
        12
    )

    local chief = Kit.model(parent, "ChefeDeGuarda")
    local yc = 13
    box(
        chief,
        "Piso do chefe de guarda",
        -6,
        6,
        yc + 0.02,
        yc + 0.1,
        -46,
        -27,
        P.Wood,
        M.planks,
        nil
    )
    Furniture.desk(
        chief,
        "Mesa do chefe de guarda",
        CFrame.new(0, yc + 0.1, -38.0),
        6.0,
        2.6,
        3.1,
        P.Walnut,
        M.wood
    )
    Furniture.chair(
        chief,
        "Cadeira do chefe de guarda",
        CFrame.new(0, yc + 0.1, -40.0) * CFrame.Angles(0, math.rad(180), 0),
        P.Leather,
        M.leather
    )
    Furniture.shelf(
        chief,
        "Estante do chefe de guarda",
        CFrame.new(-5.0, yc + 0.1, -36.0) * CFrame.Angles(0, math.rad(90), 0),
        8.0,
        8.5,
        1.4,
        4,
        P.Walnut,
        M.wood,
        true
    )
    Furniture.lockerBank(
        chief,
        "Armários do chefe de guarda",
        CFrame.new(5.0, yc + 0.1, -36.0) * CFrame.Angles(0, math.rad(-90), 0),
        3,
        1.9,
        7.2,
        1.7,
        P.GreenDark,
        M.metal
    )
    Furniture.noticeBoard(
        chief,
        "Mural do chefe de guarda",
        CFrame.new(0, yc + 6.0, -45.85),
        5.0,
        2.8
    )
    Furniture.wallClock(chief, "Relógio do chefe de guarda", CFrame.new(3.5, yc + 7.0, -45.85), 1)
    Furniture.ceilingLight(
        chief,
        "Luz do chefe de guarda",
        CFrame.new(0, yc + 12.0, -36.5),
        4.2,
        1.2,
        P.NeonWarm,
        1.0,
        12
    )

    local duty = Kit.model(parent, "Plantao")
    local yd = 26
    box(duty, "Piso do plantão", -6, 6, yd + 0.02, yd + 0.1, -46, -27, P.Terrazzo, M.ceramic, nil)
    Furniture.bed(
        duty,
        "Cama do plantão norte",
        CFrame.new(-3.7, yd + 0.1, -34.0) * CFrame.Angles(0, math.rad(90), 0),
        5.4,
        2.3,
        P.BlanketNavy
    )
    Furniture.table(
        duty,
        "Mesa do plantão norte",
        CFrame.new(3.0, yd + 0.1, -38.0),
        3.5,
        2.2,
        3.0,
        P.Oak,
        M.wood
    )
    Furniture.chair(
        duty,
        "Cadeira do plantão norte",
        CFrame.new(3.0, yd + 0.1, -40.0) * CFrame.Angles(0, math.rad(180), 0),
        P.Walnut,
        M.wood
    )
    Furniture.lockerBank(
        duty,
        "Armários do plantão norte",
        CFrame.new(5.0, yd + 0.1, -35.0) * CFrame.Angles(0, math.rad(-90), 0),
        3,
        1.9,
        7.2,
        1.7,
        P.GreenDark,
        M.metal
    )
    Kit.block(
        duty,
        "Rádio do plantão norte",
        CFrame.new(2.0, yd + 3.6, -38.0),
        Vector3.new(1.0, 0.7, 0.7),
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    Furniture.ceilingLight(
        duty,
        "Luz do plantão norte",
        CFrame.new(0, yd + 12.0, -36.5),
        4.2,
        1.2,
        P.NeonCool,
        0.85,
        12
    )
end

function Administracao.build(parent: Instance): Model
    buildEntrance(parent)
    buildWarden(parent)
    buildStaffOffice(parent)
    buildControl(parent)
    buildBreakRoom(parent)
    buildRecords(parent)
    buildArchive(parent)
    buildNorthRooms(parent)
    return parent:FindFirstChild("Administracao") :: Model
end

return Administracao

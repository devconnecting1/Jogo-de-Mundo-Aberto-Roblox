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
    Terreno, muros e fachada externa.
    O presídio fica dentro de um recinto fechado por muro de alvenaria com
    pilastras, portão de ferro e guarita. O pátio de exercícios tem muro mais
    alto, gatehouse e passagem controlada para o edifício principal.
]]

local Grounds = {}
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

local function coping(
    parent: Instance,
    name: string,
    minX: number,
    maxX: number,
    minZ: number,
    maxZ: number,
    y: number
)
    box(parent, name, minX, maxX, y, y + 0.6, minZ, maxZ, P.StoneLight, M.stone, nil)
end

local function perimeterWall(parent: Instance)
    local s = Layout.site
    local h = 9.0
    local t = 1.2
    local gateHalf = 12

    -- Frente, com vão para o portão.
    box(
        parent,
        "Muro frontal oeste",
        s.minX,
        -gateHalf,
        0,
        h,
        s.maxZ - t,
        s.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Muro frontal leste",
        gateHalf,
        s.maxX,
        0,
        h,
        s.maxZ - t,
        s.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    coping(
        parent,
        "Copa do muro frontal oeste",
        s.minX - 0.2,
        -gateHalf + 0.2,
        s.maxZ - t - 0.2,
        s.maxZ + 0.2,
        h
    )
    coping(
        parent,
        "Copa do muro frontal leste",
        gateHalf - 0.2,
        s.maxX + 0.2,
        s.maxZ - t - 0.2,
        s.maxZ + 0.2,
        h
    )

    -- Fundos e laterais.
    box(parent, "Muro dos fundos", s.minX, s.maxX, 0, h, s.minZ, s.minZ + t, P.Stone, M.stone, nil)
    box(parent, "Muro oeste", s.minX, s.minX + t, 0, h, s.minZ, s.maxZ, P.Stone, M.stone, nil)
    box(parent, "Muro leste", s.maxX - t, s.maxX, 0, h, s.minZ, s.maxZ, P.Stone, M.stone, nil)
    coping(
        parent,
        "Copa do muro dos fundos",
        s.minX - 0.2,
        s.maxX + 0.2,
        s.minZ - 0.2,
        s.minZ + t + 0.2,
        h
    )
    coping(parent, "Copa do muro oeste", s.minX - 0.2, s.minX + t + 0.2, s.minZ, s.maxZ, h)
    coping(parent, "Copa do muro leste", s.maxX - t - 0.2, s.maxX + 0.2, s.minZ, s.maxZ, h)

    -- Pilastras do muro.
    for index, x in { -90, -70, -50, -30, -14, 14, 30, 50, 70, 90, 110 } do
        if x < -gateHalf or x > gateHalf then
            box(
                parent,
                "Pilastra frontal " .. index,
                x - 1.0,
                x + 1.0,
                0,
                h + 1.2,
                s.maxZ - t - 0.4,
                s.maxZ + 0.4,
                P.StoneLight,
                M.stone,
                nil
            )
            coping(
                parent,
                "Copa da pilastra frontal " .. index,
                x - 1.3,
                x + 1.3,
                s.maxZ - t - 0.7,
                s.maxZ + 0.7,
                h + 1.2
            )
        end
    end
    for index, z in { -50, -30, -10, 10, 30, 50 } do
        box(
            parent,
            "Pilastra oeste " .. index,
            s.minX - 0.4,
            s.minX + t + 0.4,
            0,
            h + 1.2,
            z - 1.0,
            z + 1.0,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Pilastra leste " .. index,
            s.maxX - t - 0.4,
            s.maxX + 0.4,
            0,
            h + 1.2,
            z - 1.0,
            z + 1.0,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    -- Grades sobre o muro frontal.
    for index = 1, 54 do
        local x = -100 + (200 / 54) * (index - 0.5)
        if x < -gateHalf or x > gateHalf then
            Kit.block(
                parent,
                "Grade do muro frontal " .. index,
                CFrame.new(x, h + 1.9, s.maxZ - t * 0.5),
                Vector3.new(0.1, 3.2, 0.1),
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(
        parent,
        "Travessa da grade frontal",
        -100,
        -gateHalf,
        h + 3.4,
        h + 3.6,
        s.maxZ - t * 0.5 - 0.08,
        s.maxZ - t * 0.5 + 0.08,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    box(
        parent,
        "Travessa da grade frontal leste",
        gateHalf,
        100,
        h + 3.4,
        h + 3.6,
        s.maxZ - t * 0.5 - 0.08,
        s.maxZ - t * 0.5 + 0.08,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )

    -- Portão principal.
    for _, x in { -gateHalf, gateHalf } do
        box(
            parent,
            "Pilar do portão " .. x,
            x - 2.0,
            x + 2.0,
            0,
            12.5,
            s.maxZ - 2.8,
            s.maxZ + 1.2,
            P.Stone,
            M.stone,
            nil
        )
        box(
            parent,
            "Capitélio do portão " .. x,
            x - 2.5,
            x + 2.5,
            12.5,
            13.4,
            s.maxZ - 3.3,
            s.maxZ + 1.7,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Esfera do portão " .. x,
            x - 0.7,
            x + 0.7,
            13.4,
            14.8,
            s.maxZ - 1.5,
            s.maxZ - 0.1,
            P.StoneLight,
            M.stone,
            nil
        )
    end
    -- Portão de ferro fechado, entre os pilares.
    local gateZ = s.maxZ - 0.8
    for index = 1, 21 do
        local x = -gateHalf + (gateHalf * 2 / 20) * (index - 1)
        Kit.block(
            parent,
            "Grade do portão " .. index,
            CFrame.new(x, 4.6, gateZ),
            Vector3.new(0.14, 9.2, 0.14),
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for index, y in { 1.4, 4.4, 7.4, 8.9 } do
        box(
            parent,
            "Travessa do portão " .. index,
            -gateHalf,
            gateHalf,
            y,
            y + 0.16,
            gateZ - 0.08,
            gateZ + 0.08,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    box(
        parent,
        "Eixo central do portão",
        -0.18,
        0.18,
        0,
        9.2,
        gateZ - 0.12,
        gateZ + 0.12,
        P.BrassDark,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    for index, y in { 2.0, 6.0 } do
        Kit.block(
            parent,
            "Arremate do portão " .. index,
            CFrame.new(0, y, gateZ - 0.2),
            Vector3.new(0.8, 0.8, 0.08),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Guarita interna do portão.
    box(parent, "Base da guarita externa", 16, 24, 0, 0.8, 50, 57, P.Stone, M.stone, nil)
    box(
        parent,
        "Corpo da guarita externa",
        16.5,
        23.5,
        0.8,
        8.8,
        50.5,
        56.5,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        parent,
        "Cobertura da guarita externa",
        15.8,
        24.2,
        8.8,
        9.6,
        49.8,
        57.2,
        P.RoofSlate,
        M.slate,
        nil
    )
    box(
        parent,
        "Janela da guarita externa",
        16.5,
        16.7,
        3.8,
        7.0,
        52.0,
        55.0,
        P.Glass,
        M.glass,
        { transparency = 0.55, collide = false, query = false, shadow = false }
    )
    box(
        parent,
        "Porta da guarita externa",
        19.0,
        21.0,
        0.8,
        7.4,
        56.5,
        56.7,
        P.WalnutDeep,
        M.wood,
        nil
    )
    Furniture.ceilingLight(
        parent,
        "Luz da guarita externa",
        CFrame.new(20.0, 8.4, 53.5),
        2.2,
        0.8,
        P.NeonWarm,
        0.7,
        7
    )
    box(parent, "Barreira do portão", 3.0, 15.0, 3.0, 3.35, 53.0, 53.3, P.Ochre, M.metal, nil)
    Kit.block(
        parent,
        "Base da barreira",
        CFrame.new(15.2, 2.4, 53.15),
        Vector3.new(0.8, 4.8, 0.8),
        P.Iron,
        M.metal,
        nil
    )
end

local function yardWalls(parent: Instance)
    local y = Layout.yard
    local h = y.wallHeight
    local t = 1.5
    local westX = y.outer.minX + t * 0.5
    local eastX = y.outer.maxX - t * 0.5
    local northZ = y.outer.minZ + t * 0.5
    local southZ = y.outer.maxZ - t * 0.5

    -- Muro oeste com vão do portão.
    box(
        parent,
        "Muro oeste do pátio norte",
        y.outer.minX,
        y.outer.minX + t,
        0,
        h,
        y.outer.minZ,
        y.gate.minZ,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Muro oeste do pátio sul",
        y.outer.minX,
        y.outer.minX + t,
        0,
        h,
        y.gate.maxZ,
        y.outer.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Verga do portão do pátio",
        y.outer.minX,
        y.outer.minX + t,
        10.0,
        h,
        y.gate.minZ,
        y.gate.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Muro norte do pátio",
        y.outer.minX,
        y.outer.maxX,
        0,
        h,
        y.outer.minZ,
        y.outer.minZ + t,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Muro sul do pátio",
        y.outer.minX,
        y.outer.maxX,
        0,
        h,
        y.outer.maxZ - t,
        y.outer.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    box(
        parent,
        "Muro leste do pátio",
        y.outer.maxX - t,
        y.outer.maxX,
        0,
        h,
        y.outer.minZ,
        y.outer.maxZ,
        P.Stone,
        M.stone,
        nil
    )
    coping(
        parent,
        "Copa do muro norte do pátio",
        y.outer.minX - 0.2,
        y.outer.maxX + 0.2,
        y.outer.minZ - 0.2,
        y.outer.minZ + t + 0.2,
        h
    )
    coping(
        parent,
        "Copa do muro sul do pátio",
        y.outer.minX - 0.2,
        y.outer.maxX + 0.2,
        y.outer.maxZ - t - 0.2,
        y.outer.maxZ + 0.2,
        h
    )
    coping(
        parent,
        "Copa do muro leste do pátio",
        y.outer.maxX - t - 0.2,
        y.outer.maxX + 0.2,
        y.outer.minZ,
        y.outer.maxZ,
        h
    )
    coping(
        parent,
        "Copa do muro oeste do pátio norte",
        y.outer.minX - 0.2,
        y.outer.minX + t + 0.2,
        y.outer.minZ,
        y.gate.minZ,
        h
    )
    coping(
        parent,
        "Copa do muro oeste do pátio sul",
        y.outer.minX - 0.2,
        y.outer.minX + t + 0.2,
        y.gate.maxZ,
        y.outer.maxZ,
        h
    )

    -- Pilastras.
    for index, x in { 52, 68, 84, 102 } do
        box(
            parent,
            "Pilastra do pátio norte " .. index,
            x - 1.0,
            x + 1.0,
            0,
            h + 1.3,
            y.outer.minZ - 0.4,
            y.outer.minZ + t + 0.4,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Pilastra do pátio sul " .. index,
            x - 1.0,
            x + 1.0,
            0,
            h + 1.3,
            y.outer.maxZ - t - 0.4,
            y.outer.maxZ + 0.4,
            P.StoneLight,
            M.stone,
            nil
        )
    end
    for index, z in { -26, -6, 14, 30 } do
        box(
            parent,
            "Pilastra do pátio oeste " .. index,
            y.outer.minX - 0.4,
            y.outer.minX + t + 0.4,
            0,
            h + 1.3,
            z - 1.0,
            z + 1.0,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Pilastra do pátio leste " .. index,
            y.outer.maxX - t - 0.4,
            y.outer.maxX + 0.4,
            0,
            h + 1.3,
            z - 1.0,
            z + 1.0,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    -- Portão de ferro do pátio, aberto contra o muro.
    for _, z in { y.gate.minZ, y.gate.maxZ } do
        box(
            parent,
            "Pilar do portão do pátio " .. z,
            y.outer.minX - 0.6,
            y.outer.minX + t + 0.6,
            0,
            11.0,
            z - 0.5,
            z + 0.5,
            P.StoneLight,
            M.stone,
            nil
        )
    end
    for side = -1, 1, 2 do
        local hingeZ = if side < 0 then y.gate.minZ else y.gate.maxZ
        local pivot = CFrame.new(y.outer.minX + t + 0.2, 0.2, hingeZ)
            * CFrame.Angles(0, math.rad(side * 80), 0)
        for index = 1, 5 do
            Kit.block(
                parent,
                string.format("Grade do portão do pátio %d-%d", side, index),
                pivot * CFrame.new(0, 4.5, (index - 3) * 0.9),
                Vector3.new(0.12, 8.6, 0.12),
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
        for _, yy in { 1.2, 4.6, 8.0 } do
            Kit.block(
                parent,
                string.format("Travessa do portão do pátio %d-%.0f", side, yy),
                pivot * CFrame.new(0, yy, 0),
                Vector3.new(0.12, 0.14, 4.8),
                P.Iron,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    box(
        parent,
        "Luz do portão do pátio",
        y.outer.minX + t + 0.1,
        y.outer.minX + t + 0.3,
        10.2,
        10.6,
        (y.gate.minZ + y.gate.maxZ) * 0.5 - 0.4,
        (y.gate.minZ + y.gate.maxZ) * 0.5 + 0.4,
        P.NeonWarm,
        M.neon,
        { collide = false, query = false, shadow = false }
    )
end

local function forecourt(parent: Instance)
    local f = Layout.forecourt
    -- Piso de lajes.
    box(
        parent,
        "Base do pátio de entrada",
        f.minX - 10,
        f.maxX + 10,
        -0.3,
        0.02,
        f.minZ,
        f.maxZ + 2,
        P.StoneDark,
        M.stone,
        nil
    )
    local tile = 6
    for row = 1, 4 do
        for column = 1, 12 do
            local x = f.minX + tile * (column - 0.5)
            local z = f.minZ + (20 / 4) * (row - 0.5)
            box(
                parent,
                string.format("Laje do pátio %d-%d", row, column),
                x - tile * 0.5 + 0.08,
                x + tile * 0.5 - 0.08,
                0.02,
                0.1,
                z - 2.5 + 0.08,
                z + 2.5 - 0.08,
                if (row + column) % 2 == 0 then P.Path else P.StoneLight,
                M.pavement,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    -- Faixa central de acesso.
    box(
        parent,
        "Eixo de acesso",
        -6,
        6,
        0.02,
        0.13,
        f.minZ,
        Layout.site.maxZ,
        P.Marble,
        M.marble,
        nil
    )
    box(
        parent,
        "Borda oeste do eixo",
        -6.4,
        -6,
        0.03,
        0.15,
        f.minZ,
        Layout.site.maxZ,
        P.GreenDark,
        M.stone,
        nil
    )
    box(
        parent,
        "Borda leste do eixo",
        6,
        6.4,
        0.03,
        0.15,
        f.minZ,
        Layout.site.maxZ,
        P.GreenDark,
        M.stone,
        nil
    )

    -- Canteiros e gramados.
    for _, spec in
        {
            { x1 = -34, x2 = -14, z1 = 43, z2 = 55 },
            { x1 = 14, x2 = 34, z1 = 43, z2 = 55 },
        }
    do
        box(
            parent,
            "Grama do canteiro",
            spec.x1,
            spec.x2,
            0.02,
            0.12,
            spec.z1,
            spec.z2,
            P.Grass,
            M.grass,
            nil
        )
        box(
            parent,
            "Borda do canteiro oeste",
            spec.x1 - 0.3,
            spec.x1,
            0.1,
            1.2,
            spec.z1 - 0.3,
            spec.z2 + 0.3,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Borda do canteiro leste",
            spec.x2,
            spec.x2 + 0.3,
            0.1,
            1.2,
            spec.z1 - 0.3,
            spec.z2 + 0.3,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Borda do canteiro norte",
            spec.x1 - 0.3,
            spec.x2 + 0.3,
            0.1,
            1.2,
            spec.z1 - 0.3,
            spec.z1,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            parent,
            "Borda do canteiro sul",
            spec.x1 - 0.3,
            spec.x2 + 0.3,
            0.1,
            1.2,
            spec.z2,
            spec.z2 + 0.3,
            P.StoneLight,
            M.stone,
            nil
        )
        for index = 1, 5 do
            local hedgeX = spec.x1 + 2 + (index - 1) * 3.4
            box(
                parent,
                "Topiaria " .. hedgeX,
                hedgeX - 1.2,
                hedgeX + 1.2,
                0.1,
                2.4,
                spec.z2 - 2.4,
                spec.z2 - 0.8,
                P.Hedge,
                M.grass,
                nil
            )
        end
    end

    -- Jardim lateral do refeitório e dos fundos.
    box(parent, "Grama lateral oeste", -100, -72, 0.02, 0.1, 36, 50, P.Grass, M.grass, nil)
    box(parent, "Grama do fundo", -70, 100, 0.02, 0.1, -52, -48, P.Grass, M.grass, nil)
    box(parent, "Caminho de serviço", -100, 110, 0.02, 0.08, 40, 44, P.Asphalt, M.asphalt, nil)

    -- Postes de iluminação do pátio de entrada.
    for _, spec in
        {
            { x = -24, z = 44 },
            { x = 24, z = 44 },
            { x = -30, z = 56 },
            { x = 30, z = 56 },
        }
    do
        Furniture.lampPost(
            parent,
            "Poste da entrada " .. spec.x .. "/" .. spec.z,
            CFrame.new(spec.x, 0.1, spec.z),
            12.0,
            P.NeonWarm,
            1.1,
            22
        )
    end

    -- Mastro e bandeira.
    box(parent, "Base do mastro", 9.0, 12.0, 0.1, 1.0, 47.0, 50.0, P.StoneLight, M.stone, nil)
    Kit.block(
        parent,
        "Mastro",
        CFrame.new(10.5, 13.0, 48.5),
        Vector3.new(0.22, 24.0, 0.22),
        P.SteelLight,
        M.metal,
        nil
    )
    Kit.block(
        parent,
        "Bandeira",
        CFrame.new(14.5, 22.5, 48.5),
        Vector3.new(8.0, 4.6, 0.08),
        P.BookBlue,
        M.fabric,
        nil
    )
    Kit.block(
        parent,
        "Bandeira faixa clara",
        CFrame.new(14.5, 22.5, 48.55),
        Vector3.new(8.0, 1.1, 0.04),
        P.LinenWhite,
        M.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        "Ponta do mastro",
        CFrame.new(10.5, 25.3, 48.5),
        Vector3.new(0.45, 0.6, 0.45),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Bancos externos e lixeiras.
    for _, spec in
        {
            { x = -18, z = 58 },
            { x = 18, z = 58 },
        }
    do
        Furniture.bench(
            parent,
            "Banco externo " .. spec.x,
            CFrame.new(spec.x, 0.1, spec.z) * CFrame.Angles(0, math.rad(180), 0),
            7.0,
            P.Oak,
            M.wood
        )
        Kit.block(
            parent,
            "Lixeira externa " .. spec.x,
            CFrame.new(spec.x + 5.0, 1.2, spec.z),
            Vector3.new(1.1, 2.2, 1.1),
            P.Iron,
            M.metal,
            nil
        )
    end

    -- Luminárias na fachada principal.
    for _, x in { -18, 18 } do
        Furniture.wallSconce(
            parent,
            "Lanterna da fachada " .. x,
            CFrame.new(x, 8.0, 38.15),
            P.NeonWarm,
            1.0,
            12
        )
    end
end

function Grounds.build(exteriorRoot: Instance)
    local terrain = Kit.model(exteriorRoot, "Terreno")
    box(
        terrain,
        "Terreno",
        Layout.site.minX,
        Layout.site.maxX,
        -1.4,
        0,
        Layout.site.minZ,
        Layout.site.maxZ,
        P.Grass,
        M.grass,
        nil
    )
    box(terrain, "Acesso pavimentado", -102, 118, 0.01, 0.06, 38, 44, P.Asphalt, M.asphalt, nil)
    box(
        terrain,
        "Calçada do edifício",
        -41.5,
        41.5,
        0.02,
        0.12,
        36.5,
        39.0,
        P.Path,
        M.pavement,
        nil
    )
    box(
        terrain,
        "Calçada do refeitório",
        -99.5,
        -39.5,
        0.02,
        0.1,
        -25.5,
        33.5,
        P.Path,
        M.pavement,
        nil
    )
    perimeterWall(terrain)
    yardWalls(terrain)
    forecourt(terrain)
    return terrain
end

return Grounds

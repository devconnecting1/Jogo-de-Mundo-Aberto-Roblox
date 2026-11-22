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
    Oficina de carpintaria e casa de máquinas no térreo da ala norte.
    A oficina tem bancadas, prateleiras de ferramentas, cavaletes e uma gaiola
    de ferramentas trancada. A casa de máquinas concentra caldeira, gerador,
    quadros elétricos, válvulas e tubulação.
]]

local Oficina = {}
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

local function toolBoard(
    parent: Instance,
    name: string,
    x1: number,
    x2: number,
    y: number,
    z: number
)
    box(
        parent,
        name .. " placa",
        x1,
        x2,
        y,
        y + 3.4,
        z - 0.06,
        z + 0.06,
        P.OakDark,
        M.wood,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 7 do
        local x = x1 + 0.55 + (index - 1) * ((x2 - x1 - 1.1) / 7)
        Kit.block(
            parent,
            string.format("%s ferramenta %d", name, index),
            CFrame.new(x, y + 1.2 + (index % 2) * 0.7, z + 0.08),
            Vector3.new(0.12, 1.4, 0.08),
            P.SteelLight,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            parent,
            string.format("%s cabo %d", name, index),
            CFrame.new(x, y + 0.6 + (index % 2) * 0.7, z + 0.1),
            Vector3.new(0.36, 0.55, 0.12),
            P.Ochre,
            M.wood,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function buildWorkshop(parent: Instance)
    local root = Kit.model(parent, "Oficina")
    local x1, x2, z1, z2 = -38.5, -22, -46, -27
    root:SetAttribute("Bancadas", 4)

    box(root, "Piso da oficina", x1, x2, 0.02, 0.1, z1, z2, P.Concrete, M.concrete, nil)
    box(
        root,
        "Faixa de circulação",
        -26,
        -22.5,
        0.1,
        0.16,
        z1 + 1.0,
        z2 - 0.8,
        P.TileDark,
        M.ceramic,
        { collide = false, query = false, shadow = false }
    )

    -- Bancadas perimetrais.
    Furniture.table(
        root,
        "Bancada oeste",
        CFrame.new(x1 + 2.1, 0.1, -36.5) * CFrame.Angles(0, math.rad(90), 0),
        12.0,
        3.0,
        3.2,
        P.Oak,
        M.planks
    )
    Furniture.table(
        root,
        "Bancada norte",
        CFrame.new(-31.0, 0.1, -43.3),
        11.0,
        2.6,
        3.2,
        P.Oak,
        M.planks
    )
    Furniture.table(
        root,
        "Bancada leste",
        CFrame.new(x2 - 1.7, 0.1, -38.0) * CFrame.Angles(0, math.rad(-90), 0),
        8.0,
        2.4,
        3.2,
        P.Oak,
        M.planks
    )
    toolBoard(root, "Painel de ferramentas norte", -35.0, -26.5, 3.8, -44.35)

    -- Torno e serra.
    Kit.block(
        root,
        "Torno",
        CFrame.new(-37.0, 4.5, -36.0),
        Vector3.new(2.2, 1.8, 2.6),
        P.Iron,
        M.iron,
        nil
    )
    Kit.block(
        root,
        "Morsa do torno",
        CFrame.new(-36.0, 5.5, -35.0),
        Vector3.new(1.0, 0.7, 1.0),
        P.Steel,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Serra circular de bancada",
        CFrame.new(-31.0, 4.2, -43.5),
        Vector3.new(2.4, 1.8, 2.0),
        P.SteelDark,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Guia da serra",
        CFrame.new(-31.0, 5.4, -43.5),
        Vector3.new(2.8, 0.35, 2.4),
        P.Steel,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Proteção da serra",
        CFrame.new(-30.5, 5.8, -43.2),
        Vector3.new(1.1, 0.8, 1.1),
        P.Ochre,
        M.metal,
        nil
    )

    -- Cavaletes e madeira.
    for index, spec in
        {
            { x = -29.0, z = -37.0 },
            { x = -25.0, z = -40.0 },
        }
    do
        box(
            root,
            "Cavalete " .. index,
            spec.x - 1.4,
            spec.x + 1.4,
            0.1,
            2.2,
            spec.z - 0.25,
            spec.z + 0.25,
            P.OakDark,
            M.wood,
            nil
        )
        Kit.block(
            root,
            "Tábua no cavalete " .. index,
            CFrame.new(spec.x, 2.7, spec.z),
            Vector3.new(5.2, 0.3, 1.2),
            P.OakLight,
            M.planks,
            nil
        )
    end
    for index = 1, 3 do
        box(
            root,
            "Pilha de madeira " .. index,
            -38.2,
            -35.8,
            0.1 + index * 0.35,
            0.4 + index * 0.35,
            -29.5,
            -27.8,
            P.OakLight,
            M.planks,
            nil
        )
    end

    -- Gaiola de ferramentas.
    for _, spec in
        {
            { name = "poste 1", x = -25.3, z = -45.2 },
            { name = "poste 2", x = -22.7, z = -45.2 },
            { name = "poste 3", x = -25.3, z = -42.2 },
            { name = "poste 4", x = -22.7, z = -42.2 },
        }
    do
        Kit.block(
            root,
            "Poste da gaiola " .. spec.name,
            CFrame.new(spec.x, 3.5, spec.z),
            Vector3.new(0.18, 7.0, 0.18),
            P.Iron,
            M.metal,
            nil
        )
    end
    for index = 1, 5 do
        local x = -25.0 + (index - 1) * 0.55
        Kit.block(
            root,
            "Barra da gaiola " .. index,
            CFrame.new(x, 3.5, -45.2),
            Vector3.new(0.08, 7.0, 0.08),
            P.Iron,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Cobertura da gaiola", -25.4, -22.6, 7.0, 7.2, -45.3, -42.1, P.Iron, M.diamond, nil)
    box(root, "Porta da gaiola", -25.4, -22.6, 0.4, 6.8, -42.3, -42.1, P.Iron, M.iron, nil)
    Kit.block(
        root,
        "Cadeado da gaiola",
        CFrame.new(-24.0, 3.5, -42.0),
        Vector3.new(0.35, 0.55, 0.2),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Segurança e primeiros socorros.
    Kit.block(
        root,
        "Extintor da oficina",
        CFrame.new(-22.4, 2.6, -30.0),
        Vector3.new(0.55, 1.8, 0.45),
        P.BookRed,
        M.metal,
        nil
    )
    box(
        root,
        "Quadro de primeiros socorros",
        -26.5,
        -24.0,
        5.0,
        7.8,
        -44.4,
        -44.25,
        P.LinenWhite,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Cruz de primeiros socorros",
        CFrame.new(-25.25, 6.4, -44.2),
        Vector3.new(1.6, 0.5, 0.08),
        P.BookRed,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        root,
        "Cruz vertical de primeiros socorros",
        CFrame.new(-25.25, 6.4, -44.18),
        Vector3.new(0.5, 1.6, 0.08),
        P.BookRed,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Furniture.noticeBoard(
        root,
        "Mural de segurança",
        CFrame.new(-30.0, 5.8, -27.65) * CFrame.Angles(0, math.rad(180), 0),
        5.0,
        2.8
    )
    Furniture.wallClock(
        root,
        "Relógio da oficina",
        CFrame.new(-35.0, 7.0, -27.65) * CFrame.Angles(0, math.rad(180), 0),
        1
    )
    Furniture.ceilingLight(
        root,
        "Luz da oficina",
        CFrame.new(-30.0, 11.9, -36.0),
        4.6,
        1.2,
        P.NeonCool,
        0.9,
        12
    )
    Furniture.ceilingLight(
        root,
        "Luz da oficina 2",
        CFrame.new(-25.0, 11.9, -32.0),
        3.8,
        1.2,
        P.NeonWarm,
        0.8,
        10
    )
    return root
end

local function buildMachineRoom(parent: Instance)
    local root = Kit.model(parent, "CasaDeMaquinas")
    local x1, x2, z1, z2 = 22, 38.5, -46, -27
    box(root, "Piso da casa de máquinas", x1, x2, 0.02, 0.1, z1, z2, P.Concrete, M.concrete, nil)
    box(
        root,
        "Faixa de segurança",
        x1 + 1.0,
        x1 + 3.0,
        0.1,
        0.16,
        z1 + 1.0,
        z2 - 1.0,
        P.Ochre,
        M.concrete,
        { collide = false, query = false, shadow = false }
    )

    -- Caldeira principal.
    box(root, "Caldeira", 23.0, 30.0, 0.2, 10.5, -44.5, -38.0, P.BrickDark, M.brick, nil)
    box(root, "Porta da caldeira", 22.9, 23.1, 0.8, 5.0, -43.0, -39.5, P.Iron, M.iron, nil)
    Kit.block(
        root,
        "Volante da caldeira",
        CFrame.new(22.7, 2.9, -41.2),
        Vector3.new(0.3, 1.4, 1.4),
        P.Brass,
        M.metal,
        nil
    )
    for index = 1, 4 do
        box(
            root,
            "Tubulação da caldeira " .. index,
            29.8,
            36.5,
            8.5 + index * 0.55,
            8.8 + index * 0.55,
            -41.0,
            -40.4,
            P.Steel,
            M.metal,
            nil
        )
    end
    box(root, "Chaminé interna", 25.5, 27.5, 10.5, 12.5, -43.5, -41.5, P.Brick, M.brick, nil)

    -- Gerador e quadro elétrico.
    box(root, "Gerador", 31.0, 37.5, 0.2, 5.5, -44.5, -40.0, P.Iron, M.metal, nil)
    box(
        root,
        "Silenciador do gerador",
        31.5,
        37.0,
        5.5,
        7.2,
        -44.0,
        -41.5,
        P.SteelDark,
        M.steel,
        nil
    )
    for index = 1, 5 do
        box(
            root,
            "Aleta do gerador " .. index,
            37.4,
            37.55,
            1.0 + index * 0.55,
            1.45 + index * 0.55,
            -43.5,
            -41.0,
            P.IronLight,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    box(root, "Quadro elétrico", 22.5, 23.0, 1.0, 8.0, -34.0, -30.0, P.SteelDark, M.metal, nil)
    for index = 1, 8 do
        Kit.block(
            root,
            "Disjuntor " .. index,
            CFrame.new(23.1, 1.8 + (index - 1) * 0.75, -32.5),
            Vector3.new(0.2, 0.35, 0.55),
            P.Iron,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.block(
        root,
        "Luz de emergência",
        CFrame.new(26.0, 8.5, -32.0),
        Vector3.new(0.6, 0.3, 0.6),
        P.NeonGreen,
        M.neon,
        { collide = false, query = false, shadow = false }
    )

    -- Tanque de água e bombas.
    box(root, "Tanque de água", 30.0, 38.0, 0.2, 9.0, -33.5, -28.5, P.SteelLight, M.metal, nil)
    for index = 1, 3 do
        box(
            root,
            "Cinta do tanque " .. index,
            29.8,
            38.2,
            2.0 + index * 2.0,
            2.25 + index * 2.0,
            -33.7,
            -28.3,
            P.SteelDark,
            M.metal,
            nil
        )
    end
    Kit.block(
        root,
        "Bomba 1",
        CFrame.new(26.5, 1.8, -30.0),
        Vector3.new(2.0, 3.4, 2.0),
        P.Steel,
        M.metal,
        nil
    )
    Kit.block(
        root,
        "Bomba 2",
        CFrame.new(26.5, 1.8, -33.0),
        Vector3.new(2.0, 3.4, 2.0),
        P.Steel,
        M.metal,
        nil
    )
    for index = 1, 4 do
        box(
            root,
            "Tubulação de água " .. index,
            22.8,
            38.0,
            9.2 + index * 0.32,
            9.4 + index * 0.32,
            -34.0 + index * 0.6,
            -33.7 + index * 0.6,
            P.Steel,
            M.metal,
            nil
        )
    end

    -- Materiais de reserva.
    for index = 1, 3 do
        Kit.block(
            root,
            "Saco de material " .. index,
            CFrame.new(35.0 + index * 0.8, 1.2, -38.0),
            Vector3.new(1.4, 2.2, 1.0),
            P.Linen,
            M.fabric,
            nil
        )
    end

    Furniture.noticeBoard(
        root,
        "Mural da casa de máquinas",
        CFrame.new(30.0, 5.8, -27.65) * CFrame.Angles(0, math.rad(180), 0),
        5.0,
        2.8
    )
    Furniture.ceilingLight(
        root,
        "Luz da casa de máquinas",
        CFrame.new(29.0, 11.9, -36.0),
        4.6,
        1.2,
        P.NeonCool,
        0.85,
        12
    )
    Furniture.ceilingLight(
        root,
        "Luz da casa de máquinas 2",
        CFrame.new(33.0, 11.9, -30.5),
        3.8,
        1.2,
        P.NeonCool,
        0.65,
        10
    )
    return root
end

function Oficina.build(parent: Instance)
    buildWorkshop(parent)
    buildMachineRoom(parent)
    return parent:FindFirstChild("Oficina") :: Model
end

return Oficina

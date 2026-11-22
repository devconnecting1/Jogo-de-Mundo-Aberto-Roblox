local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Cozinha compacta, mas completamente equipada: armários shaker, bancada de
    pedra, cooktop embutido, forno, coifa, geladeira retrô, pia e toda a
    pequena bagunça que faz uma casa parecer habitada.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")

local Kitchen = {}

local CABINET_FRONT = -7.99
local COUNTER_TOP = 3.0
local COUNTER_Z = -8.92
local WALL_Z = -9.96

local function shakerPanel(
    parent: Instance,
    name: string,
    x: number,
    y: number,
    width: number,
    height: number,
    faceZ: number,
    color: Color3,
    handle: string?
)
    Kit.box(
        parent,
        name,
        CFrame.new(x, y, faceZ),
        Vector3.new(width, height, 0.075),
        color,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    local rail = 0.09
    local inset = 0.06
    Kit.box(
        parent,
        name .. " moldura",
        CFrame.new(x, y + height * 0.5 - rail * 0.5, faceZ - 0.035),
        Vector3.new(width, rail, 0.05),
        Palette.CabinetHighlight,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        parent,
        name .. " moldura",
        CFrame.new(x, y - height * 0.5 + rail * 0.5, faceZ - 0.035),
        Vector3.new(width, rail, 0.05),
        Palette.CabinetHighlight,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        parent,
        name .. " moldura",
        CFrame.new(x - width * 0.5 + rail * 0.5, y, faceZ - 0.035),
        Vector3.new(rail, height - rail * 2, 0.05),
        Palette.CabinetHighlight,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        parent,
        name .. " moldura",
        CFrame.new(x + width * 0.5 - rail * 0.5, y, faceZ - 0.035),
        Vector3.new(rail, height - rail * 2, 0.05),
        Palette.CabinetHighlight,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        parent,
        name .. " rebaixo",
        CFrame.new(x, y, faceZ - inset - 0.005),
        Vector3.new(width - 0.26, height - 0.26, 0.025),
        Palette.CabinetShade,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    if handle == "cup" then
        Kit.box(
            parent,
            name .. " puxador",
            CFrame.new(x, y + height * 0.5 - 0.18, faceZ - 0.11),
            Vector3.new(0.36, 0.07, 0.1),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false, reflectance = 0.25 }
        )
        for side = -1, 1 do
            Kit.rodBetween(
                parent,
                name .. " apoio",
                Vector3.new(x + side * 0.15, y + height * 0.5 - 0.18, faceZ - 0.055),
                Vector3.new(x + side * 0.15, y + height * 0.5 - 0.24, faceZ - 0.13),
                0.034,
                Palette.Brass,
                Palette.Materials.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    else
        Kit.sphere(
            parent,
            name .. " puxador",
            CFrame.new(x + width * 0.5 - 0.22, y, faceZ - 0.1),
            Vector3.new(0.16, 0.16, 0.16),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false, reflectance = 0.25 }
        )
    end
end

local function buildCabinets(parent: Instance)
    local model = Kit.model(parent, "Armarios e bancada")

    Kit.box(
        model,
        "Rodapé recuado",
        CFrame.new(-2.65, 0.17, -9.05),
        Vector3.new(7.65, 0.34, 1.6),
        Palette.Ink,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Corpo dos armários",
        CFrame.new(-2.65, 1.57, -9.02),
        Vector3.new(7.75, 2.5, 1.92),
        Palette.Cabinet,
        Palette.Materials.paint,
        { collide = true, query = true }
    )

    local modules = {
        { x = -5.875, width = 1.35, kind = "doors" },
        { x = -4.475, width = 1.45, kind = "doors" },
        { x = -2.7, width = 2.1, kind = "sink" },
        { x = -0.2, width = 2.9, kind = "oven" },
    }

    local seams = { -6.55, -5.2, -3.75, -1.65, 1.25 }
    for index, seamX in seams do
        Kit.box(
            model,
            "Junta do armário",
            CFrame.new(seamX, 1.55, COUNTER_Z + 1.02),
            Vector3.new(0.035, 2.3, 0.035),
            Palette.CabinetShade,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    for _, module in modules do
        if module.kind == "oven" then
            Kit.box(
                model,
                "Forno - moldura",
                CFrame.new(module.x, 1.55, CABINET_FRONT - 0.01),
                Vector3.new(module.width - 0.16, 2.35, 0.09),
                Palette.Steel,
                Palette.Materials.metal,
                { collide = false, query = false }
            )
            Kit.box(
                model,
                "Forno - vidro",
                CFrame.new(module.x, 1.35, CABINET_FRONT - 0.075),
                Vector3.new(module.width - 0.38, 1.52, 0.055),
                Palette.BlackGlass,
                Palette.Materials.glass,
                {
                    collide = false,
                    query = false,
                    shadow = false,
                    transparency = 0.15,
                    reflectance = 0.18,
                }
            )
            Kit.box(
                model,
                "Forno - puxador",
                CFrame.new(module.x, 2.32, CABINET_FRONT - 0.18),
                Vector3.new(module.width - 0.55, 0.09, 0.14),
                Palette.Chrome,
                Palette.Materials.metal,
                { collide = false, query = false, shadow = false, reflectance = 0.45 }
            )
            for side = -1, 1 do
                Kit.box(
                    model,
                    "Forno - suporte",
                    CFrame.new(module.x + side * (module.width * 0.5 - 0.3), 2.34, CABINET_FRONT - 0.1),
                    Vector3.new(0.08, 0.26, 0.15),
                    Palette.Chrome,
                    Palette.Materials.metal,
                    { collide = false, query = false, shadow = false }
                )
            end
            for knob = 1, 4 do
                Kit.cylinder(
                    model,
                    "Botão do forno",
                    CFrame.new(module.x - 0.85 + (knob - 1) * 0.56, 2.62, CABINET_FRONT - 0.08),
                    0.08,
                    0.19,
                    Palette.SteelDark,
                    Palette.Materials.metal,
                    "z",
                    { collide = false, query = false, shadow = false }
                )
            end
        elseif module.kind == "sink" then
            shakerPanel(
                model,
                "Porta sob a pia esquerda",
                module.x - module.width * 0.25,
                1.33,
                module.width * 0.46,
                1.62,
                CABINET_FRONT,
                Palette.Cabinet,
                "knob"
            )
            shakerPanel(
                model,
                "Porta sob a pia direita",
                module.x + module.width * 0.25,
                1.33,
                module.width * 0.46,
                1.62,
                CABINET_FRONT,
                Palette.Cabinet,
                "knob"
            )
        else
            shakerPanel(
                model,
                "Porta do armário",
                module.x,
                1.3,
                module.width - 0.18,
                1.58,
                CABINET_FRONT,
                Palette.Cabinet,
                "knob"
            )
        end

        if module.kind ~= "oven" then
            shakerPanel(
                model,
                "Gaveta",
                module.x,
                2.49,
                module.width - 0.18,
                0.48,
                CABINET_FRONT,
                Palette.Cabinet,
                "cup"
            )
        end
    end

    -- Bancada contínua com saia de pedra.
    Kit.box(
        model,
        "Bancada de pedra",
        CFrame.new(-2.65, 2.92, COUNTER_Z),
        Vector3.new(7.95, 0.2, 2.28),
        Palette.Marble,
        Palette.Materials.marble,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Saia da bancada",
        CFrame.new(-2.65, 2.83, -7.83),
        Vector3.new(7.95, 0.16, 0.14),
        Palette.Marble,
        Palette.Materials.marble,
        { collide = false, query = false, shadow = false }
    )

    -- Azulejos artesanais do espelho da bancada.
    for column = 1, 12 do
        for row = 1, 2 do
            local tileColor = if (column + row) % 4 == 0
                then Palette.TileSage
                else if (column + row) % 3 == 0 then Palette.TileCream else Palette.CabinetHighlight
            local tone = 1 + (column % 3) * 0.02
            Kit.box(
                model,
                "Azulejo",
                CFrame.new(-6.22 + (column - 1) * 0.635, 3.18 + (row - 1) * 0.48, WALL_Z + 0.02),
                Vector3.new(0.585, 0.44, 0.06),
                Kit.tint(tileColor, (tone - 1) * 2 - 0.02),
                Palette.Materials.tile,
                { collide = false, query = false, shadow = false, reflectance = 0.03 }
            )
        end
    end

    -- Prateleiras abertas à esquerda da janela.
    for shelf = 1, 2 do
        local shelfY = 4.55 + shelf * 0.72
        Kit.box(
            model,
            "Prateleira aberta",
            CFrame.new(-5.72, shelfY, -9.52),
            Vector3.new(1.7, 0.11, 0.95),
            Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false }
        )
        for side = -1, 1 do
            Kit.box(
                model,
                "Mão-francesa",
                CFrame.new(-5.72 + side * 0.62, shelfY - 0.28, -9.68),
                Vector3.new(0.12, 0.46, 0.1),
                Palette.BrassDark,
                Palette.Materials.metal,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Pratos encostados na parede da prateleira de cima.
    for plate = 1, 4 do
        Kit.cylinder(
            model,
            "Prato decorativo",
            CFrame.new(-6.18 + plate * 0.27, 6.42, -9.72),
            0.055,
            0.58,
            if plate % 2 == 0 then Palette.CeramicWhite else Palette.CeramicSpeckle,
            Palette.Materials.ceramic,
            "z",
            { collide = false, query = false, shadow = false }
        )
    end
    for jar = 1, 3 do
        local jarX = -6.2 + (jar - 1) * 0.5
        Kit.cylinder(
            model,
            "Pote de mantimentos",
            CFrame.new(jarX, 5.58, -9.36),
            0.44,
            0.4,
            Palette.GlassClear,
            Palette.Materials.glass,
            "y",
            { collide = false, query = false, shadow = false, transparency = 0.45 }
        )
        Kit.cylinder(
            model,
            "Tampa do pote",
            CFrame.new(jarX, 5.84, -9.36),
            0.1,
            0.43,
            Palette.OakPale,
            Palette.Materials.wood,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Faixa de LED sob a prateleira.
    Kit.box(
        model,
        "Fita de LED",
        CFrame.new(-5.72, 4.47, -9.8),
        Vector3.new(1.55, 0.035, 0.08),
        Color3.fromRGB(255, 218, 157),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    local ledGlow = Kit.box(
        model,
        "Luz da fita de LED",
        CFrame.new(-5.72, 4.4, -9.58),
        Vector3.new(1.5, 0.04, 0.2),
        Color3.fromRGB(255, 218, 157),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false, transparency = 0.8 }
    )
    Kit.pointLight(ledGlow, Color3.fromRGB(255, 204, 138), {
        name = "Luz de bancada",
        brightness = 0.35,
        range = 5,
        shadows = false,
    })

    return model
end

local function buildFaucetAndSink(parent: Instance)
    local model = Kit.model(parent, "Pia e torneira")
    local x = -3.35
    local topZ = -8.95

    Kit.box(
        model,
        "Aro da pia",
        CFrame.new(x, COUNTER_TOP + 0.015, topZ),
        Vector3.new(2.0, 0.04, 1.42),
        Palette.Steel,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.2 }
    )
    Kit.box(
        model,
        "Cuba",
        CFrame.new(x, COUNTER_TOP - 0.11, topZ),
        Vector3.new(1.76, 0.24, 1.18),
        Palette.SteelDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Fundo da cuba",
        CFrame.new(x, COUNTER_TOP - 0.21, topZ),
        Vector3.new(1.56, 0.03, 0.98),
        Palette.Steel,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.15 }
    )
    Kit.cylinder(
        model,
        "Ralo",
        CFrame.new(x, COUNTER_TOP - 0.19, topZ),
        0.025,
        0.24,
        Palette.SteelDark,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for _, side in { -1, 1 } do
        Kit.cylinder(
            model,
            "Torneira - base",
            CFrame.new(x + side * 0.7, COUNTER_TOP + 0.03, -9.54),
            0.08,
            0.28,
            Palette.Chrome,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false, reflectance = 0.35 }
        )
    end
    Kit.cylinder(
        model,
        "Torneira - coluna",
        CFrame.new(x, COUNTER_TOP + 0.55, -9.54),
        1.1,
        0.16,
        Palette.Chrome,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false, reflectance = 0.45 }
    )
    local curve = {
        Vector3.new(x, COUNTER_TOP + 1.08, -9.54),
        Vector3.new(x, COUNTER_TOP + 1.48, -9.45),
        Vector3.new(x, COUNTER_TOP + 1.52, -9.15),
        Vector3.new(x, COUNTER_TOP + 1.3, -8.95),
        Vector3.new(x, COUNTER_TOP + 0.98, -8.98),
    }
    for i = 1, #curve - 1 do
        Kit.rodBetween(
            model,
            "Torneira - curva",
            curve[i],
            curve[i + 1],
            0.14,
            Palette.Chrome,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false, reflectance = 0.45 }
        )
        Kit.sphere(
            model,
            "Junta da torneira",
            CFrame.new(curve[i + 1]),
            Vector3.new(0.15, 0.15, 0.15),
            Palette.Chrome,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false, reflectance = 0.4 }
        )
    end
    Kit.cylinder(
        model,
        "Bica",
        CFrame.new(x, COUNTER_TOP + 0.9, -8.98),
        0.2,
        0.12,
        Palette.Chrome,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false, reflectance = 0.45 }
    )
    Kit.box(
        model,
        "Alavanca da torneira",
        CFrame.new(x + 0.24, COUNTER_TOP + 0.65, -9.42),
        Vector3.new(0.45, 0.06, 0.06),
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    Kit.box(
        model,
        "Saboneteira",
        CFrame.new(x - 1.15, COUNTER_TOP + 0.18, -9.45),
        Vector3.new(0.22, 0.28, 0.18),
        Color3.fromRGB(172, 128, 74),
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, transparency = 0.25 }
    )
    Kit.cylinder(
        model,
        "Bomba de sabão",
        CFrame.new(x - 1.15, COUNTER_TOP + 0.43, -9.45),
        0.16,
        0.08,
        Palette.Chrome,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Esponja",
        Kit.rotated(x + 1.1, COUNTER_TOP + 0.07, -9.38, 0, 22, 0),
        Vector3.new(0.42, 0.12, 0.28),
        Palette.Mustard,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Sabão em barra",
        CFrame.new(x + 1.25, COUNTER_TOP + 0.07, -9.58),
        Vector3.new(0.32, 0.1, 0.22),
        Palette.CeramicBlue,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildCooktop(parent: Instance)
    local model = Kit.model(parent, "Cooktop e coifa")
    local x = -0.2

    Kit.box(
        model,
        "Placa de indução",
        CFrame.new(x, COUNTER_TOP + 0.015, -8.92),
        Vector3.new(2.12, 0.035, 1.28),
        Palette.BlackGlass,
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, reflectance = 0.18 }
    )
    local burners = {
        { x = x - 0.52, z = -9.18, size = 0.5 },
        { x = x + 0.52, z = -9.18, size = 0.38 },
        { x = x - 0.5, z = -8.65, size = 0.38 },
        { x = x + 0.54, z = -8.65, size = 0.5 },
    }
    for index, burner in burners do
        Kit.cylinder(
            model,
            "Boca do fogão",
            CFrame.new(burner.x, COUNTER_TOP + 0.055, burner.z),
            0.015,
            burner.size,
            Palette.SteelDark,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Anel da boca",
            CFrame.new(burner.x, COUNTER_TOP + 0.062, burner.z),
            0.008,
            burner.size + 0.13,
            Palette.Steel,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false }
        )
        if index == 1 then
            -- Uma frigideira esquecida no fogo, mas apagada.
            Kit.cylinder(
                model,
                "Frigideira",
                CFrame.new(burner.x, COUNTER_TOP + 0.2, burner.z),
                0.28,
                0.78,
                Palette.Charcoal,
                Palette.Materials.metal,
                "y",
                { collide = false, query = false, shadow = false }
            )
            Kit.rodBetween(
                model,
                "Cabo da frigideira",
                Vector3.new(burner.x + 0.35, COUNTER_TOP + 0.2, burner.z),
                Vector3.new(burner.x + 1.02, COUNTER_TOP + 0.22, burner.z + 0.1),
                0.11,
                Palette.WalnutDeep,
                Palette.Materials.wood,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Coifa e chaminé.
    Kit.box(
        model,
        "Coifa",
        CFrame.new(x, 6.42, -8.92),
        Vector3.new(2.5, 0.34, 1.72),
        Palette.Steel,
        Palette.Materials.metal,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Coifa - filtro",
        CFrame.new(x, 6.22, -8.92),
        Vector3.new(2.1, 0.06, 1.3),
        Palette.SteelDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Coifa - chaminé",
        CFrame.new(x, 7.8, -9.35),
        Vector3.new(1.12, 2.75, 0.78),
        Palette.Steel,
        Palette.Materials.metal,
        { collide = false, query = false }
    )
    for _, side in { -1, 1 } do
        Kit.box(
            model,
            "Fita de proteção da coifa",
            CFrame.new(x + side * 0.58, 6.47, -8.04),
            Vector3.new(0.055, 0.24, 0.06),
            Palette.Chrome,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false, reflectance = 0.35 }
        )
    end
    local hoodLight = Kit.box(
        model,
        "Luz da coifa",
        CFrame.new(x, 6.17, -8.62),
        Vector3.new(1.2, 0.02, 0.3),
        Color3.fromRGB(255, 224, 172),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false, transparency = 0.2 }
    )
    Kit.surfaceLight(hoodLight, Color3.fromRGB(255, 212, 155), {
        name = "Luz da coifa",
        face = Enum.NormalId.Bottom,
        brightness = 0.45,
        range = 5,
        angle = 110,
    })

    return model
end

local function buildFridge(parent: Instance)
    local model = Kit.model(parent, "Geladeira")
    local x = 2.9
    local z = -8.95

    Kit.box(
        model,
        "Corpo da geladeira",
        CFrame.new(x, 3.42, z),
        Vector3.new(2.45, 6.5, 2.08),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Porta do refrigerador",
        CFrame.new(x, 2.55, -7.86),
        Vector3.new(2.3, 3.75, 0.12),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Porta do freezer",
        CFrame.new(x, 5.15, -7.86),
        Vector3.new(2.3, 1.55, 0.12),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Junta entre portas",
        CFrame.new(x, 4.29, -7.8),
        Vector3.new(2.32, 0.07, 0.16),
        Palette.TrimShadow,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    Kit.box(
        model,
        "Puxador do refrigerador",
        CFrame.new(x + 0.9, 2.7, -7.72),
        Vector3.new(0.12, 2.15, 0.16),
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.45 }
    )
    Kit.box(
        model,
        "Puxador do freezer",
        CFrame.new(x + 0.9, 5.2, -7.72),
        Vector3.new(0.12, 1.18, 0.16),
        Palette.Chrome,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.45 }
    )

    -- Recortes e base.
    Kit.box(
        model,
        "Rodapé da geladeira",
        CFrame.new(x, 0.2, -8.9),
        Vector3.new(2.08, 0.4, 1.7),
        Palette.SteelDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for _, side in { -1, 1 } do
        Kit.sphere(
            model,
            "Pé da geladeira",
            CFrame.new(x + side * 0.92, 0.13, -7.9),
            Vector3.new(0.24, 0.24, 0.24),
            Palette.SteelDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Ímãs, fotos e listas.
    local magnetColors = { Palette.Clay, Palette.Mustard, Palette.Olive, Palette.CeramicBlue }
    for index = 1, 6 do
        Kit.cylinder(
            model,
            "Ímã",
            Kit.rotated(x - 0.9 + (index - 1) * 0.38, 2.4 + (index % 3) * 0.42, -7.72, 0, 12, 0),
            0.05,
            0.16,
            magnetColors[(index - 1) % #magnetColors + 1],
            Palette.Materials.ceramic,
            "z",
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Foto na geladeira",
        Kit.rotated(x + 0.35, 3.35, -7.7, 0, -4, 2),
        Vector3.new(0.62, 0.78, 0.02),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Foto - imagem",
        Kit.rotated(x + 0.35, 3.4, -7.715, 0, -4, 2),
        Vector3.new(0.47, 0.5, 0.012),
        Palette.SagePale,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Lista de compras",
        Kit.rotated(x - 0.45, 3.0, -7.71, 0, 5, -1),
        Vector3.new(0.5, 0.65, 0.015),
        Palette.LinenLight,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    for line = 1, 5 do
        Kit.box(
            model,
            "Linha da lista",
            Kit.rotated(x - 0.45, 3.22 - line * 0.09, -7.72, 0, 5, -1),
            Vector3.new(0.3 + (line % 2) * 0.1, 0.012, 0.008),
            Palette.SteelDark,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cesto e planta em cima da geladeira.
    Kit.box(
        model,
        "Cesto de vime",
        CFrame.new(x - 0.45, 6.95, z),
        Vector3.new(1.0, 0.55, 0.8),
        Palette.OakPale,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    local pot = Kit.cylinder(
        model,
        "Vaso da geladeira",
        CFrame.new(x + 0.55, 6.92, z + 0.05),
        0.55,
        0.68,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for leaf = 1, 7 do
        local angle = leaf * 2.4
        Kit.sphere(
            model,
            "Folha da planta",
            CFrame.new(
                x + 0.55 + math.cos(angle) * 0.38,
                7.55 + (leaf % 3) * 0.22,
                z + 0.05 + math.sin(angle) * 0.38
            ) * CFrame.Angles(math.rad(25), angle, math.rad(20)),
            Vector3.new(0.2, 0.85, 0.4),
            if leaf % 2 == 0 then Palette.LeafLight else Palette.Leaf,
            Palette.Materials.leaf,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Vaso - terra",
        CFrame.new(x + 0.55, 7.2, z + 0.05),
        0.05,
        0.52,
        Palette.Soil,
        Palette.Materials.leaf,
        "y",
        { collide = false, query = false, shadow = false }
    )
    pot.Name = "Vaso de cerâmica"

    return model
end

local function buildCounterProps(parent: Instance)
    local model = Kit.model(parent, "Objetos da cozinha")

    -- Torradeira.
    Kit.box(
        model,
        "Torradeira",
        CFrame.new(-5.75, 3.31, -8.72),
        Vector3.new(0.8, 0.58, 0.58),
        Palette.Cream,
        Palette.Materials.metal,
        { collide = false, query = false }
    )
    for side = -1, 1 do
        Kit.box(
            model,
            "Fenda da torradeira",
            CFrame.new(-5.75 + side * 0.2, 3.61, -8.72),
            Vector3.new(0.16, 0.025, 0.36),
            Palette.SteelDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Alavanca da torradeira",
        CFrame.new(-5.3, 3.22, -8.72),
        Vector3.new(0.05, 0.26, 0.09),
        Palette.SteelDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Tábua de corte apoiada.
    Kit.box(
        model,
        "Tábua de corte",
        Kit.rotated(-5.65, 3.65, -9.72, -76, 0, 0),
        Vector3.new(0.9, 1.15, 0.075),
        Palette.OakPale,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Alça da tábua",
        CFrame.new(-5.65, 4.18, -9.5),
        0.08,
        0.14,
        Palette.Walnut,
        Palette.Materials.wood,
        "z",
        { collide = false, query = false, shadow = false }
    )

    -- Potes de cerâmica.
    for index = 1, 3 do
        local jarX = -4.95 + (index - 1) * 0.34
        local jarHeight = 0.48 + (index % 2) * 0.12
        Kit.cylinder(
            model,
            "Pote de cerâmica",
            CFrame.new(jarX, 3.0 + jarHeight * 0.5, -9.55),
            jarHeight,
            0.33,
            if index == 2 then Palette.CeramicClay else Palette.CeramicSpeckle,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Tampa do pote",
            CFrame.new(jarX, 3.0 + jarHeight + 0.05, -9.55),
            0.08,
            0.36,
            Palette.Oak,
            Palette.Materials.wood,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Utensílios no pote.
    Kit.cylinder(
        model,
        "Porta-utensílios",
        CFrame.new(-4.35, 3.34, -8.45),
        0.65,
        0.42,
        Palette.CeramicWhite,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local utensilTops = {
        { x = -4.5, y = 4.28, z = -8.45, lean = -8 },
        { x = -4.35, y = 4.35, z = -8.5, lean = 3 },
        { x = -4.18, y = 4.23, z = -8.42, lean = 10 },
    }
    for index, tip in utensilTops do
        Kit.rodBetween(
            model,
            "Utensílio",
            Vector3.new(-4.35, 3.22, -8.45),
            Vector3.new(tip.x, tip.y, tip.z),
            0.055,
            if index == 2 then Palette.OakPale else Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Cabeça do utensílio",
            CFrame.new(tip.x + index * 0.02, tip.y + 0.06, tip.z),
            Vector3.new(0.09, 0.22, 0.16),
            if index == 2 then Palette.OakPale else Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Fruteira.
    Kit.cylinder(
        model,
        "Fruteira",
        CFrame.new(-5.1, 3.05, -8.28),
        0.1,
        1.05,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        Kit.sphere(
            model,
            "Limão",
            CFrame.new(-5.35 + (index - 1) * 0.26, 3.22 + (index % 2) * 0.12, -8.28),
            Vector3.new(0.27, 0.25, 0.27),
            Color3.fromRGB(190, 177, 80),
            Palette.Materials.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Chaleira esmaltada.
    Kit.sphere(
        model,
        "Chaleira",
        CFrame.new(-1.15, 3.28, -8.75),
        Vector3.new(0.52, 0.52, 0.52),
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Base da chaleira",
        CFrame.new(-1.15, 3.05, -8.75),
        0.12,
        0.46,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Bico da chaleira",
        Vector3.new(-1.43, 3.3, -8.75),
        Vector3.new(-1.75, 3.6, -8.78),
        0.09,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Alça da chaleira",
        Vector3.new(-1.15, 3.58, -8.75),
        Vector3.new(-1.15, 4.12, -8.75),
        0.075,
        Palette.Ink,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Alça da chaleira",
        Vector3.new(-1.15, 4.12, -8.75),
        Vector3.new(-0.87, 3.55, -8.75),
        0.075,
        Palette.Ink,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    -- Escorredor de louças e pratos.
    Kit.box(
        model,
        "Escorredor",
        CFrame.new(-2.0, 3.04, -9.35),
        Vector3.new(0.82, 0.08, 0.82),
        Palette.Steel,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for plate = 1, 4 do
        Kit.cylinder(
            model,
            "Prato no escorredor",
            CFrame.new(-2.25 + plate * 0.16, 3.33, -9.35) * CFrame.Angles(math.rad(-12), 0, 0),
            0.045,
            0.58,
            Palette.CeramicWhite,
            Palette.Materials.ceramic,
            "z",
            { collide = false, query = false, shadow = false }
        )
    end
    for i = 1, 4 do
        Kit.box(
            model,
            "Haste do escorredor",
            CFrame.new(-2.35 + (i - 1) * 0.23, 3.23, -9.2),
            Vector3.new(0.03, 0.38, 0.03),
            Palette.Steel,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Xícaras penduradas.
    for cup = 1, 4 do
        local cupX = -6.15 + (cup - 1) * 0.36
        Kit.cylinder(
            model,
            "Xícara pendurada",
            CFrame.new(cupX, 4.36, -9.74),
            0.26,
            0.25,
            if cup % 2 == 0 then Palette.CeramicBlue else Palette.CeramicWhite,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.rodBetween(
            model,
            "Alça da xícara",
            Vector3.new(cupX + 0.12, 4.42, -9.74),
            Vector3.new(cupX + 0.24, 4.3, -9.74),
            0.035,
            Palette.CeramicWhite,
            Palette.Materials.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Ervas na janela.
    local herbs = {
        { x = -4.45, pot = Palette.CeramicClay },
        { x = -3.85, pot = Palette.CeramicSpeckle },
        { x = -1.65, pot = Palette.CeramicBlue },
    }
    for index, herb in herbs do
        Kit.cylinder(
            model,
            "Vaso de ervas",
            CFrame.new(herb.x, 4.32, -9.62),
            0.35,
            0.42,
            herb.pot,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false, shadow = false }
        )
        for leaf = 1, 4 do
            Kit.sphere(
                model,
                "Folha de erva",
                CFrame.new(
                    herb.x + math.cos(leaf * 1.8) * 0.16,
                    4.6 + (leaf % 2) * 0.12,
                    -9.62 + math.sin(leaf * 1.8) * 0.14
                ) * CFrame.Angles(math.rad(26), leaf * 1.2, 0),
                Vector3.new(0.16, 0.38, 0.11),
                if index % 2 == 0 then Palette.LeafLight else Palette.Leaf,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Pano de prato no forno.
    Kit.box(
        model,
        "Pano de prato",
        Kit.rotated(0.05, 1.9, -7.68, 8, 0, 0),
        Vector3.new(0.72, 1.1, 0.055),
        Palette.Cream,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Listra do pano",
        Kit.rotated(0.05, 1.84, -7.65, 8, 0, 0),
        Vector3.new(0.72, 0.17, 0.012),
        Palette.Terracotta,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildRunner(parent: Instance)
    local model = Kit.model(parent, "Passadeira da cozinha")
    Kit.box(
        model,
        "Passadeira",
        CFrame.new(-2.7, 0.035, -6.75),
        Vector3.new(6.5, 0.055, 1.9),
        Palette.Olive,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    for stripe = -1, 1 do
        Kit.box(
            model,
            "Listra da passadeira",
            CFrame.new(-2.7, 0.068, -6.75 + stripe * 0.63),
            Vector3.new(6.2, 0.015, 0.12),
            Palette.Linen,
            Palette.Materials.carpet,
            { collide = false, query = false, shadow = false }
        )
    end
    for side = -1, 1 do
        for index = 1, 14 do
            Kit.box(
                model,
                "Franja",
                CFrame.new(-2.7 + (index - 7.5) * 0.43, 0.03, -6.75 + side * 0.99),
                Vector3.new(0.05, 0.02, 0.17),
                Palette.Linen,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

local function buildCeilingLights(parent: Instance)
    local model = Kit.model(parent, "Luzes da cozinha")
    for index, x in { -5.4, -2.7, 0.2 } do
        Kit.cylinder(
            model,
            "Spot embutido",
            CFrame.new(x, 9.14, -8.35),
            0.08,
            0.48,
            Palette.Trim,
            Palette.Materials.paint,
            "y",
            { collide = false, query = false, shadow = false }
        )
        local bulb = Kit.cylinder(
            model,
            "Lâmpada embutida",
            CFrame.new(x, 9.09, -8.35),
            0.03,
            0.34,
            Color3.fromRGB(255, 225, 178),
            Palette.Materials.neon,
            "y",
            { collide = false, query = false, shadow = false }
        )
        Kit.pointLight(bulb, Color3.fromRGB(255, 215, 157), {
            name = "Luz da cozinha " .. index,
            brightness = 0.85,
            range = 9,
            shadows = false,
        })
    end
    return model
end

local function buildUtensilRail(parent: Instance)
    local model = Kit.model(parent, "Trilho de utensílios")
    Kit.rodBetween(
        model,
        "Trilho",
        Vector3.new(-6.35, 3.8, -9.82),
        Vector3.new(-4.65, 3.8, -9.82),
        0.06,
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 4 do
        local x = -6.2 + (index - 1) * 0.42
        Kit.rodBetween(
            model,
            "Gancho",
            Vector3.new(x, 3.8, -9.82),
            Vector3.new(x, 3.55, -9.7),
            0.035,
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
        if index < 4 then
            Kit.cylinder(
                model,
                "Concha",
                CFrame.new(x + 0.17, 3.35, -9.67),
                0.08,
                0.34,
                if index % 2 == 0 then Palette.CeramicBlue else Palette.Steel,
                if index % 2 == 0 then Palette.Materials.ceramic else Palette.Materials.metal,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

function Kitchen.build(parent: Instance)
    local model = Kit.model(parent, "Cozinha")
    buildCabinets(model)
    buildFaucetAndSink(model)
    buildCooktop(model)
    buildFridge(model)
    buildCounterProps(model)
    buildRunner(model)
    buildCeilingLights(model)
    buildUtensilRail(model)
    return model
end

return Kitchen

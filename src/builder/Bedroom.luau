local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Canto de dormir: cama de casal, cabeceira estofada, parede ripada,
    guarda-roupa, mesa de cabeceira, luminária pendente de palha e janelas
    com cortinas de linho. O quarto é aberto para a sala, como num micro-loft.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")

local Bedroom = {}

local BED_X = 10.9
local BED_Z = -6.45
local BED_W = 5.4
local BED_D = 6.3

local function buildRug(parent: Instance)
    local model = Kit.model(parent, "Passadeira do quarto")
    Kit.box(
        model,
        "Passadeira",
        CFrame.new(7.25, 0.035, -5.55),
        Vector3.new(1.75, 0.055, 5.35),
        Palette.Cream,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Borda da passadeira",
        CFrame.new(7.25, 0.068, -5.55),
        Vector3.new(1.48, 0.01, 5.08),
        Palette.Clay,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Centro da passadeira",
        CFrame.new(7.25, 0.075, -5.55),
        Vector3.new(1.32, 0.01, 4.92),
        Palette.Linen,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 5 do
        Kit.box(
            model,
            "Listra da passadeira",
            CFrame.new(7.25, 0.083, -7.65 + index * 0.72),
            Vector3.new(1.2, 0.008, 0.09),
            Palette.Sage,
            Palette.Materials.carpet,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildAccentWall(parent: Instance)
    local model = Kit.model(parent, "Parede ripada do quarto")

    Kit.box(
        model,
        "Fundo da parede ripada",
        CFrame.new(11.0, 2.7, -9.965),
        Vector3.new(6.0, 4.8, 0.07),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    for slat = 1, 21 do
        local x = 8.1 + (slat - 1) * 0.276
        Kit.box(
            model,
            "Ripa",
            CFrame.new(x, 2.7, -9.9),
            Vector3.new(0.18, 4.75, 0.1),
            if slat % 4 == 0 then Palette.OakDark else Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Remate da parede ripada",
        CFrame.new(11.0, 5.1, -9.86),
        Vector3.new(6.1, 0.16, 0.18),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    return model
end

local function buildBed(parent: Instance)
    local model = Kit.model(parent, "Cama")

    -- Estrutura, pés e gavetas.
    Kit.box(
        model,
        "Estrutura da cama",
        CFrame.new(BED_X, 0.78, BED_Z),
        Vector3.new(BED_W, 0.82, BED_D),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    for _, sideX in { -1, 1 } do
        for _, sideZ in { -1, 1 } do
            Kit.cylinder(
                model,
                "Pé da cama",
                CFrame.new(
                    BED_X + sideX * (BED_W * 0.5 - 0.3),
                    0.2,
                    BED_Z + sideZ * (BED_D * 0.5 - 0.3)
                ),
                0.4,
                0.22,
                Palette.WalnutDeep,
                Palette.Materials.wood,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end
    for drawer = -1, 1 do
        Kit.box(
            model,
            "Gaveta da cama",
            CFrame.new(BED_X + drawer * 1.5, 0.72, BED_Z + BED_D * 0.5 + 0.015),
            Vector3.new(1.35, 0.46, 0.06),
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Puxador da gaveta",
            CFrame.new(BED_X + drawer * 1.5, 0.72, BED_Z + BED_D * 0.5 + 0.06),
            0.05,
            0.16,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Colchão e roupa de cama.
    Kit.box(
        model,
        "Colchão",
        CFrame.new(BED_X, 1.6, BED_Z),
        Vector3.new(BED_W - 0.22, 0.8, BED_D - 0.18),
        Palette.Cream,
        Palette.Materials.fabric,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Lençol de baixo",
        CFrame.new(BED_X, 2.025, BED_Z),
        Vector3.new(BED_W - 0.16, 0.06, BED_D - 0.12),
        Palette.CeramicWhite,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Edredom",
        CFrame.new(BED_X, 2.15, -5.82),
        Vector3.new(BED_W - 0.08, 0.24, 4.5),
        Palette.Linen,
        Palette.Materials.fabric,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Dobra do edredom",
        CFrame.new(BED_X, 2.29, -7.62),
        Vector3.new(BED_W - 0.12, 0.1, 0.75),
        Palette.Cream,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    for seam = 1, 3 do
        Kit.box(
            model,
            "Costura do edredom",
            CFrame.new(BED_X, 2.275, -6.95 + seam * 0.96),
            Vector3.new(BED_W - 0.24, 0.012, 0.05),
            Palette.LinenLight,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Puxa de cama no pé.
    Kit.box(
        model,
        "Manta do pé da cama",
        CFrame.new(BED_X, 2.31, -4.35),
        Vector3.new(BED_W + 0.08, 0.12, 1.55),
        Palette.Clay,
        Palette.Materials.fabric,
        { collide = false, query = false }
    )
    for fringe = 1, 10 do
        Kit.box(
            model,
            "Franja da manta",
            CFrame.new(BED_X - 2.4 + fringe * 0.48, 2.22, -3.55),
            Vector3.new(0.06, 0.26, 0.03),
            Palette.Terracotta,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Manta caída",
        CFrame.new(BED_X + BED_W * 0.5 + 0.12, 1.78, -4.35),
        Vector3.new(0.16, 1.24, 1.52),
        Palette.Clay,
        Palette.Materials.fabric,
        { collide = false, query = false }
    )

    -- Travesseiros.
    local pillows = {
        { x = BED_X - 1.35, y = 2.47, z = -8.78, color = Palette.Cream, w = 2.25, h = 0.52, d = 1.35, rot = -16 },
        { x = BED_X + 1.35, y = 2.47, z = -8.78, color = Palette.Cream, w = 2.25, h = 0.52, d = 1.35, rot = -16 },
        { x = BED_X - 0.9, y = 2.37, z = -8.2, color = Palette.SagePale, w = 1.55, h = 0.4, d = 0.95, rot = -10 },
        { x = BED_X + 1.0, y = 2.37, z = -8.16, color = Palette.Blush, w = 1.4, h = 0.4, d = 0.9, rot = -8 },
    }
    for index, pillow in pillows do
        Kit.sphere(
            model,
            "Travesseiro " .. index,
            Kit.rotated(pillow.x, pillow.y, pillow.z, pillow.rot, 0, 0),
            Vector3.new(pillow.w, pillow.h, pillow.d),
            pillow.color,
            Palette.Materials.fabric,
            { collide = false, query = false }
        )
    end

    -- Cabeceira estofada com canais e botões.
    Kit.box(
        model,
        "Cabeceira",
        CFrame.new(BED_X, 2.7, -9.53),
        Vector3.new(5.25, 4.2, 0.3),
        Palette.OliveDeep,
        Palette.Materials.fabric,
        { collide = true, query = true }
    )
    for channel = 1, 9 do
        local channelX = BED_X - 2.2 + (channel - 1) * 0.55
        Kit.sphere(
            model,
            "Canal da cabeceira",
            CFrame.new(channelX, 2.75, -9.37),
            Vector3.new(0.48, 3.75, 0.22),
            Palette.Olive,
            Palette.Materials.fabric,
            { collide = false, query = false }
        )
        Kit.sphere(
            model,
            "Capitonê",
            CFrame.new(channelX, 3.85, -9.23),
            Vector3.new(0.09, 0.09, 0.06),
            Palette.BrassDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Sapatos ao lado da cama.
    for slipper = -1, 1 do
        Kit.sphere(
            model,
            "Pantufa",
            CFrame.new(BED_X - BED_W * 0.5 - 0.28, 0.17, -7.05 + slipper * 0.36),
            Vector3.new(0.55, 0.24, 0.33),
            Palette.Blush,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    return model
end

local function buildNightstand(parent: Instance)
    local model = Kit.model(parent, "Mesa de cabeceira")
    local x = 7.16
    local z = -9.25

    Kit.box(
        model,
        "Tampo da mesa de cabeceira",
        CFrame.new(x, 2.1, z),
        Vector3.new(1.5, 0.16, 1.35),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Corpo da mesa",
        CFrame.new(x, 1.55, z),
        Vector3.new(1.34, 0.92, 1.2),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Frente da gaveta",
        CFrame.new(x, 1.64, z + 0.62),
        Vector3.new(1.18, 0.46, 0.06),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Puxador da gaveta",
        CFrame.new(x, 1.64, z + 0.67),
        0.05,
        0.14,
        Palette.Brass,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )
    for _, sx in { -1, 1 } do
        for _, sz in { -1, 1 } do
            Kit.cylinder(
                model,
                "Pé da mesa de cabeceira",
                CFrame.new(x + sx * 0.55, 0.6, z + sz * 0.46),
                1.2,
                0.1,
                Palette.WalnutDeep,
                Palette.Materials.wood,
                "y",
                { collide = false, query = false, shadow = false }
            )
        end
    end
    Kit.box(
        model,
        "Prateleira da mesa",
        CFrame.new(x, 0.72, z),
        Vector3.new(1.2, 0.08, 1.05),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )

    -- Luminária de mesa.
    Kit.cylinder(
        model,
        "Base da luminária",
        CFrame.new(x - 0.25, 2.35, z - 0.2),
        0.34,
        0.54,
        Palette.CeramicSpeckle,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Haste da luminária",
        CFrame.new(x - 0.25, 2.7, z - 0.2),
        0.5,
        0.08,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cúpula da luminária",
        CFrame.new(x - 0.25, 3.15, z - 0.2),
        0.72,
        1.05,
        Palette.LinenLight,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local lampBulb = Kit.sphere(
        model,
        "Lâmpada da cabeceira",
        CFrame.new(x - 0.25, 3.05, z - 0.2),
        Vector3.new(0.22, 0.26, 0.22),
        Color3.fromRGB(255, 227, 181),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(lampBulb, Color3.fromRGB(255, 204, 145), {
        name = "Luz da cabeceira",
        brightness = 0.8,
        range = 8,
        shadows = false,
    })

    -- Livros, óculos, água e celular.
    Kit.box(
        model,
        "Livro da cabeceira",
        Kit.rotated(x + 0.28, 2.24, z + 0.14, 0, 12, 0),
        Vector3.new(0.76, 0.11, 0.55),
        Palette.Clay,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Páginas do livro",
        Kit.rotated(x + 0.28, 2.305, z + 0.13, 0, 12, 0),
        Vector3.new(0.7, 0.035, 0.49),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Óculos",
        CFrame.new(x + 0.38, 2.23, z - 0.34),
        Vector3.new(0.5, 0.035, 0.06),
        Palette.Charcoal,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Copo de água",
        CFrame.new(x + 0.43, 2.38, z - 0.47),
        0.3,
        0.22,
        Palette.GlassClear,
        Palette.Materials.glass,
        "y",
        { collide = false, query = false, shadow = false, transparency = 0.55 }
    )
    Kit.box(
        model,
        "Celular",
        Kit.rotated(x - 0.38, 2.21, z + 0.38, 0, -22, 0),
        Vector3.new(0.34, 0.04, 0.62),
        Palette.Ink,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cesto na prateleira",
        CFrame.new(x + 0.15, 1.05, z + 0.05),
        0.55,
        0.7,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildWardrobe(parent: Instance)
    local model = Kit.model(parent, "Guarda-roupa")
    local x = 5.32
    local z = -8.04
    local width = 1.9
    local depth = 3.45
    local height = 7.1

    Kit.box(
        model,
        "Carcaça do guarda-roupa",
        CFrame.new(x, height * 0.5 + 0.12, z),
        Vector3.new(width, height, depth),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Rodapé do guarda-roupa",
        CFrame.new(x, 0.16, z),
        Vector3.new(width - 0.16, 0.3, depth - 0.2),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )

    for door = -1, 1 do
        local doorZ = z + door * depth * 0.25
        Kit.box(
            model,
            "Porta do guarda-roupa",
            CFrame.new(x + width * 0.5 + 0.04, height * 0.5 + 0.1, doorZ),
            Vector3.new(0.08, height - 0.35, depth * 0.47),
            Palette.Cabinet,
            Palette.Materials.paint,
            { collide = false, query = false }
        )
        Kit.box(
            model,
            "Moldura da porta",
            CFrame.new(x + width * 0.5 + 0.09, height * 0.5 + 0.1, doorZ),
            Vector3.new(0.04, height - 0.75, depth * 0.4),
            Palette.CabinetHighlight,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Relevo da porta",
            CFrame.new(x + width * 0.5 + 0.115, height * 0.5 + 0.1, doorZ),
            Vector3.new(0.025, height - 1.1, depth * 0.33),
            Palette.CabinetShade,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.cylinder(
            model,
            "Puxador do guarda-roupa",
            CFrame.new(x + width * 0.5 + 0.16, height * 0.5 + 0.1, z - door * 0.15),
            1.05,
            0.08,
            Palette.Brass,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false, reflectance = 0.25 }
        )
    end

    -- Cesta e caixa sobre o guarda-roupa.
    Kit.cylinder(
        model,
        "Cesto de roupa de cama",
        CFrame.new(x, height + 0.39, z - 1.05),
        0.58,
        1.0,
        Palette.OakPale,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Caixa de guardados",
        CFrame.new(x, height + 0.36, z + 0.75),
        Vector3.new(1.25, 0.46, 0.9),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Fita da caixa",
        CFrame.new(x, height + 0.6, z + 0.75),
        Vector3.new(0.18, 0.02, 0.92),
        Palette.Clay,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildWindowDressing(parent: Instance)
    local model = Kit.model(parent, "Cortinas e persiana do quarto")

    -- Persiana de linho na janela alta da cabeceira.
    Kit.box(
        model,
        "Varão da persiana",
        CFrame.new(11.0, 8.26, -9.78),
        Vector3.new(3.8, 0.12, 0.14),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for fold = 1, 5 do
        Kit.box(
            model,
            "Dobra da persiana",
            CFrame.new(11.0, 8.1 - fold * 0.18, -9.7),
            Vector3.new(3.45, 0.13, 0.13),
            if fold % 2 == 0 then Palette.Linen else Palette.LinenLight,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.rodBetween(
        model,
        "Cordão da persiana",
        Vector3.new(12.63, 7.35, -9.68),
        Vector3.new(12.63, 5.7, -9.68),
        0.025,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    -- Cortinas de linho na janela lateral.
    local rodX = 13.55
    Kit.cylinder(
        model,
        "Vara da cortina",
        CFrame.new(rodX, 7.55, -5.9),
        4.8,
        0.09,
        Palette.BrassDark,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )
    for _, bracketZ in { -8.2, -3.6 } do
        Kit.rodBetween(
            model,
            "Suporte da cortina",
            Vector3.new(13.98, 7.55, bracketZ),
            Vector3.new(rodX, 7.55, bracketZ),
            0.06,
            Palette.BrassDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, panelZ in { -7.45, -4.35 } do
        for fold = 1, 5 do
            Kit.box(
                model,
                "Cortina",
                CFrame.new(rodX - 0.02 + (fold % 2) * 0.05, 3.95, panelZ + (fold - 3) * 0.2),
                Vector3.new(0.1, 6.75, 0.24),
                if fold % 2 == 0 then Palette.Linen else Palette.LinenLight,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false, transparency = 0.02 }
            )
        end
    end

    return model
end

local function buildPendant(parent: Instance)
    local model = Kit.model(parent, "Pendente do quarto")
    local x = 10.9
    local z = -4.55

    Kit.cylinder(
        model,
        "Roseta do teto",
        CFrame.new(x, 9.16, z),
        0.08,
        0.42,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cordão do pendente",
        CFrame.new(x, 8.32, z),
        1.72,
        0.045,
        Palette.Ink,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local tiers = {
        { y = 7.56, diameter = 0.7, height = 0.22 },
        { y = 7.39, diameter = 1.1, height = 0.22 },
        { y = 7.19, diameter = 1.55, height = 0.22 },
        { y = 6.96, diameter = 1.95, height = 0.24 },
    }
    for _, tier in tiers do
        Kit.cylinder(
            model,
            "Palha do pendente",
            CFrame.new(x, tier.y, z),
            tier.height,
            tier.diameter,
            Palette.OakPale,
            Palette.Materials.wood,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Borda do pendente",
        CFrame.new(x, 6.82, z),
        0.08,
        2.02,
        Palette.OakDark,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    local bulb = Kit.sphere(
        model,
        "Lâmpada do pendente",
        CFrame.new(x, 6.62, z),
        Vector3.new(0.24, 0.28, 0.24),
        Color3.fromRGB(255, 224, 176),
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(bulb, Color3.fromRGB(255, 200, 137), {
        name = "Luz do pendente",
        brightness = 0.75,
        range = 8,
        shadows = true,
    })
    return model
end

local function buildSconces(parent: Instance)
    local model = Kit.model(parent, "Arandelas de leitura")
    for index, x in { 8.55, 13.25 } do
        Kit.cylinder(
            model,
            "Arandela - base",
            CFrame.new(x, 5.7, -9.87),
            0.08,
            0.32,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
        Kit.rodBetween(
            model,
            "Arandela - braço",
            Vector3.new(x, 5.7, -9.87),
            Vector3.new(x, 5.7, -9.55),
            0.06,
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
        local shade = Kit.cylinder(
            model,
            "Arandela - cúpula",
            CFrame.new(x, 5.7, -9.44),
            0.5,
            0.34,
            Palette.LinenLight,
            Palette.Materials.fabric,
            "z",
            { collide = false, query = false, shadow = false }
        )
        Kit.pointLight(shade, Color3.fromRGB(255, 206, 146), {
            name = "Luz de leitura " .. index,
            brightness = 0.35,
            range = 5,
            shadows = false,
        })
    end
    return model
end

local function buildGallery(parent: Instance)
    local model = Kit.model(parent, "Galeria da cabeceira")
    local z = -9.92
    local frames = {
        { x = 6.85, y = 5.25, w = 1.1, h = 1.45, art = Palette.Clay },
        { x = 7.8, y = 6.05, w = 0.82, h = 1.1, art = Palette.Olive },
    }
    for index, frame in frames do
        Kit.box(
            model,
            "Moldura",
            CFrame.new(frame.x, frame.y, z),
            Vector3.new(frame.w, frame.h, 0.08),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false }
        )
        Kit.box(
            model,
            "Passe-partout",
            CFrame.new(frame.x, frame.y, z + 0.05),
            Vector3.new(frame.w - 0.2, frame.h - 0.2, 0.02),
            Palette.Cream,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Forma abstrata",
            CFrame.new(frame.x, frame.y - 0.1, z + 0.07),
            Vector3.new((frame.w - 0.45) * 0.75, (frame.h - 0.55) * 0.5, 0.02),
            frame.art,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Linha da gravura",
            CFrame.new(frame.x, frame.y + 0.27, z + 0.08),
            Vector3.new(frame.w - 0.55, 0.025, 0.012),
            Palette.Ink,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

function Bedroom.build(parent: Instance)
    local model = Kit.model(parent, "Quarto")
    buildRug(model)
    buildAccentWall(model)
    buildBed(model)
    buildNightstand(model)
    buildWardrobe(model)
    buildWindowDressing(model)
    buildPendant(model)
    buildSconces(model)
    buildGallery(model)
    return model
end

return Bedroom

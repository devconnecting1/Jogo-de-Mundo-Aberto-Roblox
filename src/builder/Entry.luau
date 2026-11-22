local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Entrada: porta de madeira com ferragens, capacho, banco de sapatos,
    ganchos, espelho, aparador e a luz de chegada.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")
local Layout = require("./Layout")

local Entry = {}

local function buildDoor(parent: Instance)
    local model = Kit.model(parent, "Porta da entrada")
    local x = Layout.entryDoor.centerX
    local z = 10.17
    local height = 6.9
    local width = 3.02

    Kit.box(
        model,
        "Folha da porta",
        CFrame.new(x, height * 0.5 + 0.03, z),
        Vector3.new(width, height, 0.24),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = true, query = true }
    )

    -- Painéis rebaixados, desenhados somente no lado interno.
    local faceZ = z - 0.135
    for row = 0, 2 do
        local panelY = 1.45 + row * 1.86
        local panelHeight = if row == 0 then 1.3 else 1.48
        Kit.box(
            model,
            "Painel da porta",
            CFrame.new(x, panelY, faceZ),
            Vector3.new(2.12, panelHeight, 0.045),
            Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        for side = -1, 1 do
            Kit.box(
                model,
                "Moldura do painel",
                CFrame.new(x + side * 1.17, panelY, faceZ - 0.035),
                Vector3.new(0.16, panelHeight + 0.26, 0.07),
                Palette.Walnut,
                Palette.Materials.wood,
                { collide = false, query = false, shadow = false }
            )
        end
        Kit.box(
            model,
            "Moldura do painel",
            CFrame.new(x, panelY + panelHeight * 0.5 + 0.09, faceZ - 0.035),
            Vector3.new(2.46, 0.14, 0.07),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Moldura do painel",
            CFrame.new(x, panelY - panelHeight * 0.5 - 0.09, faceZ - 0.035),
            Vector3.new(2.46, 0.14, 0.07),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Maçaneta, fechadura e puxador.
    local hardwareZ = z - 0.2
    Kit.cylinder(
        model,
        "Espelho da fechadura",
        CFrame.new(x + 1.05, 3.55, hardwareZ + 0.04),
        0.08,
        0.52,
        Palette.Brass,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false, reflectance = 0.25 }
    )
    Kit.sphere(
        model,
        "Maçaneta",
        CFrame.new(x + 1.05, 3.55, hardwareZ - 0.13),
        Vector3.new(0.36, 0.36, 0.36),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.3 }
    )
    Kit.cylinder(
        model,
        "Cilindro da fechadura",
        CFrame.new(x + 1.05, 4.33, hardwareZ + 0.01),
        0.09,
        0.34,
        Palette.BrassDark,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Fenda da chave",
        CFrame.new(x + 1.05, 4.33, hardwareZ - 0.055),
        Vector3.new(0.035, 0.16, 0.02),
        Palette.Ink,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    Kit.cylinder(
        model,
        "Olho mágico",
        CFrame.new(x, 5.48, hardwareZ + 0.03),
        0.08,
        0.21,
        Palette.Brass,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false, reflectance = 0.4 }
    )
    Kit.cylinder(
        model,
        "Lente do olho mágico",
        CFrame.new(x, 5.48, hardwareZ - 0.02),
        0.02,
        0.12,
        Palette.GlassSmoke,
        Palette.Materials.glass,
        "z",
        { collide = false, query = false, shadow = false, reflectance = 0.45, transparency = 0.15 }
    )

    Kit.box(
        model,
        "Chapa de proteção",
        CFrame.new(x, 0.7, z - 0.14),
        Vector3.new(2.5, 0.55, 0.035),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.22 }
    )
    for i = 1, 12 do
        Kit.box(
            model,
            "Ribete",
            CFrame.new(x - 1.08 + (i - 1) * 0.196, 0.7, z - 0.165),
            Vector3.new(0.07, 0.07, 0.03),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    Kit.box(
        model,
        "Abridor de cartas",
        CFrame.new(x, 2.55, faceZ - 0.055),
        Vector3.new(1.22, 0.25, 0.07),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.2 }
    )
    Kit.box(
        model,
        "Abertura do abre-cartas",
        CFrame.new(x, 2.55, faceZ - 0.098),
        Vector3.new(1.02, 0.045, 0.02),
        Palette.Ink,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    for i = 0, 2 do
        Kit.cylinder(
            model,
            "Dobradiça",
            CFrame.new(x - width * 0.5 + 0.06, 1.55 + i * 1.82, hardwareZ + 0.02),
            0.38,
            0.17,
            Palette.BrassDark,
            Palette.Materials.metal,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    -- Corrente de segurança.
    local chainX = x - 0.95
    Kit.cylinder(
        model,
        "Placa da corrente",
        CFrame.new(chainX, 4.75, faceZ - 0.06),
        0.07,
        0.32,
        Palette.Brass,
        Palette.Materials.metal,
        "z",
        { collide = false, query = false, shadow = false }
    )
    for i = 1, 7 do
        local link = Kit.cylinder(
            model,
            "Elo da corrente",
            Kit.rotated(chainX + 0.2 + i * 0.09, 4.62 - i * 0.04, faceZ - 0.09, 0, 0, 0),
            0.02,
            0.12,
            Palette.Brass,
            Palette.Materials.metal,
            if i % 2 == 0 then "x" else "y",
            { collide = false, query = false, shadow = false }
        )
        link.CFrame *= CFrame.Angles(0, 0, math.rad(90))
    end

    return model
end

local function buildDoormat(parent: Instance)
    local model = Kit.model(parent, "Capacho")
    Kit.box(
        model,
        "Tapete da entrada",
        Kit.rotated(-3.6, 0.06, 8.75, 0, 2, 0),
        Vector3.new(3.25, 0.1, 1.75),
        Palette.Charcoal,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Borda do capacho",
        Kit.rotated(-3.6, 0.115, 8.75, 0, 2, 0),
        Vector3.new(2.8, 0.012, 1.36),
        Palette.Olive,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )
    for side = -1, 1 do
        for i = 1, 10 do
            Kit.box(
                model,
                "Franja",
                Kit.rotated(-3.6 + (i - 5.5) * 0.27, 0.06, 8.75 + side * 0.94, 0, 2, 0),
                Vector3.new(0.06, 0.02, 0.2),
                Palette.Linen,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

local function buildConsole(parent: Instance)
    local model = Kit.model(parent, "Aparador da entrada")
    local x = 0.45
    local z = 9.45

    Kit.box(
        model,
        "Tampo do aparador",
        CFrame.new(x, 2.75, z),
        Vector3.new(3.15, 0.18, 1.18),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Corpo do aparador",
        CFrame.new(x, 2.15, z + 0.02),
        Vector3.new(2.9, 0.8, 0.96),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Frente da gaveta",
        CFrame.new(x, 2.18, z - 0.49),
        Vector3.new(2.7, 0.64, 0.06),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.sphere(
        model,
        "Puxador da gaveta",
        CFrame.new(x, 2.2, z - 0.57),
        Vector3.new(0.14, 0.14, 0.14),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.35 }
    )
    for _, side in { -1, 1 } do
        Kit.cylinder(
            model,
            "Perna do aparador",
            CFrame.new(x + side * 1.3, 1.16, z + 0.38),
            2.3,
            0.14,
            Palette.Walnut,
            Palette.Materials.wood,
            "y",
            { collide = true, query = true, shadow = false }
        )
        Kit.cylinder(
            model,
            "Perna do aparador",
            CFrame.new(x + side * 1.3, 1.16, z - 0.38),
            2.3,
            0.14,
            Palette.Walnut,
            Palette.Materials.wood,
            "y",
            { collide = true, query = true, shadow = false }
        )
    end
    Kit.box(
        model,
        "Prateleira inferior",
        CFrame.new(x, 0.8, z + 0.04),
        Vector3.new(2.72, 0.1, 0.8),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )

    -- Objetos de chegada.
    local tray = Kit.cylinder(
        model,
        "Bandeja",
        CFrame.new(x - 0.7, 2.87, z),
        0.09,
        1.0,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false, reflectance = 0.3 }
    )
    tray.Name = "Bandeja de latão"
    Kit.cylinder(
        model,
        "Bandeja - fundo",
        CFrame.new(x - 0.7, 2.925, z),
        0.02,
        0.82,
        Palette.Walnut,
        Palette.Materials.wood,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Chaves",
        Kit.rotated(x - 0.78, 2.96, z - 0.05, 0, 24, 0),
        Vector3.new(0.42, 0.035, 0.13),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Chaveiro",
        CFrame.new(x - 0.98, 2.96, z - 0.02),
        0.035,
        0.26,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Correspondência",
        Kit.rotated(x + 0.45, 2.88, z + 0.04, 0, -8, 0),
        Vector3.new(0.92, 0.035, 0.5),
        Palette.Cream,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Carta",
        Kit.rotated(x + 0.5, 2.92, z - 0.08, 0, 12, 0),
        Vector3.new(0.72, 0.012, 0.36),
        Palette.PlasterWarm,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    local vase = Kit.cylinder(
        model,
        "Jarra",
        CFrame.new(x + 1.18, 3.12, z + 0.02),
        0.62,
        0.45,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Gargalo da jarra",
        CFrame.new(x + 1.18, 3.52, z + 0.02),
        0.32,
        0.22,
        Palette.CeramicClay,
        Palette.Materials.ceramic,
        "y",
        { collide = false, query = false, shadow = false }
    )
    for i = 1, 5 do
        local stemTop = Vector3.new(x + 1.18 + (i - 3) * 0.11, 4.55 + (i % 2) * 0.28, z + 0.02)
        Kit.rodBetween(
            model,
            "Haste seca",
            Vector3.new(x + 1.18, 3.55, z + 0.02),
            stemTop,
            0.035,
            Palette.Stem,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Flor seca",
            CFrame.new(stemTop),
            Vector3.new(0.2, 0.36, 0.2),
            Palette.Mustard,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end

    Kit.box(
        model,
        "Cesto",
        CFrame.new(x - 1.05, 0.48, z + 0.05),
        Vector3.new(1.05, 0.8, 0.72),
        Palette.CeramicSpeckle,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Cesto - borda",
        CFrame.new(x - 1.05, 0.9, z + 0.05),
        Vector3.new(1.13, 0.08, 0.8),
        Palette.OakPale,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildMirror(parent: Instance)
    local model = Kit.model(parent, "Espelho da entrada")
    local x = 0.45
    local y = 6.1
    local z = 9.94

    Kit.box(
        model,
        "Moldura do espelho",
        CFrame.new(x, y, z + 0.02),
        Vector3.new(2.5, 3.65, 0.13),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Espelho",
        CFrame.new(x, y, z - 0.06),
        Vector3.new(2.24, 3.35, 0.06),
        Palette.GlassSmoke,
        Palette.Materials.glass,
        {
            collide = false,
            query = false,
            shadow = false,
            transparency = 0.18,
            reflectance = 0.5,
        }
    )
    Kit.box(
        model,
        "Brilho do espelho",
        CFrame.new(x - 0.58, y + 0.55, z - 0.095),
        Vector3.new(0.25, 1.9, 0.015),
        Palette.LinenLight,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false, transparency = 0.72 }
    )
    for i = 1, 4 do
        Kit.box(
            model,
            "Ripa da moldura",
            CFrame.new(x - 0.98 + (i - 1) * 0.65, y, z - 0.115),
            Vector3.new(0.06, 3.25, 0.03),
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildCoatNook(parent: Instance)
    local model = Kit.model(parent, "Canto dos casacos")
    local x1, x2 = -7.0, -5.62
    local z = 9.94
    local midX = (x1 + x2) * 0.5

    Kit.box(
        model,
        "Painel de ganchos",
        CFrame.new(midX, 5.8, z),
        Vector3.new(x2 - x1, 2.7, 0.09),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Ripa do painel",
        CFrame.new(midX, 7.18, z - 0.02),
        Vector3.new(x2 - x1 + 0.2, 0.13, 0.13),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for i = 1, 3 do
        local hookX = x1 + (x2 - x1) * (i / 4)
        Kit.cylinder(
            model,
            "Gancho",
            CFrame.new(hookX, 6.42, z - 0.13),
            0.28,
            0.11,
            Palette.Brass,
            Palette.Materials.metal,
            "z",
            { collide = false, query = false, shadow = false }
        )
        Kit.sphere(
            model,
            "Ponta do gancho",
            CFrame.new(hookX, 6.56, z - 0.26),
            Vector3.new(0.14, 0.14, 0.14),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Casaco de linho pendurado no primeiro gancho.
    local coatX = x1 + (x2 - x1) * 0.25
    Kit.box(
        model,
        "Casaco - ombros",
        Kit.rotated(coatX, 5.86, z - 0.22, 0, 0, -3),
        Vector3.new(1.02, 0.28, 0.25),
        Palette.Olive,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Casaco - corpo",
        Kit.rotated(coatX, 4.2, z - 0.25, 0, 0, 2),
        Vector3.new(0.78, 3.3, 0.24),
        Palette.Olive,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    for _, side in { -1, 1 } do
        Kit.box(
            model,
            "Manga",
            Kit.rotated(coatX + side * 0.53, 4.55, z - 0.26, 0, 0, side * 5),
            Vector3.new(0.23, 2.0, 0.2),
            Palette.OliveDeep,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Cachecol",
        Kit.rotated(coatX + 0.28, 5.55, z - 0.43, 0, 0, -12),
        Vector3.new(0.22, 1.65, 0.09),
        Palette.Mustard,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    -- Bolsa de palha no segundo gancho.
    local bagX = x1 + (x2 - x1) * 0.5
    Kit.box(
        model,
        "Bolsa",
        CFrame.new(bagX, 5.3, z - 0.35),
        Vector3.new(0.85, 1.15, 0.3),
        Palette.OakPale,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Alça da bolsa",
        Vector3.new(bagX - 0.3, 5.88, z - 0.35),
        Vector3.new(bagX, 6.35, z - 0.35),
        0.055,
        Palette.Straw or Palette.OakPale,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Alça da bolsa",
        Vector3.new(bagX + 0.3, 5.88, z - 0.35),
        Vector3.new(bagX, 6.35, z - 0.35),
        0.055,
        Palette.OakPale,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Fita da bolsa",
        CFrame.new(bagX, 5.15, z - 0.515),
        Vector3.new(0.2, 0.4, 0.03),
        Palette.Terracotta,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )

    -- Chapéu de palha no terceiro gancho.
    local hatX = x1 + (x2 - x1) * 0.75
    Kit.cylinder(
        model,
        "Aba do chapéu",
        CFrame.new(hatX, 5.75, z - 0.44),
        0.07,
        1.12,
        Palette.OakPale,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Copa do chapéu",
        CFrame.new(hatX, 5.85, z - 0.44),
        0.42,
        0.62,
        Palette.OakPale,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Fita do chapéu",
        CFrame.new(hatX, 5.8, z - 0.44),
        0.16,
        0.64,
        Palette.Charcoal,
        Palette.Materials.fabric,
        "y",
        { collide = false, query = false, shadow = false }
    )

    -- Banco e sapatos.
    Kit.box(
        model,
        "Assento do banco",
        CFrame.new(midX, 1.32, 9.35),
        Vector3.new(1.7, 0.18, 1.1),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = true }
    )
    for _, side in { -1, 1 } do
        Kit.box(
            model,
            "Perna do banco",
            CFrame.new(midX + side * 0.68, 0.61, 9.35),
            Vector3.new(0.14, 1.22, 0.9),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = true, query = true, shadow = false }
        )
    end
    for i = 1, 3 do
        local sx = midX - 0.58 + (i - 1) * 0.58
        Kit.box(
            model,
            "Sapato",
            CFrame.new(sx, 0.2, 8.95 + (i % 2) * 0.18),
            Vector3.new(0.45, 0.22, 1.0),
            if i % 2 == 0 then Palette.WalnutDeep else Palette.Ink,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            model,
            "Bico do sapato",
            CFrame.new(sx, 0.2, 8.37 + (i % 2) * 0.18),
            Vector3.new(0.4, 0.15, 0.28),
            if i % 2 == 0 then Palette.WalnutDeep else Palette.Ink,
            Palette.Materials.fabric,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.cylinder(
        model,
        "Porta-guarda-chuva",
        CFrame.new(-5.35, 1.25, 9.5),
        2.1,
        0.48,
        Palette.SteelDark,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.rodBetween(
        model,
        "Guarda-chuva",
        Vector3.new(-5.35, 0.4, 9.5),
        Vector3.new(-5.28, 4.1, 9.45),
        0.09,
        Palette.Charcoal,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Cabo do guarda-chuva",
        CFrame.new(-5.28, 4.15, 9.45),
        0.42,
        0.09,
        Palette.Walnut,
        Palette.Materials.wood,
        "x",
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildLighting(parent: Instance)
    local model = Kit.model(parent, "Iluminação da entrada")

    Kit.cylinder(
        model,
        "Luminária de teto",
        CFrame.new(-3.6, 8.89, 8.65),
        0.22,
        1.0,
        Palette.Brass,
        Palette.Materials.metal,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.sphere(
        model,
        "Cúpula",
        CFrame.new(-3.6, 8.62, 8.65),
        Vector3.new(0.9, 0.48, 0.9),
        Palette.Enamel,
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, transparency = 0.35 }
    )
    Kit.pointLight(
        Kit.sphere(
            model,
            "Lâmpada",
            CFrame.new(-3.6, 8.52, 8.65),
            Vector3.new(0.38, 0.3, 0.38),
            Color3.fromRGB(255, 220, 169),
            Palette.Materials.neon,
            { collide = false, query = false, shadow = false }
        ),
        Color3.fromRGB(255, 210, 154),
        { name = "Luz da entrada", brightness = 1.2, range = 12, shadows = false }
    )

    -- Interruptor e tomada.
    Kit.box(
        model,
        "Espelho do interruptor",
        CFrame.new(-1.65, 4.1, 9.965),
        Vector3.new(0.42, 0.64, 0.06),
        Palette.Trim,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Interruptor",
        CFrame.new(-1.65, 4.1, 9.925),
        Vector3.new(0.2, 0.3, 0.05),
        Palette.CeramicWhite,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Tomada",
        CFrame.new(1.45, 1.45, 9.96),
        Vector3.new(0.5, 0.32, 0.06),
        Palette.Trim,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    return model
end

function Entry.build(parent: Instance)
    local model = Kit.model(parent, "Entrada")
    buildDoor(model)
    buildDoormat(model)
    buildConsole(model)
    buildMirror(model)
    buildCoatNook(model)
    buildLighting(model)
    return model
end

return Entry

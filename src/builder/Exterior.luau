local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Exterior mínimo e cuidado: jardim, árvores, cercas, caixas de flores nas
    janelas e a entrada com degraus. Ele existe para que as vistas de dentro
    da casa tenham profundidade e não terminem num vazio.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")

local Exterior = {}

local function leafCluster(parent: Instance, position: Vector3, radius: number, color: Color3)
    local lobes = {
        { offset = Vector3.new(0, 0, 0), size = 1.0 },
        { offset = Vector3.new(-0.75, -0.2, 0.15), size = 0.72 },
        { offset = Vector3.new(0.7, 0.1, 0.25), size = 0.78 },
        { offset = Vector3.new(0.1, 0.55, -0.55), size = 0.66 },
        { offset = Vector3.new(-0.1, -0.45, -0.6), size = 0.58 },
    }
    for index, lobe in lobes do
        Kit.sphere(
            parent,
            "Copa " .. index,
            CFrame.new(position + lobe.offset * radius),
            Vector3.new(radius * lobe.size * 1.15, radius * lobe.size * 0.8, radius * lobe.size),
            Kit.tint(color, (index % 3 - 1) * 0.04),
            Palette.Materials.leaf,
            { collide = false, query = false, shadow = true }
        )
    end
end

local function buildTree(parent: Instance, name: string, x: number, z: number, scale: number)
    local model = Kit.model(parent, name)

    for trunk = 1, 3 do
        Kit.rodBetween(
            model,
            "Tronco",
            Vector3.new(x + (trunk - 2) * 0.2, -0.4, z + (trunk % 2) * 0.15),
            Vector3.new(x + (trunk - 2) * 0.8, 7.8 * scale + trunk * 0.3, z - 0.1 + trunk * 0.1),
            0.65 - trunk * 0.08,
            Palette.Bark,
            Palette.Materials.wood,
            { collide = false, query = false }
        )
    end
    for branch = 1, 4 do
        local angle = branch * 1.8
        Kit.rodBetween(
            model,
            "Galho",
            Vector3.new(x, 5.8 * scale, z),
            Vector3.new(
                x + math.cos(angle) * 2.2 * scale,
                (8.0 + (branch % 2) * 0.8) * scale,
                z + math.sin(angle) * 2.2 * scale
            ),
            0.24,
            Palette.Bark,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    leafCluster(model, Vector3.new(x - 1.1 * scale, 9.7 * scale, z - 0.4 * scale), 2.7 * scale, Palette.Hedge)
    leafCluster(model, Vector3.new(x + 1.6 * scale, 8.9 * scale, z + 0.6 * scale), 2.1 * scale, Palette.Leaf)
    leafCluster(model, Vector3.new(x - 0.2 * scale, 8.0 * scale, z + 1.7 * scale), 1.8 * scale, Palette.LeafDeep)
    leafCluster(model, Vector3.new(x + 0.5 * scale, 10.5 * scale, z - 1.3 * scale), 1.65 * scale, Palette.LeafLight)

    return model
end

local function buildHedge(
    parent: Instance,
    name: string,
    x1: number,
    z1: number,
    x2: number,
    z2: number,
    height: number
)
    local model = Kit.model(parent, name)
    local startPoint = Vector3.new(x1, 0, z1)
    local endPoint = Vector3.new(x2, 0, z2)
    local length = (endPoint - startPoint).Magnitude
    local count = math.max(2, math.ceil(length / 1.5))
    for index = 1, count do
        local t = (index - 0.5) / count
        local position = startPoint:Lerp(endPoint, t)
        local wobble = CFrame.Angles(0, index * 0.7, 0) * CFrame.new(0, 0, ((index % 3) - 1) * 0.12)
        Kit.sphere(
            model,
            "Arbusto",
            CFrame.new(position + Vector3.yAxis * (height * 0.55)) * wobble,
            Vector3.new(1.75, height, 1.2),
            if index % 3 == 0 then Palette.LeafDeep else Palette.Hedge,
            Palette.Materials.leaf,
            { collide = false, query = false }
        )
    end
    return model
end

local function buildPlanters(parent: Instance)
    local model = Kit.model(parent, "Caixas de flores")

    local function boxPlanter(x: number, y: number, z: number, width: number, alongX: boolean, mirrored: boolean?)
        local direction = if mirrored then -1 else 1
        local size = if alongX then Vector3.new(width, 0.62, 0.7) else Vector3.new(0.7, 0.62, width)
        local cframe = if alongX
            then CFrame.new(x, y, z + direction * 0.48)
            else CFrame.new(x + direction * 0.48, y, z)

        Kit.box(
            model,
            "Jardineira",
            cframe,
            size,
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )

        local soilY = y + 0.27
        local soilSize = if alongX then Vector3.new(width - 0.18, 0.08, 0.52) else Vector3.new(0.52, 0.08, width - 0.18)
        local soilPos = if alongX then CFrame.new(x, soilY, z + direction * 0.48) else CFrame.new(x + direction * 0.48, soilY, z)
        Kit.box(
            model,
            "Terra da jardineira",
            soilPos,
            soilSize,
            Palette.Soil,
            Palette.Materials.leaf,
            { collide = false, query = false, shadow = false }
        )

        local count = math.max(3, math.floor(width / 0.48))
        for plant = 1, count do
            local offset = -width * 0.5 + (plant - 0.5) * (width / count)
            local px = if alongX then x + offset else x + direction * 0.48
            local pz = if alongX then z + direction * 0.48 else z + offset
            local height = 0.3 + (plant % 3) * 0.16
            Kit.sphere(
                model,
                "Folhagem",
                CFrame.new(px, y + 0.38 + height * 0.5, pz),
                Vector3.new(0.5, height, 0.42),
                if plant % 2 == 0 then Palette.Leaf else Palette.LeafLight,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
            if plant % 3 ~= 0 then
                Kit.sphere(
                    model,
                    "Flor",
                    CFrame.new(px, y + 0.45 + height, pz),
                    Vector3.new(0.22, 0.16, 0.22),
                    if plant % 2 == 0 then Palette.Flower else Palette.Mustard,
                    Palette.Materials.fabric,
                    { collide = false, query = false, shadow = false }
                )
            end
        end
    end

    -- Cozinha, sala, jantar e quarto.
    boxPlanter(-3.0, 3.78, -10.25, 3.15, true, true)
    boxPlanter(-12.35, 4.65, 10.25, 2.2, true, false)
    boxPlanter(8.4, 3.05, 10.25, 3.4, true, false)
    boxPlanter(-14.25, 3.1, 1.7, 2.6, false, true)
    boxPlanter(14.25, 3.4, -5.9, 3.4, false, false)

    return model
end

local function buildPorch(parent: Instance)
    local model = Kit.model(parent, "Entrada externa")
    local doorX = -3.6
    local frontZ = 10.25

    Kit.box(
        model,
        "Patamar da entrada",
        CFrame.new(doorX, -0.08, 11.25),
        Vector3.new(4.6, 0.34, 2.0),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Degrau",
        CFrame.new(doorX, -0.28, 12.35),
        Vector3.new(4.3, 0.24, 0.95),
        Palette.StoneDark,
        Palette.Materials.slate,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Degrau",
        CFrame.new(doorX, -0.45, 13.1),
        Vector3.new(4.0, 0.2, 0.8),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = true, query = true }
    )
    Kit.box(
        model,
        "Capacho externo",
        CFrame.new(doorX, -0.22, 11.0),
        Vector3.new(2.6, 0.08, 1.4),
        Palette.Charcoal,
        Palette.Materials.carpet,
        { collide = false, query = false, shadow = false }
    )

    -- Vasos e banco de varanda.
    for index, x in { doorX - 2.35, doorX + 2.35 } do
        Kit.cylinder(
            model,
            "Vaso de varanda",
            CFrame.new(x, -0.12, 11.1),
            1.0,
            0.85,
            Palette.CeramicClay,
            Palette.Materials.ceramic,
            "y",
            { collide = false, query = false }
        )
        for leaf = 1, 6 do
            local angle = leaf * 1.4
            Kit.sphere(
                model,
                "Folha do vaso",
                CFrame.new(
                    x + math.cos(angle) * 0.35,
                    0.65 + (leaf % 3) * 0.25,
                    11.1 + math.sin(angle) * 0.35
                ) * CFrame.Angles(math.rad(20), angle, math.rad(15)),
                Vector3.new(0.2, 0.8, 0.36),
                if leaf % 2 == 0 then Palette.Leaf else Palette.LeafDeep,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    Kit.box(
        model,
        "Banco externo",
        CFrame.new(doorX + 3.1, 0.55, 11.35),
        Vector3.new(2.2, 0.18, 0.85),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    for _, leg in { -0.85, 0.85 } do
        Kit.box(
            model,
            "Pé do banco externo",
            CFrame.new(doorX + 3.1 + leg, -0.02, 11.35),
            Vector3.new(0.14, 1.1, 0.7),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Lanterna de parede externa.
    Kit.box(
        model,
        "Suporte da lanterna",
        CFrame.new(doorX + 1.9, 5.55, frontZ + 0.12),
        Vector3.new(0.35, 1.2, 0.2),
        Palette.Ink,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    local lantern = Kit.box(
        model,
        "Lanterna externa",
        CFrame.new(doorX + 1.9, 5.3, frontZ + 0.28),
        Vector3.new(0.62, 0.95, 0.62),
        Palette.GlassSmoke,
        Palette.Materials.glass,
        { collide = false, query = false, shadow = false, transparency = 0.3 }
    )
    Kit.pointLight(lantern, Color3.fromRGB(255, 199, 130), {
        name = "Luz externa",
        brightness = 0.8,
        range = 10,
        shadows = true,
    })

    return model
end

local function buildPavers(parent: Instance)
    local model = Kit.model(parent, "Caminho de pedra")
    local doorX = -3.6
    for index = 1, 10 do
        local z = 13.8 + index * 1.55
        local x = doorX + math.sin(index * 0.9) * 0.9
        Kit.cylinder(
            model,
            "Laje",
            CFrame.new(x, -0.48, z) * CFrame.Angles(0, index * 0.5, 0),
            0.12,
            2.1,
            if index % 2 == 0 then Palette.Path else Palette.Stone,
            Palette.Materials.slate,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildFence(parent: Instance)
    local model = Kit.model(parent, "Cerca do jardim")
    local z = 20.0

    for post = 1, 17 do
        local x = -32 + (post - 1) * 4
        Kit.box(
            model,
            "Poste da cerca",
            CFrame.new(x, 1.7, z),
            Vector3.new(0.24, 4.2, 0.24),
            Palette.OakDark,
            Palette.Materials.wood,
            { collide = false, query = false }
        )
    end
    for rail = 0, 2 do
        Kit.box(
            model,
            "Travessa da cerca",
            CFrame.new(0, 1.2 + rail * 1.05, z),
            Vector3.new(68, 0.16, 0.12),
            Palette.Oak,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
    return model
end

local function buildGardenExtras(parent: Instance)
    local model = Kit.model(parent, "Detalhes do jardim")

    -- Banco e mesa no gramado, visíveis de longe.
    Kit.box(
        model,
        "Banco do jardim",
        CFrame.new(-17.5, 0.8, 5.0),
        Vector3.new(3.4, 0.2, 1.0),
        Palette.Oak,
        Palette.Materials.wood,
        { collide = false, query = false }
    )
    for _, side in { -1, 1 } do
        Kit.box(
            model,
            "Pé do banco do jardim",
            CFrame.new(-17.5 + side * 1.35, 0.05, 5.0),
            Vector3.new(0.18, 1.55, 0.9),
            Palette.Walnut,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Pedras e tufos de grama mais alta.
    local tufts = {
        { x = -17.0, z = 9.0, scale = 1.0 },
        { x = 6.0, z = 14.0, scale = 0.8 },
        { x = 15.5, z = -2.0, scale = 0.9 },
        { x = -8.0, z = -14.5, scale = 0.7 },
        { x = 3.0, z = -15.0, scale = 0.6 },
    }
    for index, tuft in tufts do
        for blade = 1, 5 do
            Kit.box(
                model,
                "Tufo de grama",
                Kit.rotated(
                    tuft.x + math.cos(blade * 1.7) * 0.35,
                    0.5 * tuft.scale,
                    tuft.z + math.sin(blade * 1.7) * 0.35,
                    0,
                    blade * 30,
                    8
                ),
                Vector3.new(0.06, 1.4 * tuft.scale, 0.06),
                if blade % 2 == 0 then Palette.Grass else Palette.GrassDark,
                Palette.Materials.leaf,
                { collide = false, query = false, shadow = false }
            )
        end
    end
    return model
end

function Exterior.build(parent: Instance)
    local model = Kit.model(parent, "Exterior")

    Kit.box(
        model,
        "Grama",
        CFrame.new(0, -0.85, 0),
        Vector3.new(140, 0.6, 140),
        Palette.Grass,
        Palette.Materials.grass,
        { collide = true, query = true }
    )
    for patch = 1, 8 do
        local angle = patch * 1.3
        Kit.cylinder(
            model,
            "Mancha de grama",
            CFrame.new(math.cos(angle) * (18 + patch), -0.535, math.sin(angle) * (18 + patch * 2)),
            0.02,
            7 + patch,
            if patch % 2 == 0 then Palette.GrassDark else Palette.Grass,
            Palette.Materials.grass,
            "y",
            { collide = false, query = false, shadow = false }
        )
    end

    buildTree(model, "Árvore oeste", -21.0, 1.5, 1.15)
    buildTree(model, "Árvore dos fundos", -8.0, -18.0, 1.0)
    buildTree(model, "Árvore da frente", 9.0, 18.5, 1.2)
    buildTree(model, "Árvore leste", 21.0, -5.0, 0.9)

    buildHedge(model, "Seba oeste", -16.5, -4.0, -16.5, 7.5, 2.6)
    buildHedge(model, "Seba dos fundos", -7.5, -13.0, 1.5, -13.0, 2.2)
    buildHedge(model, "Seba da frente", 5.0, 13.2, 12.0, 13.2, 2.0)
    buildHedge(model, "Seba leste", 16.3, -8.5, 16.3, -1.0, 2.4)

    buildPlanters(model)
    buildPorch(model)
    buildPavers(model)
    buildFence(model)
    buildGardenExtras(model)

    return model
end

return Exterior

local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Casa 27 — planta baixa
    Unidade: studs. A referência de escala é 1 stud ≈ 0,28 m, a mesma usada
    para a altura de um personagem R15. A área interna é de ~44 m² e cada
    circulação foi desenhada para caber com o avatar em terceira pessoa.
]]

local Layout = {}

Layout.title = "Casa 27"
Layout.studsPerMeter = 3.571
Layout.floorY = 0
Layout.height = 9.2
Layout.wallThickness = 0.5
Layout.innerWallThickness = 0.35
Layout.corner = 0.5

Layout.inner = {
    minX = -14,
    maxX = 14,
    minZ = -10,
    maxZ = 10,
}

Layout.outer = {
    minX = -14.25,
    maxX = 14.25,
    minZ = -10.25,
    maxZ = 10.25,
}

Layout.ceiling = {
    y = 9.2,
    thickness = 0.45,
}

Layout.skylight = {
    minX = -12.1,
    maxX = -7.1,
    minZ = -1.6,
    maxZ = 2.6,
    glassY = 9.7,
}

Layout.bathroom = {
    minX = -14,
    maxX = -7.6,
    minZ = 3.8,
    maxZ = 10,
    northWall = 3.625,
    eastWall = -7.425,
    doorMinZ = 6.7,
    doorMaxZ = 9.3,
    doorHeight = 7.0,
}

Layout.entryDoor = {
    centerX = -3.6,
    minX = -5.2,
    maxX = -2.0,
    height = 7.0,
    z = 10.25,
}

Layout.walls = {
    back = {
        name = "Parede dos fundos",
        axis = "X",
        center = -10.25,
        from = -14.25,
        to = 14.25,
        thickness = 0.5,
        innerSign = 1,
        openings = {
            {
                name = "Janela da cozinha",
                kind = "window",
                from = -4.8,
                to = -1.2,
                bottom = 4.15,
                top = 7.2,
                mullions = 1,
                curtains = false,
            },
            {
                name = "Janela do quarto",
                kind = "window",
                from = 9.2,
                to = 12.8,
                bottom = 5.15,
                top = 8.1,
                mullions = 2,
                curtains = false,
            },
        },
    },
    front = {
        name = "Parede da frente",
        axis = "X",
        center = 10.25,
        from = -14.25,
        to = 14.25,
        thickness = 0.5,
        innerSign = -1,
        openings = {
            {
                name = "Porta da entrada",
                kind = "door",
                from = -5.2,
                to = -2.0,
                bottom = 0,
                top = 7.0,
            },
            {
                name = "Janela de jantar",
                kind = "window",
                from = 6.6,
                to = 10.2,
                bottom = 3.4,
                top = 7.2,
                mullions = 1,
                curtains = true,
            },
            {
                name = "Janela do banheiro",
                kind = "window",
                from = -12.7,
                to = -10.1,
                bottom = 5.0,
                top = 7.0,
                frosted = true,
                mullions = 1,
                curtains = false,
            },
        },
    },
    left = {
        name = "Parede oeste",
        axis = "Z",
        center = -14.25,
        from = -10.25,
        to = 10.25,
        thickness = 0.5,
        innerSign = 1,
        openings = {
            {
                name = "Janela da sala",
                kind = "window",
                from = 0.2,
                to = 3.2,
                bottom = 3.4,
                top = 7.2,
                mullions = 1,
                curtains = true,
            },
        },
    },
    right = {
        name = "Parede leste",
        axis = "Z",
        center = 14.25,
        from = -10.25,
        to = 10.25,
        thickness = 0.5,
        innerSign = -1,
        openings = {
            {
                name = "Janela lateral do quarto",
                kind = "window",
                from = -7.8,
                to = -4.0,
                bottom = 3.8,
                top = 7.2,
                mullions = 1,
                curtains = false,
            },
        },
    },
}

Layout.dining = {
    centerX = 9.4,
    centerZ = 6.1,
    radius = 2.0,
}

Layout.spawn = {
    position = Vector3.new(-3.6, 0.55, 8.4),
    lookAt = Vector3.new(-3.0, 3.2, -4.0),
}

return Layout

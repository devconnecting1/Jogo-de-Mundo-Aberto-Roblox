local Compat = require("./Compat")
local Vector3 = Compat.Vector3

--[[
    Presídio Central — planta e escala.
    1 stud ≈ 0,28 m. O edifício principal tem três pavimentos de 13 studs
    (pé-direito livre de ~3,4 m), organizados em torno de um átrio central
    com galerias de celas. As medidas foram pensadas para circulação real de
    guardas, detentos e visitantes, com alas de segurança separadas.
]]

local Layout = {}

Layout.title = "Presídio Central"
Layout.name = "PrisaoCentral"
Layout.studsPerMeter = 3.571
Layout.floorHeight = 13
Layout.levelCount = 3
Layout.roofY = 39
Layout.parapetY = 41.6
Layout.wallThickness = 1.5
Layout.innerWallThickness = 0.6
Layout.cellHeight = 12.2

Layout.site = {
    minX = -106,
    maxX = 122,
    minZ = -54,
    maxZ = 60,
}

-- Edifício principal (casa de detenção) --------------------------------------
Layout.outer = {
    minX = -40,
    maxX = 40,
    minZ = -46,
    maxZ = 38,
}

Layout.inner = {
    minX = -38.5,
    maxX = 38.5,
    minZ = -44.5,
    maxZ = 36.5,
}

-- Vazio do átrio entre as galerias.
Layout.atrium = {
    minX = -18,
    maxX = 18,
    minZ = -20,
    maxZ = 20,
}

-- Hall de convivência no térreo, mais largo que o vazio das galerias.
Layout.hall = {
    minX = -26,
    maxX = 26,
    minZ = -27,
    maxZ = 27,
}

Layout.galleries = {
    west = { minX = -26, maxX = -18, minZ = -27, maxZ = 27 },
    east = { minX = 18, maxX = 26, minZ = -27, maxZ = 27 },
    north = { minX = -18, maxX = 18, minZ = -27, maxZ = -20 },
    south = { minX = -18, maxX = 18, minZ = 20, maxZ = 27 },
}

Layout.cellBlocks = {
    west = { minX = -38.5, maxX = -26, minZ = -27, maxZ = 27, side = "west" },
    east = { minX = 26, maxX = 38.5, minZ = -27, maxZ = 27, side = "east" },
}

Layout.cellCount = 7
Layout.cellWidth = 54 / Layout.cellCount
Layout.cellLevels = { 1, 2 }

-- Alas internas no térreo ----------------------------------------------------
Layout.westWing = {
    kitchen = { minX = -38.5, maxX = -26, minZ = -27, maxZ = 8 },
    passage = { minX = -38.5, maxX = -26, minZ = 8, maxZ = 14 },
    scullery = { minX = -38.5, maxX = -26, minZ = 14, maxZ = 27 },
}

Layout.eastWing = {
    laundry = { minX = 26, maxX = 38.5, minZ = -27, maxZ = 7 },
    passage = { minX = 26, maxX = 38.5, minZ = 7, maxZ = 13 },
    infirmary = { minX = 26, maxX = 38.5, minZ = 13, maxZ = 27 },
}

-- Ala norte: salas laterais + escadas + sala central ------------------------
Layout.northWing = {
    westRoom = { minX = -38.5, maxX = -22, minZ = -46, maxZ = -27 },
    westStair = { minX = -22, maxX = -6, minZ = -46, maxZ = -27 },
    centerRoom = { minX = -6, maxX = 6, minZ = -46, maxZ = -27 },
    eastStair = { minX = 6, maxX = 22, minZ = -46, maxZ = -27 },
    eastRoom = { minX = 22, maxX = 38.5, minZ = -46, maxZ = -27 },
}

-- Ala sul: entrada, visitas, triagem e salas administrativas ----------------
Layout.southWing = {
    westRoom = { minX = -38.5, maxX = -10, minZ = 27, maxZ = 36.5 },
    center = { minX = -10, maxX = 10, minZ = 27, maxZ = 36.5 },
    eastRoom = { minX = 10, maxX = 38.5, minZ = 27, maxZ = 36.5 },
}

-- Escadas ---------------------------------------------------------------
-- Cada caixa tem duas escadas paralelas de 5 studs e um corredor de 4 studs
-- no nível 1, que liga o patamar à ponte norte.
Layout.stairs = {
    west = {
        minX = -22,
        maxX = -6,
        minZ = -46,
        maxZ = -27,
        flightA = { minX = -22, maxX = -17 },
        flightB = { minX = -16, maxX = -11 },
        corridor = { minX = -10, maxX = -6 },
        groundDoor = { minX = -20, maxX = -8 },
        upperDoor = { minX = -9, maxX = -6 },
        levelTwoDoor = { minX = -16, maxX = -11 },
    },
    east = {
        minX = 6,
        maxX = 22,
        minZ = -46,
        maxZ = -27,
        flightA = { minX = 17, maxX = 22 },
        flightB = { minX = 11, maxX = 16 },
        corridor = { minX = 6, maxX = 10 },
        groundDoor = { minX = 8, maxX = 20 },
        upperDoor = { minX = 6, maxX = 9 },
        levelTwoDoor = { minX = 11, maxX = 16 },
    },
    steps = 20,
    run = 15,
    landingDepth = 4,
    width = 5,
}

-- Refeitório anexo -----------------------------------------------------------
Layout.refeitorio = {
    outer = { minX = -98, maxX = -40, minZ = -24, maxZ = 32 },
    inner = { minX = -96.5, maxX = -41.5, minZ = -22.5, maxZ = 30.5 },
    height = 20,
    roofHeight = 24,
}

-- Pátio e torre --------------------------------------------------------------
Layout.yard = {
    outer = { minX = 44, maxX = 110, minZ = -36, maxZ = 38 },
    inner = { minX = 45.5, maxX = 108.5, minZ = -34.5, maxZ = 36.5 },
    wallHeight = 15,
    gate = { minZ = 7, maxZ = 13 },
    tower = { minX = 94, maxX = 108.5, minZ = -34.5, maxZ = -20.5 },
}

-- Pátio de entrada -----------------------------------------------------------
Layout.forecourt = {
    minX = -36,
    maxX = 36,
    minZ = 38,
    maxZ = 58,
}

Layout.gate = {
    z = 60,
    minX = -12,
    maxX = 12,
    height = 12,
}

Layout.spawn = {
    position = Vector3.new(0, 0.55, 52),
    lookAt = Vector3.new(0, 5.5, 38),
}

function Layout.levelY(level: number): number
    return (level - 1) * Layout.floorHeight
end

function Layout.cellBounds(index: number): (number, number)
    local minZ = -27 + (index - 1) * Layout.cellWidth
    return minZ, minZ + Layout.cellWidth
end

function Layout.cellCenterZ(index: number): number
    local minZ = -27 + (index - 1) * Layout.cellWidth
    return minZ + Layout.cellWidth * 0.5
end

function Layout.cellNumber(side: string, level: number, index: number): number
    local base = if side == "west" then 100 elseif side == "east" then 107 else 0
    if level == 3 then
        base += 100
    end
    return base + index
end

Layout.areaCellHouseM2 = (80 * 84) / (Layout.studsPerMeter ^ 2)
Layout.areaRefeitorioM2 = (58 * 56) / (Layout.studsPerMeter ^ 2)
Layout.areaYardM2 = (66 * 74) / (Layout.studsPerMeter ^ 2)
Layout.areaSiteM2 = ((Layout.site.maxX - Layout.site.minX) * (Layout.site.maxZ - Layout.site.minZ))
    / (Layout.studsPerMeter ^ 2)

return Layout

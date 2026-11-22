local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Casca arquitetônica da Casa 27: piso, alvenaria, forro, esquadrias,
    molduras e o lanternim de teto. Tudo é construído a partir da planta em
    Layout.luau, sem depender de assets externos.
]]

local Kit = require("./Kit")
local Palette = require("./Palette")
local Layout = require("./Layout")

local Architecture = {}

local H = Layout.height
local T = Layout.wallThickness
local IT = Layout.innerWallThickness

local randomSeed = 2704
local function random01(): number
    randomSeed = (randomSeed * 1103515245 + 12345) % 2147483648
    return randomSeed / 2147483648
end

local function sortedOpenings(wall)
    local openings = table.clone(wall.openings or {})
    table.sort(openings, function(a, b)
        return a.from < b.from
    end)
    return openings
end

local function wallSpan(
    folder: Instance,
    wall,
    name: string,
    from: number,
    to: number,
    bottom: number,
    top: number
)
    local length = to - from
    local height = top - bottom
    if length <= 0.01 or height <= 0.01 then
        return
    end

    if wall.axis == "X" then
        Kit.box(
            folder,
            name,
            CFrame.new((from + to) * 0.5, (bottom + top) * 0.5, wall.center),
            Vector3.new(length, height, wall.thickness),
            Palette.Plaster,
            Palette.Materials.plaster
        )
    else
        Kit.box(
            folder,
            name,
            CFrame.new(wall.center, (bottom + top) * 0.5, (from + to) * 0.5),
            Vector3.new(wall.thickness, height, length),
            Palette.Plaster,
            Palette.Materials.plaster
        )
    end
end

local function buildWallBody(folder: Instance, wall, prefix: string)
    local openings = sortedOpenings(wall)
    local cursor = wall.from
    local index = 1

    for _, opening in openings do
        wallSpan(folder, wall, prefix .. " " .. index, cursor, opening.from, 0, H)
        index += 1
        if opening.bottom > 0.01 then
            wallSpan(folder, wall, prefix .. " peitoril " .. index, opening.from, opening.to, 0, opening.bottom)
        end
        if opening.top < H - 0.01 then
            wallSpan(folder, wall, prefix .. " verga " .. index, opening.from, opening.to, opening.top, H)
        end
        cursor = opening.to
        index += 1
    end
    wallSpan(folder, wall, prefix .. " " .. index, cursor, wall.to, 0, H)
end

local function trimStrip(
    folder: Instance,
    wall,
    side: number,
    from: number,
    to: number,
    centerY: number,
    height: number,
    depth: number,
    color: Color3,
    material: Enum.Material,
    name: string
)
    local length = to - from
    if length <= 0.02 then
        return
    end

    local offset = wall.thickness * 0.5 + depth * 0.5 - 0.012
    if wall.axis == "X" then
        Kit.box(
            folder,
            name,
            CFrame.new((from + to) * 0.5, centerY, wall.center + side * offset),
            Vector3.new(length, height, depth),
            color,
            material,
            { collide = false, query = false, shadow = false }
        )
    else
        Kit.box(
            folder,
            name,
            CFrame.new(wall.center + side * offset, centerY, (from + to) * 0.5),
            Vector3.new(depth, height, length),
            color,
            material,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function addWallTrim(folder: Instance, wall, side: number, includeBase: boolean?)
    local openings = sortedOpenings(wall)
    if includeBase ~= false then
        local cursor = wall.from
        local index = 1
        for _, opening in openings do
            if opening.kind == "door" and opening.bottom < 0.05 then
                trimStrip(
                    folder,
                    wall,
                    side,
                    cursor,
                    opening.from,
                    0.25,
                    0.5,
                    0.13,
                    Palette.Trim,
                    Palette.Materials.paint,
                    "Rodape " .. index
                )
                cursor = opening.to
                index += 1
            end
        end
        trimStrip(
            folder,
            wall,
            side,
            cursor,
            wall.to,
            0.25,
            0.5,
            0.13,
            Palette.Trim,
            Palette.Materials.paint,
            "Rodape " .. index
        )
    end

    trimStrip(
        folder,
        wall,
        side,
        wall.from,
        wall.to,
        H - 0.2,
        0.3,
        0.17,
        Palette.Trim,
        Palette.Materials.paint,
        "Coroa"
    )
end

local function addCurtains(folder: Instance, wall, opening)
    local side = wall.innerSign
    local faceOffset = wall.thickness * 0.5 + 0.5
    local width = opening.to - opening.from
    local mid = (opening.from + opening.to) * 0.5
    local rodY = opening.top + 0.55
    local topY = opening.top + 0.35
    local bottomY = 0.55
    local height = topY - bottomY
    local panelWidth = 1.25

    local function coords(along: number, heightOffset: number): CFrame
        if wall.axis == "X" then
            return CFrame.new(along, heightOffset, wall.center + side * faceOffset)
        end
        return CFrame.new(wall.center + side * faceOffset, heightOffset, along)
    end

    local rodSize
    if wall.axis == "X" then
        rodSize = Vector3.new(width + 2.2, 0.1, 0.1)
    else
        rodSize = Vector3.new(0.1, 0.1, width + 2.2)
    end
    Kit.box(
        folder,
        "Vara de cortina",
        coords(mid, rodY),
        rodSize,
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )

    for _, sign in { -1, 1 } do
        local finial = coords(mid + sign * (width * 0.5 + 1.1), rodY)
        Kit.sphere(
            folder,
            "Ponteira da vara",
            finial,
            Vector3.new(0.23, 0.23, 0.23),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )

        local panelCenter = mid + sign * (width * 0.5 - panelWidth * 0.35 + 0.45)
        for fold = 1, 5 do
            local along = panelCenter + (fold - 2.5) * (panelWidth / 6)
            local foldDepth = if fold % 2 == 0 then 0.05 else -0.055
            local panel = coords(along, bottomY + height * 0.5)
            if wall.axis == "X" then
                panel *= CFrame.new(0, 0, foldDepth)
            else
                panel *= CFrame.new(foldDepth, 0, 0)
            end
            Kit.box(
                folder,
                "Cortina " .. fold,
                panel,
                if wall.axis == "X"
                    then Vector3.new(panelWidth / 5.2, height, 0.1)
                    else Vector3.new(0.1, height, panelWidth / 5.2),
                if (fold + math.floor(random01() * 3)) % 3 == 0
                    then Palette.Linen
                    else Palette.LinenLight,
                Palette.Materials.fabric,
                { collide = false, query = false, shadow = false, transparency = 0.04 }
            )
        end
    end
end

local function addWindow(folder: Instance, wall, opening)
    local width = opening.to - opening.from
    local height = opening.top - opening.bottom
    local center = (opening.from + opening.to) * 0.5
    local centerY = (opening.top + opening.bottom) * 0.5
    local side = wall.innerSign
    local frameColor = Palette.Trim
    local exteriorColor = Palette.StoneDark

    local function at(along: number, y: number, depthOffset: number): CFrame
        if wall.axis == "X" then
            return CFrame.new(along, y, wall.center + depthOffset)
        end
        return CFrame.new(wall.center + depthOffset, y, along)
    end

    local glassColor = if opening.frosted then Palette.CeramicWhite else Palette.GlassClear
    local transparency = if opening.frosted then 0.55 else 0.8
    local glassSize = if wall.axis == "X"
        then Vector3.new(width - 0.22, height - 0.22, 0.06)
        else Vector3.new(0.06, height - 0.22, width - 0.22)

    Kit.box(
        folder,
        "Vidro",
        at(center, centerY, 0),
        glassSize,
        glassColor,
        Palette.Materials.glass,
        {
            collide = true,
            query = false,
            shadow = false,
            transparency = transparency,
            reflectance = 0.12,
        }
    )

    local barDepth = 0.16
    local frameParts = {
        { name = "Montante esquerdo", along = opening.from + 0.08, y = centerY, w = 0.18, h = height },
        { name = "Montante direito", along = opening.to - 0.08, y = centerY, w = 0.18, h = height },
        { name = "Travessa superior", along = center, y = opening.top - 0.09, w = width, h = 0.18 },
        { name = "Travessa inferior", along = center, y = opening.bottom + 0.09, w = width, h = 0.18 },
    }
    for _, bar in frameParts do
        Kit.box(
            folder,
            bar.name,
            at(bar.along, bar.y, 0),
            if wall.axis == "X" then Vector3.new(bar.w, bar.h, barDepth) else Vector3.new(barDepth, bar.h, bar.w),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    local columns = opening.mullions or 1
    for column = 1, columns do
        local along = opening.from + width * (column / (columns + 1))
        Kit.box(
            folder,
            "Bandeira vertical " .. column,
            at(along, centerY, 0),
            if wall.axis == "X" then Vector3.new(0.12, height - 0.24, 0.1)
            else Vector3.new(0.1, height - 0.24, 0.12),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        folder,
        "Bandeira horizontal",
        at(center, opening.bottom + height * 0.58, 0),
        if wall.axis == "X" then Vector3.new(width - 0.24, 0.1, 0.09)
        else Vector3.new(0.09, 0.1, width - 0.24),
        frameColor,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    local casingDepth = 0.12
    local faceOffset = side * (wall.thickness * 0.5 - 0.015)
    local sideOffset = wall.thickness * 0.5 + casingDepth * 0.5 - 0.03
    local interiorOffset = side * sideOffset

    if wall.axis == "X" then
        Kit.box(
            folder,
            "Casing esquerdo",
            CFrame.new(opening.from - 0.15, centerY + 0.08, wall.center + interiorOffset),
            Vector3.new(0.32, height + 0.45, casingDepth),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Casing direito",
            CFrame.new(opening.to + 0.15, centerY + 0.08, wall.center + interiorOffset),
            Vector3.new(0.32, height + 0.45, casingDepth),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Casing superior",
            CFrame.new(center, opening.top + 0.22, wall.center + interiorOffset),
            Vector3.new(width + 0.62, 0.34, casingDepth),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Peitoril",
            CFrame.new(center, opening.bottom - 0.12, wall.center + interiorOffset + side * 0.05),
            Vector3.new(width + 0.7, 0.2, 0.47),
            Palette.Marble,
            Palette.Materials.marble,
            { collide = false, query = false, shadow = false }
        )
    else
        Kit.box(
            folder,
            "Casing esquerdo",
            CFrame.new(wall.center + interiorOffset, centerY + 0.08, opening.from - 0.15),
            Vector3.new(casingDepth, height + 0.45, 0.32),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Casing direito",
            CFrame.new(wall.center + interiorOffset, centerY + 0.08, opening.to + 0.15),
            Vector3.new(casingDepth, height + 0.45, 0.32),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Casing superior",
            CFrame.new(wall.center + interiorOffset, opening.top + 0.22, center),
            Vector3.new(casingDepth, 0.34, width + 0.62),
            frameColor,
            Palette.Materials.paint,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Peitoril",
            CFrame.new(wall.center + interiorOffset + side * 0.05, opening.bottom - 0.12, center),
            Vector3.new(0.47, 0.2, width + 0.7),
            Palette.Marble,
            Palette.Materials.marble,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Acabamento externo mais escuro, visível pela janela.
    local outsideOffset = -side * sideOffset
    if wall.axis == "X" then
        Kit.box(
            folder,
            "Guarnicao externa",
            CFrame.new(center, opening.top + 0.2, wall.center + outsideOffset),
            Vector3.new(width + 0.55, 0.3, casingDepth),
            exteriorColor,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Peitoril externo",
            CFrame.new(center, opening.bottom - 0.09, wall.center + outsideOffset),
            Vector3.new(width + 0.5, 0.16, 0.35),
            Palette.Stone,
            Palette.Materials.slate,
            { collide = false, query = false, shadow = false }
        )
    else
        Kit.box(
            folder,
            "Guarnicao externa",
            CFrame.new(wall.center + outsideOffset, opening.top + 0.2, center),
            Vector3.new(casingDepth, 0.3, width + 0.55),
            exteriorColor,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Peitoril externo",
            CFrame.new(wall.center + outsideOffset, opening.bottom - 0.09, center),
            Vector3.new(0.35, 0.16, width + 0.5),
            Palette.Stone,
            Palette.Materials.slate,
            { collide = false, query = false, shadow = false }
        )
    end

    if opening.curtains then
        addCurtains(folder, wall, opening)
    end
end

local function addDoorFrame(folder: Instance, wall, opening)
    local width = opening.to - opening.from
    local center = (opening.from + opening.to) * 0.5
    local trimColor = Palette.Trim
    local depth = 0.14

    for _, side in { -1, 1 } do
        local surfaceOffset = wall.thickness * 0.5 + depth * 0.5 - 0.02
        local faceOffset = side * surfaceOffset
        if wall.axis == "X" then
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(opening.from - 0.14, opening.top * 0.5, wall.center + faceOffset),
                Vector3.new(0.3, opening.top + 0.12, depth),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(opening.to + 0.14, opening.top * 0.5, wall.center + faceOffset),
                Vector3.new(0.3, opening.top + 0.12, depth),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(center, opening.top + 0.17, wall.center + faceOffset),
                Vector3.new(width + 0.58, 0.32, depth),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
        else
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(wall.center + faceOffset, opening.top * 0.5, opening.from - 0.14),
                Vector3.new(depth, opening.top + 0.12, 0.3),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(wall.center + faceOffset, opening.top * 0.5, opening.to + 0.14),
                Vector3.new(depth, opening.top + 0.12, 0.3),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
            Kit.box(
                folder,
                "Guarnicao porta",
                CFrame.new(wall.center + faceOffset, opening.top + 0.17, center),
                Vector3.new(depth, 0.32, width + 0.58),
                trimColor,
                Palette.Materials.paint,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    -- Batentes internos do vão.
    if wall.axis == "X" then
        Kit.box(
            folder,
            "Batente",
            CFrame.new(opening.from + 0.08, opening.top * 0.5, wall.center),
            Vector3.new(0.16, opening.top, wall.thickness + 0.03),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Batente",
            CFrame.new(opening.to - 0.08, opening.top * 0.5, wall.center),
            Vector3.new(0.16, opening.top, wall.thickness + 0.03),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Batente superior",
            CFrame.new(center, opening.top - 0.08, wall.center),
            Vector3.new(width, 0.16, wall.thickness + 0.03),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    else
        Kit.box(
            folder,
            "Batente",
            CFrame.new(wall.center, opening.top * 0.5, opening.from + 0.08),
            Vector3.new(wall.thickness + 0.03, opening.top, 0.16),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Batente",
            CFrame.new(wall.center, opening.top * 0.5, opening.to - 0.08),
            Vector3.new(wall.thickness + 0.03, opening.top, 0.16),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
        Kit.box(
            folder,
            "Batente superior",
            CFrame.new(wall.center, opening.top - 0.08, center),
            Vector3.new(wall.thickness + 0.03, 0.16, width),
            Palette.TrimShadow,
            Palette.Materials.wood,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function buildWoodFloor(parent: Instance)
    local model = Kit.model(parent, "Piso de madeira")
    local minX, maxX = Layout.inner.minX, Layout.inner.maxX
    local minZ, maxZ = Layout.inner.minZ, Layout.inner.maxZ
    local plankWidth = 0.96
    local gap = 0.035

    local grout = Kit.box(
        model,
        "Subpiso",
        CFrame.new(0, -0.075, 0),
        Vector3.new(maxX - minX, 0.1, maxZ - minZ),
        Palette.WalnutDeep,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    grout.Name = "Fundo das frestas"

    Kit.box(
        model,
        "Piso físico",
        CFrame.new(0, -0.17, 0),
        Vector3.new(maxX - minX, 0.34, maxZ - minZ),
        Palette.Walnut,
        Palette.Materials.wood,
        { collide = true, query = false, shadow = false, transparency = 1 }
    )

    local tones = { Palette.Oak, Palette.OakLight, Palette.OakPale, Palette.OakDark }
    local rowCount = math.floor((maxZ - minZ) / plankWidth)
    local plankIndex = 1

    for row = 1, rowCount do
        local z = minZ + (row - 0.5) * plankWidth
        local x = minX - random01() * 2.8
        while x < maxX do
            local length = 4.2 + random01() * 3.3
            local startX = math.max(x, minX)
            local endX = math.min(x + length, maxX)
            if endX - startX > 0.5 then
                local tone = tones[(row + plankIndex) % #tones + 1]
                local variation = (random01() - 0.5) * 0.12
                Kit.box(
                    model,
                    "Tabua " .. plankIndex,
                    CFrame.new((startX + endX) * 0.5, -0.11 + random01() * 0.006, z),
                    Vector3.new(endX - startX - gap, 0.22, plankWidth - gap),
                    Kit.tint(tone, variation),
                    Palette.Materials.planks,
                    { collide = false, query = false, shadow = false }
                )
                plankIndex += 1
            end
            x += length + gap
        end
    end

    return model
end

local function buildBathroomFloor(parent: Instance)
    local model = Kit.model(parent, "Piso do banheiro")
    local b = Layout.bathroom
    local x1, x2 = b.minX + 0.08, b.maxX - 0.08
    local z1, z2 = b.minZ + 0.08, b.maxZ - 0.08

    Kit.box(
        model,
        "Contrapiso",
        CFrame.new((x1 + x2) * 0.5, 0.025, (z1 + z2) * 0.5),
        Vector3.new(x2 - x1, 0.07, z2 - z1),
        Palette.Grout,
        Palette.Materials.tile,
        { collide = false, query = false, shadow = false }
    )

    local tile = 1.42
    local gap = 0.055
    local nx = math.ceil((x2 - x1) / tile)
    local nz = math.ceil((z2 - z1) / tile)
    local cellX = (x2 - x1) / nx
    local cellZ = (z2 - z1) / nz

    for ix = 1, nx do
        for iz = 1, nz do
            local tint = (random01() - 0.5) * 0.12
            local base = if (ix + iz) % 3 == 0 then Palette.TileCream else Palette.SagePale
            Kit.box(
                model,
                "Pastilha",
                CFrame.new(x1 + (ix - 0.5) * cellX, 0.045, z1 + (iz - 0.5) * cellZ),
                Vector3.new(cellX - gap, 0.07, cellZ - gap),
                Kit.tint(base, tint),
                Palette.Materials.tile,
                {
                    collide = false,
                    query = false,
                    shadow = false,
                    reflectance = 0.04 + random01() * 0.04,
                }
            )
        end
    end

    Kit.box(
        model,
        "Soleira do banheiro",
        CFrame.new(-7.56, 0.055, 8.0),
        Vector3.new(0.75, 0.11, 2.65),
        Palette.Marble,
        Palette.Materials.marble,
        { collide = false, query = false, shadow = false }
    )

    return model
end

local function buildCeiling(parent: Instance)
    local model = Kit.model(parent, "Teto")
    local s = Layout.skylight
    local minX, maxX = Layout.inner.minX - 0.6, Layout.inner.maxX + 0.6
    local minZ, maxZ = Layout.inner.minZ - 0.6, Layout.inner.maxZ + 0.6
    local y = H + 0.22

    local function panel(name, x1, x2, z1, z2)
        Kit.box(
            model,
            name,
            CFrame.new((x1 + x2) * 0.5, y, (z1 + z2) * 0.5),
            Vector3.new(x2 - x1, 0.44, z2 - z1),
            Palette.CeilingPaint,
            Palette.Materials.plaster,
            { collide = true, query = true, shadow = true }
        )
    end

    panel("Forro oeste", minX, s.minX, minZ, maxZ)
    panel("Forro leste", s.maxX, maxX, minZ, maxZ)
    panel("Forro norte", s.minX, s.maxX, minZ, s.minZ)
    panel("Forro sul", s.minX, s.maxX, s.maxZ, maxZ)

    -- Poço de luz e caixilho do lanternim.
    local wood = Palette.OakDark
    local trimMaterial = Palette.Materials.wood
    local width = s.maxX - s.minX
    local depth = s.maxZ - s.minZ

    Kit.box(
        model,
        "Batente norte da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, H + 0.22, s.minZ + 0.14),
        Vector3.new(width + 0.28, 0.46, 0.28),
        wood,
        trimMaterial,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Batente sul da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, H + 0.22, s.maxZ - 0.14),
        Vector3.new(width + 0.28, 0.46, 0.28),
        wood,
        trimMaterial,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Batente oeste da claraboia",
        CFrame.new(s.minX + 0.14, H + 0.22, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(0.28, 0.46, depth),
        wood,
        trimMaterial,
        { collide = false, query = false }
    )
    Kit.box(
        model,
        "Batente leste da claraboia",
        CFrame.new(s.maxX - 0.14, H + 0.22, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(0.28, 0.46, depth),
        wood,
        trimMaterial,
        { collide = false, query = false }
    )

    Kit.box(
        model,
        "Poço da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, H + 0.47, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(width - 0.3, 0.08, depth - 0.3),
        Palette.CeilingPaint,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )

    -- Vidro e caixilho.
    local glass = Kit.box(
        model,
        "Vidro da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, s.glassY, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(width - 0.2, 0.07, depth - 0.2),
        Palette.GlassClear,
        Palette.Materials.glass,
        {
            collide = false,
            query = false,
            shadow = false,
            transparency = 0.79,
            reflectance = 0.1,
        }
    )
    for pin = 1, 3 do
        local along = s.minX + width * (pin / 4)
        Kit.box(
            model,
            "Caibro da claraboia",
            CFrame.new(along, s.glassY + 0.1, (s.minZ + s.maxZ) * 0.5),
            Vector3.new(0.12, 0.15, depth),
            Palette.Walnut,
            trimMaterial,
            { collide = false, query = false, shadow = false }
        )
    end
    Kit.box(
        model,
        "Travessa da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, s.glassY + 0.1, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(width, 0.15, 0.12),
        Palette.Walnut,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )

    -- Moldura aparente por baixo do forro.
    local reveal = 0.12
    Kit.box(
        model,
        "Moldura da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, H - 0.06, s.minZ + reveal),
        Vector3.new(width + 0.6, 0.16, reveal * 2),
        wood,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Moldura da claraboia",
        CFrame.new((s.minX + s.maxX) * 0.5, H - 0.06, s.maxZ - reveal),
        Vector3.new(width + 0.6, 0.16, reveal * 2),
        wood,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Moldura da claraboia",
        CFrame.new(s.minX + reveal, H - 0.06, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(reveal * 2, 0.16, depth),
        wood,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Moldura da claraboia",
        CFrame.new(s.maxX - reveal, H - 0.06, (s.minZ + s.maxZ) * 0.5),
        Vector3.new(reveal * 2, 0.16, depth),
        wood,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )

    Kit.spotLight(glass, Color3.fromRGB(255, 205, 149), {
        name = "Luz da claraboia",
        brightness = 1.15,
        range = 24,
        angle = 115,
        face = Enum.NormalId.Bottom,
        shadows = true,
    })

    -- Vigas do teto.
    local beamY = H - 0.34
    local beamHeight = 0.42
    Kit.box(
        model,
        "Viga do teto",
        CFrame.new(0, beamY, -3.45),
        Vector3.new(28.9, beamHeight, 0.48),
        Palette.Walnut,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Viga do teto",
        CFrame.new(10.5, beamY, 3.55),
        Vector3.new(7.4, beamHeight, 0.48),
        Palette.Walnut,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Viga do teto",
        CFrame.new(4.3, beamY, 0),
        Vector3.new(0.48, beamHeight, 20.3),
        Palette.Walnut,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )
    Kit.box(
        model,
        "Viga do teto",
        CFrame.new(-7.4, beamY, 6.9),
        Vector3.new(0.48, beamHeight, 6.7),
        Palette.Walnut,
        trimMaterial,
        { collide = false, query = false, shadow = false }
    )

    -- Detalhes técnicos.
    Kit.box(
        model,
        "Grelha de ventilação",
        CFrame.new(-3.0, H - 0.05, -8.35),
        Vector3.new(2.0, 0.08, 0.8),
        Palette.Enamel,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    for i = 1, 7 do
        Kit.box(
            model,
            "Aleta da grelha",
            CFrame.new(-3.0, H - 0.11, -8.68 + (i - 1) * 0.11),
            Vector3.new(1.82, 0.025, 0.035),
            Palette.SteelDark,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    Kit.cylinder(
        model,
        "Detector de fumaça",
        CFrame.new(1.0, H - 0.06, 6.5),
        0.12,
        0.72,
        Palette.CeramicWhite,
        Palette.Materials.paint,
        "y",
        { collide = false, query = false, shadow = false }
    )
    Kit.cylinder(
        model,
        "Led do detector",
        CFrame.new(1.0, H - 0.125, 6.66),
        0.03,
        0.075,
        Color3.fromRGB(165, 68, 54),
        Palette.Materials.neon,
        "y",
        { collide = false, query = false, shadow = false }
    )

    return model
end

function Architecture.build(parent: Instance)
    local root = Kit.model(parent, "Casa27")
    local structure = Kit.folder(root, "Estrutura")
    local floors = Kit.folder(structure, "Pisos")
    local outerWalls = Kit.folder(structure, "ParedesExternas")
    local innerWalls = Kit.folder(structure, "ParedesInternas")
    local windowFolder = Kit.folder(structure, "Janelas")
    local trims = Kit.folder(structure, "Molduras")

    -- Fundação, contrapiso e casca.
    Kit.box(
        structure,
        "Fundação",
        CFrame.new(0, -0.55, 0),
        Vector3.new(29.4, 1.0, 21.4),
        Palette.StoneDark,
        Palette.Materials.concrete,
        { collide = true, query = true }
    )
    Kit.box(
        structure,
        "Soleira externa",
        CFrame.new(0, -0.14, 0),
        Vector3.new(29.0, 0.28, 21.0),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = false, query = false, shadow = false }
    )

    buildWoodFloor(floors)
    buildBathroomFloor(floors)

    for _, wallName in { "back", "front", "left", "right" } do
        local wall = Layout.walls[wallName]
        local prefix = wall.name
        buildWallBody(outerWalls, wall, prefix)
        addWallTrim(trims, wall, wall.innerSign, true)

        for _, opening in sortedOpenings(wall) do
            if opening.kind == "window" then
                addWindow(windowFolder, wall, opening)
            elseif opening.kind == "door" then
                addDoorFrame(trims, wall, opening)
                if wallName == "front" then
                    Kit.box(
                        trims,
                        "Soleira da entrada",
                        CFrame.new(Layout.entryDoor.centerX, 0.075, Layout.entryDoor.z - 0.04),
                        Vector3.new(3.35, 0.15, 0.8),
                        Palette.Marble,
                        Palette.Materials.marble,
                        { collide = false, query = false, shadow = false }
                    )
                end
            end
        end
    end

    -- Banheiro: duas paredes internas, com porta de correr.
    local eastWall = {
        name = "Parede do banheiro",
        axis = "Z",
        center = Layout.bathroom.eastWall,
        from = 3.45,
        to = 10.25,
        thickness = IT,
        innerSign = 1,
        openings = {
            {
                name = "Porta do banheiro",
                kind = "door",
                from = Layout.bathroom.doorMinZ,
                to = Layout.bathroom.doorMaxZ,
                bottom = 0,
                top = Layout.bathroom.doorHeight,
            },
        },
    }
    local northWall = {
        name = "Parede norte do banheiro",
        axis = "X",
        center = Layout.bathroom.northWall,
        from = -14.25,
        to = -7.25,
        thickness = IT,
        innerSign = 1,
        openings = {},
    }

    buildWallBody(innerWalls, eastWall, eastWall.name)
    buildWallBody(innerWalls, northWall, northWall.name)
    addWallTrim(trims, eastWall, 1, true)
    addWallTrim(trims, eastWall, -1, true)
    addWallTrim(trims, northWall, -1, true)
    addWallTrim(trims, northWall, 1, false)
    addDoorFrame(trims, eastWall, eastWall.openings[1])

    Kit.box(
        trims,
        "Soleira do banheiro",
        CFrame.new(Layout.bathroom.eastWall, 0.06, 8.0),
        Vector3.new(0.72, 0.12, 2.7),
        Palette.Stone,
        Palette.Materials.slate,
        { collide = false, query = false, shadow = false }
    )

    buildCeiling(structure)

    return root
end

return Architecture

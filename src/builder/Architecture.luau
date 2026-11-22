local Compat = require("./Compat")
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local CFrame = Compat.CFrame
local Enum = Compat.Enum

local Kit = require("./Kit")
local Palette = require("./Palette")
local Layout = require("./Layout")
local Furniture = require("./Furniture")

--[[
    Casca arquitetônica do Presídio Central.
    Alvenaria de calcário, faixas de cantaria, janelas altas com grade,
    galerias de ferro em torno de um átrio de três pavimentos, escadas de
    serviço duplas e um refeitório anexo com lanternins.

    Só existem Parts retangulares. Não há cilindros, esferas, wedges nem
    malhas — nem na arquitetura, nem nas grades.
]]

local Architecture = {}

local L = Layout
local P = Palette
local M = P.Materials

-- Pastas estruturais ---------------------------------------------------------
local folders = {}

local function makeFolders(root: Instance)
    local structure = Kit.folder(root, "Estrutura")
    folders.structure = structure
    folders.floors = Kit.folder(structure, "Pisos")
    folders.outerWalls = Kit.folder(structure, "ParedesExternas")
    folders.innerWalls = Kit.folder(structure, "ParedesInternas")
    folders.ceilings = Kit.folder(structure, "Teto")
    folders.windows = Kit.folder(structure, "Janelas")
    folders.trim = Kit.folder(structure, "Molduras")
    folders.stairs = Kit.folder(structure, "Escadas")
    folders.frame = Kit.folder(structure, "Estrutura")
end

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

--[[
    Parede ao longo de X com vãos. Os vãos são retangulares e informados em
    coordenadas absolutas. A parede é preenchida abaixo, acima e entre eles.
]]
local function wallX(
    parent: Instance,
    name: string,
    zCenter: number,
    x1: number,
    x2: number,
    y1: number,
    y2: number,
    thickness: number,
    color: Color3,
    material: Enum.Material?,
    openings: { any }?,
    options: Kit.Options?
)
    local list = table.clone(openings or {})
    table.sort(list, function(a, b)
        return a.from < b.from
    end)
    local minZ = zCenter - thickness * 0.5
    local maxZ = zCenter + thickness * 0.5
    local cursor = x1
    local index = 1
    for _, opening in list do
        local from = math.max(opening.from, x1)
        local to = math.min(opening.to, x2)
        if from > cursor then
            box(
                parent,
                string.format("%s trecho %d", name, index),
                cursor,
                from,
                y1,
                y2,
                minZ,
                maxZ,
                color,
                material,
                options
            )
            index += 1
        end
        if opening.bottom > y1 then
            box(
                parent,
                string.format("%s peitoril %d", name, index),
                from,
                to,
                y1,
                math.min(opening.bottom, y2),
                minZ,
                maxZ,
                color,
                material,
                options
            )
        end
        if opening.top < y2 then
            box(
                parent,
                string.format("%s verga %d", name, index),
                from,
                to,
                math.max(opening.top, y1),
                y2,
                minZ,
                maxZ,
                color,
                material,
                options
            )
        end
        cursor = math.max(cursor, to)
        index += 1
    end
    if cursor < x2 then
        box(
            parent,
            string.format("%s trecho %d", name, index),
            cursor,
            x2,
            y1,
            y2,
            minZ,
            maxZ,
            color,
            material,
            options
        )
    end
end

local function wallZ(
    parent: Instance,
    name: string,
    xCenter: number,
    z1: number,
    z2: number,
    y1: number,
    y2: number,
    thickness: number,
    color: Color3,
    material: Enum.Material?,
    openings: { any }?,
    options: Kit.Options?
)
    local list = table.clone(openings or {})
    table.sort(list, function(a, b)
        return a.from < b.from
    end)
    local minX = xCenter - thickness * 0.5
    local maxX = xCenter + thickness * 0.5
    local cursor = z1
    local index = 1
    for _, opening in list do
        local from = math.max(opening.from, z1)
        local to = math.min(opening.to, z2)
        if from > cursor then
            box(
                parent,
                string.format("%s trecho %d", name, index),
                minX,
                maxX,
                y1,
                y2,
                cursor,
                from,
                color,
                material,
                options
            )
            index += 1
        end
        if opening.bottom > y1 then
            box(
                parent,
                string.format("%s peitoril %d", name, index),
                minX,
                maxX,
                y1,
                math.min(opening.bottom, y2),
                from,
                to,
                color,
                material,
                options
            )
        end
        if opening.top < y2 then
            box(
                parent,
                string.format("%s verga %d", name, index),
                minX,
                maxX,
                math.max(opening.top, y1),
                y2,
                from,
                to,
                color,
                material,
                options
            )
        end
        cursor = math.max(cursor, to)
        index += 1
    end
    if cursor < z2 then
        box(
            parent,
            string.format("%s trecho %d", name, index),
            minX,
            maxX,
            y1,
            y2,
            cursor,
            z2,
            color,
            material,
            options
        )
    end
end

-- Janelas -------------------------------------------------------------------
local function windowX(
    parent: Instance,
    name: string,
    zCenter: number,
    x1: number,
    x2: number,
    bottom: number,
    top: number,
    options: any?
)
    local o = options or {}
    local width = x2 - x1
    local height = top - bottom
    local midY = (bottom + top) * 0.5
    local glassColor = if o.frosted then P.GlassFrost else P.Glass
    local glassTransparency = if o.frosted then 0.38 else 0.55

    box(
        folders.windows,
        name .. " vidro",
        x1 + 0.18,
        x2 - 0.18,
        bottom + 0.18,
        top - 0.18,
        zCenter - 0.06,
        zCenter + 0.06,
        glassColor,
        M.glass,
        {
            transparency = glassTransparency,
            reflectance = 0.08,
            collide = false,
            query = false,
            shadow = false,
        }
    )
    local frameDepth = o.frameDepth or 0.34
    box(
        folders.windows,
        name .. " caixilho superior",
        x1 + 0.1,
        x2 - 0.1,
        top - 0.22,
        top - 0.02,
        zCenter - frameDepth * 0.5,
        zCenter + frameDepth * 0.5,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    box(
        folders.windows,
        name .. " caixilho inferior",
        x1 + 0.1,
        x2 - 0.1,
        bottom + 0.02,
        bottom + 0.22,
        zCenter - frameDepth * 0.5,
        zCenter + frameDepth * 0.5,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    for _, x in { x1 + 0.13, x2 - 0.23 } do
        box(
            folders.windows,
            name .. " montante lateral",
            x,
            x + 0.1,
            bottom,
            top,
            zCenter - frameDepth * 0.5,
            zCenter + frameDepth * 0.5,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    local panesX = o.panesX or 2
    for index = 1, panesX - 1 do
        local x = x1 + (width * index) / panesX - 0.05
        box(
            folders.windows,
            string.format("%s montante %d", name, index),
            x,
            x + 0.1,
            bottom,
            top,
            zCenter - frameDepth * 0.5,
            zCenter + frameDepth * 0.5,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    local panesY = o.panesY or 3
    for index = 1, panesY - 1 do
        local y = bottom + (height * index) / panesY - 0.05
        box(
            folders.windows,
            string.format("%s travessa %d", name, index),
            x1,
            x2,
            y,
            y + 0.1,
            zCenter - frameDepth * 0.5,
            zCenter + frameDepth * 0.5,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    box(
        folders.trim,
        name .. " peitoril",
        x1 - 0.55,
        x2 + 0.55,
        bottom - 0.32,
        bottom,
        zCenter - 0.85,
        zCenter + 0.85,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.trim,
        name .. " lintel",
        x1 - 0.6,
        x2 + 0.6,
        top,
        top + 0.46,
        zCenter - 0.7,
        zCenter + 0.7,
        P.StoneLight,
        M.stone,
        nil
    )
    for _, x in { x1 - 0.38, x2 + 0.03 } do
        box(
            folders.trim,
            name .. " ombreira",
            x,
            x + 0.35,
            bottom,
            top,
            zCenter - 0.55,
            zCenter + 0.55,
            P.Stone,
            M.stone,
            nil
        )
    end

    if o.bars then
        Kit.barsX(
            folders.windows,
            name .. " grade",
            x1 + 0.35,
            x2 - 0.35,
            midY,
            zCenter + 0.28,
            height - 0.45,
            1.05,
            P.Iron,
            M.iron,
            0.1,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.windows,
            name .. " travessa da grade",
            x1,
            x2,
            midY - 0.06,
            midY + 0.06,
            zCenter + 0.24,
            zCenter + 0.33,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function windowZ(
    parent: Instance,
    name: string,
    xCenter: number,
    z1: number,
    z2: number,
    bottom: number,
    top: number,
    options: any?
)
    local o = options or {}
    local width = z2 - z1
    local height = top - bottom
    local midY = (bottom + top) * 0.5
    local glassColor = if o.frosted then P.GlassFrost else P.Glass
    local glassTransparency = if o.frosted then 0.38 else 0.55

    box(
        folders.windows,
        name .. " vidro",
        xCenter - 0.06,
        xCenter + 0.06,
        bottom + 0.18,
        top - 0.18,
        z1 + 0.18,
        z2 - 0.18,
        glassColor,
        M.glass,
        {
            transparency = glassTransparency,
            reflectance = 0.08,
            collide = false,
            query = false,
            shadow = false,
        }
    )
    local frameDepth = o.frameDepth or 0.34
    box(
        folders.windows,
        name .. " caixilho superior",
        xCenter - frameDepth * 0.5,
        xCenter + frameDepth * 0.5,
        top - 0.22,
        top - 0.02,
        z1 + 0.1,
        z2 - 0.1,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    box(
        folders.windows,
        name .. " caixilho inferior",
        xCenter - frameDepth * 0.5,
        xCenter + frameDepth * 0.5,
        bottom + 0.02,
        bottom + 0.22,
        z1 + 0.1,
        z2 - 0.1,
        P.Iron,
        M.iron,
        { collide = false, query = false, shadow = false }
    )
    for _, z in { z1 + 0.13, z2 - 0.23 } do
        box(
            folders.windows,
            name .. " montante lateral",
            xCenter - frameDepth * 0.5,
            xCenter + frameDepth * 0.5,
            bottom,
            top,
            z,
            z + 0.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    local panesX = o.panesX or 2
    for index = 1, panesX - 1 do
        local z = z1 + (width * index) / panesX - 0.05
        box(
            folders.windows,
            string.format("%s montante %d", name, index),
            xCenter - frameDepth * 0.5,
            xCenter + frameDepth * 0.5,
            bottom,
            top,
            z,
            z + 0.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    local panesY = o.panesY or 3
    for index = 1, panesY - 1 do
        local y = bottom + (height * index) / panesY - 0.05
        box(
            folders.windows,
            string.format("%s travessa %d", name, index),
            xCenter - frameDepth * 0.5,
            xCenter + frameDepth * 0.5,
            y,
            y + 0.1,
            z1,
            z2,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    box(
        folders.trim,
        name .. " peitoril",
        xCenter - 0.85,
        xCenter + 0.85,
        bottom - 0.32,
        bottom,
        z1 - 0.55,
        z2 + 0.55,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.trim,
        name .. " lintel",
        xCenter - 0.7,
        xCenter + 0.7,
        top,
        top + 0.46,
        z1 - 0.6,
        z2 + 0.6,
        P.StoneLight,
        M.stone,
        nil
    )
    for _, z in { z1 - 0.38, z2 + 0.03 } do
        box(
            folders.trim,
            name .. " ombreira",
            xCenter - 0.55,
            xCenter + 0.55,
            bottom,
            top,
            z,
            z + 0.35,
            P.Stone,
            M.stone,
            nil
        )
    end

    if o.bars then
        Kit.barsZ(
            folders.windows,
            name .. " grade",
            z1 + 0.35,
            z2 - 0.35,
            midY,
            xCenter + 0.28,
            height - 0.45,
            1.05,
            P.Iron,
            M.iron,
            0.1,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.windows,
            name .. " travessa da grade",
            xCenter + 0.24,
            xCenter + 0.33,
            midY - 0.06,
            midY + 0.06,
            z1,
            z2,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
end

-- Portas --------------------------------------------------------------------
local function doorCasingX(
    parent: Instance,
    name: string,
    zCenter: number,
    x1: number,
    x2: number,
    bottom: number,
    top: number,
    thickness: number,
    color: Color3,
    material: Enum.Material?
)
    box(
        parent,
        name .. " ombreira esquerda",
        x1 - 0.32,
        x1 + 0.04,
        bottom,
        top + 0.3,
        zCenter - thickness * 0.5 - 0.12,
        zCenter + thickness * 0.5 + 0.12,
        color,
        material,
        nil
    )
    box(
        parent,
        name .. " ombreira direita",
        x2 - 0.04,
        x2 + 0.32,
        bottom,
        top + 0.3,
        zCenter - thickness * 0.5 - 0.12,
        zCenter + thickness * 0.5 + 0.12,
        color,
        material,
        nil
    )
    box(
        parent,
        name .. " padieira",
        x1 - 0.32,
        x2 + 0.32,
        top,
        top + 0.38,
        zCenter - thickness * 0.5 - 0.12,
        zCenter + thickness * 0.5 + 0.12,
        color,
        material,
        nil
    )
end

local function doorCasingZ(
    parent: Instance,
    name: string,
    xCenter: number,
    z1: number,
    z2: number,
    bottom: number,
    top: number,
    thickness: number,
    color: Color3,
    material: Enum.Material?
)
    box(
        parent,
        name .. " ombreira norte",
        xCenter - thickness * 0.5 - 0.12,
        xCenter + thickness * 0.5 + 0.12,
        bottom,
        top + 0.3,
        z1 - 0.32,
        z1 + 0.04,
        color,
        material,
        nil
    )
    box(
        parent,
        name .. " ombreira sul",
        xCenter - thickness * 0.5 - 0.12,
        xCenter + thickness * 0.5 + 0.12,
        bottom,
        top + 0.3,
        z2 - 0.04,
        z2 + 0.32,
        color,
        material,
        nil
    )
    box(
        parent,
        name .. " padieira",
        xCenter - thickness * 0.5 - 0.12,
        xCenter + thickness * 0.5 + 0.12,
        top,
        top + 0.38,
        z1 - 0.32,
        z2 + 0.32,
        color,
        material,
        nil
    )
end

--[[
    Porta dupla ou simples, com folhas abertas contra a parede. A folha é
    sempre retangular e usa almofadas em relevo, sem quaisquer formas curvas.
]]
local function doorX(
    parent: Instance,
    name: string,
    zCenter: number,
    x1: number,
    x2: number,
    bottom: number,
    top: number,
    thickness: number,
    options: any?
)
    local o = options or {}
    local color = o.color or P.GreenDark
    local casingColor = o.casingColor or P.StoneLight
    local casingMaterial = o.casingMaterial or M.stone
    local swing = o.swing or -1
    local height = top - bottom
    doorCasingX(parent, name, zCenter, x1, x2, bottom, top, thickness, casingColor, casingMaterial)

    local leaves = if o.double then 2 else 1
    local width = x2 - x1
    local leafWidth = width / leaves
    local leafDepth = if o.closed then 0.28 else leafWidth

    for index = 1, leaves do
        local hingeX = if index == 1 then x1 + 0.1 else x2 - 0.1
        local direction = if index == 1 then 1 else -1
        local leafCenterX = if o.closed
            then x1 + leafWidth * (index - 0.5)
            else hingeX - direction * leafWidth * 0.5
        local leafCenterZ = if o.closed then zCenter else zCenter + swing * 0.2

        local leafSizeX = leafWidth - 0.15
        local leafSizeZ = 0.24
        box(
            parent,
            string.format("%s folha %d", name, index),
            leafCenterX - leafSizeX * 0.5,
            leafCenterX + leafSizeX * 0.5,
            bottom + 0.1,
            top - 0.1,
            leafCenterZ - leafSizeZ * 0.5,
            leafCenterZ + leafSizeZ * 0.5,
            color,
            o.material or M.wood,
            nil
        )

        -- almofadas em relevo nas duas faces úteis
        local panelHeight = height * 0.24
        for panel = 1, 2 do
            local panelY = bottom + 1.2 + (panel - 1) * (height * 0.34)
            local panelX = leafCenterX
            local panelZ = leafCenterZ
            local sizeX = leafWidth * 0.58
            local sizeZ = 0.08
            box(
                parent,
                string.format("%s almofada %d-%d", name, index, panel),
                panelX - sizeX * 0.5,
                panelX + sizeX * 0.5,
                panelY,
                panelY + panelHeight,
                panelZ - sizeZ * 0.5,
                panelZ + sizeZ * 0.5,
                Kit.tint(color, 0.09),
                o.material or M.wood,
                { collide = false, query = false, shadow = false }
            )
        end

        local handleZ = if o.closed then zCenter + 0.2 else zCenter + swing * 0.35
        local handleX = if o.closed
            then if index == 1 then x2 - 0.75 else x1 + 0.75
            else hingeX - direction * (leafWidth - 0.4)
        box(
            parent,
            string.format("%s puxador %d", name, index),
            handleX - 0.16,
            handleX + 0.16,
            bottom + height * 0.48,
            bottom + height * 0.48 + 0.5,
            handleZ - 0.16,
            handleZ + 0.16,
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end

    if o.transom then
        box(
            folders.windows,
            name .. " bandeira",
            x1 + 0.2,
            x2 - 0.2,
            top - 0.15,
            top + 1.35,
            zCenter - 0.05,
            zCenter + 0.05,
            P.GlassFrost,
            M.glass,
            { transparency = 0.4, collide = false, query = false, shadow = false }
        )
    end
end

local function doorZ(
    parent: Instance,
    name: string,
    xCenter: number,
    z1: number,
    z2: number,
    bottom: number,
    top: number,
    thickness: number,
    options: any?
)
    local o = options or {}
    local color = o.color or P.GreenDark
    local casingColor = o.casingColor or P.StoneLight
    local casingMaterial = o.casingMaterial or M.stone
    local swing = o.swing or 1
    local height = top - bottom
    doorCasingZ(parent, name, xCenter, z1, z2, bottom, top, thickness, casingColor, casingMaterial)

    local leaves = if o.double then 2 else 1
    local width = z2 - z1
    local leafWidth = width / leaves
    local leafDepth = if o.closed then 0.28 else leafWidth

    for index = 1, leaves do
        local hingeZ = if index == 1 then z1 + 0.1 else z2 - 0.1
        local direction = if index == 1 then 1 else -1
        local leafCenterZ = if o.closed
            then z1 + leafWidth * (index - 0.5)
            else hingeZ - direction * leafWidth * 0.5
        local leafCenterX = if o.closed then xCenter else xCenter + swing * 0.2

        local leafSizeZ = leafWidth - 0.15
        local leafSizeX = 0.24
        box(
            parent,
            string.format("%s folha %d", name, index),
            leafCenterX - leafSizeX * 0.5,
            leafCenterX + leafSizeX * 0.5,
            bottom + 0.1,
            top - 0.1,
            leafCenterZ - leafSizeZ * 0.5,
            leafCenterZ + leafSizeZ * 0.5,
            color,
            o.material or M.wood,
            nil
        )

        local panelHeight = height * 0.24
        for panel = 1, 2 do
            local panelY = bottom + 1.2 + (panel - 1) * (height * 0.34)
            local sizeZ = leafWidth * 0.58
            local sizeX = 0.08
            box(
                parent,
                string.format("%s almofada %d-%d", name, index, panel),
                leafCenterX - sizeX * 0.5,
                leafCenterX + sizeX * 0.5,
                panelY,
                panelY + panelHeight,
                leafCenterZ - sizeZ * 0.5,
                leafCenterZ + sizeZ * 0.5,
                Kit.tint(color, 0.09),
                o.material or M.wood,
                { collide = false, query = false, shadow = false }
            )
        end

        local handleX = if o.closed then xCenter + 0.2 else xCenter + swing * 0.35
        local handleZ = if o.closed
            then if index == 1 then z2 - 0.75 else z1 + 0.75
            else hingeZ - direction * (leafWidth - 0.4)
        box(
            parent,
            string.format("%s puxador %d", name, index),
            handleX - 0.16,
            handleX + 0.16,
            bottom + height * 0.48,
            bottom + height * 0.48 + 0.5,
            handleZ - 0.16,
            handleZ + 0.16,
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    end
end

-- Pisos e lajes --------------------------------------------------------------
local function slab(
    parent: Instance,
    name: string,
    minX: number,
    maxX: number,
    minZ: number,
    maxZ: number,
    topY: number,
    thickness: number,
    color: Color3?,
    material: Enum.Material?
)
    box(
        parent,
        name,
        minX,
        maxX,
        topY - thickness,
        topY,
        minZ,
        maxZ,
        color or P.Terrazzo,
        material or M.concrete,
        nil
    )
end

local function buildFloors()
    -- Embasamento geral.
    box(
        folders.floors,
        "Embasamento do edifício",
        L.outer.minX - 0.8,
        L.outer.maxX + 0.8,
        -1.6,
        0,
        L.outer.minZ - 0.8,
        L.outer.maxZ + 0.8,
        P.StoneDark,
        M.stoneBlock,
        nil
    )
    -- Piso térreo.
    box(
        folders.floors,
        "Piso do térreo",
        L.inner.minX,
        L.inner.maxX,
        -0.6,
        0,
        L.inner.minZ,
        L.inner.maxZ,
        P.Terrazzo,
        M.concrete,
        nil
    )

    for level = 2, 3 do
        local y = L.levelY(level)
        local label = if level == 2 then "primeiro pavimento" else "segundo pavimento"
        slab(
            folders.floors,
            "Laje oeste — " .. label,
            -38.5,
            -18,
            -27,
            27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Laje leste — " .. label,
            18,
            38.5,
            -27,
            27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ponte norte — " .. label,
            -18,
            18,
            -27,
            -20,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ponte sul — " .. label,
            -18,
            18,
            20,
            27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ala norte oeste — " .. label,
            -38.5,
            -22,
            -46,
            -27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ala norte central — " .. label,
            -6,
            6,
            -46,
            -27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ala norte leste — " .. label,
            22,
            38.5,
            -46,
            -27,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )
        slab(
            folders.floors,
            "Ala sul — " .. label,
            -38.5,
            38.5,
            27,
            36.5,
            y,
            0.8,
            P.Terrazzo,
            M.concrete
        )

        if level == 2 then
            slab(
                folders.floors,
                "Patamar da escada oeste",
                -22,
                -6,
                -46,
                -42,
                y,
                0.8,
                P.Stone,
                M.stone
            )
            slab(
                folders.floors,
                "Patamar da escada leste",
                6,
                22,
                -46,
                -42,
                y,
                0.8,
                P.Stone,
                M.stone
            )
            slab(
                folders.floors,
                "Corredor da escada oeste",
                -10,
                -6,
                -42,
                -27,
                y,
                0.8,
                P.Stone,
                M.stone
            )
            slab(
                folders.floors,
                "Corredor da escada leste",
                6,
                10,
                -42,
                -27,
                y,
                0.8,
                P.Stone,
                M.stone
            )
        end
    end
end

-- Paredes externas -----------------------------------------------------------
local function southFacadeLevel(level: number)
    local y0 = L.levelY(level)
    local y1 = if level == 3 then L.roofY else y0 + L.floorHeight
    local z = (L.outer.maxZ + L.inner.maxZ) * 0.5
    local openings = {}
    local windows = {}

    if level == 1 then
        for _, center in { -30, -20, 20, 30 } do
            table.insert(
                openings,
                { from = center - 2.8, to = center + 2.8, bottom = 2.8, top = 9.6 }
            )
            table.insert(
                windows,
                { center = center, half = 2.8, bottom = 2.8, top = 9.6, bars = true }
            )
        end
        table.insert(openings, { from = -6, to = 6, bottom = 0, top = 10.5 })
    else
        for _, center in { -30, -20, -10, 0, 10, 20, 30 } do
            table.insert(openings, {
                from = center - 2.2,
                to = center + 2.2,
                bottom = y0 + 3.0,
                top = y0 + 10.2,
            })
            table.insert(windows, {
                center = center,
                half = 2.2,
                bottom = y0 + 3.0,
                top = y0 + 10.2,
                bars = false,
            })
        end
    end

    wallX(
        folders.outerWalls,
        "Fachada sul — nível " .. level,
        z,
        L.outer.minX,
        L.outer.maxX,
        y0,
        y1,
        L.wallThickness,
        P.Stone,
        M.stone,
        openings,
        nil
    )
    for index, spec in windows do
        windowX(
            folders.windows,
            string.format("Janela sul %d-%d", level, index),
            z,
            spec.center - spec.half,
            spec.center + spec.half,
            spec.bottom,
            spec.top,
            { bars = spec.bars, panesX = 2, panesY = 3 }
        )
    end
    if level == 1 then
        doorX(folders.outerWalls, "Porta principal", z, -6, 6, 0, 10.5, L.wallThickness, {
            double = true,
            transom = true,
            color = P.Walnut,
            casingColor = P.StoneLight,
            casingMaterial = M.stone,
            swing = -1,
        })
    end
end

local function northFacadeLevel(level: number)
    local y0 = L.levelY(level)
    local y1 = if level == 3 then L.roofY else y0 + L.floorHeight
    local z = (L.outer.minZ + L.inner.minZ) * 0.5
    local openings = {}
    local windows = {}
    for _, center in { -32, -14, 0, 14, 32 } do
        table.insert(openings, {
            from = center - 2.2,
            to = center + 2.2,
            bottom = y0 + 3.8,
            top = y0 + 10.4,
        })
        table.insert(windows, {
            center = center,
            half = 2.2,
            bottom = y0 + 3.8,
            top = y0 + 10.4,
        })
    end
    wallX(
        folders.outerWalls,
        "Fachada norte — nível " .. level,
        z,
        L.outer.minX,
        L.outer.maxX,
        y0,
        y1,
        L.wallThickness,
        P.Stone,
        M.stone,
        openings,
        nil
    )
    for index, spec in windows do
        windowX(
            folders.windows,
            string.format("Janela norte %d-%d", level, index),
            z,
            spec.center - spec.half,
            spec.center + spec.half,
            spec.bottom,
            spec.top,
            { bars = level == 1, panesX = 2, panesY = 3 }
        )
    end
end

local function eastFacadeLevel(level: number)
    local y0 = L.levelY(level)
    local y1 = if level == 3 then L.roofY else y0 + L.floorHeight
    local x = (L.outer.maxX + L.inner.maxX) * 0.5
    local openings = {}
    local windows = {}

    if level == 1 then
        for _, spec in
            {
                { center = -18, half = 2.4, bottom = 5.0, top = 10.2 },
                { center = 20, half = 2.2, bottom = 4.4, top = 10.2, frosted = true },
                { center = -36, half = 2.0, bottom = 3.8, top = 10.0 },
                { center = 34.5, half = 1.8, bottom = 3.2, top = 10.0 },
            }
        do
            table.insert(openings, {
                from = spec.center - spec.half,
                to = spec.center + spec.half,
                bottom = spec.bottom,
                top = spec.top,
            })
            table.insert(windows, spec)
        end
        table.insert(openings, { from = 7, to = 13, bottom = 0, top = 10.0 })
    else
        for index = 1, L.cellCount do
            local center = L.cellCenterZ(index)
            table.insert(openings, {
                from = center - 1.6,
                to = center + 1.6,
                bottom = y0 + 8.5,
                top = y0 + 11.4,
            })
            table.insert(windows, {
                center = center,
                half = 1.6,
                bottom = y0 + 8.5,
                top = y0 + 11.4,
                bars = true,
                cell = true,
            })
        end
        for _, spec in
            {
                { center = -36, half = 2.0, bottom = y0 + 3.8, top = y0 + 10.0 },
                { center = 34.5, half = 1.8, bottom = y0 + 3.2, top = y0 + 10.0 },
            }
        do
            table.insert(openings, {
                from = spec.center - spec.half,
                to = spec.center + spec.half,
                bottom = spec.bottom,
                top = spec.top,
            })
            table.insert(windows, spec)
        end
    end

    wallZ(
        folders.outerWalls,
        "Fachada leste — nível " .. level,
        x,
        L.outer.minZ,
        L.outer.maxZ,
        y0,
        y1,
        L.wallThickness,
        P.Stone,
        M.stone,
        openings,
        nil
    )
    for index, spec in windows do
        windowZ(
            folders.windows,
            string.format("Janela leste %d-%d", level, index),
            x,
            spec.center - spec.half,
            spec.center + spec.half,
            spec.bottom,
            spec.top,
            {
                bars = spec.bars,
                frosted = spec.frosted,
                panesX = if spec.cell then 2 else 2,
                panesY = 3,
            }
        )
    end
    if level == 1 then
        doorZ(folders.outerWalls, "Portão do pátio", x, 7, 13, 0, 10.0, L.wallThickness, {
            double = true,
            color = P.Iron,
            material = M.iron,
            casingColor = P.StoneDark,
            swing = 1,
        })
    end
end

local function westFacadeLevel(level: number)
    local y0 = L.levelY(level)
    local y1 = if level == 3 then L.roofY else y0 + L.floorHeight
    local x = (L.outer.minX + L.inner.minX) * 0.5
    local openings = {}
    local windows = {}

    if level == 1 then
        for _, spec in
            {
                { center = -36, half = 2.0, bottom = 3.8, top = 10.0 },
                { center = 34.5, half = 1.8, bottom = 3.2, top = 10.0 },
            }
        do
            table.insert(openings, {
                from = spec.center - spec.half,
                to = spec.center + spec.half,
                bottom = spec.bottom,
                top = spec.top,
            })
            table.insert(windows, spec)
        end
        -- Vão de passagem para o refeitório e janela de serviço.
        table.insert(openings, { from = 8, to = 14, bottom = 0, top = 10.0 })
        table.insert(openings, { from = 0, to = 4, bottom = 3.4, top = 6.4 })
    else
        for index = 1, L.cellCount do
            local center = L.cellCenterZ(index)
            table.insert(openings, {
                from = center - 1.6,
                to = center + 1.6,
                bottom = y0 + 8.5,
                top = y0 + 11.4,
            })
            table.insert(windows, {
                center = center,
                half = 1.6,
                bottom = y0 + 8.5,
                top = y0 + 11.4,
                bars = true,
                cell = true,
            })
        end
        for _, spec in
            {
                { center = -36, half = 2.0, bottom = y0 + 3.8, top = y0 + 10.0 },
                { center = 34.5, half = 1.8, bottom = y0 + 3.2, top = y0 + 10.0 },
            }
        do
            table.insert(openings, {
                from = spec.center - spec.half,
                to = spec.center + spec.half,
                bottom = spec.bottom,
                top = spec.top,
            })
            table.insert(windows, spec)
        end
    end

    wallZ(
        folders.outerWalls,
        "Fachada oeste — nível " .. level,
        x,
        L.outer.minZ,
        L.outer.maxZ,
        y0,
        y1,
        L.wallThickness,
        P.Stone,
        M.stone,
        openings,
        nil
    )
    for index, spec in windows do
        windowZ(
            folders.windows,
            string.format("Janela oeste %d-%d", level, index),
            x,
            spec.center - spec.half,
            spec.center + spec.half,
            spec.bottom,
            spec.top,
            { bars = spec.bars, panesX = 2, panesY = 3 }
        )
    end
    if level == 1 then
        doorZ(folders.outerWalls, "Porta do refeitório", x, 8, 14, 0, 10.0, L.wallThickness, {
            double = true,
            color = P.GreenDark,
            casingColor = P.StoneLight,
            swing = -1,
        })
        box(
            folders.trim,
            "Bancada de serviço do refeitório",
            x - 0.55,
            x + 0.55,
            3.15,
            3.4,
            0.2,
            3.8,
            P.SteelLight,
            M.steel,
            nil
        )
    end
end

local function buildOuterWalls()
    for level = 1, 3 do
        southFacadeLevel(level)
        northFacadeLevel(level)
        eastFacadeLevel(level)
        westFacadeLevel(level)
    end
end

-- Partições internas ---------------------------------------------------------
local function upperFloorRoomPartitions(level: number)
    local y0 = L.levelY(level)
    local y1 = y0 + L.floorHeight

    -- Parede entre o átrio e a ala norte.
    local northOpenings = {
        { from = -26, to = -22, bottom = y0, top = y0 + 10.0 },
        { from = -4, to = 4, bottom = y0, top = y0 + 10.0 },
        { from = 22, to = 26, bottom = y0, top = y0 + 10.0 },
    }
    if level == 2 then
        table.insert(northOpenings, { from = -9, to = -6, bottom = y0, top = y0 + 10.0 })
        table.insert(northOpenings, { from = 6, to = 9, bottom = y0, top = y0 + 10.0 })
    else
        table.insert(northOpenings, { from = -16, to = -11, bottom = y0, top = y0 + 10.0 })
        table.insert(northOpenings, { from = 11, to = 16, bottom = y0, top = y0 + 10.0 })
    end
    wallX(
        folders.innerWalls,
        "Parede norte do átrio — nível " .. level,
        -27.3,
        -38.5,
        38.5,
        y0,
        y1,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        northOpenings,
        nil
    )

    -- Parede entre o átrio e a ala sul.
    local southOpenings = {
        { from = -18, to = -12, bottom = y0, top = y0 + 10.0 },
        { from = -4, to = 4, bottom = y0, top = y0 + 10.0 },
        { from = 12, to = 18, bottom = y0, top = y0 + 10.0 },
    }
    wallX(
        folders.innerWalls,
        "Parede sul do átrio — nível " .. level,
        27.3,
        -38.5,
        38.5,
        y0,
        y1,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        southOpenings,
        nil
    )

    -- Divisórias das salas da ala sul.
    wallZ(
        folders.innerWalls,
        "Divisória oeste da ala sul — nível " .. level,
        -10,
        27,
        36.5,
        y0,
        y1,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        nil,
        nil
    )
    wallZ(
        folders.innerWalls,
        "Divisória leste da ala sul — nível " .. level,
        10,
        27,
        36.5,
        y0,
        y1,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        nil,
        nil
    )

    -- Caixas de escada e sala central da ala norte.
    for _, x in { -22, -6, 6, 22 } do
        wallZ(
            folders.innerWalls,
            string.format("Parede da caixa de escada x=%.0f — nível %d", x, level),
            x,
            -46,
            -27,
            y0,
            y1,
            L.innerWallThickness,
            P.Paint,
            M.plaster,
            nil,
            nil
        )
    end

    -- Portas de acesso às salas e às galerias.
    doorX(
        folders.innerWalls,
        string.format("Porta da biblioteca — nível %d", level),
        -27.3,
        -26,
        -22,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { color = P.GreenDark, swing = -1 }
    )
    doorX(
        folders.innerWalls,
        string.format("Porta da sala norte leste — nível %d", level),
        -27.3,
        22,
        26,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { color = P.GreenDark, swing = 1 }
    )
    doorX(
        folders.innerWalls,
        string.format("Porta da sala central norte — nível %d", level),
        -27.3,
        -4,
        4,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = -1 }
    )
    doorX(
        folders.innerWalls,
        string.format("Porta oeste do pavimento — nível %d", level),
        27.3,
        -18,
        -12,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )
    doorX(
        folders.innerWalls,
        string.format("Porta central do pavimento — nível %d", level),
        27.3,
        -4,
        4,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )
    doorX(
        folders.innerWalls,
        string.format("Porta leste do pavimento — nível %d", level),
        27.3,
        12,
        18,
        y0,
        y0 + 10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )
end

local function groundFloorPartitions()
    local y0 = 0
    local y1 = 13

    -- Parede leste/oeste entre hall e alas de serviço.
    local westOpenings = {
        { from = -22, to = -16, bottom = 0, top = 10.0 },
        { from = 8, to = 14, bottom = 0, top = 10.0 },
        { from = 18, to = 24, bottom = 0, top = 10.0 },
    }
    wallZ(
        folders.innerWalls,
        "Parede da cozinha",
        -26,
        -27,
        27,
        y0,
        y1,
        L.innerWallThickness,
        P.TileWhite,
        M.plaster,
        westOpenings,
        nil
    )
    doorZ(
        folders.innerWalls,
        "Porta da cozinha",
        -26,
        -22,
        -16,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )
    doorZ(
        folders.innerWalls,
        "Porta da copa",
        -26,
        18,
        24,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )

    local eastOpenings = {
        { from = -20, to = -14, bottom = 0, top = 10.0 },
        { from = 7, to = 13, bottom = 0, top = 10.0 },
        { from = 18, to = 24, bottom = 0, top = 10.0 },
    }
    wallZ(
        folders.innerWalls,
        "Parede da lavanderia",
        26,
        -27,
        27,
        y0,
        y1,
        L.innerWallThickness,
        P.TileWhite,
        M.plaster,
        eastOpenings,
        nil
    )
    doorZ(
        folders.innerWalls,
        "Porta da lavanderia",
        26,
        -20,
        -14,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = -1 }
    )
    doorZ(
        folders.innerWalls,
        "Porta da enfermaria",
        26,
        18,
        24,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = -1 }
    )

    -- Divisórias cozinha/copa e lavanderia/enfermaria.
    for _, spec in
        {
            { z = 8, name = "cozinha" },
            { z = 14, name = "copa" },
        }
    do
        wallX(
            folders.innerWalls,
            "Divisória da " .. spec.name,
            spec.z,
            -38.5,
            -26,
            0,
            13,
            L.innerWallThickness,
            P.TileWhite,
            M.plaster,
            { { from = -34, to = -30, bottom = 0, top = 10.0 } },
            nil
        )
        doorX(
            folders.innerWalls,
            "Porta da divisória da " .. spec.name,
            spec.z,
            -34,
            -30,
            0,
            10.0,
            L.innerWallThickness,
            { color = P.GreenDark, swing = if spec.z == 8 then -1 else 1 }
        )
    end
    for _, spec in
        {
            { z = 7, name = "lavanderia" },
            { z = 13, name = "enfermaria" },
        }
    do
        wallX(
            folders.innerWalls,
            "Divisória da " .. spec.name,
            spec.z,
            26,
            38.5,
            0,
            13,
            L.innerWallThickness,
            P.TileWhite,
            M.plaster,
            { { from = 30, to = 34, bottom = 0, top = 10.0 } },
            nil
        )
        doorX(
            folders.innerWalls,
            "Porta da divisória da " .. spec.name,
            spec.z,
            30,
            34,
            0,
            10.0,
            L.innerWallThickness,
            { color = P.GreenDark, swing = if spec.z == 7 then -1 else 1 }
        )
    end

    -- Ala sul: visitas, entrada e triagem.
    local southOpenings = {
        { from = -24, to = -18, bottom = 0, top = 10.0 },
        { from = -6, to = 6, bottom = 0, top = 10.0 },
        { from = 18, to = 24, bottom = 0, top = 10.0 },
    }
    wallX(
        folders.innerWalls,
        "Parede sul do hall",
        27.3,
        -38.5,
        38.5,
        y0,
        y1,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        southOpenings,
        nil
    )
    doorX(
        folders.innerWalls,
        "Porta das visitas",
        27.3,
        -24,
        -18,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )
    doorX(
        folders.innerWalls,
        "Porta interna da entrada",
        27.3,
        -6,
        6,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.Walnut, swing = 1 }
    )
    doorX(
        folders.innerWalls,
        "Porta da triagem",
        27.3,
        18,
        24,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = 1 }
    )

    for _, x in { -10, 10 } do
        wallZ(
            folders.innerWalls,
            string.format("Divisória da ala sul x=%.0f", x),
            x,
            27,
            36.5,
            0,
            13,
            L.innerWallThickness,
            P.Paint,
            M.plaster,
            { { from = 31, to = 35, bottom = 0, top = 10.0 } },
            nil
        )
        doorZ(
            folders.innerWalls,
            string.format("Porta da ala sul x=%.0f", x),
            x,
            31,
            35,
            0,
            10.0,
            L.innerWallThickness,
            { color = P.GreenDark, swing = if x == -10 then -1 else 1 }
        )
    end

    -- Cela de triagem: duas celas curtas ao fundo da sala.
    wallX(
        folders.innerWalls,
        "Parede das celas de triagem",
        31.2,
        22,
        38.5,
        0,
        13,
        L.innerWallThickness,
        P.PaintShadow,
        M.plaster,
        {
            { from = 24, to = 27, bottom = 0, top = 9.0 },
            { from = 32, to = 35, bottom = 0, top = 9.0 },
        },
        nil
    )
    wallZ(
        folders.innerWalls,
        "Divisória das celas de triagem",
        30.2,
        31.2,
        36.5,
        0,
        13,
        L.innerWallThickness,
        P.PaintShadow,
        M.plaster,
        nil,
        nil
    )

    -- Ala norte: paredes e acessos.
    local northOpenings = {
        { from = -26, to = -22, bottom = 0, top = 10.0 },
        { from = -20, to = -8, bottom = 0, top = 10.0 },
        { from = -4, to = 4, bottom = 0, top = 10.0 },
        { from = 8, to = 20, bottom = 0, top = 10.0 },
        { from = 22, to = 26, bottom = 0, top = 10.0 },
    }
    wallX(
        folders.innerWalls,
        "Parede norte do hall",
        -27.3,
        -38.5,
        38.5,
        0,
        13,
        L.innerWallThickness,
        P.Paint,
        M.plaster,
        northOpenings,
        nil
    )
    doorX(
        folders.innerWalls,
        "Porta da oficina",
        -27.3,
        -26,
        -22,
        0,
        10.0,
        L.innerWallThickness,
        { color = P.GreenDark, swing = -1 }
    )
    doorX(
        folders.innerWalls,
        "Porta do depósito",
        -27.3,
        22,
        26,
        0,
        10.0,
        L.innerWallThickness,
        { color = P.GreenDark, swing = -1 }
    )
    doorX(
        folders.innerWalls,
        "Porta da sala central norte",
        -27.3,
        -4,
        4,
        0,
        10.0,
        L.innerWallThickness,
        { double = true, color = P.GreenDark, swing = -1 }
    )
    for _, x in { -22, -6, 6, 22 } do
        wallZ(
            folders.innerWalls,
            string.format("Parede da ala norte x=%.0f", x),
            x,
            -46,
            -27,
            0,
            13,
            L.innerWallThickness,
            P.Paint,
            M.plaster,
            nil,
            nil
        )
    end
end

-- Escadas --------------------------------------------------------------------
local function slopedRail(
    parent: Instance,
    name: string,
    x: number,
    z1: number,
    y1: number,
    z2: number,
    y2: number,
    color: Color3,
    material: Enum.Material?
)
    local deltaZ = z2 - z1
    local deltaY = y2 - y1
    local length = math.sqrt(deltaZ * deltaZ + deltaY * deltaY)
    local angle = math.atan2(deltaY, deltaZ)
    local centerZ = (z1 + z2) * 0.5
    local centerY = (y1 + y2) * 0.5
    Kit.block(
        parent,
        name .. " corrimão inclinado",
        CFrame.new(x, centerY + 3.2, centerZ) * CFrame.Angles(angle, 0, 0),
        Vector3.new(0.16, 0.16, length),
        color,
        material,
        { collide = false, query = false, shadow = false }
    )
    local posts = 6
    for index = 1, posts do
        local t = (index - 1) / (posts - 1)
        local z = z1 + deltaZ * t
        local y = y1 + deltaY * t
        Kit.block(
            parent,
            name .. " montante " .. index,
            CFrame.new(x, y + 1.7, z),
            Vector3.new(0.14, 3.4, 0.14),
            color,
            material,
            { collide = false, query = false, shadow = false }
        )
    end
end

local function stairFlight(
    parent: Instance,
    name: string,
    x1: number,
    x2: number,
    zStart: number,
    zEnd: number,
    baseY: number,
    rise: number,
    run: number,
    steps: number,
    railingSide: number?
)
    local stepRise = rise / steps
    local stepRun = run / steps
    local direction = if zEnd > zStart then 1 else -1

    for index = 1, steps do
        local topY = baseY + stepRise * index
        local zCenter = zStart + direction * stepRun * (index - 0.5)
        box(
            parent,
            string.format("%s degrau %d", name, index),
            x1,
            x2,
            baseY,
            topY,
            math.min(zCenter - stepRun * 0.5, zCenter + stepRun * 0.5),
            math.max(zCenter - stepRun * 0.5, zCenter + stepRun * 0.5),
            P.StoneLight,
            M.stone,
            nil
        )
    end

    if railingSide then
        local x = if railingSide > 0 then x2 - 0.2 else x1 + 0.2
        slopedRail(parent, name, x, zStart, baseY, zEnd, baseY + rise, P.Iron, M.iron)
    end
end

local function buildStairs()
    for _, side in { "west", "east" } do
        local s = L.stairs[side]
        local flightA = s.flightA
        local flightB = s.flightB
        local landingZ1 = s.minZ
        local landingZ2 = s.minZ + L.stairs.landingDepth
        local run = L.stairs.run
        local steps = L.stairs.steps

        stairFlight(
            folders.stairs,
            "Escada A " .. side,
            flightA.minX,
            flightA.maxX,
            s.maxZ,
            s.maxZ - run,
            0,
            L.floorHeight,
            run,
            steps,
            if side == "west" then 1 else -1
        )
        stairFlight(
            folders.stairs,
            "Escada B " .. side,
            flightB.minX,
            flightB.maxX,
            landingZ2,
            landingZ2 + run,
            L.floorHeight,
            L.floorHeight,
            run,
            steps,
            if side == "west" then -1 else 1
        )

        -- Patamar superior da escada A no nível 1.
        slab(
            folders.stairs,
            "Patamar da escada " .. side,
            s.minX,
            s.maxX,
            landingZ1,
            landingZ2,
            L.floorHeight,
            0.8,
            P.StoneLight,
            M.stone
        )

        -- Corredor elevado ao lado da escada B, no nível 1.
        local corridor = s.corridor
        slab(
            folders.stairs,
            "Corredor elevado " .. side,
            corridor.minX,
            corridor.maxX,
            -42,
            -27,
            L.floorHeight,
            0.8,
            P.Stone,
            M.stone
        )

        -- Fechamento entre o corredor e a caixa da escada B.
        box(
            folders.innerWalls,
            "Guarda-corpo da escada " .. side,
            math.min(corridor.minX - 0.15, corridor.minX + 0.15),
            math.max(corridor.minX - 0.15, corridor.minX + 0.15),
            L.floorHeight,
            L.floorHeight + 3.0,
            -42,
            -27,
            P.Iron,
            M.iron,
            nil
        )

        -- Grades em torno do patamar.
        Kit.railingX(
            folders.stairs,
            "Corrimão do patamar " .. side,
            s.minX,
            s.maxX,
            landingZ2,
            L.floorHeight,
            3.4,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.railingZ(
            folders.stairs,
            "Corrimão lateral do patamar " .. side,
            landingZ1,
            landingZ2,
            if side == "west" then s.maxX - 0.25 else s.minX + 0.25,
            L.floorHeight,
            3.4,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )

        -- Iluminação das escadas.
        Furniture.ceilingLight(
            folders.frame,
            "Luz da escada " .. side .. " — nível 1",
            CFrame.new((s.minX + s.maxX) * 0.5, L.floorHeight + 11.6, -36),
            3.2,
            1.0,
            P.NeonWarm,
            1.1,
            12
        )
        Furniture.ceilingLight(
            folders.frame,
            "Luz da escada " .. side .. " — térreo",
            CFrame.new((s.minX + s.maxX) * 0.5, 11.6, -36),
            3.2,
            1.0,
            P.NeonWarm,
            1.1,
            12
        )
    end
end

-- Galerias e guarda-corpos ---------------------------------------------------
local function buildGalleries()
    for level = 2, 3 do
        local y = L.levelY(level)
        local railY = y + 0.65

        -- Faixa de ferro sob o piso das galerias.
        local edge = 0.36
        box(
            folders.frame,
            "Faixa da galeria oeste — nível " .. level,
            -18 + edge * 0.5,
            -18 + edge * 1.5,
            y - 0.8,
            y - 0.1,
            -20,
            20,
            P.GreenDark,
            M.iron,
            nil
        )
        box(
            folders.frame,
            "Faixa da galeria leste — nível " .. level,
            18 - edge * 1.5,
            18 - edge * 0.5,
            y - 0.8,
            y - 0.1,
            -20,
            20,
            P.GreenDark,
            M.iron,
            nil
        )
        box(
            folders.frame,
            "Faixa da ponte norte — nível " .. level,
            -18,
            18,
            y - 0.8,
            y - 0.1,
            -20 + edge * 0.5,
            -20 + edge * 1.5,
            P.GreenDark,
            M.iron,
            nil
        )
        box(
            folders.frame,
            "Faixa da ponte sul — nível " .. level,
            -18,
            18,
            y - 0.8,
            y - 0.1,
            20 - edge * 1.5,
            20 - edge * 0.5,
            P.GreenDark,
            M.iron,
            nil
        )

        -- Guarda-corpos de ferro em torno do vazio.
        Kit.railingZ(
            folders.frame,
            "Guarda-corpo oeste — nível " .. level,
            -20,
            20,
            -18,
            railY,
            2.6,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.railingZ(
            folders.frame,
            "Guarda-corpo leste — nível " .. level,
            -20,
            20,
            18,
            railY,
            2.6,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.railingX(
            folders.frame,
            "Guarda-corpo norte — nível " .. level,
            -18,
            18,
            -20,
            railY,
            2.6,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        Kit.railingX(
            folders.frame,
            "Guarda-corpo sul — nível " .. level,
            -18,
            18,
            20,
            railY,
            2.6,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )

        -- Colunatas de cantaria que sustentam as galerias. A coluna do nível
        -- superior nasce sobre o piso da galeria, formando uma ordem contínua.
        local columnBase = if level == 2 then 0 else L.floorHeight
        for _, x in { -18, 18 } do
            for _, z in { -16, 0, 16 } do
                Furniture.column(
                    folders.frame,
                    string.format("Coluna da galeria — nível %d — %.0f/%.0f", level, x, z),
                    CFrame.new(x, columnBase, z),
                    L.floorHeight - 0.8,
                    1.5,
                    P.StoneLight,
                    M.stone
                )
            end
        end
    end

    -- Pendentes altos do átrio.
    for _, x in { -9, 9 } do
        for _, z in { -10, 10 } do
            Furniture.pendantLamp(
                folders.frame,
                string.format("Pendente do átrio %.0f/%.0f", x, z),
                CFrame.new(x, L.roofY - 0.4, z),
                13,
                4.2,
                4.2,
                P.NeonWarm,
                1.9,
                24
            )
        end
    end
end

-- Cobertura e lanternim ------------------------------------------------------
local function buildRoof()
    local roofY = L.roofY
    local thickness = 0.8

    slab(
        folders.ceilings,
        "Cobertura oeste",
        -38.5,
        -18,
        -27,
        27,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )
    slab(
        folders.ceilings,
        "Cobertura leste",
        18,
        38.5,
        -27,
        27,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )
    slab(
        folders.ceilings,
        "Cobertura norte",
        -38.5,
        38.5,
        -46,
        -27,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )
    slab(
        folders.ceilings,
        "Cobertura sul",
        -38.5,
        38.5,
        27,
        36.5,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )
    slab(
        folders.ceilings,
        "Cobertura da ponte norte",
        -18,
        18,
        -27,
        -20,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )
    slab(
        folders.ceilings,
        "Cobertura da ponte sul",
        -18,
        18,
        20,
        27,
        roofY,
        thickness,
        P.RoofSlate,
        M.slate
    )

    -- Platibanda e cornija.
    for _, spec in
        {
            { name = "sul", axis = "X", center = 37.55, from = -40, to = 40 },
            { name = "norte", axis = "X", center = -45.55, from = -40, to = 40 },
            { name = "oeste", axis = "Z", center = -39.55, from = -46, to = 38 },
            { name = "leste", axis = "Z", center = 39.55, from = -46, to = 38 },
        }
    do
        if spec.axis == "X" then
            box(
                folders.ceilings,
                "Platibanda " .. spec.name,
                spec.from,
                spec.to,
                roofY,
                L.parapetY,
                spec.center - 0.55,
                spec.center + 0.55,
                P.Stone,
                M.stone,
                nil
            )
            box(
                folders.trim,
                "Copa da platibanda " .. spec.name,
                spec.from - 0.2,
                spec.to + 0.2,
                L.parapetY,
                L.parapetY + 0.4,
                spec.center - 0.8,
                spec.center + 0.8,
                P.StoneLight,
                M.stone,
                nil
            )
        else
            box(
                folders.ceilings,
                "Platibanda " .. spec.name,
                spec.center - 0.55,
                spec.center + 0.55,
                roofY,
                L.parapetY,
                spec.from,
                spec.to,
                P.Stone,
                M.stone,
                nil
            )
            box(
                folders.trim,
                "Copa da platibanda " .. spec.name,
                spec.center - 0.8,
                spec.center + 0.8,
                L.parapetY,
                L.parapetY + 0.4,
                spec.from - 0.2,
                spec.to + 0.2,
                P.StoneLight,
                M.stone,
                nil
            )
        end
    end

    -- Lanternim de vidro sobre o átrio.
    local curbY = roofY + 0.4
    local glassTop = roofY + 3.3
    box(
        folders.ceilings,
        "Curbata do lanternim norte",
        -18.6,
        18.6,
        roofY,
        curbY,
        -20.6,
        -19.9,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.ceilings,
        "Curbata do lanternim sul",
        -18.6,
        18.6,
        roofY,
        curbY,
        19.9,
        20.6,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.ceilings,
        "Curbata do lanternim oeste",
        -18.6,
        -17.9,
        roofY,
        curbY,
        -20.6,
        20.6,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.ceilings,
        "Curbata do lanternim leste",
        17.9,
        18.6,
        roofY,
        curbY,
        -20.6,
        20.6,
        P.StoneLight,
        M.stone,
        nil
    )

    -- Paredes de vidro do lanternim.
    local segments = 6
    for index = 1, segments do
        local x1 = -18 + 36 / segments * (index - 1)
        local x2 = -18 + 36 / segments * index
        box(
            folders.ceilings,
            string.format("Vidro norte do lanternim %d", index),
            x1 + 0.15,
            x2 - 0.15,
            curbY + 0.2,
            glassTop,
            -20.02,
            -19.88,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
        box(
            folders.ceilings,
            string.format("Vidro sul do lanternim %d", index),
            x1 + 0.15,
            x2 - 0.15,
            curbY + 0.2,
            glassTop,
            19.88,
            20.02,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
    end
    for index = 1, 6 do
        local z1 = -20 + 40 / 6 * (index - 1)
        local z2 = -20 + 40 / 6 * index
        box(
            folders.ceilings,
            string.format("Vidro oeste do lanternim %d", index),
            -18.02,
            -17.88,
            curbY + 0.2,
            glassTop,
            z1 + 0.15,
            z2 - 0.15,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
        box(
            folders.ceilings,
            string.format("Vidro leste do lanternim %d", index),
            17.88,
            18.02,
            curbY + 0.2,
            glassTop,
            z1 + 0.15,
            z2 - 0.15,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
    end

    -- Montantes de ferro do lanternim.
    for _, x in { -18, -12, -6, 0, 6, 12, 18 } do
        box(
            folders.ceilings,
            "Montante do lanternim x=" .. x,
            x - 0.1,
            x + 0.1,
            curbY,
            glassTop,
            -20.1,
            -19.9,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.ceilings,
            "Montante do lanternim x=" .. x,
            x - 0.1,
            x + 0.1,
            curbY,
            glassTop,
            19.9,
            20.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, z in { -20, -13.33, -6.66, 0.01, 6.66, 13.33, 20 } do
        box(
            folders.ceilings,
            "Montante do lanternim z=" .. z,
            -18.1,
            -17.9,
            curbY,
            glassTop,
            z - 0.1,
            z + 0.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.ceilings,
            "Montante do lanternim z=" .. z,
            17.9,
            18.1,
            curbY,
            glassTop,
            z - 0.1,
            z + 0.1,
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Teto de vidro do lanternim, em quatro panos.
    box(
        folders.ceilings,
        "Vidro de cobertura do lanternim",
        -18.1,
        18.1,
        glassTop + 0.2,
        glassTop + 0.32,
        -20.1,
        20.1,
        P.Glass,
        M.glass,
        { transparency = 0.68, collide = false, query = false, shadow = false }
    )
    for _, spec in
        {
            { name = "norte", minX = -18.1, maxX = 18.1, minZ = -20.1, maxZ = -19.9 },
            { name = "sul", minX = -18.1, maxX = 18.1, minZ = 19.9, maxZ = 20.1 },
            { name = "oeste", minX = -18.1, maxX = -17.9, minZ = -20.1, maxZ = 20.1 },
            { name = "leste", minX = 17.9, maxX = 18.1, minZ = -20.1, maxZ = 20.1 },
        }
    do
        box(
            folders.ceilings,
            "Borda de ferro do lanternim " .. spec.name,
            spec.minX,
            spec.maxX,
            glassTop + 0.15,
            glassTop + 0.5,
            spec.minZ,
            spec.maxZ,
            P.Iron,
            M.iron,
            nil
        )
    end

    -- Chaminé clássica da casa de máquinas.
    box(
        folders.ceilings,
        "Chaminé da casa de máquinas",
        26,
        31,
        roofY,
        56,
        -40,
        -35,
        P.Brick,
        M.brick,
        nil
    )
    box(
        folders.ceilings,
        "Coroamento da chaminé",
        25.4,
        31.6,
        56,
        57,
        -40.6,
        -34.4,
        P.StoneDark,
        M.stone,
        nil
    )
    for index = 1, 4 do
        box(
            folders.ceilings,
            "Faixa da chaminé " .. index,
            25.7,
            31.3,
            43 + index * 3,
            43.3 + index * 3,
            -40.3,
            -34.7,
            P.BrickDark,
            M.brick,
            nil
        )
    end
end

-- Refeitório ----------------------------------------------------------------
local function refectoryShell()
    local r = L.refeitorio
    local height = r.height
    local wallT = 1.5
    local westX = r.outer.minX + wallT * 0.5
    local northZ = r.outer.minZ + wallT * 0.5
    local southZ = r.outer.maxZ - wallT * 0.5

    -- Piso.
    box(
        folders.floors,
        "Piso do refeitório",
        r.outer.minX,
        r.outer.maxX,
        -0.6,
        0,
        r.outer.minZ,
        r.outer.maxZ,
        P.StoneDark,
        M.concrete,
        nil
    )
    box(
        folders.floors,
        "Acabamento do piso do refeitório",
        r.inner.minX,
        r.inner.maxX,
        0,
        0.08,
        r.inner.minZ,
        r.inner.maxZ,
        P.TerrazzoLight,
        M.ceramic,
        nil
    )

    -- Paredes com janelas altas.
    local westOpenings = {}
    for index, center in { -16, -8, 0, 8, 16 } do
        table.insert(westOpenings, {
            from = center - 2.4,
            to = center + 2.4,
            bottom = 8.2,
            top = 16.2,
        })
    end
    wallZ(
        folders.outerWalls,
        "Fachada oeste do refeitório",
        westX,
        r.outer.minZ,
        r.outer.maxZ,
        0,
        height,
        wallT,
        P.Brick,
        M.brick,
        westOpenings,
        nil
    )
    for index, center in { -16, -8, 0, 8, 16 } do
        windowZ(
            folders.windows,
            "Janela oeste do refeitório " .. index,
            westX,
            center - 2.4,
            center + 2.4,
            8.2,
            16.2,
            { panesX = 2, panesY = 3 }
        )
    end

    local northOpenings = {}
    for index, center in { -84, -72, -60, -48 } do
        table.insert(northOpenings, {
            from = center - 3.0,
            to = center + 3.0,
            bottom = 8.2,
            top = 16.2,
        })
    end
    wallX(
        folders.outerWalls,
        "Fachada norte do refeitório",
        northZ,
        r.outer.minX,
        r.outer.maxX,
        0,
        height,
        wallT,
        P.Brick,
        M.brick,
        northOpenings,
        nil
    )
    for index, center in { -84, -72, -60, -48 } do
        windowX(
            folders.windows,
            "Janela norte do refeitório " .. index,
            northZ,
            center - 3.0,
            center + 3.0,
            8.2,
            16.2,
            { panesX = 3, panesY = 3 }
        )
    end

    local southOpenings = {}
    for index, center in { -84, -72, -60, -48 } do
        table.insert(southOpenings, {
            from = center - 3.0,
            to = center + 3.0,
            bottom = 8.2,
            top = 16.2,
        })
    end
    wallX(
        folders.outerWalls,
        "Fachada sul do refeitório",
        southZ,
        r.outer.minX,
        r.outer.maxX,
        0,
        height,
        wallT,
        P.Brick,
        M.brick,
        southOpenings,
        nil
    )
    for index, center in { -84, -72, -60, -48 } do
        windowX(
            folders.windows,
            "Janela sul do refeitório " .. index,
            southZ,
            center - 3.0,
            center + 3.0,
            8.2,
            16.2,
            { panesX = 3, panesY = 3 }
        )
    end

    -- Telhado e lanternins.
    box(
        folders.ceilings,
        "Cobertura do refeitório",
        r.outer.minX - 0.4,
        r.outer.maxX + 0.4,
        height,
        height + 0.8,
        r.outer.minZ - 0.4,
        r.outer.maxZ + 0.4,
        P.RoofSlate,
        M.slate,
        nil
    )
    for _, spec in
        {
            {
                minX = r.outer.minX,
                maxX = r.outer.maxX,
                minZ = r.outer.minZ - 0.2,
                maxZ = r.outer.minZ + 0.4,
            },
            {
                minX = r.outer.minX,
                maxX = r.outer.maxX,
                minZ = r.outer.maxZ - 0.4,
                maxZ = r.outer.maxZ + 0.2,
            },
            {
                minX = r.outer.minX - 0.2,
                maxX = r.outer.minX + 0.4,
                minZ = r.outer.minZ,
                maxZ = r.outer.maxZ,
            },
            {
                minX = r.outer.maxX - 0.4,
                maxX = r.outer.maxX + 0.2,
                minZ = r.outer.minZ,
                maxZ = r.outer.maxZ,
            },
        }
    do
        box(
            folders.trim,
            "Platibanda do refeitório",
            spec.minX,
            spec.maxX,
            height,
            height + 1.8,
            spec.minZ,
            spec.maxZ,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    for index, xCenter in { -84, -69, -54 } do
        local minX = xCenter - 5
        local maxX = xCenter + 5
        box(
            folders.ceilings,
            "Curbata do lanternim do refeitório " .. index,
            minX - 0.5,
            maxX + 0.5,
            height,
            height + 2.0,
            -4.5,
            10.5,
            P.StoneLight,
            M.stone,
            nil
        )
        box(
            folders.ceilings,
            "Vidro do lanternim do refeitório " .. index,
            minX,
            maxX,
            height + 2.0,
            height + 2.15,
            -4,
            10,
            P.Glass,
            M.glass,
            { transparency = 0.62, collide = false, query = false, shadow = false }
        )
        for _, spec in
            {
                { a = minX, b = maxX, c = -4, d = -3.7, axis = "X" },
                { a = minX, b = maxX, c = 9.7, d = 10, axis = "X" },
                { a = minX, b = minX + 0.3, c = -4, d = 10, axis = "Z" },
                { a = maxX - 0.3, b = maxX, c = -4, d = 10, axis = "Z" },
            }
        do
            if spec.axis == "X" then
                box(
                    folders.trim,
                    "Borda do lanternim do refeitório " .. index,
                    spec.a,
                    spec.b,
                    height + 1.95,
                    height + 2.35,
                    spec.c,
                    spec.d,
                    P.Iron,
                    M.iron,
                    nil
                )
            else
                box(
                    folders.trim,
                    "Borda do lanternim do refeitório " .. index,
                    spec.a,
                    spec.b,
                    height + 1.95,
                    height + 2.35,
                    spec.c,
                    spec.d,
                    P.Iron,
                    M.iron,
                    nil
                )
            end
        end
    end

    -- Arcos de reforço: pilastras internas entre as janelas.
    for _, z in { -20, -12, -4, 4, 12, 20, 28 } do
        box(
            folders.trim,
            "Pilastra do refeitório z=" .. z,
            r.inner.minX - 0.2,
            r.inner.minX + 0.8,
            0.8,
            18.8,
            z - 0.6,
            z + 0.6,
            P.BrickDark,
            M.brick,
            nil
        )
    end
    for _, x in { -90, -78, -66, -54, -42 } do
        box(
            folders.trim,
            "Pilastra norte do refeitório x=" .. x,
            x - 0.6,
            x + 0.6,
            0.8,
            18.8,
            r.inner.minZ - 0.1,
            r.inner.minZ + 0.7,
            P.BrickDark,
            M.brick,
            nil
        )
        box(
            folders.trim,
            "Pilastra sul do refeitório x=" .. x,
            x - 0.6,
            x + 0.6,
            0.8,
            18.8,
            r.inner.maxZ - 0.7,
            r.inner.maxZ + 0.1,
            P.BrickDark,
            M.brick,
            nil
        )
    end

    -- Passagem e serviço para o edifício principal.
    doorZ(
        folders.innerWalls,
        "Porta de passagem do refeitório",
        (L.outer.minX + L.inner.minX) * 0.5,
        8,
        14,
        0,
        10.0,
        L.wallThickness,
        {
            double = true,
            color = P.GreenDark,
            casingColor = P.StoneLight,
            swing = 1,
        }
    )
end

-- Corredor de segurança até o pátio -----------------------------------------
local function buildSallyPort()
    local x1 = L.outer.maxX
    local x2 = L.yard.outer.minX
    local z1 = 7
    local z2 = 13
    box(
        folders.floors,
        "Piso do corredor do pátio",
        x1,
        x2,
        0.02,
        0.1,
        z1,
        z2,
        P.StoneDark,
        M.concrete,
        nil
    )
    box(
        folders.innerWalls,
        "Parede norte do corredor do pátio",
        x1,
        x2,
        0,
        10.5,
        z1 - 0.3,
        z1,
        P.Stone,
        M.stone,
        nil
    )
    box(
        folders.innerWalls,
        "Parede sul do corredor do pátio",
        x1,
        x2,
        0,
        10.5,
        z2,
        z2 + 0.3,
        P.Stone,
        M.stone,
        nil
    )
    box(
        folders.ceilings,
        "Cobertura do corredor do pátio",
        x1,
        x2,
        10.5,
        11.1,
        z1 - 0.4,
        z2 + 0.4,
        P.RoofSlate,
        M.slate,
        nil
    )
    for _, spec in
        {
            { name = "interno", x = x1 + 0.4, axis = "Z" },
            { name = "externo", x = x2 - 0.4, axis = "Z" },
        }
    do
        Kit.barsZ(
            folders.innerWalls,
            "Grade do corredor do pátio — " .. spec.name,
            z1 + 0.3,
            z2 - 0.3,
            5,
            spec.x,
            10,
            1.0,
            P.Iron,
            M.iron,
            0.15,
            { collide = false, query = false, shadow = false }
        )
    end
    Furniture.ceilingLight(
        folders.frame,
        "Luz do corredor do pátio",
        CFrame.new((x1 + x2) * 0.5, 10.4, (z1 + z2) * 0.5),
        3.5,
        1.0,
        P.NeonCool,
        1.0,
        10
    )
end

-- Fachada e pórtico ----------------------------------------------------------
local function buildFacadeDetails()
    -- Faixas horizontais de cantaria.
    for _, y in { 0.3, 12.7, 25.7, 38.2 } do
        box(
            folders.trim,
            "Faixa horizontal sul y=" .. y,
            L.outer.minX - 0.3,
            L.outer.maxX + 0.3,
            y,
            y + 0.5,
            L.outer.maxZ - 0.15,
            L.outer.maxZ + 0.45,
            P.StoneLight,
            M.stone,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.trim,
            "Faixa horizontal norte y=" .. y,
            L.outer.minX - 0.3,
            L.outer.maxX + 0.3,
            y,
            y + 0.5,
            L.outer.minZ - 0.45,
            L.outer.minZ + 0.15,
            P.StoneLight,
            M.stone,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.trim,
            "Faixa horizontal oeste y=" .. y,
            L.outer.minX - 0.45,
            L.outer.minX + 0.15,
            y,
            y + 0.5,
            L.outer.minZ - 0.3,
            L.outer.maxZ + 0.3,
            P.StoneLight,
            M.stone,
            { collide = false, query = false, shadow = false }
        )
        box(
            folders.trim,
            "Faixa horizontal leste y=" .. y,
            L.outer.maxX - 0.15,
            L.outer.maxX + 0.45,
            y,
            y + 0.5,
            L.outer.minZ - 0.3,
            L.outer.maxZ + 0.3,
            P.StoneLight,
            M.stone,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cornija forte no topo.
    box(folders.trim, "Cornija sul", -41, 41, 37.7, 38.4, 37.55, 39.0, P.StoneLight, M.stone, nil)
    box(
        folders.trim,
        "Cornija norte",
        -41,
        41,
        37.7,
        38.4,
        -47.0,
        -45.55,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.trim,
        "Cornija oeste",
        -41.0,
        -39.55,
        37.7,
        38.4,
        -47,
        39,
        P.StoneLight,
        M.stone,
        nil
    )
    box(folders.trim, "Cornija leste", 39.55, 41.0, 37.7, 38.4, -47, 39, P.StoneLight, M.stone, nil)

    -- Dentículos da fachada principal.
    for index = 1, 40 do
        local x = -39 + (78 / 40) * (index - 0.5)
        box(
            folders.trim,
            "Dentículo " .. index,
            x - 0.35,
            x + 0.35,
            37.15,
            37.7,
            38.0,
            38.55,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    -- Cadeiras e capitéis entre as janelas da fachada sul.
    for _, x in { -35, -25, -15, -5, 5, 15, 25, 35 } do
        box(
            folders.trim,
            "Pilastra sul x=" .. x,
            x - 0.45,
            x + 0.45,
            1.0,
            37.6,
            37.9,
            38.5,
            P.StoneDark,
            M.stone,
            nil
        )
        box(
            folders.trim,
            "Capitélio sul x=" .. x,
            x - 0.7,
            x + 0.7,
            36.9,
            37.6,
            37.75,
            38.6,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    -- Quinas rusticadas.
    for _, corner in
        {
            { x = L.outer.minX + 0.5, z = L.outer.minZ + 0.5 },
            { x = L.outer.maxX - 0.5, z = L.outer.minZ + 0.5 },
            { x = L.outer.minX + 0.5, z = L.outer.maxZ - 0.5 },
            { x = L.outer.maxX - 0.5, z = L.outer.maxZ - 0.5 },
        }
    do
        for index = 1, 11 do
            local width = if index % 2 == 0 then 1.7 else 2.7
            local y = 1.0 + (index - 1) * 3.35
            box(
                folders.trim,
                string.format("Quina %.0f/%.0f %d", corner.x, corner.z, index),
                corner.x - width * 0.5,
                corner.x + width * 0.5,
                y,
                y + 2.6,
                corner.z - width * 0.5,
                corner.z + width * 0.5,
                P.StoneLight,
                M.stone,
                nil
            )
        end
    end

    -- Pórtico de entrada.
    local porticoZ = 41.5
    box(
        folders.floors,
        "Piso do pórtico",
        -18,
        18,
        -0.15,
        0.1,
        38,
        45.5,
        P.StoneLight,
        M.stone,
        nil
    )
    for _, x in { -15, -9, -3, 3, 9, 15 } do
        Furniture.column(
            folders.frame,
            "Coluna do pórtico x=" .. x,
            CFrame.new(x, 0, porticoZ),
            12.5,
            1.5,
            P.StoneLight,
            M.stone
        )
    end
    box(
        folders.frame,
        "Entablamento do pórtico",
        -17.5,
        17.5,
        12.5,
        15.2,
        39.5,
        43.5,
        P.StoneLight,
        M.stone,
        nil
    )
    for index = 1, 24 do
        local x = -16.5 + (33 / 24) * (index - 0.5)
        box(
            folders.trim,
            "Dentículo do pórtico " .. index,
            x - 0.28,
            x + 0.28,
            11.9,
            12.45,
            38.7,
            43.4,
            P.StoneDark,
            M.stone,
            nil
        )
    end
    box(
        folders.frame,
        "Ático do pórtico",
        -10,
        10,
        15.2,
        18.4,
        39.7,
        42.6,
        P.StoneLight,
        M.stone,
        nil
    )
    box(
        folders.frame,
        "Cordão do ático",
        -8,
        8,
        18.4,
        19.2,
        39.9,
        42.4,
        P.StoneDark,
        M.stone,
        nil
    )
    box(folders.frame, "Teto do pórtico", -17, 17, 11.8, 12.4, 38, 43, P.Ceiling, M.plaster, nil)
    for _, z in { 39.2, 41.0, 42.8 } do
        box(
            folders.trim,
            "Viga do teto do pórtico z=" .. z,
            -17,
            17,
            11.55,
            11.85,
            z - 0.25,
            z + 0.25,
            P.StoneLight,
            M.stone,
            nil
        )
    end

    -- Lanternas do pórtico.
    for _, x in { -12, 12 } do
        Furniture.wallSconce(
            folders.frame,
            "Lanterna do pórtico x=" .. x,
            CFrame.new(x, 9.0, 38.1),
            P.NeonWarm,
            1.3,
            15
        )
    end

    -- Relógio institucional sobre a entrada.
    Furniture.wallClock(folders.frame, "Relógio da fachada", CFrame.new(0, 31.6, 38.05))
    Furniture.portrait(folders.frame, "Placa sobre a entrada", CFrame.new(0, 20.0, 38.1), 8, 2.8)

    -- Torres de ventilação discretas sobre a cobertura.
    for _, spec in
        {
            { x = -32, z = -39 },
            { x = 10, z = -39 },
        }
    do
        box(
            folders.ceilings,
            "Ventilação da cobertura",
            spec.x - 1.2,
            spec.x + 1.2,
            L.roofY,
            L.roofY + 4.2,
            spec.z - 1.2,
            spec.z + 1.2,
            P.StoneDark,
            M.stone,
            nil
        )
        box(
            folders.ceilings,
            "Sombreiro da ventilação",
            spec.x - 1.6,
            spec.x + 1.6,
            L.roofY + 4.2,
            L.roofY + 4.7,
            spec.z - 1.6,
            spec.z + 1.6,
            P.StoneLight,
            M.stone,
            nil
        )
    end
end

-- Montagem ------------------------------------------------------------------
function Architecture.build(parent: Instance?): Model
    local root = Kit.model(parent, L.name)
    makeFolders(root)

    buildFloors()
    buildOuterWalls()
    groundFloorPartitions()
    for level = 2, 3 do
        upperFloorRoomPartitions(level)
    end
    buildStairs()
    buildGalleries()
    buildRoof()
    refectoryShell()
    buildSallyPort()
    buildFacadeDetails()

    root:SetAttribute("Pavimentos", 3)
    root:SetAttribute("Celas", L.cellCount * 2 * 2)
    root:SetAttribute("AreaConstruidaM2", math.floor(L.areaCellHouseM2 * 3 + L.areaRefeitorioM2))
    root:SetAttribute("EscalaStudsPorMetro", L.studsPerMeter)

    return root
end

return Architecture

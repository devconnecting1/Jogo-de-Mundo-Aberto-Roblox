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
    Bloco de celas do Presídio Central.
    São 28 celas nos dois pavimentos superiores, distribuídas em duas galerias
    de sete celas. Cada cela tem ventilação e luz natural, cama, sanitário,
    lavatório, prateleira e porta de ferro com janela de observação.

    Variações de projeto:
      • celas individuais e celas com beliche;
      • duas celas de isolamento no segundo pavimento;
      • uma cela de confiança com mesa de trabalho;
      • quatro celas com porta aberta para leitura do interior no preview.
]]

local Cells = {}
local P = Palette
local M = P.Materials
local L = Layout

local OPEN_CELLS = {
    [101] = true,
    [108] = true,
    [207] = true,
    [208] = true,
}

local ISOLATION = {
    [201] = true,
    [202] = true,
    [214] = true,
}

local TRUSTEE = {
    [207] = true,
}

local BUNKS = {
    [108] = true,
    [109] = true,
    [110] = true,
    [111] = true,
    [112] = true,
    [113] = true,
    [114] = true,
    [205] = true,
    [209] = true,
    [211] = true,
    [213] = true,
}

local BLANKETS = {
    P.BlanketRust,
    P.BlanketOlive,
    P.BlanketNavy,
    P.BlanketGrey,
}

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

local function cellDoor(
    parent: Instance,
    name: string,
    frontX: number,
    y0: number,
    doorMinZ: number,
    doorMaxZ: number,
    side: string,
    number: number
)
    local width = doorMaxZ - doorMinZ
    local height = 8.5
    local isOpen = OPEN_CELLS[number] == true
    local isolated = ISOLATION[number] == true
    local sign = if side == "west" then -1 else 1
    local angle = if isOpen then math.rad(sign * 74) else 0
    local pivot = CFrame.new(frontX, y0 + 0.1, doorMinZ) * CFrame.Angles(0, angle, 0)
    local material = if isolated then M.steel else M.iron
    local color = if isolated then P.SteelDark else P.GreenDark

    -- Moldura de ferro.
    Kit.block(
        parent,
        name .. " ombreira A",
        CFrame.new(frontX, y0 + height * 0.5, doorMinZ - 0.12),
        Vector3.new(0.42, height, 0.24),
        P.Iron,
        M.iron,
        nil
    )
    Kit.block(
        parent,
        name .. " ombreira B",
        CFrame.new(frontX, y0 + height * 0.5, doorMaxZ + 0.12),
        Vector3.new(0.42, height, 0.24),
        P.Iron,
        M.iron,
        nil
    )
    Kit.block(
        parent,
        name .. " padieira",
        CFrame.new(frontX, y0 + height + 0.12, (doorMinZ + doorMaxZ) * 0.5),
        Vector3.new(0.42, 0.28, width + 0.5),
        P.Iron,
        M.iron,
        nil
    )

    -- Folha da porta, com almofadas e ferragens.
    local leaf = pivot * CFrame.new(0, height * 0.5, width * 0.5)
    Kit.block(
        parent,
        name .. " folha",
        leaf,
        Vector3.new(0.24, height - 0.12, width - 0.12),
        color,
        material,
        nil
    )
    for panel = 1, 2 do
        local panelY = 1.4 + (panel - 1) * 3.6
        Kit.block(
            parent,
            string.format("%s almofada %d", name, panel),
            pivot * CFrame.new(sign * 0.13, panelY, width * 0.5),
            Vector3.new(0.05, 2.4, width - 0.8),
            Kit.tint(color, 0.08),
            material,
            { collide = false, query = false, shadow = false }
        )
    end

    if not isolated then
        -- Janela de observação gradeada.
        Kit.block(
            parent,
            name .. " janela de observação",
            pivot * CFrame.new(sign * 0.14, 6.55, width * 0.5),
            Vector3.new(0.06, 2.2, width - 1.2),
            P.Iron,
            M.steel,
            { collide = false, query = false, shadow = false }
        )
        for index = 1, 4 do
            local z = width * 0.5 + (index - 2.5) * (width - 1.6) / 4
            Kit.block(
                parent,
                string.format("%s grade da janela %d", name, index),
                pivot * CFrame.new(sign * 0.19, 6.55, z),
                Vector3.new(0.05, 2.0, 0.08),
                P.IronLight,
                M.iron,
                { collide = false, query = false, shadow = false }
            )
        end
    else
        for index = 1, 5 do
            Kit.block(
                parent,
                string.format("%s rebite %d", name, index),
                pivot * CFrame.new(sign * 0.15, 2.2 + index * 1.0, width * 0.5),
                Vector3.new(0.07, 0.18, 0.18),
                P.SteelLight,
                M.steel,
                { collide = false, query = false, shadow = false }
            )
        end
    end

    Kit.block(
        parent,
        name .. " seteira",
        pivot * CFrame.new(sign * 0.15, 3.4, width * 0.5),
        Vector3.new(0.06, 0.32, 1.0),
        P.Iron,
        M.steel,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " puxador",
        pivot * CFrame.new(sign * 0.22, 4.3, width - 0.48),
        Vector3.new(0.18, 0.8, 0.16),
        P.Brass,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    for index, y in { 2.1, 6.3 } do
        Kit.block(
            parent,
            string.format("%s dobradiça %d", name, index),
            pivot * CFrame.new(sign * 0.16, y, 0.16),
            Vector3.new(0.15, 0.55, 0.2),
            P.IronLight,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Placa do número, ao lado da porta.
    Kit.block(
        parent,
        name .. " placa",
        CFrame.new(frontX - sign * 0.18, y0 + 5.6, doorMaxZ + 1.15),
        Vector3.new(0.08, 1.15, 1.55),
        P.BrassDark,
        M.metal,
        { collide = false, query = false, shadow = false }
    )
    Kit.block(
        parent,
        name .. " placa interna",
        CFrame.new(frontX - sign * 0.23, y0 + 5.6, doorMaxZ + 1.15),
        Vector3.new(0.05, 0.92, 1.3),
        P.Paper,
        M.paper,
        { collide = false, query = false, shadow = false }
    )
end

local function buildCell(
    parent: Instance,
    level: number,
    side: string,
    index: number,
    number: number
)
    local y0 = L.levelY(level)
    local cellMinZ, cellMaxZ = L.cellBounds(index)
    local cellWidth = cellMaxZ - cellMinZ
    local isWest = side == "west"
    local sign = if isWest then -1 else 1
    local backX = if isWest then L.cellBlocks.west.minX else L.cellBlocks.east.maxX
    local frontX = if isWest then L.cellBlocks.west.maxX else L.cellBlocks.east.minX
    local innerFrontX = frontX + sign * 0.15
    local innerBackX = backX - sign * 0.15
    local xCenter = (innerFrontX + innerBackX) * 0.5
    local innerMinX = math.min(innerFrontX, innerBackX)
    local innerMaxX = math.max(innerFrontX, innerBackX)
    local zCenter = L.cellCenterZ(index)
    local cellNumber = number
    local isolated = ISOLATION[cellNumber] == true
    local trustee = TRUSTEE[cellNumber] == true
    local bunk = BUNKS[cellNumber] == true
    local doorWidth = 3.9
    local doorMinZ = zCenter - doorWidth * 0.5
    local doorMaxZ = zCenter + doorWidth * 0.5

    local model = Kit.model(parent, string.format("Cela %d", cellNumber))
    model:SetAttribute("Numero", cellNumber)
    model:SetAttribute("Pavimento", level)
    model:SetAttribute("Ala", if isWest then "Oeste" else "Leste")
    model:SetAttribute(
        "Tipo",
        if isolated
            then "Isolamento"
            elseif trustee then "Confiança"
            elseif bunk then "Beliche"
            else "Individual"
    )

    -- Piso e rodapé.
    box(
        model,
        "Piso da cela",
        innerMinX,
        innerMaxX,
        y0 + 0.02,
        y0 + 0.09,
        cellMinZ + 0.35,
        cellMaxZ - 0.35,
        if isolated then P.TileDark else P.TerrazzoDark,
        M.ceramic,
        nil
    )
    box(
        model,
        "Rodapé da cela",
        innerMinX,
        innerMaxX,
        y0 + 0.1,
        y0 + 0.42,
        cellMinZ + 0.3,
        cellMaxZ - 0.3,
        P.GreenDark,
        M.paint,
        { collide = false, query = false, shadow = false }
    )

    -- Revestimento das paredes: pintura clara e faixa verde institucional.
    box(
        model,
        "Pintura do fundo",
        backX - 0.08,
        backX + 0.08,
        y0 + 0.35,
        y0 + 9.9,
        cellMinZ + 0.25,
        cellMaxZ - 0.25,
        P.Paint,
        M.plaster,
        { collide = false, query = false, shadow = false }
    )
    box(
        model,
        "Faixa verde do fundo",
        backX - 0.17,
        backX + 0.17,
        y0 + 0.38,
        y0 + 3.1,
        cellMinZ + 0.25,
        cellMaxZ - 0.25,
        P.Green,
        M.paint,
        { collide = false, query = false, shadow = false }
    )
    for _, boundaryZ in { cellMinZ, cellMaxZ } do
        box(
            model,
            "Pintura lateral",
            math.min(innerBackX, innerFrontX),
            math.max(innerBackX, innerFrontX),
            y0 + 0.35,
            y0 + 9.9,
            boundaryZ - 0.08,
            boundaryZ + 0.08,
            P.Paint,
            M.plaster,
            { collide = false, query = false, shadow = false }
        )
        box(
            model,
            "Faixa verde lateral",
            math.min(innerBackX, innerFrontX),
            math.max(innerBackX, innerFrontX),
            y0 + 0.38,
            y0 + 3.1,
            boundaryZ - 0.17,
            boundaryZ + 0.17,
            P.Green,
            M.paint,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Teto pintado e sanca.
    box(
        model,
        "Teto da cela",
        math.min(innerBackX, innerFrontX),
        math.max(innerBackX, innerFrontX),
        y0 + L.cellHeight - 0.14,
        y0 + L.cellHeight,
        cellMinZ + 0.25,
        cellMaxZ - 0.25,
        P.Ceiling,
        M.plaster,
        { collide = false, query = false, shadow = false }
    )
    for _, z in { cellMinZ + 0.35, cellMaxZ - 0.55 } do
        box(
            model,
            "Sanca da cela",
            math.min(innerBackX, innerFrontX),
            math.max(innerBackX, innerFrontX),
            y0 + L.cellHeight - 0.42,
            y0 + L.cellHeight - 0.12,
            z,
            z + 0.2,
            P.PaintShadow,
            M.plaster,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Cama ou beliche, encostado na lateral oposta ao sanitário.
    local bedX = backX - sign * 3.1
    local bedZ = cellMinZ + 1.85
    local blanket = BLANKETS[((cellNumber + index) % #BLANKETS) + 1]
    if bunk then
        Furniture.bunk(model, "Beliche", CFrame.new(bedX, y0 + 0.06, bedZ), 6.15, 2.75, blanket)
    else
        Furniture.bed(model, "Cama", CFrame.new(bedX, y0 + 0.06, bedZ), 6.15, 2.75, blanket)
    end

    -- Sanitário e lavatório no canto do fundo.
    local toiletX = backX - sign * 1.25
    local toiletZ = cellMaxZ - 1.55
    local toiletCF = CFrame.new(toiletX, y0 + 0.06, toiletZ)
        * CFrame.Angles(0, math.rad(sign * 90), 0)
    Furniture.toilet(model, "Sanitário", toiletCF)
    box(
        model,
        "Divisória do sanitário",
        math.min(backX - sign * 0.1, backX - sign * 2.7),
        math.max(backX - sign * 0.1, backX - sign * 2.7),
        y0 + 0.1,
        y0 + 6.4,
        cellMaxZ - 3.25,
        cellMaxZ - 3.0,
        P.PaintShadow,
        M.plaster,
        nil
    )

    local sinkZ = cellMaxZ - 3.95
    local sinkCF = CFrame.new(backX - sign * 0.75, y0 + 0.06, sinkZ)
        * CFrame.Angles(0, math.rad(sign * 90), 0)
    Furniture.sink(model, "Lavatório", sinkCF)
    box(
        model,
        "Espelho",
        math.min(backX - sign * 0.035, backX + sign * 0.035),
        math.max(backX - sign * 0.035, backX + sign * 0.035),
        y0 + 4.7,
        y0 + 6.7,
        sinkZ - 0.9,
        sinkZ + 0.9,
        P.SteelLight,
        M.metal,
        { collide = false, query = false, shadow = false, reflectance = 0.25 }
    )

    -- Janela alta já gradeada pela fachada; peitoril interno de pedra.
    box(
        model,
        "Peitoril interno da janela",
        math.min(backX - sign * 0.35, backX + sign * 0.1),
        math.max(backX - sign * 0.35, backX + sign * 0.1),
        y0 + 8.25,
        y0 + 8.5,
        zCenter - 1.9,
        zCenter + 1.9,
        P.StoneLight,
        M.stone,
        { collide = false, query = false, shadow = false }
    )
    if isolated then
        box(
            model,
            "Fechamento cego da janela",
            math.min(backX - sign * 0.2, backX + sign * 0.05),
            math.max(backX - sign * 0.2, backX + sign * 0.05),
            y0 + 8.5,
            y0 + 11.4,
            zCenter - 1.6,
            zCenter + 1.6,
            P.SteelDark,
            M.diamond,
            nil
        )
    end

    -- Prateleira e pertences, exceto no isolamento.
    if not isolated then
        box(
            model,
            "Prateleira da parede",
            math.min(backX - sign * 1.1, backX - sign * 5.6),
            math.max(backX - sign * 1.1, backX - sign * 5.6),
            y0 + 6.3,
            y0 + 6.48,
            cellMinZ + 0.45,
            cellMinZ + 1.25,
            P.Oak,
            M.wood,
            nil
        )
        Furniture.books(
            model,
            "Livros da prateleira",
            CFrame.new(backX - sign * 2.2, y0 + 6.5, cellMinZ + 0.85),
            2.2,
            4,
            cellNumber * 3 + 1
        )
        Kit.block(
            model,
            "Caneca",
            CFrame.new(backX - sign * 4.55, y0 + 6.78, cellMinZ + 0.85),
            Vector3.new(0.38, 0.55, 0.38),
            P.Ceramic,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
        Kit.block(
            model,
            "Pasta de higiene",
            CFrame.new(backX - sign * 5.05, y0 + 6.65, cellMinZ + 0.85),
            Vector3.new(0.3, 0.32, 0.55),
            P.CeramicBlue,
            M.ceramic,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Mesa, banco e objetos de uso diário.
    if trustee then
        Furniture.desk(
            model,
            "Mesa da cela de confiança",
            CFrame.new(backX - sign * 4.2, y0 + 0.06, zCenter + 1.15)
                * CFrame.Angles(0, math.rad(sign * 90), 0),
            4.2,
            2.1,
            3.0,
            P.Oak,
            M.wood
        )
        Furniture.chair(
            model,
            "Cadeira da mesa",
            CFrame.new(backX - sign * 4.2, y0 + 0.06, zCenter + 3.6)
                * CFrame.Angles(0, math.rad(180), 0),
            P.Walnut,
            M.wood
        )
        Furniture.books(
            model,
            "Livros de estudo",
            CFrame.new(backX - sign * 4.2, y0 + 3.1, zCenter + 1.15),
            2.1,
            5,
            88
        )
        Kit.block(
            model,
            "Luminária de mesa",
            CFrame.new(backX - sign * 5.0, y0 + 3.6, zCenter + 0.2),
            Vector3.new(0.5, 0.8, 0.5),
            P.Brass,
            M.metal,
            { collide = false, query = false, shadow = false }
        )
    elseif not isolated then
        box(
            model,
            "Mesa pequena",
            math.min(backX - sign * 6.1, backX - sign * 3.9),
            math.max(backX - sign * 6.1, backX - sign * 3.9),
            y0 + 2.55,
            y0 + 2.82,
            cellMaxZ - 4.4,
            cellMaxZ - 2.6,
            P.Oak,
            M.wood,
            nil
        )
        for _, z in { cellMaxZ - 4.15, cellMaxZ - 2.9 } do
            Kit.block(
                model,
                "Perna da mesa",
                CFrame.new(backX - sign * 5.0, y0 + 1.3, z),
                Vector3.new(0.22, 2.55, 0.22),
                P.OakDark,
                M.wood,
                nil
            )
        end
        Furniture.stool(
            model,
            "Banco",
            CFrame.new(backX - sign * 5.0, y0 + 0.06, zCenter + 2.25),
            P.Walnut,
            M.wood
        )
    else
        box(
            model,
            "Cama baixa de isolamento",
            math.min(backX - sign * 6.4, backX - sign * 0.6),
            math.max(backX - sign * 6.4, backX - sign * 0.6),
            y0 + 0.15,
            y0 + 1.45,
            cellMaxZ - 3.9,
            cellMaxZ - 1.4,
            P.BlanketGrey,
            M.fabric,
            nil
        )
        box(
            model,
            "Travesseiro de isolamento",
            math.min(backX - sign * 5.9, backX - sign * 4.4),
            math.max(backX - sign * 5.9, backX - sign * 4.4),
            y0 + 1.45,
            y0 + 1.85,
            cellMaxZ - 3.8,
            cellMaxZ - 1.5,
            P.Linen,
            M.fabric,
            nil
        )
    end

    -- Porta de ferro e transom gradeado.
    local frontWallMin = if isWest then frontX - 0.32 else frontX - 0.28
    local frontWallMax = if isWest then frontX + 0.28 else frontX + 0.32
    box(
        model,
        "Parede frontal esquerda",
        frontWallMin,
        frontWallMax,
        y0,
        y0 + L.cellHeight,
        cellMinZ + 0.25,
        doorMinZ,
        P.PaintShadow,
        M.plaster,
        nil
    )
    box(
        model,
        "Parede frontal direita",
        frontWallMin,
        frontWallMax,
        y0,
        y0 + L.cellHeight,
        doorMaxZ,
        cellMaxZ - 0.25,
        P.PaintShadow,
        M.plaster,
        nil
    )
    box(
        model,
        "Verga da cela",
        frontWallMin,
        frontWallMax,
        y0 + 8.8,
        y0 + L.cellHeight,
        doorMinZ,
        doorMaxZ,
        P.PaintShadow,
        M.plaster,
        nil
    )
    cellDoor(model, "Porta da cela", frontX, y0, doorMinZ, doorMaxZ, side, cellNumber)

    -- Transom acima da porta, com grades.
    for index = 1, 5 do
        local z = doorMinZ + (doorMaxZ - doorMinZ) * (index - 0.5) / 5
        Kit.block(
            model,
            "Grade do transom " .. index,
            CFrame.new(frontX, y0 + 9.8, z),
            Vector3.new(0.16, 2.0, 0.08),
            P.Iron,
            M.iron,
            { collide = false, query = false, shadow = false }
        )
    end

    -- Luminária de teto, discreta e protegida por caixa de ferro.
    Furniture.ceilingLight(
        model,
        "Luz da cela",
        CFrame.new(xCenter, y0 + L.cellHeight - 0.05, zCenter),
        2.3,
        1.2,
        if isolated then P.NeonCool else P.NeonWarm,
        if isolated then 0.45 else 0.75,
        8
    )

    -- Soleira e faixa de circulação junto à porta.
    box(
        model,
        "Soleira da cela",
        frontX - 0.35,
        frontX + 0.35,
        y0 + 0.01,
        y0 + 0.08,
        doorMinZ,
        doorMaxZ,
        P.StoneLight,
        M.stone,
        nil
    )
end

local function buildCellBlockWalls(parent: Instance)
    for level = 2, 3 do
        local y0 = L.levelY(level)
        local y1 = y0 + L.floorHeight
        for _, side in { "west", "east" } do
            local isWest = side == "west"
            local backX = if isWest then L.cellBlocks.west.minX else L.cellBlocks.east.maxX
            local frontX = if isWest then L.cellBlocks.west.maxX else L.cellBlocks.east.minX
            local minX = math.min(backX, frontX)
            local maxX = math.max(backX, frontX)

            -- Paredes entre as celas.
            for index = 0, L.cellCount do
                local z = -27 + index * L.cellWidth
                box(
                    parent,
                    string.format("Divisória das celas %s %d-%d", side, level, index),
                    minX,
                    maxX,
                    y0,
                    y1,
                    z - 0.25,
                    z + 0.25,
                    P.PaintShadow,
                    M.plaster,
                    nil
                )
            end

            -- Faixa de cantaria no piso e cornija na frente das celas.
            local baseMin = if isWest then frontX - 0.45 else frontX - 0.15
            local baseMax = if isWest then frontX + 0.15 else frontX + 0.45
            box(
                parent,
                "Rodapé da galeria " .. side .. " — nível " .. level,
                baseMin,
                baseMax,
                y0,
                y0 + 0.5,
                -27,
                27,
                P.GreenDark,
                M.paint,
                { collide = false, query = false, shadow = false }
            )
            local corniceMin = if isWest then frontX - 0.35 else frontX - 0.25
            local corniceMax = if isWest then frontX + 0.25 else frontX + 0.35
            box(
                parent,
                "Cornija da galeria " .. side .. " — nível " .. level,
                corniceMin,
                corniceMax,
                y0 + 11.5,
                y0 + 11.9,
                -27,
                27,
                P.PaintWarm,
                M.plaster,
                { collide = false, query = false, shadow = false }
            )

            -- Arandelas a cada duas celas, voltadas para a galeria.
            for index = 1, L.cellCount, 2 do
                local z = L.cellCenterZ(index)
                local cf = CFrame.new(frontX + (if isWest then 0.48 else -0.48), y0 + 6.1, z)
                    * CFrame.Angles(0, math.rad(if isWest then 90 else -90), 0)
                Furniture.wallSconce(
                    parent,
                    string.format("Arandela %s %d-%d", side, level, index),
                    cf,
                    P.NeonWarm,
                    0.65,
                    8
                )
            end
        end
    end
end

function Cells.build(parent: Instance): Model
    local root = Kit.model(parent, "Celas")
    buildCellBlockWalls(root)

    for level = 2, 3 do
        for _, side in { "west", "east" } do
            for index = 1, L.cellCount do
                local number = L.cellNumber(side, level, index)
                buildCell(root, level, side, index, number)
            end
        end
    end

    root:SetAttribute("Total", L.cellCount * 2 * 2)
    root:SetAttribute("Beliches", 11)
    root:SetAttribute("Isolamento", 3)
    root:SetAttribute("PortasAbertas", 4)
    return root
end

return Cells

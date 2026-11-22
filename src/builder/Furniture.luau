local Compat = require("./Compat")
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

local Kit = require("./Kit")
local Palette = require("./Palette")

--[[
    Marcenaria, ferragens e mobiliário do presídio.
    Tudo é montado com blocos retangulares. As funções recebem um CFrame com
    origem no piso e usam coordenadas locais (X = comprimento, Y = altura,
    Z = profundidade), para que a mesma peça possa ser girada sem retrabalho.
]]

local Furniture = {}

local function block(
    parent: Instance,
    name: string,
    cf: CFrame,
    size: Vector3,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    return Kit.block(parent, name, cf, size, color, material, options)
end

local BOOK_COLORS = {
    Palette.BookRed,
    Palette.BookGreen,
    Palette.BookBlue,
    Palette.BookTan,
    Palette.OakDark,
    Palette.GreenDark,
}

function Furniture.books(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    count: number,
    seed: number?
)
    local rng = seed or 17
    local step = width / count
    for index = 1, count do
        rng = (rng * 1103515245 + 12345) % 2147483648
        local height = 2.1 + (rng % 90) / 100
        local thickness = step * (0.62 + ((rng // 7) % 18) / 100)
        local x = -width * 0.5 + step * (index - 0.5)
        block(
            parent,
            string.format("%s livro %d", name, index),
            cf * CFrame.new(x, height * 0.5, 0),
            Vector3.new(thickness, height, 1.15),
            BOOK_COLORS[(rng % #BOOK_COLORS) + 1],
            Palette.Materials.paper,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Furniture.shelf(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    height: number,
    depth: number,
    count: number,
    color: Color3,
    material: Enum.Material?,
    withBooks: boolean?,
    options: Kit.Options?
)
    local side = 0.22
    block(
        parent,
        name .. " lateral esquerda",
        cf * CFrame.new(-width * 0.5 + side * 0.5, height * 0.5, 0),
        Vector3.new(side, height, depth),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " lateral direita",
        cf * CFrame.new(width * 0.5 - side * 0.5, height * 0.5, 0),
        Vector3.new(side, height, depth),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " fundo",
        cf * CFrame.new(0, height * 0.5, -depth * 0.5 + 0.1),
        Vector3.new(width, height, 0.18),
        Kit.tint(color, -0.08),
        material,
        options
    )
    local gap = (height - 0.4) / count
    for index = 0, count do
        local y = 0.2 + gap * index
        block(
            parent,
            string.format("%s prateleira %d", name, index + 1),
            cf * CFrame.new(0, y, 0),
            Vector3.new(width - side * 2, 0.16, depth - 0.3),
            color,
            material,
            options
        )
        if withBooks and index < count then
            local rows = math.max(1, math.floor(width / 1.7))
            local rowWidth = (width - side * 2) / rows
            for row = 1, rows do
                local x = -width * 0.5 + side + rowWidth * (row - 0.5)
                Furniture.books(
                    parent,
                    name .. " " .. index .. "-" .. row,
                    cf * CFrame.new(x, y + 0.18, 0.05),
                    rowWidth - 0.35,
                    math.max(3, math.floor(rowWidth / 0.55)),
                    index * 31 + row * 7
                )
            end
        end
    end
end

function Furniture.table(
    parent: Instance,
    name: string,
    cf: CFrame,
    length: number,
    width: number,
    height: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " tampo",
        cf * CFrame.new(0, height - 0.2, 0),
        Vector3.new(length, 0.28, width),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " saia",
        cf * CFrame.new(0, height - 0.62, 0),
        Vector3.new(length - 1.2, 0.55, width - 0.8),
        Kit.tint(color, -0.08),
        material,
        options
    )
    for _, xSign in { -1, 1 } do
        for _, zSign in { -1, 1 } do
            block(
                parent,
                string.format("%s perna %d%d", name, xSign, zSign),
                cf
                    * CFrame.new(
                        xSign * (length * 0.5 - 0.7),
                        height * 0.5,
                        zSign * (width * 0.5 - 0.65)
                    ),
                Vector3.new(0.3, height, 0.3),
                Kit.tint(color, -0.12),
                material,
                options
            )
        end
    end
end

function Furniture.desk(
    parent: Instance,
    name: string,
    cf: CFrame,
    length: number,
    width: number,
    height: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " tampo",
        cf * CFrame.new(0, height - 0.18, 0),
        Vector3.new(length, 0.3, width),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " lateral esquerda",
        cf * CFrame.new(-length * 0.5 + 0.35, (height - 0.3) * 0.5, 0),
        Vector3.new(0.55, height - 0.3, width - 0.3),
        Kit.tint(color, -0.1),
        material,
        options
    )
    block(
        parent,
        name .. " gaveteiro",
        cf * CFrame.new(length * 0.5 - 0.8, (height - 0.3) * 0.5, 0),
        Vector3.new(1.4, height - 0.3, width - 0.3),
        Kit.tint(color, -0.08),
        material,
        options
    )
    for index = 1, 3 do
        local y = 1.1 + (index - 1) * 1.55
        block(
            parent,
            string.format("%s gaveta %d", name, index),
            cf * CFrame.new(length * 0.5 - 0.8, y, width * 0.5 - 0.1),
            Vector3.new(1.1, 1.15, 0.12),
            Kit.tint(color, 0.04),
            material,
            options
        )
        block(
            parent,
            string.format("%s puxador %d", name, index),
            cf * CFrame.new(length * 0.5 - 0.8, y, width * 0.5 + 0.02),
            Vector3.new(0.45, 0.1, 0.1),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Furniture.chair(
    parent: Instance,
    name: string,
    cf: CFrame,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " assento",
        cf * CFrame.new(0, 2.75, 0),
        Vector3.new(2.4, 0.3, 2.3),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " encosto",
        cf * CFrame.new(0, 5.15, -1.02),
        Vector3.new(2.4, 2.6, 0.28),
        color,
        material,
        options
    )
    for _, xSign in { -1, 1 } do
        for _, zSign in { -1, 1 } do
            block(
                parent,
                string.format("%s perna %d%d", name, xSign, zSign),
                cf * CFrame.new(xSign * 0.95, 1.35, zSign * 0.9),
                Vector3.new(0.22, 2.7, 0.22),
                Kit.tint(color, -0.16),
                material,
                options
            )
        end
    end
end

function Furniture.stool(
    parent: Instance,
    name: string,
    cf: CFrame,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " assento",
        cf * CFrame.new(0, 2.35, 0),
        Vector3.new(1.7, 0.28, 1.7),
        color,
        material,
        options
    )
    for _, xSign in { -1, 1 } do
        for _, zSign in { -1, 1 } do
            block(
                parent,
                string.format("%s perna %d%d", name, xSign, zSign),
                cf * CFrame.new(xSign * 0.62, 1.15, zSign * 0.62),
                Vector3.new(0.18, 2.3, 0.18),
                Kit.tint(color, -0.16),
                material,
                options
            )
        end
    end
end

function Furniture.bench(
    parent: Instance,
    name: string,
    cf: CFrame,
    length: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " assento",
        cf * CFrame.new(0, 1.7, 0),
        Vector3.new(length, 0.32, 1.6),
        color,
        material,
        options
    )
    block(
        parent,
        name .. " encosto",
        cf * CFrame.new(0, 3.25, -0.72),
        Vector3.new(length, 1.8, 0.24),
        Kit.tint(color, -0.04),
        material,
        options
    )
    for _, xSign in { -1, 1 } do
        block(
            parent,
            string.format("%s perna %d", name, xSign),
            cf * CFrame.new(xSign * (length * 0.5 - 0.8), 0.85, 0),
            Vector3.new(0.35, 1.7, 1.4),
            Kit.tint(color, -0.16),
            material,
            options
        )
    end
end

function Furniture.lockerBank(
    parent: Instance,
    name: string,
    cf: CFrame,
    count: number,
    width: number,
    height: number,
    depth: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    local total = count * width
    block(
        parent,
        name .. " corpo",
        cf * CFrame.new(0, height * 0.5, 0),
        Vector3.new(total, height, depth),
        Kit.tint(color, -0.08),
        material,
        options
    )
    for index = 1, count do
        local x = -total * 0.5 + width * (index - 0.5)
        block(
            parent,
            string.format("%s porta %d", name, index),
            cf * CFrame.new(x, height * 0.5, depth * 0.5 + 0.06),
            Vector3.new(width - 0.16, height - 0.18, 0.14),
            color,
            material,
            options
        )
        block(
            parent,
            string.format("%s respiro %d", name, index),
            cf * CFrame.new(x, height - 1.3, depth * 0.5 + 0.15),
            Vector3.new(width * 0.5, 0.1, 0.04),
            Palette.Iron,
            Palette.Materials.iron,
            { collide = false, query = false, shadow = false }
        )
        block(
            parent,
            string.format("%s puxador %d", name, index),
            cf * CFrame.new(x + width * 0.3, height * 0.52, depth * 0.5 + 0.18),
            Vector3.new(0.12, 0.62, 0.12),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    block(
        parent,
        name .. " rodapé",
        cf * CFrame.new(0, 0.35, 0),
        Vector3.new(total, 0.7, depth + 0.12),
        Palette.Iron,
        Palette.Materials.iron,
        options
    )
end

function Furniture.cabinet(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    height: number,
    depth: number,
    color: Color3,
    material: Enum.Material?,
    options: Kit.Options?
)
    block(
        parent,
        name .. " corpo",
        cf * CFrame.new(0, height * 0.5, 0),
        Vector3.new(width, height, depth),
        Kit.tint(color, -0.06),
        material,
        options
    )
    block(
        parent,
        name .. " tampo",
        cf * CFrame.new(0, height + 0.12, 0),
        Vector3.new(width + 0.3, 0.24, depth + 0.3),
        Kit.tint(color, 0.08),
        material,
        options
    )
    local doors = math.max(2, math.floor(width / 2.6))
    for index = 1, doors do
        local x = -width * 0.5 + (width / doors) * (index - 0.5)
        block(
            parent,
            string.format("%s porta %d", name, index),
            cf * CFrame.new(x, height * 0.5, depth * 0.5 + 0.05),
            Vector3.new(width / doors - 0.16, height - 1.0, 0.1),
            color,
            material,
            options
        )
        block(
            parent,
            string.format("%s puxador %d", name, index),
            cf * CFrame.new(x + width / doors * 0.28, height * 0.58, depth * 0.5 + 0.14),
            Vector3.new(0.1, 0.5, 0.1),
            Palette.Brass,
            Palette.Materials.metal,
            { collide = false, query = false, shadow = false }
        )
    end
    block(
        parent,
        name .. " rodapé",
        cf * CFrame.new(0, 0.35, 0),
        Vector3.new(width, 0.7, depth + 0.08),
        Palette.Iron,
        Palette.Materials.iron,
        options
    )
end

function Furniture.bed(
    parent: Instance,
    name: string,
    cf: CFrame,
    length: number,
    width: number,
    blanket: Color3,
    options: Kit.Options?
)
    local frameColor = Palette.Iron
    local frameMaterial = Palette.Materials.metal
    local frameHeight = 2.1
    for _, xSign in { -1, 1 } do
        for _, zSign in { -1, 1 } do
            block(
                parent,
                string.format("%s pé %d%d", name, xSign, zSign),
                cf
                    * CFrame.new(
                        xSign * (length * 0.5 - 0.25),
                        frameHeight * 0.5,
                        zSign * (width * 0.5 - 0.2)
                    ),
                Vector3.new(0.18, frameHeight, 0.18),
                frameColor,
                frameMaterial,
                options
            )
        end
    end
    block(
        parent,
        name .. " estrado",
        cf * CFrame.new(0, frameHeight - 0.15, 0),
        Vector3.new(length, 0.2, width),
        frameColor,
        frameMaterial,
        options
    )
    block(
        parent,
        name .. " colchão",
        cf * CFrame.new(0, frameHeight + 0.35, 0),
        Vector3.new(length - 0.4, 0.55, width - 0.25),
        Palette.Linen,
        Palette.Materials.fabric,
        options
    )
    block(
        parent,
        name .. " cobertor",
        cf * CFrame.new(0.45, frameHeight + 0.66, 0),
        Vector3.new(length * 0.62, 0.14, width - 0.2),
        blanket,
        Palette.Materials.fabric,
        options
    )
    block(
        parent,
        name .. " travesseiro",
        cf * CFrame.new(-length * 0.5 + 1.1, frameHeight + 0.67, 0),
        Vector3.new(1.45, 0.34, width - 0.6),
        Palette.LinenWhite,
        Palette.Materials.fabric,
        options
    )
end

function Furniture.bunk(
    parent: Instance,
    name: string,
    cf: CFrame,
    length: number,
    width: number,
    blanket: Color3,
    options: Kit.Options?
)
    local frameColor = Palette.Iron
    local frameMaterial = Palette.Materials.metal
    local height = 7.1
    for _, xSign in { -1, 1 } do
        for _, zSign in { -1, 1 } do
            block(
                parent,
                string.format("%s montante %d%d", name, xSign, zSign),
                cf
                    * CFrame.new(
                        xSign * (length * 0.5 - 0.25),
                        height * 0.5,
                        zSign * (width * 0.5 - 0.2)
                    ),
                Vector3.new(0.2, height, 0.2),
                frameColor,
                frameMaterial,
                options
            )
        end
    end

    for level = 1, 2 do
        local deckY = if level == 1 then 2.3 else 5.9
        block(
            parent,
            name .. " estrado " .. level,
            cf * CFrame.new(0, deckY, 0),
            Vector3.new(length, 0.2, width),
            frameColor,
            frameMaterial,
            options
        )
        block(
            parent,
            name .. " colchão " .. level,
            cf * CFrame.new(0, deckY + 0.45, 0),
            Vector3.new(length - 0.4, 0.5, width - 0.25),
            Palette.Linen,
            Palette.Materials.fabric,
            options
        )
        block(
            parent,
            name .. " cobertor " .. level,
            cf * CFrame.new(0.5, deckY + 0.73, 0),
            Vector3.new(length * 0.58, 0.12, width - 0.2),
            blanket,
            Palette.Materials.fabric,
            options
        )
        block(
            parent,
            name .. " travesseiro " .. level,
            cf * CFrame.new(-length * 0.5 + 1.15, deckY + 0.74, 0),
            Vector3.new(1.35, 0.3, width - 0.6),
            Palette.LinenWhite,
            Palette.Materials.fabric,
            options
        )
    end

    for index = 1, 3 do
        block(
            parent,
            name .. " degrau " .. index,
            cf * CFrame.new(length * 0.5 - 0.8, 2.7 + index * 1.05, width * 0.5 - 0.25),
            Vector3.new(0.7, 0.14, 0.5),
            frameColor,
            frameMaterial,
            options
        )
    end
    block(
        parent,
        name .. " guarda",
        cf * CFrame.new(0, 6.35, width * 0.5 - 0.25),
        Vector3.new(length * 0.8, 0.5, 0.16),
        frameColor,
        frameMaterial,
        options
    )
end

function Furniture.toilet(parent: Instance, name: string, cf: CFrame, options: Kit.Options?)
    block(
        parent,
        name .. " base",
        cf * CFrame.new(0, 0.45, 0),
        Vector3.new(1.4, 0.9, 1.7),
        Palette.Ceramic,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " vaso",
        cf * CFrame.new(0, 1.0, 0.15),
        Vector3.new(1.55, 0.35, 1.85),
        Palette.Ceramic,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " assento",
        cf * CFrame.new(0, 1.22, 0.32),
        Vector3.new(1.35, 0.14, 1.35),
        Palette.CeramicBlue,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " caixa",
        cf * CFrame.new(0, 2.15, -0.72),
        Vector3.new(1.6, 1.75, 0.75),
        Palette.Ceramic,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " botão",
        cf * CFrame.new(0, 3.1, -0.72),
        Vector3.new(0.35, 0.14, 0.25),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
end

function Furniture.sink(parent: Instance, name: string, cf: CFrame, options: Kit.Options?)
    block(
        parent,
        name .. " pedestal",
        cf * CFrame.new(0, 1.15, 0),
        Vector3.new(0.65, 2.3, 0.65),
        Palette.Ceramic,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " cuba",
        cf * CFrame.new(0, 2.55, 0),
        Vector3.new(1.8, 0.45, 1.35),
        Palette.Ceramic,
        Palette.Materials.ceramic,
        options
    )
    block(
        parent,
        name .. " torneira",
        cf * CFrame.new(0, 3.2, -0.45),
        Vector3.new(0.16, 0.9, 0.16),
        Palette.Brass,
        Palette.Materials.metal,
        options
    )
    block(
        parent,
        name .. " bica",
        cf * CFrame.new(0, 3.6, -0.15),
        Vector3.new(0.12, 0.12, 0.65),
        Palette.Brass,
        Palette.Materials.metal,
        options
    )
end

function Furniture.pendantLamp(
    parent: Instance,
    name: string,
    cf: CFrame,
    drop: number,
    shadeWidth: number,
    shadeDepth: number,
    lightColor: Color3,
    brightness: number,
    range: number
)
    block(
        parent,
        name .. " haste",
        cf * CFrame.new(0, -drop * 0.5, 0),
        Vector3.new(0.12, drop, 0.12),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    local y = -drop
    block(
        parent,
        name .. " cúpula",
        cf * CFrame.new(0, y + 0.45, 0),
        Vector3.new(shadeWidth, 0.3, shadeDepth),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    for _, xSign in { -1, 1 } do
        block(
            parent,
            name .. " aba X " .. xSign,
            cf * CFrame.new(xSign * shadeWidth * 0.5, y + 0.12, 0),
            Vector3.new(0.12, 0.8, shadeDepth),
            Palette.Iron,
            Palette.Materials.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    for _, zSign in { -1, 1 } do
        block(
            parent,
            name .. " aba Z " .. zSign,
            cf * CFrame.new(0, y + 0.12, zSign * shadeDepth * 0.5),
            Vector3.new(shadeWidth, 0.8, 0.12),
            Palette.Iron,
            Palette.Materials.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    local diffuser = block(
        parent,
        name .. " difusor",
        cf * CFrame.new(0, y - 0.3, 0),
        Vector3.new(shadeWidth - 0.35, 0.1, shadeDepth - 0.35),
        lightColor,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(diffuser, lightColor, {
        name = "Luz do pendente",
        brightness = brightness,
        range = range,
        shadows = false,
    })
end

function Furniture.ceilingLight(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    depth: number,
    lightColor: Color3,
    brightness: number,
    range: number
)
    block(
        parent,
        name .. " caixilho",
        cf * CFrame.new(0, -0.12, 0),
        Vector3.new(width, 0.24, depth),
        Palette.IronLight,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    local diffuser = block(
        parent,
        name .. " difusor",
        cf * CFrame.new(0, -0.3, 0),
        Vector3.new(width - 0.25, 0.12, depth - 0.25),
        lightColor,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.surfaceLight(diffuser, lightColor, {
        name = "Luz do teto",
        brightness = brightness,
        range = range,
        face = Enum.NormalId.Bottom,
        shadows = false,
    })
end

function Furniture.wallSconce(
    parent: Instance,
    name: string,
    cf: CFrame,
    lightColor: Color3,
    brightness: number,
    range: number
)
    block(
        parent,
        name .. " base",
        cf * CFrame.new(0, 0, 0.18),
        Vector3.new(0.6, 0.9, 0.22),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " braço",
        cf * CFrame.new(0, 0.15, 0.85),
        Vector3.new(0.14, 0.14, 1.2),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " cúpula",
        cf * CFrame.new(0, 0.55, 1.25),
        Vector3.new(1.1, 0.18, 1.1),
        Palette.Brass,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    local bulb = block(
        parent,
        name .. " luz",
        cf * CFrame.new(0, 0.42, 1.25),
        Vector3.new(0.8, 0.12, 0.8),
        lightColor,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(bulb, lightColor, {
        name = "Luz da arandela",
        brightness = brightness,
        range = range,
        shadows = false,
    })
end

function Furniture.wallClock(parent: Instance, name: string, cf: CFrame)
    block(
        parent,
        name .. " caixa",
        cf * CFrame.new(0, 0, 0.12),
        Vector3.new(4.4, 4.4, 0.24),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " mostrador",
        cf * CFrame.new(0, 0, 0.27),
        Vector3.new(3.8, 3.8, 0.1),
        Palette.Paper,
        Palette.Materials.paper,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 12 do
        local angle = math.rad(index * 30)
        local x = math.sin(angle) * 1.55
        local y = math.cos(angle) * 1.55
        block(
            parent,
            string.format("%s marca %d", name, index),
            cf * CFrame.new(x, y, 0.34),
            Vector3.new(0.15, if index % 3 == 0 then 0.42 else 0.26, 0.05),
            Palette.Iron,
            Palette.Materials.iron,
            { collide = false, query = false, shadow = false }
        )
    end
    block(
        parent,
        name .. " ponteiro hora",
        cf * CFrame.new(0, 0.55, 0.36) * CFrame.Angles(0, 0, math.rad(-32)),
        Vector3.new(0.13, 1.15, 0.06),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " ponteiro minuto",
        cf * CFrame.new(0.7, 0.2, 0.37) * CFrame.Angles(0, 0, math.rad(-74)),
        Vector3.new(0.1, 1.65, 0.06),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
end

function Furniture.noticeBoard(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    height: number
)
    block(
        parent,
        name .. " moldura",
        cf * CFrame.new(0, 0, 0.14),
        Vector3.new(width + 0.5, height + 0.5, 0.28),
        Palette.OakDark,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " cortiça",
        cf * CFrame.new(0, 0, 0.3),
        Vector3.new(width, height, 0.12),
        Palette.OakLight,
        Palette.Materials.fabric,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 5 do
        local x = -width * 0.35 + ((index - 1) % 3) * width * 0.35
        local y = height * 0.22 - math.floor((index - 1) / 3) * height * 0.42
        block(
            parent,
            string.format("%s aviso %d", name, index),
            cf * CFrame.new(x, y, 0.39) * CFrame.Angles(0, 0, math.rad((index % 3) - 1)),
            Vector3.new(width * 0.24, height * 0.26, 0.04),
            Palette.Paper,
            Palette.Materials.paper,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Furniture.portrait(
    parent: Instance,
    name: string,
    cf: CFrame,
    width: number,
    height: number
)
    block(
        parent,
        name .. " moldura",
        cf * CFrame.new(0, 0, 0.14),
        Vector3.new(width + 0.45, height + 0.45, 0.28),
        Palette.BrassDark,
        Palette.Materials.metal,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " tela",
        cf * CFrame.new(0, 0, 0.31),
        Vector3.new(width, height, 0.08),
        Palette.PaintShadow,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " figura",
        cf * CFrame.new(0, -height * 0.12, 0.37),
        Vector3.new(width * 0.38, height * 0.52, 0.04),
        Palette.Walnut,
        Palette.Materials.paint,
        { collide = false, query = false, shadow = false }
    )
end

function Furniture.plant(parent: Instance, name: string, cf: CFrame, scale: number?)
    local s = scale or 1
    block(
        parent,
        name .. " vaso",
        cf * CFrame.new(0, 1.0 * s, 0),
        Vector3.new(2.0 * s, 2.0 * s, 2.0 * s),
        Palette.Terracotta,
        Palette.Materials.concrete,
        nil
    )
    block(
        parent,
        name .. " terra",
        cf * CFrame.new(0, 1.97 * s, 0),
        Vector3.new(1.7 * s, 0.18 * s, 1.7 * s),
        Palette.Soil,
        Palette.Materials.ground,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " caule",
        cf * CFrame.new(0, 3.2 * s, 0),
        Vector3.new(0.18 * s, 2.7 * s, 0.18 * s),
        Palette.Stem,
        Palette.Materials.wood,
        { collide = false, query = false, shadow = false }
    )
    for index = 1, 5 do
        local angle = (index - 1) * 1.256
        block(
            parent,
            name .. " folha " .. index,
            cf
                * CFrame.new(
                    math.cos(angle) * 0.75 * s,
                    (3.4 + (index % 3) * 0.45) * s,
                    math.sin(angle) * 0.75 * s
                )
                * CFrame.Angles(0, angle, math.rad(18)),
            Vector3.new(1.4 * s, 0.18 * s, 0.75 * s),
            if index % 2 == 0 then Palette.LeafLight else Palette.Leaf,
            Palette.Materials.grass,
            { collide = false, query = false, shadow = false }
        )
    end
end

function Furniture.column(
    parent: Instance,
    name: string,
    cf: CFrame,
    height: number,
    width: number,
    color: Color3?,
    material: Enum.Material?
)
    local stone = color or Palette.StoneLight
    local stoneMaterial = material or Palette.Materials.stone
    block(
        parent,
        name .. " plinto",
        cf * CFrame.new(0, 0.45, 0),
        Vector3.new(width + 1.0, 0.9, width + 1.0),
        Kit.tint(stone, -0.07),
        stoneMaterial,
        nil
    )
    block(
        parent,
        name .. " fuste",
        cf * CFrame.new(0, height * 0.5, 0),
        Vector3.new(width, height, width),
        stone,
        stoneMaterial,
        nil
    )
    block(
        parent,
        name .. " capitel",
        cf * CFrame.new(0, height - 0.45, 0),
        Vector3.new(width + 0.7, 0.9, width + 0.7),
        Kit.tint(stone, 0.06),
        stoneMaterial,
        nil
    )
    block(
        parent,
        name .. " ábaco",
        cf * CFrame.new(0, height - 0.05, 0),
        Vector3.new(width + 1.15, 0.28, width + 1.15),
        Kit.tint(stone, 0.1),
        stoneMaterial,
        nil
    )
end

function Furniture.lampPost(
    parent: Instance,
    name: string,
    cf: CFrame,
    height: number,
    lightColor: Color3,
    brightness: number,
    range: number
)
    block(
        parent,
        name .. " base",
        cf * CFrame.new(0, 0.6, 0),
        Vector3.new(1.8, 1.2, 1.8),
        Palette.StoneDark,
        Palette.Materials.stone,
        nil
    )
    block(
        parent,
        name .. " poste",
        cf * CFrame.new(0, height * 0.5, 0),
        Vector3.new(0.5, height, 0.5),
        Palette.Iron,
        Palette.Materials.iron,
        nil
    )
    block(
        parent,
        name .. " lanterna",
        cf * CFrame.new(0, height + 0.8, 0),
        Vector3.new(1.8, 2.0, 1.8),
        Palette.GlassAmber,
        Palette.Materials.glass,
        { transparency = 0.25, collide = false, query = false, shadow = false }
    )
    local cap = block(
        parent,
        name .. " coroa",
        cf * CFrame.new(0, height + 2.05, 0),
        Vector3.new(2.3, 0.4, 2.3),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    block(
        parent,
        name .. " arremate",
        cf * CFrame.new(0, height + 2.55, 0),
        Vector3.new(0.35, 0.7, 0.35),
        Palette.Iron,
        Palette.Materials.iron,
        { collide = false, query = false, shadow = false }
    )
    local bulb = block(
        parent,
        name .. " luz",
        cf * CFrame.new(0, height + 0.9, 0),
        Vector3.new(0.7, 1.1, 0.7),
        lightColor,
        Palette.Materials.neon,
        { collide = false, query = false, shadow = false }
    )
    Kit.pointLight(bulb, lightColor, {
        name = "Luz externa",
        brightness = brightness,
        range = range,
        shadows = false,
    })
    return cap
end

return Furniture

local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Kit de construção do Presídio Central.
    Toda a geometria é feita exclusivamente com Part / Block. Não há bolas,
    cilindros, wedges nem malhas: a linguagem do prédio é retangular, como a
    alvenaria, a cantaria e as grades de uma penitenciária clássica.
]]

local Kit = {}

export type Options = {
    collide: boolean?,
    query: boolean?,
    touch: boolean?,
    shadow: boolean?,
    transparency: number?,
    reflectance: number?,
    material: Enum.Material?,
}

local function applyOptions(part: BasePart, options: Options?)
    local o = options or {}
    part.Anchored = true
    part.CanCollide = if o.collide == nil then true else o.collide
    part.CanQuery = if o.query == nil then true else o.query
    part.CanTouch = if o.touch == nil then true else o.touch
    part.CastShadow = if o.shadow == nil then true else o.shadow
    part.Transparency = o.transparency or 0
    part.Reflectance = o.reflectance or 0
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    if part:IsA("Part") then
        part.Shape = Enum.PartType.Block
    end
end

function Kit.folder(parent: Instance, name: string): Folder
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

function Kit.model(parent: Instance, name: string): Model
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    return model
end

function Kit.part(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame,
    color: Color3,
    material: Enum.Material?,
    options: Options?
): Part
    assert(size.X > 0 and size.Y > 0 and size.Z > 0, "Peça com tamanho inválido: " .. name)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    applyOptions(part, options)
    part.Parent = parent
    return part
end

function Kit.block(
    parent: Instance,
    name: string,
    cframe: CFrame,
    size: Vector3,
    color: Color3,
    material: Enum.Material?,
    options: Options?
): Part
    return Kit.part(parent, name, size, cframe, color, material, options)
end

--[[
    Caixa alinhada aos eixos a partir de dois cantos. É o tijolo básico da
    construção: paredes, lajes, móveis e guarnições saem todos daqui.
]]
function Kit.span(
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
    options: Options?
): Part
    return Kit.part(
        parent,
        name,
        Vector3.new(maxX - minX, maxY - minY, maxZ - minZ),
        CFrame.new((minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5),
        color,
        material,
        options
    )
end

-- CFrame helpers -------------------------------------------------------------
function Kit.at(x: number, y: number, z: number): CFrame
    return CFrame.new(x, y, z)
end

function Kit.rotated(x: number, y: number, z: number, rx: number, ry: number, rz: number): CFrame
    return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
end

function Kit.offset(base: CFrame, x: number, y: number, z: number): CFrame
    return base * CFrame.new(x, y, z)
end

-- Grades e corrimãos ---------------------------------------------------------
local function baluster(
    parent: Instance,
    name: string,
    cframe: CFrame,
    height: number,
    color: Color3,
    material: Enum.Material?,
    options: Options?
)
    return Kit.block(
        parent,
        name,
        cframe * CFrame.new(0, height * 0.5, 0),
        Vector3.new(0.09, height, 0.09),
        color,
        material,
        options
    )
end

--[[
    Corrimão reto ao longo de X. Base do corrimão em `y`; altura total em
    `height`. Usa apenas barras retangulares, como as grades fundidas do
    presídio.
]]
function Kit.railingX(
    parent: Instance,
    name: string,
    x1: number,
    x2: number,
    z: number,
    y: number,
    height: number,
    color: Color3,
    material: Enum.Material?,
    options: Options?
)
    local length = x2 - x1
    if length <= 0.1 then
        return
    end
    local midX = (x1 + x2) * 0.5
    local railOptions = table.clone(options or {})
    railOptions.collide = false
    railOptions.query = false
    railOptions.shadow = false

    Kit.block(
        parent,
        name .. " corrimão",
        CFrame.new(midX, y + height, z),
        Vector3.new(length, 0.16, 0.18),
        color,
        material,
        railOptions
    )
    Kit.block(
        parent,
        name .. " travessa",
        CFrame.new(midX, y + height * 0.52, z),
        Vector3.new(length, 0.09, 0.1),
        color,
        material,
        railOptions
    )
    Kit.block(
        parent,
        name .. " rodapé",
        CFrame.new(midX, y + 0.22, z),
        Vector3.new(length, 0.2, 0.14),
        color,
        material,
        railOptions
    )

    local posts = math.max(2, math.ceil(length / 6) + 1)
    for index = 1, posts do
        local x = x1 + (x2 - x1) * ((index - 1) / (posts - 1))
        Kit.block(
            parent,
            string.format("%s montante %d", name, index),
            CFrame.new(x, y + height * 0.5, z),
            Vector3.new(0.18, height, 0.2),
            color,
            material,
            railOptions
        )
    end

    local count = math.max(1, math.floor(length / 1.5))
    for index = 1, count do
        local x = x1 + (length * (index - 0.5)) / count
        baluster(
            parent,
            string.format("%s balaústre %d", name, index),
            CFrame.new(x, y + 0.3, z),
            height - 0.3,
            color,
            material,
            railOptions
        )
    end
end

function Kit.railingZ(
    parent: Instance,
    name: string,
    z1: number,
    z2: number,
    x: number,
    y: number,
    height: number,
    color: Color3,
    material: Enum.Material?,
    options: Options?
)
    local length = z2 - z1
    if length <= 0.1 then
        return
    end
    local midZ = (z1 + z2) * 0.5
    local railOptions = table.clone(options or {})
    railOptions.collide = false
    railOptions.query = false
    railOptions.shadow = false

    Kit.block(
        parent,
        name .. " corrimão",
        CFrame.new(x, y + height, midZ),
        Vector3.new(0.18, 0.16, length),
        color,
        material,
        railOptions
    )
    Kit.block(
        parent,
        name .. " travessa",
        CFrame.new(x, y + height * 0.52, midZ),
        Vector3.new(0.1, 0.09, length),
        color,
        material,
        railOptions
    )
    Kit.block(
        parent,
        name .. " rodapé",
        CFrame.new(x, y + 0.22, midZ),
        Vector3.new(0.14, 0.2, length),
        color,
        material,
        railOptions
    )

    local posts = math.max(2, math.ceil(length / 6) + 1)
    for index = 1, posts do
        local z = z1 + (z2 - z1) * ((index - 1) / (posts - 1))
        Kit.block(
            parent,
            string.format("%s montante %d", name, index),
            CFrame.new(x, y + height * 0.5, z),
            Vector3.new(0.2, height, 0.18),
            color,
            material,
            railOptions
        )
    end

    local count = math.max(1, math.floor(length / 1.5))
    for index = 1, count do
        local z = z1 + (length * (index - 0.5)) / count
        baluster(
            parent,
            string.format("%s balaústre %d", name, index),
            CFrame.new(x, y + 0.3, z),
            height - 0.3,
            color,
            material,
            railOptions
        )
    end
end

--[[
    Série de grades verticais dentro de um vão retangular. É usada nas celas,
    nas janelas altas e nos portões, sempre com barras de seção quadrada.
]]
function Kit.barsX(
    parent: Instance,
    name: string,
    x1: number,
    x2: number,
    centerY: number,
    z: number,
    height: number,
    spacing: number,
    color: Color3,
    material: Enum.Material?,
    thickness: number?,
    options: Options?
)
    local t = thickness or 0.12
    local count = math.max(1, math.floor((x2 - x1) / spacing))
    for index = 1, count do
        local x = x1 + ((x2 - x1) * (index - 0.5)) / count
        Kit.block(
            parent,
            string.format("%s barra %d", name, index),
            CFrame.new(x, centerY, z),
            Vector3.new(t, height, t),
            color,
            material,
            options
        )
    end
end

function Kit.barsZ(
    parent: Instance,
    name: string,
    z1: number,
    z2: number,
    centerY: number,
    x: number,
    height: number,
    spacing: number,
    color: Color3,
    material: Enum.Material?,
    thickness: number?,
    options: Options?
)
    local t = thickness or 0.12
    local count = math.max(1, math.floor((z2 - z1) / spacing))
    for index = 1, count do
        local z = z1 + ((z2 - z1) * (index - 0.5)) / count
        Kit.block(
            parent,
            string.format("%s barra %d", name, index),
            CFrame.new(x, centerY, z),
            Vector3.new(t, height, t),
            color,
            material,
            options
        )
    end
end

-- Luzes ----------------------------------------------------------------------
export type LightOptions = {
    name: string?,
    brightness: number?,
    range: number?,
    shadows: boolean?,
    angle: number?,
    face: Enum.NormalId?,
}

function Kit.pointLight(parent: BasePart, color: Color3, options: LightOptions?): PointLight
    local o = options or {}
    local light = Instance.new("PointLight")
    light.Name = o.name or "Luz"
    light.Color = color
    light.Brightness = o.brightness or 1
    light.Range = o.range or 12
    light.Shadows = if o.shadows == nil then true else o.shadows
    light.Parent = parent
    return light
end

function Kit.spotLight(parent: BasePart, color: Color3, options: LightOptions?): SpotLight
    local o = options or {}
    local light = Instance.new("SpotLight")
    light.Name = o.name or "Foco"
    light.Color = color
    light.Brightness = o.brightness or 1
    light.Range = o.range or 14
    light.Angle = o.angle or 70
    light.Face = o.face or Enum.NormalId.Front
    light.Shadows = if o.shadows == nil then true else o.shadows
    light.Parent = parent
    return light
end

function Kit.surfaceLight(parent: BasePart, color: Color3, options: LightOptions?): SurfaceLight
    local o = options or {}
    local light = Instance.new("SurfaceLight")
    light.Name = o.name or "Luz de superfície"
    light.Color = color
    light.Brightness = o.brightness or 1
    light.Range = o.range or 10
    light.Angle = o.angle or 120
    light.Face = o.face or Enum.NormalId.Front
    light.Shadows = if o.shadows == nil then false else o.shadows
    light.Parent = parent
    return light
end

-- Utilitários ----------------------------------------------------------------
function Kit.tint(color: Color3, amount: number): Color3
    if amount >= 0 then
        return color:Lerp(Color3.new(1, 1, 1), amount)
    end
    return color:Lerp(Color3.new(0, 0, 0), -amount)
end

function Kit.stripes(
    parent: Instance,
    name: string,
    cframe: CFrame,
    totalWidth: number,
    stripWidth: number,
    height: number,
    depth: number,
    count: number,
    color: Color3,
    material: Enum.Material?,
    options: Options?
)
    local step = totalWidth / count
    for index = 1, count do
        local x = -totalWidth * 0.5 + step * (index - 0.5)
        Kit.block(
            parent,
            name .. " " .. index,
            cframe * CFrame.new(x, 0, 0),
            Vector3.new(stripWidth, height, depth),
            color,
            material,
            options
        )
    end
end

return Kit

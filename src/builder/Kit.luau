local Compat = require("./Compat")
local Instance = Compat.Instance
local CFrame = Compat.CFrame
local Color3 = Compat.Color3
local Vector3 = Compat.Vector3
local Enum = Compat.Enum

--[[
    Kit de construção usado pelo gerador da Casa 27.
    Mantém toda a geometria ancorada, sem scripts e com propriedades seguras
    para um lugar focado em exploração e composição visual.
]]

local Kit = {}

export type Options = {
    collide: boolean?,
    query: boolean?,
    touch: boolean?,
    shadow: boolean?,
    transparency: number?,
    reflectance: number?,
    shape: Enum.PartType?,
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
    if o.shape then
        part.Shape = o.shape
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

function Kit.box(
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

function Kit.sphere(
    parent: Instance,
    name: string,
    cframe: CFrame,
    size: Vector3,
    color: Color3,
    material: Enum.Material?,
    options: Options?
): Part
    local merged = table.clone(options or {})
    merged.shape = Enum.PartType.Ball
    return Kit.part(parent, name, size, cframe, color, material, merged)
end

function Kit.cylinder(
    parent: Instance,
    name: string,
    cframe: CFrame,
    length: number,
    diameter: number,
    color: Color3,
    material: Enum.Material?,
    axis: string?,
    options: Options?
): Part
    local merged = table.clone(options or {})
    merged.shape = Enum.PartType.Cylinder
    local rotation = CFrame.new()
    if axis == "y" then
        rotation = CFrame.Angles(0, 0, math.rad(90))
    elseif axis == "z" then
        rotation = CFrame.Angles(0, math.rad(90), 0)
    end
    return Kit.part(
        parent,
        name,
        Vector3.new(length, diameter, diameter),
        cframe * rotation,
        color,
        material,
        merged
    )
end

function Kit.rodBetween(
    parent: Instance,
    name: string,
    from: Vector3,
    to: Vector3,
    diameter: number,
    color: Color3,
    material: Enum.Material?,
    options: Options?
): Part
    local delta = to - from
    local length = delta.Magnitude
    local center = from + delta * 0.5
    local xAxis = if length > 0.0001 then delta.Unit else Vector3.xAxis
    local reference = if math.abs(xAxis.Y) > 0.95 then Vector3.zAxis else Vector3.yAxis
    local zAxis = xAxis:Cross(reference).Unit
    local yAxis = zAxis:Cross(xAxis).Unit
    local rotation = CFrame.fromMatrix(Vector3.zero, xAxis, yAxis, zAxis)

    local merged = table.clone(options or {})
    merged.shape = Enum.PartType.Cylinder
    return Kit.part(
        parent,
        name,
        Vector3.new(length, diameter, diameter),
        CFrame.new(center) * rotation,
        color,
        material,
        merged
    )
end

function Kit.wedge(
    parent: Instance,
    name: string,
    cframe: CFrame,
    size: Vector3,
    color: Color3,
    material: Enum.Material?,
    options: Options?
): WedgePart
    local part = Instance.new("WedgePart")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    applyOptions(part, options)
    part.Parent = parent
    return part
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

-- Luzes ----------------------------------------------------------------------
export type LightOptions = {
    name: string?,
    brightness: number?,
    range: number?,
    shadows: boolean?,
    angle: number?,
    face: Enum.NormalId?,
}

function Kit.pointLight(
    parent: BasePart,
    color: Color3,
    options: LightOptions?
): PointLight
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

function Kit.spotLight(
    parent: BasePart,
    color: Color3,
    options: LightOptions?
): SpotLight
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

function Kit.surfaceLight(
    parent: BasePart,
    color: Color3,
    options: LightOptions?
): SurfaceLight
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
        Kit.box(
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

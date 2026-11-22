--!strict
--[[
    Exporta a geometria gerada para preview/scene.json.
    O visualizador web lê esse arquivo; ele não é usado pelo Roblox.
]]

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")

local Enum = roblox.Enum

local House = require("../src/builder/House")

local house = House.build(nil)

local parts = {}
local lights = {}

local roomNames = {
    Cozinha = "Cozinha",
    Sala = "Sala",
    Quarto = "Quarto",
    Banheiro = "Banheiro",
    Jantar = "Jantar",
    Entrada = "Entrada",
}

local function round(value: number, digits: number?): number
    local factor = 10 ^ (digits or 4)
    return math.round(value * factor) / factor
end

local function ancestors(instance: Instance): { string }
    local names = {}
    local current: Instance? = instance.Parent
    while current do
        table.insert(names, current.Name)
        current = current.Parent
    end
    return names
end

local function hasAncestorNamed(names: { string }, expected: string): boolean
    for _, name in names do
        if name == expected then
            return true
        end
    end
    return false
end

local function layerFor(instance: Instance): string
    local names = ancestors(instance)
    if hasAncestorNamed(names, "Teto") then
        return "ceiling"
    elseif hasAncestorNamed(names, "ParedesExternas") then
        return "outerWalls"
    elseif hasAncestorNamed(names, "ParedesInternas") then
        return "innerWalls"
    elseif hasAncestorNamed(names, "Janelas") then
        return "windows"
    elseif hasAncestorNamed(names, "Molduras") then
        return "trim"
    elseif hasAncestorNamed(names, "Pisos") then
        return "floor"
    elseif hasAncestorNamed(names, "Exterior") then
        return "exterior"
    elseif hasAncestorNamed(names, "Estrutura") then
        return "structure"
    end
    return "interior"
end

local function roomFor(instance: Instance): string
    local names = ancestors(instance)
    for internalName, publicName in roomNames do
        if hasAncestorNamed(names, internalName) then
            return publicName
        end
    end
    return "Estrutura"
end

local function serializePart(part: BasePart)
    if part.Transparency >= 1 then
        return
    end
    if part:IsA("SpawnLocation") then
        return
    end

    local shape = "Block"
    if part:IsA("Part") and part.Shape ~= Enum.PartType.Block then
        shape = part.Shape.Name
    elseif part:IsA("WedgePart") then
        shape = "Wedge"
    end

    local components = { part.CFrame:GetComponents() }
    local size = part.Size
    local color = part.Color
    table.insert(parts, {
        n = part.Name,
        k = part.ClassName,
        s = shape,
        cf = {
            round(components[1]),
            round(components[2]),
            round(components[3]),
            round(components[4], 5),
            round(components[5], 5),
            round(components[6], 5),
            round(components[7], 5),
            round(components[8], 5),
            round(components[9], 5),
            round(components[10], 5),
            round(components[11], 5),
            round(components[12], 5),
        },
        sz = { round(size.X), round(size.Y), round(size.Z) },
        c = { round(color.R, 4), round(color.G, 4), round(color.B, 4) },
        m = part.Material.Name,
        t = round(part.Transparency, 3),
        r = round(part.Reflectance, 3),
        cc = part.CanCollide,
        sh = part.CastShadow,
        layer = layerFor(part),
        room = roomFor(part),
    })
end

local function serializeLight(light: Light)
    local parent = light.Parent
    if not parent or not parent:IsA("BasePart") then
        return
    end
    if not light.Enabled then
        return
    end

    local p = parent.CFrame.Position
    local color = light.Color
    local entry = {
        n = light.Name,
        type = light.ClassName,
        p = { round(p.X), round(p.Y), round(p.Z) },
        c = { round(color.R, 4), round(color.G, 4), round(color.B, 4) },
        b = round(light.Brightness, 3),
        range = round(light.Range, 2),
        shadows = light.Shadows,
    }
    if light:IsA("SpotLight") then
        entry.angle = light.Angle
        entry.face = light.Face.Name
    elseif light:IsA("SurfaceLight") then
        entry.angle = light.Angle
        entry.face = light.Face.Name
    end
    table.insert(lights, entry)
end

local function walk(instance: Instance)
    if instance:IsA("BasePart") then
        serializePart(instance)
    elseif instance:IsA("Light") then
        serializeLight(instance)
    end
    for _, child in instance:GetChildren() do
        walk(child)
    end
end

walk(house)

local shots = {
    {
        id = "sala",
        label = "Sala de estar",
        mode = "interior",
        pos = { -2.65, 5.5, 2.35 },
        target = { -11.0, 2.75, 0.7 },
        fov = 58,
    },
    {
        id = "cozinha",
        label = "Cozinha",
        mode = "interior",
        pos = { 0.65, 5.35, -3.4 },
        target = { -3.1, 2.9, -9.25 },
        fov = 60,
    },
    {
        id = "quarto",
        label = "Quarto",
        mode = "interior",
        pos = { 4.8, 5.45, -2.25 },
        target = { 11.2, 2.5, -7.1 },
        fov = 60,
    },
    {
        id = "banheiro",
        label = "Banheiro",
        mode = "interior",
        pos = { -5.1, 4.95, 8.9 },
        target = { -11.3, 3.5, 6.6 },
        fov = 58,
    },
    {
        id = "jantar",
        label = "Jantar",
        mode = "interior",
        pos = { 4.4, 5.35, 2.9 },
        target = { 9.9, 3.0, 6.5 },
        fov = 58,
    },
    {
        id = "entrada",
        label = "Entrada",
        mode = "interior",
        pos = { 1.55, 5.25, 5.7 },
        target = { -3.7, 3.55, 9.75 },
        fov = 58,
    },
    {
        id = "geral",
        label = "Maquete",
        mode = "dollhouse",
        pos = { 19.5, 23.5, 24.5 },
        target = { -0.4, 1.4, 0.2 },
        fov = 38,
    },
}

local data = {
    meta = {
        title = "Casa 27",
        subtitle = "Um mundo aberto do tamanho de uma casa.",
        description = "Interior de 44 m² em escala real, 100% construído em Luau e gerado de forma determinística.",
        dimensions = {
            width = 29,
            depth = 21,
            height = 9.2,
            unit = "studs",
            studsPerMeter = 3.571,
            areaSquareMeters = 44,
        },
        counts = {
            parts = #parts,
            lights = #lights,
        },
        generatedBy = "tools/export_scene.luau",
        shots = shots,
    },
    parts = parts,
    lights = lights,
}

local output = serde.encode("json", data, true)
fs.writeFile("preview/scene.json", output)
print(string.format("[casa27] preview/scene.json: %d peças, %d luzes, %.1f KB", #parts, #lights, #output / 1024))

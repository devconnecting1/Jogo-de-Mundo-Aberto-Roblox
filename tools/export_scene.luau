--!strict
--[[
    Exporta a geometria gerada para preview/scene.json.
    O visualizador web lê esse arquivo; ele não é usado pelo Roblox.
]]

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")

local Enum = roblox.Enum

local Prison = require("../src/builder/Prison")

local prison = Prison.build(nil)

local parts = {}
local lights = {}

local roomNames = {
    HallCentral = "Hall Central",
    Celas = "Celas",
    Refeitorio = "Refeitório",
    Cozinha = "Cozinha",
    Lavanderia = "Lavanderia",
    Enfermaria = "Enfermaria",
    Visitas = "Visitas",
    Triagem = "Triagem",
    Entrada = "Entrada",
    Administracao = "Diretoria",
    Escritorio = "Escritório",
    Controle = "Controle",
    Alojamento = "Alojamento",
    Registro = "Registro",
    Arquivo = "Arquivo",
    SalaDeGuarda = "Sala de Guarda",
    ChefeDeGuarda = "Chefe de Guarda",
    Plantao = "Plantão",
    Biblioteca = "Biblioteca",
    SalaDeAula = "Sala de Aula",
    Capela = "Capela",
    ArquivoMorto = "Arquivo Morto",
    Oficina = "Oficina",
    CasaDeMaquinas = "Casa de Máquinas",
    Patio = "Pátio",
    TorreDeVigia = "Torre de Vigia",
    Terreno = "Terreno",
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

walk(prison)

local shots = {
    {
        id = "geral",
        label = "Maquete do complexo",
        mode = "dollhouse",
        pos = { -138, 108, 128 },
        target = { -6, 6, 0 },
        fov = 45,
    },
    {
        id = "fachada",
        label = "Fachada principal",
        mode = "interior",
        pos = { 0, 30, 102 },
        target = { 0, 17, 38 },
        fov = 48,
    },
    {
        id = "atrio",
        label = "Átrio das galerias",
        mode = "interior",
        pos = { 18, 8.5, 20 },
        target = { -14, 16, -12 },
        fov = 72,
    },
    {
        id = "galeria",
        label = "Galeria das celas",
        mode = "interior",
        pos = { 10, 16.5, 14 },
        target = { -26, 15.0, -8 },
        fov = 70,
    },
    {
        id = "cela",
        label = "Cela 109",
        mode = "interior",
        pos = { 26.6, 18.4, -15.43 },
        target = { 37.3, 16.2, -15.43 },
        fov = 80,
    },
    {
        id = "refeitorio",
        label = "Refeitório",
        mode = "interior",
        pos = { -91.5, 5.8, 26.5 },
        target = { -58, 7.8, -12 },
        fov = 64,
    },
    {
        id = "cozinha",
        label = "Cozinha industrial",
        mode = "interior",
        pos = { -27.2, 5.8, 4.0 },
        target = { -36.0, 4.8, -22.0 },
        fov = 64,
    },
    {
        id = "enfermaria",
        label = "Enfermaria",
        mode = "interior",
        pos = { 27.2, 5.8, 25.0 },
        target = { 36.0, 4.8, 15.0 },
        fov = 64,
    },
    {
        id = "patio",
        label = "Pátio de exercícios",
        mode = "interior",
        pos = { 62, 13.5, 29 },
        target = { 96, 9.0, -14 },
        fov = 62,
    },
}

local data = {
    meta = {
        title = "Presídio Central",
        subtitle = "Um showcase de arquitetura prisional clássica.",
        description = "Complexo prisional de três pavimentos, 100% construído com Parts retangulares e gerado de forma determinística.",
        dimensions = {
            width = 228,
            depth = 114,
            height = 56.5,
            unit = "studs",
            studsPerMeter = 3.571,
            areaSquareMeters = 2038,
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
print(
    string.format(
        "[presidio] preview/scene.json: %d peças, %d luzes, %.1f KB",
        #parts,
        #lights,
        #output / 1024
    )
)

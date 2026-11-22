--!strict
--[[
    Valida o .rbxlx produzido pelo Rojo, e não apenas o modelo intermediário.
    Uso: lune run tools/validate_place.luau [caminho-do-place]
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local Enum = roblox.Enum
local path = if process.args[1] then process.args[1] else "build/PrisaoCentral.rbxlx"

local readOk, contents = pcall(fs.readFile, path)
assert(readOk, "Place não encontrado: " .. path)

local game = roblox.deserializePlace(contents)

local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local prison = workspace:FindFirstChild("PrisaoCentral")
assert(prison, "O place não contém o modelo PrisaoCentral")
assert(prison:IsA("Model"), "PrisaoCentral deveria ser um Model")

local totals = {
    parts = 0,
    lights = 0,
    scripts = 0,
    spawns = 0,
    humanoids = 0,
    guis = 0,
    nonBlock = 0,
}

local function walk(instance: Instance)
    if instance:IsA("SpawnLocation") then
        totals.spawns += 1
    end
    if instance:IsA("BasePart") then
        totals.parts += 1
        if not instance.Anchored then
            error("Parte não ancorada no place final: " .. instance:GetFullName(), 0)
        end
        if not instance:IsA("Part") or instance.Shape ~= Enum.PartType.Block then
            totals.nonBlock += 1
        end
    elseif instance:IsA("Light") then
        totals.lights += 1
    elseif instance:IsA("LuaSourceContainer") then
        totals.scripts += 1
    elseif instance:IsA("Humanoid") then
        totals.humanoids += 1
    elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") then
        totals.guis += 1
    end
    for _, child in instance:GetChildren() do
        walk(child)
    end
end

walk(workspace)

assert(totals.parts > 8000, "Place final com poucas peças")
assert(totals.parts < 12000, "Place final passou do orçamento de peças")
assert(totals.lights >= 100, "Place final sem iluminação prática suficiente")
assert(totals.lights <= 180, "Place final com luzes demais")
assert(totals.scripts == 0, "O place desta entrega não deve conter scripts")
assert(totals.spawns == 1, "Place final deve ter exatamente um SpawnLocation")
assert(totals.humanoids == 0, "O showcase não deve conter NPCs ou humanoides")
assert(totals.guis == 0, "O showcase não deve conter interfaces no mundo")
assert(totals.nonBlock == 0, "O place deve conter apenas Parts retangulares")

assert(prison:FindFirstChild("Estrutura") ~= nil, "Estrutura ausente no place final")
assert(prison:FindFirstChild("Ambientes") ~= nil, "Ambientes ausentes no place final")
assert(prison:FindFirstChild("Exterior") ~= nil, "Exterior ausente no place final")
assert(prison:FindFirstChild("Celas", true) ~= nil, "Bloco de celas ausente")
assert(prison:FindFirstChild("Refeitorio", true) ~= nil, "Refeitório ausente")
assert(prison:FindFirstChild("Patio", true) ~= nil, "Pátio ausente")
assert(prison:FindFirstChild("TorreDeVigia", true) ~= nil, "Torre de vigia ausente")
assert(prison:FindFirstChild("Terreno", true) ~= nil, "Terreno ausente")

assert(lighting:FindFirstChild("Atmosphere"), "Atmosphere ausente no place final")
assert(lighting:FindFirstChild("Bloom"), "Bloom ausente no place final")
assert(
    not workspace.StreamingEnabled,
    "StreamingEnabled deve ficar desligado neste showcase compacto"
)

local technologyOk, technology = pcall(function()
    return lighting.Technology
end)
if technologyOk then
    local label = tostring(technology)
    assert(
        string.find(label, "Future") ~= nil,
        "A iluminação final deve usar Future, recebeu " .. label
    )
end

print(
    string.format(
        "[place] válido: %s | %d peças | %d luzes | %d spawn(s) | %d scripts | %d NPCs | %d UIs",
        path,
        totals.parts,
        totals.lights,
        totals.spawns,
        totals.scripts,
        totals.humanoids,
        totals.guis
    )
)

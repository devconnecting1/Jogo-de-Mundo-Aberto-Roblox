--!strict
--[[
    Valida o .rbxlx produzido pelo Rojo, e não apenas o modelo intermediário.
    Uso: lune run tools/validate_place.luau [caminho-do-place]
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local path = if process.args[1] then process.args[1] else "build/Casa27.rbxlx"

local readOk, contents = pcall(fs.readFile, path)
assert(readOk, "Place não encontrado: " .. path)

local game = roblox.deserializePlace(contents)

local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local casa = workspace:FindFirstChild("Casa27")
assert(casa, "O place não contém o modelo Casa27")
assert(casa:IsA("Model"), "Casa27 deveria ser um Model")

local totals = {
    parts = 0,
    lights = 0,
    scripts = 0,
    spawns = 0,
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
    elseif instance:IsA("Light") then
        totals.lights += 1
    elseif instance:IsA("LuaSourceContainer") then
        totals.scripts += 1
    end
    for _, child in instance:GetChildren() do
        walk(child)
    end
end

walk(workspace)

assert(totals.parts > 1800, "Place final com poucas peças")
assert(totals.lights >= 18, "Place final sem iluminação prática suficiente")
assert(totals.scripts == 0, "O place desta entrega não deve conter scripts")
assert(totals.spawns >= 1, "Place final sem SpawnLocation")

assert(lighting:FindFirstChild("Atmosphere"), "Atmosphere ausente no place final")
assert(lighting:FindFirstChild("Bloom"), "Bloom ausente no place final")
assert(not workspace.StreamingEnabled, "StreamingEnabled deve ficar desligado nesta casa compacta")

local technologyOk, technology = pcall(function()
    return lighting.Technology
end)
if technologyOk then
    local label = tostring(technology)
    assert(string.find(label, "Future") ~= nil, "A iluminação final deve usar Future, recebeu " .. label)
end

print(
    string.format(
        "[place] válido: %s | %d peças | %d luzes | %d spawn(s) | %d scripts",
        path,
        totals.parts,
        totals.lights,
        totals.spawns,
        totals.scripts
    )
)

--!strict
--[[
    Gera src/world/PrisaoCentral.rbxm a partir do código-fonte em src/builder.
    Execute com: lune run tools/build_world.luau
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local Prison = require("../src/builder/Prison")

local outputPath = if process.args[1] then process.args[1] else "src/world/PrisaoCentral.rbxm"

local prison = Prison.build(nil)
assert(prison:IsA("Model"), "Prison.build deve retornar um Model")
assert(prison.Name == "PrisaoCentral", "O modelo raiz deve se chamar PrisaoCentral")

local serialized = roblox.serializeModel({ prison })
fs.writeFile(outputPath, serialized)

local parts = 0
local lights = 0
local scripts = 0
local spawns = 0
local function walk(instance: Instance)
    if instance:IsA("BasePart") then
        parts += 1
        assert(
            instance.Anchored,
            "Toda a geometria precisa estar ancorada: " .. instance:GetFullName()
        )
        if instance:IsA("SpawnLocation") then
            spawns += 1
        end
    elseif instance:IsA("Light") then
        lights += 1
    elseif instance:IsA("LuaSourceContainer") then
        scripts += 1
    end
    for _, child in instance:GetChildren() do
        walk(child)
    end
end
walk(prison)

print(string.format("[presidio] %s gerado", outputPath))
print(
    string.format(
        "[presidio] %d BaseParts, %d luzes, %d spawn(s), %d scripts",
        parts,
        lights,
        spawns,
        scripts
    )
)
print("[presidio] O mapa é estático, ancorado e não contém scripts.")

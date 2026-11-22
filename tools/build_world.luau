--!strict
--[[
    Gera src/world/Casa27.rbxm a partir do código-fonte em src/builder.
    Execute com: lune run tools/build_world.luau
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local House = require("../src/builder/House")

local outputPath = if process.args[1] then process.args[1] else "src/world/Casa27.rbxm"

local house = House.build(nil)
assert(house:IsA("Model"), "House.build deve retornar um Model")
assert(house.Name == "Casa27", "O modelo raiz deve se chamar Casa27")

local serialized = roblox.serializeModel({ house })
fs.writeFile(outputPath, serialized)

local parts = 0
local lights = 0
local scripts = 0
local function walk(instance: Instance)
    if instance:IsA("BasePart") then
        parts += 1
        assert(instance.Anchored, "Toda a geometria precisa estar ancorada: " .. instance:GetFullName())
    elseif instance:IsA("Light") then
        lights += 1
    elseif instance:IsA("LuaSourceContainer") then
        scripts += 1
    end
    for _, child in instance:GetChildren() do
        walk(child)
    end
end
walk(house)

print(string.format("[casa27] %s gerado", outputPath))
print(string.format("[casa27] %d BaseParts, %d luzes, %d scripts", parts, lights, scripts))
print("[casa27] O mapa é estático, ancorado e não contém scripts.")

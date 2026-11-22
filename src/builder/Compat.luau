--[[
    Tipos e construtores Roblox usados pelo compilador de mundo.
    Este módulo é exclusivo do Lune: a casa final é um .rbxm estático e não
    carrega este arquivo em runtime.
]]

local roblox = require("@lune/roblox")

return {
    Instance = roblox.Instance,
    CFrame = roblox.CFrame,
    Color3 = roblox.Color3,
    Vector3 = roblox.Vector3,
    Vector2 = roblox.Vector2,
    Enum = roblox.Enum,
    NumberSequence = roblox.NumberSequence,
    ColorSequence = roblox.ColorSequence,
    UDim = roblox.UDim,
    UDim2 = roblox.UDim2,
}

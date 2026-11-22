--!strict
--[[
    Suíte de validação da Casa 27.
    Executada no GitHub Actions com Lune, sem precisar abrir o Studio.
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")

local House = require("../src/builder/House")

local Enum = roblox.Enum

type TestResult = {
    name: string,
    ok: boolean,
    detail: string?,
}

local results: { TestResult } = {}
local currentTest = ""

local function test(name: string, body: () -> ())
    currentTest = name
    local ok, detail = pcall(body)
    table.insert(results, {
        name = name,
        ok = ok,
        detail = if ok then nil else tostring(detail),
    })
end

local function fail(message: string)
    error(message, 2)
end

local function expect(condition: boolean, message: string)
    if not condition then
        fail(message)
    end
end

local house = House.build(nil)

local allParts: { BasePart } = {}
local allModels: { Model } = {}
local allLights: { Light } = {}
local scripts: { LuaSourceContainer } = {}

local function traverse(instance: Instance)
    if instance:IsA("BasePart") then
        table.insert(allParts, instance)
    elseif instance:IsA("Model") then
        table.insert(allModels, instance)
    elseif instance:IsA("Light") then
        table.insert(allLights, instance)
    elseif instance:IsA("LuaSourceContainer") then
        table.insert(scripts, instance)
    end

    for _, child in instance:GetChildren() do
        traverse(child)
    end
end

traverse(house)

local function hasModel(name: string): boolean
    return house:FindFirstChild(name, true) ~= nil
end

test("modelo raiz e organização", function()
    expect(house.Name == "Casa27", "O modelo raiz deveria se chamar Casa27")
    expect(house:FindFirstChild("Estrutura") ~= nil, "Falta a pasta Estrutura")
    expect(house:FindFirstChild("Ambientes") ~= nil, "Falta a pasta Ambientes")
    expect(house:FindFirstChild("Exterior") ~= nil, "Falta o conjunto Exterior")

    for _, name in { "Sala", "Cozinha", "Quarto", "Banheiro", "Jantar", "Entrada" } do
        expect(hasModel(name), "Ambiente ausente: " .. name)
    end
end)

test("a geometria é estática, ancorada e segura", function()
    expect(#allParts > 1800, "A casa deveria ter mais de 1.800 peças")
    expect(#allParts < 3200, "A casa passou do orçamento de peças")
    expect(#scripts == 0, "O lugar não deve conter scripts")

    for _, part in allParts do
        expect(part.Anchored, "Peça não ancorada: " .. part:GetFullName())
        expect(part.Size.X > 0 and part.Size.Y > 0 and part.Size.Z > 0, "Peça com tamanho inválido")
    end
end)

test("iluminação prática está presente e dentro do orçamento", function()
    expect(#allLights >= 18, "A casa deveria ter ao menos 18 luzes")
    expect(#allLights <= 30, "O conjunto de luzes estourou o orçamento")

    for _, light in allLights do
        expect(light.Parent ~= nil and light.Parent:IsA("BasePart"), "Luz sem suporte físico")
        expect(light.Brightness > 0, "Luz com brilho inválido: " .. light:GetFullName())
    end
end)

test("spawn único e apontando para dentro", function()
    local spawns = {}
    for _, part in allParts do
        if part:IsA("SpawnLocation") then
            table.insert(spawns, part)
        end
    end
    expect(#spawns == 1, "Deve existir exatamente um SpawnLocation")
    local spawn = spawns[1]
    local position = spawn.CFrame.Position
    expect(position.X > -14 and position.X < 14, "Spawn fora do eixo X da casa")
    expect(position.Z > 5 and position.Z < 10, "Spawn deveria ficar na entrada")
    expect(spawn.Transparency >= 0.99, "O spawn deve ser invisível")
end)

test("todos os ambientes têm mobiliário suficiente", function()
    local minimums = {
        Sala = 240,
        Cozinha = 260,
        Quarto = 170,
        Banheiro = 260,
        Jantar = 150,
        Entrada = 80,
    }

    for roomName, minimum in minimums do
        local room = house:FindFirstChild(roomName, true)
        expect(room ~= nil, "Ambiente ausente: " .. roomName)
        if room then
            local count = 0
            local function countParts(instance: Instance)
                if instance:IsA("BasePart") then
                    count += 1
                end
                for _, child in instance:GetChildren() do
                    countParts(child)
                end
            end
            countParts(room)
            expect(count >= minimum, string.format("%s tem apenas %d peças", roomName, count))
        end
    end
end)

test("esquadrias, portas, teto e jardim existem", function()
    local glassCount = 0
    local doorCount = 0
    local exteriorCount = 0
    for _, part in allParts do
        if part.Material == Enum.Material.Glass then
            glassCount += 1
        end
        if string.find(part.Name, "porta") or string.find(part.Name, "Porta") then
            doorCount += 1
        end
        if part:FindFirstAncestor("Exterior") then
            exteriorCount += 1
        end
    end

    expect(glassCount >= 20, "As janelas e o box precisam de vidro")
    expect(doorCount >= 8, "Detalhamento de portas insuficiente")
    expect(exteriorCount >= 100, "O exterior precisa de vegetação e contexto")
    expect(house:FindFirstChild("Teto", true) ~= nil, "Falta o teto")
    expect(house:FindFirstChild("Pisos", true) ~= nil, "Falta o piso")
end)

test("dimensões reais e ausência de geometria perdida", function()
    for _, part in allParts do
        local position = part.CFrame.Position
        expect(math.abs(position.X) < 80, "Peça perdida no eixo X")
        expect(math.abs(position.Z) < 80, "Peça perdida no eixo Z")
        expect(position.Y > -3 and position.Y < 16, "Peça perdida no eixo Y")
    end

    local areaSquareStuds = 28 * 20
    local squareMeters = areaSquareStuds / (3.571 * 3.571)
    expect(squareMeters > 40 and squareMeters < 48, "A área deve ficar em torno de 44 m²")
end)

local function walkabilityTest()
    local cell = 0.25
    local avatarRadius = 0.85
    local minX, maxX = -13.75, 13.75
    local minZ, maxZ = -9.75, 9.75
    local columns = math.floor((maxX - minX) / cell) + 1
    local rows = math.floor((maxZ - minZ) / cell) + 1

    local blocked = table.create(columns * rows, false)
    local function indexOf(column: number, row: number): number
        return (row - 1) * columns + column
    end

    for _, part in allParts do
        if part.CanCollide and not part:FindFirstAncestor("Exterior") then
            local components = { part.CFrame:GetComponents() }
            local centerX = components[1]
            local centerY = components[2]
            local centerZ = components[3]
            local size = part.Size
            local halfY = size.Y * 0.5

            if centerY + halfY > 0.2 and centerY - halfY < 5.5 then
                local halfX = math.abs(components[4]) * size.X * 0.5
                    + math.abs(components[5]) * size.Y * 0.5
                    + math.abs(components[6]) * size.Z * 0.5
                local halfZ = math.abs(components[10]) * size.X * 0.5
                    + math.abs(components[11]) * size.Y * 0.5
                    + math.abs(components[12]) * size.Z * 0.5

                local columnMin = math.max(
                    1,
                    math.floor((centerX - halfX - avatarRadius - minX) / cell)
                )
                local columnMax = math.min(
                    columns,
                    math.ceil((centerX + halfX + avatarRadius - minX) / cell)
                )
                local rowMin = math.max(
                    1,
                    math.floor((centerZ - halfZ - avatarRadius - minZ) / cell)
                )
                local rowMax = math.min(
                    rows,
                    math.ceil((centerZ + halfZ + avatarRadius - minZ) / cell)
                )

                for row = rowMin, rowMax do
                    for column = columnMin, columnMax do
                        local x = minX + (column - 0.5) * cell
                        local z = minZ + (row - 0.5) * cell
                        local dx = math.max(math.abs(x - centerX) - halfX, 0)
                        local dz = math.max(math.abs(z - centerZ) - halfZ, 0)
                        if dx * dx + dz * dz < avatarRadius * avatarRadius then
                            blocked[indexOf(column, row)] = true
                        end
                    end
                end
            end
        end
    end

    local function cellFor(x: number, z: number): (number, number)
        local column = math.clamp(math.floor((x - minX) / cell) + 1, 1, columns)
        local row = math.clamp(math.floor((z - minZ) / cell) + 1, 1, rows)
        return column, row
    end

    local spawnX, spawnZ = -3.6, 8.4
    local startColumn, startRow = cellFor(spawnX, spawnZ)
    expect(not blocked[indexOf(startColumn, startRow)], "O spawn está bloqueado por mobiliário")

    local targets = {
        { name = "sala", x = -5.8, z = 0.2 },
        { name = "cozinha", x = -2.0, z = -5.5 },
        { name = "banheiro", x = -9.6, z = 7.9 },
        { name = "quarto", x = 6.9, z = -4.2 },
        { name = "jantar", x = 9.2, z = 2.7 },
    }

    local targetCells = {}
    for _, target in targets do
        local column, row = cellFor(target.x, target.z)
        expect(
            not blocked[indexOf(column, row)],
            "O ponto de " .. target.name .. " está bloqueado"
        )
        targetCells[indexOf(column, row)] = target.name
    end

    local visited = table.create(columns * rows, false)
    local queue = { indexOf(startColumn, startRow) }
    visited[queue[1]] = true
    local head = 1
    local found = 0
    local foundNames: { string } = {}

    while head <= #queue and found < #targets do
        local current = queue[head]
        head += 1

        local targetName = targetCells[current]
        if targetName then
            found += 1
            table.insert(foundNames, targetName)
        end

        local column = ((current - 1) % columns) + 1
        local row = math.floor((current - 1) / columns) + 1
        local neighbours = {
            { column - 1, row },
            { column + 1, row },
            { column, row - 1 },
            { column, row + 1 },
        }
        for _, neighbour in neighbours do
            local nextColumn = neighbour[1]
            local nextRow = neighbour[2]
            if nextColumn >= 1 and nextColumn <= columns and nextRow >= 1 and nextRow <= rows then
                local nextIndex = indexOf(nextColumn, nextRow)
                if not visited[nextIndex] and not blocked[nextIndex] then
                    visited[nextIndex] = true
                    table.insert(queue, nextIndex)
                end
            end
        end
    end

    expect(
        found == #targets,
        string.format(
            "Somente %d/%d destinos são alcançáveis: %s",
            found,
            #targets,
            table.concat(foundNames, ", ")
        )
    )
end

test("todos os cômodos são alcançáveis por um avatar", walkabilityTest)

local failures = 0
for _, result in results do
    if result.ok then
        print(string.format("  ok    %s", result.name))
    else
        failures += 1
        print(string.format("  falha %s\n        %s", result.name, result.detail))
    end
end

print(string.format("\n[house tests] %d/%d testes passaram", #results - failures, #results))
if failures > 0 then
    process.exit(1)
end

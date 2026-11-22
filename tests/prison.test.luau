--!strict
--[[
    Suíte de validação do Presídio Central.
    Executada no GitHub Actions com Lune, sem abrir o Studio.
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")

local Prison = require("../src/builder/Prison")

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

local prison = Prison.build(nil)

local allParts: { BasePart } = {}
local allModels: { Model } = {}
local allLights: { Light } = {}
local scripts: { LuaSourceContainer } = {}
local humanoids: { Humanoid } = {}
local guis: { Instance } = {}

local function traverse(instance: Instance)
    if instance:IsA("BasePart") then
        table.insert(allParts, instance)
    elseif instance:IsA("Model") then
        table.insert(allModels, instance)
    elseif instance:IsA("Light") then
        table.insert(allLights, instance)
    elseif instance:IsA("LuaSourceContainer") then
        table.insert(scripts, instance)
    elseif instance:IsA("Humanoid") then
        table.insert(humanoids, instance)
    elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") then
        table.insert(guis, instance)
    end
    for _, child in instance:GetChildren() do
        traverse(child)
    end
end

traverse(prison)

local function find(name: string): Instance?
    return prison:FindFirstChild(name, true)
end

local function countParts(root: Instance): number
    local count = 0
    local function walk(instance: Instance)
        if instance:IsA("BasePart") then
            count += 1
        end
        for _, child in instance:GetChildren() do
            walk(child)
        end
    end
    walk(root)
    return count
end

local function startsWith(value: string, prefix: string): boolean
    return string.sub(value, 1, #prefix) == prefix
end

test("modelo raiz, pastas e atributos", function()
    expect(prison.Name == "PrisaoCentral", "O modelo raiz deveria se chamar PrisaoCentral")
    expect(prison:FindFirstChild("Estrutura") ~= nil, "Falta a pasta Estrutura")
    expect(prison:FindFirstChild("Ambientes") ~= nil, "Falta a pasta Ambientes")
    expect(prison:FindFirstChild("Exterior") ~= nil, "Falta a pasta Exterior")
    expect(prison:GetAttribute("Pavimentos") == 3, "O presídio deve ter três pavimentos")
    expect(prison:GetAttribute("Celas") == 28, "A contagem de celas principais deve ser 28")
    expect(prison:GetAttribute("CelasDeTriagem") == 2, "A triagem deve ter duas celas")
    expect(prison:GetAttribute("RefeitorioLugares") == 48, "O refeitório deve ter 48 lugares")
end)

test("todos os ambientes e anexos existem", function()
    local ambient = prison:FindFirstChild("Ambientes")
    expect(ambient ~= nil, "Pasta Ambientes ausente")
    local required = {
        "HallCentral",
        "Celas",
        "Refeitorio",
        "Cozinha",
        "Lavanderia",
        "Enfermaria",
        "Visitas",
        "Triagem",
        "Entrada",
        "Administracao",
        "Escritorio",
        "Controle",
        "Alojamento",
        "Registro",
        "Arquivo",
        "SalaDeGuarda",
        "ChefeDeGuarda",
        "Plantao",
        "Biblioteca",
        "SalaDeAula",
        "Capela",
        "ArquivoMorto",
        "Oficina",
        "CasaDeMaquinas",
        "Patio",
    }
    for _, name in required do
        local model = ambient:FindFirstChild(name)
        expect(model ~= nil, "Ambiente ausente: " .. name)
        if model then
            expect(countParts(model) > 0, "Ambiente vazio: " .. name)
        end
    end
    local exterior = prison:FindFirstChild("Exterior")
    expect(exterior:FindFirstChild("Terreno") ~= nil, "Terreno ausente")
    expect(exterior:FindFirstChild("TorreDeVigia") ~= nil, "Torre de vigia ausente")
end)

test("a geometria é estática, ancorada e sem scripts ou NPCs", function()
    expect(#allParts > 8000, "O complexo deveria ter mais de 8.000 peças")
    expect(#allParts < 12000, "O complexo passou do orçamento de peças")
    expect(#scripts == 0, "O lugar não deve conter scripts")
    expect(#humanoids == 0, "O showcase não deve conter NPCs ou humanoides")
    expect(#guis == 0, "O showcase não deve conter interfaces no mundo")

    for _, part in allParts do
        expect(part.Anchored, "Peça não ancorada: " .. part:GetFullName())
        expect(
            part.Size.X > 0 and part.Size.Y > 0 and part.Size.Z > 0,
            "Peça com tamanho inválido"
        )
    end
end)

test("somente Parts retangulares, sem cilindros, esferas ou wedges", function()
    for _, part in allParts do
        expect(
            part:IsA("Part"),
            "Geometria não é Part: " .. part.ClassName .. " " .. part:GetFullName()
        )
        local body = part :: Part
        if body:IsA("Part") then
            expect(
                body.Shape == Enum.PartType.Block,
                "Geometria não retangular: " .. part:GetFullName()
            )
        end
    end
end)

test("spawn único e apontando para a entrada", function()
    local spawns = {}
    for _, part in allParts do
        if part:IsA("SpawnLocation") then
            table.insert(spawns, part)
        end
    end
    expect(#spawns == 1, "Deve existir exatamente um SpawnLocation")
    local spawn = spawns[1]
    local position = spawn.CFrame.Position
    expect(math.abs(position.X) < 5, "O spawn deve estar no eixo da entrada")
    expect(position.Z > 45 and position.Z < 58, "O spawn deve estar no pátio de entrada")
    expect(spawn.Transparency >= 0.99, "O spawn deve ser invisível")
end)

test("iluminação prática em quantidade coerente", function()
    expect(#allLights >= 100, "O complexo precisa de ao menos 100 luzes")
    expect(#allLights <= 180, "O conjunto de luzes estourou o orçamento")
    for _, light in allLights do
        expect(light.Parent ~= nil and light.Parent:IsA("BasePart"), "Luz sem suporte físico")
        expect(light.Brightness > 0, "Luz com brilho inválido: " .. light:GetFullName())
    end
end)

test("28 celas + 2 celas de triagem, com mobiliário completo", function()
    local cells = prison:FindFirstChild("Celas", true)
    expect(cells ~= nil, "Pasta de celas ausente")
    local cellModels = {}
    for _, child in cells:GetChildren() do
        if child:IsA("Model") and startsWith(child.Name, "Cela ") then
            table.insert(cellModels, child)
        end
    end
    expect(#cellModels == 28, string.format("Esperava 28 celas, encontrei %d", #cellModels))

    local byType = {}
    for _, cell in cellModels do
        local model = cell :: Model
        local parts = countParts(model)
        expect(parts >= 30, string.format("%s tem apenas %d peças", model.Name, parts))
        local function hasFragment(fragment: string): boolean
            local found = false
            local function search(instance: Instance)
                if instance:IsA("BasePart") and string.find(instance.Name, fragment) then
                    found = true
                end
                for _, child in instance:GetChildren() do
                    search(child)
                end
            end
            search(model)
            return found
        end
        expect(hasFragment("Porta da cela"), model.Name .. " sem porta")
        expect(hasFragment("Sanitário"), model.Name .. " sem sanitário")
        expect(hasFragment("Lavatório"), model.Name .. " sem lavatório")
        expect(hasFragment("Cama") or hasFragment("Beliche"), model.Name .. " sem cama ou beliche")
        local kind = model:GetAttribute("Tipo") or "Individual"
        byType[kind] = (byType[kind] or 0) + 1
    end
    expect((byType["Isolamento"] or 0) == 3, "Devem existir três celas de isolamento")
    expect((byType["Confiança"] or 0) == 1, "Deve existir uma cela de confiança")
    expect((byType["Beliche"] or 0) >= 10, "As celas com beliche são insuficientes")

    local triage = prison:FindFirstChild("Triagem", true)
    expect(triage:FindFirstChild("Cela de espera 1", true) ~= nil, "Cela de espera 1 ausente")
    expect(triage:FindFirstChild("Cela de espera 2", true) ~= nil, "Cela de espera 2 ausente")
end)

test("refeitório grande, cozinha, lavanderia e enfermaria equipados", function()
    local refectory = prison:FindFirstChild("Refeitorio", true)
    expect(countParts(refectory) >= 500, "O refeitório tem detalhe insuficiente")
    expect(refectory:GetAttribute("Lugares") == 48, "O refeitório deve ter 48 lugares")
    expect(refectory:GetAttribute("Mesas") == 6, "O refeitório deve ter seis mesas")

    local tables = 0
    for _, part in allParts do
        if startsWith(part.Name, "Mesa do refeitório ") and string.find(part.Name, "tampo") then
            tables += 1
        end
    end
    expect(tables == 6, string.format("Esperava seis mesas de refeitório, encontrei %d", tables))

    expect(countParts(prison:FindFirstChild("Cozinha", true)) >= 180, "Cozinha pouco equipada")
    expect(
        countParts(prison:FindFirstChild("Lavanderia", true)) >= 180,
        "Lavanderia pouco equipada"
    )
    expect(
        countParts(prison:FindFirstChild("Enfermaria", true)) >= 100,
        "Enfermaria pouco equipada"
    )
    expect(
        countParts(prison:FindFirstChild("Biblioteca", true)) >= 250,
        "Biblioteca pouco equipada"
    )
    expect(countParts(prison:FindFirstChild("Capela", true)) >= 150, "Capela pouco equipada")
end)

test("esquadrias, grades, portas e escadas existem", function()
    local glassCount = 0
    local doorCount = 0
    local barCount = 0
    local stepCount = 0
    local lightFixtures = 0
    for _, part in allParts do
        if part.Material == Enum.Material.Glass then
            glassCount += 1
        end
        if string.find(part.Name, "Porta") or string.find(part.Name, "porta") then
            doorCount += 1
        end
        if string.find(part.Name, "Grade") or string.find(part.Name, "grade") then
            barCount += 1
        end
        if string.find(part.Name, "degrau") or string.find(part.Name, "Degrau") then
            stepCount += 1
        end
        if part:FindFirstChildWhichIsA("Light") then
            lightFixtures += 1
        end
    end
    expect(glassCount >= 90, "As janelas, vitrais e lanternins precisam de vidro")
    expect(doorCount >= 40, "Detalhamento de portas insuficiente")
    expect(barCount >= 150, "As grades das celas e janelas são insuficientes")
    expect(stepCount >= 80, "As escadas de serviço estão incompletas")
    expect(lightFixtures >= 100, "Muitas luzes não estão apoiadas em luminárias")
end)

test("três pavimentos, lajes e medida coerente", function()
    local structure = prison:FindFirstChild("Estrutura")
    expect(structure:FindFirstChild("Pisos") ~= nil, "Pasta de pisos ausente")
    expect(structure:FindFirstChild("Teto") ~= nil, "Pasta de cobertura ausente")
    expect(
        prison:FindFirstChild("Laje oeste — primeiro pavimento", true) ~= nil,
        "Laje do primeiro pavimento ausente"
    )
    expect(
        prison:FindFirstChild("Laje oeste — segundo pavimento", true) ~= nil,
        "Laje do segundo pavimento ausente"
    )

    for _, part in allParts do
        local position = part.CFrame.Position
        expect(
            position.Y > -3 and position.Y < 70,
            "Peça perdida no eixo Y: " .. part:GetFullName()
        )
        expect(
            position.X > -110 and position.X < 125,
            "Peça perdida no eixo X: " .. part:GetFullName()
        )
        expect(
            position.Z > -58 and position.Z < 65,
            "Peça perdida no eixo Z: " .. part:GetFullName()
        )
    end
end)

-- Navegabilidade -------------------------------------------------------------
local function inRegions(x: number, z: number, regions: { any }): boolean
    for _, region in regions do
        if x >= region.minX and x <= region.maxX and z >= region.minZ and z <= region.maxZ then
            return true
        end
    end
    return false
end

local function walkability(
    levelName: string,
    y0: number,
    regions: { any },
    startX: number,
    startZ: number,
    targets: { any }
)
    local cell = 0.5
    local avatarRadius = 0.85
    local minX, maxX = -100, 118
    local minZ, maxZ = -50, 58
    local columns = math.floor((maxX - minX) / cell) + 1
    local rows = math.floor((maxZ - minZ) / cell) + 1

    local blocked = table.create(columns * rows, false)
    for _, part in allParts do
        if part.CanCollide then
            local components = { part.CFrame:GetComponents() }
            local centerX = components[1]
            local centerY = components[2]
            local centerZ = components[3]
            local size = part.Size
            local halfX = math.abs(components[4]) * size.X * 0.5
                + math.abs(components[5]) * size.Y * 0.5
                + math.abs(components[6]) * size.Z * 0.5
            local halfY = math.abs(components[7]) * size.X * 0.5
                + math.abs(components[8]) * size.Y * 0.5
                + math.abs(components[9]) * size.Z * 0.5
            local halfZ = math.abs(components[10]) * size.X * 0.5
                + math.abs(components[11]) * size.Y * 0.5
                + math.abs(components[12]) * size.Z * 0.5

            if centerY + halfY >= y0 + 0.4 and centerY - halfY <= y0 + 5.6 then
                local columnMin =
                    math.max(1, math.floor((centerX - halfX - avatarRadius - minX) / cell))
                local columnMax =
                    math.min(columns, math.ceil((centerX + halfX + avatarRadius - minX) / cell))
                local rowMin =
                    math.max(1, math.floor((centerZ - halfZ - avatarRadius - minZ) / cell))
                local rowMax =
                    math.min(rows, math.ceil((centerZ + halfZ + avatarRadius - minZ) / cell))
                for row = rowMin, rowMax do
                    for column = columnMin, columnMax do
                        local x = minX + (column - 0.5) * cell
                        local z = minZ + (row - 0.5) * cell
                        local dx = math.max(math.abs(x - centerX) - halfX, 0)
                        local dz = math.max(math.abs(z - centerZ) - halfZ, 0)
                        if dx * dx + dz * dz < avatarRadius * avatarRadius then
                            blocked[(row - 1) * columns + column] = true
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

    local function indexOf(column: number, row: number): number
        return (row - 1) * columns + column
    end

    local startColumn, startRow = cellFor(startX, startZ)
    expect(
        inRegions(startX, startZ, regions),
        levelName .. ": ponto inicial fora da área caminhável"
    )
    expect(not blocked[indexOf(startColumn, startRow)], levelName .. ": ponto inicial bloqueado")

    local targetCells = {}
    for _, target in targets do
        expect(
            inRegions(target.x, target.z, regions),
            levelName .. ": " .. target.name .. " fora da área caminhável"
        )
        local column, row = cellFor(target.x, target.z)
        expect(
            not blocked[indexOf(column, row)],
            levelName .. ": " .. target.name .. " bloqueado por mobiliário"
        )
        targetCells[indexOf(column, row)] = target.name
    end

    local visited = table.create(columns * rows, false)
    local queue = { indexOf(startColumn, startRow) }
    visited[queue[1]] = true
    local head = 1
    local found = 0
    local foundNames: { string } = {}

    while head <= #queue do
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
                local worldX = minX + (nextColumn - 0.5) * cell
                local worldZ = minZ + (nextRow - 0.5) * cell
                if
                    not visited[nextIndex]
                    and not blocked[nextIndex]
                    and inRegions(worldX, worldZ, regions)
                then
                    visited[nextIndex] = true
                    table.insert(queue, nextIndex)
                end
            end
        end
    end

    expect(
        found == #targets,
        string.format(
            "%s: somente %d/%d destinos alcançáveis: %s",
            levelName,
            found,
            #targets,
            table.concat(foundNames, ", ")
        )
    )
end

test("térreo navegável: entrada, hall, refeitório, alas, pátio e triagem", function()
    local regions = {
        { minX = -38.5, maxX = 38.5, minZ = -44.5, maxZ = 36.5 },
        { minX = -96.5, maxX = -42, minZ = -22.5, maxZ = 30.5 },
        { minX = -42, maxX = -38.5, minZ = 8, maxZ = 14 },
        { minX = 38.5, maxX = 45.5, minZ = 7, maxZ = 13 },
        { minX = 45.5, maxX = 108.5, minZ = -34.5, maxZ = 36.5 },
        { minX = -36, maxX = 36, minZ = 36.5, maxZ = 58 },
    }
    walkability("térreo", 0, regions, 0, 52, {
        { name = "hall", x = 0, z = 0 },
        { name = "refeitório", x = -70, z = 0 },
        { name = "cozinha", x = -28.5, z = -20 },
        { name = "lavanderia", x = 29, z = -17 },
        { name = "enfermaria", x = 29, z = 20 },
        { name = "visitas", x = -24, z = 35.0 },
        { name = "triagem", x = 26, z = 29 },
        { name = "oficina", x = -33, z = -35 },
        { name = "casa de máquinas", x = 24, z = -29 },
        { name = "pátio", x = 70, z = 0 },
    })
end)

test("primeiro pavimento navegável: celas, biblioteca, aula, diretoria e controle", function()
    local regions = {
        { minX = -38.5, maxX = -18, minZ = -27, maxZ = 27 },
        { minX = 18, maxX = 38.5, minZ = -27, maxZ = 27 },
        { minX = -18, maxX = 18, minZ = -27, maxZ = -20 },
        { minX = -18, maxX = 18, minZ = 20, maxZ = 27 },
        { minX = -38.5, maxX = 38.5, minZ = 27, maxZ = 36.5 },
        { minX = -38.5, maxX = -22, minZ = -46, maxZ = -27 },
        { minX = 22, maxX = 38.5, minZ = -46, maxZ = -27 },
        { minX = -6, maxX = 6, minZ = -46, maxZ = -27 },
        { minX = -22, maxX = -6, minZ = -46, maxZ = -42 },
        { minX = -10, maxX = -6, minZ = -42, maxZ = -27 },
        { minX = 6, maxX = 22, minZ = -46, maxZ = -42 },
        { minX = 6, maxX = 10, minZ = -42, maxZ = -27 },
    }
    walkability("primeiro pavimento", 13, regions, 0, -23, {
        { name = "galeria oeste", x = -22, z = 0 },
        { name = "galeria leste", x = 22, z = 0 },
        { name = "ponte sul", x = 0, z = 23 },
        { name = "biblioteca", x = -35.25, z = -36 },
        { name = "sala de aula", x = 32, z = -36 },
        { name = "diretoria", x = -16, z = 29.0 },
        { name = "escritório", x = 30, z = 28.7 },
        { name = "controle", x = 0, z = 29.3 },
        { name = "chefe de guarda", x = 0, z = -36 },
    })
end)

test("segundo pavimento navegável: capela, arquivo, alojamento e registro", function()
    local regions = {
        { minX = -38.5, maxX = -18, minZ = -27, maxZ = 27 },
        { minX = 18, maxX = 38.5, minZ = -27, maxZ = 27 },
        { minX = -18, maxX = 18, minZ = -27, maxZ = -20 },
        { minX = -18, maxX = 18, minZ = 20, maxZ = 27 },
        { minX = -38.5, maxX = 38.5, minZ = 27, maxZ = 36.5 },
        { minX = -38.5, maxX = -22, minZ = -46, maxZ = -27 },
        { minX = 22, maxX = 38.5, minZ = -46, maxZ = -27 },
        { minX = -6, maxX = 6, minZ = -46, maxZ = -27 },
    }
    walkability("segundo pavimento", 26, regions, 0, -23, {
        { name = "galeria oeste", x = -22, z = 0 },
        { name = "galeria leste", x = 22, z = 0 },
        { name = "ponte sul", x = 0, z = 23 },
        { name = "capela", x = -30.25, z = -36 },
        { name = "arquivo morto", x = 23.5, z = -36 },
        { name = "alojamento", x = -16, z = 29.0 },
        { name = "registro", x = 0, z = 28.8 },
        { name = "arquivo", x = 30, z = 29.0 },
        { name = "plantão", x = 0, z = -36 },
    })
end)

test("escadas conectam os pavimentos", function()
    local flightA = 0
    local flightB = 0
    for _, part in allParts do
        if startsWith(part.Name, "Escada A") and string.find(part.Name, "degrau") then
            flightA += 1
        elseif startsWith(part.Name, "Escada B") and string.find(part.Name, "degrau") then
            flightB += 1
        end
    end
    expect(flightA >= 40, "Escadas do térreo ao primeiro pavimento incompletas")
    expect(flightB >= 40, "Escadas do primeiro ao segundo pavimento incompletas")
    expect(prison:FindFirstChild("Patamar da escada oeste", true) ~= nil, "Patamar oeste ausente")
    expect(prison:FindFirstChild("Patamar da escada leste", true) ~= nil, "Patamar leste ausente")
end)

local failures = 0
for _, result in results do
    if result.ok then
        print(string.format("  ok    %s", result.name))
    else
        failures += 1
        print(string.format("  falha %s\n        %s", result.name, result.detail))
    end
end

print(string.format("\n[presidio tests] %d/%d testes passaram", #results - failures, #results))
if failures > 0 then
    process.exit(1)
end

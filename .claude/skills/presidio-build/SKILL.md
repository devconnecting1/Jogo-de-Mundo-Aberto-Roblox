---
name: presidio-build
description: Build, validate and re-render the Presídio Central Roblox showcase. Use when changing Luau geometry, preview cameras, README counts, tests or CI in this repository.
---

# Presídio Central — build e validação

Leia o `AGENTS.md` na raiz antes de começar. As regras invioláveis estão lá;
este skill resume o caminho operacional.

## Quando usar

- Alterar geometria, ambientes, celas, mobiliário ou iluminação em
  `src/builder/`.
- Alterar câmeras, camadas ou renderização em `preview/`, `scripts/` e
  `tools/export_scene.luau`.
- Atualizar contagens, imagens, README ou testes do showcase.

## Passos

1. Confirme a planta em `src/builder/Layout.luau` e reutilize `Kit`,
   `Furniture` e `Palette`.
2. Regenere os artefatos:
   ```bash
   lune run tools/build_world.luau
   lune run tools/export_scene.luau
   ```
3. Rode os testes Luau:
   ```bash
   lune run tests/prison.test.luau
   ```
   Esperado: 14/14, incluindo a navegabilidade dos três pavimentos.
4. Compile e valide o lugar:
   ```bash
   mkdir -p build
   rojo build default.project.json -o build/PrisaoCentral.rbxlx
   lune run tools/validate_place.luau build/PrisaoCentral.rbxlx
   ```
   Esperado: 9.455 Parts, 142 luzes, 1 spawn, 0 scripts, 0 NPCs, 0 UIs,
   somente Blocks.
5. Rode o subconjunto web rápido:
   ```bash
   npm run test:unit
   npx eslint preview scripts tests playwright.config.mjs eslint.config.mjs --max-warnings=0
   npx prettier --check .
   ```
6. Só regenere imagens que serão commitadas:
   ```bash
   npm run render:previews -- atrio cela
   ```
   Use os IDs `geral`, `fachada`, `atrio`, `galeria`, `cela`, `refeitorio`,
   `cozinha`, `enfermaria`, `patio`. As imagens ficam em 1440 × 900.
7. Atualize README, testes de preview e corpo do PR se contagens, salas ou
   pontos de vista mudarem. Deixe Playwright e o restante da validação para o
   GitHub Actions.

## Nunca

- Editar `src/world/PrisaoCentral.rbxm` ou `preview/scene.json` à mão.
- Adicionar cilindros, esferas, wedges, malhas, NPCs, scripts ou UIs.
- Afrouxar testes ou o raio de navegabilidade para esconder uma obstrução.
- Commitar imagens de depuração, `build/`, `node_modules/` ou segredos.

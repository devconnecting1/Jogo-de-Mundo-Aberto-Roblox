# Presídio Central — instruções para agentes

A fonte única de regras deste repositório é o [AGENTS.md](AGENTS.md). Leia-o
antes de alterar código, geometria, testes, CI ou documentação. O arquivo cobre
o escopo do showcase, as regras de "somente Parts", a ausência de NPCs/UIs, o
fluxo de build/testes, o uso do GitHub Actions e o checklist de conclusão.

@AGENTS.md

## Atalhos para o Claude Code

- Build: `lune run tools/build_world.luau`
- Cena do preview: `lune run tools/export_scene.luau`
- Testes Luau: `lune run tests/prison.test.luau`
- Place: `rojo build default.project.json -o build/PrisaoCentral.rbxlx` e
  `lune run tools/validate_place.luau build/PrisaoCentral.rbxlx`
- Web: `npm run test:unit`, ESLint e Prettier; Playwright fica a cargo do CI.
- Imagens: `npm run render:previews -- <ids>` somente quando forem commitadas.
- Não edite `src/world/PrisaoCentral.rbxm` nem `preview/scene.json` à mão.

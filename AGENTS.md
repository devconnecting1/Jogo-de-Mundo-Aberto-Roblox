# Presídio Central — guia para agentes

Este é o guia único de regras e de fluxo de trabalho do repositório. Ele vale
para pessoas e para qualquer agente de IA (Claude Code, Codex, Copilot, Cursor,
DeepSeek e afins). O formato `AGENTS.md` é o padrão comum adotado pela indústria;
`CLAUDE.md` e `.github/copilot-instructions.md` apenas apontam para cá. Não crie
arquivos de instruções por modelo.

Documentação para humanos: [README.md](README.md).

## Missão do repositório

O **Presídio Central** é um showcase estático de arquitetura prisional clássica
para Roblox. Toda a geometria é gerada de forma determinística por código Luau,
executado com Lune; o lugar final é montado pelo Rojo. O repositório também
contém um visualizador Three.js de revisão, usado para tirar as imagens do
README e do PR.

O entregável é o **lugar explorável**, com qualidade de leitura arquitetônica
(plantas, circulação, setorização, materiais e iluminação). Não é um jogo.

## Regras invioláveis

1. **Somente `Part` retangular.** Toda a geometria usa `Part` com
   `Shape = Enum.PartType.Block`. Não use `WedgePart`, `CylinderPart` circular,
   esferas, `MeshPart`, `UnionOperation`, terreno ou malhas.
2. **Um único `SpawnLocation`.** Ele é a exceção permitida à regra de apenas
   Parts; não adicione outros spawns.
3. **Sem scripts no lugar.** O modelo exportado não contém
   `LuaSourceContainer`.
4. **Sem NPCs ou humanoides.** Nada de `Humanoid`, `Animator`, rigs ou
   personagens.
5. **Sem interfaces no mundo.** Nada de `ScreenGui` ou `SurfaceGui`; o
   showcase não tem UI de gameplay, inventário, missões ou áudio.
6. **Tudo ancorado.** Toda peça do modelo e do lugar final deve ter
   `Anchored = true`.
7. **Determinismo.** A mesma entrada deve gerar a mesma geometria. Não use
   aleatoriedade sem semente fixa nem dados externos.
8. **Sem assets de terceiros.** Nada de imagens, modelos, texturas, áudio ou
   plugins externos. Materiais, cores e formas são originais do código.
9. **Navegabilidade obrigatória.** Os testes fazem flood fill 2D por pavimento
   com avatar de raio **0,85 stud** e precisam alcançar os 28 destinos. Portas,
   móveis e paredes não podem selar corredores, salas ou alvos.
10. **Não edite artefatos gerados à mão.** Altere o builder e regenere
    `src/world/PrisaoCentral.rbxm` e `preview/scene.json`.
11. **Não afrouxe testes para fazer o CI passar.** Corrija a geometria, a cena
    ou o comportamento. Ajustes de limite só são aceitos quando o contrato do
    projeto realmente mudou e o motivo está documentado no PR.
12. **Idioma:** documentação, nomes de instâncias e mensagens em português;
    identificadores de código seguem o padrão existente.

## O que existe hoje

- **3 pavimentos** com pé-direito de 13 studs entre pisos.
- **28 celas nas galerias** (13 individuais, 11 com beliche, 3 de isolamento e
  1 de confiança) + **2 celas de espera** na triagem.
- **Refeitório para 48 lugares**, cozinha industrial, lavanderia, enfermaria,
  visitas, triagem, hall central, biblioteca, sala de aula, capela, oficina,
  casa de máquinas, administração, pátio murado e torre de vigia.
- **9.455 Parts**, **142 luzes práticas**, **1 spawn**, **0 scripts**,
  **0 NPCs** e **0 UIs** no lugar final.
- **9 imagens de revisão**: `geral`, `fachada`, `atrio`, `galeria`, `cela`,
  `refeitorio`, `cozinha`, `enfermaria` e `patio`.

Escala de referência: **1 stud ≈ 0,28 m**. O edifício principal tem 80 × 84
studs; o refeitório, 58 × 56 studs; o terreno, 2.038 m².

## Mapa do repositório

```text
src/builder/        geometria em Luau (fonte da verdade)
  Architecture      casca, átrio, galerias, escadas, fachadas e refeitório
  Cells             celas, portas de ferro, beliches e isolamento
  Hall              hall central, posto de guarda e convivência
  Refeitorio        mesas, balcão, proteção, tesouras e pendentes
  Cozinha           cocção, câmara fria, copa, lava-louças e despensa
  Lavanderia        máquinas, triagem, carrinhos e vapor
  Enfermaria        leitos, cortinas, posto e medicamentos
  Visitas           cabines, vidro, telefones e área pública
  Triagem           registro, pertences e celas de espera
  Administracao     entrada, diretoria, escritórios, controle e plantão
  Biblioteca        biblioteca, sala de aula e mobiliário
  Capela            capela, vitrais e arquivo morto
  Oficina           carpintaria, gaiola de ferramentas e casa de máquinas
  Patio             pátio, guarita, torre de vigia e equipamentos
  Grounds           terreno, muros, portões e paisagismo
  Kit               helpers de peças, grades, corrimãos e luzes
  Furniture         mesas, camas, estantes, portas e luminárias
  Palette           paleta fechada de materiais clássicos
  Layout            planta, níveis, alas e escala
  Prison            orquestrador do complexo
src/world/          PrisaoCentral.rbxm gerado e versionado
tools/              build, export do preview e validação do place
tests/              testes de navegabilidade, geometria e preview
preview/            visualizador Three.js e scene.json exportada
scripts/            servidor local e renderizador de imagens
assets/preview/     imagens de revisão commitadas (1440 × 900)
.github/workflows/  CI, preview, render e publicação no Roblox
```

## Fluxo de trabalho

### Preparação

```bash
rokit install        # Rojo e Lune nas versões do rokit.toml
npm ci               # Node 22+ (apenas para preview/testes web)
```

### Geometria e lugar

```bash
lune run tools/build_world.luau
lune run tools/export_scene.luau
lune run tests/prison.test.luau
mkdir -p build
rojo build default.project.json -o build/PrisaoCentral.rbxlx
lune run tools/validate_place.luau build/PrisaoCentral.rbxlx
```

### Qualidade web

```bash
npm run test:unit
npx eslint preview scripts tests playwright.config.mjs eslint.config.mjs --max-warnings=0
npx prettier --check .
npm run test:e2e       # Playwright; pesado, prefira o CI
```

### Visualizador e imagens

```bash
npm run preview                          # http://localhost:4173
npm run render:previews                  # as 9 imagens oficiais
npm run render:previews -- atrio cela    # somente alguns pontos de vista
```

As imagens devem ter **1440 × 900**, mais de 80 KB e os nove IDs acima. Renders
de depuração não entram no repositório.

## O que roda no GitHub Actions

O CI é a fonte de verdade para validação. Não é necessário rodar tudo
localmente em cada mudança.

| Workflow                 | Quando roda         | O que valida                                                        |
| ------------------------ | ------------------- | ------------------------------------------------------------------- |
| **Luau & Rojo**          | push e pull request | build do modelo, export da cena, 14 testes Luau, place Rojo e place |
| **Preview & JavaScript** | push e pull request | ESLint, Prettier, testes unitários e Playwright                     |
| **Render de revisão**    | manual              | renderiza as imagens com navegador headless e publica um artifact   |
| **Publicar no Roblox**   | após CI na `main`   | publicação automática; também aceita execução manual                |

Recomendação: use o CI para lint, testes, Playwright e validação do lugar. Rode
localmente apenas o subconjunto rápido e os renders que serão **commitados**,
porque imagens de artifact do GitHub não servem como URL crua no README/PR.
Para atualizar as imagens oficiais, rode o workflow **Render de revisão**,
baixe o artifact e commite os PNGs.

**Custo:** runners padrão são gratuitos em repositório público. Não use runners
maiores, actions pagas, serviços externos de render ou agendamentos
desnecessários. O render é manual, aceita uma lista de IDs e o cache de
toolchain, npm e Chromium já reduz o tempo; `concurrency` cancela execuções
antigas. Se o repositório virar privado, os mesmos workflows continuam dentro
do plano gratuito para o volume normal de PRs, mas renders completos devem
ficar para quando as câmeras mudarem.

## Como alterar a geometria sem quebrar o showcase

1. Leia `src/builder/Layout.luau` e confirme eixos, níveis e alas.
2. Reutilize `Kit`, `Furniture` e `Palette`; evite peças únicas sem helper.
3. Prefira paredes com aberturas, janelas altas e grades de seção quadrada.
4. Preserve a setorização: público → triagem → circulação segura → galerias.
5. Rode `build_world` e `export_scene`; nunca edite os gerados.
6. Rode os testes Luau. Se um destino ficou inalcançável, ajuste o móvel ou a
   porta — não o raio do avatar.
7. Se mudou câmera, ambiente ou contagem, regenere as imagens afetadas e
   atualize README, testes de preview e corpo do PR.
8. Só então abra o PR; deixe o CI provar o restante.

## Critérios de qualidade

- **Arquitetura legível:** alas claras, circulação separada, portas e escadas
  coerentes, sem salas labirínticas.
- **Segurança realista:** barreiras sucessivas, sally port, guarita, torre,
  linhas de visão e pátio contido.
- **Celas salubres:** luz natural alta, ventilação, sanitário, lavatório e piso
  lavável.
- **Serviço adjacente:** cozinha ao lado do refeitório; lavanderia perto das
  celas; enfermaria perto do acesso.
- **Linguagem clássica e contida:** calcário, tijolo, ferro, madeira, terrazzo
  e verde institucional; cornijas, pilastras e esquadrias altas com moderação.
- **Sem excesso de detalhe:** o orçamento é de 8.000 a 12.000 Parts e 100 a 180
  luzes. Cada peça deve ter função visual ou construtiva.
- **Preview honesto:** a cena vem da mesma geometria do lugar; não invente
  imagens, medidas ou recursos no README.

## Commits e pull requests

- Use commits convencionais e curtos, em português: `feat:`, `fix:`, `ci:`,
  `docs:`, `test:`, `chore:`, `refactor:`.
- Um PR deve explicar o escopo, listar a validação executada e mostrar imagens
  quando a geometria mudou.
- Não commite `node_modules/`, `build/`, `test-results/`, `playwright-report/`
  nem artefatos de depuração.
- Nunca inclua segredos, chaves da Open Cloud ou IDs privados. Credenciais só
  existem em **Settings → Secrets and variables → Actions**.
- Mudanças de publicação no Roblox exigem revisão extra: confira os nomes dos
  secrets e o environment `roblox-production`.

## Checklist de conclusão

- [ ] `lune run tools/build_world.luau` sem erros e contagens esperadas.
- [ ] `lune run tools/export_scene.luau` atualizado.
- [ ] `lune run tests/prison.test.luau` → 14/14.
- [ ] `rojo build` + `lune run tools/validate_place.luau` → 9.455 Parts,
      142 luzes, 1 spawn, 0 scripts/NPCs/UIs, somente Blocks.
- [ ] `npm run test:unit`, ESLint e Prettier passando.
- [ ] Imagens afetadas regeradas em 1440 × 900.
- [ ] README e corpo do PR com números, plantas e imagens coerentes.
- [ ] CI verde antes do merge.

## Fora de escopo

NPCs, IA, combate, facções, economia, inventário, missões, áudio, veículos,
interações com portas, UI de gameplay e qualquer sistema que transforme o
showcase em um jogo. O lugar é estático; os controles padrão do Roblox bastam.

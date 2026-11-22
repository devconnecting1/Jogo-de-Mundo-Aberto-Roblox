import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  buildPartMatrix,
  getMaterialProfile,
  getShot,
  isTransparentPart,
  layerIsVisible,
} from "../../preview/scene-utils.mjs";

const rawScene = await readFile(new URL("../../preview/scene.json", import.meta.url), "utf8");
const scene = JSON.parse(rawScene);

const validLayers = new Set([
  "ceiling",
  "outerWalls",
  "innerWalls",
  "windows",
  "trim",
  "floor",
  "exterior",
  "structure",
  "interior",
]);

test("o export contém o complexo inteiro e metadados coerentes", () => {
  assert.equal(scene.meta.title, "Presídio Central");
  assert.equal(scene.meta.counts.parts, scene.parts.length);
  assert.equal(scene.meta.counts.lights, scene.lights.length);
  assert.ok(scene.parts.length > 8000, "o complexo deve ser detalhado, com mais de 8000 peças");
  assert.ok(scene.parts.length < 12000, "o export não deve explodir em número de peças");
  assert.ok(scene.lights.length >= 100, "a ambientação precisa de luzes práticas");
  assert.ok(scene.lights.length <= 180, "há um limite de bom senso para luzes em tempo real");
  assert.equal(scene.meta.dimensions.areaSquareMeters, 2038);
});

test("todas as peças são blocos com transformações e dimensões válidas", () => {
  for (const part of scene.parts) {
    assert.ok(part.n.length > 0, "toda peça tem nome");
    assert.equal(part.s, "Block", `forma não retangular em ${part.n}`);
    assert.equal(part.cf.length, 12);
    assert.equal(part.sz.length, 3);
    assert.equal(part.c.length, 3);
    assert.ok(part.sz.every((value) => Number.isFinite(value) && value > 0));
    assert.ok(part.cf.every(Number.isFinite));
    assert.ok(part.c.every((value) => value >= 0 && value <= 1));
    assert.ok(part.t >= 0 && part.t < 1, "peças invisíveis não devem ser exportadas");
    assert.ok(validLayers.has(part.layer), `camada desconhecida: ${part.layer}`);
  }
});

test("matrizes são afins, finitas e preservam a orientação", () => {
  for (const part of scene.parts) {
    const matrix = buildPartMatrix(part);
    assert.equal(matrix.length, 16);
    assert.ok(matrix.every(Number.isFinite));
    assert.deepEqual(matrix.slice(12), [0, 0, 0, 1]);
    assert.ok(matrix.some((value) => value !== 0));
  }
});

test("a geometria fica dentro do envelope do terreno", () => {
  for (const part of scene.parts) {
    assert.ok(part.cf[0] >= -110 && part.cf[0] <= 125, `peça fora no eixo X: ${part.n}`);
    assert.ok(part.cf[2] >= -58 && part.cf[2] <= 65, `peça fora no eixo Z: ${part.n}`);
    assert.ok(part.cf[1] >= -2 && part.cf[1] <= 70, `peça fora no eixo Y: ${part.n}`);
  }
});

test("existem peças em todas as camadas e em todos os ambientes principais", () => {
  const layerCounts = new Map();
  const roomCounts = new Map();
  for (const part of scene.parts) {
    layerCounts.set(part.layer, (layerCounts.get(part.layer) ?? 0) + 1);
    roomCounts.set(part.room, (roomCounts.get(part.room) ?? 0) + 1);
  }

  for (const layer of validLayers) {
    if (layer === "windows") assert.ok(layerCounts.get(layer) > 700);
    else assert.ok(layerCounts.get(layer) > 0, `camada vazia: ${layer}`);
  }

  const minimums = {
    "Hall Central": 300,
    Celas: 2000,
    Refeitório: 500,
    Cozinha: 180,
    Lavanderia: 180,
    Enfermaria: 100,
    Visitas: 140,
    Triagem: 140,
    Pátio: 100,
    Biblioteca: 300,
    Capela: 150,
    Diretoria: 150,
    Entrada: 80,
    Terreno: 200,
    "Torre de Vigia": 100,
  };
  for (const [room, minimum] of Object.entries(minimums)) {
    assert.ok((roomCounts.get(room) ?? 0) >= minimum, `${room} tem detalhe insuficiente`);
  }
  assert.ok(roomCounts.size >= 25, "o complexo deve cobrir todos os ambientes");
});

test("os pontos de vista são únicos e estão bem formados", () => {
  const shots = scene.meta.shots;
  assert.equal(shots.length, 9);
  assert.equal(new Set(shots.map((shot) => shot.id)).size, shots.length);
  for (const shot of shots) {
    assert.ok(["interior", "dollhouse"].includes(shot.mode));
    assert.equal(shot.pos.length, 3);
    assert.equal(shot.target.length, 3);
    assert.ok(shot.pos.every(Number.isFinite));
    assert.ok(shot.target.every(Number.isFinite));
    // Interiores estreitos podem usar FOV amplo, até 80°.
    assert.ok(shot.fov >= 30 && shot.fov <= 80);
  }
  assert.equal(getShot(scene, "geral").id, "geral");
  assert.equal(getShot(scene, "inexistente").id, "geral");
});

test("utilitários de material e camadas respondem corretamente", () => {
  assert.equal(getMaterialProfile("MaterialInexistente").roughness, 0.7);
  assert.equal(getMaterialProfile("Wood").roughness, 0.7);
  assert.equal(isTransparentPart({ m: "Glass", t: 0 }), true);
  assert.equal(isTransparentPart({ m: "Wood", t: 0 }), false);
  assert.equal(isTransparentPart({ m: "Fabric", t: 0.2 }), true);
  assert.equal(layerIsVisible("ceiling", { ceiling: false }), false);
  assert.equal(layerIsVisible("outerWalls", { outerShell: false }), false);
  assert.equal(layerIsVisible("interior", { ceiling: false, outerShell: false }), true);
});

test("os renders de revisão existem e correspondem aos pontos de vista", async () => {
  const { readFile, stat } = await import("node:fs/promises");
  const expected = new Set(scene.meta.shots.map((shot) => shot.id));

  for (const shot of scene.meta.shots) {
    const url = new URL(`../../assets/preview/${shot.id}.png`, import.meta.url);
    const info = await stat(url);
    // Interiores muito planos comprimem bem; abaixo disso o render provavelmente falhou.
    assert.ok(info.size > 60_000, `${shot.id}.png está pequeno demais`);

    const image = await readFile(url);
    assert.deepEqual(
      [...image.subarray(0, 8)],
      [137, 80, 78, 71, 13, 10, 26, 10],
      `${shot.id}.png não é um PNG válido`,
    );
    assert.equal(image.readUInt32BE(16), 1440, "largura inesperada no render");
    assert.equal(image.readUInt32BE(20), 900, "altura inesperada no render");
  }

  assert.equal(expected.size, 9);
});

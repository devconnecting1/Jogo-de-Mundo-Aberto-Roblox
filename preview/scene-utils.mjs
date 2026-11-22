/**
 * Utilidades puras compartilhadas pelo visualizador e pelos testes.
 * Nada aqui depende do DOM.
 */

export const MATERIAL_PROFILES = {
  SmoothPlastic: { roughness: 0.52, metalness: 0.02, envMapIntensity: 0.65 },
  Plastic: { roughness: 0.62, metalness: 0.0, envMapIntensity: 0.5 },
  Wood: { roughness: 0.7, metalness: 0.0, envMapIntensity: 0.4 },
  WoodPlanks: { roughness: 0.76, metalness: 0.0, envMapIntensity: 0.32 },
  Marble: { roughness: 0.26, metalness: 0.04, envMapIntensity: 0.85 },
  CeramicTiles: { roughness: 0.28, metalness: 0.0, envMapIntensity: 0.8 },
  Glass: { roughness: 0.08, metalness: 0.04, envMapIntensity: 1.0 },
  Metal: { roughness: 0.34, metalness: 0.82, envMapIntensity: 1.05 },
  Neon: { roughness: 0.4, metalness: 0.0, envMapIntensity: 0.3 },
  Fabric: { roughness: 0.94, metalness: 0.0, envMapIntensity: 0.22 },
  Carpet: { roughness: 0.98, metalness: 0.0, envMapIntensity: 0.18 },
  Plaster: { roughness: 0.9, metalness: 0.0, envMapIntensity: 0.3 },
  Concrete: { roughness: 0.92, metalness: 0.0, envMapIntensity: 0.25 },
  Slate: { roughness: 0.8, metalness: 0.02, envMapIntensity: 0.4 },
  Grass: { roughness: 0.97, metalness: 0.0, envMapIntensity: 0.2 },
  LeafyGrass: { roughness: 0.94, metalness: 0.0, envMapIntensity: 0.22 },
  Brick: { roughness: 0.88, metalness: 0.0, envMapIntensity: 0.3 },
};

const FALLBACK_PROFILE = { roughness: 0.7, metalness: 0.0, envMapIntensity: 0.4 };

export function getMaterialProfile(materialName) {
  return MATERIAL_PROFILES[materialName] ?? FALLBACK_PROFILE;
}

/**
 * Monta a matriz 4x4 em ordem row-major, como `THREE.Matrix4.set()` espera.
 * O CFrame exportado segue a convenção [x,y,z, r00..r22] do Roblox.
 */
export function buildPartMatrix(part) {
  const [x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22] = part.cf;
  const [sx, sy, sz] = part.sz;

  return [
    r00 * sx,
    r01 * sy,
    r02 * sz,
    x,
    r10 * sx,
    r11 * sy,
    r12 * sz,
    y,
    r20 * sx,
    r21 * sy,
    r22 * sz,
    z,
    0,
    0,
    0,
    1,
  ];
}

export function isTransparentPart(part) {
  return part.m === "Glass" || part.t > 0.02;
}

export function layerIsVisible(layer, { ceiling = true, outerShell = true } = {}) {
  if (layer === "ceiling") return ceiling;
  if (layer === "outerWalls" || layer === "windows") return outerShell;
  return true;
}

export function getShot(scene, shotId) {
  return scene.meta.shots.find((shot) => shot.id === shotId) ?? scene.meta.shots[0];
}

export function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

export function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
}

export function formatNumber(value) {
  return new Intl.NumberFormat("pt-BR").format(value);
}

/**
 * Reduz as luzes exportadas para um conjunto viável no preview.
 * Luzes espacialmente próximas são fundidas, e o conjunto principal
 * prioriza intensidade × alcance.
 */
export function clusterPreviewLights(lights, { radius = 7, limit = 10 } = {}) {
  const clusters = [];

  for (const light of lights) {
    const score = light.b * light.range;
    let cluster = clusters.find((candidate) => {
      const dx = candidate.x - light.p[0];
      const dy = candidate.y - light.p[1];
      const dz = candidate.z - light.p[2];
      return Math.sqrt(dx * dx + dy * dy + dz * dz) <= radius;
    });

    if (!cluster) {
      cluster = {
        x: light.p[0],
        y: light.p[1],
        z: light.p[2],
        count: 0,
        brightness: 0,
        range: 0,
        color: light.c,
        score: 0,
      };
      clusters.push(cluster);
    }

    cluster.count += 1;
    cluster.x = (cluster.x * (cluster.count - 1) + light.p[0]) / cluster.count;
    cluster.y = (cluster.y * (cluster.count - 1) + light.p[1]) / cluster.count;
    cluster.z = (cluster.z * (cluster.count - 1) + light.p[2]) / cluster.count;
    cluster.brightness += light.b;
    cluster.range = Math.max(cluster.range, light.range);
    cluster.score += score;
  }

  return clusters
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((cluster) => ({
      position: [cluster.x, cluster.y, cluster.z],
      color: cluster.color,
      brightness: cluster.brightness * 0.72,
      range: cluster.range,
    }));
}

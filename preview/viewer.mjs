import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";

import {
  buildPartMatrix,
  clamp,
  clusterPreviewLights,
  easeInOutCubic,
  formatNumber,
  getMaterialProfile,
  getShot,
  isTransparentPart,
  layerIsVisible,
} from "./scene-utils.mjs";

const canvas = document.querySelector("#scene");
const loading = document.querySelector("#loading");
const loadingProgress = document.querySelector("#loading-progress");
const loadingDetail = document.querySelector("#loading-detail");
const errorPanel = document.querySelector("#error");
const errorMessage = document.querySelector("#error-message");
const statusLabel = document.querySelector("#status-label");
const shotList = document.querySelector("#shot-list");
const ceilingButton = document.querySelector("#toggle-ceiling");
const outerButton = document.querySelector("#toggle-outer");
const partCountLabel = document.querySelector("#part-count");
const lightCountLabel = document.querySelector("#light-count");

const params = new URLSearchParams(window.location.search);
const isClean = params.get("clean") === "1";
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
const isStill = params.get("still") === "1";

if (isClean) document.body.classList.add("clean");

const state = {
  ceiling: true,
  outerShell: true,
  shotId: null,
  transitioning: false,
};

const layerObjects = new Map();
let renderer;
let scene;
let camera;
let controls;
let tween = null;
let sceneData = null;
let environmentTexture = null;

const geometries = {
  Block: new THREE.BoxGeometry(1, 1, 1),
  Ball: new THREE.SphereGeometry(0.5, 18, 13),
  Cylinder: (() => {
    const geometry = new THREE.CylinderGeometry(0.5, 0.5, 1, 20, 1);
    geometry.rotateZ(Math.PI / 2);
    return geometry;
  })(),
};

const temporaryVector = new THREE.Vector3();
const temporaryQuaternion = new THREE.Quaternion();
const temporaryScale = new THREE.Vector3();
const temporaryMatrix = new THREE.Matrix4();

function setProgress(percent, detail) {
  loadingProgress.style.width = `${clamp(percent, 4, 100)}%`;
  if (detail) loadingDetail.textContent = detail;
}

function showError(error) {
  console.error(error);
  window.__PRISAO_ERROR__ = String(error);
  loading.classList.add("is-hidden");
  errorPanel.hidden = false;
  errorMessage.textContent =
    "Não foi possível montar o preview 3D. Verifique se o navegador tem WebGL ativo e recarregue a página.";
  statusLabel.textContent = "Falha ao carregar";
}

function addToLayer(layer, object) {
  if (!layerObjects.has(layer)) layerObjects.set(layer, []);
  layerObjects.get(layer).push(object);
}

function createMaterial(part, profile) {
  const color = new THREE.Color().setRGB(part.c[0], part.c[1], part.c[2], THREE.SRGBColorSpace);

  if (part.m === "Neon") {
    return new THREE.MeshStandardMaterial({
      color,
      emissive: color,
      emissiveIntensity: 2.2,
      roughness: profile.roughness,
      metalness: 0,
      toneMapped: false,
    });
  }

  if (part.m === "Glass" && part.r >= 0.3) {
    return new THREE.MeshStandardMaterial({
      color,
      roughness: 0.07,
      metalness: 0.92,
      envMapIntensity: 1.45,
      side: THREE.DoubleSide,
    });
  }

  if (part.m === "Glass") {
    return new THREE.MeshPhysicalMaterial({
      color,
      roughness: clamp(0.06 + part.t * 0.42, 0.06, 0.5),
      metalness: 0,
      transparent: true,
      opacity: clamp(1 - part.t * 0.92, 0.1, 0.88),
      transmission: 0.22,
      thickness: 0.25,
      ior: 1.45,
      envMapIntensity: 1.15,
      side: THREE.DoubleSide,
      depthWrite: false,
    });
  }

  return new THREE.MeshStandardMaterial({
    color,
    roughness: profile.roughness,
    metalness: profile.metalness,
    envMapIntensity: profile.envMapIntensity,
    transparent: part.t > 0.02,
    opacity: clamp(1 - part.t, 0.08, 1),
    side: THREE.FrontSide,
  });
}

function addInstancedBucket(parts, bucketKey) {
  const first = parts[0];
  const geometry = geometries[first.s] ?? geometries.Block;
  const profile = getMaterialProfile(first.m);
  const material = new THREE.MeshStandardMaterial({
    color: 0xffffff,
    roughness: profile.roughness,
    metalness: profile.metalness,
    envMapIntensity: profile.envMapIntensity,
  });

  const mesh = new THREE.InstancedMesh(geometry, material, parts.length);
  mesh.name = `instanced-${bucketKey}`;
  mesh.castShadow = first.sh;
  mesh.receiveShadow = true;
  mesh.frustumCulled = false;

  for (let index = 0; index < parts.length; index += 1) {
    const part = parts[index];
    temporaryMatrix.set(...buildPartMatrix(part));
    mesh.setMatrixAt(index, temporaryMatrix);
    mesh.setColorAt(
      index,
      new THREE.Color().setRGB(part.c[0], part.c[1], part.c[2], THREE.SRGBColorSpace),
    );
  }

  mesh.instanceMatrix.needsUpdate = true;
  if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true;
  scene.add(mesh);
  addToLayer(first.layer, mesh);
  return mesh;
}

function addTransparentPart(part) {
  const geometry = geometries[part.s] ?? geometries.Block;
  const profile = getMaterialProfile(part.m);
  const material = createMaterial(part, profile);
  const mesh = new THREE.Mesh(geometry, material);

  const matrix = new THREE.Matrix4().set(...buildPartMatrix(part));
  matrix.decompose(temporaryVector, temporaryQuaternion, temporaryScale);
  mesh.position.copy(temporaryVector);
  mesh.quaternion.copy(temporaryQuaternion);
  mesh.scale.copy(temporaryScale);
  mesh.castShadow = false;
  mesh.receiveShadow = true;
  mesh.renderOrder = 2;

  scene.add(mesh);
  addToLayer(part.layer, mesh);
  return mesh;
}

function addGeometry(parts) {
  setProgress(58, "Assentando celas, refeitório e oficinas…");
  const buckets = new Map();

  for (const part of parts) {
    if (isTransparentPart(part) || part.m === "Neon") {
      addTransparentPart(part);
    } else {
      const key = [part.layer, part.s, part.m, part.sh ? "shadow" : "nos"].join("|");
      if (!buckets.has(key)) buckets.set(key, []);
      buckets.get(key).push(part);
    }
  }

  for (const [key, bucketParts] of buckets) {
    addInstancedBucket(bucketParts, key);
  }
}

function addSky() {
  const skyGeometry = new THREE.SphereGeometry(700, 40, 20);
  const skyMaterial = new THREE.ShaderMaterial({
    side: THREE.BackSide,
    depthWrite: false,
    uniforms: {
      topColor: { value: new THREE.Color("#8fa6ad") },
      horizonColor: { value: new THREE.Color("#eadbc6") },
      groundColor: { value: new THREE.Color("#b8b09d") },
      sunDirection: { value: new THREE.Vector3(-0.55, 0.34, 0.38).normalize() },
    },
    vertexShader: `
      varying vec3 vWorldPosition;
      void main() {
        vec4 worldPosition = modelMatrix * vec4(position, 1.0);
        vWorldPosition = worldPosition.xyz;
        gl_Position = projectionMatrix * viewMatrix * worldPosition;
      }
    `,
    fragmentShader: `
      uniform vec3 topColor;
      uniform vec3 horizonColor;
      uniform vec3 groundColor;
      uniform vec3 sunDirection;
      varying vec3 vWorldPosition;

      void main() {
        vec3 direction = normalize(vWorldPosition);
        float height = direction.y;
        vec3 sky = mix(horizonColor, topColor, smoothstep(0.0, 0.6, height));
        sky = mix(groundColor, sky, smoothstep(-0.12, 0.02, height));
        float sun = pow(max(dot(direction, sunDirection), 0.0), 460.0);
        float halo = pow(max(dot(direction, sunDirection), 0.0), 18.0) * 0.2;
        sky += vec3(1.0, 0.75, 0.47) * sun * 2.3;
        sky += vec3(1.0, 0.72, 0.45) * halo;
        gl_FragColor = vec4(sky, 1.0);
      }
    `,
  });
  const sky = new THREE.Mesh(skyGeometry, skyMaterial);
  sky.name = "sky";
  sky.frustumCulled = false;
  scene.add(sky);
}

function addLights(lights) {
  setProgress(72, "Acendendo as lâmpadas do complexo…");

  const hemisphere = new THREE.HemisphereLight(
    new THREE.Color("#cfd9d6"),
    new THREE.Color("#625142"),
    1.4,
  );
  hemisphere.name = "hemisphere";
  scene.add(hemisphere);

  const sun = new THREE.DirectionalLight(new THREE.Color("#ffd6a1"), 3.4);
  sun.name = "sun";
  sun.position.set(-110, 155, 105);
  sun.target.position.set(0, 0, 0);
  sun.castShadow = true;
  sun.shadow.mapSize.set(2048, 2048);
  sun.shadow.camera.left = -175;
  sun.shadow.camera.right = 175;
  sun.shadow.camera.top = 175;
  sun.shadow.camera.bottom = -175;
  sun.shadow.camera.near = 2;
  sun.shadow.camera.far = 520;
  sun.shadow.bias = -0.00035;
  sun.shadow.normalBias = 0.035;
  scene.add(sun);
  scene.add(sun.target);

  const fill = new THREE.DirectionalLight(new THREE.Color("#b9cfda"), 0.55);
  fill.name = "fill";
  fill.position.set(70, 60, -90);
  scene.add(fill);

  const clustered = clusterPreviewLights(lights);
  for (const lightData of clustered) {
    const color = new THREE.Color().setRGB(
      lightData.color[0],
      lightData.color[1],
      lightData.color[2],
      THREE.SRGBColorSpace,
    );
    const point = new THREE.PointLight(color, lightData.brightness * 23, lightData.range * 2.7, 2);
    point.name = "prisao-luz";
    point.position.set(...lightData.position);
    point.castShadow = false;
    scene.add(point);
  }
}

function addEnvironment(rendererInstance) {
  const pmrem = new THREE.PMREMGenerator(rendererInstance);
  const roomEnvironment = new RoomEnvironment();
  environmentTexture = pmrem.fromScene(roomEnvironment, 0.045).texture;
  scene.environment = environmentTexture;
  scene.environmentIntensity = 0.42;
  roomEnvironment.dispose();
  pmrem.dispose();
}

function initRenderer() {
  renderer = new THREE.WebGLRenderer({
    canvas,
    antialias: true,
    powerPreference: "high-performance",
    preserveDrawingBuffer: true,
  });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.16;
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFShadowMap;
  renderer.setClearColor(new THREE.Color("#b8c5c4"), 1);

  scene = new THREE.Scene();
  scene.fog = new THREE.Fog(new THREE.Color("#bec7bd"), 210, 720);

  camera = new THREE.PerspectiveCamera(55, window.innerWidth / window.innerHeight, 0.06, 900);
  camera.position.set(-135, 105, 125);

  controls = new OrbitControls(camera, canvas);
  controls.enableDamping = true;
  controls.dampingFactor = 0.065;
  controls.rotateSpeed = 0.52;
  controls.zoomSpeed = 0.72;
  controls.panSpeed = 0.5;
  controls.minDistance = 0.8;
  controls.maxDistance = 310;
  controls.maxPolarAngle = Math.PI * 0.86;
  controls.target.set(0, 8, 0);
  controls.update();
}

function refreshLayerVisibility() {
  for (const [layer, objects] of layerObjects) {
    const visible = layerIsVisible(layer, state);
    for (const object of objects) object.visible = visible;
  }

  ceilingButton.setAttribute("aria-pressed", String(state.ceiling));
  outerButton.setAttribute("aria-pressed", String(state.outerShell));
}

function setShot(shot, { immediate = false } = {}) {
  if (!shot) return;

  state.shotId = shot.id;
  if (shot.mode === "dollhouse") {
    state.ceiling = false;
    state.outerShell = false;
  } else {
    state.ceiling = true;
    state.outerShell = true;
  }
  refreshLayerVisibility();
  updateShotButtons();

  const targetPosition = new THREE.Vector3(...shot.pos);
  const targetLook = new THREE.Vector3(...shot.target);
  const shouldAnimate = !immediate && !reducedMotion;

  if (tween) tween = null;
  controls.enabled = true;

  if (!shouldAnimate) {
    camera.position.copy(targetPosition);
    controls.target.copy(targetLook);
    camera.fov = shot.fov ?? 55;
    camera.updateProjectionMatrix();
    controls.update();
    return;
  }

  tween = {
    startedAt: performance.now(),
    duration: shot.mode === "dollhouse" ? 1150 : 880,
    fromPosition: camera.position.clone(),
    toPosition: targetPosition,
    fromTarget: controls.target.clone(),
    toTarget: targetLook,
    fromFov: camera.fov,
    toFov: shot.fov ?? 55,
  };
  controls.enabled = false;
}

function updateTween(now) {
  if (!tween) return;
  const elapsed = now - tween.startedAt;
  const progress = clamp(elapsed / tween.duration, 0, 1);
  const eased = easeInOutCubic(progress);

  camera.position.lerpVectors(tween.fromPosition, tween.toPosition, eased);
  controls.target.lerpVectors(tween.fromTarget, tween.toTarget, eased);
  camera.fov = THREE.MathUtils.lerp(tween.fromFov, tween.toFov, eased);
  camera.updateProjectionMatrix();

  if (progress >= 1) {
    controls.enabled = true;
    tween = null;
    controls.update();
  }
}

function updateShotButtons() {
  for (const button of shotList.querySelectorAll(".shot")) {
    button.setAttribute("aria-current", String(button.dataset.shotId === state.shotId));
  }
}

function setupUi(shots) {
  shotList.replaceChildren();
  for (const shot of shots) {
    const button = document.createElement("button");
    button.className = "shot";
    button.type = "button";
    button.dataset.shotId = shot.id;
    button.textContent = shot.label;
    button.addEventListener("click", () => {
      setShot(getShot(sceneData, shot.id));
    });
    shotList.appendChild(button);
  }

  ceilingButton.addEventListener("click", () => {
    state.ceiling = !state.ceiling;
    refreshLayerVisibility();
  });
  outerButton.addEventListener("click", () => {
    state.outerShell = !state.outerShell;
    refreshLayerVisibility();
  });
}

function showLoadedState() {
  statusLabel.textContent = "Preview interativo";
  loading.classList.add("is-hidden");
  window.__PRISAO_READY__ = true;
}

function buildScene(data) {
  setProgress(34, "Erguendo alas, celas e galerias…");
  sceneData = data;

  partCountLabel.textContent = formatNumber(data.meta.counts.parts);
  lightCountLabel.textContent = formatNumber(data.meta.counts.lights);

  addSky();
  addLights(data.lights);
  addGeometry(data.parts);
  addEnvironment(renderer);
  setProgress(92, "Ajustando a luz do fim de tarde…");

  setupUi(data.meta.shots);

  const requestedShot = params.get("shot");
  const initialShot = requestedShot ? getShot(data, requestedShot) : data.meta.shots[0];
  const requestedMode = params.get("mode");
  setShot(initialShot, { immediate: true });
  if (requestedMode === "dollhouse" && initialShot.mode !== "dollhouse") {
    state.ceiling = false;
    state.outerShell = false;
    refreshLayerVisibility();
  }
}

function handleResize() {
  if (!renderer || !camera) return;
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
}

let renderedFrames = 0;

function animate(now) {
  updateTween(now);
  controls.update();
  renderer.render(scene, camera);
  renderedFrames += 1;

  if (isStill && renderedFrames >= 3) {
    renderer.setAnimationLoop(null);
    window.__PRISAO_STILL_READY__ = true;
  }
}

async function boot() {
  try {
    if (isClean) {
      document.body.classList.add("clean");
    }

    setProgress(8, "Lendo a planta do presídio…");
    const response = await fetch("./scene.json", { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`scene.json respondeu ${response.status}`);
    }
    const data = await response.json();

    initRenderer();
    buildScene(data);
    window.addEventListener("resize", handleResize);

    renderer.setAnimationLoop(animate);
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        showLoadedState();
        window.__PRISAO_VIEWER__ = {
          ready: true,
          data: {
            title: data.meta.title,
            partCount: data.meta.counts.parts,
            lightCount: data.meta.counts.lights,
            shots: data.meta.shots.map((shot) => shot.id),
          },
          getState: () => ({ ...state }),
          setShot: (shotId) => setShot(getShot(data, shotId), { immediate: true }),
          setLayers: (ceiling, outerShell) => {
            state.ceiling = Boolean(ceiling);
            state.outerShell = Boolean(outerShell);
            refreshLayerVisibility();
          },
        };
      });
    });
  } catch (error) {
    showError(error);
  }
}

boot();

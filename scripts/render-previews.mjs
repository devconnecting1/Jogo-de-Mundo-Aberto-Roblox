import { spawn } from "node:child_process";
import { mkdir } from "node:fs/promises";
import path from "node:path";
import process from "node:process";

import { chromium } from "@playwright/test";

const port = Number(process.env.PREVIEW_PORT ?? 4174);
const baseUrl = `http://127.0.0.1:${port}`;
const outputDirectory = path.resolve("assets/preview");
const defaultShots = [
  "geral",
  "fachada",
  "atrio",
  "galeria",
  "cela",
  "refeitorio",
  "cozinha",
  "enfermaria",
  "patio",
];
const requestedShots = process.argv.slice(2);
const shots = requestedShots.length > 0 ? requestedShots : defaultShots;

await mkdir(outputDirectory, { recursive: true });

const server = spawn("node", ["scripts/serve.mjs"], {
  env: { ...process.env, PORT: String(port) },
  stdio: ["ignore", "pipe", "pipe"],
});

const waitForServer = new Promise((resolve, reject) => {
  const timeout = setTimeout(
    () => reject(new Error("Servidor demorou demais para subir.")),
    15_000,
  );
  server.stdout.on("data", (chunk) => {
    if (chunk.toString().includes("preview em")) {
      clearTimeout(timeout);
      resolve();
    }
  });
  server.stderr.on("data", (chunk) => process.stderr.write(chunk));
  server.on("exit", (code) => {
    clearTimeout(timeout);
    if (code !== 0) reject(new Error(`Servidor encerrou com código ${code}.`));
  });
});

const browser = await chromium.launch({
  headless: true,
  args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--disable-dev-shm-usage"],
});

try {
  await waitForServer;
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1,
    reducedMotion: "reduce",
  });
  const page = await context.newPage();
  page.on("pageerror", (error) => {
    throw new Error(`Erro no preview: ${error.message}`);
  });

  for (const shot of shots) {
    const target = path.join(outputDirectory, `${shot}.png`);
    await page.goto(`${baseUrl}/?shot=${shot}&clean=1&still=1`, { waitUntil: "networkidle" });
    await page.waitForFunction(
      () => window.__PRISAO_READY__ === true && window.__PRISAO_STILL_READY__ === true,
      null,
      { timeout: 240_000 },
    );
    await page.waitForTimeout(500);
    await page.screenshot({ path: target, type: "png", timeout: 120_000 });
    console.log(`[preview] ${shot}.png`);
  }
  await context.close();
} finally {
  await browser.close();
  server.kill("SIGTERM");
}

import { expect, test } from "@playwright/test";

test.describe("visualizador da Casa 27", () => {
  test("carrega a cena sem erros de página", async ({ page }) => {
    const pageErrors = [];
    page.on("pageerror", (error) => pageErrors.push(error.message));

    await page.goto("/?shot=sala&still=1");
    await page.waitForFunction(
      () => window.__CASA_READY__ === true && window.__CASA_STILL_READY__ === true,
      null,
      { timeout: 45_000 },
    );

    const viewer = await page.evaluate(() => window.__CASA_VIEWER__);
    expect(viewer.ready).toBe(true);
    expect(viewer.data.title).toBe("Casa 27");
    expect(viewer.data.partCount).toBeGreaterThan(1500);
    expect(viewer.data.lightCount).toBeGreaterThan(8);
    expect(viewer.data.shots).toHaveLength(7);
    expect(pageErrors).toEqual([]);

    await expect(page.locator("#scene")).toBeVisible();
    await expect(page.locator(".status")).toContainText("Preview interativo");
    await expect(page.locator(".loading")).toHaveClass(/is-hidden/);
  });

  test("troca de ponto de vista e camadas", async ({ page }) => {
    await page.goto("/?still=1");
    await page.waitForFunction(
      () => window.__CASA_READY__ === true && window.__CASA_STILL_READY__ === true,
      null,
      { timeout: 45_000 },
    );

    await page.getByRole("button", { name: "Cozinha" }).click();
    await expect(page.getByRole("button", { name: "Cozinha" })).toHaveAttribute(
      "aria-current",
      "true",
    );
    await expect
      .poll(() => page.evaluate(() => window.__CASA_VIEWER__.getState().shotId))
      .toBe("cozinha");

    await page.getByRole("button", { name: "Maquete" }).click();
    await expect
      .poll(() => page.evaluate(() => window.__CASA_VIEWER__.getState().ceiling))
      .toBe(false);

    await page.getByRole("button", { name: /Teto/ }).click();
    await expect
      .poll(() => page.evaluate(() => window.__CASA_VIEWER__.getState().ceiling))
      .toBe(true);
  });

  test("modo limpo esconde a interface de revisão", async ({ page }) => {
    await page.goto("/?shot=geral&clean=1&still=1");
    await page.waitForFunction(
      () => window.__CASA_READY__ === true && window.__CASA_STILL_READY__ === true,
      null,
      { timeout: 45_000 },
    );

    await expect(page.locator(".masthead")).toBeHidden();
    await expect(page.locator(".shots")).toBeHidden();
    await expect(page.locator("#scene")).toBeVisible();
  });
});

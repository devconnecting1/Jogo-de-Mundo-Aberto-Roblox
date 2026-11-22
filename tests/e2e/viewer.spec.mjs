import { expect, test } from "@playwright/test";

test.describe("visualizador do Presídio Central", () => {
  test("carrega a cena sem erros de página", async ({ page }) => {
    const pageErrors = [];
    page.on("pageerror", (error) => pageErrors.push(error.message));

    await page.goto("/?shot=geral&still=1");
    await page.waitForFunction(
      () => window.__PRISAO_READY__ === true && window.__PRISAO_STILL_READY__ === true,
      null,
      { timeout: 120_000 },
    );

    const viewer = await page.evaluate(() => window.__PRISAO_VIEWER__);
    expect(viewer.ready).toBe(true);
    expect(viewer.data.title).toBe("Presídio Central");
    expect(viewer.data.partCount).toBeGreaterThan(8000);
    expect(viewer.data.lightCount).toBeGreaterThan(100);
    expect(viewer.data.shots).toHaveLength(9);
    expect(pageErrors).toEqual([]);

    await expect(page.locator("#scene")).toBeVisible();
    await expect(page.locator(".status")).toContainText("Preview interativo");
    await expect(page.locator(".loading")).toHaveClass(/is-hidden/);
  });

  test("troca de ponto de vista e camadas", async ({ page }) => {
    await page.goto("/?still=1");
    await page.waitForFunction(
      () => window.__PRISAO_READY__ === true && window.__PRISAO_STILL_READY__ === true,
      null,
      { timeout: 120_000 },
    );

    await page.getByRole("button", { name: "Refeitório" }).click();
    await expect(page.getByRole("button", { name: "Refeitório" })).toHaveAttribute(
      "aria-current",
      "true",
    );
    await expect
      .poll(() => page.evaluate(() => window.__PRISAO_VIEWER__.getState().shotId))
      .toBe("refeitorio");

    await page.getByRole("button", { name: "Maquete" }).click();
    await expect
      .poll(() => page.evaluate(() => window.__PRISAO_VIEWER__.getState().ceiling))
      .toBe(false);

    await page.getByRole("button", { name: /Teto/ }).click();
    await expect
      .poll(() => page.evaluate(() => window.__PRISAO_VIEWER__.getState().ceiling))
      .toBe(true);
  });

  test("modo limpo esconde a interface de revisão", async ({ page }) => {
    await page.goto("/?shot=geral&clean=1&still=1");
    await page.waitForFunction(
      () => window.__PRISAO_READY__ === true && window.__PRISAO_STILL_READY__ === true,
      null,
      { timeout: 120_000 },
    );

    await expect(page.locator(".masthead")).toBeHidden();
    await expect(page.locator(".shots")).toBeHidden();
    await expect(page.locator("#scene")).toBeVisible();
  });
});

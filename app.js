(function () {
  const storageKey = "elmarhepp-theme";
  const root = document.documentElement;
  const toggle = document.querySelector("[data-theme-toggle]");
  const toggleLabel = document.querySelector("[data-theme-toggle-label]");
  const toggleIcon = document.querySelector("[data-theme-toggle-icon]");
  const config = window.LEGAL_CONFIG || {};

  const readStoredTheme = () => {
    try {
      const storedTheme = localStorage.getItem(storageKey);
      return storedTheme === "light" || storedTheme === "dark"
        ? storedTheme
        : null;
    } catch (error) {
      return null;
    }
  };

  const prefersLightMode = () =>
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: light)").matches;

  const setTheme = (theme) => {
    const isLightTheme = theme === "light";
    const nextThemeLabel = isLightTheme ? "Dunkelmodus" : "Hellmodus";

    root.dataset.theme = isLightTheme ? "light" : "dark";

    if (toggle) {
      toggle.setAttribute("aria-pressed", String(isLightTheme));
      toggle.setAttribute("aria-label", `Zu ${nextThemeLabel} wechseln`);
    }

    if (toggleLabel) {
      toggleLabel.textContent = nextThemeLabel;
    }

    if (toggleIcon) {
      toggleIcon.textContent = isLightTheme ? "☾" : "☀";
    }
  };

  setTheme(
    root.dataset.theme ||
      readStoredTheme() ||
      (prefersLightMode() ? "light" : "dark"),
  );

  if (toggle) {
    toggle.addEventListener("click", () => {
      const nextTheme = root.dataset.theme === "light" ? "dark" : "light";

      try {
        localStorage.setItem(storageKey, nextTheme);
      } catch (error) {
        // Ignore storage errors and keep the theme change for the current page.
      }

      setTheme(nextTheme);
    });
  }

  if (window.matchMedia) {
    const mediaQuery = window.matchMedia("(prefers-color-scheme: light)");

    mediaQuery.addEventListener("change", (event) => {
      if (readStoredTheme()) {
        return;
      }

      setTheme(event.matches ? "light" : "dark");
    });
  }

  const values = {
    name: config.name || "",
    email: config.email || "",
    addressLine1: config.addressLine1 || "",
    addressLine2: config.addressLine2 || "",
    country: config.country || "",
    responsible: config.contentResponsible || config.name || "",
  };

  document.querySelectorAll("[data-legal-text]").forEach((element) => {
    const key = element.dataset.legalText;
    if (values[key]) {
      element.textContent = values[key];
    }
  });

  document.querySelectorAll("[data-legal-email]").forEach((link) => {
    if (values.email) {
      link.textContent = values.email;
      link.setAttribute("href", `mailto:${values.email}`);
    }
  });
})();

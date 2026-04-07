(function () {
  const config = window.LEGAL_CONFIG || {};

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

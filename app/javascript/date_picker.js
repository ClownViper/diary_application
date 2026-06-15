// flatpickr: locale-aware date picker that replaces the native date input.
// Locale is read from the <html lang> attribute (set by bcp47_locale).
(function () {
  const isJa = document.documentElement.lang.startsWith("ja");

  function loadStyle(href) {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = href;
    document.head.appendChild(link);
  }

  function loadScript(src, cb) {
    const s = document.createElement("script");
    s.src = src;
    s.onload = cb;
    document.head.appendChild(s);
  }

  function initAll() {
    document.querySelectorAll("input[type='date']").forEach(function (el) {
      flatpickr(el, {
        locale:        isJa ? "ja" : "en",
        dateFormat:    "Y-m-d",
        altInput:      true,
        altFormat:     isJa ? "Y年n月j日" : "m/d/Y",
        altInputClass: el.className,
        allowInput:    true,
        // Force flatpickr on mobile too; otherwise it falls back to the native
        // date input, whose value is hidden by our color:transparent rule.
        disableMobile: true,
      });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    if (!document.querySelector("input[type='date']")) return;
    loadStyle("https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css");
    loadScript("https://cdn.jsdelivr.net/npm/flatpickr", function () {
      if (isJa) {
        loadScript("https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js", initAll);
      } else {
        initAll();
      }
    });
  });
})();

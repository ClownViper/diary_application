// Loading feedback for saves and navigations.
//
// On form submit (save):
//   - disable the submit control(s) and swap their label to a loading text
//     (prevents double submit and shows the click was registered)
//   - show a full-screen overlay with a spinner so the gap between submit and
//     the next page load is not a blank, unresponsive screen.
//
// On internal link clicks (sidebar, "new" buttons, etc.):
//   - show the same overlay after a short delay, since full-page navigations
//     otherwise look frozen while the next page loads.
//
// This is a plain full-page-navigation app (no Turbo), so all of this DOM
// state is reset automatically by the next page load. The pageshow handler
// covers the back/forward (bfcache) case where the old DOM is restored.
//
// Opt out per form/link with `data-no-loading`. Override the text per form
// with `data-loading-text="..."`.

document.addEventListener("DOMContentLoaded", () => {
  const overlay = document.getElementById("loadingOverlay");
  const overlayText = document.getElementById("loadingOverlayText");
  const defaultText = overlay?.dataset.defaultText || "保存中…";
  const navText = overlay?.dataset.navText || "読み込み中…";

  const showOverlay = (text) => {
    if (!overlay) return;
    if (overlayText) overlayText.textContent = text;
    overlay.classList.remove("hidden");
    overlay.classList.add("flex");
  };

  const hideOverlay = () => {
    if (!overlay) return;
    overlay.classList.add("hidden");
    overlay.classList.remove("flex");
  };

  const submitButtons = (form) =>
    form.querySelectorAll(
      'input[type="submit"], button[type="submit"], button:not([type])'
    );

  document.addEventListener("submit", (e) => {
    const form = e.target;
    if (!(form instanceof HTMLFormElement)) return;
    if ("noLoading" in form.dataset) return; // opt-out
    if (form.dataset.submitting === "true") return; // already in progress
    // Skip GET forms (e.g. search/filter): "saving" feedback would be misleading.
    if ((form.getAttribute("method") || "get").toLowerCase() === "get") return;

    // Reaching the submit event means native HTML5 validation passed (an
    // invalid form fires `invalid`, not `submit`), so the form is really
    // being sent.
    form.dataset.submitting = "true";

    const text = form.dataset.loadingText || defaultText;

    submitButtons(form).forEach((btn) => {
      // Disabling after the submit event has fired does not cancel the
      // submission; it only blocks repeat clicks.
      btn.classList.add("opacity-70", "cursor-not-allowed");
      if (btn.tagName === "INPUT") {
        btn.dataset.originalValue = btn.value;
        btn.value = text;
      } else {
        btn.dataset.originalHtml = btn.innerHTML;
        btn.textContent = text;
      }
      // Defer disabling so the button's name/value is still submitted.
      setTimeout(() => {
        btn.disabled = true;
      }, 0);
    });

    showOverlay(text);
  });

  // --- Navigation feedback ---
  // Internal full-page navigations (sidebar links, "new" buttons, etc.) have
  // no Turbo, so the screen looks frozen while the next page loads. Show the
  // overlay synchronously on click: once the browser starts navigating it
  // stops painting the outgoing page, so a delayed overlay would never appear.
  document.addEventListener("click", (e) => {
    if (e.defaultPrevented) return; // handled by another script (calendar/csv)
    if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;

    const link = e.target.closest("a[href]");
    if (!link) return;
    if ("noLoading" in link.dataset) return;
    if ("csvDownload" in link.dataset) return; // handled by csv_download.js
    if (link.hasAttribute("download")) return;
    if (link.dataset.method || link.dataset.turboMethod) return; // needs UJS, not a plain GET
    if (link.target && link.target !== "_self") return; // opens a new tab/window

    const href = link.getAttribute("href") || "";
    if (
      !href ||
      href.startsWith("#") ||
      href.startsWith("javascript:") ||
      href.startsWith("mailto:") ||
      href.startsWith("tel:")
    )
      return;

    const url = new URL(link.href, window.location.href);
    if (url.origin !== window.location.origin) return; // external site
    // Same-page hash jump: no reload.
    if (
      url.pathname === window.location.pathname &&
      url.search === window.location.search &&
      url.hash
    )
      return;

    showOverlay(navText);
  });

  // Restore state if the page is shown from the bfcache (back/forward),
  // otherwise the overlay shown before navigating away stays visible.
  window.addEventListener("pageshow", (e) => {
    if (!e.persisted) return;
    hideOverlay();
    document.querySelectorAll('form[data-submitting="true"]').forEach((form) => {
      delete form.dataset.submitting;
      submitButtons(form).forEach((btn) => {
        btn.disabled = false;
        btn.classList.remove("opacity-70", "cursor-not-allowed");
        if (btn.tagName === "INPUT" && btn.dataset.originalValue !== undefined) {
          btn.value = btn.dataset.originalValue;
        } else if (btn.dataset.originalHtml !== undefined) {
          btn.innerHTML = btn.dataset.originalHtml;
        }
      });
    });
  });
});

// ISBN barcode scanner modal (book new/edit pages).
// Configuration (search URL + localized messages) comes from the
// #bookScannerLayer data attributes rendered by books/_scanner_modal.
document.addEventListener("DOMContentLoaded", () => {
  const layer = document.getElementById("bookScannerLayer");
  if (!layer) return;

  const SEARCH_URL = layer.dataset.searchUrl;
  const MSG = {
    scanning:    layer.dataset.msgScanning,
    cameraError: layer.dataset.msgCameraError,
    searching:   layer.dataset.msgSearching,
    notFound:    layer.dataset.msgNotFound,
    apiError:    layer.dataset.msgApiError,
  };

  let _scanner = null;
  let _lastResult = null;

  function loadLib(cb) {
    if (window.Html5Qrcode) { cb(); return; }
    const s = document.createElement("script");
    s.src = "https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js";
    s.onload = cb;
    document.head.appendChild(s);
  }

  function setStatus(msg) {
    const el = document.getElementById("bookScannerStatus");
    el.textContent = msg;
    el.classList.toggle("hidden", !msg);
  }

  function startCamera() {
    setStatus(MSG.scanning);
    _scanner = new Html5Qrcode("bookScannerReader");
    _scanner.start(
      { facingMode: "environment" },
      { fps: 10, qrbox: { width: 240, height: 100 } },
      (decoded) => { stopCamera(); lookup(decoded); },
      () => {}
    ).catch(() => {
      _scanner = null;
      setStatus(MSG.cameraError);
    });
  }

  function stopCamera() {
    if (_scanner) {
      const s = _scanner;
      _scanner = null;
      try { s.stop().catch(() => {}); } catch { /* not running */ }
    }
  }

  async function lookup(isbn) {
    isbn = isbn.replace(/[^0-9X]/gi, "");
    if (isbn.length < 10) { setStatus(MSG.notFound); return; }
    setStatus(MSG.searching);
    document.getElementById("bookScannerResult").classList.add("hidden");
    document.getElementById("bookScannerFillBtn").classList.add("hidden");
    document.getElementById("bookScannerRetryBtn").classList.add("hidden");
    try {
      const res = await fetch(`${SEARCH_URL}?isbn=${isbn}`, {
        headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" }
      });
      const data = await res.json();
      if (res.ok) {
        _lastResult = data;
        setStatus("");
        document.getElementById("bookScannerTitle").textContent  = data.title  || "";
        document.getElementById("bookScannerAuthor").textContent = data.author || "";
        const thumb = document.getElementById("bookScannerThumb");
        if (data.thumbnail) { thumb.src = data.thumbnail; thumb.classList.remove("hidden"); }
        else { thumb.classList.add("hidden"); }
        document.getElementById("bookScannerResult").classList.remove("hidden");
        document.getElementById("bookScannerFillBtn").classList.remove("hidden");
        document.getElementById("bookScannerRetryBtn").classList.remove("hidden");
      } else {
        setStatus(data.error || MSG.notFound);
        document.getElementById("bookScannerRetryBtn").classList.remove("hidden");
      }
    } catch {
      setStatus(MSG.apiError);
      document.getElementById("bookScannerRetryBtn").classList.remove("hidden");
    }
  }

  // Global functions (called from onclick attributes in the modal/form)
  window.openBookScanner = function () {
    _lastResult = null;
    document.getElementById("bookScannerResult").classList.add("hidden");
    document.getElementById("bookScannerFillBtn").classList.add("hidden");
    document.getElementById("bookScannerRetryBtn").classList.add("hidden");
    document.getElementById("bookIsbnInput").value = "";
    setStatus("");
    layer.classList.remove("hidden");
    layer.classList.add("flex");
    loadLib(startCamera);
  };

  window.closeBookScanner = function () {
    stopCamera();
    layer.classList.add("hidden");
    layer.classList.remove("flex");
  };

  window.bookScannerFill = function () {
    if (!_lastResult) return;
    const t = document.getElementById("book_title");
    const a = document.getElementById("book_author");
    if (t) t.value = _lastResult.title  || "";
    if (a) a.value = _lastResult.author || "";
    window.closeBookScanner();
  };

  window.bookScannerRetry = function () {
    document.getElementById("bookScannerResult").classList.add("hidden");
    document.getElementById("bookScannerFillBtn").classList.add("hidden");
    document.getElementById("bookScannerRetryBtn").classList.add("hidden");
    startCamera();
  };

  window.bookScannerSearchManual = function () {
    const isbn = document.getElementById("bookIsbnInput").value.trim();
    if (isbn) lookup(isbn);
  };
});

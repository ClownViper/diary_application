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
    pricePhoto:  layer.dataset.msgPricePhoto,
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

  // Grab the current camera frame as base64 JPEG (must run before stopCamera).
  // The frame is sent to the server so AI can read the printed price near the
  // barcode on the back cover.
  function captureFrame() {
    const video = document.querySelector("#bookScannerReader video");
    if (!video || !video.videoWidth) return null;
    const canvas = document.createElement("canvas");
    canvas.width  = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext("2d").drawImage(video, 0, 0);
    return canvas.toDataURL("image/jpeg", 0.8).split(",")[1];
  }

  function startCamera() {
    setStatus(MSG.scanning);
    _scanner = new Html5Qrcode("bookScannerReader");
    _scanner.start(
      { facingMode: "environment" },
      { fps: 10, qrbox: { width: 240, height: 100 } },
      (decoded) => { const frame = captureFrame(); stopCamera(); lookup(decoded, frame); },
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

  async function lookup(isbn, frame = null) {
    isbn = isbn.replace(/[^0-9X]/gi, "");
    if (isbn.length < 10) { setStatus(MSG.notFound); return; }
    document.getElementById("bookIsbnInput").value = isbn;
    setStatus(MSG.searching);
    document.getElementById("bookScannerResult").classList.add("hidden");
    document.getElementById("bookScannerFillBtn").classList.add("hidden");
    document.getElementById("bookScannerRetryBtn").classList.add("hidden");
    try {
      // With a camera frame, POST it so the server-side AI can read the
      // printed price from the photo.
      const res = frame
        ? await fetch(SEARCH_URL, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
            },
            body: JSON.stringify({ isbn: isbn, image: frame })
          })
        : await fetch(`${SEARCH_URL}?isbn=${isbn}`, {
            headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" }
          });
      const data = await res.json();
      if (res.ok) {
        _lastResult = data;
        setStatus("");
        document.getElementById("bookScannerTitle").textContent  = data.title  || "";
        document.getElementById("bookScannerAuthor").textContent = data.author || "";
        document.getElementById("bookScannerPrice").textContent  = data.price
          ? "¥" + Number(data.price).toLocaleString() + (data.price_source === "photo" ? MSG.pricePhoto : "")
          : "";
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
    const i = document.getElementById("book_isbn");
    const p = document.getElementById("book_purchase_price");
    if (t) t.value = _lastResult.title  || "";
    if (a) a.value = _lastResult.author || "";
    if (i) i.value = _lastResult.isbn   || document.getElementById("bookIsbnInput").value;
    if (p && _lastResult.price && !p.value) p.value = _lastResult.price;
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
    if (isbn) lookup(isbn, captureFrame()); // include the live frame when the camera is running
  };
});

// Register the service worker for PWA / Web Push support
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service_worker.js");
}

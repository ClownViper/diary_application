// Register Web Push notification subscription
document.addEventListener("DOMContentLoaded", () => {
  const vapidPublicKey = document.querySelector('meta[name="vapid-public-key"]');
  if (!vapidPublicKey) return;
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) return;

  // If already subscribed, just sync with server
  navigator.serviceWorker.ready.then((registration) => {
    registration.pushManager.getSubscription().then((subscription) => {
      if (subscription) {
        sendSubscriptionToServer(subscription);
      }
    });
  });

  // Wire up the enable-notifications button (settings page)
  const btn = document.getElementById("enable-push-btn");
  if (!btn) return;

  updateButtonState(btn);

  btn.addEventListener("click", () => {
    const applicationServerKey = vapidPublicKey.content;
    navigator.serviceWorker.ready.then((registration) => {
      Notification.requestPermission().then((permission) => {
        if (permission !== "granted") return;

        registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(applicationServerKey)
        }).then((newSubscription) => {
          sendSubscriptionToServer(newSubscription);
          updateButtonState(btn);
        });
      });
    });
  });
});

function updateButtonState(btn) {
  if (Notification.permission === "granted") {
    btn.textContent = "✓ 通知が有効です";
    btn.disabled = true;
    btn.classList.add("opacity-50", "cursor-not-allowed");
  } else if (Notification.permission === "denied") {
    btn.textContent = "通知がブロックされています（端末の設定から変更してください）";
    btn.disabled = true;
    btn.classList.add("opacity-50", "cursor-not-allowed");
  }
}

function sendSubscriptionToServer(subscription) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]');
  fetch("/push_subscriptions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken ? csrfToken.content : ""
    },
    body: JSON.stringify(subscription.toJSON())
  });
}

function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const rawData = atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

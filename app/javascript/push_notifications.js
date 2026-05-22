// Register Web Push notification subscription
document.addEventListener("DOMContentLoaded", () => {
  const vapidPublicKey = document.querySelector('meta[name="vapid-public-key"]');
  if (!vapidPublicKey) return;

  const applicationServerKey = vapidPublicKey.content;
  if (!applicationServerKey) return;

  if (!("serviceWorker" in navigator) || !("PushManager" in window)) return;

  navigator.serviceWorker.ready.then((registration) => {
    registration.pushManager.getSubscription().then((subscription) => {
      if (subscription) {
        // Already subscribed — send existing subscription to server
        sendSubscriptionToServer(subscription);
        return;
      }

      // Request notification permission from the user
      Notification.requestPermission().then((permission) => {
        if (permission !== "granted") return;

        registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(applicationServerKey)
        }).then((newSubscription) => {
          sendSubscriptionToServer(newSubscription);
        });
      });
    });
  });
});

// Send subscription data to the server
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

// Convert a Base64 string to Uint8Array
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

// Web Push通知のサブスクリプション登録
document.addEventListener("DOMContentLoaded", () => {
  const vapidPublicKey = document.querySelector('meta[name="vapid-public-key"]');
  if (!vapidPublicKey) return;

  const applicationServerKey = vapidPublicKey.content;
  if (!applicationServerKey) return;

  if (!("serviceWorker" in navigator) || !("PushManager" in window)) return;

  navigator.serviceWorker.ready.then((registration) => {
    registration.pushManager.getSubscription().then((subscription) => {
      if (subscription) {
        // 既にサブスクリプション済み → サーバーに登録
        sendSubscriptionToServer(subscription);
        return;
      }

      // 通知許可をリクエスト
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

// サブスクリプション情報をサーバーに送信
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

// Base64文字列をUint8Arrayに変換
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

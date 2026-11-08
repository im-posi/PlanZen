// PlanZen bildirim servisi
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (e) => e.waitUntil(self.clients.claim()));

self.addEventListener("push", (e) => {
  let d = {};
  try { d = e.data ? e.data.json() : {}; } catch (_) {}
  e.waitUntil(self.registration.showNotification(d.t || "PlanZen", {
    body: d.b || "",
    icon: "icon-192.png",
    badge: "icon-192.png",
    tag: d.id || undefined,
    data: { id: d.id || null, k: d.k || null }
  }));
});

self.addEventListener("notificationclick", (e) => {
  e.notification.close();
  const id = (e.notification.data || {}).id || null;
  const url = self.registration.scope + (id ? "?n=" + id : "");
  e.waitUntil((async () => {
    const all = await self.clients.matchAll({ type: "window", includeUncontrolled: true });
    for (const c of all) {
      if (c.url.startsWith(self.registration.scope)) {
        await c.focus();
        c.postMessage({ type: "open-notification", id });
        return;
      }
    }
    await self.clients.openWindow(url);
  })());
});
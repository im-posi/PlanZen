// PlanZen: bildirimler + çevrimdışı açılış
// Dosyalar "önce internet, yoksa kayıtlı kopya" yöntemiyle sunulur: internet varken hep en yeni sürüm gelir.
const CACHE = "planzen-v2";
const SHELL = ["./", "index.html", "manifest.webmanifest", "icon-192.png", "icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil((async () => {
    const c = await caches.open(CACHE);
    await Promise.all(SHELL.map((u) => c.add(u).catch(() => {})));
    await self.skipWaiting();
  })());
});

self.addEventListener("activate", (e) => {
  e.waitUntil((async () => {
    for (const k of await caches.keys()) if (k !== CACHE) await caches.delete(k);
    await self.clients.claim();
  })());
});

const withTimeout = (p, ms) => Promise.race([p, new Promise((_, rej) => setTimeout(() => rej(new Error("zaman aşımı")), ms))]);

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const own = url.origin === self.location.origin;
  const cdn = url.hostname === "cdn.jsdelivr.net";
  if (!own && !cdn) return; // Supabase ve diğer sunuculara karışma
  e.respondWith((async () => {
    const cache = await caches.open(CACHE);
    try {
      const res = await withTimeout(fetch(req), 4500);
      if (res && (res.ok || res.type === "opaque")) {
        cache.put(req, res.clone());
        if (req.mode === "navigate") cache.put("index.html", res.clone());
      }
      return res;
    } catch (_) {
      const hit = await cache.match(req, { ignoreSearch: true });
      if (hit) return hit;
      if (req.mode === "navigate") {
        const idx = (await cache.match("index.html")) || (await cache.match("./"));
        if (idx) return idx;
      }
      return new Response("Çevrimdışısın ve bu sayfa henüz cihazına kaydedilmemiş. İnternete bağlanıp bir kez aç.", { status: 503, headers: { "Content-Type": "text/plain; charset=utf-8" } });
    }
  })());
});

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
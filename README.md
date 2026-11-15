# PlanZen

YKS'ye hazırlanan öğrenciler için, tek dosyalık (`index.html`) bir çalışma planlayıcı. Telefona ana ekrana eklenerek uygulama gibi kullanılır. Türkçe arayüz.

## Neler var?

- **Odak sayacı:** ders seçip kronometre başlat; süreler ders ders kaydedilir, geçmiş günler düzeltilebilir.
- **Haftalık program:** zaman aralıklı Ders/Konu/Soru blokları, sürükle-bırak, sadakat yüzdesi, arşiv ve gelecek hafta planı.
- **Soru ve deneme takibi:** doğru/yanlış girişi, net hesabı (doğru − yanlış/4), ders ve konu bazlı istatistik, zayıf konular, deneme net grafiği.
- **Hafıza kartları:** Türk Dili ve Edebiyatı, dönemlere ayrılmış; aralıklı tekrar (Leitner) ile.
- **Arkadaşlar:** kullanıcı adıyla ekle, haftalık süre ve istatistikleri karşılaştır.
- **Rozetler, seri, çalışma takvimi, haftalık özet görseli.**
- **Bildirimler:** sabah motivasyon mesajları ve duyurular (web push), yönetici paneli.
- **Yedek:** her gece otomatik yedek (son 14), elle yedek, dosyaya indir/dosyadan yükle, tek tıkla geri yükleme.
- **Hesap:** e-posta ile giriş, "şifremi unuttum", ayarlardan şifre değiştirme.
- **Çevrimdışı açılış, koyu/açık/dinamik tema, iPhone renk paleti.**

## Dosyalar

| Dosya | Ne işe yarar |
|---|---|
| `index.html` | Uygulamanın tamamı (HTML, CSS, JS) |
| `sw.js` | Service worker: çevrimdışı açılış ve push bildirimleri |
| `manifest.webmanifest`, `icon-*.png` | Ana ekrana ekleme |
| `kartlar.json` | Hafıza kartlarının içeriği |
| `supabase_*.sql` | Veritabanı kurulum ve güncelleme dosyaları |

> `planzen-onizleme.html` yalnızca bilgisayarda deneme içindir (giriş ekranı kapalı, sahte veri). Depoya yüklenmemelidir.

## Kurulum

1. [Supabase](https://supabase.com) üzerinde proje aç.
2. SQL Editor'da sırayla çalıştır: `supabase_kurulum.sql`, `supabase_guncelleme.sql`, `supabase_guncelleme_2.sql`, `supabase_duzeltme.sql`, `supabase_yedek.sql`.
3. `index.html` içindeki `SUPABASE_URL` ve `SUPABASE_KEY` (publishable key) değerlerini kendi projenle değiştir.
4. Supabase > Authentication > URL Configuration bölümünde **Site URL**'ye yayın adresini yaz ve **Redirect URLs**'e `https://KULLANICI.github.io/PlanZen/**` ekle (şifre sıfırlama ve e-posta doğrulama bağlantıları için gerekli).
5. Dosyaları GitHub'a yükle, Settings > Pages'den yayımla.
6. iPhone'da bildirim için siteyi Safari'den **Ana Ekrana Ekle** ile kur (iOS 16.4+).

Bildirim sistemi için ek tablolar, iki Edge Function (`push-api`, `push-cron`) ve her dakika çalışan bir `pg_cron` işi gerekir; bunlar bu depodaki SQL dosyalarında yoktur.

## Güvenlik notları

- Tüm tablolarda satır güvenliği (RLS) açıktır; kullanıcı yalnızca kendi verisini ve arkadaşlarının paylaşılan özetini görür.
- Arkadaşlar ham verini değil, yalnızca profilindeki özet istatistikleri görür.
- Yedekler yalnızca sahibi tarafından okunur; geri yükleme öncesi mevcut veri ayrıca yedeklenir.
- Supabase panelinden "Leaked password protection" özelliğini açman önerilir.

## Teknoloji

Tek sayfa, framework yok: saf HTML/CSS/JS. Arka uç: Supabase (Auth, Postgres, Edge Functions, pg_cron). Yayın: GitHub Pages.

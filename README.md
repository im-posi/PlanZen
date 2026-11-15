# PlanZen

YKS'ye hazırlanan öğrenciler için bir çalışma planlayıcı. Telefona ana ekrana eklenerek uygulama gibi kullanılır. Türkçe arayüz.

## Neler var?

- **Odak sayacı:** ders seçip kronometre başlat; süreler ders ders kaydedilir, geçmiş günler düzeltilebilir.
- **Haftalık program:** zaman aralıklı Ders/Konu/Soru blokları, sürükle-bırak, sadakat yüzdesi, arşiv ve gelecek hafta planı.
- **Soru ve deneme takibi:** doğru/yanlış girişi, net hesabı (doğru − yanlış/4), ders ve konu bazlı istatistik, zayıf konular, deneme net grafiği.
- **Hafıza kartları:** Eberlemesi güç önemli kavramlar için ilaç. Aralıklı tekrar (Leitner) ile.
- **Arkadaşlar:** kullanıcı adıyla ekle, haftalık süre ve istatistikleri karşılaştır.
- **Rozetler, seri, çalışma takvimi, haftalık özet görseli.**
- **Bildirimler:** sabah motivasyon mesajları ve duyurular.
- **Yedek:** ilerlemelerin her gece otomatik yedeklenir.
- **Hesap:** e-posta ile giriş, "şifremi unuttum", ayarlardan şifre değiştirme.
- **Çevrimdışı açılış, koyu/açık/dinamik tema, renk paleti.**

## Dosyalar

| Dosya | Ne işe yarar, Meraklısına |
|---|---|
| `index.html` | Uygulamanın tamamı (HTML, CSS, JS) |
| `sw.js` | Service worker: çevrimdışı açılış ve push bildirimleri |
| `manifest.webmanifest`, `icon-*.png` | Ana ekrana ekleme |
| `kartlar.json` | Hafıza kartlarının içeriği |
| `supabase_*.sql` | Veritabanı kurulum ve güncelleme dosyaları |

> `planzen-onizleme.html` yalnızca bilgisayarda deneme içindir (giriş ekranı kapalı, sahte veri). Depoya yüklenmemelidir. (Dosya zaten repoda yer almaz.)

## Güvenlik notları

- Tüm tablolarda satır güvenliği (RLS) açıktır; kullanıcı yalnızca kendi verisini ve arkadaşlarının paylaşılan özetini görür.
- Arkadaşlar ham verini değil, yalnızca profilindeki özet istatistikleri görür.
- Yedekler yalnızca sahibi tarafından okunur; geri yükleme öncesi mevcut veri ayrıca yedeklenir. Seçenek yok ise otomatik sistem senin için çalışıyordur.


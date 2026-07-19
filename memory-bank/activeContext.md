# Active Context

## Şu anki durum (2026-07-19)
- BÜYÜK handoff v2 paketi uygulandı: 29 dosyalık
  "Eğitimciler Platformu Tasarımı (1).zip" (öncekinin 11 dosyalık
  halinin genişletilmişi). Detay: progress.md 2026-07-19.
- Yeni: iller.dart (81 il/973 ilçe), öğrenci ilanları (kapalı ağ) +
  teklif akışı, 7 panel ekranı, vitrin sayfaları (Yardım/Güvenlik/KVKK/
  Sözleşme/Ücretlendirme/Kariyer), admin "Paketler & gelir" + ücret
  aralığı yönetimi, mesajlaşmada iletişim maskeleme, karşılaştırma v2.
- 21/21 test, analyze temiz, Vercel'de canlı ve ekran görüntüleriyle
  doğrulandı.

## Açık işler
- Gerçek backend entegrasyonu (Firebase/Supabase) — sonraki faz.
- Gerçek video oynatma ve dosya yükleme (şimdilik placeholder).
- Gerçek kimlik doğrulama (şimdilik demo kullanıcı seçimi).
- GitHub Pages dağıtımı eski kaldı (Vercel güncel); gerekirse
  base-href'li ayrı build ile tazele.
- Kabul listesi 2. madde (otomatik link testi) Flutter'da widget testi
  olarak kısmen karşılandı; ekran başına tıklama testi eklenebilir.

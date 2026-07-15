# Progress

## 2026-07-15
- [x] `flutter create egitimciler_platformu` (web, windows, android)
- [x] Memory bank kuruldu (RooFlow tarzı)
- [x] Modeller + mock veri
- [x] AppState (provider)
- [x] Ekranlar: giriş, keşfet, detay, karşılaştır, mesajlar, teklifler, iş ilanları, öğretmen havuzu, profilim
- [x] flutter analyze temiz (0 issue)
- [x] flutter test: 9/9 geçti (rol görünürlük testleri dahil)
- [x] flutter build web --release başarılı
- [x] README yazıldı
- [x] İlk git commit

## 2026-07-16 — Deploy
- [x] GitHub repo: https://github.com/gokhan6167/egitimciler_platformu (master)
- [x] GitHub Pages canlı: https://gokhan6167.github.io/egitimciler_platformu/
- Deploy yöntemi: `flutter build web --release --base-href /egitimciler_platformu/`
  → `build/web` içindeki yerel git repo'dan `gh-pages` dalına force push.
- Yeniden deploy: aynı build komutu + `cd build/web; git add -A; git commit; git push --force https://github.com/gokhan6167/egitimciler_platformu.git gh-pages`

## 2026-07-16 — Pusula Eğitim tasarım sistemi
- Kaynak: Claude Design projesi "Eğitimciler Platformu Tasarımı" (4 dosya:
  landing v2, ilan detay özel okul / dershane-etüt / özel öğretmen).
- [x] Marka: Pusula Eğitim — yeşil #0F7A63, Plus Jakarta Sans + Public Sans
  (google_fonts), pill butonlar; tema `lib/theme/pusula_theme.dart`.
- [x] Landing page (`landing_screen.dart`) giriş öncesi ana sayfa oldu.
- [x] İlan detay yeniden tasarlandı; tür bazlı varyantlar:
  öğretmen (avatar + belgeler + paketler + uygunluk), dershane (programlar + etüt saatleri).
- [x] Modeller: ProgramItem, OpeningHour, CredentialItem, highlight alanları.
- [x] 9/9 test, analyze temiz, web build + Pages deploy tazelendi.

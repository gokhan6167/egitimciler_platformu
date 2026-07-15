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

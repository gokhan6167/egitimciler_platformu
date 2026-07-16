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

## 2026-07-16 — Vercel deploy
- [x] Vercel canlı: https://pusula-egitim.vercel.app (proje: gokhans-projects-fcf81002/pusula-egitim)
- Deploy yöntemi: `flutter build web --release --base-href /` (Vercel için base `/`,
  GitHub Pages için `/egitimciler_platformu/` — ikisi ayrı build ister).
- Yeniden deploy: build sonrası `build/web` içinde `vercel deploy --prod --yes`.
  `build/web/.vercel` klasörü proje bağlantısını tutar; silinirse
  `vercel link --yes --project pusula-egitim` ile yeniden bağla.
- Vercel hesabı: gokhan61673-6714 (CLI ile giriş yapıldı).

## 2026-07-16 — Giriş ekranı, arama düzeltmesi, misafir akışı, veri
- [x] Giriş ekranı "Giris Yap.dc.html" tasarımına göre yeniden yazıldı:
  split-screen (form + alıntı paneli), rol sekmeleri (Veli/Öğrenci, Öğretmen,
  Kurum), e-posta/şifre, sosyal butonlar (demo'da snackbar). Demo hesap
  seçici rol sekmesine entegre; seçim e-postayı otomatik doldurur.
- [x] Arama motoru düzeltildi: Dart'ta 'İ'.toLowerCase() birleşik nokta
  ürettiğinden Türkçe aramalar eşleşmiyordu → AppState._fold ile TR
  karakter normalizasyonu (her iki taraf ASCII'ye katlanır, kelime bazlı).
- [x] Landing hero araması gerçek TextField oldu; sorgu + tür filtresiyle
  SearchResultsScreen açılır (girişsiz). Kategori kartları ve öne çıkan
  ilanlar da girişsiz detaya gider.
- [x] Misafir akışı: Browse/Detay/Karşılaştırma girişsiz çalışır; teklif,
  mesaj, puan verme login'e yönlendirir (_requireLogin).
- [x] Mock veri genişletildi: 5 veli, 5 öğrenci, 5 okul, 5 dershane, 5 kurs
  (yeni kurum kullanıcıları + ilan profilleri + yorumlar).
- [x] 11/11 test geçti (yeni: TR arama testi + misafir arama widget testi),
  analyze temiz, Vercel yeniden deploy edildi.

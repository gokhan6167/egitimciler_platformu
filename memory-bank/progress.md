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

## 2026-07-16 — Tam misafir gezinme
- Kural: ziyaretçi üyeliksiz her yeri gezer (arama, ilan detayları,
  karşılaştırma); giriş SADECE ilan verme/düzenleme, mesajlaşma, teklif ve
  puan verme için istenir (_requireLogin).
- [x] Landing navbar: Keşfet → sonuçlar, Karşılaştır → CompareScreen,
  Nasıl çalışır → bölüme kaydırma; Öğretmen kariyeri → giriş (kapalı ağ).
- [x] CTA "Aramaya başla" ve footer Keşfet linkleri girişsiz kategori
  sonuçlarına gider.

## 2026-07-16 — Ana sayfa butonu + canlı ziyaretçi testi
- [x] HomeButton widget'ı (lib/widgets/home_button.dart): tüm AppBar'lara
  eklendi (sonuçlar, detay, karşılaştır, sohbet, HomeShell); giriş
  ekranına "Ana sayfa" butonu; landing navbar oturum açıkken "Panele dön"
  gösterir.
- [x] Canlı site puppeteer-core + headless Chrome ile ziyaretçi olarak
  test edildi: arama → sonuçlar → karşılaştırmaya ekleme → ilan detayı →
  ana sayfa butonu; hepsi girişsiz çalışıyor (ekran görüntüleriyle
  doğrulandı).
- Not: kullanıcı "arama çalışmıyor" dediğinde neden büyük olasılıkla
  Flutter service worker'ın eski sürümü önbelleğe almasıydı → sert
  yenileme (Ctrl+F5) gerekir. Hero aramada seçili sekme tür filtresi
  uygular; yanlış sekmede arama 0 sonuç verebilir (olası UX karışıklığı).

## 2026-07-16 — Kayıt Ol + yeni arama sayfası tasarımları
- [x] Kayıt ekranı "Kayit Ol.dc.html" tasarımından (register_screen.dart):
  rol kartları (Veli/Öğrenci, Öğretmen, Kurum), role göre alanlar (Kurum
  adı + tür dropdown'u, Branş), KVKK onayı, role göre yan panel.
  AppState.registerUser: hesap oluşturur, eğitimcilere boş ilan profili
  açar, otomatik giriş yapar. Landing "Kayıt ol" ve login "Ücretsiz kayıt
  olun" buna bağlandı.
- [x] Arama sonuçları "Arama - Ozel Okul/Kurs.dc.html" tasarımından
  yeniden yazıldı (BrowseScreen geniş düzen): pill arama çubuğu + il
  dropdown + Ara; 264px filtre kenar çubuğu (Tür sayaçlı radio, ücret
  slider, Şehir, En az puan pilleri, Temizle), sıralama pilleri
  (Önerilen/Puan/Ücret), kaldırılabilir aktif filtre çipleri, yatay ilan
  kartları (görsel + rozetler + etiketler + açıklama + fiyat +
  Karşılaştır/Mesaj/Teklif iste). Dar ekranda eski kompakt düzen korunur.
  Tasarımlardaki modele uymayan filtreler (kademe, mesafe, yaş grubu,
  gün) bilinçli olarak Tür/Şehir'e uyarlandı.
- [x] 12/12 test (yeni: kayıt testi), analyze temiz, Vercel deploy,
  canlıda headless Chrome ile iki ekran da görsel doğrulandı.
- [x] Landing hero araması v2 tasarımına birebir uyduruldu: kategori
  sekmeleri arama hapının içinde (solda, ayraçlı), "İl / ilçe" bölümü
  kaldırıldı; dar ekranda sekmeler barın üstünde kalır. Canlıda doğrulandı.

## 2026-07-16 — Türe özel filtreler + Admin Paneli
- [x] Yapılandırılabilir filtre sistemi: FilterSection (checkbox/radio/pills,
  active bayrağı), SearchPageConfig; tür başına bölümler 4 arama tasarımından
  (okul: Kademe+Olanaklar; kurs: Alan+Yaş+Gün; dershane: Program+Olanaklar;
  öğretmen: Branş+Seviye+Ders şekli+Deneyim). Eşleşme: TR-katlanmış kelime
  araması (ad/açıklama/özellikler/programlar/sahip bio); 'experience' özel
  bölümü sahibin yılına bakar. AppState.facetSelections; bölümler arası AND,
  bölüm içi OR. Sıralama 4 ölçüt: Önerilen/Puan/Ücret ↑/Ücret ↓.
- [x] Moderasyon modeli: ListingStatus (pending/published/suspended/rejected;
  yalnız published aranır), ReviewStatus (yalnız published puana sayılır),
  JobPosting.active, AppUser.suspended. Yeni eğitimci kaydı pending ilan açar.
- [x] Admin Paneli "Admin Panel.dc.html"den (admin_panel_screen.dart): koyu
  kenar çubuğu + 6 görünüm — Genel bakış (canlı istatistik, onay kuyruğu
  Onayla/Reddet, etkinlik akışı), Filtre yönetimi (tür sekmeleri, grup
  kartları: aktif/pasif anahtar, seçenek çipi silme, seçenek ekleme, grup
  silme, yeni grup diyaloğu), İlanlar/Kullanıcılar/İş ilanları tabloları
  (askıya al/yayınla), Yorum moderasyonu (Yayınla/Kaldır).
- [x] Admin girişi: UserRole.admin, 'Site Yöneticisi' demo hesabı (giriş
  ekranında Kurum sekmesinin ilk kaydı); HomeShell admin'i panele yönlendirir.
- [x] 14/14 test (facet + admin moderasyon/CRUD testleri eklendi). Canlıda
  puppeteer ile TEK TEK doğrulandı: 4 tür sayfası ve filtreleri, Lise facet
  tıklaması (2 sonuç + çip), admin girişi, 6 panel görünümü, Onayla akışı
  (rozet 2→1), Montessori seçeneği ekleme. Ekran görüntüleriyle kayıtlı.

## 2026-07-16 — Diğer güncellemeler
- [x] Zirve Dershanesi → Kavram Dershanesi (veri + landing tablo/kariyer).
- [x] İlan rozetleri çeşitlendi: ProviderProfile.badge (Doğrulanmış/Öne
  çıkan/En çok tercih/Yeni), landing + arama kartlarında gösteriliyor.
- [x] v2 tasarım GÜNCELLENDİ ve uygulandı: hero başlık kısaldı ("En uygun
  eğitimi karşılaştırarak bulun"), arama hapı artık metin girişi değil —
  4 renkli kategori butonu (yeşil/amber/indigo/pembe) + Ara; butonlar
  doğrudan tür sayfasını açar. Metin araması sonuç sayfasındaki çubukta
  yaşamaya devam ediyor. Widget testleri güncellendi (hero tab akışı).

# Eğitimciler Platformu

Velilerin ve öğrencilerin çocukları için **özel okul, kurs, dershane ve özel öğretmen**
arayabileceği; eğitimcilerin ilan verip kendilerini tanıtabileceği platform (Flutter).

## Özellikler

- **Rol bazlı giriş (demo)**: Veli, Öğrenci, Özel Öğretmen, Kurum.
- **İlan/tanıtım sayfaları**: fotoğraf galerisi, kısa tanıtım videosu, açıklama, özellikler, fiyat.
- **Arama ve süzme**: tür, şehir, azami fiyat, asgari puan, metin arama.
- **Karşılaştırma**: en fazla 3 ilanı yan yana tablo halinde karşılaştırma.
- **Puanlama**: yıldız + yorum (veli/öğrenci).
- **Mesajlaşma**: kullanıcılar arası birebir sohbet.
- **Teklif sistemi**: teklif iste → eğitimci fiyat verir → kabul/ret.
- **İş ilanları**: kurumlar açar, **sadece öğretmenler** görür.
- **Öğretmen havuzu**: iş arayan öğretmenleri **sadece kurumlar** görür.

## Çalıştırma

```bash
flutter pub get
flutter run -d chrome    # veya: -d windows
```

## Test

```bash
flutter analyze
flutter test
```

## Mimari

- `lib/models/` — saf Dart veri modelleri
- `lib/data/mock_data.dart` — demo/seed veri (backend gelince repository olacak)
- `lib/state/app_state.dart` — Provider tabanlı tek state kaynağı
- `lib/screens/` — ekranlar (rol bazlı görünürlük)
- `memory-bank/` — RooFlow tarzı proje hafızası (ürün bağlamı, kararlar, ilerleme)

## Yol Haritası

- [ ] Gerçek backend (Firebase/Supabase): auth, veritabanı, dosya yükleme
- [ ] Gerçek video oynatma (`video_player`)
- [ ] Bildirimler, favoriler, gelişmiş arama

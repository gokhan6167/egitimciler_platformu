# Product Context — Eğitimciler Platformu

## Vizyon
Velilerin ve öğrencilerin çocukları için özel okul, kurs, dershane ve özel öğretmen
arayabileceği; eğitimcilerin de kendilerini tanıtıp ilan verebileceği bir platform.

## Kullanıcı Rolleri
- **Veli / Öğrenci**: Arama, filtreleme, karşılaştırma, puanlama, mesajlaşma, teklif isteme.
- **Özel Öğretmen**: Kendi tanıtım sayfası (ilan), iş arama modu (sadece kurumlar görür),
  iş ilanlarını görme ve başvurma, mesajlaşma, gelen teklif taleplerine fiyat verme.
- **Kurum (Özel okul / Kurs / Dershane)**: Tanıtım sayfası (ilan), iş ilanı açma
  (sadece öğretmenler görür), iş arayan öğretmen havuzunu görme, mesajlaşma, teklif yanıtlama.

## Temel Özellikler
1. İlan/tanıtım sayfaları: fotoğraf galerisi + kısa tanıtım videosu + açıklama + özellikler + fiyat.
2. Arama ve süzme: tür, şehir, fiyat aralığı, minimum puan, metin arama.
3. Karşılaştırma: en fazla 3 ilanı yan yana tablo halinde karşılaştırma.
4. Puanlama: yıldız + yorum (veli/öğrenci).
5. Mesajlaşma: tüm kullanıcılar arasında birebir sohbet.
6. Teklif sistemi: veli/öğrenci teklif ister → eğitimci fiyat verir → kabul/ret.
7. İş ilanları: kurum açar, SADECE öğretmen rolü görür.
8. Öğretmen havuzu: iş arayan öğretmenleri SADECE kurum rolü görür.

## Görünürlük Kuralları (kritik)
- JobPosting listesi: yalnızca `UserRole.teacher`.
- İş arayan öğretmen havuzu: yalnızca `UserRole.institution`.

## Teknoloji
- Flutter (web + windows + android), Provider state management.
- Şimdilik mock/in-memory veri katmanı; gerçek backend (Firebase/Supabase) sonraki faz.

import 'package:flutter/material.dart';

import '../theme/pusula_theme.dart';
import '../widgets/showcase.dart';

/// Yardım merkezi — grouped FAQ accordions from `Yardim.dc.html`.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _groups = <(String, List<(String, String)>)>[
    (
      'Veliler ve öğrenciler',
      [
        (
          'Arama ve karşılaştırma nasıl çalışır?',
          'Kategori seçin (özel okul, kurs, dershane, özel öğretmen), il/ilçe '
              've diğer filtrelerle daraltın. "+ Karşılaştır" ile en fazla 4 '
              'ilanı ücret, mesafe, puan ve kontenjan üzerinden yan yana '
              'inceleyebilirsiniz.'
        ),
        (
          'Teklif isteği gönderince ne olur?',
          'Talebiniz kuruma/öğretmene iletilir; yanıt platform mesajlarınıza '
              'düşer ve e-posta ile bildirilir. Ortalama yanıt süresi ilan '
              'sayfasında görünür. Teklif istemek ücretsizdir ve bağlayıcı '
              'değildir.'
        ),
        (
          'Ders arayan öğrenci ilanını nasıl veririm?',
          'Veli veya öğrenci hesabıyla "Ücretsiz ilan ver" adımından ders, '
              'seviye, dersin yeri, bütçe ve uygunluk bilgilerinizi girin. '
              'İlanınız onaydan sonra yalnızca doğrulanmış öğretmenlere '
              'görünür; teklifler size bildirilir.'
        ),
        (
          'Değerlendirme puanları güvenilir mi?',
          'Yalnızca platform üzerinden iletişime geçmiş kullanıcılar '
              'değerlendirme bırakabilir. Hakaret, reklam veya kişisel bilgi '
              'içeren yorumlar moderasyon ekibince kaldırılır.'
        ),
      ]
    ),
    (
      'Öğretmenler',
      [
        (
          'Belge doğrulama nasıl yapılır?',
          'Profilinize diploma, formasyon ve adli sicil belgenizi yükleyin; '
              'ekibimiz 2 iş günü içinde inceler. Doğrulanan profiller ✓ '
              'rozeti alır ve öğrenci ilanlarının iletişim bilgilerine '
              'erişebilir.'
        ),
        (
          'İş ilanlarını kimler görür?',
          'Kurumların açtığı iş ilanları yalnızca öğretmen hesaplarına '
              'görünür. Başvurunuz yalnızca ilgili kuruma iletilir; profiliniz '
              'veli ve öğrencilere kapalıdır.'
        ),
        (
          'Öğrenci ilanlarına nasıl teklif veririm?',
          '"Ders Arayan Öğrenci" sayfasında branş, seviye, il/ilçe ve bütçe '
              'filtreleriyle size uygun ilanları bulun; "Teklif ver" ile '
              'ücretinizi ve uygunluğunuzu iletin. Öğrenci kabul ederse '
              'mesajlaşma açılır.'
        ),
      ]
    ),
    (
      'Kurumlar',
      [
        (
          'Kurum ilanı nasıl verilir?',
          'Kurum hesabı açın, kurum bilgilerinizi ve MEB ruhsat numaranızı '
              'girin. Fotoğraf ve tanıtım videosu ekleyin; ilanınız doğrulama '
              'sonrası yayına alınır.'
        ),
        (
          'Doğrulanmış kurum rozeti nasıl alınır?',
          'Ruhsat, vergi levhası ve yetkili kimlik doğrulaması tamamlanan '
              'kurumlar rozet alır. Rozetli kurumlar aramada öne çıkar ve '
              '"yalnızca doğrulanmış" filtresinde listelenir.'
        ),
        (
          'İş ilanı açma ve başvuru yönetimi',
          'Kurum panelinden pozisyon, branş ve çalışma türü girin. Başvuruları '
              'tek panelden görüntüler, aday öğretmen havuzunda arama '
              'yapabilirsiniz.'
        ),
      ]
    ),
    (
      'Hesap ve güvenlik',
      [
        (
          'Şifremi unuttum, ne yapmalıyım?',
          'Giriş sayfasındaki "Şifremi unuttum" bağlantısından e-postanıza '
              'sıfırlama bağlantısı isteyin. Bağlantı 30 dakika geçerlidir.'
        ),
        (
          'Hesabımı nasıl silerim?',
          'Ayarlar → Hesap → "Hesabı kalıcı olarak sil" adımını izleyin. '
              'Verileriniz KVKK kapsamındaki saklama süreleri sonunda tamamen '
              'kaldırılır.'
        ),
        (
          'Şüpheli bir ilan veya kullanıcı gördüm',
          'İlan veya profil sayfasındaki "Bildir" bağlantısını kullanın ya da '
              'Güvenlik sayfasındaki adımları izleyin. Bildirimler 24 saat '
              'içinde incelenir.'
        ),
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      children: [
        const PageIntro(
          title: 'Yardım merkezi',
          lead: Text(
            'Sık sorulan sorular. Aradığınızı bulamazsanız bize yazın.',
            style: TextStyle(fontSize: 16, color: PusulaColors.body),
          ),
        ),
        for (final (group, items) in _groups) ...[
          Text(group, style: pusulaHeading(fontSize: 19)),
          const SizedBox(height: 10),
          for (final (q, a) in items)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(),
                title: Text(q,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: PusulaColors.body)),
                ],
              ),
            ),
          const SizedBox(height: 18),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PusulaColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hâlâ yardıma mı ihtiyacınız var?',
                  style: pusulaHeading(fontSize: 18)),
              const SizedBox(height: 6),
              const Text('destek@pusulaegitim.com · Hafta içi 09.00–18.00',
                  style: TextStyle(color: PusulaColors.body)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Demo: destek talebi formu yakında eklenecek.'))),
                child: const Text('Destek talebi aç'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Güvenlik — verification/trust cards from `Guvenlik.dc.html`.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  static const _items = <(String, String)>[
    (
      'Kurum doğrulama',
      'Okul, kurs ve dershaneler MEB ruhsatı, vergi levhası ve yetkili '
          'kimliğiyle doğrulanır. Rozetsiz kurumlar "doğrulanmış" filtresinde '
          'listelenmez.'
    ),
    (
      'Öğretmen belge kontrolü',
      'Özel öğretmen profillerinde diploma, pedagojik formasyon ve adli sicil '
          'belgesi incelenir. Doğrulama tamamlanmadan öğrenci ilanlarının '
          'iletişim bilgileri açılmaz.'
    ),
    (
      'Kapalı ağ ilkesi',
      'İş ilanlarını yalnızca öğretmenler, öğretmen profillerini yalnızca '
          'kurumlar, öğrenci ilanlarının iletişimini yalnızca doğrulanmış '
          'öğretmenler görür. Veriler kategoriler arasında paylaşılmaz.'
    ),
    (
      'Platform içi mesajlaşma',
      'İlk iletişim platform üzerinden kurulur; mesajlar şifreli saklanır. '
          'Telefon ve adres bilgisi ancak iki taraf da onay verdiğinde '
          'paylaşılır.'
    ),
    (
      'Gerçek değerlendirmeler',
      'Yalnızca platform üzerinden iletişim kurmuş kullanıcılar puan '
          'verebilir. Sahte, hakaret veya reklam içeren yorumlar moderasyonla '
          'kaldırılır.'
    ),
    (
      'Ödeme güvenliği uyarısı',
      'Pusula Eğitim ödemelere aracılık etmez. Kayıt ücreti talep eden '
          'mesajlara itibar etmeyin; ödemeleri her zaman kurumun resmî '
          'kanallarından yapın.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      children: [
        const PageIntro(
          title: 'Güvenlik',
          lead: Text(
            'Çocuğunuzun eğitimi söz konusu olduğunda güven pazarlık konusu '
            'değildir. Platformdaki her ilan ve her hesap şu adımlardan geçer.',
            style: TextStyle(fontSize: 16, color: PusulaColors.body),
          ),
        ),
        for (final (title, body) in _items)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: PusulaColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('✓',
                        style: TextStyle(
                            color: PusulaColors.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: pusulaHeading(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(body,
                            style: const TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: PusulaColors.body)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF1DF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Şüpheli bir durum mu gördünüz?',
                  style: pusulaHeading(fontSize: 18)),
              const SizedBox(height: 6),
              const Text(
                'İlan veya profil sayfasındaki "Bildir" bağlantısını kullanın '
                'ya da guvenlik@pusulaegitim.com adresine yazın. Bildirimler '
                '24 saat içinde incelenir; gerekli durumlarda hesap askıya '
                'alınır.',
                style: TextStyle(
                    fontSize: 14, height: 1.55, color: Color(0xFF8A6212)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shared layout for the two legal documents (numbered sections).
class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final List<(String, List<String>)> sections;

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      maxWidth: 760,
      children: [
        PageIntro(
          title: title,
          lead: Text(subtitle,
              style:
                  const TextStyle(fontSize: 14, color: PusulaColors.muted)),
        ),
        for (var i = 0; i < sections.length; i++) ...[
          Text('${i + 1}. ${sections[i].$1}',
              style: pusulaHeading(fontSize: 18)),
          const SizedBox(height: 8),
          for (final para in sections[i].$2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: para.startsWith('• ')
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ',
                            style: TextStyle(color: PusulaColors.primary)),
                        Expanded(
                          child: Text(para.substring(2),
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: PusulaColors.body)),
                        ),
                      ],
                    )
                  : Text(para,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: PusulaColors.body)),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// KVKK Aydınlatma Metni from `KVKK.dc.html`.
class KvkkScreen extends StatelessWidget {
  const KvkkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'KVKK Aydınlatma Metni',
      subtitle: 'Son güncelleme: 19 Temmuz 2026 · 6698 sayılı Kişisel '
          'Verilerin Korunması Kanunu kapsamında',
      sections: [
        (
          'Veri sorumlusu',
          [
            'Bu aydınlatma metni, Pusula Eğitim Teknolojileri A.Ş. '
                '("Pusula Eğitim") tarafından, pusulaegitim.com platformunu '
                'kullanan veli, öğrenci, öğretmen ve kurum yetkililerinin '
                'kişisel verilerinin işlenmesine ilişkin olarak '
                'hazırlanmıştır.',
          ]
        ),
        (
          'İşlenen kişisel veriler',
          [
            '• Kimlik ve iletişim: ad-soyad, e-posta, telefon, il/ilçe bilgisi',
            '• Hesap ve işlem: üyelik türü, ilanlar, teklif ve mesajlaşma '
                'kayıtları, değerlendirmeler',
            '• Öğretmen doğrulama: diploma, formasyon belgesi, adli sicil '
                'kaydı (açık rızaya dayalı)',
            '• Kurum doğrulama: ruhsat, vergi ve yetkili bilgileri',
            '• Teknik: IP adresi, cihaz/tarayıcı bilgisi, çerez kayıtları',
            'Öğrencilere ilişkin veriler (sınıf düzeyi, ders ihtiyacı) '
                'yalnızca veli onayıyla ve ilan amacıyla sınırlı işlenir; 18 '
                'yaş altı kullanıcılar platformu veli gözetiminde kullanır.',
          ]
        ),
        (
          'İşleme amaçları',
          [
            '• Üyelik oluşturulması ve platform hizmetlerinin sunulması',
            '• İlanların yayımlanması, arama-karşılaştırma, teklif ve '
                'mesajlaşma süreçleri',
            '• Doğrulama rozetleri için belge incelemesi',
            '• Güvenlik, moderasyon ve dolandırıcılık önleme',
            '• Yasal yükümlülüklerin yerine getirilmesi',
          ]
        ),
        (
          'Hukuki sebepler',
          [
            'Verileriniz; KVKK m.5/2 uyarınca sözleşmenin kurulması ve ifası, '
                'hukuki yükümlülük, meşru menfaat hukuki sebeplerine, adli '
                'sicil gibi özel nitelikli veriler ise m.6 uyarınca açık '
                'rızanıza dayanılarak işlenir.',
          ]
        ),
        (
          'Verilerin aktarılması',
          [
            'Verileriniz; barındırma ve e-posta hizmeti sağlayıcılarına, '
                'yasal talep hâlinde yetkili kurumlara aktarılabilir. Kapalı '
                'ağ ilkesi gereği öğretmen profilleri velilere, öğrenci '
                'iletişim bilgileri doğrulanmamış hesaplara açılmaz. Veriler '
                'yurt dışına yalnızca KVKK m.9 şartlarıyla aktarılır.',
          ]
        ),
        (
          'Saklama süresi',
          [
            'Üyelik verileri hesap silindikten sonra en geç 6 ay, mesajlaşma '
                'kayıtları 1 yıl, yasal saklama yükümlülüğüne tabi kayıtlar '
                'ilgili mevzuattaki süre boyunca saklanır ve ardından silinir '
                'veya anonimleştirilir.',
          ]
        ),
        (
          'Haklarınız (KVKK m.11)',
          [
            '• Verilerinizin işlenip işlenmediğini öğrenme ve bilgi talep etme',
            '• İşleme amacını ve amacına uygun kullanılıp kullanılmadığını '
                'öğrenme',
            '• Eksik/yanlış işlenmiş verilerin düzeltilmesini isteme',
            '• Silme veya yok edilmesini isteme',
            '• Otomatik sistemlerce analiz sonucu aleyhe çıkan sonuca itiraz',
            '• Zarara uğranması hâlinde tazminat talep etme',
          ]
        ),
        (
          'Başvuru',
          [
            'Taleplerinizi kvkk@pusulaegitim.com adresine veya Ayarlar → '
                'Gizlilik → "KVKK başvurusu" adımından iletebilirsiniz. '
                'Başvurular en geç 30 gün içinde ücretsiz sonuçlandırılır.',
          ]
        ),
      ],
    );
  }
}

/// Kullanıcı Sözleşmesi from `Kullanici Sozlesmesi.dc.html`.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  /// Section list is shared with the registration consent modal.
  static const sections = <(String, List<String>)>[
    (
      'Taraflar ve konu',
      [
        'İşbu sözleşme, Pusula Eğitim Teknolojileri A.Ş. ("Platform") ile '
            'üyelik oluşturan gerçek veya tüzel kişi ("Kullanıcı") arasında, '
            'platform hizmetlerinin kullanım koşullarını düzenlemek amacıyla '
            'elektronik ortamda kurulmuştur. Üyelik sırasında onay kutusunun '
            'işaretlenmesiyle yürürlüğe girer.',
      ]
    ),
    (
      'Platformun niteliği',
      [
        'Platform; veli/öğrenciler ile özel okul, kurs, dershane ve özel '
            'öğretmenleri buluşturan bir ilan ve iletişim aracısıdır. '
            'Platform eğitim hizmetinin tarafı değildir; ders, kayıt ve ödeme '
            'ilişkisi doğrudan Kullanıcılar arasında kurulur. Platform '
            'ödemelere aracılık etmez.',
      ]
    ),
    (
      'Üyelik türleri ve doğrulama',
      [
        '• Veli/Öğrenci: Arama, karşılaştırma, teklif isteme, ders ilanı '
            'verme. 18 yaş altı kullanıcılar veli onayıyla üye olur.',
        '• Öğretmen: Profil ve ders ilanı yayımlama, iş ilanlarını '
            'görüntüleme, öğrenci ilanlarına teklif verme. Belge doğrulaması '
            'tamamlanmadan iletişim bilgilerine erişilemez.',
        '• Kurum: Kurum ilanı ve iş ilanı yayımlama. Ruhsat ve yetkili '
            'doğrulaması zorunludur.',
        'Kullanıcı, verdiği bilgilerin doğru ve güncel olduğunu; sahte belge '
            'veya kimlik kullanılması hâlinde üyeliğin derhâl '
            'sonlandırılacağını kabul eder.',
      ]
    ),
    (
      'Kapalı ağ ve gizlilik ilkesi',
      [
        'İş ilanları yalnızca öğretmen hesaplarına; iş arayan öğretmen '
            'profilleri yalnızca kurum hesaplarına; öğrenci ilanlarının '
            'iletişim bilgileri yalnızca doğrulanmış öğretmen hesaplarına '
            'gösterilir. Kullanıcı, bu erişim kurallarını aşmaya yönelik '
            'girişimde bulunmayacağını kabul eder.',
      ]
    ),
    (
      'Kullanıcı yükümlülükleri',
      [
        '• İlan ve profillerde yanıltıcı bilgi, başkasına ait görsel veya '
            'belge kullanmamak',
        '• Değerlendirmelerde hakaret, reklam ve kişisel veri paylaşmamak',
        '• Platform dışına yönlendirme yaparak doğrulama ve moderasyon '
            'süreçlerini aşmamak',
        '• Diğer kullanıcıların verilerini yalnızca iletişim amacıyla '
            'kullanmak, üçüncü kişilerle paylaşmamak',
      ]
    ),
    (
      'İçerik ve moderasyon',
      [
        'Platform; mevzuata veya işbu sözleşmeye aykırı ilan, yorum ve '
            'mesajları bildirimsiz kaldırma, hesapları askıya alma veya '
            'sonlandırma hakkını saklı tutar. İlanlar yayına alınmadan önce '
            'onay sürecinden geçer.',
      ]
    ),
    (
      'Sorumluluğun sınırlandırılması',
      [
        'Platform, Kullanıcılar arasında kurulan eğitim ilişkisinin '
            'ifasından, ders kalitesinden, ücret ödemelerinden ve taraflar '
            'arasındaki uyuşmazlıklardan sorumlu değildir. Doğrulama '
            'rozetleri belge kontrolüne dayanır; hizmet kalitesi garantisi '
            'anlamına gelmez.',
      ]
    ),
    (
      'Kişisel veriler',
      [
        'Kişisel verilerin işlenmesine ilişkin esaslar KVKK Aydınlatma '
            'Metni\'nde düzenlenmiştir; işbu sözleşmenin ayrılmaz parçasıdır.',
      ]
    ),
    (
      'Değişiklik, fesih ve uyuşmazlık',
      [
        'Platform sözleşmede değişiklik yapabilir; değişiklikler yayımlandığı '
            'anda yürürlüğe girer ve Kullanıcılara bildirilir. Kullanıcı '
            'dilediği zaman hesabını kapatabilir. Uyuşmazlıklarda İstanbul '
            '(Anadolu) Mahkemeleri ve İcra Daireleri yetkilidir; Türk hukuku '
            'uygulanır.',
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Kullanıcı Sözleşmesi',
      subtitle: 'Yürürlük: 19 Temmuz 2026 · Sürüm 1.0',
      sections: sections,
    );
  }
}

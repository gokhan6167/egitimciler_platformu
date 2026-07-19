/// Seed data for the MVP. Will be replaced by a real backend later.
library;

import '../models/models.dart';

String _pic(int seed) => 'https://picsum.photos/seed/edu$seed/640/360';

/// Demo e-mail derived from the user's name (TR chars folded to ASCII).
String _emailFor(AppUser u) {
  const map = {
    'ı': 'i', 'ç': 'c', 'ğ': 'g', 'ö': 'o', 'ş': 's', 'ü': 'u',
    'İ': 'i', 'Ç': 'c', 'Ğ': 'g', 'Ö': 'o', 'Ş': 's', 'Ü': 'u',
  };
  final slug = u.name
      .split('')
      .map((c) => map[c] ?? c.toLowerCase())
      .join()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '.');
  return u.role == UserRole.institution
      ? 'info@${slug.replaceAll('.', '')}.com'
      : '$slug@eposta.com';
}

/// Fresh copies each call so AppState instances don't share mutable state.
/// Sections mirror the type-specific "Arama - *" Claude Design files;
/// admins can add/remove sections and options at runtime.
List<SearchPageConfig> buildSearchConfigs() => [
      SearchPageConfig(type: ProviderType.privateSchool, sections: [
        FilterSection(
          id: 'kademe',
          title: 'Kademe',
          subtitle: 'Özel okul arama sayfasındaki kademe filtresi',
          kind: FilterKind.checkbox,
          options: ['Anaokulu', 'İlkokul', 'Ortaokul', 'Lise'],
        ),
        FilterSection(
          id: 'mesafe',
          title: 'Mesafe',
          subtitle: 'Konuma göre uzaklık (yakında konum verisiyle)',
          kind: FilterKind.radio,
          affectsResults: false,
          options: ['1 km içinde', '3 km içinde', '5 km içinde', 'İlçe geneli'],
        ),
        FilterSection(
          id: 'mufredat',
          title: 'Müfredat',
          subtitle: 'Eğitim modeli filtresi',
          kind: FilterKind.checkbox,
          affectsResults: false,
          options: ['MEB', 'IB', 'Cambridge', 'Montessori'],
        ),
        FilterSection(
          id: 'dil',
          title: 'Yabancı dil',
          subtitle: 'Dil programı filtresi',
          kind: FilterKind.checkbox,
          options: ['İngilizce ağırlıklı', 'Almanca', 'Fransızca'],
        ),
        FilterSection(
          id: 'sinif',
          title: 'Sınıf mevcudu',
          subtitle: 'Maksimum sınıf büyüklüğü',
          kind: FilterKind.pills,
          affectsResults: false,
          options: ['12 ve altı', '16 ve altı', '24 ve altı'],
        ),
        FilterSection(
          id: 'olanaklar',
          title: 'Olanaklar',
          subtitle: 'Kampüs ve program olanakları',
          kind: FilterKind.checkbox,
          options: [
            'Servis',
            'Yemekhane',
            'Yüzme havuzu',
            'Robotik lab',
            'Çift dilli müfredat',
          ],
        ),
      ]),
      SearchPageConfig(type: ProviderType.course, sections: [
        FilterSection(
          id: 'alan',
          title: 'Kurs alanı',
          subtitle: 'Kurs arama sayfasındaki alan filtresi',
          kind: FilterKind.checkbox,
          options: [
            'Kodlama & Robotik',
            'Yabancı Dil',
            'Matematik & Fen',
            'Müzik',
            'Resim & Sanat',
            'Spor',
          ],
        ),
        FilterSection(
          id: 'yas',
          title: 'Yaş grubu',
          subtitle: 'Hedef yaş aralıkları',
          kind: FilterKind.checkbox,
          options: ['4–6 yaş', '7–10 yaş', '11–14 yaş', '15+ / yetişkin'],
        ),
        FilterSection(
          id: 'sekil',
          title: 'Ders şekli',
          subtitle: 'Yüz yüze veya online',
          kind: FilterKind.radio,
          affectsResults: false,
          options: ['Yüz yüze', 'Online'],
        ),
        FilterSection(
          id: 'gun',
          title: 'Gün',
          subtitle: 'Ders günü seçenekleri',
          kind: FilterKind.pills,
          options: ['Hafta içi', 'Hafta sonu', 'Akşam'],
        ),
        FilterSection(
          id: 'grup',
          title: 'Grup büyüklüğü',
          subtitle: 'Ders grubu kişi sayısı',
          kind: FilterKind.pills,
          affectsResults: false,
          options: ['Birebir', '8 ve altı', '16 ve altı'],
        ),
      ]),
      SearchPageConfig(type: ProviderType.dershane, sections: [
        FilterSection(
          id: 'program',
          title: 'Hazırlık programı',
          subtitle: 'Dershane arama sayfasındaki program filtresi',
          kind: FilterKind.checkbox,
          options: ['LGS hazırlık', 'YKS (TYT–AYT)', 'Ara sınıf takviye', 'Etüt merkezi'],
        ),
        FilterSection(
          id: 'mesafe',
          title: 'Mesafe',
          subtitle: 'Konuma göre uzaklık (yakında konum verisiyle)',
          kind: FilterKind.radio,
          affectsResults: false,
          options: ['1 km içinde', '3 km içinde', '5 km içinde', 'İlçe geneli'],
        ),
        FilterSection(
          id: 'sinif',
          title: 'Sınıf mevcudu',
          subtitle: 'Maksimum sınıf büyüklüğü',
          kind: FilterKind.pills,
          affectsResults: false,
          options: ['12 ve altı', '16 ve altı', '20 ve altı'],
        ),
        FilterSection(
          id: 'olanaklar',
          title: 'Olanaklar',
          subtitle: 'Dershane olanakları',
          kind: FilterKind.checkbox,
          options: [
            'Haftalık deneme sınavı',
            'Birebir etüt',
            'Akşam soru çözümü',
            'Rehberlik & tercih desteği',
            'Kapalı devre veli takibi',
          ],
        ),
        FilterSection(
          id: 'gunler',
          title: 'Ders günleri',
          subtitle: 'Program günü seçenekleri',
          kind: FilterKind.pills,
          options: ['Hafta içi', 'Hafta sonu', 'Akşam'],
        ),
      ]),
      SearchPageConfig(type: ProviderType.privateTeacher, sections: [
        FilterSection(
          id: 'brans',
          title: 'Branş',
          subtitle: 'Öğretmen arama sayfasındaki branş filtresi',
          kind: FilterKind.checkbox,
          options: [
            'Matematik',
            'Fizik',
            'Kimya',
            'İngilizce',
            'Türkçe & Edebiyat',
            'Biyoloji',
          ],
        ),
        FilterSection(
          id: 'seviye',
          title: 'Seviye',
          subtitle: 'Öğrenci seviyesi',
          kind: FilterKind.checkbox,
          options: ['İlkokul (1–4)', 'Ortaokul (5–8)', 'Lise (9–12)', 'LGS / YKS hazırlık'],
        ),
        FilterSection(
          id: 'sekil',
          title: 'Ders şekli',
          subtitle: 'Ders verilebilen ortamlar',
          kind: FilterKind.radio,
          options: ['Evde ders', 'Online'],
        ),
        FilterSection(
          id: 'experience',
          title: 'Deneyim',
          subtitle: 'Minimum deneyim yılı',
          kind: FilterKind.pills,
          options: ['3+ yıl', '5+ yıl', '10+ yıl'],
        ),
        FilterSection(
          id: 'uygunluk',
          title: 'Uygunluk',
          subtitle: 'Ders verilebilen zamanlar',
          kind: FilterKind.pills,
          affectsResults: false,
          options: ['Hafta içi', 'Hafta sonu', 'Akşam'],
        ),
      ]),
    ];

final List<AppUser> seedUsers = [
  // Admin
  AppUser(id: 'u_admin', name: 'Site Yöneticisi', role: UserRole.admin),
  // Parents
  AppUser(id: 'u_veli', name: 'Ayşe Yılmaz', role: UserRole.parent, city: 'İstanbul'),
  AppUser(id: 'u_veli2', name: 'Fatma Öztürk', role: UserRole.parent, city: 'İzmir'),
  AppUser(id: 'u_veli3', name: 'Hasan Çelik', role: UserRole.parent, city: 'Bursa'),
  AppUser(id: 'u_veli4', name: 'Elif Aydın', role: UserRole.parent, city: 'Antalya'),
  AppUser(id: 'u_veli5', name: 'Murat Koç', role: UserRole.parent, city: 'Ankara'),
  // Students
  AppUser(id: 'u_ogrenci', name: 'Mert Kaya', role: UserRole.student, city: 'Ankara'),
  AppUser(id: 'u_ogrenci2', name: 'Zehra Polat', role: UserRole.student, city: 'İstanbul'),
  AppUser(id: 'u_ogrenci3', name: 'Ali Duman', role: UserRole.student, city: 'İzmir'),
  AppUser(id: 'u_ogrenci4', name: 'Ece Güneş', role: UserRole.student, city: 'Bursa'),
  AppUser(id: 'u_ogrenci5', name: 'Burak Yıldız', role: UserRole.student, city: 'Antalya'),
  // Teachers
  AppUser(
    id: 'u_ogretmen1',
    name: 'Zeynep Demir',
    role: UserRole.teacher,
    city: 'İstanbul',
    subject: 'Matematik',
    bio: '10 yıllık deneyimli matematik öğretmeni. LGS ve YKS hazırlık uzmanı.',
    seekingJob: true,
    experienceYears: 10,
    providerId: 'p_ogretmen1',
  ),
  AppUser(
    id: 'u_ogretmen2',
    name: 'Emre Şahin',
    role: UserRole.teacher,
    city: 'Ankara',
    subject: 'İngilizce',
    bio: 'Cambridge sertifikalı İngilizce öğretmeni. Konuşma odaklı dersler.',
    seekingJob: true,
    experienceYears: 6,
    providerId: 'p_ogretmen2',
  ),
  AppUser(
    id: 'u_ogretmen3',
    name: 'Selin Arslan',
    role: UserRole.teacher,
    city: 'İzmir',
    subject: 'Fizik',
    bio: 'ODTÜ mezunu fizik öğretmeni. Kavram temelli öğretim.',
    seekingJob: false,
    experienceYears: 4,
    providerId: 'p_ogretmen3',
  ),
  // Institutions
  AppUser(
    id: 'u_kurum1',
    name: 'Bilge Koleji',
    role: UserRole.institution,
    city: 'İstanbul',
    bio: 'Anaokulundan liseye tam donanımlı özel okul.',
    providerId: 'p_kurum1',
  ),
  AppUser(
    id: 'u_kurum2',
    name: 'Kavram Dershanesi',
    role: UserRole.institution,
    city: 'Ankara',
    bio: 'LGS ve YKS hazırlıkta 20 yıllık tecrübe.',
    providerId: 'p_kurum2',
  ),
  AppUser(
    id: 'u_kurum3',
    name: 'Lingua Dil Kursu',
    role: UserRole.institution,
    city: 'İzmir',
    bio: 'İngilizce, Almanca ve İspanyolca kursları.',
    providerId: 'p_kurum3',
  ),
  // Schools
  AppUser(
    id: 'u_okul2',
    name: 'Atlas Koleji',
    role: UserRole.institution,
    city: 'Ankara',
    bio: 'Fen ve teknoloji ağırlıklı özel okul.',
    providerId: 'p_okul2',
  ),
  AppUser(
    id: 'u_okul3',
    name: 'Deniz Koleji',
    role: UserRole.institution,
    city: 'İzmir',
    bio: 'Denize sıfır kampüste çift dilli eğitim.',
    providerId: 'p_okul3',
  ),
  AppUser(
    id: 'u_okul4',
    name: 'Yıldız Okulları',
    role: UserRole.institution,
    city: 'Bursa',
    bio: 'Anaokulundan liseye butik eğitim.',
    providerId: 'p_okul4',
  ),
  AppUser(
    id: 'u_okul5',
    name: 'Akdeniz Koleji',
    role: UserRole.institution,
    city: 'Antalya',
    bio: 'Uluslararası bakalorya programlı özel okul.',
    providerId: 'p_okul5',
  ),
  // Dershaneler
  AppUser(
    id: 'u_dershane2',
    name: 'Başarı Dershanesi',
    role: UserRole.institution,
    city: 'İstanbul',
    bio: 'LGS ve YKS odaklı, küçük sınıflar.',
    providerId: 'p_dershane2',
  ),
  AppUser(
    id: 'u_dershane3',
    name: 'Hedef Dershanesi',
    role: UserRole.institution,
    city: 'İzmir',
    bio: 'Deneme sınavı ve koçluk ağırlıklı hazırlık.',
    providerId: 'p_dershane3',
  ),
  AppUser(
    id: 'u_dershane4',
    name: 'Anadolu Dershanesi',
    role: UserRole.institution,
    city: 'Bursa',
    bio: '25 yıldır üniversite hazırlıkta uzman kadro.',
    providerId: 'p_dershane4',
  ),
  AppUser(
    id: 'u_dershane5',
    name: 'Doruk Dershanesi',
    role: UserRole.institution,
    city: 'Antalya',
    bio: 'Birebir etüt destekli LGS/YKS programları.',
    providerId: 'p_dershane5',
  ),
  // Pending registrations (admin approval queue)
  AppUser(
    id: 'u_bekleyen1',
    name: 'Formül YKS Dershanesi',
    role: UserRole.institution,
    city: 'Konya',
    bio: 'YKS hazırlıkta uzman kadro.',
    providerId: 'p_bekleyen1',
  ),
  AppUser(
    id: 'u_bekleyen2',
    name: 'Mert Yılmaz',
    role: UserRole.teacher,
    city: 'Bursa',
    subject: 'Fizik',
    bio: 'Fizik öğretmeni, 7 yıl deneyim.',
    experienceYears: 7,
    providerId: 'p_bekleyen2',
  ),
  // Courses
  AppUser(
    id: 'u_kurs2',
    name: 'Kodlama Atölyesi',
    role: UserRole.institution,
    city: 'İstanbul',
    bio: 'Çocuk ve gençler için kodlama ve robotik.',
    providerId: 'p_kurs2',
  ),
  AppUser(
    id: 'u_kurs3',
    name: 'Sanat Akademisi',
    role: UserRole.institution,
    city: 'Ankara',
    bio: 'Resim, seramik ve tasarım atölyeleri.',
    providerId: 'p_kurs3',
  ),
  AppUser(
    id: 'u_kurs4',
    name: 'Robotik Kulübü',
    role: UserRole.institution,
    city: 'Bursa',
    bio: 'STEM ve robotik yarışma takımları.',
    providerId: 'p_kurs4',
  ),
  AppUser(
    id: 'u_kurs5',
    name: 'Nota Müzik Kursu',
    role: UserRole.institution,
    city: 'Antalya',
    bio: 'Enstrüman ve şan eğitimi, sahne deneyimi.',
    providerId: 'p_kurs5',
  ),
]..asMap().forEach((i, u) {
    u.email = _emailFor(u);
    // Staggered demo registration dates for the admin user table.
    u.joinedAt = DateTime(2025, 11, 2).add(Duration(days: i * 9));
  });

/// Card badges per listing id, mirroring the design's variety.
const Map<String, String> _badges = {
  'p_kurum2': 'Öne çıkan',
  'p_ogretmen1': 'En çok tercih',
  'p_ogretmen2': 'Yeni',
  'p_okul2': 'Öne çıkan',
  'p_okul4': 'Yeni',
  'p_dershane2': 'En çok tercih',
  'p_dershane5': 'Yeni',
  'p_kurs2': 'Yeni',
  'p_kurs4': 'Öne çıkan',
};

final List<ProviderProfile> seedProviders = [
  ProviderProfile(
    id: 'p_kurum1',
    ownerUserId: 'u_kurum1',
    name: 'Bilge Koleji',
    type: ProviderType.privateSchool,
    city: 'İstanbul',
    description:
        'Anaokulundan liseye kadar tam donanımlı kampüs. Yüzme havuzu, laboratuvarlar, '
        'yabancı dil ağırlıklı müfredat ve rehberlik servisi.',
    monthlyPrice: 25000,
    photoUrls: [_pic(11), _pic(12), _pic(13), _pic(14), _pic(15)],
    videoUrl: 'https://example.com/video/bilge-koleji-tanitim.mp4',
    videoDuration: '1:20',
    address: 'Caferağa Mah. Eğitim Sk. No:12',
    features: [
      'Servis',
      'Yemekhane',
      'Yüzme Havuzu',
      'Yabancı Dil Ağırlıklı',
      'Rehberlik'
    ],
    highlight: '2026–27 kontenjanı: son 8 kişi',
    programs: const [
      ProgramItem(
          title: 'Anaokulu',
          price: '20.000 TL/ay',
          description: 'Oyun temelli çift dilli okul öncesi programı.'),
      ProgramItem(
          title: 'İlkokul (1–4)',
          price: '25.000 TL/ay',
          description: 'Çift dilli müfredat, 12 kişilik sınıflar.',
          note: 'Kardeş indirimi'),
      ProgramItem(
          title: 'Ortaokul (5–8)',
          price: '27.000 TL/ay',
          description: 'LGS hazırlık destekli akademik program.'),
      ProgramItem(
          title: 'Lise (9–12)',
          price: '29.000 TL/ay',
          description: 'YKS hazırlık, robotik ve proje laboratuvarları.',
          note: 'Erken kayıt indirimi'),
    ],
    reviews: [
      Review(
        id: 'r1',
        authorId: 'u_veli',
        authorName: 'Ayşe Yılmaz',
        stars: 5,
        comment: 'Öğretmen kadrosu çok ilgili, çocuğum severek gidiyor.',
        date: DateTime(2026, 5, 12),
      ),
      Review(
        id: 'r2',
        authorId: 'u_ogrenci',
        authorName: 'Mert Kaya',
        stars: 4,
        comment: 'Laboratuvarlar harika ama yemekler geliştirilebilir.',
        date: DateTime(2026, 6, 2),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_kurum2',
    ownerUserId: 'u_kurum2',
    name: 'Kavram Dershanesi',
    type: ProviderType.dershane,
    city: 'Ankara',
    description:
        'LGS ve YKS hazırlıkta 20 yıllık tecrübe. Haftalık deneme sınavları, '
        'birebir etüt ve koçluk sistemi.',
    monthlyPrice: 8000,
    photoUrls: [_pic(21), _pic(22), _pic(23), _pic(24)],
    videoUrl: 'https://example.com/video/zirve-tanitim.mp4',
    videoDuration: '0:48',
    address: 'Kızılay Mah. Ders Cd. No:34',
    trialLesson: true,
    features: ['Deneme Sınavı', 'Birebir Etüt', 'Koçluk', 'Online Takip'],
    highlight: 'Ücretsiz deneme dersi + seviye sınavı',
    programs: const [
      ProgramItem(
          title: 'LGS Hazırlık (8. sınıf)',
          price: '8.000 TL/ay',
          description:
              'Haftada 18 saat ders, haftalık deneme ve birebir soru çözümü.',
          note: 'Kontenjan: son 12 kişi'),
      ProgramItem(
          title: 'YKS Hazırlık (TYT–AYT)',
          price: '9.500 TL/ay',
          description:
              'Branş öğretmenleriyle tam program, rehberlik ve tercih desteği.',
          note: 'Kontenjan: son 6 kişi'),
      ProgramItem(
          title: 'Etüt Merkezi (5–12. sınıf)',
          price: '4.500 TL/ay',
          description:
              'Hafta içi her akşam ödev takibi, konu tekrarı ve soru çözümü.',
          note: 'Esnek gün seçimi'),
      ProgramItem(
          title: 'Birebir Etüt Paketi',
          price: '1.200 TL/saat',
          description:
              'Seçtiğiniz branşta birebir çalışma; 8 ve 16 saatlik paketler.',
          note: 'Pakette %10 indirim'),
    ],
    hours: const [
      OpeningHour('Hafta içi', '16:00 – 21:30'),
      OpeningHour('Cumartesi', '09:00 – 18:00'),
      OpeningHour('Pazar', 'Deneme sınavı'),
    ],
    reviews: [
      Review(
        id: 'r3',
        authorId: 'u_ogrenci',
        authorName: 'Mert Kaya',
        stars: 5,
        comment: 'Denemeler ve etütler sayesinde netlerim çok arttı.',
        date: DateTime(2026, 4, 20),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_kurum3',
    ownerUserId: 'u_kurum3',
    name: 'Lingua Dil Kursu',
    type: ProviderType.course,
    city: 'İzmir',
    description:
        'İngilizce, Almanca ve İspanyolca kursları. Küçük gruplar, yabancı eğitmenler '
        've konuşma kulübü.',
    monthlyPrice: 4500,
    photoUrls: [_pic(31), _pic(32)],
    address: 'Alsancak Mah. Kıbrıs Şehitleri Cd. No:21',
    features: ['Yabancı Eğitmen', 'Küçük Grup', 'Konuşma Kulübü', 'Sertifika'],
    reviews: [
      Review(
        id: 'r4',
        authorId: 'u_veli',
        authorName: 'Ayşe Yılmaz',
        stars: 4,
        comment: 'Konuşma kulübü çok faydalı.',
        date: DateTime(2026, 3, 15),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_ogretmen1',
    ownerUserId: 'u_ogretmen1',
    name: 'Zeynep Demir — Matematik',
    type: ProviderType.privateTeacher,
    city: 'İstanbul',
    description:
        '10 yıllık deneyimli matematik öğretmeni. LGS ve YKS hazırlık uzmanı. '
        'Birebir veya 2 kişilik grup dersleri, online seçeneği mevcut.',
    monthlyPrice: 6000,
    lessonPrice: 1500,
    trialLesson: true,
    photoUrls: [_pic(41)],
    videoUrl: 'https://example.com/video/zeynep-tanitim.mp4',
    videoDuration: '0:35',
    features: ['Birebir Ders', 'Online Ders', 'LGS', 'YKS', 'Seviye Tespiti'],
    highlight: 'İlk ders %50 indirimli · seviye tespiti dahil',
    credentials: const [
      CredentialItem('Boğaziçi Matematik Bölümü — Lisans', '2014'),
      CredentialItem('Pedagojik formasyon sertifikası', '2015'),
      CredentialItem('MEB özel öğretim kurumu çalışma belgesi', '2016'),
      CredentialItem('Üstün zekâlılar eğitimi sertifika programı', '2022'),
    ],
    programs: const [
      ProgramItem(
          title: 'Tek ders',
          price: '1.500 TL',
          description: '60 dk birebir ders, ders sonu veli notu.'),
      ProgramItem(
          title: '8 ders paketi',
          price: '11.000 TL',
          description:
              'Ders başı 1.375 TL. Haftalık plan ve deneme analizi dahil.',
          note: 'En çok tercih edilen'),
      ProgramItem(
          title: '16 ders paketi',
          price: '20.000 TL',
          description: 'Ders başı 1.250 TL. Aylık veli görüşmesi dahil.'),
    ],
    hours: const [
      OpeningHour('Hafta içi', '16:00 – 21:00'),
      OpeningHour('Cumartesi', '10:00 – 18:00'),
      OpeningHour('Pazar', 'Dolu'),
      OpeningHour('Online', 'Esnek saat'),
    ],
    lessonModes: const [
      OpeningHour('Öğrencinin evinde', '✓ Kadıköy çevresi'),
      OpeningHour('Online (canlı)', '✓ Tüm Türkiye'),
      OpeningHour('Grup dersi (2–3 kişi)', '✓ Talebe göre'),
    ],
    reviews: [
      Review(
        id: 'r5',
        authorId: 'u_ogrenci',
        authorName: 'Mert Kaya',
        stars: 5,
        comment: 'Anlatımı çok net, sorularıma sabırla cevap veriyor.',
        date: DateTime(2026, 6, 10),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_ogretmen2',
    ownerUserId: 'u_ogretmen2',
    name: 'Emre Şahin — İngilizce',
    type: ProviderType.privateTeacher,
    city: 'Ankara',
    description:
        'Cambridge sertifikalı İngilizce öğretmeni. Konuşma odaklı, oyunlaştırılmış dersler. '
        'Çocuk ve yetişkin grupları.',
    monthlyPrice: 5000,
    lessonPrice: 1200,
    photoUrls: [_pic(51)],
    features: ['Konuşma Odaklı', 'Online Ders', 'Sertifikalı'],
    reviews: [],
  ),
  // ---- Schools ----
  ProviderProfile(
    id: 'p_okul2',
    ownerUserId: 'u_okul2',
    name: 'Atlas Koleji',
    type: ProviderType.privateSchool,
    city: 'Ankara',
    description:
        'Fen ve teknoloji ağırlıklı müfredat, robotik laboratuvarları ve '
        'TÜBİTAK proje koçluğu. 16 kişilik sınıflar.',
    monthlyPrice: 22000,
    photoUrls: [_pic(71), _pic(72), _pic(73)],
    address: 'Çankaya Mah. Bilim Sk. No:5',
    features: ['Servis', 'Yemekhane', 'Robotik Lab', 'Proje Koçluğu'],
    highlight: 'Burs sınavı: 15 Ağustos',
    reviews: [
      Review(
        id: 'r7',
        authorId: 'u_veli5',
        authorName: 'Murat Koç',
        stars: 5,
        comment: 'Fen laboratuvarları ve öğretmen kadrosu çok güçlü.',
        date: DateTime(2026, 5, 3),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_okul3',
    ownerUserId: 'u_okul3',
    name: 'Deniz Koleji',
    type: ProviderType.privateSchool,
    city: 'İzmir',
    description:
        'Denize sıfır kampüste çift dilli eğitim. Yelken, yüzme ve su sporları '
        'kulüpleri; Cambridge sınav merkezi.',
    monthlyPrice: 24000,
    photoUrls: [_pic(74), _pic(75)],
    features: ['Çift Dilli', 'Yüzme', 'Yelken', 'Cambridge Merkezi'],
    reviews: [
      Review(
        id: 'r8',
        authorId: 'u_veli2',
        authorName: 'Fatma Öztürk',
        stars: 4,
        comment: 'Kampüs harika, İngilizce eğitimi çok iyi.',
        date: DateTime(2026, 4, 18),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_okul4',
    ownerUserId: 'u_okul4',
    name: 'Yıldız Okulları',
    type: ProviderType.privateSchool,
    city: 'Bursa',
    description:
        'Anaokulundan liseye butik eğitim; sınıf başına en fazla 14 öğrenci, '
        'her öğrenciye bireysel gelişim planı.',
    monthlyPrice: 18000,
    photoUrls: [_pic(76), _pic(77)],
    features: ['Butik Sınıf', 'Bireysel Plan', 'Servis', 'Rehberlik'],
    reviews: [
      Review(
        id: 'r9',
        authorId: 'u_veli3',
        authorName: 'Hasan Çelik',
        stars: 5,
        comment: 'Küçük sınıflar sayesinde oğlumla birebir ilgileniyorlar.',
        date: DateTime(2026, 6, 21),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_okul5',
    ownerUserId: 'u_okul5',
    name: 'Akdeniz Koleji',
    type: ProviderType.privateSchool,
    city: 'Antalya',
    description:
        'Uluslararası bakalorya (IB) programı, yabancı öğretmen kadrosu ve '
        'yurt dışı üniversite danışmanlığı.',
    monthlyPrice: 28000,
    photoUrls: [_pic(78), _pic(79)],
    features: ['IB Programı', 'Yabancı Öğretmen', 'Yurt Dışı Danışmanlık'],
    reviews: [
      Review(
        id: 'r10',
        authorId: 'u_veli4',
        authorName: 'Elif Aydın',
        stars: 4,
        comment: 'IB programı için Antalya’daki en iyi seçenek.',
        date: DateTime(2026, 3, 30),
      ),
    ],
  ),
  // ---- Dershaneler ----
  ProviderProfile(
    id: 'p_dershane2',
    ownerUserId: 'u_dershane2',
    name: 'Başarı Dershanesi',
    type: ProviderType.dershane,
    city: 'İstanbul',
    description:
        'LGS ve YKS odaklı, 12 kişilik sınıflar. Haftalık birebir etüt ve '
        'veli bilgilendirme sistemi.',
    monthlyPrice: 9000,
    photoUrls: [_pic(81), _pic(82)],
    address: 'Merkez Mah. Başarı Sk. No:8',
    trialLesson: true,
    features: ['Küçük Sınıf', 'Birebir Etüt', 'Veli Takip', 'Deneme Sınavı'],
    highlight: 'Erken kayıtta %15 indirim',
    reviews: [
      Review(
        id: 'r11',
        authorId: 'u_ogrenci2',
        authorName: 'Zehra Polat',
        stars: 5,
        comment: 'Etüt sistemi sayesinde matematik netlerim ikiye katlandı.',
        date: DateTime(2026, 5, 25),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_dershane3',
    ownerUserId: 'u_dershane3',
    name: 'Hedef Dershanesi',
    type: ProviderType.dershane,
    city: 'İzmir',
    description:
        'Deneme sınavı ve koçluk ağırlıklı YKS hazırlık. Her öğrenciye haftalık '
        'birebir koçluk görüşmesi.',
    monthlyPrice: 7500,
    photoUrls: [_pic(83), _pic(84)],
    trialLesson: true,
    features: ['Koçluk', 'Deneme Sınavı', 'Online Takip'],
    reviews: [
      Review(
        id: 'r12',
        authorId: 'u_ogrenci3',
        authorName: 'Ali Duman',
        stars: 4,
        comment: 'Koçluk görüşmeleri motivasyonumu yüksek tutuyor.',
        date: DateTime(2026, 4, 9),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_dershane4',
    ownerUserId: 'u_dershane4',
    name: 'Anadolu Dershanesi',
    type: ProviderType.dershane,
    city: 'Bursa',
    description:
        '25 yıldır üniversite hazırlıkta uzman kadro. TYT-AYT tam program ve '
        'hafta sonu yoğunlaştırılmış kamplar.',
    monthlyPrice: 6500,
    photoUrls: [_pic(85)],
    features: ['Tecrübeli Kadro', 'Hafta Sonu Kampı', 'Rehberlik'],
    reviews: [
      Review(
        id: 'r13',
        authorId: 'u_ogrenci4',
        authorName: 'Ece Güneş',
        stars: 4,
        comment: 'Hafta sonu kampları sınav öncesi çok işe yaradı.',
        date: DateTime(2026, 6, 5),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_dershane5',
    ownerUserId: 'u_dershane5',
    name: 'Doruk Dershanesi',
    type: ProviderType.dershane,
    city: 'Antalya',
    description:
        'Birebir etüt destekli LGS/YKS programları. Akıllı tahta, soru bankası '
        'uygulaması ve 7/24 soru çözüm hattı.',
    monthlyPrice: 7000,
    photoUrls: [_pic(86)],
    features: ['Birebir Etüt', 'Soru Çözüm Hattı', 'Mobil Uygulama'],
    reviews: [
      Review(
        id: 'r17',
        authorId: 'u_veli3',
        authorName: 'Anonim veli',
        stars: 1,
        comment: 'Kayıt parasını iade etmiyorlar, kimse muhatap olmuyor!!! '
            'Kesinlikle uzak durun.',
        date: DateTime(2026, 7, 14),
        status: ReviewStatus.reported,
      ),
    ],
  ),
  // ---- Courses ----
  ProviderProfile(
    id: 'p_kurs2',
    ownerUserId: 'u_kurs2',
    name: 'Kodlama Atölyesi',
    type: ProviderType.course,
    city: 'İstanbul',
    description:
        '7-17 yaş için kodlama ve robotik. Scratch, Python ve Arduino '
        'müfredatı; yıl sonu proje sergisi.',
    monthlyPrice: 3500,
    photoUrls: [_pic(91), _pic(92)],
    trialLesson: true,
    features: ['Scratch', 'Python', 'Arduino', 'Proje Sergisi'],
    highlight: 'İlk hafta ücretsiz deneme',
    reviews: [
      Review(
        id: 'r14',
        authorId: 'u_veli5',
        authorName: 'Murat Koç',
        stars: 5,
        comment: 'Oğlum kendi oyununu yaptı, kursu iple çekiyor.',
        date: DateTime(2026, 5, 14),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_kurs3',
    ownerUserId: 'u_kurs3',
    name: 'Sanat Akademisi',
    type: ProviderType.course,
    city: 'Ankara',
    description:
        'Resim, seramik ve tasarım atölyeleri. Güzel sanatlar liselerine ve '
        'fakültelerine hazırlık programları.',
    monthlyPrice: 3000,
    photoUrls: [_pic(93)],
    features: ['Resim', 'Seramik', 'GSL Hazırlık', 'Portfolyo'],
    reviews: [
      Review(
        id: 'r15',
        authorId: 'u_ogrenci5',
        authorName: 'Burak Yıldız',
        stars: 5,
        comment: 'Portfolyo hazırlığında çok destek oldular.',
        date: DateTime(2026, 2, 27),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_kurs4',
    ownerUserId: 'u_kurs4',
    name: 'Robotik Kulübü',
    type: ProviderType.course,
    city: 'Bursa',
    description:
        'STEM ve robotik yarışma takımları. FIRST LEGO League ve TEKNOFEST '
        'hazırlık grupları.',
    monthlyPrice: 4000,
    photoUrls: [_pic(94)],
    features: ['LEGO League', 'TEKNOFEST', 'Takım Çalışması'],
    reviews: [
      Review(
        id: 'r16',
        authorId: 'u_ogrenci4',
        authorName: 'Ece Güneş',
        stars: 4,
        comment: 'Takımımızla TEKNOFEST finaline kaldık!',
        date: DateTime(2026, 6, 30),
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_kurs5',
    ownerUserId: 'u_kurs5',
    name: 'Nota Müzik Kursu',
    type: ProviderType.course,
    city: 'Antalya',
    description:
        'Piyano, gitar, keman ve şan eğitimi. Yıl sonu konserleri ve sahne '
        'deneyimi; konservatuvar hazırlık.',
    monthlyPrice: 2800,
    photoUrls: [_pic(95)],
    features: ['Piyano', 'Gitar', 'Şan', 'Konservatuvar Hazırlık'],
    reviews: [
      Review(
        id: 'r18',
        authorId: 'u_ogrenci5',
        authorName: 'Burak Yıldız',
        stars: 5,
        comment: 'Gitar hocam harika, iletişim bilgilerimi profilimden '
            'paylaşıyorum: 05xx xxx xx xx.',
        date: DateTime(2026, 7, 15),
        status: ReviewStatus.pending,
      ),
    ],
  ),
  ProviderProfile(
    id: 'p_ogretmen3',
    ownerUserId: 'u_ogretmen3',
    name: 'Selin Arslan — Fizik',
    type: ProviderType.privateTeacher,
    city: 'İzmir',
    description: 'ODTÜ mezunu fizik öğretmeni. Kavram temelli öğretim, bol deney ve simülasyon.',
    monthlyPrice: 4000,
    lessonPrice: 1000,
    trialLesson: true,
    photoUrls: [_pic(61)],
    features: ['Birebir Ders', 'AYT Fizik', 'Deneyle Öğrenme'],
    reviews: [
      Review(
        id: 'r6',
        authorId: 'u_veli',
        authorName: 'Ayşe Yılmaz',
        stars: 4,
        comment: 'Kızımın fizik korkusunu yendi.',
        date: DateTime(2026, 2, 8),
      ),
    ],
  ),
  ..._pendingProviders,
]..asMap().forEach((i, p) {
    final badge = _badges[p.id];
    if (badge != null) p.badge = badge;
    p.district = _districts[p.id] ?? '';
    // Staggered publish dates for the "Yeni eklenen" sort.
    p.createdAt = DateTime(2026, 2, 1).add(Duration(days: i * 7));
  });

/// Listings waiting for admin approval — hidden from public search.
final List<ProviderProfile> _pendingProviders = [
  ProviderProfile(
    id: 'p_bekleyen1',
    ownerUserId: 'u_bekleyen1',
    name: 'Formül YKS Dershanesi',
    type: ProviderType.dershane,
    city: 'Konya',
    description: 'YKS (TYT–AYT) hazırlıkta uzman kadro, haftalık deneme sınavı.',
    monthlyPrice: 5500,
    photoUrls: [_pic(96)],
    features: ['Deneme Sınavı', 'Rehberlik'],
  )..status = ListingStatus.pending,
  ProviderProfile(
    id: 'p_bekleyen2',
    ownerUserId: 'u_bekleyen2',
    name: 'Mert Yılmaz — Fizik',
    type: ProviderType.privateTeacher,
    city: 'Bursa',
    description: '7 yıl deneyimli fizik öğretmeni; AYT fizik ve okula destek.',
    monthlyPrice: 4500,
    lessonPrice: 1100,
    photoUrls: [_pic(97)],
    features: ['Birebir Ders', 'AYT Fizik'],
  )..status = ListingStatus.pending,
];

/// District per listing id — pickers and filters read from data/iller.dart.
const Map<String, String> _districts = {
  'p_kurum1': 'Kadıköy',
  'p_kurum2': 'Çankaya',
  'p_kurum3': 'Konak',
  'p_ogretmen1': 'Kadıköy',
  'p_ogretmen2': 'Yenimahalle',
  'p_ogretmen3': 'Bornova',
  'p_okul2': 'Çankaya',
  'p_okul3': 'Karşıyaka',
  'p_okul4': 'Nilüfer',
  'p_okul5': 'Muratpaşa',
  'p_dershane2': 'Üsküdar',
  'p_dershane3': 'Bornova',
  'p_dershane4': 'Osmangazi',
  'p_dershane5': 'Kepez',
  'p_kurs2': 'Beşiktaş',
  'p_kurs3': 'Keçiören',
  'p_kurs4': 'Yıldırım',
  'p_kurs5': 'Konyaaltı',
  'p_bekleyen1': 'Selçuklu',
  'p_bekleyen2': 'Nilüfer',
};

/// Student lesson requests (closed network: teachers only).
/// Fresh copies per call so AppState instances stay independent.
List<StudentListing> buildStudentListings() => [
      StudentListing(
        id: 'sl1',
        ownerUserId: 'u_veli',
        title: 'LGS matematik için haftada 2 gün özel ders',
        subject: 'Matematik',
        level: '8. sınıf (LGS)',
        city: 'İstanbul',
        district: 'Kadıköy',
        budget: 1200,
        schedule: 'Hafta içi akşam',
        mode: 'Evde ders',
        description:
            'Oğlum 8. sınıfa geçti, matematik netleri 10 civarında. LGS\'ye '
            'kadar düzenli çalışacak sabırlı bir öğretmen arıyoruz.',
        createdAt: DateTime(2026, 7, 14),
        startNow: true,
      ),
      StudentListing(
        id: 'sl2',
        ownerUserId: 'u_ogrenci2',
        title: 'AYT fizik takviyesi (online olabilir)',
        subject: 'Fizik',
        level: '12. sınıf (YKS)',
        city: 'İstanbul',
        district: 'Üsküdar',
        budget: 900,
        schedule: 'Hafta sonu',
        mode: 'Online',
        description:
            'TYT fiziğim iyi ama AYT problemlerinde zorlanıyorum. Konu '
            'anlatımından çok soru çözümü odaklı ders istiyorum.',
        createdAt: DateTime(2026, 7, 12),
      ),
      StudentListing(
        id: 'sl3',
        ownerUserId: 'u_veli2',
        title: 'İlkokul 3. sınıf okuma-yazma desteği',
        subject: 'Türkçe',
        level: '3. sınıf',
        city: 'İzmir',
        district: 'Karşıyaka',
        budget: 600,
        schedule: 'Hafta içi gündüz',
        mode: 'Evde ders',
        description:
            'Kızımın okuma hızı sınıf ortalamasının altında; oyunla öğreten, '
            'sınıf öğretmenliği mezunu biri olursa çok seviniriz.',
        createdAt: DateTime(2026, 7, 10),
      ),
      StudentListing(
        id: 'sl4',
        ownerUserId: 'u_ogrenci5',
        title: 'Konservatuvar hazırlık — şan dersi',
        subject: 'Müzik',
        level: 'Lise (11. sınıf)',
        city: 'Antalya',
        district: 'Muratpaşa',
        budget: 800,
        schedule: 'Hafta sonu',
        mode: 'Fark etmez',
        description:
            'Konservatuvar şan bölümüne hazırlanıyorum; repertuvar ve '
            'diyafram tekniği çalıştıracak hoca arıyorum.',
        createdAt: DateTime(2026, 7, 8),
      ),
      StudentListing(
        id: 'sl5',
        ownerUserId: 'u_veli5',
        title: 'İngilizce konuşma pratiği (7. sınıf)',
        subject: 'İngilizce',
        level: '7. sınıf',
        city: 'Ankara',
        district: 'Çankaya',
        budget: 700,
        schedule: 'Hafta içi akşam',
        mode: 'Online',
        description:
            'Gramer bilgisi iyi ama konuşmaya çekiniyor. Oyunlaştırılmış, '
            'konuşma ağırlıklı online ders arıyoruz.',
        createdAt: DateTime(2026, 7, 16),
        startNow: true,
      ),
    ];

List<ListingBid> buildSeedBids() => [
      ListingBid(
        id: 'b1',
        teacherUserId: 'u_ogretmen1',
        listingId: 'sl1',
        price: 1400,
        message: 'Merhaba, Kadıköy çevresinde evde ders veriyorum. İlk ders '
            'seviye tespiti olarak ücretsiz.',
        createdAt: DateTime(2026, 7, 15, 10, 30),
      ),
      ListingBid(
        id: 'b2',
        teacherUserId: 'u_ogretmen3',
        listingId: 'sl2',
        price: 900,
        message: 'AYT fizik için soru çözüm kampı formatında online '
            'çalışabiliriz; deneme analizleri dahil.',
        createdAt: DateTime(2026, 7, 13, 18, 45),
      ),
    ];

/// Packages shown on Ücretlendirme; the admin "Paketler" section edits
/// these same objects (price input, sales toggle) so both stay in sync.
List<PricingPlan> buildPricingPlans() => [
      PricingPlan(
        id: 'plan_baslangic',
        audience: PlanAudience.institution,
        name: 'Başlangıç',
        desc: 'Platformu denemek için',
        cta: 'Ücretsiz başla',
        price: 0,
        period: '',
        features: [
          '1 aktif ilan',
          '5 fotoğraf',
          'Teklif alma & mesajlaşma',
          'Doğrulama rozeti başvurusu',
          'Temel görüntülenme sayacı',
        ],
        subscribers: 132,
      ),
      PricingPlan(
        id: 'plan_premium',
        audience: PlanAudience.institution,
        name: 'Premium',
        desc: 'Büyüyen kurumlar için',
        cta: 'Premium\'a geç',
        price: 1490,
        period: '/ay',
        popular: true,
        features: [
          '3 aktif ilan + tanıtım videosu',
          'Sınırsız fotoğraf',
          'Ayda 2 hafta arama sonucunda öne çıkarma',
          'Detaylı istatistik panosu (görüntülenme, teklif, dönüşüm)',
          '5 aktif iş ilanı (kapalı ağ)',
          'Öncelikli destek',
        ],
        subscribers: 48,
      ),
      PricingPlan(
        id: 'plan_kurumsal',
        audience: PlanAudience.institution,
        name: 'Kurumsal',
        desc: 'Çok şubeli kurumlar için',
        cta: 'Bize ulaşın',
        price: 3990,
        period: '/ay',
        features: [
          'Sınırsız ilan & şube yönetimi',
          'Sınırsız iş ilanı',
          'Sponsorlu video kotası (ayda 2 hafta)',
          'Şube bazlı istatistik & rapor dışa aktarma',
          'Özel hesap yöneticisi',
        ],
        subscribers: 9,
      ),
      PricingPlan(
        id: 'plan_ogretmen_free',
        audience: PlanAudience.teacher,
        name: 'Ücretsiz',
        desc: 'Her öğretmen için',
        cta: 'Profil oluştur',
        price: 0,
        period: '',
        features: [
          'Doğrulanmış profil + tanışma videosu',
          'Ayda 5 öğrenci ilanına teklif',
          'Mesajlaşma & takvim',
          'Komisyonsuz ders ücreti',
        ],
        subscribers: 310,
      ),
      PricingPlan(
        id: 'plan_ogretmen_pro',
        audience: PlanAudience.teacher,
        name: 'Pro',
        desc: 'Aktif ders verenler için',
        cta: 'Pro\'ya geç',
        price: 190,
        period: '/ay',
        popular: true,
        features: [
          'Sınırsız teklif hakkı',
          'Aramada öne çıkan profil rozeti',
          'Profil istatistikleri (görüntülenme, dönüşüm)',
          'İş ilanlarına öncelikli başvuru',
        ],
        subscribers: 86,
      ),
      PricingPlan(
        id: 'plan_ogretmen_yillik',
        audience: PlanAudience.teacher,
        name: 'Pro Yıllık',
        desc: '2 ay hediye',
        cta: 'Yıllık başla',
        price: 1900,
        period: '/yıl',
        features: [
          'Tüm Pro özellikleri',
          '12 ay fiyat sabitleme',
          'Yıllık gelir raporu (vergi beyanı için)',
        ],
        subscribers: 41,
      ),
      PricingPlan(
        id: 'addon_video',
        audience: PlanAudience.addon,
        name: 'Sponsorlu kısa video',
        desc: 'Tanıtım videonuz ana sayfadaki kısa video akışında '
            '\'Sponsorlu\' rozetiyle döner; hedef il seçilebilir.',
        price: 490,
        period: '/hafta',
        subscribers: 12,
      ),
      PricingPlan(
        id: 'addon_one_cikarma',
        audience: PlanAudience.addon,
        name: 'Öne çıkarma',
        desc: 'İlanınız kendi kategorisindeki arama sonuçlarının en üstünde '
            '\'Öne çıkan\' şeridiyle gösterilir.',
        price: 290,
        period: '/hafta',
        subscribers: 23,
      ),
      PricingPlan(
        id: 'addon_is_ilani',
        audience: PlanAudience.addon,
        name: 'İş ilanı paketi',
        desc: 'Başlangıç paketindeki kurumlar için tekil iş ilanı yayını — '
            'yalnızca öğretmenlere görünür, 30 gün.',
        price: 190,
        period: '/ilan',
        subscribers: 17,
      ),
    ];

/// Slider bounds per search page (README: okul ₺2.000–15.000/500,
/// kurs ₺500–6.000/250, dershane ₺1.000–8.000/250, öğretmen ve öğrenci
/// bütçesi ₺200–1.500/50). Admin "ücret aralığı" groups edit these.
Map<String, PriceRangeConfig> buildPriceRanges() => {
      'privateSchool': PriceRangeConfig(min: 2000, max: 15000, step: 500),
      'course': PriceRangeConfig(min: 500, max: 6000, step: 250),
      'dershane': PriceRangeConfig(min: 1000, max: 8000, step: 250),
      'privateTeacher': PriceRangeConfig(min: 200, max: 1500, step: 50),
      'studentBudget': PriceRangeConfig(min: 200, max: 1500, step: 50),
    };

final List<Conversation> seedConversations = [
  Conversation(
    id: 'c1',
    userAId: 'u_veli',
    userBId: 'u_ogretmen1',
    messages: [
      ChatMessage(
        id: 'm1',
        senderId: 'u_veli',
        text: 'Merhaba, oğlum için LGS matematik dersi arıyorum. Uygun musunuz?',
        sentAt: DateTime(2026, 7, 10, 14, 30),
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'u_ogretmen1',
        text: 'Merhaba! Evet, hafta içi akşamları uygunum. Detayları konuşabiliriz.',
        sentAt: DateTime(2026, 7, 10, 15, 5),
      ),
    ],
  ),
];

final List<Offer> seedOffers = [
  Offer(
    id: 'o1',
    requesterId: 'u_veli',
    providerId: 'p_ogretmen1',
    note: 'Haftada 2 gün LGS matematik dersi için aylık fiyat teklifi rica ederim.',
    createdAt: DateTime(2026, 7, 11, 9, 0),
    quotedPrice: 5500,
    status: OfferStatus.quoted,
  ),
];

final List<JobPosting> seedJobs = [
  JobPosting(
    id: 'j1',
    institutionUserId: 'u_kurum1',
    institutionName: 'Bilge Koleji',
    title: 'Matematik Öğretmeni',
    subject: 'Matematik',
    city: 'İstanbul',
    salaryText: '45.000 - 60.000 TL',
    description: 'Lise kademesi için tam zamanlı matematik öğretmeni arıyoruz. '
        'En az 3 yıl deneyim beklenmektedir.',
    createdAt: DateTime(2026, 7, 1),
    benefits: ['Yemek', 'Servis', 'SGK + özel sağlık'],
  ),
  JobPosting(
    id: 'j2',
    institutionUserId: 'u_kurum3',
    institutionName: 'Lingua Dil Kursu',
    title: 'İngilizce Eğitmeni (Yarı Zamanlı)',
    subject: 'İngilizce',
    city: 'İzmir',
    salaryText: 'Ders başı 800 TL',
    description: 'Hafta sonu yetişkin grupları için konuşma odaklı İngilizce eğitmeni.',
    createdAt: DateTime(2026, 7, 8),
    benefits: ['Esnek çalışma saatleri', 'Ders başı prim'],
  ),
];

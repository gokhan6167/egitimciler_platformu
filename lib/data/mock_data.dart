/// Seed data for the MVP. Will be replaced by a real backend later.
library;

import '../models/models.dart';

String _pic(int seed) => 'https://picsum.photos/seed/edu$seed/640/360';

/// Fresh copies each call so AppState instances don't share mutable state.
/// Sections mirror the type-specific "Arama - *" Claude Design files;
/// admins can add/remove sections and options at runtime.
List<SearchPageConfig> buildSearchConfigs() => [
      SearchPageConfig(type: ProviderType.privateSchool, sections: [
        FilterSection(
          id: 'kademe',
          title: 'Kademe',
          kind: FilterKind.checkbox,
          options: ['Anaokulu', 'İlkokul', 'Ortaokul', 'Lise'],
        ),
        FilterSection(
          id: 'olanaklar',
          title: 'Olanaklar',
          kind: FilterKind.checkbox,
          options: [
            'Servis',
            'Yemek',
            'Yüzme Havuzu',
            'Robotik Lab',
            'Çift Dilli',
            'Rehberlik',
          ],
        ),
      ]),
      SearchPageConfig(type: ProviderType.course, sections: [
        FilterSection(
          id: 'alan',
          title: 'Kurs alanı',
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
          kind: FilterKind.checkbox,
          options: ['4–6 yaş', '7–10 yaş', '11–14 yaş', '15+ / yetişkin'],
        ),
        FilterSection(
          id: 'gun',
          title: 'Gün',
          kind: FilterKind.pills,
          options: ['Hafta içi', 'Hafta sonu', 'Akşam'],
        ),
      ]),
      SearchPageConfig(type: ProviderType.dershane, sections: [
        FilterSection(
          id: 'program',
          title: 'Hazırlık programı',
          kind: FilterKind.checkbox,
          options: ['LGS hazırlık', 'YKS (TYT–AYT)', 'Ara sınıf takviye', 'Etüt merkezi'],
        ),
        FilterSection(
          id: 'olanaklar',
          title: 'Olanaklar',
          kind: FilterKind.checkbox,
          options: [
            'Deneme Sınavı',
            'Birebir Etüt',
            'Koçluk',
            'Rehberlik',
            'Veli Takip',
          ],
        ),
      ]),
      SearchPageConfig(type: ProviderType.privateTeacher, sections: [
        FilterSection(
          id: 'brans',
          title: 'Branş',
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
          kind: FilterKind.checkbox,
          options: ['İlkokul (1–4)', 'Ortaokul (5–8)', 'Lise (9–12)', 'LGS / YKS hazırlık'],
        ),
        FilterSection(
          id: 'sekil',
          title: 'Ders şekli',
          kind: FilterKind.radio,
          options: ['Evde ders', 'Online'],
        ),
        FilterSection(
          id: 'experience',
          title: 'Deneyim',
          kind: FilterKind.pills,
          options: ['3+ yıl', '5+ yıl', '10+ yıl'],
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
    name: 'Zirve Dershanesi',
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
];

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
    features: ['Servis', 'Yemek', 'Yüzme Havuzu', 'Yabancı Dil Ağırlıklı', 'Rehberlik'],
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
    name: 'Zirve Dershanesi',
    type: ProviderType.dershane,
    city: 'Ankara',
    description:
        'LGS ve YKS hazırlıkta 20 yıllık tecrübe. Haftalık deneme sınavları, '
        'birebir etüt ve koçluk sistemi.',
    monthlyPrice: 8000,
    photoUrls: [_pic(21), _pic(22), _pic(23), _pic(24)],
    videoUrl: 'https://example.com/video/zirve-tanitim.mp4',
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
    photoUrls: [_pic(41)],
    videoUrl: 'https://example.com/video/zeynep-tanitim.mp4',
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
    features: ['Servis', 'Yemek', 'Robotik Lab', 'Proje Koçluğu'],
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
];

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
    photoUrls: [_pic(97)],
    features: ['Birebir Ders', 'AYT Fizik'],
  )..status = ListingStatus.pending,
];

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
  ),
];

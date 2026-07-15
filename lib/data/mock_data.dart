/// Seed data for the MVP. Will be replaced by a real backend later.
library;

import '../models/models.dart';

String _pic(int seed) => 'https://picsum.photos/seed/edu$seed/640/360';

final List<AppUser> seedUsers = [
  // Seekers
  AppUser(id: 'u_veli', name: 'Ayşe Yılmaz', role: UserRole.parent, city: 'İstanbul'),
  AppUser(id: 'u_ogrenci', name: 'Mert Kaya', role: UserRole.student, city: 'Ankara'),
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

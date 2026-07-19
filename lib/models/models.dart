/// Core data models for the educators platform.
/// Pure Dart — no Flutter imports, so they can move to a backend later.
library;

enum UserRole { parent, student, teacher, institution, admin }

extension UserRoleX on UserRole {
  String get labelTr => switch (this) {
        UserRole.parent => 'Veli',
        UserRole.student => 'Öğrenci',
        UserRole.teacher => 'Özel Öğretmen',
        UserRole.institution => 'Kurum',
        UserRole.admin => 'Yönetici',
      };

  bool get isSeeker => this == UserRole.parent || this == UserRole.student;
  bool get isEducator => this == UserRole.teacher || this == UserRole.institution;
}

enum ProviderType { privateSchool, course, dershane, privateTeacher }

/// Moderation state of a listing. Only published listings are searchable.
enum ListingStatus { pending, published, suspended, rejected }

extension ListingStatusX on ListingStatus {
  String get labelTr => switch (this) {
        ListingStatus.pending => 'Bekliyor',
        ListingStatus.published => 'Yayında',
        ListingStatus.suspended => 'Askıda',
        ListingStatus.rejected => 'Reddedildi',
      };
}

/// Moderation state of a review. Only published ones count toward ratings.
enum ReviewStatus { pending, published, reported, removed }

extension ReviewStatusX on ReviewStatus {
  String get labelTr => switch (this) {
        ReviewStatus.pending => 'Bekliyor',
        ReviewStatus.published => 'Yayında',
        ReviewStatus.reported => 'Bildirildi',
        ReviewStatus.removed => 'Kaldırıldı',
      };
}

/// How a configurable filter section renders and behaves.
/// checkbox → multi select, radio → single select, pills → multi-select pills.
enum FilterKind { checkbox, radio, pills }

extension FilterKindX on FilterKind {
  String get labelTr => switch (this) {
        FilterKind.checkbox => 'Çoklu seçim',
        FilterKind.radio => 'Tek seçim',
        FilterKind.pills => 'Hap butonlar',
      };
}

/// One admin-configurable filter block on a type-specific search page
/// (e.g. "Kademe" for schools, "Branş" for teachers). Options match
/// listings by folded word search over their text; the special id
/// 'experience' compares against the owner's years of experience.
class FilterSection {
  FilterSection({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle = '',
    this.affectsResults = true,
    List<String>? options,
  }) : options = options ?? [];

  /// When false the section renders and produces chips like in the design
  /// prototypes, but does not narrow results (no matching data yet,
  /// e.g. distance or class size).
  final bool affectsResults;

  final String id;
  String title;

  /// Short admin-panel description, e.g. "Özel okul arama sayfasındaki
  /// kademe filtresi" (from the Admin Panel design).
  String subtitle;

  FilterKind kind;
  final List<String> options;

  /// Inactive sections are hidden on the search page but keep their options.
  bool active = true;
}

/// The set of filter sections shown for one provider type's search page.
class SearchPageConfig {
  SearchPageConfig({required this.type, List<FilterSection>? sections})
      : sections = sections ?? [];

  final ProviderType type;
  final List<FilterSection> sections;
}

extension ProviderTypeX on ProviderType {
  String get labelTr => switch (this) {
        ProviderType.privateSchool => 'Özel Okul',
        ProviderType.course => 'Kurs',
        ProviderType.dershane => 'Dershane',
        ProviderType.privateTeacher => 'Özel Öğretmen',
      };
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.city = '',
    this.bio = '',
    this.subject = '',
    this.email = '',
    this.joinedAt,
    this.providerId,
    this.seekingJob = false,
    this.experienceYears = 0,
  });

  final String id;
  String name;
  final UserRole role;
  String city;
  String bio;

  /// Contact e-mail shown in the admin user table.
  String email;

  /// Registration date shown in the admin user table.
  DateTime? joinedAt;

  /// Teacher-specific: branch/subject taught.
  String subject;

  /// Teacher-specific: visible to institutions only when true.
  bool seekingJob;
  int experienceYears;

  /// Set when this user owns a listing (teacher or institution).
  String? providerId;

  /// Suspended by an admin; kept for the admin panel user table.
  bool suspended = false;
}

class Review {
  Review({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.stars,
    required this.comment,
    required this.date,
    this.status = ReviewStatus.published,
  });

  final String id;
  final String authorId;
  final String authorName;
  final int stars; // 1..5
  final String comment;
  final DateTime date;
  ReviewStatus status;
}

/// A named program/package offered by a listing (e.g. "LGS Hazırlık").
class ProgramItem {
  const ProgramItem({
    required this.title,
    required this.price,
    required this.description,
    this.note = '',
  });

  final String title;
  final String price;
  final String description;

  /// Short green highlight, e.g. "Kontenjan: son 6 kişi".
  final String note;
}

/// Opening hours row for the sidebar card (e.g. etüt merkezi saatleri,
/// öğretmen uygunluğu). Also reused for lesson-mode rows (label/value).
class OpeningHour {
  const OpeningHour(this.day, this.time);

  final String day;
  final String time;
}

/// Diploma/certificate row for teacher listings ("Eğitim & belgeler").
class CredentialItem {
  const CredentialItem(this.title, this.year);

  final String title;
  final String year;
}

/// A public listing page for a school, course, dershane or private teacher.
class ProviderProfile {
  ProviderProfile({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.type,
    required this.city,
    this.district = '',
    required this.description,
    required this.monthlyPrice,
    List<String>? photoUrls,
    this.videoUrl,
    this.videoDuration,
    this.address,
    this.lessonPrice,
    this.trialLesson = false,
    List<String>? features,
    List<Review>? reviews,
    List<ProgramItem>? programs,
    List<OpeningHour>? hours,
    List<OpeningHour>? lessonModes,
    List<CredentialItem>? credentials,
    this.highlight,
  })  : photoUrls = photoUrls ?? [],
        features = features ?? [],
        reviews = reviews ?? [],
        programs = programs ?? [],
        hours = hours ?? [],
        lessonModes = lessonModes ?? [],
        credentials = credentials ?? [];

  final String id;
  final String ownerUserId;
  String name;
  ProviderType type;
  String city;

  /// District within the city; pickers are fed from data/iller.dart.
  String district;
  String description;
  double monthlyPrice;
  final List<String> photoUrls;

  /// Moderation state; only published listings appear in search.
  ListingStatus status = ListingStatus.published;

  /// Publish date used by the "Yeni eklenen" sort.
  DateTime createdAt = DateTime(2026, 1, 1);

  /// True while the owner has edits not yet submitted for review
  /// (drives the panel status chip: Yayında → Kaydedilmemiş → Onay bekliyor).
  bool hasUnsavedChanges = false;

  /// Card badge from the design: "Doğrulanmış", "Öne çıkan",
  /// "En çok tercih" veya "Yeni".
  String badge = 'Doğrulanmış';

  /// Short intro video URL (played via placeholder player in MVP).
  String? videoUrl;

  /// Video length shown on the badge, e.g. "1:20".
  String? videoDuration;

  /// Street address line for the location card (city is separate).
  String? address;

  /// Contact phone shown in the panel's "İletişim & konum" card.
  String? phone;

  /// Teacher-specific: per-lesson price (60 min), shown as "/ders (60 dk)".
  double? lessonPrice;

  /// Offers a free/discounted trial lesson ("Deneme dersi" badge + filter).
  bool trialLesson;

  final List<String> features;
  final List<Review> reviews;
  final List<ProgramItem> programs;
  final List<OpeningHour> hours;

  /// Teacher-specific: "Ders şekli" rows (mode label → coverage note).
  final List<OpeningHour> lessonModes;

  /// Teacher-specific: diplomas and certificates.
  final List<CredentialItem> credentials;

  /// Short green note under the sidebar price,
  /// e.g. "Ücretsiz deneme dersi + seviye sınavı".
  String? highlight;

  List<Review> get publishedReviews =>
      reviews.where((r) => r.status == ReviewStatus.published).toList();

  /// Average of PUBLISHED reviews only (moderation-aware).
  double get avgRating {
    final visible =
        reviews.where((r) => r.status == ReviewStatus.published).toList();
    return visible.isEmpty
        ? 0
        : visible.map((r) => r.stars).reduce((a, b) => a + b) / visible.length;
  }
}

/// Status flow of a student listing (closed network: only teachers browse).
enum StudentListingStatus { active, matched, closed }

extension StudentListingStatusX on StudentListingStatus {
  String get labelTr => switch (this) {
        StudentListingStatus.active => 'Yayında',
        StudentListingStatus.matched => 'Eşleşti',
        StudentListingStatus.closed => 'Kapandı',
      };
}

enum BidStatus { pending, accepted, rejected }

/// A teacher's offer on a student listing.
class ListingBid {
  ListingBid({
    required this.id,
    required this.teacherUserId,
    required this.listingId,
    required this.price,
    required this.message,
    required this.createdAt,
    this.status = BidStatus.pending,
  });

  final String id;
  final String teacherUserId;
  final String listingId;
  final double price;
  final String message;
  final DateTime createdAt;
  BidStatus status;
}

/// A lesson request posted by a parent/student; visible ONLY to teachers.
/// Only the owner's first name is ever shown (privacy rule from the design).
class StudentListing {
  StudentListing({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.subject,
    required this.level,
    required this.city,
    this.district = '',
    required this.budget,
    required this.schedule,
    required this.mode,
    required this.description,
    required this.createdAt,
    this.startNow = false,
    this.status = StudentListingStatus.active,
  });

  final String id;
  final String ownerUserId;
  String title;
  String subject;

  /// Grade/level, e.g. "8. sınıf (LGS)".
  String level;
  String city;
  String district;

  /// Monthly budget in TL (upper bound the family stated).
  double budget;

  /// e.g. "Hafta sonu", "Hafta içi akşam".
  String schedule;

  /// "Evde ders" / "Online" / "Fark etmez".
  String mode;
  String description;
  final DateTime createdAt;

  /// "Hemen başlayacak" badge + sort option.
  bool startNow;
  StudentListingStatus status;
}

/// Who a pricing plan is sold to (Ücretlendirme page tabs + add-ons).
enum PlanAudience { institution, teacher, addon }

extension PlanAudienceX on PlanAudience {
  String get labelTr => switch (this) {
        PlanAudience.institution => 'Kurumlar',
        PlanAudience.teacher => 'Öğretmenler',
        PlanAudience.addon => 'Ek ürünler',
      };
}

/// A sellable package. Managed in the admin "Paketler" section; the
/// Ücretlendirme page renders straight from this list so price edits
/// there are reflected immediately.
class PricingPlan {
  PricingPlan({
    required this.id,
    required this.audience,
    required this.name,
    this.desc = '',
    this.cta = '',
    required this.price,
    required this.period,
    List<String>? features,
    this.popular = false,
    this.subscribers = 0,
  }) : features = features ?? [];

  final String id;
  final PlanAudience audience;
  String name;

  /// Short tagline under the plan name, e.g. "Büyüyen kurumlar için".
  final String desc;

  /// Button label, e.g. "Premium'a geç".
  final String cta;

  /// TL; 0 renders as "₺0".
  double price;

  /// e.g. "/ay", "/yıl", "/hafta", "/ilan".
  final String period;
  final List<String> features;
  final bool popular;

  /// Active subscription count for the admin revenue cards (MRR = Σ price×subs
  /// of monthly plans).
  int subscribers;

  /// Admin can pause sales; paused plans are greyed out on Ücretlendirme.
  bool onSale = true;
}

/// Admin-managed slider bounds for a search page's price filter
/// (the "ücret aralığı" groups in filter management hold min/max/step).
class PriceRangeConfig {
  PriceRangeConfig({required this.min, required this.max, required this.step});

  double min;
  double max;
  double step;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
}

class Conversation {
  Conversation({
    required this.id,
    required this.userAId,
    required this.userBId,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  final String id;
  final String userAId;
  final String userBId;
  final List<ChatMessage> messages;

  bool involves(String userId) => userAId == userId || userBId == userId;

  String otherUserId(String userId) => userAId == userId ? userBId : userAId;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

enum OfferStatus { requested, quoted, accepted, rejected }

extension OfferStatusX on OfferStatus {
  String get labelTr => switch (this) {
        OfferStatus.requested => 'Teklif Bekleniyor',
        OfferStatus.quoted => 'Fiyat Verildi',
        OfferStatus.accepted => 'Kabul Edildi',
        OfferStatus.rejected => 'Reddedildi',
      };
}

/// A parent/student asks a provider for a price; the provider quotes;
/// the requester accepts or rejects.
class Offer {
  Offer({
    required this.id,
    required this.requesterId,
    required this.providerId,
    required this.note,
    required this.createdAt,
    this.quotedPrice,
    this.status = OfferStatus.requested,
  });

  final String id;
  final String requesterId;
  final String providerId;
  final String note;
  final DateTime createdAt;
  double? quotedPrice;
  OfferStatus status;
}

/// Posted by institutions; visible ONLY to teachers.
class JobPosting {
  JobPosting({
    required this.id,
    required this.institutionUserId,
    required this.institutionName,
    required this.title,
    required this.subject,
    required this.city,
    required this.salaryText,
    required this.description,
    required this.createdAt,
    List<String>? benefits,
    List<String>? applicantUserIds,
  })  : benefits = benefits ?? [],
        applicantUserIds = applicantUserIds ?? [];

  final String id;
  final String institutionUserId;
  final String institutionName;
  final String title;
  final String subject;
  final String city;
  final String salaryText;
  final String description;
  final DateTime createdAt;

  /// Perks like "Yemek", "Servis", "SGK + özel sağlık" from the job form.
  final List<String> benefits;
  final List<String> applicantUserIds;

  /// Closed by an admin or the institution; hidden from teachers when false.
  bool active = true;
}

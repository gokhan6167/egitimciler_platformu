/// Core data models for the educators platform.
/// Pure Dart — no Flutter imports, so they can move to a backend later.
library;

enum UserRole { parent, student, teacher, institution }

extension UserRoleX on UserRole {
  String get labelTr => switch (this) {
        UserRole.parent => 'Veli',
        UserRole.student => 'Öğrenci',
        UserRole.teacher => 'Özel Öğretmen',
        UserRole.institution => 'Kurum',
      };

  bool get isSeeker => this == UserRole.parent || this == UserRole.student;
  bool get isEducator => this == UserRole.teacher || this == UserRole.institution;
}

enum ProviderType { privateSchool, course, dershane, privateTeacher }

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
    this.providerId,
    this.seekingJob = false,
    this.experienceYears = 0,
  });

  final String id;
  String name;
  final UserRole role;
  String city;
  String bio;

  /// Teacher-specific: branch/subject taught.
  String subject;

  /// Teacher-specific: visible to institutions only when true.
  bool seekingJob;
  int experienceYears;

  /// Set when this user owns a listing (teacher or institution).
  String? providerId;
}

class Review {
  Review({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.stars,
    required this.comment,
    required this.date,
  });

  final String id;
  final String authorId;
  final String authorName;
  final int stars; // 1..5
  final String comment;
  final DateTime date;
}

/// A public listing page for a school, course, dershane or private teacher.
class ProviderProfile {
  ProviderProfile({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.type,
    required this.city,
    required this.description,
    required this.monthlyPrice,
    List<String>? photoUrls,
    this.videoUrl,
    List<String>? features,
    List<Review>? reviews,
  })  : photoUrls = photoUrls ?? [],
        features = features ?? [],
        reviews = reviews ?? [];

  final String id;
  final String ownerUserId;
  String name;
  ProviderType type;
  String city;
  String description;
  double monthlyPrice;
  final List<String> photoUrls;

  /// Short intro video URL (played via placeholder player in MVP).
  String? videoUrl;
  final List<String> features;
  final List<Review> reviews;

  double get avgRating => reviews.isEmpty
      ? 0
      : reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length;
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
    List<String>? applicantUserIds,
  }) : applicantUserIds = applicantUserIds ?? [];

  final String id;
  final String institutionUserId;
  final String institutionName;
  final String title;
  final String subject;
  final String city;
  final String salaryText;
  final String description;
  final DateTime createdAt;
  final List<String> applicantUserIds;
}

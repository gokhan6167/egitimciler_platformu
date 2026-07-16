import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

/// Single source of truth for the MVP. Backed by in-memory seed data;
/// swap the internals for a repository/backend later without touching screens.
class AppState extends ChangeNotifier {
  AppState()
      : users = List.of(seedUsers),
        providers = List.of(seedProviders),
        conversations = List.of(seedConversations),
        offers = List.of(seedOffers),
        jobs = List.of(seedJobs);

  final List<AppUser> users;
  final List<ProviderProfile> providers;
  final List<Conversation> conversations;
  final List<Offer> offers;
  final List<JobPosting> jobs;

  AppUser? currentUser;

  int _idCounter = 100;
  String _newId(String prefix) => '${prefix}_${_idCounter++}';

  // ---------- Auth (demo) ----------

  void signIn(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  void signOut() {
    currentUser = null;
    compareIds.clear();
    notifyListeners();
  }

  /// Demo registration: creates the account (and an empty listing for
  /// educators so "Profilim" works), then signs it in.
  AppUser registerUser({
    required String name,
    required UserRole role,
    String city = '',
    String subject = '',
    ProviderType providerType = ProviderType.course,
  }) {
    final id = _newId('u');
    String? providerId;
    if (role.isEducator) {
      providerId = _newId('p');
      providers.add(ProviderProfile(
        id: providerId,
        ownerUserId: id,
        name: role == UserRole.teacher
            ? '$name — ${subject.isEmpty ? 'Özel Ders' : subject}'
            : name,
        type: role == UserRole.teacher
            ? ProviderType.privateTeacher
            : providerType,
        city: city,
        description: '',
        monthlyPrice: 0,
      ));
    }
    final user = AppUser(
      id: id,
      name: name,
      role: role,
      city: city,
      subject: subject,
      providerId: providerId,
      seekingJob: role == UserRole.teacher,
    );
    users.add(user);
    currentUser = user;
    notifyListeners();
    return user;
  }

  // ---------- Lookups ----------

  AppUser? userById(String id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  ProviderProfile? providerById(String id) {
    for (final p in providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Listing owned by the current user (teacher/institution), if any.
  ProviderProfile? get myProvider {
    final pid = currentUser?.providerId;
    return pid == null ? null : providerById(pid);
  }

  // ---------- Browse / filter ----------

  String searchQuery = '';
  ProviderType? filterType;
  String? filterCity;
  double? filterMaxPrice;
  double filterMinRating = 0;

  List<String> get cities =>
      providers.map((p) => p.city).toSet().toList()..sort();

  /// Case/accent-insensitive fold for Turkish text. Dart's toLowerCase()
  /// maps 'İ' to 'i' + combining dot (U+0307), so "İstanbul" would never
  /// contain "istanbul"; fold both sides to plain ASCII instead.
  static String _fold(String s) {
    const map = {
      'İ': 'i', 'I': 'i', 'ı': 'i',
      'Ç': 'c', 'ç': 'c',
      'Ğ': 'g', 'ğ': 'g',
      'Ö': 'o', 'ö': 'o',
      'Ş': 's', 'ş': 's',
      'Ü': 'u', 'ü': 'u',
      '̇': '', // combining dot above, in case it sneaks in
    };
    final sb = StringBuffer();
    for (final ch in s.split('')) {
      sb.write(map[ch] ?? ch.toLowerCase());
    }
    return sb.toString();
  }

  List<ProviderProfile> get filteredProviders {
    return providers.where((p) {
      if (filterType != null && p.type != filterType) return false;
      if (filterCity != null && p.city != filterCity) return false;
      if (filterMaxPrice != null && p.monthlyPrice > filterMaxPrice!) return false;
      if (p.avgRating < filterMinRating) return false;
      if (searchQuery.trim().isNotEmpty) {
        final q = _fold(searchQuery.trim());
        final hay = _fold(
            '${p.name} ${p.description} ${p.city} ${p.features.join(' ')} ${p.type.labelTr}');
        // Every word of the query must match somewhere.
        for (final word in q.split(RegExp(r'\s+'))) {
          if (!hay.contains(word)) return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setFilters({
    ProviderType? type,
    String? city,
    double? maxPrice,
    double? minRating,
    bool clear = false,
  }) {
    if (clear) {
      filterType = null;
      filterCity = null;
      filterMaxPrice = null;
      filterMinRating = 0;
    } else {
      filterType = type;
      filterCity = city;
      filterMaxPrice = maxPrice;
      filterMinRating = minRating ?? 0;
    }
    notifyListeners();
  }

  // ---------- Compare ----------

  static const int compareLimit = 3;
  final Set<String> compareIds = {};

  bool isInCompare(String providerId) => compareIds.contains(providerId);

  /// Returns false when the compare list is full.
  bool toggleCompare(String providerId) {
    if (compareIds.contains(providerId)) {
      compareIds.remove(providerId);
    } else {
      if (compareIds.length >= compareLimit) return false;
      compareIds.add(providerId);
    }
    notifyListeners();
    return true;
  }

  List<ProviderProfile> get compareList =>
      compareIds.map(providerById).whereType<ProviderProfile>().toList();

  // ---------- Reviews ----------

  void addReview(String providerId, int stars, String comment) {
    final user = currentUser;
    final provider = providerById(providerId);
    if (user == null || provider == null) return;
    provider.reviews.add(Review(
      id: _newId('r'),
      authorId: user.id,
      authorName: user.name,
      stars: stars,
      comment: comment,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------- Messaging ----------

  List<Conversation> get myConversations {
    final me = currentUser;
    if (me == null) return [];
    final list = conversations.where((c) => c.involves(me.id)).toList();
    list.sort((a, b) {
      final ta = a.lastMessage?.sentAt ?? DateTime(2000);
      final tb = b.lastMessage?.sentAt ?? DateTime(2000);
      return tb.compareTo(ta);
    });
    return list;
  }

  Conversation conversationWith(String otherUserId) {
    final me = currentUser!;
    for (final c in conversations) {
      if (c.involves(me.id) && c.involves(otherUserId)) return c;
    }
    final conv = Conversation(id: _newId('c'), userAId: me.id, userBId: otherUserId);
    conversations.add(conv);
    notifyListeners();
    return conv;
  }

  void sendMessage(Conversation conv, String text) {
    final me = currentUser;
    if (me == null || text.trim().isEmpty) return;
    conv.messages.add(ChatMessage(
      id: _newId('m'),
      senderId: me.id,
      text: text.trim(),
      sentAt: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------- Offers ----------

  /// Offers I requested (seeker view).
  List<Offer> get myRequestedOffers {
    final me = currentUser;
    if (me == null) return [];
    return offers.where((o) => o.requesterId == me.id).toList().reversed.toList();
  }

  /// Offers targeting my listing (educator view).
  List<Offer> get incomingOffers {
    final pid = currentUser?.providerId;
    if (pid == null) return [];
    return offers.where((o) => o.providerId == pid).toList().reversed.toList();
  }

  void requestOffer(String providerId, String note) {
    final me = currentUser;
    if (me == null) return;
    offers.add(Offer(
      id: _newId('o'),
      requesterId: me.id,
      providerId: providerId,
      note: note,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void quoteOffer(Offer offer, double price) {
    offer.quotedPrice = price;
    offer.status = OfferStatus.quoted;
    notifyListeners();
  }

  void respondToQuote(Offer offer, {required bool accept}) {
    offer.status = accept ? OfferStatus.accepted : OfferStatus.rejected;
    notifyListeners();
  }

  // ---------- Jobs (visibility enforced here too) ----------

  /// Job postings — only teachers may see them.
  List<JobPosting> get visibleJobs {
    if (currentUser?.role != UserRole.teacher) return [];
    return jobs.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// My own postings (institution view).
  List<JobPosting> get myJobPostings {
    final me = currentUser;
    if (me == null || me.role != UserRole.institution) return [];
    return jobs.where((j) => j.institutionUserId == me.id).toList();
  }

  /// Teachers seeking a job — only institutions may see them.
  List<AppUser> get jobSeekingTeachers {
    if (currentUser?.role != UserRole.institution) return [];
    return users.where((u) => u.role == UserRole.teacher && u.seekingJob).toList();
  }

  void createJob({
    required String title,
    required String subject,
    required String city,
    required String salaryText,
    required String description,
  }) {
    final me = currentUser;
    if (me == null || me.role != UserRole.institution) return;
    jobs.add(JobPosting(
      id: _newId('j'),
      institutionUserId: me.id,
      institutionName: me.name,
      title: title,
      subject: subject,
      city: city,
      salaryText: salaryText,
      description: description,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Returns false if already applied.
  bool applyToJob(JobPosting job) {
    final me = currentUser;
    if (me == null || me.role != UserRole.teacher) return false;
    if (job.applicantUserIds.contains(me.id)) return false;
    job.applicantUserIds.add(me.id);
    notifyListeners();
    return true;
  }

  void setSeekingJob(bool value) {
    final me = currentUser;
    if (me == null || me.role != UserRole.teacher) return;
    me.seekingJob = value;
    notifyListeners();
  }

  // ---------- My listing ----------

  void updateMyProvider({
    String? name,
    String? description,
    double? monthlyPrice,
    String? city,
    String? videoUrl,
  }) {
    final p = myProvider;
    if (p == null) return;
    if (name != null && name.trim().isNotEmpty) p.name = name.trim();
    if (description != null) p.description = description;
    if (monthlyPrice != null) p.monthlyPrice = monthlyPrice;
    if (city != null && city.trim().isNotEmpty) p.city = city.trim();
    if (videoUrl != null) p.videoUrl = videoUrl.trim().isEmpty ? null : videoUrl.trim();
    notifyListeners();
  }

  void addPhotoToMyProvider(String url) {
    final p = myProvider;
    if (p == null || url.trim().isEmpty) return;
    p.photoUrls.add(url.trim());
    notifyListeners();
  }
}

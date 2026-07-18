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
        jobs = List.of(seedJobs),
        searchConfigs = buildSearchConfigs();

  final List<AppUser> users;
  final List<ProviderProfile> providers;
  final List<Conversation> conversations;
  final List<Offer> offers;
  final List<JobPosting> jobs;

  /// Admin-configurable filter sections per provider type search page.
  final List<SearchPageConfig> searchConfigs;

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
    String email = '',
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
      )..status = ListingStatus.pending); // admin approves before publishing
    }
    final user = AppUser(
      id: id,
      name: name,
      role: role,
      city: city,
      subject: subject,
      email: email,
      joinedAt: DateTime.now(),
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

  List<String> get cities => providers
      .where((p) => p.status == ListingStatus.published)
      .map((p) => p.city)
      .toSet()
      .toList()
    ..sort();

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
      if (p.status != ListingStatus.published) return false;
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
      if (!_matchesFacets(p)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
  }

  // ---------- Admin: moderation ----------

  bool get isAdmin => currentUser?.role == UserRole.admin;

  List<ProviderProfile> get pendingListings =>
      providers.where((p) => p.status == ListingStatus.pending).toList();

  void setListingStatus(ProviderProfile p, ListingStatus status) {
    p.status = status;
    notifyListeners();
  }

  void setUserSuspended(AppUser user, bool suspended) {
    user.suspended = suspended;
    notifyListeners();
  }

  void setReviewStatus(Review review, ReviewStatus status) {
    review.status = status;
    notifyListeners();
  }

  void setJobActive(JobPosting job, bool active) {
    job.active = active;
    notifyListeners();
  }

  /// Reviews for the moderation panel: reported and pending first,
  /// then the most recent published ones.
  List<(ProviderProfile, Review)> get moderationQueue {
    final all = <(ProviderProfile, Review)>[
      for (final p in providers)
        for (final r in p.reviews) (p, r),
    ];
    int weight(ReviewStatus s) => switch (s) {
          ReviewStatus.reported => 0,
          ReviewStatus.pending => 1,
          ReviewStatus.published => 2,
          ReviewStatus.removed => 3,
        };
    all.sort((a, b) {
      final w = weight(a.$2.status).compareTo(weight(b.$2.status));
      return w != 0 ? w : b.$2.date.compareTo(a.$2.date);
    });
    return all;
  }

  // ---------- Admin: filter section management ----------

  int _sectionCounter = 100;

  void addFilterSection(
    ProviderType type, {
    required String title,
    required FilterKind kind,
    required List<String> options,
  }) {
    final config = configFor(type);
    if (config == null || title.trim().isEmpty) return;
    config.sections.add(FilterSection(
      id: 'custom_${_sectionCounter++}',
      title: title.trim(),
      kind: kind,
      options: options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList(),
    ));
    notifyListeners();
  }

  void toggleFilterSectionActive(ProviderType type, String sectionId) {
    final config = configFor(type);
    if (config == null) return;
    for (final s in config.sections) {
      if (s.id == sectionId) s.active = !s.active;
    }
    notifyListeners();
  }

  void removeFilterSection(ProviderType type, String sectionId) {
    final config = configFor(type);
    if (config == null) return;
    config.sections.removeWhere((s) => s.id == sectionId);
    facetSelections.remove(_facetKey(type, sectionId));
    notifyListeners();
  }

  void addFilterOption(ProviderType type, String sectionId, String option) {
    final config = configFor(type);
    final trimmed = option.trim();
    if (config == null || trimmed.isEmpty) return;
    for (final s in config.sections) {
      if (s.id == sectionId && !s.options.contains(trimmed)) {
        s.options.add(trimmed);
      }
    }
    notifyListeners();
  }

  void removeFilterOption(ProviderType type, String sectionId, String option) {
    final config = configFor(type);
    if (config == null) return;
    for (final s in config.sections) {
      if (s.id == sectionId) {
        s.options.remove(option);
        facetSelections[_facetKey(type, sectionId)]?.remove(option);
      }
    }
    notifyListeners();
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
      facetSelections.clear();
    } else {
      if (type != filterType) facetSelections.clear();
      filterType = type;
      filterCity = city;
      filterMaxPrice = maxPrice;
      filterMinRating = minRating ?? 0;
    }
    notifyListeners();
  }

  // ---------- Configurable facets ----------

  /// Selected options per filter section, keyed `type:sectionId`.
  final Map<String, Set<String>> facetSelections = {};

  SearchPageConfig? configFor(ProviderType? type) {
    if (type == null) return null;
    for (final c in searchConfigs) {
      if (c.type == type) return c;
    }
    return null;
  }

  String _facetKey(ProviderType type, String sectionId) =>
      '${type.name}:$sectionId';

  Set<String> facetSelection(ProviderType type, String sectionId) =>
      facetSelections[_facetKey(type, sectionId)] ?? const {};

  void toggleFacet(ProviderType type, FilterSection section, String option) {
    final key = _facetKey(type, section.id);
    final set = facetSelections.putIfAbsent(key, () => <String>{});
    if (set.contains(option)) {
      set.remove(option);
    } else {
      if (section.kind == FilterKind.radio) set.clear();
      set.add(option);
    }
    if (set.isEmpty) facetSelections.remove(key);
    notifyListeners();
  }

  void clearFacets({ProviderType? type}) {
    if (type == null) {
      facetSelections.clear();
    } else {
      facetSelections.removeWhere((k, _) => k.startsWith('${type.name}:'));
    }
    notifyListeners();
  }

  /// All searchable text of a listing, folded for Turkish matching.
  String _facetHaystack(ProviderProfile p) {
    final owner = userById(p.ownerUserId);
    return _fold([
      p.name,
      p.description,
      p.city,
      p.features.join(' '),
      p.programs.map((x) => '${x.title} ${x.description}').join(' '),
      p.hours.map((x) => '${x.day} ${x.time}').join(' '),
      p.lessonModes.map((x) => '${x.day} ${x.time}').join(' '),
      owner?.subject ?? '',
      owner?.bio ?? '',
    ].join(' '));
  }

  /// True when the listing matches every active facet section (options
  /// within a section combine with OR, sections combine with AND).
  bool _matchesFacets(ProviderProfile p) {
    final config = configFor(filterType);
    if (config == null) return true;

    String? hay; // built lazily once per provider
    for (final section in config.sections) {
      if (!section.affectsResults) continue; // chip-only sections
      final selected = facetSelection(config.type, section.id);
      if (selected.isEmpty) continue;

      if (section.id == 'experience') {
        final owner = userById(p.ownerUserId);
        final years = owner?.experienceYears ?? 0;
        final wanted = selected
            .map((o) => int.tryParse(o.split('+').first.trim()) ?? 0)
            .reduce((a, b) => a < b ? a : b);
        if (years < wanted) return false;
        continue;
      }

      hay ??= _facetHaystack(p);
      final anyOption = selected.any((option) => _optionMatches(hay!, option));
      if (!anyOption) return false;
    }
    return true;
  }

  /// "Kodlama & Robotik" matches if any meaningful word matches.
  static bool _optionMatches(String hay, String option) => _fold(option)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.length >= 3)
      .any(hay.contains);

  /// How many published listings of [type] a facet option matches —
  /// shown next to checkbox options like the counts in the design.
  int facetOptionCount(ProviderType type, FilterSection section, String option) {
    return providers.where((p) {
      if (p.status != ListingStatus.published || p.type != type) return false;
      if (!section.affectsResults) return true;
      if (section.id == 'experience') {
        final years = userById(p.ownerUserId)?.experienceYears ?? 0;
        final wanted = int.tryParse(option.split('+').first.trim()) ?? 0;
        return years >= wanted;
      }
      return _optionMatches(_facetHaystack(p), option);
    }).length;
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

  /// Job postings — only teachers may see them, and only active ones.
  List<JobPosting> get visibleJobs {
    if (currentUser?.role != UserRole.teacher) return [];
    return jobs.where((j) => j.active).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

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
        studentListings = buildStudentListings(),
        bids = buildSeedBids(),
        pricingPlans = buildPricingPlans(),
        priceRanges = buildPriceRanges(),
        searchConfigs = buildSearchConfigs();

  final List<AppUser> users;
  final List<ProviderProfile> providers;
  final List<Conversation> conversations;
  final List<Offer> offers;
  final List<JobPosting> jobs;
  final List<StudentListing> studentListings;
  final List<ListingBid> bids;

  /// Sellable packages; single source for Ücretlendirme and admin "Paketler".
  final List<PricingPlan> pricingPlans;

  /// Admin-managed price slider bounds per search page.
  final Map<String, PriceRangeConfig> priceRanges;

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
    String bio = '',
    int experienceYears = 0,
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
      bio: bio,
      subject: subject,
      email: email,
      joinedAt: DateTime.now(),
      providerId: providerId,
      seekingJob: role == UserRole.teacher,
      experienceYears: experienceYears,
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

  /// Multi-select districts of [filterCity] (pill buttons under the
  /// province picker; data comes from data/iller.dart).
  final Set<String> filterDistricts = {};
  double? filterMaxPrice;
  double filterMinRating = 0;

  /// Active sort key; valid keys come from [sortOptionsFor].
  String sortKey = 'recommended';

  /// Sort menu entries per search page (README "Sıralama" spec).
  static List<(String, String)> sortOptionsFor(ProviderType? type) {
    if (type == ProviderType.privateTeacher) {
      return const [
        ('recommended', 'Önerilen'),
        ('rating', 'Puan'),
        ('price', 'Ücret'),
        ('distance', 'Mesafe'),
        ('experience', 'Deneyim'),
        ('response', 'Yanıt hızı'),
        ('newest', 'Yeni eklenen'),
      ];
    }
    return const [
      ('recommended', 'Önerilen'),
      ('rating', 'Puan'),
      ('price', 'Ücret'),
      ('distance', 'Mesafe'),
      ('reviews', 'Yorum sayısı'),
      ('newest', 'Yeni eklenen'),
    ];
  }

  void setSortKey(String key) {
    sortKey = key;
    notifyListeners();
  }

  /// Deterministic pseudo-value derived from the id (stable across runs,
  /// unlike String.hashCode) — stands in for distance/response data.
  static int idSeed(String id) =>
      id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  /// Fake distance in km (0.5–9.9) until real location data exists.
  static double pseudoDistanceKm(String id) => 0.5 + (idSeed(id) % 95) / 10;

  /// Fake average response minutes (10–129) for "Yanıt hızı".
  static int responseMinutes(String id) => 10 + idSeed(id) % 120;

  /// Price used by the search slider: per-lesson for teachers,
  /// monthly for institutions.
  static double effectivePrice(ProviderProfile p) =>
      p.type == ProviderType.privateTeacher
          ? (p.lessonPrice ?? p.monthlyPrice)
          : p.monthlyPrice;

  /// Slider bounds for a search page; falls back to a generic range.
  PriceRangeConfig priceRangeFor(ProviderType? type) =>
      priceRanges[type?.name ?? ''] ??
      PriceRangeConfig(min: 0, max: 30000, step: 500);

  void toggleFilterDistrict(String district) {
    if (!filterDistricts.remove(district)) filterDistricts.add(district);
    notifyListeners();
  }

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
    final list = providers.where((p) {
      if (p.status != ListingStatus.published) return false;
      if (filterType != null && p.type != filterType) return false;
      if (filterCity != null && p.city != filterCity) return false;
      if (filterDistricts.isNotEmpty && !filterDistricts.contains(p.district)) {
        return false;
      }
      if (filterMaxPrice != null && effectivePrice(p) > filterMaxPrice!) {
        return false;
      }
      if (p.avgRating < filterMinRating) return false;
      if (searchQuery.trim().isNotEmpty) {
        final q = _fold(searchQuery.trim());
        final hay = _fold(
            '${p.name} ${p.description} ${p.city} ${p.district} ${p.features.join(' ')} ${p.type.labelTr}');
        // Every word of the query must match somewhere.
        for (final word in q.split(RegExp(r'\s+'))) {
          if (!hay.contains(word)) return false;
        }
      }
      if (!_matchesFacets(p)) return false;
      return true;
    }).toList();

    int cmp(ProviderProfile a, ProviderProfile b) => switch (sortKey) {
          'rating' => b.avgRating.compareTo(a.avgRating),
          'price' => effectivePrice(a).compareTo(effectivePrice(b)),
          'distance' =>
            pseudoDistanceKm(a.id).compareTo(pseudoDistanceKm(b.id)),
          'reviews' => b.publishedReviews.length
              .compareTo(a.publishedReviews.length),
          'newest' => b.createdAt.compareTo(a.createdAt),
          'experience' => (userById(b.ownerUserId)?.experienceYears ?? 0)
              .compareTo(userById(a.ownerUserId)?.experienceYears ?? 0),
          'response' =>
            responseMinutes(a.id).compareTo(responseMinutes(b.id)),
          // Recommended: badge holders first, then rating.
          _ => ((b.badge == 'Öne çıkan' ? 1 : 0) -
                      (a.badge == 'Öne çıkan' ? 1 : 0)) *
                  10 +
              b.avgRating.compareTo(a.avgRating).sign.toInt(),
        };
    list.sort(cmp);
    return list;
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
      filterDistricts.clear();
      filterMaxPrice = null;
      filterMinRating = 0;
      sortKey = 'recommended';
      facetSelections.clear();
    } else {
      if (type != filterType) {
        facetSelections.clear();
        sortKey = 'recommended';
      }
      if (city != filterCity) filterDistricts.clear();
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

  static const int compareLimit = 4;
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
    List<String>? benefits,
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
      benefits: benefits,
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
    double? lessonPrice,
    String? city,
    String? district,
    String? address,
    String? phone,
    String? videoUrl,
    bool? trialLesson,
  }) {
    final p = myProvider;
    if (p == null) return;
    if (name != null && name.trim().isNotEmpty) p.name = name.trim();
    if (description != null) p.description = description;
    if (monthlyPrice != null) p.monthlyPrice = monthlyPrice;
    if (lessonPrice != null) p.lessonPrice = lessonPrice;
    if (city != null && city.trim().isNotEmpty) p.city = city.trim();
    if (district != null) p.district = district.trim();
    if (address != null) p.address = address.trim().isEmpty ? null : address.trim();
    if (phone != null) p.phone = phone.trim().isEmpty ? null : phone.trim();
    if (videoUrl != null) p.videoUrl = videoUrl.trim().isEmpty ? null : videoUrl.trim();
    if (trialLesson != null) p.trialLesson = trialLesson;
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Toggle a selectable feature tag on my listing. The options come from
  /// the SAME admin-managed filter sections the search pages use, keeping
  /// panel tags and search filters in sync by construction.
  void toggleMyProviderFeature(String option) {
    final p = myProvider;
    if (p == null) return;
    if (!p.features.remove(option)) p.features.add(option);
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Radio-like groups: drop the group's other options, then set [option].
  void selectMyProviderFeature(FilterSection section, String option) {
    final p = myProvider;
    if (p == null) return;
    p.features.removeWhere(section.options.contains);
    p.features.add(option);
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  void addPhotoToMyProvider(String url) {
    final p = myProvider;
    if (p == null || url.trim().isEmpty) return;
    p.photoUrls.add(url.trim());
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  void removePhotoFromMyProvider(String url) {
    final p = myProvider;
    if (p == null) return;
    p.photoUrls.remove(url);
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Replaces my listing's lesson packages ("Ders paketleri & teklifler").
  void setMyProviderPrograms(List<ProgramItem> programs) {
    final p = myProvider;
    if (p == null) return;
    p.programs
      ..clear()
      ..addAll(programs);
    p.hasUnsavedChanges = true;
    notifyListeners();
  }

  /// "Kaydet ve onaya gönder": edits go back through admin review
  /// (status chip: Kaydedilmemiş değişiklikler → Onay bekliyor).
  void submitMyProviderForReview() {
    final p = myProvider;
    if (p == null) return;
    p.hasUnsavedChanges = false;
    p.status = ListingStatus.pending;
    notifyListeners();
  }

  /// Deterministic demo stats for the panel stat strip
  /// (views, offer requests, compare adds, conversion).
  static ({int views, int offers, int compares, String conversion})
      providerStats(ProviderProfile p) {
    final seed = idSeed(p.id);
    final views = 400 + seed % 1800;
    final offers = 4 + seed % 38;
    return (
      views: views,
      offers: offers,
      compares: 10 + seed % 90,
      conversion: '%${(offers * 100 / views).toStringAsFixed(1)}',
    );
  }

  // ---------- Student listings (closed network) ----------

  /// Student lesson requests — visible only to teachers and admins;
  /// owners always see their own.
  List<StudentListing> get visibleStudentListings {
    final me = currentUser;
    if (me == null) return [];
    if (me.role == UserRole.teacher || me.role == UserRole.admin) {
      return studentListings
          .where((l) => l.status != StudentListingStatus.closed)
          .toList();
    }
    return studentListings.where((l) => l.ownerUserId == me.id).toList();
  }

  /// Sort keys for the student listing search page.
  static const List<(String, String)> studentSortOptions = [
    ('newest', 'En yeni'),
    ('budget', 'Bütçe'),
    ('distance', 'Yakınımda'),
    ('bids', 'Teklif sayısı'),
    ('startNow', 'Hemen başlayacak'),
  ];

  String studentSortKey = 'newest';
  String studentSearchQuery = '';
  String? studentFilterCity;
  final Set<String> studentFilterDistricts = {};
  double? studentMaxBudget;

  void setStudentSort(String key) {
    studentSortKey = key;
    notifyListeners();
  }

  void setStudentSearch(String q) {
    studentSearchQuery = q;
    notifyListeners();
  }

  void setStudentCity(String? city) {
    if (city != studentFilterCity) studentFilterDistricts.clear();
    studentFilterCity = city;
    notifyListeners();
  }

  void toggleStudentDistrict(String district) {
    if (!studentFilterDistricts.remove(district)) {
      studentFilterDistricts.add(district);
    }
    notifyListeners();
  }

  void setStudentMaxBudget(double? budget) {
    studentMaxBudget = budget;
    notifyListeners();
  }

  void clearStudentFilters() {
    studentSearchQuery = '';
    studentFilterCity = null;
    studentFilterDistricts.clear();
    studentMaxBudget = null;
    studentSortKey = 'newest';
    notifyListeners();
  }

  List<ListingBid> bidsFor(String listingId) =>
      bids.where((b) => b.listingId == listingId).toList();

  List<StudentListing> get filteredStudentListings {
    final list = visibleStudentListings.where((l) {
      if (studentFilterCity != null && l.city != studentFilterCity) {
        return false;
      }
      if (studentFilterDistricts.isNotEmpty &&
          !studentFilterDistricts.contains(l.district)) {
        return false;
      }
      if (studentMaxBudget != null && l.budget > studentMaxBudget!) {
        return false;
      }
      final q = studentSearchQuery.trim();
      if (q.isNotEmpty) {
        final hay = _fold(
            '${l.title} ${l.subject} ${l.level} ${l.city} ${l.district} ${l.description} ${l.schedule} ${l.mode}');
        for (final word in _fold(q).split(RegExp(r'\s+'))) {
          if (!hay.contains(word)) return false;
        }
      }
      return true;
    }).toList();

    int cmp(StudentListing a, StudentListing b) => switch (studentSortKey) {
          'budget' => b.budget.compareTo(a.budget),
          'distance' =>
            pseudoDistanceKm(a.id).compareTo(pseudoDistanceKm(b.id)),
          'bids' => bidsFor(b.id).length.compareTo(bidsFor(a.id).length),
          'startNow' => (b.startNow ? 1 : 0).compareTo(a.startNow ? 1 : 0),
          _ => b.createdAt.compareTo(a.createdAt),
        };
    list.sort(cmp);
    return list;
  }

  /// Teacher places (or updates) an offer on a student listing.
  bool placeBid(StudentListing listing, double price, String message) {
    final me = currentUser;
    if (me == null || me.role != UserRole.teacher) return false;
    if (bids.any(
        (b) => b.listingId == listing.id && b.teacherUserId == me.id)) {
      return false; // one bid per teacher per listing
    }
    bids.add(ListingBid(
      id: _newId('b'),
      teacherUserId: me.id,
      listingId: listing.id,
      price: price,
      message: message,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  /// Owner accepts a bid → chip turns "✓ Kabul edildi" and a conversation
  /// with the teacher opens (design: accepted offer → "Mesaja git").
  void acceptBid(ListingBid bid) {
    bid.status = BidStatus.accepted;
    final listing = studentListings.firstWhere((l) => l.id == bid.listingId);
    listing.status = StudentListingStatus.matched;
    notifyListeners();
  }

  /// Owner rejects a bid → it drops from the list.
  void rejectBid(ListingBid bid) {
    bid.status = BidStatus.rejected;
    notifyListeners();
  }

  /// My own student listings (seeker side of the closed network).
  List<StudentListing> get myStudentListings {
    final me = currentUser;
    if (me == null) return [];
    return studentListings.where((l) => l.ownerUserId == me.id).toList();
  }

  /// Bids I placed as a teacher (the "giden" tab of Tekliflerim).
  List<ListingBid> get myBids {
    final me = currentUser;
    if (me == null) return [];
    return bids.where((b) => b.teacherUserId == me.id).toList();
  }

  StudentListing? studentListingById(String id) {
    for (final l in studentListings) {
      if (l.id == id) return l;
    }
    return null;
  }

  void createStudentListing({
    required String title,
    required String subject,
    required String level,
    required String city,
    String district = '',
    required double budget,
    required String schedule,
    required String mode,
    required String description,
    bool startNow = false,
  }) {
    final me = currentUser;
    if (me == null) return;
    studentListings.add(StudentListing(
      id: _newId('sl'),
      ownerUserId: me.id,
      title: title,
      subject: subject,
      level: level,
      city: city,
      district: district,
      budget: budget,
      schedule: schedule,
      mode: mode,
      description: description,
      createdAt: DateTime.now(),
      startNow: startNow,
    ));
    notifyListeners();
  }

  // ---------- Pricing plans (admin ↔ Ücretlendirme sync) ----------

  List<PricingPlan> plansFor(PlanAudience audience) =>
      pricingPlans.where((p) => p.audience == audience).toList();

  /// Monthly recurring revenue for the admin revenue card
  /// (yearly plans contribute price/12).
  double get monthlyRecurringRevenue {
    var total = 0.0;
    for (final p in pricingPlans) {
      if (!p.onSale) continue;
      total += switch (p.period) {
        '/ay' => p.price * p.subscribers,
        '/yıl' => p.price * p.subscribers / 12,
        _ => 0.0,
      };
    }
    return total;
  }

  int get activeSubscriptions => pricingPlans
      .where((p) => p.price > 0)
      .fold(0, (sum, p) => sum + p.subscribers);

  void setPlanPrice(PricingPlan plan, double price) {
    plan.price = price;
    notifyListeners();
  }

  void setPlanOnSale(PricingPlan plan, bool onSale) {
    plan.onSale = onSale;
    notifyListeners();
  }

  /// Admin edits to a search page's price slider bounds.
  void setPriceRange(String key, {double? min, double? max, double? step}) {
    final range = priceRanges[key];
    if (range == null) return;
    if (min != null) range.min = min;
    if (max != null) range.max = max;
    if (step != null) range.step = step;
    notifyListeners();
  }

  // ---------- Contact masking (Güvenlik: numara gizleme) ----------

  static final RegExp _phoneRe =
      RegExp(r'(\+?\d[\d\s().-]{7,}\d)');
  static final RegExp _emailRe =
      RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+', caseSensitive: false);

  /// True once the pair has an accepted offer or accepted bid between them
  /// ("ilk ders onayı") — masking is lifted after that.
  bool contactUnlocked(String userAId, String userBId) {
    bool pairMatches(String x, String y) =>
        (x == userAId && y == userBId) || (x == userBId && y == userAId);
    for (final o in offers) {
      if (o.status != OfferStatus.accepted) continue;
      final providerOwner = providerById(o.providerId)?.ownerUserId;
      if (providerOwner != null && pairMatches(o.requesterId, providerOwner)) {
        return true;
      }
    }
    for (final b in bids) {
      if (b.status != BidStatus.accepted) continue;
      final owner = studentListingById(b.listingId)?.ownerUserId;
      if (owner != null && pairMatches(b.teacherUserId, owner)) return true;
    }
    return false;
  }

  /// Masks phone numbers and e-mails until the first lesson is confirmed.
  /// Returns (text, masked?) so the UI can show the warning pill.
  (String, bool) maskContact(String text, Conversation conv) {
    if (contactUnlocked(conv.userAId, conv.userBId)) return (text, false);
    var masked = false;
    var out = text.replaceAllMapped(_phoneRe, (m) {
      masked = true;
      return '••• (numara gizlendi)';
    });
    out = out.replaceAllMapped(_emailRe, (m) {
      masked = true;
      return '••• (e-posta gizlendi)';
    });
    return (out, masked);
  }
}

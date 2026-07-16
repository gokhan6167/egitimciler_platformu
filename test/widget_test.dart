import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egitimciler_platformu/main.dart';
import 'package:egitimciler_platformu/models/models.dart';
import 'package:egitimciler_platformu/state/app_state.dart';

void main() {
  testWidgets('landing page renders and leads to demo sign-in', (tester) async {
    await tester.pumpWidget(const EgitimcilerApp());
    await tester.pump();

    // Hero from the Pusula design.
    expect(find.text('Çocuğunuza en uygun eğitimi karşılaştırarak bulun.'),
        findsOneWidget);
    expect(find.text('Kayıt ol'), findsOneWidget);

    // "Giriş yap" opens the sign-in screen from the "Giris Yap" design.
    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('Tekrar hoş geldiniz'), findsOneWidget);
    expect(find.textContaining('Ayşe Yılmaz'), findsWidgets); // parent tab

    // Kurum tab lists institution demo accounts.
    await tester.tap(find.text('Kurum'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bilge Koleji'), findsWidgets);

    // Signing in with the default (first) institution account works.
    final loginButton = find.widgetWithText(FilledButton, 'Giriş yap');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Tekrar hoş geldiniz'), findsNothing);
  });

  testWidgets('hero search reaches results and detail without sign-in',
      (tester) async {
    await tester.pumpWidget(const EgitimcilerApp());
    await tester.pump();

    // Type a Turkish-cased query and search (default tab: Özel Okul).
    await tester.enterText(find.byType(TextField).first, 'istanbul');
    await tester.ensureVisible(find.text('Ara'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();

    // Guest results page shows the matching school despite İ/i casing.
    expect(find.text('Arama sonuçları'), findsOneWidget);
    expect(find.textContaining('Bilge Koleji'), findsWidgets);

    // Listing detail opens without an account and offers seeker actions.
    await tester.tap(find.textContaining('Bilge Koleji').first);
    await tester.pumpAndSettle();
    expect(find.text('Teklif iste'), findsOneWidget);
  });

  group('role-based visibility', () {
    test('job postings are visible ONLY to teachers', () {
      final app = AppState();

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.teacher));
      expect(app.visibleJobs, isNotEmpty);

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.parent));
      expect(app.visibleJobs, isEmpty);

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.institution));
      expect(app.visibleJobs, isEmpty,
          reason: 'institutions manage their own postings via myJobPostings, '
              'the browse list stays teacher-only');
    });

    test('job-seeking teachers are visible ONLY to institutions', () {
      final app = AppState();

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.institution));
      expect(app.jobSeekingTeachers, isNotEmpty);
      expect(app.jobSeekingTeachers.every((t) => t.seekingJob), isTrue);

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.parent));
      expect(app.jobSeekingTeachers, isEmpty);

      app.signIn(app.users.firstWhere((u) => u.role == UserRole.teacher));
      expect(app.jobSeekingTeachers, isEmpty);
    });
  });

  group('core flows', () {
    test('registration creates the account and signs it in', () {
      final app = AppState();

      final parent = app.registerUser(name: 'Deneme Veli', role: UserRole.parent);
      expect(app.currentUser, parent);
      expect(parent.providerId, isNull);

      final teacher = app.registerUser(
          name: 'Deneme Öğretmen', role: UserRole.teacher, subject: 'Kimya');
      expect(teacher.providerId, isNotNull);
      expect(app.providerById(teacher.providerId!)!.type,
          ProviderType.privateTeacher);
      expect(app.visibleJobs, isNotEmpty,
          reason: 'new teachers can browse job postings');

      final institution = app.registerUser(
          name: 'Deneme Koleji',
          role: UserRole.institution,
          providerType: ProviderType.privateSchool);
      expect(institution.providerId, isNotNull);
      expect(app.providerById(institution.providerId!)!.type,
          ProviderType.privateSchool);
    });

    test('search is Turkish case/accent insensitive', () {
      final app = AppState();

      app.setSearch('istanbul'); // matches "İstanbul"
      expect(app.filteredProviders.map((p) => p.name),
          contains('Bilge Koleji'));

      app.setSearch('İNGİLİZCE'); // matches "İngilizce"
      expect(app.filteredProviders.map((p) => p.name),
          contains('Lingua Dil Kursu'));

      app.setSearch('kodlama atolyesi'); // accent-folded multi-word
      expect(app.filteredProviders.map((p) => p.name),
          contains('Kodlama Atölyesi'));

      app.setSearch('');
      expect(
          app.filteredProviders.length,
          app.providers
              .where((p) => p.status == ListingStatus.published)
              .length,
          reason: 'pending/suspended listings stay out of public search');
    });

    test('configurable facets filter listings per type', () {
      final app = AppState();

      // Okul sayfası: "Lise" kademesi program başlıklarından eşleşir.
      app.setFilters(type: ProviderType.privateSchool);
      final config = app.configFor(ProviderType.privateSchool)!;
      final kademe = config.sections.firstWhere((s) => s.id == 'kademe');
      app.toggleFacet(ProviderType.privateSchool, kademe, 'Lise');
      expect(app.filteredProviders.map((p) => p.name),
          contains('Bilge Koleji'));
      expect(
          app.filteredProviders
              .every((p) => p.type == ProviderType.privateSchool),
          isTrue);

      // Öğretmen sayfası: deneyim filtresi sahibin yılına bakar.
      app.setFilters(type: ProviderType.privateTeacher);
      final tConfig = app.configFor(ProviderType.privateTeacher)!;
      final deneyim =
          tConfig.sections.firstWhere((s) => s.id == 'experience');
      app.toggleFacet(ProviderType.privateTeacher, deneyim, '10+ yıl');
      expect(app.filteredProviders.map((p) => p.name).toList(),
          ['Zeynep Demir — Matematik']);

      app.setFilters(clear: true);
      expect(app.facetSelections, isEmpty);
    });

    test('admin can moderate listings, jobs, reviews and filters', () {
      final app = AppState();
      app.signIn(app.users.firstWhere((u) => u.role == UserRole.admin));
      expect(app.isAdmin, isTrue);

      // Listing approval publishes into search.
      final pending = app.pendingListings.first;
      final before = app.filteredProviders.length;
      app.setListingStatus(pending, ListingStatus.published);
      expect(app.filteredProviders.length, before + 1);
      app.setListingStatus(pending, ListingStatus.pending); // restore seed

      // Job closing hides it from teachers.
      final job = app.jobs.first;
      app.setJobActive(job, false);
      app.signIn(app.users.firstWhere((u) => u.role == UserRole.teacher));
      expect(app.visibleJobs.map((j) => j.id), isNot(contains(job.id)));
      app.setJobActive(job, true); // restore seed

      // Removing a review drops it from the average.
      final provider = app.providerById('p_kurum1')!;
      final review = provider.publishedReviews.first;
      final countBefore = provider.publishedReviews.length;
      app.setReviewStatus(review, ReviewStatus.removed);
      expect(provider.publishedReviews.length, countBefore - 1);
      app.setReviewStatus(review, ReviewStatus.published); // restore seed

      // Filter section CRUD.
      app.addFilterSection(ProviderType.privateSchool,
          title: 'Müfredat türü',
          kind: FilterKind.checkbox,
          options: ['MEB', 'IB']);
      final config = app.configFor(ProviderType.privateSchool)!;
      final added = config.sections.last;
      expect(added.title, 'Müfredat türü');
      app.addFilterOption(ProviderType.privateSchool, added.id, 'Cambridge');
      expect(added.options, contains('Cambridge'));
      app.removeFilterOption(ProviderType.privateSchool, added.id, 'MEB');
      expect(added.options, isNot(contains('MEB')));
      app.toggleFilterSectionActive(ProviderType.privateSchool, added.id);
      expect(added.active, isFalse);
      app.removeFilterSection(ProviderType.privateSchool, added.id);
      expect(config.sections.any((s) => s.id == added.id), isFalse);
    });

    test('filtering by type, city, price and rating works', () {
      final app = AppState();

      app.setFilters(type: ProviderType.privateTeacher);
      expect(
          app.filteredProviders
              .every((p) => p.type == ProviderType.privateTeacher),
          isTrue);

      app.setFilters(city: 'İstanbul');
      expect(app.filteredProviders.every((p) => p.city == 'İstanbul'), isTrue);

      app.setFilters(maxPrice: 5000);
      expect(
          app.filteredProviders.every((p) => p.monthlyPrice <= 5000), isTrue);

      app.setFilters(minRating: 4.5);
      expect(app.filteredProviders.every((p) => p.avgRating >= 4.5), isTrue);

      app.setFilters(clear: true);
      expect(
          app.filteredProviders.length,
          app.providers
              .where((p) => p.status == ListingStatus.published)
              .length);
    });

    test('compare list is capped at 3', () {
      final app = AppState();
      final ids = app.providers.map((p) => p.id).toList();

      expect(app.toggleCompare(ids[0]), isTrue);
      expect(app.toggleCompare(ids[1]), isTrue);
      expect(app.toggleCompare(ids[2]), isTrue);
      expect(app.toggleCompare(ids[3]), isFalse, reason: 'limit is 3');
      expect(app.compareList.length, 3);

      expect(app.toggleCompare(ids[0]), isTrue, reason: 'removal always works');
      expect(app.compareList.length, 2);
    });

    test('offer flow: request -> quote -> accept', () {
      final app = AppState();
      final parent = app.users.firstWhere((u) => u.role == UserRole.parent);
      app.signIn(parent);

      app.requestOffer('p_ogretmen2', 'Haftada 1 gün İngilizce dersi.');
      final offer = app.myRequestedOffers.first;
      expect(offer.status, OfferStatus.requested);

      // Educator quotes
      final teacher = app.users.firstWhere((u) => u.providerId == 'p_ogretmen2');
      app.signIn(teacher);
      expect(app.incomingOffers.map((o) => o.id), contains(offer.id));
      app.quoteOffer(offer, 4800);
      expect(offer.status, OfferStatus.quoted);
      expect(offer.quotedPrice, 4800);

      // Requester accepts
      app.signIn(parent);
      app.respondToQuote(offer, accept: true);
      expect(offer.status, OfferStatus.accepted);
    });

    test('messaging creates one conversation per pair and appends messages', () {
      final app = AppState();
      app.signIn(app.users.firstWhere((u) => u.role == UserRole.student));

      final conv1 = app.conversationWith('u_ogretmen3');
      final conv2 = app.conversationWith('u_ogretmen3');
      expect(conv1.id, conv2.id);

      app.sendMessage(conv1, 'Merhaba, fizik dersi hakkında bilgi alabilir miyim?');
      expect(conv1.messages.last.text, contains('fizik'));
      expect(app.myConversations.map((c) => c.id), contains(conv1.id));
    });

    test('review changes average rating', () {
      final app = AppState();
      app.signIn(app.users.firstWhere((u) => u.role == UserRole.parent));

      final provider = app.providerById('p_ogretmen2')!;
      expect(provider.avgRating, 0);
      app.addReview(provider.id, 5, 'Harika bir öğretmen.');
      expect(provider.avgRating, 5);
      expect(provider.reviews.length, 1);
    });

    test('institution can create a job and teacher can apply once', () {
      final app = AppState();
      final institution =
          app.users.firstWhere((u) => u.role == UserRole.institution);
      app.signIn(institution);
      final before = app.myJobPostings.length;
      app.createJob(
        title: 'Fizik Öğretmeni',
        subject: 'Fizik',
        city: 'İstanbul',
        salaryText: '50.000 TL',
        description: 'Lise fizik öğretmeni aranıyor.',
      );
      expect(app.myJobPostings.length, before + 1);
      final job = app.myJobPostings.last;

      final teacher = app.users.firstWhere((u) => u.role == UserRole.teacher);
      app.signIn(teacher);
      expect(app.applyToJob(job), isTrue);
      expect(app.applyToJob(job), isFalse, reason: 'no duplicate applications');
      expect(job.applicantUserIds, contains(teacher.id));
    });
  });
}

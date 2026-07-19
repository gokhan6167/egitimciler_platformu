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
    expect(find.text('En uygun eğitimi karşılaştırarak bulun'),
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

  testWidgets('hero category tab reaches results and detail without sign-in',
      (tester) async {
    await tester.pumpWidget(const EgitimcilerApp());
    await tester.pump();

    // Colored hero tab opens the type's own search page (v2 design).
    await tester.tap(find.text('Dershane').first);
    await tester.pumpAndSettle();

    // AppBar now shows the green pill logo instead of a plain title (design).
    expect(find.text('Pusula Eğitim'), findsOneWidget);
    expect(find.textContaining('Kavram Dershanesi'), findsWidgets);

    // Listing detail opens without an account and offers seeker actions.
    await tester.tap(find.textContaining('Kavram Dershanesi').first);
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
      // Teachers are priced per lesson, institutions per month.
      expect(
          app.filteredProviders
              .every((p) => AppState.effectivePrice(p) <= 5000),
          isTrue);

      app.setFilters(minRating: 4.5);
      expect(app.filteredProviders.every((p) => p.avgRating >= 4.5), isTrue);

      app.setFilters(clear: true);
      expect(
          app.filteredProviders.length,
          app.providers
              .where((p) => p.status == ListingStatus.published)
              .length);
    });

    test('compare list is capped at 4 (design: en fazla 4 ilan)', () {
      final app = AppState();
      final ids = app.providers.map((p) => p.id).toList();

      expect(app.toggleCompare(ids[0]), isTrue);
      expect(app.toggleCompare(ids[1]), isTrue);
      expect(app.toggleCompare(ids[2]), isTrue);
      expect(app.toggleCompare(ids[3]), isTrue);
      expect(app.toggleCompare(ids[4]), isFalse, reason: 'limit is 4');
      expect(app.compareList.length, 4);

      expect(app.toggleCompare(ids[0]), isTrue, reason: 'removal always works');
      expect(app.compareList.length, 3);
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

  group('handoff v2 features', () {
    test('student listings are closed network: teachers see, parents own', () {
      final app = AppState();
      final parent = app.users.firstWhere((u) => u.role == UserRole.parent);
      final teacher = app.users.firstWhere((u) => u.role == UserRole.teacher);
      final institution =
          app.users.firstWhere((u) => u.role == UserRole.institution);

      app.signIn(teacher);
      expect(app.visibleStudentListings, isNotEmpty,
          reason: 'teachers browse all active listings');

      app.signIn(institution);
      expect(app.visibleStudentListings, isEmpty,
          reason: 'institutions never see student listings');

      app.signIn(parent);
      expect(
          app.visibleStudentListings.every((l) => l.ownerUserId == parent.id),
          isTrue,
          reason: 'seekers only see their own listings');
    });

    test('bid flow: teacher bids once, owner accepts -> listing matched', () {
      final app = AppState();
      final teacher = app.users.firstWhere((u) => u.id == 'u_ogretmen2');
      app.signIn(teacher);
      final listing = app.studentListings.first;
      expect(app.placeBid(listing, 1000, 'Uygunum'), isTrue);
      expect(app.placeBid(listing, 900, 'Tekrar'), isFalse,
          reason: 'one bid per teacher per listing');

      final bid = app.bids
          .firstWhere((b) => b.teacherUserId == teacher.id &&
              b.listingId == listing.id);
      app.acceptBid(bid);
      expect(bid.status, BidStatus.accepted);
      expect(listing.status, StudentListingStatus.matched);
    });

    test('contact masking hides phone/e-mail until a bid is accepted', () {
      final app = AppState();
      final listing = app.studentListings.first; // owner: u_veli
      final owner = app.userById(listing.ownerUserId)!;
      final teacher = app.users.firstWhere((u) => u.id == 'u_ogretmen3');

      app.signIn(owner);
      final conv = app.conversationWith(teacher.id);
      const risky = 'Numaram 0532 123 45 67, mail: veli@ornek.com';

      final (maskedText, masked) = app.maskContact(risky, conv);
      expect(masked, isTrue);
      expect(maskedText.contains('0532'), isFalse);
      expect(maskedText.contains('veli@ornek.com'), isFalse);

      // Teacher's bid gets accepted -> contact unlocks.
      app.signIn(teacher);
      app.placeBid(listing, 950, 'Merhaba');
      final bid = app.bids.firstWhere((b) =>
          b.teacherUserId == teacher.id && b.listingId == listing.id);
      app.acceptBid(bid);

      final (unmaskedText, stillMasked) = app.maskContact(risky, conv);
      expect(stillMasked, isFalse);
      expect(unmaskedText, risky);
    });

    test('admin plan price edits feed the pricing page data', () {
      final app = AppState();
      final premium =
          app.pricingPlans.firstWhere((p) => p.id == 'plan_premium');
      expect(premium.price, 1490);

      app.setPlanPrice(premium, 1690);
      expect(
          app
              .plansFor(PlanAudience.institution)
              .firstWhere((p) => p.id == 'plan_premium')
              .price,
          1690,
          reason: 'Ücretlendirme reads the same objects');

      app.setPlanOnSale(premium, false);
      expect(premium.onSale, isFalse);
      expect(app.monthlyRecurringRevenue,
          lessThan(1690 * premium.subscribers + 1),
          reason: 'paused plans drop out of MRR');
    });

    test('admin price range edits drive search slider bounds', () {
      final app = AppState();
      final before = app.priceRangeFor(ProviderType.privateSchool);
      expect(before.min, 2000);
      expect(before.max, 15000);
      expect(before.step, 500);

      app.setPriceRange('privateSchool', max: 20000, step: 1000);
      final after = app.priceRangeFor(ProviderType.privateSchool);
      expect(after.max, 20000);
      expect(after.step, 1000);
    });

    test('district filter narrows results, sort keys reorder them', () {
      final app = AppState();
      app.setFilters(type: ProviderType.privateSchool, city: 'İstanbul');
      app.toggleFilterDistrict('Kadıköy');
      expect(app.filteredProviders.every((p) => p.district == 'Kadıköy'),
          isTrue);
      app.toggleFilterDistrict('Kadıköy');

      app.setFilters(type: ProviderType.privateSchool);
      app.setSortKey('price');
      final prices = app.filteredProviders
          .map(AppState.effectivePrice)
          .toList();
      for (var i = 1; i < prices.length; i++) {
        expect(prices[i - 1] <= prices[i], isTrue,
            reason: 'ascending price sort');
      }

      app.setSortKey('newest');
      final dates =
          app.filteredProviders.map((p) => p.createdAt).toList();
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].isBefore(dates[i]), isFalse,
            reason: 'newest first');
      }
    });

    test('panel edits mark unsaved changes; submit sends to review', () {
      final app = AppState();
      final teacher = app.users.firstWhere((u) => u.id == 'u_ogretmen1');
      app.signIn(teacher);
      final p = app.myProvider!;
      expect(p.hasUnsavedChanges, isFalse);

      app.updateMyProvider(description: 'Yeni tanıtım');
      expect(p.hasUnsavedChanges, isTrue);

      app.submitMyProviderForReview();
      expect(p.hasUnsavedChanges, isFalse);
      expect(p.status, ListingStatus.pending,
          reason: 'edits go back through moderation');

      // Panel feature toggles use the same options as search filters.
      final section = app
          .configFor(p.type)!
          .sections
          .firstWhere((s) => s.id == 'brans');
      app.selectMyProviderFeature(section, section.options.first);
      expect(p.features, contains(section.options.first));
    });
  });
}

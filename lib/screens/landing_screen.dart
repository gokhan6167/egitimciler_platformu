import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import 'browse_screen.dart';
import 'compare_screen.dart';
import 'login_screen.dart';
import 'provider_detail_screen.dart';

/// Public marketing page, implemented from the "Pusula Egitim v2"
/// Claude Design file. All CTAs lead to the (demo) sign-in screen.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _SearchTab {
  const _SearchTab(this.label, this.hint);

  final String label;
  final String hint;
}

class _LandingScreenState extends State<LandingScreen> {
  int _activeTab = 0;
  final _searchController = TextEditingController();
  final _howItWorksKey = GlobalKey();

  static const _tabs = [
    _SearchTab('Özel Okul', 'Örn. bilim koleji, İngilizce ağırlıklı'),
    _SearchTab('Kurs', 'Örn. matematik, kodlama, İngilizce'),
    _SearchTab('Dershane', 'Örn. LGS, YKS hazırlık'),
    _SearchTab('Özel Öğretmen', 'Örn. birebir matematik, evde'),
  ];

  static const _tabTypes = [
    ProviderType.privateSchool,
    ProviderType.course,
    ProviderType.dershane,
    ProviderType.privateTeacher,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// Run the hero search: store query + selected type, then open the
  /// results page — no sign-in required to browse and compare.
  void _submitSearch() {
    final app = context.read<AppState>();
    app.setSearch(_searchController.text);
    app.setFilters(type: _tabTypes[_activeTab]);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  /// Category cards open the same results page filtered by type.
  void _browseCategory(ProviderType type) {
    final app = context.read<AppState>();
    app.setSearch('');
    app.setFilters(type: type);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  /// "Keşfet" style links: open the guest results page unfiltered.
  void _openResults() {
    final app = context.read<AppState>();
    app.setSearch('');
    app.setFilters(clear: true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  void _openCompare() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompareScreen()),
    );
  }

  void _scrollToHowItWorks() {
    final ctx = _howItWorksKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
    }
  }

  bool get _wide => MediaQuery.of(context).size.width >= 980;
  bool get _narrow => MediaQuery.of(context).size.width < 620;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _navBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    _hero(),
                    _sectionDivider(),
                    _categories(),
                    _sectionDivider(),
                    _featuredListings(),
                    _howItWorks(),
                    _compareSection(),
                    _careerSection(),
                    _testimonial(),
                    _sectionDivider(),
                    _cta(),
                    _footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider() =>
      Container(height: 1, color: PusulaColors.border);

  Widget _maxWidth(Widget child, {EdgeInsets? padding}) => Container(
        constraints: const BoxConstraints(maxWidth: 1120),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 32),
        child: child,
      );

  // ---------- Nav ----------

  Widget _navBar() {
    return Container(
      decoration: const BoxDecoration(
        color: PusulaColors.background,
        border: Border(bottom: BorderSide(color: PusulaColors.border)),
      ),
      child: Center(
        child: _maxWidth(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                const PusulaLogo(),
                const SizedBox(width: 9),
                Text('Pusula Eğitim',
                    style: pusulaHeading(fontSize: 17, letterSpacingFactor: -0.01)),
                const Spacer(),
                if (_wide) ...[
                  for (final (link, onTap) in [
                    ('Nasıl çalışır', _scrollToHowItWorks),
                    ('Keşfet', _openResults),
                    ('Karşılaştır', _openCompare),
                    // Career area is the closed network — account required.
                    ('Öğretmen kariyeri', _goToSignIn),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: InkWell(
                        onTap: onTap,
                        child: Text(link,
                            style: const TextStyle(
                                fontSize: 14, color: PusulaColors.body)),
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
                TextButton(
                  onPressed: _goToSignIn,
                  child: const Text('Giriş yap',
                      style: TextStyle(color: PusulaColors.ink)),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10)),
                  onPressed: _goToSignIn,
                  child: const Text('Kayıt ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Hero ----------

  Widget _hero() {
    return _maxWidth(
      Padding(
        padding: EdgeInsets.only(top: _narrow ? 56 : 96, bottom: 72),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                'Çocuğunuza en uygun eğitimi karşılaştırarak bulun.',
                textAlign: TextAlign.center,
                style: pusulaHeading(
                  fontSize: _narrow ? 31 : (_wide ? 54 : 38),
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacingFactor: -0.03,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const Text(
                'Özel okul, kurs, dershane ve özel öğretmenleri tek yerde inceleyin. '
                'Puanları görün, teklif alın, mesajlaşın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, height: 1.65, color: PusulaColors.body),
              ),
            ),
            const SizedBox(height: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () => setState(() => _activeTab = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: i == _activeTab
                                  ? PusulaColors.primarySoft
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              _tabs[i].label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: i == _activeTab
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: i == _activeTab
                                    ? PusulaColors.primaryDark
                                    : PusulaColors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _searchBar(),
                  const SizedBox(height: 28),
                  const Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      Text('8.400+ doğrulanmış ilan', style: _statStyle),
                      Text('·', style: _statStyle),
                      Text('62.000+ veli değerlendirmesi', style: _statStyle),
                      Text('·', style: _statStyle),
                      Text('81 il', style: _statStyle),
                      Text('·', style: _statStyle),
                      Text('%98 teklif yanıt oranı', style: _statStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _statStyle = TextStyle(fontSize: 13, color: PusulaColors.muted);

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 6, 6, 6),
      decoration: BoxDecoration(
        color: PusulaColors.card,
        border: Border.all(color: const Color(0xFFE3E1DB)),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: PusulaColors.ink.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _submitSearch(),
              style: const TextStyle(fontSize: 15, color: PusulaColors.ink),
              decoration: InputDecoration(
                hintText: _tabs[_activeTab].hint,
                hintStyle:
                    const TextStyle(fontSize: 15, color: PusulaColors.faint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!_narrow) ...[
            Container(
                width: 1,
                height: 22,
                color: PusulaColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 16)),
            const Text('İl / ilçe',
                style: TextStyle(fontSize: 15, color: PusulaColors.faint)),
          ],
          const SizedBox(width: 16),
          FilledButton(
            style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            onPressed: _submitSearch,
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  // ---------- Categories ----------

  Widget _categories() {
    const cats = [
      ('01', 'Özel Okullar', 'Anaokulundan liseye kurumsal okullar.', '1.240'),
      ('02', 'Kurslar', 'Dil, kodlama, sanat ve beceri kursları.', '3.080'),
      ('03', 'Dershaneler', "LGS ve YKS'ye hazırlık merkezleri.", '2.410'),
      ('04', 'Özel Öğretmenler', 'Birebir ve evde ders veren eğitmenler.', '1.670'),
    ];
    final columns = _narrow ? 1 : (_wide ? 4 : 2);

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Ne aradığınızı seçin', 'Tüm kategoriler →',
                onTap: () {
                  final app = context.read<AppState>();
                  app.setSearch('');
                  app.setFilters(clear: true);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SearchResultsScreen()));
                }),
            const SizedBox(height: 36),
            _grid(
              columns: columns,
              gap: 24,
              children: [
                for (var i = 0; i < cats.length; i++)
                  InkWell(
                    onTap: () => _browseCategory(_tabTypes[i]),
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(color: PusulaColors.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cats[i].$1,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: PusulaColors.faint)),
                          const SizedBox(height: 14),
                          Text(cats[i].$2, style: pusulaHeading(fontSize: 18)),
                          const SizedBox(height: 6),
                          Text(cats[i].$3,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: PusulaColors.muted,
                                  height: 1.55)),
                          const SizedBox(height: 12),
                          Text('${cats[i].$4} ilan',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: PusulaColors.primary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Featured listings (real seed data) ----------

  Widget _featuredListings() {
    final providers = context.watch<AppState>().providers.take(6).toList();
    final columns = _narrow ? 1 : (_wide ? 3 : 2);

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.only(top: 56, bottom: 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Velilerin en çok incelediği ilanlar', 'Tümünü gör →',
                onTap: () {
                  final app = context.read<AppState>();
                  app.setSearch('');
                  app.setFilters(clear: true);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SearchResultsScreen()));
                }),
            const SizedBox(height: 36),
            _grid(
              columns: columns,
              gap: 32,
              children: [
                for (final p in providers) _listingCard(p),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingCard(ProviderProfile p) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(providerId: p.id)),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: p.photoUrls.isEmpty
                    ? _patternBox(height: 190)
                    : NetworkPhoto(
                        url: p.photoUrls.first,
                        height: 190,
                        width: double.infinity),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PusulaColors.background.withValues(alpha: 0.92),
                    border: Border.all(color: PusulaColors.border),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('Doğrulanmış',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: PusulaColors.ink)),
                ),
              ),
              if (p.videoUrl != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PusulaColors.ink.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('▶ Tanıtım',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${p.type.labelTr.toUpperCase()} · ${p.city.toUpperCase()}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PusulaColors.faint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(p.name,
                    style: pusulaHeading(
                        fontSize: 17, height: 1.35, letterSpacingFactor: -0.01)),
              ),
              const SizedBox(width: 12),
              Text.rich(
                TextSpan(
                  text: '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)} ',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: '(${p.reviews.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: PusulaColors.faint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text('${formatPrice(p.monthlyPrice)}/ay başlangıç',
                    style: const TextStyle(
                        fontSize: 14, color: PusulaColors.body)),
              ),
              const Text('Teklif al →',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patternBox({double? height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: PusulaColors.patternA,
        border: Border.all(color: PusulaColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.school_outlined,
          color: PusulaColors.faint, size: 32),
    );
  }

  // ---------- How it works ----------

  Widget _howItWorks() {
    const steps = [
      ('1', 'Ara & Karşılaştır',
          'İl, seviye ve bütçenize göre filtreleyin. İlanları puanlarıyla yan yana karşılaştırın.'),
      ('2', 'Teklif Al & Mesajlaş',
          'Beğendiğiniz kurumlara teklif isteği gönderin, doğrudan mesajlaşarak sorularınızı sorun.'),
      ('3', 'Değerlendir & Karar Ver',
          'Gerçek veli yorumlarını okuyun, kararınızı verin ve deneyiminizi puanlayın.'),
    ];

    return Container(
      key: _howItWorksKey,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PusulaColors.surface,
        border: Border(
          top: BorderSide(color: PusulaColors.border),
          bottom: BorderSide(color: PusulaColors.border),
        ),
      ),
      child: Center(
        child: _maxWidth(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              children: [
                Text('Üç adımda doğru karar',
                    textAlign: TextAlign.center,
                    style: pusulaHeading(fontSize: 28)),
                const SizedBox(height: 48),
                _grid(
                  columns: _wide ? 3 : 1,
                  gap: 48,
                  children: [
                    for (final (num, title, desc) in steps)
                      Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PusulaColors.card,
                              border:
                                  Border.all(color: PusulaColors.borderDark),
                            ),
                            alignment: Alignment.center,
                            child: Text(num,
                                style: pusulaHeading(
                                    fontSize: 15,
                                    color: PusulaColors.primary)),
                          ),
                          const SizedBox(height: 18),
                          Text(title, style: pusulaHeading(fontSize: 19)),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(desc,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: PusulaColors.body,
                                    height: 1.65)),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Compare ----------

  Widget _compareSection() {
    const features = [
      'Ücret, mesafe, kontenjan ve puanı tek tabloda görün',
      'İl / ilçe, seviye, branş ve bütçe filtreleri',
      'Doğrulanmış rozetler ve gerçek veli yorumları',
      'Kaydettiğiniz ilanları listeleyip paylaşın',
    ];

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Yan yana koyun, farkı görün.',
            style: pusulaHeading(fontSize: 32)),
        const SizedBox(height: 16),
        const Text(
          'Ücret, mesafe, kadro, başarı oranı ve veli puanlarını tek tabloda '
          'karşılaştırın. Filtrelerle seçenekleri saniyeler içinde daraltın.',
          style:
              TextStyle(fontSize: 16, color: PusulaColors.body, height: 1.7),
        ),
        const SizedBox(height: 24),
        for (final f in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('—',
                    style: TextStyle(
                        color: PusulaColors.primary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(f,
                      style: const TextStyle(
                          fontSize: 15,
                          color: PusulaColors.slate,
                          height: 1.55)),
                ),
              ],
            ),
          ),
      ],
    );

    final right = Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: PusulaColors.card,
        border: Border.all(color: PusulaColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _compareTable(),
    );

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 88),
        child: _wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 64),
                  Expanded(flex: 11, child: right),
                ],
              )
            : Column(children: [left, const SizedBox(height: 40), right]),
      ),
    );
  }

  Widget _compareTable() {
    const rows = [
      ('Puan', '4.9', '4.7', '4.6', true),
      ('Aylık ücret', '₺6.500', '₺3.200', '₺2.900', false),
      ('Mesafe', '2.1 km', '4.8 km', '1.3 km', false),
      ('Kontenjan', 'Var', 'Dolu', 'Var', false),
      ('Teklif', '✓', '✓', '✓', true),
    ];
    const labelStyle = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: PusulaColors.faint);
    TextStyle cell(bool bold) => TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? PusulaColors.ink : PusulaColors.body,
        );

    Widget row(String label, String a, String b, String c, TextStyle s,
        {bool border = true}) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: border
            ? const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFFF1EFEA))))
            : null,
        child: Row(
          children: [
            Expanded(flex: 13, child: Text(label, style: labelStyle)),
            Expanded(
                flex: 10, child: Text(a, style: s, textAlign: TextAlign.center)),
            Expanded(
                flex: 10, child: Text(b, style: s, textAlign: TextAlign.center)),
            Expanded(
                flex: 10, child: Text(c, style: s, textAlign: TextAlign.center)),
          ],
        ),
      );
    }

    final head = pusulaHeading(fontSize: 13, letterSpacingFactor: 0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Expanded(
                  flex: 13,
                  child: Text('Karşılaştırma',
                      style: TextStyle(
                          fontSize: 12, color: PusulaColors.faint))),
              Expanded(
                  flex: 10,
                  child: Text('Bilge Koleji',
                      style: head, textAlign: TextAlign.center)),
              Expanded(
                  flex: 10,
                  child: Text('Anadolu Kurs',
                      style: head, textAlign: TextAlign.center)),
              Expanded(
                  flex: 10,
                  child: Text('Zirve Dershane',
                      style: head, textAlign: TextAlign.center)),
            ],
          ),
        ),
        for (final (label, a, b, c, bold) in rows)
          row(label, a, b, c, cell(bold)),
      ],
    );
  }

  // ---------- Career (closed network) ----------

  Widget _careerSection() {
    const jobs = [
      ('Matematik Öğretmeni (LGS)', 'Zirve Dershanesi · Ankara', 'Tam zamanlı'),
      ('Fen Bilimleri Öğretmeni', 'Bilge Koleji · İstanbul', 'Tam zamanlı'),
      ('İngilizce Eğitmeni', 'Fluent Akademi · Antalya', 'Yarı zamanlı'),
    ];
    const teachers = [
      ('Merve A.', 'Matematik · 8 yıl', '★ 5.0'),
      ('Kaan T.', 'Fizik · 5 yıl', '★ 4.8'),
      ('Selin D.', 'İngilizce · 6 yıl', '★ 4.9'),
    ];

    Widget listRow(String title, String sub, String trailing) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PusulaColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 12, color: PusulaColors.faint)),
                ],
              ),
            ),
            Text(trailing,
                style:
                    const TextStyle(fontSize: 12, color: PusulaColors.body)),
          ],
        ),
      );
    }

    Widget column(String title, String sub, List<Widget> rows, String cta) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: pusulaHeading(fontSize: 17)),
          const SizedBox(height: 4),
          Text(sub,
              style:
                  const TextStyle(fontSize: 13, color: PusulaColors.faint)),
          const SizedBox(height: 18),
          ...rows,
          const SizedBox(height: 20),
          InkWell(
            onTap: _goToSignIn,
            child: Text(cta,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: PusulaColors.primary)),
          ),
        ],
      );
    }

    final institutions = column(
      'Kurumlar',
      'İş ilanı açın, doğrulanmış öğretmen havuzunda arayın.',
      [for (final (t, s, tr) in jobs) listRow(t, s, tr)],
      'İş ilanı ver →',
    );
    final teachersCol = column(
      'Öğretmenler',
      'Profil oluşturun, branşınıza uygun ilanlara gizli başvurun.',
      [for (final (t, s, tr) in teachers) listRow(t, s, tr)],
      'Öğretmen profili oluştur →',
    );

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: Container(
          padding: EdgeInsets.all(_narrow ? 28 : 56),
          decoration: BoxDecoration(
            color: PusulaColors.card,
            border: Border.all(color: PusulaColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ÖĞRETMEN KARİYERİ · KAPALI AĞ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.primary,
                      letterSpacing: 0.72)),
              const SizedBox(height: 12),
              Text('Kurumlar ve öğretmenler için özel alan',
                  style: pusulaHeading(fontSize: 30)),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'İş ilanlarını yalnızca öğretmenler görür; iş arayan öğretmen '
                  'profillerini yalnızca öğretmen arayan kurumlar görür. '
                  'Veli ve öğrencilere kapalıdır.',
                  style: TextStyle(
                      fontSize: 16, color: PusulaColors.body, height: 1.65),
                ),
              ),
              const SizedBox(height: 44),
              _wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: institutions),
                        const SizedBox(width: 56),
                        Expanded(child: teachersCol),
                      ],
                    )
                  : Column(children: [
                      institutions,
                      const SizedBox(height: 40),
                      teachersCol
                    ]),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Testimonial / CTA / Footer ----------

  Widget _testimonial() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 88),
      child: Column(
        children: [
          Text(
            '"Üç dershaneyi puanlarına ve ücretlerine göre karşılaştırdım, '
            'ikisiyle mesajlaştım ve teklif aldım. Bir haftada kararımızı verdik."',
            textAlign: TextAlign.center,
            style: pusulaHeading(
                fontSize: _narrow ? 20 : 26,
                fontWeight: FontWeight.w600,
                height: 1.5,
                letterSpacingFactor: -0.01),
          ),
          const SizedBox(height: 22),
          const Text('Elif Y. — Veli, Ankara · ★ 5.0',
              style: TextStyle(fontSize: 14, color: PusulaColors.muted)),
        ],
      ),
    );
  }

  Widget _cta() {
    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 88),
        child: Column(
          children: [
            Text('Doğru eğitime giden yolu bugün bulun.',
                textAlign: TextAlign.center,
                style: pusulaHeading(
                    fontSize: _narrow ? 28 : 38,
                    fontWeight: FontWeight.w800,
                    letterSpacingFactor: -0.03)),
            const SizedBox(height: 14),
            const Text(
              "Veli, öğrenci, öğretmen ya da kurum — Pusula Eğitim'e ücretsiz katılın.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: PusulaColors.body),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                    onPressed: _openResults,
                    child: const Text('Aramaya başla')),
                OutlinedButton(
                    onPressed: _goToSignIn,
                    child: const Text('İlan / iş ilanı ver')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    Widget linkCol(String title, List<String> links,
        {Map<String, VoidCallback> actions = const {}}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 14),
          for (final l in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: InkWell(
                onTap: actions[l] ?? _goToSignIn,
                child: Text(l,
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.muted)),
              ),
            ),
        ],
      );
    }

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const PusulaLogo(size: 22),
            const SizedBox(width: 8),
            Text('Pusula Eğitim', style: pusulaHeading(fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(
          width: 280,
          child: Text(
            "Türkiye'nin eğitim pazar yeri. Özel okul, kurs, dershane ve "
            'özel öğretmeni karşılaştırarak bulun.',
            style: TextStyle(
                fontSize: 13, height: 1.6, color: PusulaColors.muted),
          ),
        ),
      ],
    );

    final cols = [
      linkCol(
        'Keşfet',
        ['Özel okullar', 'Kurslar', 'Dershaneler', 'Özel öğretmenler'],
        actions: {
          'Özel okullar': () => _browseCategory(ProviderType.privateSchool),
          'Kurslar': () => _browseCategory(ProviderType.course),
          'Dershaneler': () => _browseCategory(ProviderType.dershane),
          'Özel öğretmenler': () =>
              _browseCategory(ProviderType.privateTeacher),
        },
      ),
      linkCol(
        'Kurumlar',
        ['İlan ver', 'İş ilanı aç', 'Fiyatlandırma', 'Nasıl çalışır'],
        actions: {'Nasıl çalışır': _scrollToHowItWorks},
      ),
      linkCol('Destek', ['Yardım merkezi', 'Güvenlik', 'İletişim', 'KVKK']),
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PusulaColors.surface,
        border: Border(top: BorderSide(color: PusulaColors.border)),
      ),
      child: Center(
        child: _maxWidth(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 56, bottom: 28),
                child: _wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 16, child: brand),
                          for (final c in cols) Expanded(flex: 10, child: c),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          brand,
                          const SizedBox(height: 32),
                          Wrap(spacing: 48, runSpacing: 32, children: cols),
                        ],
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  children: const [
                    Text('© 2026 Pusula Eğitim. Tüm hakları saklıdır.',
                        style: TextStyle(
                            fontSize: 12, color: PusulaColors.faint)),
                    Text("Türkiye'de sevgiyle",
                        style: TextStyle(
                            fontSize: 12, color: PusulaColors.faint)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helpers ----------

  Widget _sectionHeader(String title, String action, {VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: pusulaHeading(fontSize: 28))),
        InkWell(
          onTap: onTap ?? _goToSignIn,
          child: Text(action,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PusulaColors.primary)),
        ),
      ],
    );
  }

  Widget _grid({
    required int columns,
    required double gap,
    required List<Widget> children,
  }) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) rowChildren.add(SizedBox(width: gap));
        rowChildren.add(Expanded(
          child: i + j < children.length
              ? children[i + j]
              : const SizedBox.shrink(),
        ));
      }
      if (i > 0) rows.add(SizedBox(height: gap));
      rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren));
    }
    return Column(children: rows);
  }
}

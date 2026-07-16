import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import 'browse_screen.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'provider_detail_screen.dart';
import 'register_screen.dart';

/// Public landing page from the minimal "Pusula Egitim v2" design:
/// slim nav, hero with colored category buttons, three featured listings,
/// a three-step strip, a career strip and a one-line footer.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

/// Hero category tab: each has its own pastel color and opens that
/// type's search page directly.
class _SearchTab {
  const _SearchTab(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;
}

class _LandingScreenState extends State<LandingScreen> {
  int _activeTab = 0;

  static const _tabs = [
    _SearchTab('Özel Okul', Color(0xFFEAF3EF), Color(0xFF0B5E4C)),
    _SearchTab('Kurs', Color(0xFFFBF1DF), Color(0xFF8A6212)),
    _SearchTab('Dershane', Color(0xFFEEF0FB), Color(0xFF3A46A0)),
    _SearchTab('Özel Öğretmen', Color(0xFFF7EAF1), Color(0xFF8A2E63)),
  ];

  static const _tabTypes = [
    ProviderType.privateSchool,
    ProviderType.course,
    ProviderType.dershane,
    ProviderType.privateTeacher,
  ];

  bool get _wide => MediaQuery.of(context).size.width >= 980;
  bool get _narrow => MediaQuery.of(context).size.width < 620;

  void _goToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  /// Category buttons open the type's own search page.
  void _browseCategory(ProviderType type) {
    final app = context.read<AppState>();
    app.setSearch('');
    app.setFilters(type: type);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  /// "Tümünü gör": the results page with no filters.
  void _openResults() {
    final app = context.read<AppState>();
    app.setSearch('');
    app.setFilters(clear: true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what sayfası demo sürümünde henüz yok.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _navBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _hero(),
                  _featured(),
                  _divider(),
                  _how(),
                  _divider(),
                  _careerStrip(),
                  _divider(),
                  _footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: PusulaColors.border);

  Widget _maxWidth(Widget child, {EdgeInsets? padding}) => Container(
        constraints: const BoxConstraints(maxWidth: 1060),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 32),
        child: child,
      );

  // ---------- Nav ----------

  Widget _navBar() {
    final signedIn = context.watch<AppState>().currentUser != null;

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
                    style: pusulaHeading(
                        fontSize: 17, letterSpacingFactor: -0.01)),
                const Spacer(),
                if (signedIn)
                  FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                    ),
                    child: const Text('Panele dön'),
                  )
                else ...[
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
                    onPressed: _goToRegister,
                    child: const Text('Kayıt ol'),
                  ),
                ],
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
        padding: EdgeInsets.only(top: _narrow ? 56 : 96, bottom: 88),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                'En uygun eğitimi karşılaştırarak bulun',
                textAlign: TextAlign.center,
                style: pusulaHeading(
                  fontSize: _narrow ? 30 : (_wide ? 40 : 34),
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacingFactor: -0.02,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Text(
                'Okul, kurs, dershane ve özel öğretmenler tek yerde',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, height: 1.6, color: PusulaColors.body),
              ),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  _searchBar(),
                  const SizedBox(height: 24),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      Text('8.400+ doğrulanmış ilan', style: _statStyle),
                      Text('·', style: _statStyle),
                      Text('62.000+ veli değerlendirmesi', style: _statStyle),
                      Text('·', style: _statStyle),
                      Text('81 il', style: _statStyle),
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

  static const _statStyle = TextStyle(fontSize: 13, color: PusulaColors.faint);

  /// Colored category button inside the search pill.
  Widget _heroTab(int i) {
    final tab = _tabs[i];
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        setState(() => _activeTab = i);
        _browseCategory(_tabTypes[i]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tab.bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          tab.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tab.fg,
          ),
        ),
      ),
    );
  }

  /// Search pill: four colored category buttons + Ara.
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: PusulaColors.card,
        border: Border.all(color: const Color(0xFFE3E1DB)),
        borderRadius: BorderRadius.circular(_narrow ? 24 : 100),
        boxShadow: [
          BoxShadow(
            color: PusulaColors.ink.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: _narrow
          ? Column(
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < _tabs.length; i++) _heroTab(i),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => _browseCategory(_tabTypes[_activeTab]),
                    child: const Text('Ara'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _heroTab(i)),
                ],
                const SizedBox(width: 6),
                FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 12)),
                  onPressed: () => _browseCategory(_tabTypes[_activeTab]),
                  child: const Text('Ara'),
                ),
              ],
            ),
    );
  }

  // ---------- Featured (3 listings) ----------

  Widget _featured() {
    final providers = context
        .watch<AppState>()
        .providers
        .where((p) => p.status == ListingStatus.published)
        .toList()
      ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
    final top = providers.take(3).toList();
    final columns = _narrow ? 1 : (_wide ? 3 : 2);

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text('Öne çıkan ilanlar',
                      style: pusulaHeading(
                          fontSize: 20, letterSpacingFactor: -0.01)),
                ),
                InkWell(
                  onTap: _openResults,
                  child: const Text('Tümünü gör →',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PusulaColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (ctx, c) {
              final w = (c.maxWidth - (columns - 1) * 24) / columns;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final p in top)
                    SizedBox(width: w, child: _listingCard(p)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _listingCard(ProviderProfile p) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(providerId: p.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: p.photoUrls.isEmpty
                ? Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PusulaColors.patternA,
                      border: Border.all(color: PusulaColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_outlined,
                        color: PusulaColors.faint, size: 32),
                  )
                : NetworkPhoto(
                    url: p.photoUrls.first,
                    height: 170,
                    width: double.infinity),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(p.name,
                    style: pusulaHeading(
                        fontSize: 16,
                        height: 1.35,
                        letterSpacingFactor: -0.01)),
              ),
              const SizedBox(width: 12),
              Text(
                '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text('${p.type.labelTr} · ${p.city}',
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.muted)),
              ),
              Text('${formatPrice(p.monthlyPrice)}/ay',
                  style: const TextStyle(
                      fontSize: 13, color: PusulaColors.body)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- How (3 steps) ----------

  Widget _how() {
    const steps = [
      ('01', 'Ara ve karşılaştır', 'Puan, ücret ve mesafeye göre filtreleyin.'),
      ('02', 'Teklif alın', 'Kurumlarla doğrudan mesajlaşın, teklif isteyin.'),
      ('03', 'Karar verin', 'Gerçek veli yorumlarıyla güvenle seçin.'),
    ];

    Widget step((String, String, String) s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.$1,
                style: pusulaHeading(
                    fontSize: 13,
                    color: PusulaColors.primary,
                    letterSpacingFactor: 0)),
            const SizedBox(height: 8),
            Text(s.$2,
                style:
                    pusulaHeading(fontSize: 17, letterSpacingFactor: -0.01)),
            const SizedBox(height: 6),
            Text(s.$3,
                style: const TextStyle(
                    fontSize: 14, color: PusulaColors.body, height: 1.6)),
          ],
        );

    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: _wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(width: 40),
                    Expanded(child: step(steps[i])),
                  ],
                ],
              )
            : Column(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 28),
                    SizedBox(width: double.infinity, child: step(steps[i])),
                  ],
                ],
              ),
      ),
    );
  }

  // ---------- Career strip ----------

  Widget _careerStrip() {
    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: 'Öğretmen veya kurum musunuz? ',
                style: pusulaHeading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacingFactor: 0),
                children: const [
                  TextSpan(
                    text:
                        'İş ilanları yalnızca öğretmenlere, öğretmen profilleri '
                        'yalnızca kurumlara açık.',
                    style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: PusulaColors.slate),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _goToSignIn,
              child: const Text('Öğretmen kariyeri →',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Footer ----------

  Widget _footer() {
    return _maxWidth(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Wrap(
          spacing: 20,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            const Text('© 2026 Pusula Eğitim',
                style: TextStyle(fontSize: 13, color: PusulaColors.faint)),
            Wrap(
              spacing: 20,
              children: [
                for (final label in const ['Yardım', 'Güvenlik', 'KVKK'])
                  InkWell(
                    onTap: () => _comingSoon(label),
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 13, color: PusulaColors.faint)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

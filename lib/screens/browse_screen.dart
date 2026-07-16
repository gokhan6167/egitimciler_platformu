import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import '../widgets/home_button.dart';
import 'compare_screen.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
import 'provider_detail_screen.dart';

/// Standalone results page for guests coming from the landing hero search.
/// Wraps [BrowseScreen] in its own scaffold; signing in is offered but not
/// required to browse, open listings or compare them.
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AppState>().currentUser != null;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PusulaLogo(size: 22),
            const SizedBox(width: 8),
            Text('Arama sonuçları', style: pusulaHeading(fontSize: 16)),
          ],
        ),
        centerTitle: false,
        actions: [
          const HomeButton(),
          if (!signedIn)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Giriş yap'),
              ),
            ),
        ],
      ),
      body: const BrowseScreen(),
    );
  }
}

/// Search + filters + results, from the "Arama - Ozel Okul" Claude Design
/// file: pill search bar, filter sidebar (wide) or filter sheet (narrow),
/// sort pills, active filter chips and horizontal listing cards.
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // Seeded with the query typed on the landing hero, if any.
  late final TextEditingController _searchController;
  int _sort = 0; // 0 önerilen (puan), 1 puan, 2 ücret (artan)

  static const _ratingSteps = [0.0, 4.0, 4.5, 4.8];
  static const _ratingLabels = ['Tümü', '4.0+', '4.5+', '4.8+'];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: context.read<AppState>().searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------- Guest gating ----------

  bool _requireLogin() {
    if (context.read<AppState>().currentUser != null) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu işlem için önce giriş yapın.')),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return false;
  }

  void _messageOwner(ProviderProfile p) {
    if (!_requireLogin()) return;
    final app = context.read<AppState>();
    final owner = app.userById(p.ownerUserId);
    if (owner == null || owner.id == app.currentUser!.id) return;
    final conv = app.conversationWith(owner.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conv.id)),
    );
  }

  void _requestOffer(ProviderProfile p) {
    if (!_requireLogin()) return;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Teklif İste'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'İhtiyacınızı kısaca yazın',
            hintText: 'Örn: Haftada 2 gün LGS matematik dersi',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              final note = controller.text.trim();
              if (note.isEmpty) return;
              context.read<AppState>().requestOffer(p.id, note);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Teklif talebiniz gönderildi. '
                        'Teklifler sekmesinden takip edebilirsiniz.')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _toggleCompare(ProviderProfile p) {
    final ok = context.read<AppState>().toggleCompare(p.id);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('En fazla 3 ilan karşılaştırabilirsiniz.')),
      );
    }
  }

  void _openDetail(ProviderProfile p) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ProviderDetailScreen(providerId: p.id)),
    );
  }

  // ---------- Narrow-layout filter sheet ----------

  Future<void> _openFilters(BuildContext context) async {
    final app = context.read<AppState>();
    var type = app.filterType;
    var city = app.filterCity;
    var maxPrice = app.filterMaxPrice;
    var minRating = app.filterMinRating;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtrele', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text('Tür'),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tümü'),
                    selected: type == null,
                    onSelected: (_) => setSheet(() => type = null),
                  ),
                  for (final t in ProviderType.values)
                    ChoiceChip(
                      label: Text(t.labelTr),
                      selected: type == t,
                      onSelected: (_) => setSheet(() => type = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Şehir'),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tümü'),
                    selected: city == null,
                    onSelected: (_) => setSheet(() => city = null),
                  ),
                  for (final c in app.cities)
                    ChoiceChip(
                      label: Text(c),
                      selected: city == c,
                      onSelected: (_) => setSheet(() => city = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text('En yüksek aylık ücret: '
                  '${maxPrice == null ? 'Sınırsız' : formatPrice(maxPrice!)}'),
              Slider(
                value: (maxPrice ?? 30000).clamp(1000, 30000),
                min: 1000,
                max: 30000,
                divisions: 29,
                onChanged: (v) =>
                    setSheet(() => maxPrice = v >= 30000 ? null : v),
              ),
              Text('En düşük puan: '
                  '${minRating == 0 ? 'Farketmez' : minRating.toStringAsFixed(1)}'),
              Slider(
                value: minRating,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: (v) => setSheet(() => minRating = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      app.setFilters(clear: true);
                      Navigator.pop(sheetCtx);
                    },
                    child: const Text('Temizle'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      app.setFilters(
                        type: type,
                        city: city,
                        maxPrice: maxPrice,
                        minRating: minRating,
                      );
                      Navigator.pop(sheetCtx);
                    },
                    child: const Text('Uygula'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Build ----------

  static const _sortLabels = ['Önerilen', 'Puan', 'Ücret ↑', 'Ücret ↓'];

  List<ProviderProfile> _sorted(List<ProviderProfile> list) {
    final copy = List.of(list);
    switch (_sort) {
      case 1: // puan
        copy.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      case 2: // ücret artan
        copy.sort((a, b) => a.monthlyPrice.compareTo(b.monthlyPrice));
      case 3: // ücret azalan
        copy.sort((a, b) => b.monthlyPrice.compareTo(a.monthlyPrice));
      default: // önerilen: puan, eşitse yorum sayısı
        copy.sort((a, b) {
          final r = b.avgRating.compareTo(a.avgRating);
          return r != 0
              ? r
              : b.publishedReviews.length.compareTo(a.publishedReviews.length);
        });
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser; // null → guest arriving from landing search
    final canCompare = user == null || user.role.isSeeker;
    final list = _sorted(app.filteredProviders);
    final wide = MediaQuery.of(context).size.width >= 980;

    return wide
        ? _wideLayout(app, list, canCompare)
        : _narrowLayout(app, list, canCompare);
  }

  // ---------- Wide layout (design) ----------

  Widget _wideLayout(
      AppState app, List<ProviderProfile> list, bool canCompare) {
    return Column(
      children: [
        _searchBarRow(app),
        if (canCompare && app.compareIds.isNotEmpty) _compareBar(app),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 60),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 264, child: _sidebar(app)),
                    const SizedBox(width: 40),
                    Expanded(child: _results(app, list, canCompare)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBarRow(AppState app) {
    return Container(
      decoration: const BoxDecoration(
        color: PusulaColors.card,
        border: Border(bottom: BorderSide(color: PusulaColors.border)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: PusulaColors.borderDark),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          size: 18, color: PusulaColors.faint),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: app.setSearch,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Okul, kurs, dershane, öğretmen ara...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                      if (app.searchQuery.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _searchController.clear();
                            app.setSearch('');
                          },
                          child: const Icon(Icons.close,
                              size: 16, color: PusulaColors.faint),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: PusulaColors.borderDark),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: app.filterCity,
                    hint: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: PusulaColors.faint),
                        SizedBox(width: 6),
                        Text('Tüm iller',
                            style: TextStyle(
                                fontSize: 15, color: PusulaColors.body)),
                      ],
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('Tüm iller')),
                      for (final c in app.cities)
                        DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ],
                    style: const TextStyle(
                        fontSize: 15, color: PusulaColors.ink),
                    onChanged: (v) => app.setFilters(
                      type: app.filterType,
                      city: v,
                      maxPrice: app.filterMaxPrice,
                      minRating: app.filterMinRating,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14)),
                onPressed: () => app.setSearch(_searchController.text),
                child: const Text('Ara'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compareBar(AppState app) {
    return Container(
      color: PusulaColors.surface,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    'Karşılaştırma listesinde ${app.compareIds.length} ilan var'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Karşılaştır'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CompareScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Sidebar ----------

  Widget _sidebar(AppState app) {
    final config = app.configFor(app.filterType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Filtreler',
                  style: pusulaHeading(fontSize: 16, letterSpacingFactor: 0)),
            ),
            InkWell(
              onTap: () {
                // Keep the type (this is the type's own page); reset the rest.
                final type = app.filterType;
                if (type != null) app.clearFacets(type: type);
                app.setFilters(type: type);
                setState(() => _sort = 0);
              },
              child: const Text('Temizle',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (config == null)
          _section(
            'Tür',
            [
              _radioRow('Tümü', app.filterType == null,
                  () => _setType(app, null),
                  count: app.filteredProviders.length),
              for (final t in ProviderType.values)
                _radioRow(t.labelTr, app.filterType == t,
                    () => _setType(app, t),
                    count: app.providers
                        .where((p) =>
                            p.type == t &&
                            p.status == ListingStatus.published)
                        .length),
            ],
          )
        else
          for (final section in config.sections.where((s) => s.active))
            _facetSection(app, config.type, section),
        _section(
          'Aylık ücret',
          [
            Row(
              children: [
                const Expanded(child: SizedBox()),
                Text(
                  app.filterMaxPrice == null
                      ? 'Sınırsız'
                      : '${formatPrice(app.filterMaxPrice!)} ve altı',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.primaryDark),
                ),
              ],
            ),
            Slider(
              value: (app.filterMaxPrice ?? 30000).clamp(1000, 30000),
              min: 1000,
              max: 30000,
              divisions: 29,
              onChanged: (v) => app.setFilters(
                type: app.filterType,
                city: app.filterCity,
                maxPrice: v >= 30000 ? null : v,
                minRating: app.filterMinRating,
              ),
            ),
            const Row(
              children: [
                Text('₺1.000',
                    style:
                        TextStyle(fontSize: 12, color: PusulaColors.faint)),
                Expanded(child: SizedBox()),
                Text('₺30.000+',
                    style:
                        TextStyle(fontSize: 12, color: PusulaColors.faint)),
              ],
            ),
          ],
        ),
        _section(
          'Şehir',
          [
            _radioRow('Tümü', app.filterCity == null,
                () => _setCity(app, null)),
            for (final c in app.cities)
              _radioRow(c, app.filterCity == c, () => _setCity(app, c)),
          ],
        ),
        _section(
          'En az puan',
          [
            Row(
              children: [
                for (var i = 0; i < _ratingSteps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _ratingPill(app, i)),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _setType(AppState app, ProviderType? t) => app.setFilters(
        type: t,
        city: app.filterCity,
        maxPrice: app.filterMaxPrice,
        minRating: app.filterMinRating,
      );

  void _setCity(AppState app, String? c) => app.setFilters(
        type: app.filterType,
        city: c,
        maxPrice: app.filterMaxPrice,
        minRating: app.filterMinRating,
      );

  void _setRating(AppState app, double r) => app.setFilters(
        type: app.filterType,
        city: app.filterCity,
        maxPrice: app.filterMaxPrice,
        minRating: r,
      );

  /// Renders one admin-configured filter section by its kind.
  Widget _facetSection(AppState app, ProviderType type, FilterSection s) {
    final selected = app.facetSelection(type, s.id);

    switch (s.kind) {
      case FilterKind.checkbox:
        return _section(s.title, [
          for (final o in s.options)
            _checkRow(o, selected.contains(o),
                () => app.toggleFacet(type, s, o)),
        ]);
      case FilterKind.radio:
        return _section(s.title, [
          _radioRow('Tümü', selected.isEmpty, () {
            for (final o in Set.of(selected)) {
              app.toggleFacet(type, s, o);
            }
          }),
          for (final o in s.options)
            _radioRow(o, selected.contains(o), () {
              if (!selected.contains(o)) app.toggleFacet(type, s, o);
            }),
        ]);
      case FilterKind.pills:
        return _section(s.title, [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in s.options)
                _facetPill(o, selected.contains(o),
                    () => app.toggleFacet(type, s, o)),
            ],
          ),
        ]);
    }
  }

  Widget _checkRow(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? PusulaColors.primary : Colors.white,
                border: Border.all(
                    color: selected
                        ? PusulaColors.primary
                        : const Color(0xFFC6C2B9)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: PusulaColors.slate)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _facetPill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : PusulaColors.card,
          border: Border.all(
              color: selected
                  ? PusulaColors.primary
                  : PusulaColors.borderDark),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? PusulaColors.primaryDark : PusulaColors.body,
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PusulaColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _radioRow(String label, bool selected, VoidCallback onTap,
      {int? count}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: selected
                      ? PusulaColors.primary
                      : const Color(0xFFC6C2B9),
                  width: selected ? 5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: PusulaColors.slate)),
            ),
            if (count != null)
              Text('$count',
                  style: const TextStyle(
                      fontSize: 12, color: PusulaColors.faint)),
          ],
        ),
      ),
    );
  }

  Widget _ratingPill(AppState app, int i) {
    final selected = app.filterMinRating == _ratingSteps[i];
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => _setRating(app, _ratingSteps[i]),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : PusulaColors.card,
          border: Border.all(
              color: selected
                  ? PusulaColors.primary
                  : PusulaColors.borderDark),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          _ratingLabels[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? PusulaColors.primaryDark : PusulaColors.body,
          ),
        ),
      ),
    );
  }

  // ---------- Results column ----------

  String _resultsTitle(AppState app) {
    final type = app.filterType;
    final city = app.filterCity;
    if (type == null && city == null) return 'Tüm ilanlar';
    final what = type == null ? 'ilanlar' : '${type.labelTr} ilanları';
    return city == null ? what : "$city'de $what";
  }

  Widget _results(AppState app, List<ProviderProfile> list, bool canCompare) {
    final chips = _activeChips(app);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_resultsTitle(app),
                      style: pusulaHeading(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${list.length} sonuç bulundu',
                      style: const TextStyle(
                          fontSize: 14, color: PusulaColors.muted)),
                ],
              ),
            ),
            const Text('Sırala:',
                style: TextStyle(fontSize: 13, color: PusulaColors.muted)),
            const SizedBox(width: 10),
            for (var i = 0; i < _sortLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _sortPill(_sortLabels[i], i),
            ],
          ],
        ),
        if (chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(spacing: 8, runSpacing: 8, children: chips),
          ),
        const SizedBox(height: 20),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
                child: Text(
                    'Sonuç bulunamadı. Filtreleri gevşetmeyi deneyin.')),
          )
        else
          for (final p in list) ...[
            _resultCard(app, p, canCompare),
            const SizedBox(height: 20),
          ],
      ],
    );
  }

  Widget _sortPill(String label, int i) {
    final selected = _sort == i;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => setState(() => _sort = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : PusulaColors.card,
          border: Border.all(
              color: selected
                  ? PusulaColors.primary
                  : PusulaColors.borderDark),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? PusulaColors.primaryDark : PusulaColors.body,
          ),
        ),
      ),
    );
  }

  List<Widget> _activeChips(AppState app) {
    Widget chip(String label, VoidCallback onRemove) {
      return InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: PusulaColors.primarySoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text('$label ✕',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PusulaColors.primaryDark)),
        ),
      );
    }

    final config = app.configFor(app.filterType);
    return [
      if (app.filterType != null)
        chip(app.filterType!.labelTr, () => _setType(app, null)),
      if (config != null)
        for (final section in config.sections.where((s) => s.active))
          for (final option in app.facetSelection(config.type, section.id))
            chip(option, () => app.toggleFacet(config.type, section, option)),
      if (app.filterCity != null)
        chip(app.filterCity!, () => _setCity(app, null)),
      if (app.filterMaxPrice != null)
        chip('≤ ${formatPrice(app.filterMaxPrice!)}',
            () => app.setFilters(
                  type: app.filterType,
                  city: app.filterCity,
                  maxPrice: null,
                  minRating: app.filterMinRating,
                )),
      if (app.filterMinRating > 0)
        chip('★ ${app.filterMinRating.toStringAsFixed(1)}+',
            () => _setRating(app, 0)),
    ];
  }

  Widget _resultCard(AppState app, ProviderProfile p, bool canCompare) {
    final inCompare = app.isInCompare(p.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openDetail(p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PusulaColors.card,
          border: Border.all(color: PusulaColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // photo
            SizedBox(
              width: 220,
              height: 156,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: p.photoUrls.isEmpty
                        ? Container(
                            width: 220,
                            height: 156,
                            color: PusulaColors.patternA,
                            alignment: Alignment.center,
                            child: const Icon(Icons.school_outlined,
                                color: PusulaColors.faint, size: 32),
                          )
                        : NetworkPhoto(
                            url: p.photoUrls.first, width: 220, height: 156),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: PusulaColors.primarySoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('✓ Doğrulanmış',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: PusulaColors.primaryDark)),
                    ),
                  ),
                  if (p.videoUrl != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
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
            ),
            const SizedBox(width: 20),
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            style: pusulaHeading(
                                fontSize: 18,
                                height: 1.3,
                                letterSpacingFactor: -0.01)),
                      ),
                      const SizedBox(width: 14),
                      Text.rich(
                        TextSpan(
                          text:
                              '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)} ',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                          children: [
                            TextSpan(
                              text: '(${p.publishedReviews.length})',
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
                  Text('${p.type.labelTr} · ${p.city}',
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.muted)),
                  const SizedBox(height: 8),
                  if (p.features.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final f in p.features.take(3))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 4),
                            decoration: BoxDecoration(
                              color: PusulaColors.surface,
                              border:
                                  Border.all(color: PusulaColors.border),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(f,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: PusulaColors.slate)),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        color: PusulaColors.body,
                        height: 1.55),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Color(0xFFF1EFEA))),
                    ),
                    child: Row(
                      children: [
                        Text(formatPrice(p.monthlyPrice),
                            style: pusulaHeading(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 5),
                        const Text('/ay başlangıç',
                            style: TextStyle(
                                fontSize: 13, color: PusulaColors.faint)),
                        const Spacer(),
                        if (canCompare)
                          TextButton(
                            onPressed: () => _toggleCompare(p),
                            style: TextButton.styleFrom(
                              foregroundColor: inCompare
                                  ? PusulaColors.primary
                                  : PusulaColors.body,
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            child: Text(inCompare
                                ? '✓ Karşılaştır'
                                : '+ Karşılaştır'),
                          ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _messageOwner(p),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Mesaj'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _requestOffer(p),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Teklif iste'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Narrow layout (previous compact list) ----------

  Widget _narrowLayout(
      AppState app, List<ProviderProfile> list, bool canCompare) {
    final hasFilter = app.filterType != null ||
        app.filterCity != null ||
        app.filterMaxPrice != null ||
        app.filterMinRating > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Okul, kurs, öğretmen ara...',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: app.searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Temizle',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              app.setSearch('');
                            },
                          ),
                  ),
                  onChanged: app.setSearch,
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: hasFilter,
                child: IconButton.filledTonal(
                  tooltip: 'Filtrele',
                  icon: const Icon(Icons.tune),
                  onPressed: () => _openFilters(context),
                ),
              ),
            ],
          ),
        ),
        if (canCompare && app.compareIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                      'Karşılaştırma listesinde ${app.compareIds.length} ilan var'),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Karşılaştır'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CompareScreen()),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                      'Sonuç bulunamadı. Filtreleri gevşetmeyi deneyin.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _ProviderCard(
                      provider: list[i], showCompare: canCompare),
                ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, required this.showCompare});

  final ProviderProfile provider;
  final bool showCompare;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final inCompare = app.isInCompare(provider.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(providerId: provider.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.photoUrls.isNotEmpty)
              Stack(
                children: [
                  NetworkPhoto(
                      url: provider.photoUrls.first,
                      height: 160,
                      width: double.infinity),
                  if (provider.videoUrl != null)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Tanıtım Videosu',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(provider.name,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      TypeBadge(type: provider.type),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      Text(provider.city,
                          style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Text('${formatPrice(provider.monthlyPrice)}/ay',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: provider.avgRating),
                      Text(' (${provider.publishedReviews.length} yorum)',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      if (showCompare)
                        TextButton.icon(
                          icon: Icon(inCompare
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                          label: const Text('Karşılaştır'),
                          onPressed: () {
                            final ok = context
                                .read<AppState>()
                                .toggleCompare(provider.id);
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'En fazla 3 ilan karşılaştırabilirsiniz.')),
                              );
                            }
                          },
                        ),
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
}

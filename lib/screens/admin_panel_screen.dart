import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import 'landing_screen.dart';

/// Admin panel from the "Admin Panel" Claude Design file: dark sidebar with
/// six views — dashboard, filter management, listings, users, reviews and
/// job postings. All actions operate on the live in-memory AppState.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

// Design tokens specific to the dark admin sidebar.
const _sideBg = Color(0xFF1A222C);
const _sideMuted = Color(0xFFA9B2BC);
const _sideFaint = Color(0xFF6B7683);
const _accent = Color(0xFF5FD3B4);
const _warnText = Color(0xFF8A6212);
const _warnBg = Color(0xFFFBF1DF);
const _errText = Color(0xFFB4423A);
const _errBg = Color(0xFFFBF0EF);

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _view = 0;
  int _catTab = 0;
  final Map<String, TextEditingController> _optionDrafts = {};

  static const _navItems = [
    ('◧', 'Genel bakış'),
    ('≔', 'Filtre yönetimi'),
    ('▤', 'İlanlar'),
    ('◉', 'Kullanıcılar'),
    ('✎', 'Yorumlar'),
    ('⚑', 'İş ilanları'),
  ];

  static const _catTypes = [
    ProviderType.privateSchool,
    ProviderType.course,
    ProviderType.dershane,
    ProviderType.privateTeacher,
  ];

  @override
  void dispose() {
    for (final c in _optionDrafts.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _draftFor(String key) =>
      _optionDrafts.putIfAbsent(key, TextEditingController.new);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final wide = MediaQuery.of(context).size.width >= 980;

    final views = [
      _dashboard(app),
      _filterManagement(app),
      _listings(app),
      _users(app),
      _reviews(app),
      _jobs(app),
    ];

    return Scaffold(
      backgroundColor: PusulaColors.surface,
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 232, child: _sidebar(app, vertical: true)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(36, 28, 36, 60),
                    child: views[_view],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _sidebar(app, vertical: false),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    child: views[_view],
                  ),
                ),
              ],
            ),
    );
  }

  // ---------- Sidebar ----------

  Widget _sidebar(AppState app, {required bool vertical}) {
    final user = app.currentUser;
    final initials = (user?.name ?? 'A')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final pendingCount = app.pendingListings.length;

    Widget navButton(int i) {
      final selected = _view == i;
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _view = i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _accent.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: vertical ? MainAxisSize.max : MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                child: Text(_navItems[i].$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: selected ? _accent : _sideMuted)),
              ),
              const SizedBox(width: 10),
              Text(_navItems[i].$2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? _accent : _sideMuted,
                  )),
              if (i == 0 && pendingCount > 0) ...[
                if (vertical) const Spacer() else const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0A43B),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('$pendingCount',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _sideBg)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final logo = Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accent, width: 2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 7,
              height: 7,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: _accent),
            ),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pusula Eğitim',
                  style: pusulaHeading(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacingFactor: 0)),
              const Text('YÖNETİM PANELİ',
                  style: TextStyle(
                      fontSize: 10, letterSpacing: 0.8, color: _sideFaint)),
            ],
          ),
        ],
      ),
    );

    final footer = Container(
      padding: const EdgeInsets.only(top: 14, left: 10),
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: PusulaColors.primary,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const Text('Süper admin',
                        style: TextStyle(fontSize: 11, color: _sideFaint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (_) => false,
                ),
                style: TextButton.styleFrom(foregroundColor: _sideMuted),
                icon: const Icon(Icons.home_outlined, size: 16),
                label: const Text('Site', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () {
                  context.read<AppState>().signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LandingScreen()),
                    (_) => false,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: _sideMuted),
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Çıkış', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );

    if (!vertical) {
      return Container(
        color: _sideBg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < _navItems.length; i++) ...[
              navButton(i),
              const SizedBox(width: 2),
            ],
          ]),
        ),
      );
    }

    return Container(
      color: _sideBg,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          logo,
          for (var i = 0; i < _navItems.length; i++) ...[
            navButton(i),
            const SizedBox(height: 2),
          ],
          const Spacer(),
          footer,
        ],
      ),
    );
  }

  // ---------- Shared bits ----------

  Widget _pageHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: pusulaHeading(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 14, color: PusulaColors.muted)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PusulaColors.card,
        border: Border.all(color: PusulaColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  /// Status chip: ok (green), warn (amber), err (red).
  Widget _chip(String label, String kind) {
    final (fg, bg) = switch (kind) {
      'ok' => (PusulaColors.primaryDark, PusulaColors.primarySoft),
      'warn' => (_warnText, _warnBg),
      _ => (_errText, _errBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _smallActionButton(String label, VoidCallback onTap,
      {bool primary = false, bool danger = false}) {
    if (primary) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: danger ? _errText : PusulaColors.body,
        side: BorderSide(
            color: danger ? const Color(0xFFE5C9C6) : PusulaColors.borderDark),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }

  // ---------- 1. Genel bakış ----------

  Widget _dashboard(AppState app) {
    final pending = app.pendingListings;
    final stats = [
      ('Toplam ilan', '${app.providers.length}', '▲ canlı veri', 'ok'),
      ('Kayıtlı kullanıcı', '${app.users.length}', '▲ canlı veri', 'ok'),
      ('Teklif isteği', '${app.offers.length}', '▲ tüm zamanlar', 'ok'),
      ('Bekleyen onay', '${pending.length}', 'işlem gerekli', 'warn'),
    ];

    // Recent activity synthesized from real data, newest first.
    final activity = <(DateTime, String)>[
      for (final p in app.providers)
        for (final r in p.reviews)
          (r.date, '${r.authorName}, ${p.name} için ★${r.stars} yorum yazdı'),
      for (final j in app.jobs)
        (j.createdAt, '${j.institutionName} iş ilanı açtı: ${j.title}'),
      for (final o in app.offers)
        (o.createdAt, 'Yeni teklif isteği: ${app.providerById(o.providerId)?.name ?? ''}'),
      for (final p in pending) (DateTime(2026, 7, 15), '${p.name} kaydı onay bekliyor'),
    ]..sort((a, b) => b.$1.compareTo(a.$1));

    final wide = MediaQuery.of(context).size.width >= 1240;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader('Genel bakış', '16 Temmuz 2026 · Canlı platform verileri'),
        // Stat cards
        LayoutBuilder(builder: (ctx, c) {
          final cols = wide || c.maxWidth >= 700 ? 4 : 2;
          final w = (c.maxWidth - (cols - 1) * 16) / cols;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final (label, value, delta, kind) in stats)
                SizedBox(
                  width: w,
                  child: _card(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 13, color: PusulaColors.muted)),
                        const SizedBox(height: 8),
                        Text(value,
                            style: pusulaHeading(
                                fontSize: 26, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(delta,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kind == 'warn'
                                    ? _warnText
                                    : PusulaColors.primaryDark)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 28),
        // Pending approvals
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Onay bekleyen ilanlar',
                        style: pusulaHeading(
                            fontSize: 16, letterSpacingFactor: 0)),
                  ),
                  Text('${pending.length} bekliyor',
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.muted)),
                ],
              ),
              const SizedBox(height: 4),
              if (pending.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Bekleyen ilan yok. 🎉',
                      style: TextStyle(color: PusulaColors.body)),
                ),
              for (final p in pending)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Color(0xFFF1EFEA))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${p.type.labelTr} · ${p.city}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: PusulaColors.faint)),
                          ],
                        ),
                      ),
                      _chip(p.status.labelTr, 'warn'),
                      const SizedBox(width: 12),
                      _smallActionButton(
                          'Onayla',
                          () => app.setListingStatus(
                              p, ListingStatus.published),
                          primary: true),
                      const SizedBox(width: 8),
                      _smallActionButton(
                          'Reddet',
                          () =>
                              app.setListingStatus(p, ListingStatus.rejected),
                          danger: true),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Activity
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Son etkinlikler',
                  style: pusulaHeading(fontSize: 16, letterSpacingFactor: 0)),
              const SizedBox(height: 8),
              for (final (date, text) in activity.take(6))
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Color(0xFFF1EFEA))),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 78,
                        child: Text(formatDate(date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: PusulaColors.faint)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(text,
                            style: const TextStyle(
                                fontSize: 14,
                                color: PusulaColors.slate,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 2. Filtre yönetimi ----------

  Widget _filterManagement(AppState app) {
    final type = _catTypes[_catTab];
    final config = app.configFor(type)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(
            'Filtre yönetimi',
            'Arama sayfalarında görünen filtre gruplarını ve seçenekleri '
                'düzenleyin. Değişiklikler anında yayına alınır.'),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < _catTypes.length; i++)
              _catPill(_catTypes[i].labelTr, i),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (ctx, c) {
          final two = c.maxWidth >= 760;
          final w = two ? (c.maxWidth - 20) / 2 : c.maxWidth;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for (final section in config.sections)
                SizedBox(width: w, child: _filterGroupCard(app, type, section)),
              SizedBox(width: w, child: _addSectionCard(app, type)),
            ],
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: PusulaColors.primarySoft,
            border: Border.all(color: const Color(0xFFCFE6DD)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pasif gruplar arama sayfasında gizlenir; seçenekleri '
                  'silinmez. Bir seçeneği kaldırmak mevcut ilanları etkilemez, '
                  'yalnızca filtre listesinden çıkarır.',
                  style: TextStyle(
                      fontSize: 13,
                      color: PusulaColors.primaryDark,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _catPill(String label, int i) {
    final selected = _catTab == i;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => setState(() => _catTab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : PusulaColors.card,
          border: Border.all(
              color:
                  selected ? PusulaColors.primary : PusulaColors.borderDark),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? PusulaColors.primaryDark : PusulaColors.body,
            )),
      ),
    );
  }

  Widget _filterGroupCard(
      AppState app, ProviderType type, FilterSection section) {
    final draftKey = '${type.name}:${section.id}';
    final controller = _draftFor(draftKey);

    void addOption() {
      app.addFilterOption(type, section.id, controller.text);
      controller.clear();
    }

    return _card(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(section.title,
                    style:
                        pusulaHeading(fontSize: 16, letterSpacingFactor: 0)),
              ),
              // Active toggle — 40×22 pill switch from the design.
              _DesignSwitch(
                value: section.active,
                onTap: () => app.toggleFilterSectionActive(type, section.id),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Grubu sil',
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: PusulaColors.faint),
                onPressed: () => app.removeFilterSection(type, section.id),
              ),
            ],
          ),
          Text(
            '${section.kind.labelTr}${section.active ? '' : ' · şu an gizli'}',
            style: const TextStyle(fontSize: 12, color: PusulaColors.faint),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in section.options)
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
                  decoration: BoxDecoration(
                    color: PusulaColors.surface,
                    border: Border.all(color: PusulaColors.border),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(option,
                          style: const TextStyle(
                              fontSize: 13, color: PusulaColors.slate)),
                      const SizedBox(width: 8),
                      _OptionDeleteButton(
                        onTap: () =>
                            app.removeFilterOption(type, section.id, option),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => addOption(),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Yeni seçenek ekle…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide:
                          const BorderSide(color: PusulaColors.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                          color: PusulaColors.primary, width: 1.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: addOption,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('+ Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addSectionCard(AppState app, ProviderType type) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showAddSectionDialog(app, type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          border: Border.all(color: PusulaColors.borderDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline,
                color: PusulaColors.primary, size: 28),
            SizedBox(height: 8),
            Text('Yeni filtre grubu ekle',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PusulaColors.primary)),
            SizedBox(height: 4),
            Text('Başlık, tür ve seçenekleriyle yeni bir grup oluşturun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: PusulaColors.faint)),
          ],
        ),
      ),
    );
  }

  void _showAddSectionDialog(AppState app, ProviderType type) {
    final titleController = TextEditingController();
    final optionsController = TextEditingController();
    var kind = FilterKind.checkbox;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text('${type.labelTr} · Yeni filtre grubu'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: 'Grup başlığı', hintText: 'Örn. Müfredat türü'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<FilterKind>(
                  initialValue: kind,
                  decoration:
                      const InputDecoration(labelText: 'Seçim türü'),
                  items: [
                    for (final k in FilterKind.values)
                      DropdownMenuItem(value: k, child: Text(k.labelTr)),
                  ],
                  onChanged: (v) => setDlg(() => kind = v ?? kind),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Seçenekler (virgülle ayırın)',
                    hintText: 'MEB, IB, Cambridge, Montessori',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () {
                app.addFilterSection(
                  type,
                  title: titleController.text,
                  kind: kind,
                  options: optionsController.text.split(','),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Grubu ekle'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 3. İlanlar ----------

  Widget _listings(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader('İlan yönetimi',
            'Tüm kategorilerdeki ilanları görüntüleyin, durumlarını değiştirin.'),
        _card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tableHeader(
                  const ['İLAN', 'KATEGORİ', 'PUAN', 'DURUM', 'İŞLEM']),
              for (final p in app.providers)
                _tableRow([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(p.city,
                          style: const TextStyle(
                              fontSize: 12, color: PusulaColors.faint)),
                    ],
                  ),
                  Text(p.type.labelTr,
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.body)),
                  Text(
                      '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 13)),
                  _chip(
                      p.status.labelTr,
                      switch (p.status) {
                        ListingStatus.published => 'ok',
                        ListingStatus.pending => 'warn',
                        _ => 'err',
                      }),
                  Align(
                    alignment: Alignment.centerRight,
                    child: p.status == ListingStatus.published
                        ? _smallActionButton(
                            'Askıya al',
                            () => app.setListingStatus(
                                p, ListingStatus.suspended))
                        : _smallActionButton(
                            'Yayınla',
                            () => app.setListingStatus(
                                p, ListingStatus.published),
                            primary: true),
                  ),
                ]),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 4. Kullanıcılar ----------

  Widget _users(AppState app) {
    final counts = <UserRole, int>{};
    for (final u in app.users) {
      counts[u.role] = (counts[u.role] ?? 0) + 1;
    }
    final seekers = (counts[UserRole.parent] ?? 0) +
        (counts[UserRole.student] ?? 0);

    Color avatarColor(UserRole role) => switch (role) {
          UserRole.parent || UserRole.student => const Color(0xFF8A6212),
          UserRole.teacher => const Color(0xFF3A46A0),
          UserRole.institution => const Color(0xFF8A2E63),
          UserRole.admin => PusulaColors.primary,
        };

    (Color, Color) roleChipColors(UserRole role) => switch (role) {
          UserRole.parent ||
          UserRole.student =>
            (const Color(0xFF3A46A0), const Color(0xFFEEF0FB)),
          UserRole.teacher =>
            (PusulaColors.primaryDark, PusulaColors.primarySoft),
          UserRole.institution =>
            (const Color(0xFF8A2E63), const Color(0xFFF7EAF1)),
          UserRole.admin => (PusulaColors.ink, PusulaColors.surface),
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(
            'Kullanıcılar',
            '${app.users.length} kayıtlı kullanıcı · $seekers veli/öğrenci · '
                '${counts[UserRole.teacher] ?? 0} öğretmen · '
                '${counts[UserRole.institution] ?? 0} kurum'),
        _card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tableHeader(
                  const ['KULLANICI', 'ROL', 'ŞEHİR', 'DURUM', 'İŞLEM']),
              for (final u in app.users.where((u) => u.role != UserRole.admin))
                _tableRow([
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: avatarColor(u.role),
                        child: Text(
                          u.name
                              .split(RegExp(r'\s+'))
                              .where((w) => w.isNotEmpty)
                              .take(2)
                              .map((w) => w[0].toUpperCase())
                              .join(),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Builder(builder: (_) {
                    final (fg, bg) = roleChipColors(u.role);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(u.role.labelTr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: fg)),
                    );
                  }),
                  Text(u.city.isEmpty ? '—' : u.city,
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.body)),
                  _chip(u.suspended ? 'Askıda' : 'Aktif',
                      u.suspended ? 'err' : 'ok'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: u.suspended
                        ? _smallActionButton('Aktifleştir',
                            () => app.setUserSuspended(u, false),
                            primary: true)
                        : _smallActionButton('Askıya al',
                            () => app.setUserSuspended(u, true)),
                  ),
                ]),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 5. Yorumlar ----------

  Widget _reviews(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader('Yorum moderasyonu',
            'Bildirilen ve onay bekleyen değerlendirmeler.'),
        for (final (provider, review) in app.moderationQueue.take(12))
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _card(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: review.authorName,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: ' → ${provider.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: PusulaColors.faint),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text('★ ${review.stars}.0',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      _chip(
                          review.status.labelTr,
                          switch (review.status) {
                            ReviewStatus.published => 'ok',
                            ReviewStatus.pending => 'warn',
                            _ => 'err',
                          }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment,
                      style: const TextStyle(
                          fontSize: 14,
                          color: PusulaColors.slate,
                          height: 1.65)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (review.status != ReviewStatus.published)
                        _smallActionButton(
                            'Yayınla',
                            () => app.setReviewStatus(
                                review, ReviewStatus.published),
                            primary: true)
                      else
                        _smallActionButton('✓ Yayında', () {}),
                      const SizedBox(width: 8),
                      if (review.status != ReviewStatus.removed)
                        _smallActionButton(
                            'Kaldır',
                            () => app.setReviewStatus(
                                review, ReviewStatus.removed),
                            danger: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ---------- 6. İş ilanları ----------

  Widget _jobs(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader('İş ilanları (kapalı ağ)',
            'Kurumların açtığı öğretmen iş ilanları — yalnızca öğretmenlere görünür.'),
        _card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tableHeader(
                  const ['POZİSYON', 'KURUM', 'BAŞVURU', 'DURUM', 'İŞLEM']),
              for (final j in app.jobs)
                _tableRow([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${j.subject} · ${j.city}',
                          style: const TextStyle(
                              fontSize: 12, color: PusulaColors.faint)),
                    ],
                  ),
                  Text(j.institutionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.body)),
                  Text('${j.applicantUserIds.length} başvuru',
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.body)),
                  _chip(j.active ? 'Yayında' : 'Kapalı',
                      j.active ? 'ok' : 'err'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: j.active
                        ? _smallActionButton(
                            'Kapat', () => app.setJobActive(j, false))
                        : _smallActionButton(
                            'Yayınla', () => app.setJobActive(j, true),
                            primary: true),
                  ),
                ]),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Table helpers ----------

  static const _tableFlex = [20, 10, 8, 8, 10];

  Widget _tableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: PusulaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              flex: _tableFlex[i],
              child: Text(labels[i],
                  textAlign: i == labels.length - 1
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: PusulaColors.muted)),
            ),
        ],
      ),
    );
  }

  Widget _tableRow(List<Widget> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1EFEA))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: _tableFlex[i],
              child: Align(
                alignment: Alignment.centerLeft,
                child: cells[i],
              ),
            ),
        ],
      ),
    );
  }
}

/// 40×22 pill toggle from the design (on: green, off: grey; animated knob).
class _DesignSwitch extends StatelessWidget {
  const _DesignSwitch({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 22,
          decoration: BoxDecoration(
            color: value ? PusulaColors.primary : PusulaColors.borderDark,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✕ delete button on a filter option pill: grey circle, red on hover.
class _OptionDeleteButton extends StatefulWidget {
  const _OptionDeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_OptionDeleteButton> createState() => _OptionDeleteButtonState();
}

class _OptionDeleteButtonState extends State<_OptionDeleteButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Seçeneği kaldır',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _hovered ? _errText : PusulaColors.border,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('✕',
                style: TextStyle(
                    fontSize: 10,
                    color: _hovered ? Colors.white : PusulaColors.muted)),
          ),
        ),
      ),
    );
  }
}

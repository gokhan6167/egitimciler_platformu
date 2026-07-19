import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/iller.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import 'messages_screen.dart';

/// "Arama - Ogrenci Ilanlari" — closed network: only teachers browse
/// lesson requests; parents/students manage their own from the panel.
class StudentListingsScreen extends StatefulWidget {
  const StudentListingsScreen({super.key});

  @override
  State<StudentListingsScreen> createState() => _StudentListingsScreenState();
}

class _StudentListingsScreenState extends State<StudentListingsScreen> {
  bool _showFilters = false;
  bool _urgentOnly = false;
  final Set<String> _subjects = {};
  final Set<String> _levels = {};
  String? _place;

  static const _levelOptions = [
    'İlkokul (1–4)',
    'Ortaokul (5–8)',
    'Lise (9–12)',
    'LGS / YKS hazırlık',
  ];
  static const _placeOptions = ['Evde ders', 'Online', 'Fark etmez'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;
    if (me == null || !(me.role == UserRole.teacher || me.role == UserRole.admin)) {
      return _closedNetworkNotice();
    }

    var results = app.filteredStudentListings;
    if (_urgentOnly) results = results.where((l) => l.startNow).toList();
    if (_subjects.isNotEmpty) {
      results = results.where((l) => _subjects.contains(l.subject)).toList();
    }
    if (_levels.isNotEmpty) {
      results = results
          .where((l) => _levels.any((lv) => _levelMatches(lv, l.level)))
          .toList();
    }
    if (_place != null && _place != 'Fark etmez') {
      results = results
          .where((l) => l.mode == _place || l.mode == 'Fark etmez')
          .toList();
    }

    final wide = MediaQuery.of(context).size.width > 980;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PusulaColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✓ Öğrenci ve veliler ücretsiz ilan verir; iletişim '
                  'bilgilerini yalnızca doğrulanmış öğretmen hesapları görür '
                  've teklif yapabilir.',
                  style: TextStyle(
                      fontSize: 13, color: PusulaColors.primaryDark),
                ),
              ),
              const SizedBox(height: 16),
              if (!wide)
                OutlinedButton(
                  onPressed: () =>
                      setState(() => _showFilters = !_showFilters),
                  child: Text(_showFilters
                      ? '☰ Filtreleri gizle'
                      : '☰ Filtreleri göster'),
                ),
              const SizedBox(height: 8),
              wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 264, child: _filterColumn(app)),
                        const SizedBox(width: 24),
                        Expanded(child: _resultColumn(app, results)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showFilters) _filterColumn(app),
                        _resultColumn(app, results),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _levelMatches(String option, String level) {
    final l = level.toLowerCase();
    return switch (option) {
      'İlkokul (1–4)' => RegExp(r'\b([1-4])\. sınıf').hasMatch(l) ||
          l.contains('ilkokul'),
      'Ortaokul (5–8)' => RegExp(r'\b([5-8])\. sınıf').hasMatch(l) ||
          l.contains('ortaokul'),
      'Lise (9–12)' => l.contains('lise') ||
          RegExp(r'\b(9|1[0-2])\. sınıf').hasMatch(l),
      _ => l.contains('lgs') || l.contains('yks'),
    };
  }

  Widget _closedNetworkNotice() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 40, color: PusulaColors.primary),
                const SizedBox(height: 12),
                Text('Kapalı ağ', style: pusulaHeading(fontSize: 20)),
                const SizedBox(height: 8),
                const Text(
                  'Öğrenci ilanlarını yalnızca doğrulanmış öğretmen '
                  'hesapları görebilir. Veli ve öğrenciler kendi ilanlarını '
                  '"İlanlarım" panelinden yönetir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PusulaColors.body, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Filters ----------

  Widget _filterColumn(AppState app) {
    final subjects = app.studentListings.map((l) => l.subject).toSet().toList()
      ..sort();
    final range = app.priceRanges['studentBudget'] ??
        PriceRangeConfig(min: 200, max: 1500, step: 50);
    final budget = (app.studentMaxBudget ?? range.max)
        .clamp(range.min, range.max)
        .toDouble();
    final city = app.studentFilterCity;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filtreler', style: pusulaHeading(fontSize: 16)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _subjects.clear();
                    _levels.clear();
                    _place = null;
                    _urgentOnly = false;
                  });
                  app.clearStudentFilters();
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Kelime ile filtrele',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'ör. LGS matematik, konuşma…',
              isDense: true,
            ),
            onChanged: app.setStudentSearch,
          ),
          const SizedBox(height: 16),
          const Text('İl',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: city,
            decoration: const InputDecoration(isDense: true),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm iller')),
              for (final il in iller)
                DropdownMenuItem(value: il, child: Text(il)),
            ],
            onChanged: app.setStudentCity,
          ),
          if (city != null) ...[
            const SizedBox(height: 12),
            const Text('İlçe · birden fazla seçilebilir',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ilce in ilceler[city] ?? const <String>[])
                  _pill(
                    ilce,
                    app.studentFilterDistricts.contains(ilce),
                    () => app.toggleStudentDistrict(ilce),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text('Ders',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final s in subjects)
            _check(
              '$s (${app.studentListings.where((l) => l.subject == s).length})',
              _subjects.contains(s),
              () => setState(() =>
                  _subjects.contains(s) ? _subjects.remove(s) : _subjects.add(s)),
            ),
          const SizedBox(height: 12),
          const Text('Seviye',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final lv in _levelOptions)
            _check(
              lv,
              _levels.contains(lv),
              () => setState(() =>
                  _levels.contains(lv) ? _levels.remove(lv) : _levels.add(lv)),
            ),
          const SizedBox(height: 12),
          const Text('Dersin yeri',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final d in _placeOptions)
                _pill(d, _place == d,
                    () => setState(() => _place = _place == d ? null : d)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Öğrenci bütçesi (60 dk)',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          Slider(
            value: budget,
            min: range.min,
            max: range.max,
            divisions:
                ((range.max - range.min) / range.step).round().clamp(1, 500),
            label: budget >= range.max
                ? '₺${range.max.toStringAsFixed(0)}+'
                : '₺${budget.toStringAsFixed(0)} ve altı',
            onChanged: (v) =>
                app.setStudentMaxBudget(v >= range.max ? null : v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₺${range.min.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 12, color: PusulaColors.faint)),
              Text('₺${range.max.toStringAsFixed(0)}+',
                  style: const TextStyle(
                      fontSize: 12, color: PusulaColors.faint)),
            ],
          ),
          const SizedBox(height: 8),
          _check('Hemen başlayacaklar', _urgentOnly,
              () => setState(() => _urgentOnly = !_urgentOnly)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() {}),
              child: const Text('Ara'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color:
                  selected ? PusulaColors.primary : PusulaColors.borderDark),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color:
                  selected ? PusulaColors.primaryDark : PusulaColors.body,
            )),
      ),
    );
  }

  Widget _check(String label, bool value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: value ? PusulaColors.primary : PusulaColors.faint,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13.5, color: PusulaColors.body)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Results ----------

  Widget _resultColumn(AppState app, List<StudentListing> results) {
    final chips = <(String, VoidCallback)>[
      if (app.studentSearchQuery.trim().isNotEmpty)
        ('"${app.studentSearchQuery.trim()}"', () => app.setStudentSearch('')),
      if (app.studentFilterCity != null)
        (app.studentFilterCity!, () => app.setStudentCity(null)),
      for (final d in app.studentFilterDistricts)
        (d, () => app.toggleStudentDistrict(d)),
      for (final s in _subjects.toList())
        (s, () => setState(() => _subjects.remove(s))),
      for (final lv in _levels.toList())
        (lv, () => setState(() => _levels.remove(lv))),
      if (_place != null) (_place!, () => setState(() => _place = null)),
      if (app.studentMaxBudget != null)
        (
          '₺${app.studentMaxBudget!.toStringAsFixed(0)} ve altı',
          () => app.setStudentMaxBudget(null)
        ),
      if (_urgentOnly)
        ('Hemen başlayacak', () => setState(() => _urgentOnly = false)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            Text('Ders arayan öğrenciler', style: pusulaHeading(fontSize: 22)),
            Text('${results.length} ilan bulundu',
                style: const TextStyle(
                    fontSize: 13, color: PusulaColors.muted)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            const Text('Sırala:',
                style: TextStyle(fontSize: 13, color: PusulaColors.muted)),
            for (final (key, label) in AppState.studentSortOptions)
              _pill(label, app.studentSortKey == key,
                  () => app.setStudentSort(key)),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (label, onRemove) in chips)
                InputChip(
                  label: Text(label),
                  deleteIcon: const Icon(Icons.close, size: 15),
                  onDeleted: onRemove,
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (results.isEmpty)
          _emptyState(app)
        else
          for (final l in results) _listingCard(app, l),
      ],
    );
  }

  Widget _emptyState(AppState app) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        children: [
          const Text('⌕',
              style: TextStyle(fontSize: 40, color: PusulaColors.faint)),
          const SizedBox(height: 8),
          Text('Bu kriterlere uygun sonuç bulunamadı',
              style: pusulaHeading(fontSize: 18)),
          const SizedBox(height: 6),
          const Text(
            'Kelime filtresini kaldırmayı, bütçeyi artırmayı veya ilçe '
            'seçimini genişletmeyi deneyin.',
            style: TextStyle(fontSize: 13.5, color: PusulaColors.body),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _subjects.clear();
                _levels.clear();
                _place = null;
                _urgentOnly = false;
              });
              app.clearStudentFilters();
            },
            child: const Text('Filtreleri temizle'),
          ),
        ],
      ),
    );
  }

  String _firstName(AppState app, StudentListing l) {
    final owner = app.userById(l.ownerUserId);
    return owner == null ? 'Öğrenci' : owner.name.split(' ').first;
  }

  Widget _listingCard(AppState app, StudentListing l) {
    final me = app.currentUser!;
    final bidCount = app.bidsFor(l.id).length;
    final myBid = app.bidsFor(l.id).where((b) => b.teacherUserId == me.id);
    final name = _firstName(app, l);
    final initials =
        name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: PusulaColors.primarySoft,
                child: Text(initials,
                    style: const TextStyle(
                        color: PusulaColors.primaryDark,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text('$name ✓', style: pusulaHeading(fontSize: 16)),
                        Text(l.level,
                            style: const TextStyle(
                                fontSize: 13, color: PusulaColors.muted)),
                        if (l.startNow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF1DF),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text('Hemen başlayacak',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8A6212))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l.subject} · ${l.district.isNotEmpty ? '${l.district}, ' : ''}${l.city} · ${l.schedule} · ${l.mode}',
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.body),
                    ),
                  ],
                ),
              ),
              Text('$bidCount teklif',
                  style: const TextStyle(
                      fontSize: 12.5, color: PusulaColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(l.title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(l.description,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.5, color: PusulaColors.body)),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '₺${l.budget.toStringAsFixed(0)}',
                    style: pusulaHeading(fontSize: 18)),
                const TextSpan(
                    text: ' /ders bütçe',
                    style: TextStyle(
                        fontSize: 12.5, color: PusulaColors.muted)),
              ])),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  final conv = app.conversationWith(l.ownerUserId);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(conversationId: conv.id)));
                },
                child: const Text('Mesaj'),
              ),
              myBid.isEmpty
                  ? FilledButton(
                      onPressed: () => _openBidDialog(app, l),
                      child: const Text('Teklif ver'),
                    )
                  : OutlinedButton(
                      onPressed: null,
                      child: Text(switch (myBid.first.status) {
                        BidStatus.accepted => '✓ Kabul edildi',
                        BidStatus.rejected => 'Reddedildi',
                        _ => '✓ Teklif gönderildi',
                      }),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void _openBidDialog(AppState app, StudentListing l) {
    final priceCtl =
        TextEditingController(text: l.budget.toStringAsFixed(0));
    final msgCtl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Teklif ver'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Ders ücreti (60 dk)', prefixText: '₺ '),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Mesajınız (uygunluk, yaklaşım…)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(priceCtl.text) ?? l.budget;
              app.placeBid(l, price, msgCtl.text.trim());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Teklifiniz iletildi. Öğrenci kabul ederse '
                      'mesajlaşma açılır.')));
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}

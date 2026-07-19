import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import '../widgets/home_button.dart';
import 'provider_detail_screen.dart';

/// "Karsilastir" design: up to 4 listings side by side. Green cells mark
/// the best value per row, the best price/rating combo gets a
/// "★ Konsül önerisi" badge, and "Yalnızca farkları göster" hides rows
/// where every column matches.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  bool _onlyDiffs = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.compareList;

    final body = list.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Karşılaştırma listeniz boş.\n'
                'Arama sonuçlarındaki "+ Karşılaştır" butonuyla en fazla '
                '4 ilan ekleyin.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        : _table(app, list);

    final isPushed = ModalRoute.of(context)?.canPop ?? false;
    if (isPushed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Karşılaştırma'),
          actions: const [HomeButton(), SizedBox(width: 8)],
        ),
        body: body,
      );
    }
    return body;
  }

  /// Composite score for the "★ Konsül önerisi" badge: rating counts up,
  /// price counts down (both normalized within the compared set).
  String? _consulPickId(List<ProviderProfile> list) {
    if (list.length < 2) return null;
    final prices = list.map(AppState.effectivePrice).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    String? best;
    var bestScore = double.negativeInfinity;
    for (final p in list) {
      final priceNorm = maxP == minP
          ? 0.0
          : (AppState.effectivePrice(p) - minP) / (maxP - minP);
      final score = p.avgRating / 5 - priceNorm * 0.6;
      if (score > bestScore) {
        bestScore = score;
        best = p.id;
      }
    }
    return best;
  }

  Widget _table(AppState app, List<ProviderProfile> list) {
    final consulId = _consulPickId(list);
    final allFeatures = <String>{for (final p in list) ...p.features}.toList();

    // Row model: label + per-column cell text/flag + which columns are best.
    final rows = <(String, List<String>, Set<int>)>[];

    void addRow(String label, List<String> cells, {Set<int>? best}) {
      rows.add((label, cells, best ?? const {}));
    }

    Set<int> bestOf(List<double> values, {bool lowest = false}) {
      if (values.toSet().length <= 1) return const {};
      final target = lowest
          ? values.reduce((a, b) => a < b ? a : b)
          : values.reduce((a, b) => a > b ? a : b);
      return {
        for (var i = 0; i < values.length; i++)
          if (values[i] == target) i,
      };
    }

    final prices = list.map(AppState.effectivePrice).toList();
    addRow(
      'Ücret',
      [
        for (final p in list)
          p.type == ProviderType.privateTeacher
              ? '${formatPrice(p.lessonPrice ?? 0)}/ders'
              : '${formatPrice(p.monthlyPrice)}/ay',
      ],
      best: bestOf(prices, lowest: true),
    );
    addRow(
      'Puan',
      [
        for (final p in list)
          p.avgRating == 0
              ? '—'
              : '★ ${p.avgRating.toStringAsFixed(1)}',
      ],
      best: bestOf(list.map((p) => p.avgRating).toList()),
    );
    addRow(
      'Yorum sayısı',
      [for (final p in list) '${p.publishedReviews.length}'],
      best: bestOf(
          list.map((p) => p.publishedReviews.length.toDouble()).toList()),
    );
    addRow(
      'Mesafe (tahmini)',
      [
        for (final p in list)
          '${AppState.pseudoDistanceKm(p.id).toStringAsFixed(1)} km',
      ],
      best: bestOf(
          list.map((p) => AppState.pseudoDistanceKm(p.id)).toList(),
          lowest: true),
    );
    addRow('Konum', [
      for (final p in list)
        '${p.district.isNotEmpty ? '${p.district}, ' : ''}${p.city}',
    ]);
    addRow('Tanıtım videosu',
        [for (final p in list) p.videoUrl != null ? '✓' : '—']);
    addRow('Deneme dersi',
        [for (final p in list) p.trialLesson ? '✓' : '—']);
    for (final f in allFeatures) {
      addRow(f, [for (final p in list) p.features.contains(f) ? '✓' : '—']);
    }

    final visibleRows = _onlyDiffs
        ? rows.where((r) => r.$2.toSet().length > 1).toList()
        : rows;

    const colWidth = 190.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('← Aramaya dön'),
                  ),
                  Text('Karşılaştırma', style: pusulaHeading(fontSize: 24)),
                  Text('· ${list.length} ilan',
                      style: const TextStyle(
                          fontSize: 14, color: PusulaColors.muted)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _onlyDiffs,
                        onChanged: (v) => setState(() => _onlyDiffs = v),
                      ),
                      const Text('Yalnızca farkları göster',
                          style: TextStyle(fontSize: 13.5)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Arama sonuçlarındaki "+ Karşılaştır" ile en fazla 4 ilan '
                'eklenir.',
                style: TextStyle(fontSize: 13, color: PusulaColors.muted),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 150),
                        for (final p in list)
                          Container(
                            width: colWidth,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: p.id == consulId
                                      ? PusulaColors.primary
                                      : PusulaColors.border,
                                  width: p.id == consulId ? 2 : 1),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (p.id == consulId)
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                PusulaColors.primarySoft,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    100),
                                          ),
                                          child: const Text(
                                              '★ Konsül önerisi',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: PusulaColors
                                                      .primaryDark)),
                                        ),
                                      )
                                    else
                                      const Spacer(),
                                    InkWell(
                                      onTap: () =>
                                          app.toggleCompare(p.id),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text('✕',
                                            style: TextStyle(
                                                color:
                                                    PusulaColors.faint)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (p.photoUrls.isNotEmpty)
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: NetworkPhoto(
                                        url: p.photoUrls.first,
                                        width: colWidth,
                                        height: 84),
                                  ),
                                const SizedBox(height: 8),
                                Text(p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: pusulaHeading(fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.type.labelTr} · ${p.city}',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: PusulaColors.muted),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Data rows
                    for (final (label, cells, best) in visibleRows)
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PusulaColors.border)),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(label,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: PusulaColors.body)),
                            ),
                            for (var i = 0; i < cells.length; i++)
                              Container(
                                width: colWidth,
                                margin:
                                    const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9, horizontal: 10),
                                color: best.contains(i)
                                    ? PusulaColors.primarySoft
                                    : null,
                                child: Text(
                                  cells[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: best.contains(i)
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: cells[i] == '—'
                                        ? PusulaColors.faint
                                        : (best.contains(i)
                                            ? PusulaColors.primaryDark
                                            : PusulaColors.ink),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    // CTA row
                    Row(
                      children: [
                        const SizedBox(width: 150),
                        for (final p in list)
                          Container(
                            width: colWidth,
                            margin: const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 10)),
                                    onPressed: () =>
                                        _openDetail(context, p),
                                    child: const Text('Teklif iste',
                                        style:
                                            TextStyle(fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 10)),
                                    onPressed: () =>
                                        _openDetail(context, p),
                                    child: const Text('İlanı incele',
                                        style:
                                            TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PusulaColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '✓ Yeşil hücreler o satırdaki en iyi değeri gösterir. '
                  'Ücretler kurumların beyanıdır; kesin fiyat için teklif '
                  'isteyin.',
                  style: TextStyle(
                      fontSize: 12.5, color: PusulaColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, ProviderProfile p) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProviderDetailScreen(providerId: p.id)));
  }
}

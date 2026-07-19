import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/showcase.dart';

/// Ücretlendirme & paketler — renders straight from AppState.pricingPlans,
/// so admin price edits in "Paketler" show up here immediately.
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _tab = 0;

  static const _faqs = <(String, String)>[
    (
      'Velilerden ücret alınıyor mu?',
      'Hayır. Arama, karşılaştırma, teklif isteme ve mesajlaşma veliler ile '
          'öğrenciler için tamamen ücretsizdir.'
    ),
    (
      'Ders ücretinden komisyon kesiliyor mu?',
      'Hayır. Ödemeler kurum/öğretmen ile veli arasında doğrudan yapılır; '
          'platform komisyon almaz.'
    ),
    (
      'Paketi istediğim zaman iptal edebilir miyim?',
      'Evet, aylık paketler dönem sonunda iptal edilebilir; kalan öne '
          'çıkarma hakları dönem sonuna kadar kullanılabilir.'
    ),
    (
      'Doğrulama rozeti ücretli mi?',
      'Hayır. Belge doğrulaması tüm paketlerde ücretsizdir ve moderasyon '
          'ekibince 2 iş günü içinde tamamlanır.'
    ),
  ];

  String _tl(double price) {
    final s = price.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '₺$buf';
  }

  Widget _planCard(PricingPlan p) {
    final popular = p.popular;
    return Container(
      width: 262,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: p.onSale ? Colors.white : PusulaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: popular
            ? Border.all(color: PusulaColors.primary, width: 2)
            : Border.all(color: PusulaColors.border),
        boxShadow: popular
            ? [
                BoxShadow(
                  color: PusulaColors.primary.withValues(alpha: 0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (popular)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: PusulaColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('En çok tercih edilen',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          Text(p.name, style: pusulaHeading(fontSize: 20)),
          const SizedBox(height: 4),
          Text(p.desc,
              style: const TextStyle(
                  fontSize: 13, color: PusulaColors.muted)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_tl(p.price),
                  style: pusulaHeading(
                      fontSize: 32, fontWeight: FontWeight.w800)),
              if (p.period.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 2),
                  child: Text(p.period,
                      style: const TextStyle(
                          fontSize: 14, color: PusulaColors.muted)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final f in p.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✓',
                      style: TextStyle(
                          color: PusulaColors.primary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: PusulaColors.body)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: p.popular
                ? FilledButton(
                    onPressed: p.onSale ? () => _cta(p) : null,
                    child: Text(p.onSale ? p.cta : 'Satışta değil'),
                  )
                : OutlinedButton(
                    onPressed: p.onSale ? () => _cta(p) : null,
                    child: Text(p.onSale ? p.cta : 'Satışta değil'),
                  ),
          ),
        ],
      ),
    );
  }

  void _cta(PricingPlan p) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Demo: "${p.name}" paketi ödeme akışı MVP sonrası '
            'eklenecek.')));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final plans = app.plansFor(
        _tab == 0 ? PlanAudience.institution : PlanAudience.teacher);
    final addons = app.plansFor(PlanAudience.addon);

    return ShowcaseScaffold(
      maxWidth: 900,
      children: [
        const PageIntro(
          title: 'Ücretlendirme & paketler',
          lead: Text(
            'Veliler ve öğrenciler için platform tamamen ücretsizdir. Ders '
            'ücretlerinden komisyon alınmaz — gelirimiz kurum paketleri ve '
            'sponsorlu içeriktendir.',
            style: TextStyle(fontSize: 16, color: PusulaColors.body),
          ),
        ),
        Row(
          children: [
            for (final (i, label) in const [(0, 'Kurumlar'), (1, 'Öğretmenler')])
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(label),
                  selected: _tab == i,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontWeight:
                        _tab == i ? FontWeight.w700 : FontWeight.w500,
                    color: _tab == i
                        ? PusulaColors.primaryDark
                        : PusulaColors.body,
                  ),
                  onSelected: (_) => setState(() => _tab = i),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [for (final p in plans) _planCard(p)],
        ),
        if (_tab == 0) ...[
          const SizedBox(height: 40),
          Text('Ek ürünler', style: pusulaHeading(fontSize: 22)),
          const SizedBox(height: 6),
          const Text(
            'Pakete ek olarak, dilediğiniz hafta satın alınır; otomatik '
            'yenilenmez.',
            style: TextStyle(fontSize: 14, color: PusulaColors.body),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final ad in addons)
                Container(
                  width: 276,
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
                        children: [
                          Expanded(
                            child: Text(ad.name,
                                style: pusulaHeading(fontSize: 15)),
                          ),
                          Text('${_tl(ad.price)}${ad.period}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: PusulaColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(ad.desc,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: PusulaColors.body)),
                    ],
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 40),
        Text('Sık sorulanlar', style: pusulaHeading(fontSize: 22)),
        const SizedBox(height: 12),
        for (final (q, a) in _faqs)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(),
              title: Text(q,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: PusulaColors.body)),
              ],
            ),
          ),
      ],
    );
  }
}

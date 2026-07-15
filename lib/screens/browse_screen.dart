import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'compare_screen.dart';
import 'provider_detail_screen.dart';

/// Search + filter + list of all listings. Seekers can also add to compare.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;
    final list = app.filteredProviders;
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
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Okul, kurs, öğretmen ara...',
                    border: OutlineInputBorder(),
                    isDense: true,
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
        if (user.role.isSeeker && app.compareIds.isNotEmpty)
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
              ? const Center(child: Text('Sonuç bulunamadı. Filtreleri gevşetmeyi deneyin.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, i) =>
                      _ProviderCard(provider: list[i], showCompare: user.role.isSeeker),
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
                            Icon(Icons.play_circle, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Tanıtım Videosu',
                                style: TextStyle(color: Colors.white, fontSize: 12)),
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
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Text(provider.city,
                          style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Text('${formatPrice(provider.monthlyPrice)}/ay',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: provider.avgRating),
                      Text(' (${provider.reviews.length} yorum)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

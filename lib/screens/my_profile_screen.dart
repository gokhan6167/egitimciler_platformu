import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import 'provider_detail_screen.dart';

/// Educators edit their public listing here: name, description, price,
/// city, photos and intro video URL.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _city;
  late final TextEditingController _video;
  final _photo = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().myProvider;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.monthlyPrice.toStringAsFixed(0) ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _video = TextEditingController(text: p?.videoUrl ?? '');
    _initialized = p != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _city.dispose();
    _video.dispose();
    _photo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.myProvider;

    if (p == null || !_initialized) {
      return const Center(child: Text('Size ait bir ilan bulunamadı.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('İlanımı Düzenle',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('Önizle'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ProviderDetailScreen(providerId: p.id)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
              labelText: 'İlan Başlığı', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Tanıtım Yazısı', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Aylık Ücret (TL)',
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _city,
                decoration: const InputDecoration(
                    labelText: 'Şehir', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _video,
          decoration: const InputDecoration(
            labelText: 'Tanıtım Videosu URL',
            hintText: 'https://... (kısa tanıtım videonuz)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Kaydet'),
          onPressed: () {
            context.read<AppState>().updateMyProvider(
                  name: _name.text,
                  description: _description.text,
                  monthlyPrice: double.tryParse(_price.text),
                  city: _city.text,
                  videoUrl: _video.text,
                );
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İlanınız güncellendi.')));
          },
        ),
        const SizedBox(height: 24),
        Text('Fotoğraflar (${p.photoUrls.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (p.photoUrls.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: p.photoUrls.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    NetworkPhoto(url: p.photoUrls[i], height: 120, width: 180),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _photo,
                decoration: const InputDecoration(
                  labelText: 'Fotoğraf URL ekle',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              icon: const Icon(Icons.add_photo_alternate),
              tooltip: 'Ekle',
              onPressed: () {
                context.read<AppState>().addPhotoToMyProvider(_photo.text);
                _photo.clear();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İstatistikler',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Ortalama puan: ${p.avgRating == 0 ? '-' : p.avgRating.toStringAsFixed(1)}'),
                Text('Yorum sayısı: ${p.reviews.length}'),
                Text('Aylık ücret: ${formatPrice(p.monthlyPrice)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

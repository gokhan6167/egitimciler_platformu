import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'messages_screen.dart';

/// Public listing page: photo gallery, intro video, description, features,
/// reviews + add review, message the owner, request an offer.
class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  void _showReviewDialog(BuildContext context) {
    var stars = 5;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Puan Ver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarPicker(value: stars, onChanged: (v) => setDlg(() => stars = v)),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'Yorumunuz', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () {
                context
                    .read<AppState>()
                    .addReview(providerId, stars, controller.text.trim());
                Navigator.pop(dialogCtx);
              },
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfferDialog(BuildContext context) {
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
            border: OutlineInputBorder(),
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
              context.read<AppState>().requestOffer(providerId, note);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Teklif talebiniz gönderildi. Teklifler sekmesinden takip edebilirsiniz.')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context, String url) {
    // MVP: placeholder player; real playback (video_player package) comes later.
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle, color: Colors.white, size: 72),
                const SizedBox(height: 12),
                const Text('Tanıtım videosu (demo)',
                    style: TextStyle(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(url,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final provider = app.providerById(providerId);
    if (provider == null) {
      return const Scaffold(body: Center(child: Text('İlan bulunamadı')));
    }
    final user = app.currentUser!;
    final isOwner = user.id == provider.ownerUserId;
    final owner = app.userById(provider.ownerUserId);

    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Photo gallery ---
          if (provider.photoUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.photoUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkPhoto(
                      url: provider.photoUrls[i], height: 200, width: 320),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(provider.name,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              TypeBadge(type: provider.type),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              Text(provider.city, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Text('${formatPrice(provider.monthlyPrice)}/ay',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: provider.avgRating, size: 22),
          const SizedBox(height: 16),

          // --- Video ---
          if (provider.videoUrl != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.play_circle),
              label: const Text('Tanıtım Videosunu İzle'),
              onPressed: () => _playVideo(context, provider.videoUrl!),
            ),
          const SizedBox(height: 16),

          Text('Hakkında', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(provider.description),
          const SizedBox(height: 16),

          if (provider.features.isNotEmpty) ...[
            Text('Özellikler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in provider.features) Chip(label: Text(f)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // --- Actions (not for the owner) ---
          if (!isOwner && owner != null)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('Mesaj Gönder'),
                    onPressed: () {
                      final conv =
                          context.read<AppState>().conversationWith(owner.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(conversationId: conv.id)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (user.role.isSeeker)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.local_offer),
                      label: const Text('Teklif İste'),
                      onPressed: () => _showOfferDialog(context),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 24),

          // --- Reviews ---
          Row(
            children: [
              Text('Yorumlar (${provider.reviews.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (!isOwner && user.role.isSeeker)
                TextButton.icon(
                  icon: const Icon(Icons.star),
                  label: const Text('Puan Ver'),
                  onPressed: () => _showReviewDialog(context),
                ),
            ],
          ),
          if (provider.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Henüz yorum yok. İlk yorumu siz yazın!'),
            ),
          for (final r in provider.reviews.reversed)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Row(
                  children: [
                    Expanded(child: Text(r.authorName)),
                    RatingStars(rating: r.stars.toDouble(), size: 14),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.comment.isNotEmpty) Text(r.comment),
                    Text(formatDate(r.date),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

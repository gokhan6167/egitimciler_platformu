import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Seekers see offers they requested; educators see incoming requests
/// on their listing and can quote a price.
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _showQuoteDialog(BuildContext context, Offer offer) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Fiyat Teklifi Ver'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Aylık fiyat (TL)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(
                  controller.text.replaceAll('.', '').replaceAll(',', '.'));
              if (price == null || price <= 0) return;
              context.read<AppState>().quoteOffer(offer, price);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OfferStatus s) => switch (s) {
        OfferStatus.requested => Colors.orange,
        OfferStatus.quoted => Colors.blue,
        OfferStatus.accepted => Colors.green,
        OfferStatus.rejected => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;
    final isSeeker = user.role.isSeeker;
    final offers = isSeeker ? app.myRequestedOffers : app.incomingOffers;

    if (offers.isEmpty) {
      return Center(
        child: Text(
          isSeeker
              ? 'Henüz teklif talebiniz yok.\nİlan sayfalarındaki "Teklif İste" butonunu kullanın.'
              : 'Henüz size gelen teklif talebi yok.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: offers.length,
      itemBuilder: (context, i) {
        final offer = offers[i];
        final provider = app.providerById(offer.providerId);
        final requester = app.userById(offer.requesterId);
        final statusColor = _statusColor(offer.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSeeker
                            ? (provider?.name ?? 'İlan')
                            : (requester?.name ?? 'Kullanıcı'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(offer.status.labelTr,
                          style: TextStyle(color: statusColor, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(offer.note),
                const SizedBox(height: 6),
                Text(formatDate(offer.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (offer.quotedPrice != null) ...[
                  const SizedBox(height: 6),
                  Text('Verilen fiyat: ${formatPrice(offer.quotedPrice!)}/ay',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 8),
                // Educator: quote when requested
                if (!isSeeker && offer.status == OfferStatus.requested)
                  FilledButton.icon(
                    icon: const Icon(Icons.price_change),
                    label: const Text('Fiyat Ver'),
                    onPressed: () => _showQuoteDialog(context, offer),
                  ),
                // Seeker: accept/reject when quoted
                if (isSeeker && offer.status == OfferStatus.quoted)
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Kabul Et'),
                        onPressed: () => context
                            .read<AppState>()
                            .respondToQuote(offer, accept: true),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Reddet'),
                        onPressed: () => context
                            .read<AppState>()
                            .respondToQuote(offer, accept: false),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import 'messages_screen.dart';
import 'provider_detail_screen.dart';

/// "Tekliflerim" design: incoming offers as rich cards (accept → Mesaja
/// git), outgoing requests as a table. Content adapts to the role:
/// seekers see their requests + bids on their student listing; educators
/// see incoming requests on their listing (and teachers their sent bids).
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;
    final isSeeker = user.role.isSeeker;

    final incomingBids = <ListingBid>[
      if (isSeeker)
        for (final l in app.myStudentListings)
          ...app.bidsFor(l.id).where((b) => b.status != BidStatus.rejected),
    ];
    final incomingRequests = isSeeker ? <Offer>[] : app.incomingOffers;
    final outgoingOffers = isSeeker ? app.myRequestedOffers : <Offer>[];
    final myBids = user.role == UserRole.teacher ? app.myBids : <ListingBid>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tekliflerim', style: pusulaHeading(fontSize: 26)),
              const SizedBox(height: 4),
              const Text(
                'Gönderdiğiniz teklif istekleri ve ilanınıza gelen teklifler '
                'tek yerde.',
                style: TextStyle(fontSize: 14, color: PusulaColors.body),
              ),
              const SizedBox(height: 20),
              if (incomingBids.isNotEmpty) ...[
                Text('Öğrenci ilanıma gelen teklifler',
                    style: pusulaHeading(fontSize: 18)),
                const SizedBox(height: 10),
                for (final b in incomingBids) _bidCard(context, app, b),
                const SizedBox(height: 20),
              ],
              if (incomingRequests.isNotEmpty) ...[
                Text('Gelen teklif istekleri',
                    style: pusulaHeading(fontSize: 18)),
                const SizedBox(height: 10),
                for (final o in incomingRequests)
                  _incomingRequestCard(context, app, o),
                const SizedBox(height: 20),
              ],
              if (outgoingOffers.isNotEmpty) ...[
                Text('Gönderdiğim teklif istekleri',
                    style: pusulaHeading(fontSize: 18)),
                const SizedBox(height: 10),
                _outgoingTable(context, app, outgoingOffers),
                const SizedBox(height: 20),
              ],
              if (myBids.isNotEmpty) ...[
                Text('Öğrenci ilanlarına verdiğim teklifler',
                    style: pusulaHeading(fontSize: 18)),
                const SizedBox(height: 10),
                for (final b in myBids) _myBidRow(context, app, b),
                const SizedBox(height: 20),
              ],
              if (incomingBids.isEmpty &&
                  incomingRequests.isEmpty &&
                  outgoingOffers.isEmpty &&
                  myBids.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PusulaColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 40, color: PusulaColors.faint),
                      SizedBox(height: 10),
                      Text('Henüz teklif yok',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text(
                        'İlan sayfalarındaki "Teklif iste" butonunu kullanın '
                        'veya ilan verin.',
                        style: TextStyle(
                            fontSize: 13, color: PusulaColors.body),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PusulaColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '✓ Teklif geldiğinde e-posta ve uygulama bildirimi '
                  'alırsınız; kurumlar ortalama 1 iş günü içinde yanıtlar.',
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

  void _goToChat(BuildContext context, AppState app, String otherUserId) {
    final conv = app.conversationWith(otherUserId);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(conversationId: conv.id)));
  }

  /// A teacher's bid on my student listing (seeker view).
  Widget _bidCard(BuildContext context, AppState app, ListingBid b) {
    final teacher = app.userById(b.teacherUserId);
    final listing = app.studentListingById(b.listingId);
    final name = teacher?.name ?? 'Öğretmen';
    final accepted = b.status == BidStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: accepted ? PusulaColors.primary : PusulaColors.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        spacing: 12,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: PusulaColors.primarySoft,
            child: Text(name.characters.first.toUpperCase(),
                style: const TextStyle(
                    color: PusulaColors.primaryDark,
                    fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name ✓', style: pusulaHeading(fontSize: 15)),
                Text(
                  '${teacher?.subject ?? ''} · ${listing?.title ?? ''}',
                  style: const TextStyle(
                      fontSize: 12.5, color: PusulaColors.body),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (b.message.isNotEmpty)
                  Text(b.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: PusulaColors.muted)),
              ],
            ),
          ),
          Text('₺${b.price.toStringAsFixed(0)}/ders',
              style: pusulaHeading(fontSize: 16)),
          if (accepted) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PusulaColors.primarySoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('✓ Kabul edildi',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PusulaColors.primaryDark)),
            ),
            FilledButton(
              onPressed: () => _goToChat(context, app, b.teacherUserId),
              child: const Text('Mesaja git →'),
            ),
          ] else ...[
            FilledButton(
              onPressed: () {
                app.acceptBid(b);
                _goToChat(context, app, b.teacherUserId);
              },
              child: const Text('Kabul et'),
            ),
            OutlinedButton(
              onPressed: () => app.rejectBid(b),
              child: const Text('Reddet'),
            ),
          ],
          if (teacher?.providerId != null)
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ProviderDetailScreen(
                          providerId: teacher!.providerId!))),
              child: const Text('Profili incele'),
            ),
        ],
      ),
    );
  }

  /// A seeker's request landing on my listing (educator view).
  Widget _incomingRequestCard(BuildContext context, AppState app, Offer o) {
    final requester = app.userById(o.requesterId);
    final name = requester?.name ?? 'Kullanıcı';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        spacing: 12,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: PusulaColors.primarySoft,
            child: Text(name.characters.first.toUpperCase(),
                style: const TextStyle(
                    color: PusulaColors.primaryDark,
                    fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: pusulaHeading(fontSize: 15)),
                Text(o.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: PusulaColors.body)),
                Text(formatDate(o.createdAt),
                    style: const TextStyle(
                        fontSize: 11.5, color: PusulaColors.faint)),
              ],
            ),
          ),
          _statusChip(o.status),
          if (o.quotedPrice != null)
            Text('${formatPrice(o.quotedPrice!)}/ay',
                style: pusulaHeading(fontSize: 15)),
          if (o.status == OfferStatus.requested)
            FilledButton(
              onPressed: () => _quoteDialog(context, o),
              child: const Text('Fiyat ver'),
            ),
          if (o.status == OfferStatus.accepted)
            FilledButton(
              onPressed: () => _goToChat(context, app, o.requesterId),
              child: const Text('Mesaja git →'),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(OfferStatus s) {
    final (fg, bg) = switch (s) {
      OfferStatus.requested => (
          const Color(0xFF8A6212),
          const Color(0xFFFBF1DF)
        ),
      OfferStatus.quoted => (
          PusulaColors.primaryDark,
          PusulaColors.primarySoft
        ),
      OfferStatus.accepted => (
          PusulaColors.primaryDark,
          PusulaColors.primarySoft
        ),
      OfferStatus.rejected => (
          const Color(0xFFB4423A),
          const Color(0xFFFBF0EF)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(s.labelTr,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  void _quoteDialog(BuildContext context, Offer offer) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Fiyat teklifi ver'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Aylık fiyat', prefixText: '₺ '),
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

  /// Outgoing request table (seeker view), like the design's table:
  /// Kurum/Öğretmen · Kategori · Tarih · Durum · İşlem.
  Widget _outgoingTable(BuildContext context, AppState app, List<Offer> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: PusulaColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('KURUM / ÖĞRETMEN',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.faint))),
                Expanded(
                    flex: 2,
                    child: Text('KATEGORİ',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.faint))),
                Expanded(
                    flex: 2,
                    child: Text('TARİH',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.faint))),
                Expanded(
                    flex: 2,
                    child: Text('DURUM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.faint))),
                Expanded(
                    flex: 3,
                    child: Text('İŞLEM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.faint))),
              ],
            ),
          ),
          for (final o in list)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: PusulaColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            app.providerById(o.providerId)?.name ?? 'İlan',
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600)),
                        if (o.quotedPrice != null)
                          Text('Teklif: ${formatPrice(o.quotedPrice!)}/ay',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: PusulaColors.body)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                        app.providerById(o.providerId)?.type.labelTr ?? '',
                        style: const TextStyle(
                            fontSize: 12.5, color: PusulaColors.body)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(formatDate(o.createdAt),
                        style: const TextStyle(
                            fontSize: 12.5, color: PusulaColors.body)),
                  ),
                  Expanded(flex: 2, child: _statusChip(o.status)),
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (o.status == OfferStatus.quoted) ...[
                          FilledButton(
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6)),
                            onPressed: () => context
                                .read<AppState>()
                                .respondToQuote(o, accept: true),
                            child: const Text('Kabul et',
                                style: TextStyle(fontSize: 12)),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6)),
                            onPressed: () => context
                                .read<AppState>()
                                .respondToQuote(o, accept: false),
                            child: const Text('Reddet',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        if (o.status == OfferStatus.accepted)
                          FilledButton(
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6)),
                            onPressed: () {
                              final owner = app
                                  .providerById(o.providerId)
                                  ?.ownerUserId;
                              if (owner != null) {
                                _goToChat(context, app, owner);
                              }
                            },
                            child: const Text('Mesaja git →',
                                style: TextStyle(fontSize: 12)),
                          ),
                        if (o.status == OfferStatus.requested)
                          const Text('Yanıt bekleniyor',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: PusulaColors.faint)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// A bid I placed as a teacher, with its status.
  Widget _myBidRow(BuildContext context, AppState app, ListingBid b) {
    final listing = app.studentListingById(b.listingId);
    final firstName = listing == null
        ? ''
        : (app.userById(listing.ownerUserId)?.name.split(' ').first ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing?.title ?? 'İlan',
                    style: pusulaHeading(fontSize: 14.5)),
                Text(
                    '$firstName · ${listing?.subject ?? ''} · ${listing?.city ?? ''}',
                    style: const TextStyle(
                        fontSize: 12.5, color: PusulaColors.body)),
              ],
            ),
          ),
          Text('₺${b.price.toStringAsFixed(0)}/ders',
              style: pusulaHeading(fontSize: 15)),
          switch (b.status) {
            BidStatus.accepted => FilledButton(
                onPressed: () {
                  final owner = listing?.ownerUserId;
                  if (owner != null) _goToChat(context, app, owner);
                },
                child: const Text('✓ Kabul edildi — Mesaja git →'),
              ),
            BidStatus.rejected => const Text('Reddedildi',
                style: TextStyle(
                    fontSize: 12.5, color: Color(0xFFB4423A))),
            _ => const Text('Yanıt bekleniyor',
                style:
                    TextStyle(fontSize: 12.5, color: PusulaColors.faint)),
          },
        ],
      ),
    );
  }
}

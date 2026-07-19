import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/iller.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import 'messages_screen.dart';

/// "Ogrenci Ilan Paneli" — parents/students manage their lesson request
/// and its incoming teacher offers. Only the first name is ever shown on
/// the public card; contact details unlock after accepting an offer.
class StudentListingPanelScreen extends StatefulWidget {
  const StudentListingPanelScreen({super.key});

  @override
  State<StudentListingPanelScreen> createState() =>
      _StudentListingPanelScreenState();
}

class _StudentListingPanelScreenState
    extends State<StudentListingPanelScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;
    if (me == null) return const SizedBox.shrink();
    final listings = app.myStudentListings;
    final wide = MediaQuery.of(context).size.width >= 1100;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Text('Öğrenci ilan paneli', style: pusulaHeading(fontSize: 26)),
            FilledButton(
              onPressed: () => _openCreateDialog(app),
              child: const Text('+ Ücretsiz ilan ver'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'İlan özellikleri öğrenci ilanı filtreleriyle eşleşir; iletişim '
          'bilgilerinizi yalnızca doğrulanmış öğretmenler görür.',
          style: TextStyle(fontSize: 13.5, color: PusulaColors.body),
        ),
        const SizedBox(height: 18),
        if (listings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 44),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PusulaColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.post_add,
                    size: 40, color: PusulaColors.faint),
                const SizedBox(height: 10),
                Text('Henüz ilanınız yok', style: pusulaHeading(fontSize: 18)),
                const SizedBox(height: 6),
                const Text(
                  'Ders ihtiyacınızı anlatan ücretsiz bir ilan verin; '
                  'doğrulanmış öğretmenlerden teklif alın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: PusulaColors.body),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => _openCreateDialog(app),
                  child: const Text('+ Ücretsiz ilan ver'),
                ),
              ],
            ),
          )
        else
          for (final l in listings) _listingBlock(app, l),
      ],
    );

    final preview = listings.isEmpty
        ? const SizedBox.shrink()
        : _previewCard(app, listings.first);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 24),
                    SizedBox(width: 330, child: preview),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, preview],
                ),
        ),
      ),
    );
  }

  Widget _listingBlock(AppState app, StudentListing l) {
    final listingBids = app
        .bidsFor(l.id)
        .where((b) => b.status != BidStatus.rejected)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(child: Text(l.title, style: pusulaHeading(fontSize: 17))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: l.status == StudentListingStatus.active
                      ? PusulaColors.primarySoft
                      : const Color(0xFFFBF1DF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  l.status.labelTr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: l.status == StudentListingStatus.active
                        ? PusulaColors.primaryDark
                        : const Color(0xFF8A6212),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l.subject} · ${l.level} · ${l.district.isNotEmpty ? '${l.district}, ' : ''}${l.city} · '
            '₺${l.budget.toStringAsFixed(0)}/ders · ${l.schedule} · ${l.mode}',
            style: const TextStyle(fontSize: 13, color: PusulaColors.body),
          ),
          const SizedBox(height: 8),
          Text(l.description,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.5, color: PusulaColors.body)),
          const Divider(height: 28),
          Row(
            children: [
              Text('Gelen teklifler', style: pusulaHeading(fontSize: 15)),
              const SizedBox(width: 8),
              Text('· ${listingBids.length}',
                  style: const TextStyle(
                      fontSize: 13, color: PusulaColors.muted)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Teklifleri kabul ettiğinizde mesajlaşma açılır.',
              style: TextStyle(fontSize: 12.5, color: PusulaColors.muted)),
          const SizedBox(height: 10),
          if (listingBids.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Henüz teklif gelmedi.',
                  style: TextStyle(
                      fontSize: 13, color: PusulaColors.faint)),
            )
          else
            for (final b in listingBids) _bidRow(app, b),
        ],
      ),
    );
  }

  Widget _bidRow(AppState app, ListingBid b) {
    final teacher = app.userById(b.teacherUserId);
    final name = teacher?.name ?? 'Öğretmen';
    final accepted = b.status == BidStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accepted ? PusulaColors.primarySoft : PusulaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: accepted ? PusulaColors.primary : PusulaColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(
              name.characters.first.toUpperCase(),
              style: const TextStyle(
                  color: PusulaColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name ✓',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(
                  '${teacher?.subject ?? ''} · ${teacher?.experienceYears ?? 0} yıl deneyim',
                  style: const TextStyle(
                      fontSize: 12.5, color: PusulaColors.body),
                ),
                if (b.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(b.message,
                      style: const TextStyle(
                          fontSize: 13, height: 1.4,
                          color: PusulaColors.body)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₺${b.price.toStringAsFixed(0)}/ders',
                  style: pusulaHeading(fontSize: 15)),
              const SizedBox(height: 6),
              if (accepted)
                FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8)),
                  onPressed: () {
                    final conv = app.conversationWith(b.teacherUserId);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(conversationId: conv.id)));
                  },
                  child: const Text('Mesaja git →',
                      style: TextStyle(fontSize: 12.5)),
                )
              else
                Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8)),
                      onPressed: () {
                        app.acceptBid(b);
                        final conv = app.conversationWith(b.teacherUserId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              'Teklif kabul edildi; mesajlaşma açıldı.'),
                          action: SnackBarAction(
                            label: 'Mesaja git',
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                        conversationId: conv.id))),
                          ),
                        ));
                      },
                      child: const Text('Kabul et',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8)),
                      onPressed: () => app.rejectBid(b),
                      child: const Text('Reddet',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewCard(AppState app, StudentListing l) {
    final name = app.userById(l.ownerUserId)?.name.split(' ').first ?? '';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İlan kartı önizlemesi', style: pusulaHeading(fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PusulaColors.primarySoft,
                child: Text(
                  name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                  style: const TextStyle(
                      color: PusulaColors.primaryDark,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name ✓', style: pusulaHeading(fontSize: 15)),
                    Text(l.level,
                        style: const TextStyle(
                            fontSize: 12.5, color: PusulaColors.muted)),
                  ],
                ),
              ),
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
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A6212))),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${l.subject} · ${l.schedule} · ${l.mode}',
              style: const TextStyle(
                  fontSize: 12.5, color: PusulaColors.body)),
          const SizedBox(height: 8),
          Text(l.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, height: 1.45, color: PusulaColors.body)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '₺${l.budget.toStringAsFixed(0)}',
                      style: pusulaHeading(fontSize: 17)),
                  const TextSpan(
                      text: ' /ders',
                      style: TextStyle(
                          fontSize: 12, color: PusulaColors.muted)),
                ])),
              ),
              FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  disabledBackgroundColor: PusulaColors.primary,
                  disabledForegroundColor: Colors.white,
                ),
                child:
                    const Text('Teklif ver →', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PusulaColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '✓ Soyadınız ve iletişim bilgileriniz ilanda görünmez; '
              'yalnızca teklifini kabul ettiğiniz doğrulanmış öğretmenlerle '
              'paylaşılır.',
              style: TextStyle(
                  fontSize: 12, height: 1.5,
                  color: PusulaColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateDialog(AppState app) {
    final title = TextEditingController();
    final subject = TextEditingController();
    final level = TextEditingController();
    final budget = TextEditingController(text: '800');
    final description = TextEditingController();
    String? city = app.currentUser?.city.isNotEmpty == true &&
            iller.contains(app.currentUser!.city)
        ? app.currentUser!.city
        : null;
    String? district;
    String schedule = 'Hafta içi akşam';
    String mode = 'Fark etmez';
    bool startNow = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Ücretsiz öğrenci ilanı ver'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(
                          labelText: 'İlan başlığı',
                          hintText:
                              'ör. LGS matematik için haftada 2 gün ders')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: subject,
                            decoration: const InputDecoration(
                                labelText: 'Ders',
                                hintText: 'Matematik'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: level,
                            decoration: const InputDecoration(
                                labelText: 'Seviye',
                                hintText: '8. sınıf (LGS)'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: city,
                        decoration: const InputDecoration(labelText: 'İl'),
                        items: [
                          for (final il in iller)
                            DropdownMenuItem(value: il, child: Text(il)),
                        ],
                        onChanged: (v) => setDlg(() {
                          city = v;
                          district = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: district,
                        decoration: const InputDecoration(labelText: 'İlçe'),
                        items: [
                          for (final ilce
                              in ilceler[city] ?? const <String>[])
                            DropdownMenuItem(value: ilce, child: Text(ilce)),
                        ],
                        onChanged: (v) => setDlg(() => district = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                          controller: budget,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Bütçe (60 dk)',
                              prefixText: '₺ ')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: mode,
                        decoration:
                            const InputDecoration(labelText: 'Dersin yeri'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Evde ders', child: Text('Evde ders')),
                          DropdownMenuItem(
                              value: 'Online', child: Text('Online')),
                          DropdownMenuItem(
                              value: 'Fark etmez',
                              child: Text('Fark etmez')),
                        ],
                        onChanged: (v) =>
                            setDlg(() => mode = v ?? 'Fark etmez'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: schedule,
                    decoration:
                        const InputDecoration(labelText: 'Uygunluk'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Hafta içi gündüz',
                          child: Text('Hafta içi gündüz')),
                      DropdownMenuItem(
                          value: 'Hafta içi akşam',
                          child: Text('Hafta içi akşam')),
                      DropdownMenuItem(
                          value: 'Hafta sonu', child: Text('Hafta sonu')),
                    ],
                    onChanged: (v) =>
                        setDlg(() => schedule = v ?? schedule),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'İhtiyaç açıklaması')),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Hemen başlamak istiyoruz'),
                    value: startNow,
                    onChanged: (v) => setDlg(() => startNow = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty ||
                    subject.text.trim().isEmpty ||
                    city == null) {
                  return;
                }
                app.createStudentListing(
                  title: title.text.trim(),
                  subject: subject.text.trim(),
                  level: level.text.trim(),
                  city: city!,
                  district: district ?? '',
                  budget: double.tryParse(budget.text) ?? 0,
                  schedule: schedule,
                  mode: mode,
                  description: description.text.trim(),
                  startNow: startNow,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('İlanınız yayınlandı; yalnızca doğrulanmış '
                        'öğretmenlere gösterilir.')));
              },
              child: const Text('İlanı yayınla'),
            ),
          ],
        ),
      ),
    );
  }
}

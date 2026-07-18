import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import '../widgets/home_button.dart';
import 'login_screen.dart';
import 'messages_screen.dart';

/// Public listing page, implemented from the "Ilan Detay" Claude Design file:
/// breadcrumb, gallery grid, title + tags, about, stats, facilities,
/// reviews, sticky action sidebar and similar listings.
class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  /// Guests can browse; actions that need an account route to sign-in.
  bool _requireLogin(BuildContext context) {
    if (context.read<AppState>().currentUser != null) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu işlem için önce giriş yapın.')),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return false;
  }

  // ---------- Dialogs ----------

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
                decoration: const InputDecoration(labelText: 'Yorumunuz'),
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
            color: PusulaColors.ink,
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

  void _messageOwner(BuildContext context, AppUser owner) {
    final conv = context.read<AppState>().conversationWith(owner.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conv.id)),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final provider = app.providerById(providerId);
    if (provider == null) {
      return const Scaffold(body: Center(child: Text('İlan bulunamadı')));
    }
    final user = app.currentUser; // null → guest browsing from search
    final isOwner = user != null && user.id == provider.ownerUserId;
    final owner = app.userById(provider.ownerUserId);
    final wide = MediaQuery.of(context).size.width >= 980;
    final isTeacher = provider.type == ProviderType.privateTeacher;

    final content =
        _mainColumn(context, provider, user, isOwner, owner, isTeacher);
    final sidebar = _sidebar(context, app, provider, user, isOwner, owner);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PusulaLogo(size: 22),
            const SizedBox(width: 8),
            Text('Pusula Eğitim', style: pusulaHeading(fontSize: 16)),
          ],
        ),
        centerTitle: false,
        actions: const [HomeButton(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16)
                .copyWith(top: 20, bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(provider),
                const SizedBox(height: 22),
                if (!isTeacher) ...[
                  _gallery(context, provider, wide),
                  const SizedBox(height: 32),
                ],
                wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 19, child: content),
                          const SizedBox(width: 56),
                          Expanded(flex: 10, child: sidebar),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          sidebar,
                          const SizedBox(height: 28),
                          content,
                        ],
                      ),
                _similar(context, app, provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb(ProviderProfile p) {
    const style = TextStyle(fontSize: 13, color: PusulaColors.faint);
    return Wrap(
      spacing: 6,
      children: [
        const Text('Keşfet', style: style),
        const Text('/', style: style),
        Text(p.type.labelTr, style: style),
        const Text('/', style: style),
        Text(p.city,
            style: const TextStyle(fontSize: 13, color: PusulaColors.body)),
      ],
    );
  }

  // ---------- Gallery ----------

  Widget _galleryTile(BuildContext context, ProviderProfile p, int index,
      {List<Widget> overlays = const []}) {
    final hasPhoto = index < p.photoUrls.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            NetworkPhoto(url: p.photoUrls[index])
          else
            Container(
              color: PusulaColors.patternA,
              alignment: Alignment.center,
              child: const Icon(Icons.image_outlined,
                  color: PusulaColors.faint, size: 32),
            ),
          ...overlays,
        ],
      ),
    );
  }

  Widget _gallery(BuildContext context, ProviderProfile p, bool wide) {
    final verifiedBadge = Positioned(
      top: 14,
      left: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: PusulaColors.primarySoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text('✓ Doğrulanmış kurum',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PusulaColors.primaryDark)),
      ),
    );

    final videoBadge = p.videoUrl == null
        ? null
        : Positioned(
            bottom: 14,
            left: 14,
            child: InkWell(
              onTap: () => _playVideo(context, p.videoUrl!),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PusulaColors.ink.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                    p.videoDuration == null
                        ? '▶ Tanıtım videosu'
                        : '▶ Tanıtım videosu · ${p.videoDuration}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          );

    final morePhotos = p.photoUrls.length > 3
        ? Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: PusulaColors.background.withValues(alpha: 0.92),
                border: Border.all(color: PusulaColors.border),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('+${p.photoUrls.length - 3} fotoğraf',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.ink)),
            ),
          )
        : null;

    final main = _galleryTile(context, p, 0, overlays: [
      verifiedBadge,
      ?videoBadge,
    ]);

    if (!wide) return SizedBox(height: 260, child: main);

    return SizedBox(
      height: 380,
      child: Row(
        children: [
          Expanded(flex: 2, child: main),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _galleryTile(context, p, 1)),
                const SizedBox(height: 12),
                Expanded(
                  child: _galleryTile(context, p, 2, overlays: [
                    ?morePhotos,
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Main column ----------

  Widget _mainColumn(BuildContext context, ProviderProfile p, AppUser? user,
      bool isOwner, AppUser? owner, bool isTeacher) {
    // Captured by the reviews Builder below; lets the header's
    // "Yorumları gör" link scroll down to the reviews section.
    BuildContext? reviewsCtx;
    void seeReviews() {
      final c = reviewsCtx;
      if (c != null && c.mounted) {
        Scrollable.ensureVisible(
          c,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTeacher)
          _teacherHeader(context, p, owner)
        else
          _header(context, p, seeReviews),
        if (isTeacher && p.videoUrl != null)
          _bordered(_videoBlock(context, p)),
        _bordered(_about(p, isTeacher)),
        _bordered(_stats(p, owner, isTeacher)),
        if (isTeacher && p.credentials.isNotEmpty)
          _bordered(_credentials(p)),
        if (p.programs.isNotEmpty) _bordered(_programs(p, isTeacher)),
        if (p.features.isNotEmpty) _bordered(_facilities(p)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Builder(builder: (c) {
            reviewsCtx = c;
            return _reviews(context, p, user, isOwner);
          }),
        ),
      ],
    );
  }

  Widget _teacherHeader(BuildContext context, ProviderProfile p, AppUser? owner) {
    final narrow = MediaQuery.of(context).size.width < 620;

    final avatar = SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: 132,
              height: 132,
              child: p.photoUrls.isEmpty
                  ? Container(
                      color: PusulaColors.patternA,
                      child: const Icon(Icons.person_outline,
                          color: PusulaColors.faint, size: 48),
                    )
                  : NetworkPhoto(url: p.photoUrls.first),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PusulaColors.primary,
                border: Border.all(color: PusulaColors.background, width: 2),
              ),
              child:
                  const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'ÖZEL ÖĞRETMEN${owner != null && owner.subject.isNotEmpty ? ' · ${owner.subject.toUpperCase()}' : ''}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PusulaColors.faint,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(owner?.name ?? p.name,
            style: pusulaHeading(
                fontSize: 34, fontWeight: FontWeight.w800, height: 1.12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text:
                    '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)} ',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: PusulaColors.ink),
                children: [
                  TextSpan(
                      text: '(${p.publishedReviews.length} değerlendirme)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: PusulaColors.faint)),
                ],
              ),
            ),
            const Text('·',
                style: TextStyle(color: PusulaColors.body, fontSize: 14)),
            Text(p.city,
                style:
                    const TextStyle(fontSize: 14, color: PusulaColors.body)),
            if (owner != null && owner.experienceYears > 0) ...[
              const Text('·',
                  style: TextStyle(color: PusulaColors.body, fontSize: 14)),
              Text('${owner.experienceYears} yıl deneyim',
                  style: const TextStyle(
                      fontSize: 14, color: PusulaColors.body)),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in p.features.take(5))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: PusulaColors.surface,
                  border: Border.all(color: PusulaColors.border),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(t,
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.slate)),
              ),
          ],
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 28),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PusulaColors.border)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [avatar, const SizedBox(height: 20), info],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 28),
                Expanded(child: info),
              ],
            ),
    );
  }

  Widget _videoBlock(BuildContext context, ProviderProfile p) {
    return InkWell(
      onTap: () => _playVideo(context, p.videoUrl!),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: PusulaColors.patternA,
          border: Border.all(color: PusulaColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: PusulaColors.ink),
              child: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
                p.videoDuration == null
                    ? 'Tanışma videosu'
                    : 'Tanışma videosu · ${p.videoDuration}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PusulaColors.body)),
          ],
        ),
      ),
    );
  }

  Widget _credentials(ProviderProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Eğitim & belgeler', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 6),
        for (final c in p.credentials)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1EFEA))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('—',
                    style: TextStyle(
                        color: PusulaColors.primary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(c.title,
                      style: const TextStyle(
                          fontSize: 15, color: PusulaColors.slate)),
                ),
                const SizedBox(width: 16),
                Text(c.year,
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.faint)),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: PusulaColors.primarySoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
              '✓ Diploma ve adli sicil belgesi platform tarafından doğrulandı',
              style: TextStyle(
                  fontSize: 13, color: PusulaColors.primaryDark)),
        ),
      ],
    );
  }

  Widget _bordered(Widget child) => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: PusulaColors.border)),
        ),
        child: child,
      );

  Widget _header(
      BuildContext context, ProviderProfile p, VoidCallback onSeeReviews) {
    return Container(
      padding: const EdgeInsets.only(bottom: 26),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PusulaColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.type.labelTr.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PusulaColors.faint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Text(p.name,
              style: pusulaHeading(
                  fontSize: 36, fontWeight: FontWeight.w800, height: 1.12)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  text:
                      '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)} ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: PusulaColors.ink),
                  children: [
                    TextSpan(
                        text: '(${p.publishedReviews.length} değerlendirme)',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: PusulaColors.faint)),
                  ],
                ),
              ),
              const Text('·',
                  style: TextStyle(color: PusulaColors.body, fontSize: 14)),
              Text(p.city,
                  style: const TextStyle(
                      fontSize: 14, color: PusulaColors.body)),
              const Text('·',
                  style: TextStyle(color: PusulaColors.body, fontSize: 14)),
              InkWell(
                onTap: onSeeReviews,
                child: const Text('Yorumları gör',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PusulaColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in p.features.take(5))
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: PusulaColors.surface,
                    border: Border.all(color: PusulaColors.border),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(t,
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.slate)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _about(ProviderProfile p, bool isTeacher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isTeacher ? 'Hakkımda' : 'Kurum hakkında',
            style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 14),
        Text(p.description,
            style: const TextStyle(
                fontSize: 15, height: 1.75, color: PusulaColors.slate)),
      ],
    );
  }

  Widget _stats(ProviderProfile p, AppUser? owner, bool isTeacher) {
    final stats = isTeacher
        ? [
            ('${owner?.experienceYears ?? 0} yıl', 'Deneyim'),
            (p.avgRating == 0 ? '—' : '★ ${p.avgRating.toStringAsFixed(1)}',
                'Öğrenci puanı'),
            ('${p.publishedReviews.length}', 'Değerlendirme'),
            (formatPrice(p.monthlyPrice), 'Aylık başlangıç'),
          ]
        : [
            (p.avgRating == 0 ? '—' : '★ ${p.avgRating.toStringAsFixed(1)}',
                'Veli puanı'),
            ('${p.publishedReviews.length}', 'Değerlendirme'),
            ('${p.photoUrls.length}', 'Fotoğraf'),
            (formatPrice(p.monthlyPrice), 'Aylık başlangıç'),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sayılarla', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoCols = constraints.maxWidth < 560;
            final itemWidth =
                (constraints.maxWidth - (twoCols ? 16 : 48)) /
                    (twoCols ? 2 : 4);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final (val, label) in stats)
                  Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: PusulaColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(val,
                            style: pusulaHeading(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(label,
                            style: const TextStyle(
                                fontSize: 13, color: PusulaColors.muted)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _programs(ProviderProfile p, bool isTeacher) {
    // Type-specific layouts from the design: schools show a fee table
    // ("Ücretler"), teachers a 3-column package grid with the middle
    // card highlighted, dershane/kurs the 2-column program cards.
    if (p.type == ProviderType.privateSchool) return _feeTable(p);
    if (isTeacher) return _packages(p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Programlar', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth >= 560
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final prog in p.programs)
                  Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: PusulaColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(prog.title,
                                  style: pusulaHeading(
                                      fontSize: 16,
                                      letterSpacingFactor: -0.01)),
                            ),
                            const SizedBox(width: 12),
                            Text(prog.price,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(prog.description,
                            style: const TextStyle(
                                fontSize: 13,
                                color: PusulaColors.muted,
                                height: 1.6)),
                        if (prog.note.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(prog.note,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PusulaColors.primaryDark)),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// School fee table from the "Ilan Detay - Ozel Okul" design:
  /// level rows with right-aligned prices instead of program cards.
  Widget _feeTable(ProviderProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ücretler', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 6),
        const Text('Yemek ve servis hariç',
            style: TextStyle(fontSize: 13, color: PusulaColors.faint)),
        const SizedBox(height: 16),
        for (final prog in p.programs)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1EFEA))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(prog.title,
                      style: const TextStyle(
                          fontSize: 15, color: PusulaColors.slate)),
                ),
                Text(prog.price,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Text('Erken kayıt ve kardeş indirimi için teklif isteyin.',
            style: TextStyle(fontSize: 13, color: PusulaColors.muted)),
      ],
    );
  }

  /// Teacher lesson packages: 3-column grid, middle card highlighted
  /// (green border on #FAFCFB) and the price shown large under the title.
  Widget _packages(ProviderProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ders paketleri', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 620 ? 3 : 1;
            final itemWidth =
                (constraints.maxWidth - 16 * (cols - 1)) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (var i = 0; i < p.programs.length; i++)
                  Builder(builder: (context) {
                    final prog = p.programs[i];
                    final highlighted = p.programs.length >= 3 && i == 1;
                    return Container(
                      width: itemWidth,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: highlighted
                            ? const Color(0xFFFAFCFB)
                            : PusulaColors.card,
                        border: Border.all(
                            color: highlighted
                                ? PusulaColors.primary
                                : PusulaColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prog.title,
                              style: pusulaHeading(
                                  fontSize: 16,
                                  letterSpacingFactor: -0.01)),
                          const SizedBox(height: 6),
                          Text(prog.price,
                              style: pusulaHeading(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(prog.description,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: PusulaColors.muted,
                                  height: 1.6)),
                          if (prog.note.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(prog.note,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: PusulaColors.primaryDark)),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _facilities(ProviderProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Olanaklar', style: pusulaHeading(fontSize: 20)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth >= 480
                ? (constraints.maxWidth - 32) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 32,
              runSpacing: 12,
              children: [
                for (final f in p.features)
                  SizedBox(
                    width: itemWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('—',
                            style: TextStyle(
                                color: PusulaColors.primary,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: PusulaColors.slate,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _reviews(
      BuildContext context, ProviderProfile p, AppUser? user, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                  p.type == ProviderType.privateSchool
                      ? 'Veli değerlendirmeleri'
                      : 'Veli ve öğrenci değerlendirmeleri',
                  style: pusulaHeading(fontSize: 20)),
            ),
            Text.rich(
              TextSpan(
                text:
                    '★ ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)} ',
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                      text: '(${p.publishedReviews.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: PusulaColors.faint)),
                ],
              ),
            ),
          ],
        ),
        if (!isOwner && (user == null || user.role.isSeeker))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text('Puan Ver'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10)),
              onPressed: () {
                if (_requireLogin(context)) _showReviewDialog(context);
              },
            ),
          ),
        const SizedBox(height: 8),
        if (p.publishedReviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Henüz değerlendirme yok. İlk yorumu siz yazın!',
                style: TextStyle(color: PusulaColors.body)),
          ),
        for (final r in p.publishedReviews.reversed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: Color(0xFFF1EFEA))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: r.authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          children: [
                            TextSpan(
                              text: ' · ${formatDate(r.date)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: PusulaColors.faint),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text('★ ${r.stars}.0',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                if (r.comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(r.comment,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: PusulaColors.slate)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ---------- Sidebar ----------

  /// "₺1.500" — the design's price format with dotted thousands.
  static String _tl(double v) {
    final t = v.round().toString();
    final sb = StringBuffer('₺');
    for (var i = 0; i < t.length; i++) {
      if (i > 0 && (t.length - i) % 3 == 0) sb.write('.');
      sb.write(t[i]);
    }
    return sb.toString();
  }

  Widget _sidebar(BuildContext context, AppState app, ProviderProfile p,
      AppUser? user, bool isOwner, AppUser? owner) {
    final inCompare = app.isInCompare(p.id);
    final isTeacher = p.type == ProviderType.privateTeacher;
    // Guests get the seeker actions; auth is asked on tap where needed.
    final seekerish = user == null || user.role.isSeeker;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: PusulaColors.card,
            border: Border.all(color: PusulaColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teachers with a per-lesson price show it like the design
              // ("ders ücreti" + ₺550 /ders (60 dk)); others stay monthly.
              Text(
                  isTeacher && p.lessonPrice != null
                      ? 'ders ücreti'
                      : 'başlangıç',
                  style: const TextStyle(
                      fontSize: 13, color: PusulaColors.faint)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      isTeacher && p.lessonPrice != null
                          ? _tl(p.lessonPrice!)
                          : formatPrice(p.monthlyPrice),
                      style: pusulaHeading(
                          fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        isTeacher && p.lessonPrice != null
                            ? '/ders (60 dk)'
                            : '/ay',
                        style: const TextStyle(
                            fontSize: 14, color: PusulaColors.body)),
                  ),
                ],
              ),
              if (p.trialLesson) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: PusulaColors.primarySoft,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('Deneme dersi',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: PusulaColors.primaryDark)),
                ),
              ],
              if (p.highlight != null) ...[
                const SizedBox(height: 4),
                Text(p.highlight!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PusulaColors.primaryDark)),
              ],
              const SizedBox(height: 20),
              if (!isOwner && owner != null) ...[
                if (seekerish) ...[
                  Builder(builder: (context) {
                    // Design: primary CTA flips to "✓ ... gönderildi"
                    // once a request exists for this listing.
                    final offerSent = user != null &&
                        app.offers.any((o) =>
                            o.requesterId == user.id &&
                            o.providerId == p.id);
                    return FilledButton(
                      onPressed: () {
                        if (_requireLogin(context)) _showOfferDialog(context);
                      },
                      child: Text(offerSent
                          ? (isTeacher
                              ? '✓ Ders talebi gönderildi'
                              : '✓ Teklif isteği gönderildi')
                          : (isTeacher ? 'Ders talebi gönder' : 'Teklif iste')),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
                OutlinedButton(
                  onPressed: () {
                    if (_requireLogin(context)) _messageOwner(context, owner);
                  },
                  child: const Text('Mesaj gönder'),
                ),
                if (seekerish) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      final ok = context.read<AppState>().toggleCompare(p.id);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'En fazla 3 ilan karşılaştırabilirsiniz.')),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: inCompare
                            ? PusulaColors.primary
                            : PusulaColors.body),
                    child: Text(inCompare
                        ? '✓ Karşılaştırma listesinde'
                        : '+ Karşılaştırmaya ekle'),
                  ),
                ],
                const SizedBox(height: 14),
                Center(
                  child: Text(
                      'Ortalama yanıt süresi: ${switch (p.type) {
                        ProviderType.privateTeacher => '1 saat',
                        ProviderType.dershane ||
                        ProviderType.course =>
                          '2 saat',
                        ProviderType.privateSchool => '3 saat',
                      }}',
                      style: const TextStyle(
                          fontSize: 12, color: PusulaColors.faint)),
                ),
              ] else
                const Text('Bu sizin ilanınız.',
                    style:
                        TextStyle(fontSize: 13, color: PusulaColors.body)),
            ],
          ),
        ),
        if (p.hours.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: PusulaColors.card,
              border: Border.all(color: PusulaColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isTeacher ? 'Uygunluk' : 'Etüt merkezi saatleri',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                for (final h in p.hours)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Color(0xFFF1EFEA))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(h.day,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: PusulaColors.body)),
                        ),
                        Text(h.time,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: h.time == 'Dolu'
                                    ? PusulaColors.faint
                                    : PusulaColors.primaryDark)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (p.lessonModes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: PusulaColors.surface,
              border: Border.all(color: PusulaColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ders şekli',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                for (final m in p.lessonModes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(m.day,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: PusulaColors.body)),
                        ),
                        Text(m.time,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PusulaColors.primaryDark)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: PusulaColors.surface,
            border: Border.all(color: PusulaColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Konum',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: PusulaColors.patternA,
                  border: Border.all(color: PusulaColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.map_outlined,
                    color: PusulaColors.faint, size: 32),
              ),
              const SizedBox(height: 12),
              Text(p.address == null ? p.city : '${p.address}\n${p.city}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: PusulaColors.body,
                      height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Similar ----------

  Widget _similar(BuildContext context, AppState app, ProviderProfile p) {
    final similar = app.providers
        .where((o) => o.id != p.id)
        .toList()
      ..sort((a, b) {
        final sameA = a.type == p.type ? 0 : 1;
        final sameB = b.type == p.type ? 0 : 1;
        return sameA != sameB
            ? sameA.compareTo(sameB)
            : b.avgRating.compareTo(a.avgRating);
      });
    final items = similar.take(3).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final wide = MediaQuery.of(context).size.width >= 980;
    final isTeacher = p.type == ProviderType.privateTeacher;

    Widget teacherCard(ProviderProfile s) {
      return InkWell(
        onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(providerId: s.id)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: PusulaColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: s.photoUrls.isEmpty
                      ? Container(
                          color: PusulaColors.patternA,
                          child: const Icon(Icons.person_outline,
                              color: PusulaColors.faint))
                      : NetworkPhoto(url: s.photoUrls.first),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pusulaHeading(
                                  fontSize: 15,
                                  letterSpacingFactor: -0.01)),
                        ),
                        Text(
                            '★ ${s.avgRating == 0 ? '—' : s.avgRating.toStringAsFixed(1)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('${s.type.labelTr} · ${s.city}',
                        style: const TextStyle(
                            fontSize: 13, color: PusulaColors.muted)),
                    const SizedBox(height: 3),
                    Text('${formatPrice(s.monthlyPrice)}/ay',
                        style: const TextStyle(
                            fontSize: 13, color: PusulaColors.body)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget card(ProviderProfile s) {
      if (isTeacher) return teacherCard(s);
      return InkWell(
        onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(providerId: s.id)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: s.photoUrls.isEmpty
                  ? Container(
                      height: 160,
                      width: double.infinity,
                      color: PusulaColors.patternA,
                      alignment: Alignment.center,
                      child: const Icon(Icons.school_outlined,
                          color: PusulaColors.faint, size: 32),
                    )
                  : NetworkPhoto(
                      url: s.photoUrls.first,
                      height: 160,
                      width: double.infinity),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(s.name,
                      style: pusulaHeading(
                          fontSize: 16,
                          height: 1.35,
                          letterSpacingFactor: -0.01)),
                ),
                const SizedBox(width: 12),
                Text(
                    '★ ${s.avgRating == 0 ? '—' : s.avgRating.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('${s.type.labelTr} · ${s.city}',
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.muted)),
                ),
                Text('${formatPrice(s.monthlyPrice)}/ay',
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.body)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 64),
      padding: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PusulaColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isTeacher ? 'Benzer öğretmenler' : 'Benzer ilanlar',
              style: pusulaHeading(fontSize: 24)),
          const SizedBox(height: 28),
          wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 32),
                      Expanded(child: card(items[i])),
                    ],
                  ],
                )
              : Column(
                  children: [
                    for (final s in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: card(s),
                      ),
                  ],
                ),
        ],
      ),
    );
  }
}

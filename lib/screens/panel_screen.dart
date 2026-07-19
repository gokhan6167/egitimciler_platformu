import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/iller.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import 'pricing_screen.dart';
import 'provider_detail_screen.dart';

/// Status chip colors from the design: Yayında (green) →
/// Kaydedilmemiş değişiklikler (red) → Onay bekliyor (amber).
(String, Color, Color) panelStatusChip(ProviderProfile p) {
  if (p.hasUnsavedChanges) {
    return ('Kaydedilmemiş değişiklikler', const Color(0xFFB4423A),
        const Color(0xFFFBF0EF));
  }
  return switch (p.status) {
    ListingStatus.pending => (
        'Onay bekliyor',
        const Color(0xFF8A6212),
        const Color(0xFFFBF1DF)
      ),
    ListingStatus.published => (
        'Yayında',
        PusulaColors.primaryDark,
        PusulaColors.primarySoft
      ),
    ListingStatus.suspended => (
        'Askıda',
        const Color(0xFFB4423A),
        const Color(0xFFFBF0EF)
      ),
    ListingStatus.rejected => (
        'Reddedildi',
        const Color(0xFFB4423A),
        const Color(0xFFFBF0EF)
      ),
  };
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.provider});

  final ProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = panelStatusChip(provider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

/// One stat card of the 4-card strip shared by all panels.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: PusulaColors.muted)),
          const SizedBox(height: 6),
          Text(value, style: pusulaHeading(fontSize: 24)),
          const SizedBox(height: 4),
          Text(note,
              style: const TextStyle(
                  fontSize: 12, color: PusulaColors.primary)),
        ],
      ),
    );
  }
}

/// The listing management panel for schools, dershaneler, courses and
/// teachers ("Ozel Okul / Dershane / Kurs / Ogretmen Paneli" designs).
/// Feature groups come from the SAME admin-managed filter sections the
/// search pages use, so panel tags and search filters always match.
class ProviderPanelScreen extends StatefulWidget {
  const ProviderPanelScreen({super.key});

  @override
  State<ProviderPanelScreen> createState() => _ProviderPanelScreenState();
}

class _ProviderPanelScreenState extends State<ProviderPanelScreen> {
  String? _forProviderId;
  late TextEditingController _title;
  late TextEditingController _price;
  late TextEditingController _about;
  late TextEditingController _phone;
  late TextEditingController _address;

  @override
  void dispose() {
    if (_forProviderId != null) {
      _title.dispose();
      _price.dispose();
      _about.dispose();
      _phone.dispose();
      _address.dispose();
    }
    super.dispose();
  }

  void _bindControllers(ProviderProfile p) {
    if (_forProviderId == p.id) return;
    _forProviderId = p.id;
    final isTeacher = p.type == ProviderType.privateTeacher;
    _title = TextEditingController(text: p.name);
    _price = TextEditingController(
        text: (isTeacher ? (p.lessonPrice ?? 0) : p.monthlyPrice)
            .toStringAsFixed(0));
    _about = TextEditingController(text: p.description);
    _phone = TextEditingController(text: p.phone ?? '');
    _address = TextEditingController(text: p.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.myProvider;
    if (p == null) {
      return const Center(child: Text('Bu hesaba bağlı bir ilan yok.'));
    }
    _bindControllers(p);
    final wide = MediaQuery.of(context).size.width >= 1100;
    final stats = AppState.providerStats(p);
    final isTeacher = p.type == ProviderType.privateTeacher;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, app, p),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            StatCard(
                label: 'Görüntülenme · 30 gün',
                value: '${stats.views}',
                note: '▲ %12'),
            StatCard(
                label: isTeacher ? 'Ders talebi' : 'Teklif isteği',
                value: '${stats.offers}',
                note: '▲ ${(stats.offers / 4).round()} bu ay'),
            isTeacher
                ? StatCard(
                    label: 'Ortalama yanıt süresi',
                    value: '${AppState.responseMinutes(p.id)} dk',
                    note: 'hedef: 60 dk altı')
                : StatCard(
                    label: 'Karşılaştırmaya eklenme',
                    value: '${stats.compares}',
                    note: '▲ %9'),
            StatCard(
                label: 'Dönüşüm oranı',
                value: stats.conversion,
                note: 'sektör ort. %1,6'),
          ],
        ),
        const SizedBox(height: 22),
        _photosCard(app, p),
        const SizedBox(height: 14),
        _videoCard(app, p),
        const SizedBox(height: 14),
        _infoCard(app, p),
        const SizedBox(height: 14),
        _featuresCard(app, p),
        const SizedBox(height: 14),
        _contactCard(app, p),
        const SizedBox(height: 14),
        _kvkkNote(),
        const SizedBox(height: 24),
      ],
    );

    final preview = _previewCard(app, p);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: 24),
                    SizedBox(width: 330, child: preview),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [form, preview],
                ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppState app, ProviderProfile p) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Text('${p.type.labelTr} paneli', style: pusulaHeading(fontSize: 26)),
        StatusChip(provider: p),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(providerId: p.id))),
          child: Text(p.type == ProviderType.privateTeacher
              ? 'Profili görüntüle'
              : 'İlanı görüntüle'),
        ),
        FilledButton(
          onPressed: p.hasUnsavedChanges
              ? () {
                  app.submitMyProviderForReview();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Değişiklikler onaya gönderildi. Moderasyon '
                          'onayından sonra yayına alınır.')));
                }
              : null,
          child: const Text('Kaydet ve onaya gönder'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PricingScreen())),
          child: const Text('Paketler'),
        ),
      ],
    );
  }

  Widget _card({required String title, String? hint, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: pusulaHeading(fontSize: 17)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint,
                style: const TextStyle(
                    fontSize: 12.5, color: PusulaColors.muted)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _photosCard(AppState app, ProviderProfile p) {
    return _card(
      title: 'Fotoğraflar',
      hint: 'İlk fotoğraf kapak görseli olur. JPG / PNG · maks. 10 MB.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < p.photoUrls.length; i++)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkPhoto(
                      url: p.photoUrls[i], width: 130, height: 84),
                ),
                if (i == 0)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: PusulaColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('Kapak',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: InkWell(
                    onTap: () =>
                        app.removePhotoFromMyProvider(p.photoUrls[i]),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: const Text('✕',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          InkWell(
            onTap: () => app.addPhotoToMyProvider(
                'https://picsum.photos/seed/${p.id}${p.photoUrls.length + 1}/640/360'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 130,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: PusulaColors.borderDark,
                    style: BorderStyle.solid),
                color: PusulaColors.surface,
              ),
              alignment: Alignment.center,
              child: const Text('+ Fotoğraf yükle',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: PusulaColors.body)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(AppState app, ProviderProfile p) {
    return _card(
      title: 'Tanıtım videosu',
      hint:
          'Maksimum 2 dakika. Videolu ilanlar %60 daha fazla teklif isteği alır.',
      child: p.videoUrl != null
          ? Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PusulaColors.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${Uri.parse(p.videoUrl!).pathSegments.isNotEmpty ? Uri.parse(p.videoUrl!).pathSegments.last : p.videoUrl!}'
                    '${p.videoDuration != null ? ' · ${p.videoDuration}' : ''}',
                    style: const TextStyle(fontSize: 13.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Videoyu kaldır',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => app.updateMyProvider(videoUrl: ''),
                ),
              ],
            )
          : InkWell(
              onTap: () => app.updateMyProvider(
                  videoUrl: 'https://example.com/video/tanitim.mp4'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PusulaColors.borderDark),
                  color: PusulaColors.surface,
                ),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Text('+ Video yükle',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: PusulaColors.body)),
                    SizedBox(height: 4),
                    Text('MP4 · maks. 2 dk / 200 MB',
                        style: TextStyle(
                            fontSize: 12, color: PusulaColors.faint)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoCard(AppState app, ProviderProfile p) {
    final isTeacher = p.type == ProviderType.privateTeacher;
    return _card(
      title: 'İlan bilgileri',
      child: Column(
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'İlan başlığı'),
            onChanged: (v) => app.updateMyProvider(name: v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            decoration: InputDecoration(
              labelText: isTeacher
                  ? 'Ders ücreti (60 dk)'
                  : 'Aylık ücret (başlangıç)',
              prefixText: '₺ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final price = double.tryParse(v.replaceAll('.', ''));
              if (price == null) return;
              if (isTeacher) {
                app.updateMyProvider(lessonPrice: price);
              } else {
                app.updateMyProvider(monthlyPrice: price);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _about,
            decoration: InputDecoration(
                labelText:
                    isTeacher ? 'Kendinizi tanıtın' : 'Kurum tanıtımı'),
            maxLines: 4,
            onChanged: (v) => app.updateMyProvider(description: v),
          ),
          if (isTeacher) ...[
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ücretsiz deneme dersi sunuyorum'),
              value: p.trialLesson,
              onChanged: (v) => app.updateMyProvider(trialLesson: v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _featuresCard(AppState app, ProviderProfile p) {
    final config = app.configFor(p.type);
    final sections =
        config?.sections.where((s) => s.active).toList() ?? const [];
    return _card(
      title: 'İlan özellikleri',
      hint:
          'Arama filtreleriyle birebir eşleşir; veliler bu özelliklere göre süzer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in sections) ...[
            Row(
              children: [
                Text(s.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Text(
                  s.kind == FilterKind.radio
                      ? '· tek seçim'
                      : '· birden fazla seçilebilir',
                  style: const TextStyle(
                      fontSize: 12, color: PusulaColors.faint),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in s.options)
                  _featurePill(app, p, s, o),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _featurePill(
      AppState app, ProviderProfile p, FilterSection s, String option) {
    final selected = p.features.contains(option);
    return InkWell(
      onTap: () => s.kind == FilterKind.radio
          ? app.selectMyProviderFeature(s, option)
          : app.toggleMyProviderFeature(option),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? PusulaColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected
                  ? PusulaColors.primary
                  : PusulaColors.borderDark),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected ? PusulaColors.primaryDark : PusulaColors.body,
          ),
        ),
      ),
    );
  }

  Widget _contactCard(AppState app, ProviderProfile p) {
    return _card(
      title: 'İletişim & konum',
      child: Column(
        children: [
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Telefon'),
            onChanged: (v) => app.updateMyProvider(phone: v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: iller.contains(p.city) ? p.city : null,
                  decoration: const InputDecoration(labelText: 'İl'),
                  items: [
                    for (final il in iller)
                      DropdownMenuItem(value: il, child: Text(il)),
                  ],
                  onChanged: (v) =>
                      app.updateMyProvider(city: v, district: ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: (ilceler[p.city] ?? const [])
                          .contains(p.district)
                      ? p.district
                      : null,
                  decoration: const InputDecoration(labelText: 'İlçe'),
                  items: [
                    for (final ilce in ilceler[p.city] ?? const <String>[])
                      DropdownMenuItem(value: ilce, child: Text(ilce)),
                  ],
                  onChanged: (v) => app.updateMyProvider(district: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Adres'),
            onChanged: (v) => app.updateMyProvider(address: v),
          ),
        ],
      ),
    );
  }

  Widget _kvkkNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PusulaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PusulaColors.border),
      ),
      child: const Text(
        'Belge alanlarına yüklediğiniz dosyalar yalnızca doğrulama amacıyla '
        'işlenir; üyelik sona erdiğinde 6 ay içinde silinir (KVKK).',
        style: TextStyle(fontSize: 12.5, color: PusulaColors.muted),
      ),
    );
  }

  Widget _previewCard(AppState app, ProviderProfile p) {
    final isTeacher = p.type == ProviderType.privateTeacher;
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
          Text('Arama kartı önizlemesi',
              style: pusulaHeading(fontSize: 15)),
          const SizedBox(height: 12),
          if (p.photoUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkPhoto(
                  url: p.photoUrls.first,
                  width: double.infinity,
                  height: 150),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PusulaColors.primarySoft,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('✓ ${p.badge}',
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: PusulaColors.primaryDark)),
              ),
              if (p.videoDuration != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PusulaColors.ink,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('▶ ${p.videoDuration}',
                      style: const TextStyle(
                          fontSize: 11.5, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.name, style: pusulaHeading(fontSize: 17)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 15, color: Colors.amber),
              Text(
                ' ${p.avgRating == 0 ? '—' : p.avgRating.toStringAsFixed(1)}'
                '  (${p.publishedReviews.length})',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${p.type.labelTr}${p.district.isNotEmpty ? ' · ${p.district}' : ''}, ${p.city}',
                  style: const TextStyle(
                      fontSize: 12.5, color: PusulaColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in p.features.take(6))
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PusulaColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: PusulaColors.border),
                  ),
                  child: Text(f,
                      style: const TextStyle(
                          fontSize: 11.5, color: PusulaColors.body)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, height: 1.45, color: PusulaColors.body),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                        text: isTeacher
                            ? formatPrice(p.lessonPrice ?? 0)
                                .replaceAll(' TL', ' ₺')
                            : formatPrice(p.monthlyPrice)
                                .replaceAll(' TL', ' ₺'),
                        style: pusulaHeading(fontSize: 18)),
                    TextSpan(
                      text: isTeacher ? ' /ders (60 dk)' : ' /aydan başlayan',
                      style: const TextStyle(
                          fontSize: 12, color: PusulaColors.muted),
                    ),
                  ],
                )),
              ),
              FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  disabledBackgroundColor: PusulaColors.primary,
                  disabledForegroundColor: Colors.white,
                ),
                child: Text(isTeacher ? 'Ders talebi →' : 'Teklif iste →',
                    style: const TextStyle(fontSize: 13)),
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
              '✓ Seçtiğiniz özellikler ilan etiketlerinize ve arama filtresi '
              'eşleşmelerine yansır. Değişiklikler moderasyon onayından '
              'sonra yayına alınır.',
              style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: PusulaColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

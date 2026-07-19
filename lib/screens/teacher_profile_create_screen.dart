import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/iller.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/showcase.dart';
import 'home_shell.dart';

class _PackageRow {
  _PackageRow(String name, String price)
      : name = TextEditingController(text: name),
        price = TextEditingController(text: price);

  final TextEditingController name;
  final TextEditingController price;

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

/// "Ogretmen Profili Olustur" — 5-step form with live profile preview.
/// Publishing registers a teacher account (demo) and creates a pending
/// listing that goes through admin review.
class TeacherProfileCreateScreen extends StatefulWidget {
  const TeacherProfileCreateScreen({super.key});

  @override
  State<TeacherProfileCreateScreen> createState() =>
      _TeacherProfileCreateScreenState();
}

class _TeacherProfileCreateScreenState
    extends State<TeacherProfileCreateScreen> {
  final _name = TextEditingController();
  final _about = TextEditingController();
  final _price = TextEditingController(text: '900');
  final List<_PackageRow> _packages = [
    _PackageRow('Tek ders', '900'),
    _PackageRow('8 ders paketi', '6.800'),
  ];

  static const _branches = [
    'Matematik',
    'Fizik',
    'Kimya',
    'İngilizce',
    'Türkçe & Edebiyat',
    'Biyoloji',
  ];
  static const _expOptions = ['0–2 yıl', '3–5 yıl', '5–10 yıl', '10+ yıl'];
  static const _levelOptions = [
    'İlkokul (1–4)',
    'Ortaokul (5–8)',
    'Lise (9–12)',
    'LGS / YKS hazırlık',
  ];
  static const _formatOptions = ['Evde ders', 'Online'];
  static const _availOptions = ['Hafta içi', 'Hafta sonu', 'Akşam'];
  static const _docs = ['Diploma', 'Formasyon belgesi', 'Adli sicil kaydı'];

  String _branch = _branches.first;
  String _experience = _expOptions[1];
  final Set<String> _levels = {'Ortaokul (5–8)'};
  final Set<String> _formats = {'Evde ders'};
  final Set<String> _avail = {'Hafta içi'};
  String? _city;
  final Set<String> _districts = {};
  final Set<String> _uploadedDocs = {};
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _price.dispose();
    for (final p in _packages) {
      p.dispose();
    }
    super.dispose();
  }

  int get _experienceYears =>
      switch (_experience) { '0–2 yıl' => 1, '3–5 yıl' => 4, '5–10 yıl' => 7, _ => 12 };

  List<String> get _selectedTags =>
      [..._levels, ..._formats, ..._avail];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 1100;
    final form = _form(context);
    final preview = _preview();

    return ShowcaseScaffold(
      maxWidth: 1180,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('← Öğretmen kariyeri'),
        ),
      ],
      children: [
        const PageIntro(
          title: 'Öğretmen profili oluştur',
          lead: Text(
            'Profiliniz yalnızca öğrenci arayan veliler ile öğretmen arayan '
            'kurumlara gösterilir. Belge doğrulaması tamamlanınca ✓ rozeti '
            'alırsınız.',
            style: TextStyle(fontSize: 15, color: PusulaColors.body),
          ),
        ),
        wide
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
                children: [form, const SizedBox(height: 20), preview],
              ),
      ],
    );
  }

  Widget _sectionCard(String title, {String? hint, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: pusulaHeading(fontSize: 16)),
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

  Widget _pillGroup(String title, List<String> options, Set<String> selected,
      {bool single = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              InkWell(
                onTap: () => setState(() {
                  if (single) selected.clear();
                  selected.contains(o)
                      ? selected.remove(o)
                      : selected.add(o);
                }),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected.contains(o)
                        ? PusulaColors.primarySoft
                        : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: selected.contains(o)
                            ? PusulaColors.primary
                            : PusulaColors.borderDark),
                  ),
                  child: Text(o,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected.contains(o)
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected.contains(o)
                            ? PusulaColors.primaryDark
                            : PusulaColors.body,
                      )),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard('1 · Temel bilgiler', child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _branch,
                    decoration: const InputDecoration(labelText: 'Branş'),
                    items: [
                      for (final b in _branches)
                        DropdownMenuItem(value: b, child: Text(b)),
                    ],
                    onChanged: (v) =>
                        setState(() => _branch = v ?? _branch),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _experience,
                    decoration:
                        const InputDecoration(labelText: 'Deneyim'),
                    items: [
                      for (final e in _expOptions)
                        DropdownMenuItem(value: e, child: Text(e)),
                    ],
                    onChanged: (v) =>
                        setState(() => _experience = v ?? _experience),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _about,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Hakkımda'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        )),
        _sectionCard(
          '2 · Ders kriterleri',
          hint: 'Bu kriterler profilinizde etiket olarak görünür ve arama '
              'filtreleriyle eşleşir.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pillGroup('Seviye', _levelOptions, _levels),
              _pillGroup('Ders şekli', _formatOptions, _formats),
              _pillGroup('Uygunluk', _availOptions, _avail),
            ],
          ),
        ),
        _sectionCard(
          '3 · Konum & ücret',
          hint: 'Yüz yüze ders verdiğiniz bölgeleri seçin; online dersler '
              'tüm Türkiye\'ye açıktır.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _city,
                      decoration: const InputDecoration(labelText: 'İl'),
                      items: [
                        for (final il in iller)
                          DropdownMenuItem(value: il, child: Text(il)),
                      ],
                      onChanged: (v) => setState(() {
                        _city = v;
                        _districts.clear();
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Ders ücreti (60 dk)',
                          prefixText: '₺ '),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_city != null) ...[
                const SizedBox(height: 12),
                _pillGroup('İlçeler · birden fazla seçilebilir',
                    ilceler[_city] ?? const [], _districts),
              ],
            ],
          ),
        ),
        _sectionCard(
          '4 · Ders paketleri & teklifler',
          hint: 'Velilere sunacağınız hazır paketler. Öğrenci ilanlarına '
              'teklif verirken bu paketlerden seçebilirsiniz.',
          child: Column(
            children: [
              for (var i = 0; i < _packages.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _packages[i].name,
                          decoration: const InputDecoration(
                              labelText: 'Paket adı', isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _packages[i].price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Fiyat',
                              prefixText: '₺ ',
                              isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Paketi sil',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _packages.length <= 1
                            ? null
                            : () => setState(
                                () => _packages.removeAt(i).dispose()),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(
                      () => _packages.add(_PackageRow('', ''))),
                  child: const Text('+ Teklif ekle'),
                ),
              ),
            ],
          ),
        ),
        _sectionCard(
          '5 · Belgeler',
          hint: 'Doğrulama rozeti için gereklidir; yalnızca moderasyon ekibi '
              'görür. KVKK gereği belgeler sadece doğrulama amacıyla '
              'işlenir, üyelik sona erdiğinde 6 ay içinde kalıcı olarak '
              'silinir.',
          child: Column(
            children: [
              for (final d in _docs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(d,
                              style: const TextStyle(fontSize: 14))),
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => _uploadedDocs.add(d)),
                        child: Text(_uploadedDocs.contains(d)
                            ? '✓ Yüklendi'
                            : 'PDF / JPG yükle'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_submitted)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PusulaColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '✓ Profiliniz onaya gönderildi. Belge doğrulaması genellikle '
              '2 iş günü içinde tamamlanır; sonuç e-posta ile bildirilir.',
              style: TextStyle(
                  fontSize: 13, color: PusulaColors.primaryDark),
            ),
          ),
        FilledButton(
          onPressed: _submitted ? null : () => _publish(context),
          child: Text(_submitted
              ? '✓ Onaya gönderildi'
              : 'Profili yayınla (onaya gönder)'),
        ),
      ],
    );
  }

  void _publish(BuildContext context) {
    final app = context.read<AppState>();
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen ad soyad girin.')));
      return;
    }
    final me = app.currentUser;
    if (me == null || me.role != UserRole.teacher) {
      app.registerUser(
        name: _name.text.trim(),
        role: UserRole.teacher,
        city: _city ?? '',
        subject: _branch,
        bio: _about.text.trim(),
        experienceYears: _experienceYears,
      );
    }
    app.updateMyProvider(
      name: '${_name.text.trim()} — $_branch',
      description: _about.text.trim(),
      city: _city,
      district: _districts.isNotEmpty ? _districts.first : null,
      lessonPrice: double.tryParse(
          _price.text.replaceAll('.', '').replaceAll(',', '.')),
    );
    for (final tag in _selectedTags) {
      if (!(app.myProvider?.features.contains(tag) ?? true)) {
        app.toggleMyProviderFeature(tag);
      }
    }
    app.setMyProviderPrograms([
      for (final p in _packages)
        if (p.name.text.trim().isNotEmpty)
          ProgramItem(
              title: p.name.text.trim(),
              price: '${p.price.text.trim()} TL',
              description: ''),
    ]);
    app.submitMyProviderForReview();
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Profiliniz oluşturuldu ve onaya gönderildi.'),
      action: SnackBarAction(
        label: 'Panele git',
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (_) => false,
        ),
      ),
    ));
  }

  Widget _preview() {
    final name = _name.text.trim().isEmpty ? 'Adınız' : _name.text.trim();
    final initials = name.split(' ').take(2).map((w) =>
        w.isEmpty ? '' : w.characters.first.toUpperCase()).join();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil önizleme', style: pusulaHeading(fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: PusulaColors.primarySoft,
                child: Text(initials,
                    style: const TextStyle(
                        color: PusulaColors.primaryDark,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: pusulaHeading(fontSize: 16)),
                    Text(
                      '$_branch · $_experience'
                      '${_city != null ? ' · $_city' : ''}',
                      style: const TextStyle(
                          fontSize: 12.5, color: PusulaColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: '₺${_price.text.trim().isEmpty ? '—' : _price.text.trim()}',
                style: pusulaHeading(fontSize: 18)),
            const TextSpan(
                text: ' /ders (60 dk)',
                style:
                    TextStyle(fontSize: 12, color: PusulaColors.muted)),
          ])),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in _selectedTags)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PusulaColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: PusulaColors.border),
                  ),
                  child: Text(t,
                      style: const TextStyle(
                          fontSize: 11.5, color: PusulaColors.body)),
                ),
            ],
          ),
          if (_about.text.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_about.text.trim(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, height: 1.45,
                    color: PusulaColors.body)),
          ],
          const SizedBox(height: 12),
          Text('Teklifler', style: pusulaHeading(fontSize: 13.5)),
          const SizedBox(height: 6),
          for (final p in _packages)
            if (p.name.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(p.name.text,
                            style: const TextStyle(fontSize: 13))),
                    Text('₺${p.price.text}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          const SizedBox(height: 10),
          const Text(
            'Önizleme, velilerin ve kurumların profilinizi nasıl '
            'göreceğini gösterir.',
            style: TextStyle(fontSize: 12, color: PusulaColors.faint),
          ),
        ],
      ),
    );
  }
}

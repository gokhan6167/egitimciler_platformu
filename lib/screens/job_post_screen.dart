import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/iller.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/showcase.dart';
import 'login_screen.dart';

class _PositionRow {
  _PositionRow(String title, this.branch, this.type)
      : titleCtl = TextEditingController(text: title);

  final TextEditingController titleCtl;
  String branch;
  String type;

  void dispose() => titleCtl.dispose();
}

/// "Kurum Is Ilani Ver" — multi-position job posting form. Each position
/// publishes as its own listing, visible ONLY to teacher accounts.
class JobPostScreen extends StatefulWidget {
  const JobPostScreen({super.key});

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  static const _branches = [
    'Matematik',
    'Fizik',
    'Kimya',
    'İngilizce',
    'Türkçe & Edebiyat',
    'Biyoloji',
    'Sınıf Öğretmenliği',
    'Rehberlik',
  ];
  static const _types = ['Tam zamanlı', 'Yarı zamanlı', 'Ders başı'];
  static const _benefitOptions = [
    'Yemek',
    'Servis',
    'SGK + özel sağlık',
    'Eğitim desteği',
    'Prim',
    'Esnek çalışma saatleri',
  ];

  final _orgName = TextEditingController();
  final _salaryMin = TextEditingController(text: '45.000');
  final _salaryMax = TextEditingController(text: '60.000');
  final _description = TextEditingController();
  String? _city;
  String? _district;
  final Set<String> _benefits = {'Yemek', 'Servis'};
  final List<_PositionRow> _positions = [
    _PositionRow('Matematik Öğretmeni', 'Matematik', 'Tam zamanlı'),
  ];
  bool _submitted = false;

  @override
  void dispose() {
    _orgName.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    _description.dispose();
    for (final p in _positions) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;
    if (me != null &&
        me.role == UserRole.institution &&
        _orgName.text.isEmpty) {
      _orgName.text = me.name;
    }
    final wide = MediaQuery.of(context).size.width >= 1100;
    final form = _form(app);
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
          title: 'Kurum olarak iş ilanı ver',
          lead: Text(
            'İlanınız yalnızca öğretmen hesaplarına gösterilir; başvurular '
            'tek panelde toplanır. Doğrulanmış kurumların ilanları öne '
            'çıkar.',
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

  Widget _card(String title, {String? hint, required Widget child}) {
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

  Widget _form(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card('1 · Kurum bilgileri', child: Column(
          children: [
            TextField(
              controller: _orgName,
              decoration: const InputDecoration(labelText: 'Kurum adı'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
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
                      _district = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _district,
                    decoration: const InputDecoration(labelText: 'İlçe'),
                    items: [
                      for (final ilce in ilceler[_city] ?? const <String>[])
                        DropdownMenuItem(value: ilce, child: Text(ilce)),
                    ],
                    onChanged: (v) => setState(() => _district = v),
                  ),
                ),
              ],
            ),
          ],
        )),
        _card(
          '2 · Açık pozisyonlar',
          hint: 'Her pozisyon ayrı ilan olarak yayımlanır.',
          child: Column(
            children: [
              for (var i = 0; i < _positions.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PusulaColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PusulaColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _positions[i].titleCtl,
                              decoration: const InputDecoration(
                                  labelText: 'Pozisyon başlığı',
                                  isDense: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Pozisyonu sil',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: _positions.length <= 1
                                ? null
                                : () => setState(() =>
                                    _positions.removeAt(i).dispose()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _positions[i].branch,
                              decoration: const InputDecoration(
                                  labelText: 'Branş', isDense: true),
                              items: [
                                for (final b in _branches)
                                  DropdownMenuItem(
                                      value: b, child: Text(b)),
                              ],
                              onChanged: (v) => setState(() =>
                                  _positions[i].branch = v ?? 'Matematik'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _positions[i].type,
                              decoration: const InputDecoration(
                                  labelText: 'Çalışma türü',
                                  isDense: true),
                              items: [
                                for (final t in _types)
                                  DropdownMenuItem(
                                      value: t, child: Text(t)),
                              ],
                              onChanged: (v) => setState(() =>
                                  _positions[i].type = v ?? _types.first),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _positions.add(
                      _PositionRow('', _branches.first, _types.first))),
                  child: const Text('+ Pozisyon ekle'),
                ),
              ),
            ],
          ),
        ),
        _card(
          '3 · Teklif (maaş & olanaklar)',
          hint: 'Maaş aralığı belirten ilanlar 3 kat daha fazla başvuru alır.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _salaryMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Aylık maaş — alt sınır',
                          prefixText: '₺ '),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _salaryMax,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Aylık maaş — üst sınır',
                          prefixText: '₺ '),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Yan olanaklar',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in _benefitOptions)
                    FilterChip(
                      label: Text(b),
                      selected: _benefits.contains(b),
                      showCheckmark: false,
                      onSelected: (_) => setState(() =>
                          _benefits.contains(b)
                              ? _benefits.remove(b)
                              : _benefits.add(b)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _description,
                maxLines: 4,
                decoration:
                    const InputDecoration(labelText: 'İlan açıklaması'),
                onChanged: (_) => setState(() {}),
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
              '✓ İlanınız onaya gönderildi. Yayına alındığında yalnızca '
              'öğretmen hesaplarına gösterilecek ve uygun adaylara bildirim '
              'gidecek.',
              style: TextStyle(
                  fontSize: 13, color: PusulaColors.primaryDark),
            ),
          ),
        FilledButton(
          onPressed: _submitted ? null : () => _publish(app),
          child: Text(_submitted
              ? '✓ Onaya gönderildi'
              : 'İlanı yayınla (onaya gönder)'),
        ),
      ],
    );
  }

  String get _salaryText =>
      '${_salaryMin.text.trim()} - ${_salaryMax.text.trim()} TL';

  void _publish(AppState app) {
    final me = app.currentUser;
    if (me == null || me.role != UserRole.institution) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'İş ilanı vermek için kurum hesabıyla giriş yapmalısınız.'),
        action: SnackBarAction(
          label: 'Giriş yap',
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      ));
      return;
    }
    var created = 0;
    for (final p in _positions) {
      final title = p.titleCtl.text.trim();
      if (title.isEmpty) continue;
      app.createJob(
        title: title,
        subject: p.branch,
        city: _city ?? me.city,
        salaryText: '$_salaryText · ${p.type}',
        description: _description.text.trim(),
        benefits: _benefits.toList(),
      );
      created++;
    }
    if (created == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('En az bir pozisyon başlığı girin.')));
      return;
    }
    setState(() => _submitted = true);
  }

  Widget _preview() {
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
          Text('İlan önizleme', style: pusulaHeading(fontSize: 15)),
          const SizedBox(height: 12),
          for (final p in _positions)
            if (p.titleCtl.text.trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PusulaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PusulaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.titleCtl.text.trim(),
                              style: pusulaHeading(fontSize: 14.5)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF1DF),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(p.type,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8A6212))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_orgName.text.trim().isEmpty ? 'Kurumunuz' : _orgName.text.trim()}'
                      '${_district != null ? ' · $_district' : ''}'
                      '${_city != null ? ', $_city' : ''}',
                      style: const TextStyle(
                          fontSize: 12.5, color: PusulaColors.body),
                    ),
                    const SizedBox(height: 6),
                    Text('₺$_salaryText',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final b in _benefits)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(color: PusulaColors.border),
                            ),
                            child: Text(b,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: PusulaColors.body)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        disabledBackgroundColor: PusulaColors.primary,
                        disabledForegroundColor: Colors.white,
                      ),
                      child: const Text('Başvur',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 4),
          const Text(
            'Önizleme, öğretmenlerin kariyer sayfasında göreceği ilan '
            'kartlarını gösterir.',
            style: TextStyle(fontSize: 12, color: PusulaColors.faint),
          ),
        ],
      ),
    );
  }
}

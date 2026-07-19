import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/showcase.dart';
import 'job_post_screen.dart';
import 'login_screen.dart';
import 'pricing_screen.dart';
import 'teacher_profile_create_screen.dart';

/// "Ogretmen Kariyeri" — public landing for the closed hiring network.
/// Job cards are teasers; applying requires a signed-in teacher account.
class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  String? _branchFilter;
  String? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;
    final isTeacher = me?.role == UserRole.teacher;

    var jobs = app.jobs.where((j) => j.active).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_branchFilter != null) {
      jobs = jobs.where((j) => j.subject == _branchFilter).toList();
    }
    if (_typeFilter != null) {
      jobs = jobs
          .where((j) => j.salaryText.contains(_typeFilter!) ||
              (_typeFilter == 'Tam zamanlı' &&
                  !j.salaryText.contains('zamanlı') &&
                  !j.salaryText.contains('başı')))
          .toList();
    }
    final branches = app.jobs.map((j) => j.subject).toSet().toList()..sort();

    return ShowcaseScaffold(
      maxWidth: 940,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PricingScreen())),
          child: const Text('Ücretlendirme'),
        ),
      ],
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: PusulaColors.ink,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text('Kapalı ağ · Veli ve öğrencilere kapalıdır',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 14),
        const PageIntro(
          title: 'Öğretmen kariyeri',
          lead: Text(
            'Kurumların iş ilanlarını yalnızca öğretmenler görür; iş arayan '
            'öğretmen profillerini yalnızca öğretmen arayan kurumlar görür.',
            style: TextStyle(fontSize: 16, color: PusulaColors.body),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TeacherProfileCreateScreen())),
              child: const Text('Öğretmen profili oluştur'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE0A43B)),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobPostScreen())),
              child: const Text('Kurum olarak iş ilanı ver'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${app.jobs.where((j) => j.active).length + 410} açık pozisyon · '
          '9.800+ doğrulanmış öğretmen · %92 yanıt oranı',
          style: const TextStyle(fontSize: 13.5, color: PusulaColors.muted),
        ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Açık pozisyonlar', style: pusulaHeading(fontSize: 22)),
            const SizedBox(width: 10),
            Text('${jobs.length} ilan gösteriliyor',
                style: const TextStyle(
                    fontSize: 13, color: PusulaColors.muted)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in branches)
              FilterChip(
                label: Text(b),
                selected: _branchFilter == b,
                showCheckmark: false,
                onSelected: (_) => setState(
                    () => _branchFilter = _branchFilter == b ? null : b),
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (final j in jobs) _jobCard(app, j, isTeacher),
        if (jobs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Bu filtreyle açık pozisyon bulunamadı.',
                style: TextStyle(color: PusulaColors.muted)),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PusulaColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '✓ Başvurular yalnızca ilgili kuruma iletilir; profiliniz veli '
            've öğrencilere görünmez. Başvurmak için doğrulanmış öğretmen '
            'hesabı gerekir.',
            style:
                TextStyle(fontSize: 13, color: PusulaColors.primaryDark),
          ),
        ),
        const SizedBox(height: 34),
        LayoutBuilder(builder: (context, c) {
          final twoCol = c.maxWidth > 700;
          final cards = [
            _audienceCard(
              title: 'Öğretmenler için',
              body: 'Profilinizi oluşturun, belgelerinizi doğrulatın; '
                  'branşınıza uygun ilanları görün ve gizli başvurun.',
              bullets: const [
                'Belge doğrulama rozetiyle öne çıkın',
                'Branş ve şehre göre ilan bildirimleri alın',
                'Özel ders ilanı vererek öğrenci bulun',
              ],
              cta: 'Öğretmen profili oluştur →',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TeacherProfileCreateScreen())),
            ),
            _audienceCard(
              title: 'Kurumlar için',
              body: 'İş ilanı açın, başvuruları tek panelden yönetin, '
                  'doğrulanmış öğretmen havuzunda arama yapın.',
              bullets: const [
                'Branş, deneyim ve şehre göre aday süzün',
                'Adayların doğrulanmış belgelerini görün',
                'İlanınız yalnızca öğretmenlere gösterilir',
              ],
              cta: 'İş ilanı ver →',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobPostScreen())),
            ),
          ];
          return twoCol
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 16),
                    Expanded(child: cards[1]),
                  ],
                )
              : Column(children: [
                  cards[0],
                  const SizedBox(height: 16),
                  cards[1],
                ]);
        }),
      ],
    );
  }

  Widget _jobCard(AppState app, JobPosting j, bool isTeacher) {
    final me = app.currentUser;
    final applied = me != null && j.applicantUserIds.contains(me.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(j.title, style: pusulaHeading(fontSize: 16)),
                const SizedBox(height: 3),
                Text('${j.institutionName} · ${j.city}',
                    style: const TextStyle(
                        fontSize: 13, color: PusulaColors.body)),
                if (j.benefits.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final b in j.benefits)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PusulaColors.surface,
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
                ],
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(j.salaryText,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              isTeacher
                  ? (applied
                      ? const OutlinedButton(
                          onPressed: null, child: Text('✓ Başvuruldu'))
                      : FilledButton(
                          onPressed: () {
                            app.applyToJob(j);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Başvurunuz yalnızca '
                                        'ilgili kuruma iletildi.')));
                          },
                          child: const Text('Başvur')))
                  : OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text('Öğretmen girişiyle başvur'),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _audienceCard({
    required String title,
    required String body,
    required List<String> bullets,
    required String cta,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PusulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: pusulaHeading(fontSize: 18)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: PusulaColors.body)),
          const SizedBox(height: 10),
          for (final b in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('— $b',
                  style: const TextStyle(
                      fontSize: 13.5, color: PusulaColors.body)),
            ),
          const SizedBox(height: 10),
          TextButton(onPressed: onTap, child: Text(cta)),
        ],
      ),
    );
  }
}

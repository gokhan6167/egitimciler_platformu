import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Teachers: browse and apply to job postings (only teachers can see them).
/// Institutions: manage their own postings and see applicants.
class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  void _showCreateJobDialog(BuildContext context) {
    final title = TextEditingController();
    final subject = TextEditingController();
    final city = TextEditingController();
    final salary = TextEditingController();
    final description = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Yeni İş İlanı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Başlık')),
              TextField(
                  controller: subject,
                  decoration: const InputDecoration(labelText: 'Branş')),
              TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'Şehir')),
              TextField(
                  controller: salary,
                  decoration:
                      const InputDecoration(labelText: 'Maaş (metin)')),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              context.read<AppState>().createJob(
                    title: title.text.trim(),
                    subject: subject.text.trim(),
                    city: city.text.trim(),
                    salaryText: salary.text.trim(),
                    description: description.text.trim(),
                  );
              Navigator.pop(dialogCtx);
            },
            child: const Text('Yayınla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;

    // Defensive visibility check: this screen is reachable only for
    // teachers and institutions, but guard anyway.
    if (user.role == UserRole.teacher) return _teacherView(context, app);
    if (user.role == UserRole.institution) {
      return _institutionView(context, app);
    }
    return const Center(
        child: Text('İş ilanları yalnızca öğretmenler ve kurumlar içindir.'));
  }

  Widget _teacherView(BuildContext context, AppState app) {
    final jobs = app.visibleJobs;
    final me = app.currentUser!;

    return Column(
      children: [
        SwitchListTile(
          title: const Text('İş arıyorum'),
          subtitle: const Text(
              'Açıkken profiliniz öğretmen arayan kurumlara görünür.'),
          value: me.seekingJob,
          onChanged: (v) => context.read<AppState>().setSeekingJob(v),
        ),
        const Divider(height: 1),
        Expanded(
          child: jobs.isEmpty
              ? const Center(child: Text('Şu anda açık iş ilanı yok.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: jobs.length,
                  itemBuilder: (context, i) {
                    final job = jobs[i];
                    final applied = job.applicantUserIds.contains(me.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                '${job.institutionName} • ${job.city} • ${job.subject}',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(job.description),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.payments,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(job.salaryText),
                                const Spacer(),
                                Text(formatDate(job.createdAt),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              icon: Icon(
                                  applied ? Icons.check : Icons.send),
                              label: Text(
                                  applied ? 'Başvuruldu' : 'Başvur'),
                              onPressed: applied
                                  ? null
                                  : () {
                                      context
                                          .read<AppState>()
                                          .applyToJob(job);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Başvurunuz iletildi.')));
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _institutionView(BuildContext context, AppState app) {
    final jobs = app.myJobPostings;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('İlan Aç'),
        onPressed: () => _showCreateJobDialog(context),
      ),
      body: jobs.isEmpty
          ? const Center(
              child: Text(
                  'Henüz iş ilanınız yok.\n"İlan Aç" ile yeni ilan yayınlayın.\n\n'
                  'Not: İş ilanlarını yalnızca öğretmenler görebilir.',
                  textAlign: TextAlign.center),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('${job.subject} • ${job.city} • ${job.salaryText}',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(job.description),
                        const SizedBox(height: 8),
                        Text('Başvurular (${job.applicantUserIds.length})',
                            style: Theme.of(context).textTheme.titleSmall),
                        if (job.applicantUserIds.isEmpty)
                          const Text('Henüz başvuru yok.',
                              style: TextStyle(color: Colors.grey)),
                        for (final uid in job.applicantUserIds)
                          Builder(builder: (context) {
                            final t = app.userById(uid);
                            if (t == null) return const SizedBox.shrink();
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                  child: Icon(Icons.person, size: 18)),
                              title: Text(t.name),
                              subtitle: Text(
                                  '${t.subject} • ${t.experienceYears} yıl deneyim • ${t.city}'),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

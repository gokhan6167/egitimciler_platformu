import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'messages_screen.dart';

/// Teachers who marked "iş arıyorum" — visible ONLY to institutions.
class TeacherPoolScreen extends StatelessWidget {
  const TeacherPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;

    // Defensive visibility check.
    if (user.role != UserRole.institution) {
      return const Center(
          child: Text('Öğretmen havuzunu yalnızca kurumlar görebilir.'));
    }

    final teachers = app.jobSeekingTeachers;

    if (teachers.isEmpty) {
      return const Center(child: Text('Şu anda iş arayan öğretmen yok.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: teachers.length,
      itemBuilder: (context, i) {
        final t = teachers[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                              '${t.subject} • ${t.experienceYears} yıl deneyim • ${t.city}',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5)),
                      ),
                      child: const Text('İş Arıyor',
                          style:
                              TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                  ],
                ),
                if (t.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(t.bio),
                ],
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.chat),
                  label: const Text('İletişime Geç'),
                  onPressed: () {
                    final conv =
                        context.read<AppState>().conversationWith(t.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(conversationId: conv.id)),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

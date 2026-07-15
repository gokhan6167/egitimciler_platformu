import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'home_shell.dart';

/// Demo sign-in: pick one of the seeded users. Real auth comes later.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  IconData _roleIcon(UserRole role) => switch (role) {
        UserRole.parent => Icons.family_restroom,
        UserRole.student => Icons.school,
        UserRole.teacher => Icons.person,
        UserRole.institution => Icons.business,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final byRole = <UserRole, List<AppUser>>{};
    for (final u in app.users) {
      byRole.putIfAbsent(u.role, () => []).add(u);
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.menu_book, size: 64, color: Colors.indigo),
              const SizedBox(height: 8),
              Text('Eğitimciler Platformu',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Demo kullanıcı seçerek giriş yapın',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              for (final role in UserRole.values) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(role.labelTr,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Colors.grey.shade600)),
                ),
                for (final user in byRole[role] ?? <AppUser>[])
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(_roleIcon(role))),
                      title: Text(user.name),
                      subtitle: Text([
                        role.labelTr,
                        if (user.city.isNotEmpty) user.city,
                        if (user.subject.isNotEmpty) user.subject,
                      ].join(' • ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.read<AppState>().signIn(user);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeShell()),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

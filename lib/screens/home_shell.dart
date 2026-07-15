import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'browse_screen.dart';
import 'compare_screen.dart';
import 'jobs_screen.dart';
import 'landing_screen.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
import 'my_profile_screen.dart';
import 'offers_screen.dart';
import 'teacher_pool_screen.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Role-aware navigation shell. Tabs differ per role:
/// - parent/student: Keşfet, Karşılaştır, Teklifler, Mesajlar
/// - teacher: Keşfet, İş İlanları (only teachers), Teklifler, Mesajlar, Profilim
/// - institution: Keşfet, Öğretmen Havuzu (only institutions), İş İlanlarım,
///   Teklifler, Mesajlar, Profilim
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<_NavItem> _itemsFor(UserRole role) {
    return [
      _NavItem('Keşfet', Icons.search, (_) => const BrowseScreen()),
      if (role.isSeeker)
        _NavItem('Karşılaştır', Icons.compare_arrows, (_) => const CompareScreen()),
      if (role == UserRole.teacher)
        _NavItem('İş İlanları', Icons.work, (_) => const JobsScreen()),
      if (role == UserRole.institution) ...[
        _NavItem('Öğretmen Havuzu', Icons.groups, (_) => const TeacherPoolScreen()),
        _NavItem('İş İlanlarım', Icons.work, (_) => const JobsScreen()),
      ],
      _NavItem('Teklifler', Icons.local_offer, (_) => const OffersScreen()),
      _NavItem('Mesajlar', Icons.chat_bubble_outline, (_) => const MessagesScreen()),
      if (role.isEducator)
        _NavItem('Profilim', Icons.badge, (_) => const MyProfileScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser;
    if (user == null) return const LoginScreen();

    final items = _itemsFor(user.role);
    if (_index >= items.length) _index = 0;
    final wide = MediaQuery.of(context).size.width >= 800;

    final body = items[_index].builder(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(items[_index].label),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text('${user.name} (${user.role.labelTr})',
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
          IconButton(
            tooltip: 'Çıkış',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AppState>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final it in items)
                      NavigationRailDestination(
                        icon: Icon(it.icon),
                        label: Text(it.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final it in items)
                  NavigationDestination(icon: Icon(it.icon), label: it.label),
              ],
            ),
    );
  }
}

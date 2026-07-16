import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import 'home_shell.dart';

/// Sign-in screen from the "Giris Yap" Claude Design file: split layout with
/// the form on the left and a testimonial side panel on the right.
/// Auth is still demo-only — the email field is fed from the selected demo
/// account and "Giriş yap" signs that account in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _RoleTab {
  const _RoleTab(this.label, this.roles);

  final String label;
  final List<UserRole> roles;
}

class _LoginScreenState extends State<LoginScreen> {
  static const _tabs = [
    _RoleTab('Veli / Öğrenci', [UserRole.parent, UserRole.student]),
    _RoleTab('Öğretmen', [UserRole.teacher]),
    _RoleTab('Kurum', [UserRole.institution]),
  ];

  int _activeTab = 0;
  String? _selectedUserId;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<AppUser> _usersForTab(AppState app) => app.users
      .where((u) => _tabs[_activeTab].roles.contains(u.role))
      .toList();

  /// ayse.yilmaz@demo.pusula — derived demo e-mail for a seed user.
  String _demoEmail(AppUser user) {
    const map = {
      'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
      'Ç': 'c', 'Ğ': 'g', 'İ': 'i', 'I': 'i', 'Ö': 'o', 'Ş': 's', 'Ü': 'u',
    };
    final slug = user.name
        .split('')
        .map((c) => map[c] ?? c.toLowerCase())
        .join()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '.');
    return '$slug@demo.pusula';
  }

  void _selectUser(AppUser user) {
    setState(() {
      _selectedUserId = user.id;
      _emailController.text = _demoEmail(user);
    });
  }

  void _signIn() {
    final app = context.read<AppState>();
    final candidates = _usersForTab(app);
    if (candidates.isEmpty) return;
    final user = candidates.firstWhere(
      (u) => u.id == _selectedUserId,
      orElse: () => candidates.first,
    );
    app.signIn(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what demo sürümünde henüz aktif değil.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 980;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _formSide()),
          if (wide) Expanded(child: _SidePanel()),
        ],
      ),
    );
  }

  // ---------- Form side ----------

  Widget _formSide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PusulaLogo(),
                const SizedBox(width: 9),
                Text('Pusula Eğitim',
                    style:
                        pusulaHeading(fontSize: 17, letterSpacingFactor: -0.01)),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tekrar hoş geldiniz',
                      style:
                          pusulaHeading(fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                    'Hesabınıza giriş yapın; aramalarınız, teklifleriniz ve '
                    'mesajlarınız sizi bekliyor.',
                    style: TextStyle(
                        fontSize: 15, color: PusulaColors.body, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  _roleTabs(),
                  const SizedBox(height: 20),
                  _demoAccountPicker(),
                  const SizedBox(height: 20),
                  _fieldLabel('E-posta'),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'ornek@eposta.com'),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _fieldLabel('Şifre'),
                      const Spacer(),
                      InkWell(
                        onTap: () => _comingSoon('Şifre sıfırlama'),
                        child: const Text('Şifremi unuttum',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PusulaColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => _signIn(),
                    decoration: const InputDecoration(hintText: '••••••••'),
                  ),
                  const SizedBox(height: 18),
                  _RememberMe(),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _signIn,
                    child: const Text('Giriş yap'),
                  ),
                  const SizedBox(height: 26),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('veya',
                            style: TextStyle(
                                fontSize: 13, color: PusulaColors.faint)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 26),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Google ile giriş'),
                    icon: const Text('G',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF4285F4))),
                    label: const Text('Google ile devam et'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Apple ile giriş'),
                    icon: const Icon(Icons.apple, size: 20),
                    label: const Text('Apple ile devam et'),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Hesabınız yok mu? ',
                        style: const TextStyle(
                            fontSize: 14, color: PusulaColors.body),
                        children: [
                          WidgetSpan(
                            child: InkWell(
                              onTap: () => _comingSoon('Kayıt'),
                              child: const Text('Ücretsiz kayıt olun',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: PusulaColors.primary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 56),
          const Text('© 2026 Pusula Eğitim · KVKK · Güvenlik',
              style: TextStyle(fontSize: 12, color: PusulaColors.faint)),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));

  Widget _roleTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PusulaColors.surface,
        border: Border.all(color: PusulaColors.border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => setState(() {
                  _activeTab = i;
                  _selectedUserId = null;
                  _emailController.clear();
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == _activeTab ? PusulaColors.card : null,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: i == _activeTab
                        ? [
                            BoxShadow(
                              color: PusulaColors.ink.withValues(alpha: 0.08),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          i == _activeTab ? FontWeight.w600 : FontWeight.w500,
                      color: i == _activeTab
                          ? PusulaColors.primaryDark
                          : PusulaColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Demo-only block: pick which seeded account the form signs in with.
  Widget _demoAccountPicker() {
    final app = context.watch<AppState>();
    final users = _usersForTab(app);
    final selectedId = _selectedUserId ?? (users.isEmpty ? null : users.first.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: PusulaColors.surface,
        border: Border.all(color: PusulaColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEMO HESAP SEÇİN',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: PusulaColors.faint)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final user in users)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _selectUser(user),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            user.id == selectedId
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18,
                            color: user.id == selectedId
                                ? PusulaColors.primary
                                : PusulaColors.faint,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              [
                                user.name,
                                user.role.labelTr,
                                if (user.city.isNotEmpty) user.city,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13, color: PusulaColors.slate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RememberMe extends StatefulWidget {
  @override
  State<_RememberMe> createState() => _RememberMeState();
}

class _RememberMeState extends State<_RememberMe> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _value = !_value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: _value,
              onChanged: (v) => setState(() => _value = v ?? false),
            ),
          ),
          const SizedBox(width: 9),
          const Text('Beni hatırla',
              style: TextStyle(fontSize: 14, color: PusulaColors.body)),
        ],
      ),
    );
  }
}

// ---------- Side panel ----------

class _SidePanel extends StatelessWidget {
  static const _perks = [
    'Kaydettiğiniz ilanlar ve karşılaştırma listeleriniz',
    'Kurumlarla mesajlaşma ve teklif takibi',
    'Öğretmenler için iş ilanları ve gizli başvurular',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PusulaColors.surface,
        border: Border(left: BorderSide(color: PusulaColors.border)),
      ),
      padding: const EdgeInsets.all(64),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"Üç dershaneyi puanlarına ve ücretlerine göre karşılaştırdım, '
                'ikisiyle mesajlaştım ve teklif aldım. Bir haftada kararımızı '
                'verdik."',
                style: pusulaHeading(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacingFactor: -0.01),
              ),
              const SizedBox(height: 20),
              const Text('Elif Y. — Veli, Ankara · ★ 5.0',
                  style: TextStyle(fontSize: 14, color: PusulaColors.muted)),
              const SizedBox(height: 48),
              for (final perk in _perks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('—',
                          style: TextStyle(
                              color: PusulaColors.primary,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(perk,
                            style: const TextStyle(
                                fontSize: 15,
                                color: PusulaColors.slate,
                                height: 1.55)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
              const Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text('8.400+ doğrulanmış ilan', style: _statStyle),
                  Text('·', style: _statStyle),
                  Text('62.000+ değerlendirme', style: _statStyle),
                  Text('·', style: _statStyle),
                  Text('81 il', style: _statStyle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _statStyle =
      TextStyle(fontSize: 13, color: PusulaColors.muted);
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import 'home_shell.dart';
import 'landing_screen.dart';
import 'login_screen.dart';

/// Sign-up screen from the "Kayit Ol" Claude Design file: role cards on the
/// left form, role-aware fields and a role-aware perks side panel. Demo-only
/// backend — the account is created in AppState and signed in directly.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RoleCard {
  const _RoleCard(this.title, this.desc);

  final String title;
  final String desc;
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _cards = [
    _RoleCard('Veli / Öğrenci',
        'Okul, kurs, dershane ve özel öğretmen arıyorum'),
    _RoleCard('Öğretmen', 'Ders vermek ve iş ilanlarını görmek istiyorum'),
    _RoleCard('Kurum', 'Okul, kurs veya dershane olarak ilan vereceğim'),
  ];

  static const _subtitles = [
    'Karşılaştırın, teklif alın, mesajlaşın — kararınızı güvenle verin.',
    'Profilinizi oluşturun; size uygun iş ilanlarını görün, gizli başvurun.',
    'Kurumunuzu tanıtın, teklif taleplerini yanıtlayın, iş ilanı açın.',
  ];

  static const _sideTitles = [
    'Veliler ve öğrenciler için doğru eğitimi bulmanın en kısa yolu.',
    'Öğretmenler için kapalı ve güvenli bir kariyer ağı.',
    'Kurumunuzu binlerce veliyle buluşturun.',
  ];

  static const _perksByRole = [
    [
      'İlanları puan, ücret ve mesafeye göre karşılaştırın',
      'Kurumlardan teklif alın, doğrudan mesajlaşın',
      'Gerçek veli yorumlarını okuyun, deneyiminizi puanlayın',
      'Kaydettiğiniz ilanları listeleyip paylaşın',
    ],
    [
      'İş ilanlarını yalnızca öğretmenler görür',
      'Profiliniz sadece öğretmen arayan kurumlara açılır',
      'Diploma ve belge doğrulama rozetiyle öne çıkın',
      'Özel ders ilanı vererek öğrenci bulun',
    ],
    [
      'Fotoğraf ve tanıtım videosuyla kurum sayfası',
      'Teklif taleplerini tek panelden yönetin',
      'İş ilanı açın, doğrulanmış öğretmen havuzunda arayın',
      'Doğrulanmış kurum rozetiyle güven kazanın',
    ],
  ];

  int _role = 0;
  bool _termsAccepted = false;
  bool _signingUp = false;
  ProviderType _institutionType = ProviderType.privateSchool;
  final _institutionController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subjectController = TextEditingController();

  bool get _isTeacher => _role == 1;
  bool get _isInstitution => _role == 2;

  @override
  void dispose() {
    _institutionController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _fail(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signUp() async {
    if (_signingUp) return;
    final personName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    final institutionName = _institutionController.text.trim();

    if (_isInstitution && institutionName.isEmpty) {
      _fail('Kurum adını yazın.');
      return;
    }
    if (personName.isEmpty) {
      _fail(_isInstitution ? 'Yetkili adını yazın.' : 'Adınızı yazın.');
      return;
    }
    if (!_emailController.text.trim().contains('@')) {
      _fail('Geçerli bir e-posta adresi yazın.');
      return;
    }
    if (_passwordController.text.length < 8) {
      _fail('Şifre en az 8 karakter olmalı.');
      return;
    }
    if (_isTeacher && _subjectController.text.trim().isEmpty) {
      _fail('Branşınızı yazın.');
      return;
    }
    if (!_termsAccepted) {
      _fail('Kullanım koşullarını ve KVKK metnini kabul etmelisiniz.');
      return;
    }

    // "Hesap oluşturuluyor…" state from the design while the account is set up.
    setState(() => _signingUp = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.read<AppState>().registerUser(
          name: _isInstitution ? institutionName : personName,
          role: _isInstitution
              ? UserRole.institution
              : (_isTeacher ? UserRole.teacher : UserRole.parent),
          subject: _subjectController.text.trim(),
          email: _emailController.text.trim(),
          providerType: _institutionType,
        );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
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
          if (wide) Expanded(child: _sidePanel()),
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
          Row(
            children: [
              InkWell(
                onTap: _goHome,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PusulaLogo(),
                    const SizedBox(width: 9),
                    Text('Pusula Eğitim',
                        style: pusulaHeading(
                            fontSize: 17, letterSpacingFactor: -0.01)),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Ana sayfa'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ücretsiz hesap oluşturun',
                      style: pusulaHeading(
                          fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    _subtitles[_role],
                    style: const TextStyle(
                        fontSize: 15, color: PusulaColors.body, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  for (var i = 0; i < _cards.length; i++) ...[
                    _roleCard(i),
                    if (i < _cards.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 28),
                  if (_isInstitution) ...[
                    _fieldLabel('Kurum adı'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _institutionController,
                      decoration:
                          const InputDecoration(hintText: 'Örn. Bilge Koleji'),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Kurum türü'),
                    const SizedBox(height: 7),
                    DropdownButtonFormField<ProviderType>(
                      initialValue: _institutionType,
                      items: [
                        for (final t in const [
                          ProviderType.privateSchool,
                          ProviderType.course,
                          ProviderType.dershane,
                        ])
                          DropdownMenuItem(value: t, child: Text(t.labelTr)),
                      ],
                      onChanged: (v) => setState(
                          () => _institutionType = v ?? _institutionType),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(_isInstitution ? 'Yetkili adı' : 'Ad'),
                            const SizedBox(height: 7),
                            TextField(
                              controller: _firstNameController,
                              decoration:
                                  const InputDecoration(hintText: 'Adınız'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Soyad'),
                            const SizedBox(height: 7),
                            TextField(
                              controller: _lastNameController,
                              decoration:
                                  const InputDecoration(hintText: 'Soyadınız'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('E-posta'),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'ornek@eposta.com'),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Şifre'),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: 'En az 8 karakter'),
                  ),
                  if (_isTeacher) ...[
                    const SizedBox(height: 16),
                    _fieldLabel('Branş'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _subjectController,
                      decoration:
                          const InputDecoration(hintText: 'Örn. Matematik'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: _termsAccepted,
                            onChanged: (v) =>
                                setState(() => _termsAccepted = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Kullanım koşullarını',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: PusulaColors.primary),
                              children: [
                                TextSpan(
                                  text: ' ve ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: PusulaColors.body),
                                ),
                                TextSpan(text: 'KVKK aydınlatma metnini'),
                                TextSpan(
                                  text: ' okudum, kabul ediyorum.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: PusulaColors.body),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _signUp,
                    child: Text(_signingUp
                        ? 'Hesap oluşturuluyor…'
                        : 'Hesap oluştur'),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Google ile kayıt'),
                    icon: const Text('G',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF4285F4))),
                    label: const Text('Google ile devam et'),
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Zaten hesabınız var mı? ',
                        style: const TextStyle(
                            fontSize: 14, color: PusulaColors.body),
                        children: [
                          WidgetSpan(
                            child: InkWell(
                              onTap: _goToSignIn,
                              child: const Text('Giriş yapın',
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
          const SizedBox(height: 40),
          const Text('© 2026 Pusula Eğitim · KVKK · Güvenlik',
              style: TextStyle(fontSize: 12, color: PusulaColors.faint)),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));

  Widget _roleCard(int i) {
    final active = i == _role;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _role = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PusulaColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? PusulaColors.primary : PusulaColors.borderDark,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: active
                      ? PusulaColors.primary
                      : const Color(0xFFC6C2B9),
                  width: active ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_cards[i].title,
                      style: pusulaHeading(
                          fontSize: 15, letterSpacingFactor: 0)),
                  const SizedBox(height: 2),
                  Text(_cards[i].desc,
                      style: const TextStyle(
                          fontSize: 13, color: PusulaColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Side panel ----------

  Widget _sidePanel() {
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
                _sideTitles[_role],
                style: pusulaHeading(
                    fontSize: 24, height: 1.35, letterSpacingFactor: -0.01),
              ),
              const SizedBox(height: 28),
              for (final perk in _perksByRole[_role])
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
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: PusulaColors.border)),
                ),
                child: const Wrap(
                  spacing: 28,
                  runSpacing: 6,
                  children: [
                    Text('8.400+ doğrulanmış ilan', style: _statStyle),
                    Text('·', style: _statStyle),
                    Text('62.000+ değerlendirme', style: _statStyle),
                    Text('·', style: _statStyle),
                    Text('81 il', style: _statStyle),
                  ],
                ),
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

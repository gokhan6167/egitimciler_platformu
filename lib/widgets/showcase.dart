import 'package:flutter/material.dart';

import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/static_pages.dart';
import '../theme/pusula_theme.dart';

/// Green logo pill from the design (`#EAF3EF`, hover `#CFE6DD`) —
/// present top-left on every page, always returns to the landing page.
class LogoPill extends StatefulWidget {
  const LogoPill({super.key, this.compact = false});

  /// Compact renders only the compass dot (for narrow app bars).
  final bool compact;

  @override
  State<LogoPill> createState() => _LogoPillState();
}

class _LogoPillState extends State<LogoPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
          (_) => false,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover
                ? const Color(0xFFCFE6DD)
                : PusulaColors.primarySoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PusulaLogo(size: 20),
              if (!widget.compact) ...[
                const SizedBox(width: 8),
                Text('Pusula Eğitim',
                    style: pusulaHeading(
                        fontSize: 15, color: PusulaColors.primaryDark)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer used on every page: Yardım · Güvenlik · KVKK (+ Sözleşme).
class PusulaFooter extends StatelessWidget {
  const PusulaFooter({super.key, this.showTerms = true});

  final bool showTerms;

  @override
  Widget build(BuildContext context) {
    Widget link(String label, Widget Function() page) => InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => page())),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: PusulaColors.muted)),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PusulaColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          const Text('© 2026 Pusula Eğitim. Tüm hakları saklıdır.',
              style: TextStyle(fontSize: 13, color: PusulaColors.faint)),
          const SizedBox(width: 12),
          link('Yardım', () => const HelpScreen()),
          link('Güvenlik', () => const SecurityScreen()),
          link('KVKK', () => const KvkkScreen()),
          if (showTerms) link('Kullanıcı Sözleşmesi', () => const TermsScreen()),
        ],
      ),
    );
  }
}

/// Page shell for showcase pages: top nav with the logo pill + auth
/// buttons, scrollable centered content, shared footer.
class ShowcaseScaffold extends StatelessWidget {
  const ShowcaseScaffold({
    super.key,
    required this.children,
    this.maxWidth = 860,
    this.actions,
  });

  final List<Widget> children;
  final double maxWidth;

  /// Extra nav actions before Giriş/Kayıt (e.g. "Ücretlendirme").
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: PusulaColors.border)),
              ),
              child: Row(
                children: [
                  LogoPill(compact: narrow),
                  const Spacer(),
                  ...?actions,
                  if (!narrow) ...[
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text('Giriş yap'),
                    ),
                    const SizedBox(width: 6),
                  ],
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                    child: const Text('Kayıt ol'),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ),
            const PusulaFooter(),
          ],
        ),
      ),
    );
  }
}

/// Section heading + optional lead paragraph for showcase pages.
class PageIntro extends StatelessWidget {
  const PageIntro({super.key, required this.title, this.lead});

  final String title;
  final Widget? lead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: pusulaHeading(fontSize: 34, fontWeight: FontWeight.w800)),
        if (lead != null) ...[const SizedBox(height: 12), lead!],
        const SizedBox(height: 28),
      ],
    );
  }
}

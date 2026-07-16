import 'package:flutter/material.dart';

import '../screens/landing_screen.dart';

/// AppBar action that returns to the public landing page from anywhere.
/// Keeps the session — signed-in users can come back via "Panele dön".
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ana sayfa',
      icon: const Icon(Icons.home_outlined),
      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (_) => false,
      ),
    );
  }
}

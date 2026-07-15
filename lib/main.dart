import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/landing_screen.dart';
import 'state/app_state.dart';
import 'theme/pusula_theme.dart';

void main() {
  runApp(const EgitimcilerApp());
}

class EgitimcilerApp extends StatelessWidget {
  const EgitimcilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Pusula Eğitim',
        debugShowCheckedModeBanner: false,
        theme: pusulaTheme(),
        home: const LandingScreen(),
      ),
    );
  }
}

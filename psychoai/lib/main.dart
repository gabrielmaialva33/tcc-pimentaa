import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const PsychoAIApp());
}

class PsychoAIApp extends StatelessWidget {
  const PsychoAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsychoAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingScreen(),
    );
  }
}
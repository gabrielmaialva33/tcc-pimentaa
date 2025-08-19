import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/calm_button.dart';
import '../memories/presentation/memory_input_screen.dart';

/// Tela de onboarding que introduz o usuário ao conceito do app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bem-vindo ao PsychoAI',
      subtitle: 'Sua jornada de autoconhecimento começa aqui',
      description: 'Um espaço seguro para explorar suas lembranças e descobrir padrões psicológicos com a ajuda da inteligência artificial.',
      icon: Icons.psychology_outlined,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Lembranças Encobridoras',
      subtitle: 'Explore o conceito freudiano',
      description: 'Baseado na teoria de Freud, algumas lembranças podem ocultar experiências mais profundas. Nossa IA ajuda a identificar esses padrões.',
      icon: Icons.memory_outlined,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Análise Inteligente',
      subtitle: 'IA especializada em psicanálise',
      description: 'Utilizamos modelos avançados da NVIDIA para analisar suas narrativas e fornecer insights baseados em princípios psicanalíticos.',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.accent,
    ),
    OnboardingPage(
      title: 'Privacidade Total',
      subtitle: 'Seus dados são sagrados',
      description: 'Todas as informações são criptografadas e você mantém controle total sobre seus dados. Pode exportar ou excluir a qualquer momento.',
      icon: Icons.security_outlined,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: List.generate(
                    _pages.length,
                        (index) =>
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip/Back button
                    if (_currentPage == 0)
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Pular',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _previousPage,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chevron_left, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Voltar',
                              style: AppTypography.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),

                    // Next/Start button
                    CalmButton(
                      onPressed: _currentPage == _pages.length - 1
                          ? _startApp
                          : _nextPage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Começar'
                                : 'Próximo',
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8))
              .then(delay: 200.ms)
              .shimmer(duration: 1000.ms),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: AppTypography.textTheme.displaySmall?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 30, end: 0),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: page.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .slideY(begin: 30, end: 0),

          const SizedBox(height: 32),

          // Description
          Text(
            page.description,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms)
              .slideY(begin: 30, end: 0),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _navigateToMain();
  }

  void _startApp() {
    _navigateToMain();
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MemoryInputScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Modelo para representar uma página do onboarding
class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/models/user_profile.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/memories/presentation/memory_input_screen.dart';

/// App principal que gerencia roteamento baseado em autenticação
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsychoAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return AuthWrapper(authProvider: authProvider);
        },
      ),
    );
  }
}

/// Wrapper que decide qual tela mostrar baseado no estado de autenticação
class AuthWrapper extends StatelessWidget {
  final AuthProvider authProvider;

  const AuthWrapper({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    switch (authProvider.state.status) {
      case AuthStatus.uninitialized:
        return const SplashScreen();
      
      case AuthStatus.loading:
        return const LoadingScreen();
      
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      
      case AuthStatus.authenticated:
        return _buildAuthenticatedApp(context);
      
      case AuthStatus.error:
        return ErrorScreen(
          message: authProvider.errorMessage ?? 'Erro desconhecido',
          onRetry: () => authProvider.clearError(),
        );
    }
  }

  Widget _buildAuthenticatedApp(BuildContext context) {
    final user = authProvider.currentUser!;
    
    // Verificar se email está verificado (apenas para analistas)
    if (user.role.isAnalyst && !user.isEmailVerified) {
      return EmailVerificationScreen(user: user);
    }
    
    // Verificar se analista está verificado profissionalmente
    if (user.role.isAnalyst && user.isProfessionalVerified != true) {
      return ProfessionalVerificationPendingScreen(user: user);
    }
    
    // Redirecionar para dashboard baseado no papel
    if (user.role.isAnalyst) {
      return const AnalystDashboard();
    } else {
      return const PatientDashboard();
    }
  }
}

/// Tela de splash inicial
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'PsychoAI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Análise Psicanalítica com IA',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de carregamento
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Carregando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de boas-vindas com onboarding progressivo
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bem-vindo ao PsychoAI',
      subtitle: 'Sua jornada de autoconhecimento começa aqui',
      description: 'Utilizamos inteligência artificial e princípios psicanalíticos para ajudá-lo a compreender suas memórias e emoções.',
      icon: Icons.psychology_outlined,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Análise Profunda',
      subtitle: 'Descubra padrões inconscientes',
      description: 'Nossa IA identifica lembranças encobridoras e mecanismos de defesa, oferecendo insights valiosos para sua terapia.',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Ambiente Seguro',
      subtitle: 'Seus dados são protegidos',
      description: 'Mantemos total privacidade e confidencialidade. Seus pensamentos e análises ficam seguros conosco.',
      icon: Icons.shield_outlined,
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: _currentPage < _pages.length 
            ? _buildOnboardingPage()
            : _buildRoleSelectionPage(),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage() {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentPage = _pages.length;
                  });
                },
                child: Text(
                  'Pular',
                  style: TextStyle(
                    color: AppColors.onBackground.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              ...List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage 
                      ? AppColors.primary 
                      : AppColors.primary.withValues(alpha: 0.3),
                  ),
                );
              }),
            ],
          ),
        ),

        // Page content
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
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: page.color.withValues(alpha: 0.1),
                        border: Border.all(
                          color: page.color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        page.icon,
                        size: 60,
                        color: page.color,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page.title,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.subtitle,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: page.color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      page.description,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onBackground.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: AppColors.onBackground.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voltar',
                        style: TextStyle(
                          color: AppColors.onBackground.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),

              ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    setState(() {
                      _currentPage = _pages.length;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage < _pages.length - 1 ? 'Próximo' : 'Começar',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'PsychoAI',
            style: AppTypography.textTheme.headlineLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Como você gostaria de usar o PsychoAI?',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildRoleCard(
            context,
            title: 'Sou Paciente',
            subtitle: 'Quero analisar minhas memórias',
            icon: Icons.person_outline,
            color: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            context,
            title: 'Sou Psicanalista',
            subtitle: 'Quero acessar análises profissionais',
            icon: Icons.medical_services_outlined,
            color: AppColors.accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: Text(
              'Já tenho uma conta',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Classe para representar uma página do onboarding
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

/// Tela de erro
class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ops! Algo deu errado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de verificação de email
class EmailVerificationScreen extends StatelessWidget {
  final UserProfile user;

  const EmailVerificationScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação de Email'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email_outlined,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Verifique seu email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enviamos um link de verificação para:\n${user.email}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().sendEmailVerification();
              },
              child: const Text('Reenviar Email'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().reloadUserProfile();
              },
              child: const Text('Já verifiquei'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela de verificação profissional pendente
class ProfessionalVerificationPendingScreen extends StatelessWidget {
  final UserProfile user;

  const ProfessionalVerificationPendingScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação Profissional'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pending_outlined,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Verificação Pendente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Olá Dr(a). ${user.displayName}!\n\n'
              'Sua conta está sendo verificada por nossa equipe. '
              'Você receberá um email quando a verificação for concluída.\n\n'
              'CRP: ${user.crp}\n'
              'Especialização: ${user.specialty}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().reloadUserProfile();
              },
              child: const Text('Verificar Status'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard temporário para analistas
class AnalystDashboard extends StatelessWidget {
  const AnalystDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Profissional'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard do Analista\n(Em desenvolvimento)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Dashboard temporário para pacientes
class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao PsychoAI!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MemoryInputScreen(),
                  ),
                );
              },
              child: const Text('Registrar Nova Memória'),
            ),
          ],
        ),
      ),
    );
  }
}

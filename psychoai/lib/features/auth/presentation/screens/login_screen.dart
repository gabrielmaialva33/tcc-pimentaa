import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../components/auth_components.dart';
import 'patient_registration_screen.dart';
import 'analyst_registration_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro no login'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _navigateToPatientRegistration() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PatientRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToAnalystRegistration() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AnalystRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToForgotPassword() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ForgotPasswordScreen(email: _emailController.text.trim()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CleanBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo e título
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.psychology,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                      ).animate()
                          .scale(delay: 200.ms, duration: 600.ms)
                          .then()
                          .shimmer(duration: 1500.ms),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Bem-vindo de volta',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Entre na sua conta PsychoAI',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Formulário de login
                  MaterialCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        AnimatedTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'seu@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          validator: _validateEmail,
                        ).animate()
                            .fadeIn(delay: 800.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        
                        const SizedBox(height: 20),
                        
                        AnimatedTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          hint: 'Digite sua senha',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _obscurePassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          onSuffixTap: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                            HapticFeedback.selectionClick();
                          },
                        ).animate()
                            .fadeIn(delay: 1000.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        
                        const SizedBox(height: 12),
                        
                        // Link esqueci a senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _navigateToForgotPassword,
                            child: Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ).animate()
                            .fadeIn(delay: 1200.ms, duration: 600.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Botão de login
                        MaterialButton(
                          text: 'Entrar',
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                          icon: Icons.login,
                          backgroundColor: Theme.of(context).primaryColor,
                        ).animate()
                            .fadeIn(delay: 1400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 700.ms, duration: 800.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                  
                  const SizedBox(height: 32),
                  
                  // Divisor
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ou',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ).animate()
                      .fadeIn(delay: 1600.ms, duration: 600.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Botões de registro
                  Text(
                    'Não tem uma conta?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(delay: 1800.ms, duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomGlassmorphicButton(
                          text: 'Sou Paciente',
                          onPressed: _navigateToPatientRegistration,
                          icon: Icons.person_outline,
                          height: 48,
                        ).animate()
                            .fadeIn(delay: 2000.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomGlassmorphicButton(
                          text: 'Sou Analista',
                          onPressed: _navigateToAnalystRegistration,
                          icon: Icons.medical_services_outlined,
                          height: 48,
                        ).animate()
                            .fadeIn(delay: 2200.ms, duration: 600.ms)
                            .slideX(begin: 0.3, end: 0),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botão voltar
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 2400.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
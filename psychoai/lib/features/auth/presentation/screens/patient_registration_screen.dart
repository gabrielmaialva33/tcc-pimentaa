import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../components/auth_components.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers para os formulários
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 - Informações básicas
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 - Segurança
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 3 - Preferências
  bool _allowAnalytics = true;
  bool _allowNotifications = true;
  String _preferredTheme = 'system';
  List<String> _interests = [];

  final List<String> _availableInterests = [
    'Ansiedade',
    'Depressão',
    'Relacionamentos',
    'Trauma',
    'Autoestima',
    'Crescimento pessoal',
    'Mindfulness',
    'Sono',
    'Estresse',
    'Família',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Digite seu nome completo';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.length < 10 || cleaned.length > 11) {
        return 'Digite um telefone válido';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Senha deve conter maiúscula, minúscula e número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  Future<void> _nextStep() async {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState!.validate();
        break;
      case 1:
        isValid = _step2FormKey.currentState!.validate();
        break;
      case 2:
        await _handleRegistration();
        return;
    }

    if (isValid) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleRegistration() async {
    if (!_step3FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerPatient(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      preferences: {
        'allowAnalytics': _allowAnalytics,
        'allowNotifications': _allowNotifications,
        'preferredTheme': _preferredTheme,
        'interests': _interests,
      },
    );

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conta criada com sucesso! Bem-vindo!'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro no registro'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header com progresso
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _previousStep,
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 24),
                    StepProgressIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                      stepLabels: const [
                        'Informações Básicas',
                        'Segurança',
                        'Preferências',
                      ],
                    ),
                  ],
                ),
              ),

              // Conteúdo dos passos
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),

              // Botões de navegação
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: GlassmorphicButton(
                          text: 'Voltar',
                          onPressed: _previousStep,
                          icon: Icons.arrow_back,
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 2,
                      child: GlassmorphicButton(
                        text: _currentStep == 2 ? 'Criar Conta' : 'Continuar',
                        onPressed: _isLoading ? null : _nextStep,
                        isLoading: _isLoading && _currentStep == 2,
                        icon: _currentStep == 2 
                            ? Icons.check 
                            : Icons.arrow_forward,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            GlassmorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vamos nos conhecer!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Digite suas informações básicas para criarmos sua conta.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ).animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),
                  
                  const SizedBox(height: 32),
                  
                  AnimatedTextField(
                    controller: _nameController,
                    label: 'Nome Completo',
                    hint: 'João Silva',
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: _validateName,
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  AnimatedTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'joao@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ).animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  AnimatedTextField(
                    controller: _phoneController,
                    label: 'Telefone (Opcional)',
                    hint: '(11) 99999-9999',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ).animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ],
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 800.ms)
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            GlassmorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proteja sua conta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Crie uma senha forte para manter suas informações seguras.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ).animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),
                  
                  const SizedBox(height: 32),
                  
                  AnimatedTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: 'Digite uma senha forte',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onChanged: (value) => setState(() {}),
                    onSuffixTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                      HapticFeedback.selectionClick();
                    },
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  
                  if (_passwordController.text.isNotEmpty) ...[
                    PasswordStrengthIndicator(
                      password: _passwordController.text,
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  AnimatedTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    hint: 'Digite a senha novamente',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined,
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    onSuffixTap: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      HapticFeedback.selectionClick();
                    },
                  ).animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ],
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 800.ms)
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personalize sua experiência',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Configure suas preferências para uma experiência personalizada.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Interesses
                    Text(
                      'Áreas de interesse (opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableInterests.map((interest) {
                        final isSelected = _interests.contains(interest);
                        return FilterChip(
                          label: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _interests.add(interest);
                              } else {
                                _interests.remove(interest);
                              }
                            });
                            HapticFeedback.selectionClick();
                          },
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          selectedColor: Colors.white,
                          checkmarkColor: Colors.blue,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        );
                      }).toList(),
                    ).animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Configurações de privacidade
                    Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Permitir análises anônimas',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Ajude a melhorar o app com dados anônimos',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          value: _allowAnalytics,
                          onChanged: (value) {
                            setState(() => _allowAnalytics = value);
                            HapticFeedback.selectionClick();
                          },
                          activeColor: Colors.white,
                          tileColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        SwitchListTile(
                          title: Text(
                            'Receber notificações',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Lembretes e insights personalizados',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          value: _allowNotifications,
                          onChanged: (value) {
                            setState(() => _allowNotifications = value);
                            HapticFeedback.selectionClick();
                          },
                          activeColor: Colors.white,
                          tileColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ).animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../components/auth_components.dart';

class AnalystRegistrationScreen extends StatefulWidget {
  const AnalystRegistrationScreen({super.key});

  @override
  State<AnalystRegistrationScreen> createState() => _AnalystRegistrationScreenState();
}

class _AnalystRegistrationScreenState extends State<AnalystRegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers para os formulários
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 - Informações pessoais
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 - Informações profissionais
  final _crpController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();
  final List<String> _certifications = [];
  final _certificationController = TextEditingController();

  // Step 3 - Segurança
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToEthicsCode = false;

  final List<String> _availableSpecialties = [
    'Psicanálise Clínica',
    'Psicoterapia Psicanalítica',
    'Psicanálise de Crianças e Adolescentes',
    'Psicanálise de Casal e Família',
    'Psicanálise de Grupos',
    'Neuropsicanalise',
    'Psicanálise Institucional',
    'Formação em Psicanálise',
    'Supervisão Clínica',
    'Outra',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _crpController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _certificationController.dispose();
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

  String? _validateCRP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CRP é obrigatório';
    }
    
    // Formato básico: XX/XXXXX ou XX XXXXX
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 6 || cleaned.length > 7) {
      return 'CRP deve ter formato XX/XXXXX';
    }
    return null;
  }

  String? _validateSpecialty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Especialização é obrigatória';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Biografia profissional é obrigatória';
    }
    if (value.trim().length < 50) {
      return 'Biografia deve ter pelo menos 50 caracteres';
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
        isValid = _step3FormKey.currentState!.validate();
        if (isValid && (!_agreeToTerms || !_agreeToEthicsCode)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Você deve aceitar os termos e código de ética'),
              backgroundColor: Colors.orange.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
        if (isValid) {
          await _handleRegistration();
          return;
        }
        break;
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

  void _addCertification() {
    final text = _certificationController.text.trim();
    if (text.isNotEmpty && !_certifications.contains(text)) {
      setState(() {
        _certifications.add(text);
        _certificationController.clear();
      });
      HapticFeedback.selectionClick();
    }
  }

  void _removeCertification(String certification) {
    setState(() => _certifications.remove(certification));
    HapticFeedback.selectionClick();
  }

  Future<void> _handleRegistration() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerAnalyst(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      crp: _crpController.text.trim(),
      specialty: _specialtyController.text.trim(),
      professionalBio: _bioController.text.trim(),
      certifications: _certifications.isNotEmpty ? _certifications : null,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      preferences: {
        'agreeToTerms': _agreeToTerms,
        'agreeToEthicsCode': _agreeToEthicsCode,
      },
    );

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conta criada! Aguarde verificação profissional.'),
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
                            'Registro Profissional',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StepProgressIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                      stepLabels: const [
                        'Informações Pessoais',
                        'Dados Profissionais',
                        'Segurança e Termos',
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
                            ? Icons.medical_services 
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomGlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Dados Pessoais',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Informações pessoais para identificação profissional.',
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
                      hint: 'Dr(a). Maria Silva',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                    ).animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    AnimatedTextField(
                      controller: _emailController,
                      label: 'Email Profissional',
                      hint: 'maria@clinica.com',
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
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomGlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Qualificações',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Informações profissionais para verificação.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    AnimatedTextField(
                      controller: _crpController,
                      label: 'CRP (Conselho Regional)',
                      hint: '06/123456',
                      prefixIcon: Icons.badge_outlined,
                      validator: _validateCRP,
                    ).animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Dropdown de especialização
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButtonFormField<String>(
                        value: _specialtyController.text.isNotEmpty 
                            ? _specialtyController.text 
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Especialização',
                          labelStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.psychology_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                        ),
                        dropdownColor: const Color(0xFF1565C0),
                        style: const TextStyle(color: Colors.white),
                        items: _availableSpecialties.map((specialty) {
                          return DropdownMenuItem(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _specialtyController.text = value ?? '');
                          HapticFeedback.selectionClick();
                        },
                        validator: _validateSpecialty,
                      ),
                    ).animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    AnimatedTextField(
                      controller: _bioController,
                      label: 'Biografia Profissional',
                      hint: 'Descreva sua experiência, formação e abordagem terapêutica...',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      validator: _validateBio,
                    ).animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Certificações
                    Text(
                      'Certificações (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedTextField(
                            controller: _certificationController,
                            label: 'Adicionar certificação',
                            hint: 'Ex: Especialização em Psicanálise Lacaniana',
                            prefixIcon: Icons.card_membership_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassmorphicButton(
                          text: '+',
                          onPressed: _addCertification,
                          width: 56,
                          height: 56,
                        ),
                      ],
                    ),
                    
                    if (_certifications.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Column(
                        children: _certifications.map((cert) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cert,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeCertification(cert),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ).animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
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

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomGlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Segurança e Ética',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Crie uma senha segura e aceite os termos profissionais.',
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
                    
                    const SizedBox(height: 32),
                    
                    // Termos e condições
                    Column(
                      children: [
                        CheckboxListTile(
                          title: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(text: 'Aceito os '),
                                TextSpan(
                                  text: 'Termos de Uso',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' e '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                            HapticFeedback.selectionClick();
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.blue,
                          tileColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        CheckboxListTile(
                          title: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(text: 'Comprometo-me a seguir o '),
                                TextSpan(
                                  text: 'Código de Ética Profissional',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' e manter sigilo absoluto das informações dos pacientes'),
                              ],
                            ),
                          ),
                          value: _agreeToEthicsCode,
                          onChanged: (value) {
                            setState(() => _agreeToEthicsCode = value ?? false);
                            HapticFeedback.selectionClick();
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.blue,
                          tileColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.amber.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sua conta será revisada por nossa equipe antes da ativação. Você receberá um email com o resultado.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(delay: 1000.ms, duration: 600.ms),
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
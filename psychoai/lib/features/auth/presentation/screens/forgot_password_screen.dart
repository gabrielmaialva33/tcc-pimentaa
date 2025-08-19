import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../components/auth_components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? email;
  
  const ForgotPasswordScreen({
    super.key,
    this.email,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _emailSent = true);
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao enviar email'),
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

  void _handleBackToLogin() {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
  }

  void _handleResendEmail() {
    setState(() => _emailSent = false);
    _handleSendResetEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CleanBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleBackToLogin,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Recuperar Senha',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 40),

                // Logo e animação
                if (!_emailSent) ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ).animate()
                      .scale(delay: 200.ms, duration: 600.ms)
                      .then()
                      .shimmer(duration: 1500.ms),
                ] else ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_read,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ).animate()
                      .scale(duration: 600.ms)
                      .then()
                      ,
                ],

                const SizedBox(height: 24),

                // Título e descrição
                Text(
                  _emailSent ? 'Email Enviado!' : 'Esqueceu sua senha?',
                  style: const TextStyle(
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
                  _emailSent
                      ? 'Enviamos um link de redefinição para ${_emailController.text}'
                      : 'Digite seu email para receber um link de redefinição de senha',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 48),

                // Conteúdo principal
                if (!_emailSent) ...[
                  // Formulário
                  MaterialCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
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

                          const SizedBox(height: 24),

                          CustomMaterialButton(
                            text: 'Enviar Link',
                            onPressed: _isLoading ? null : _handleSendResetEmail,
                            isLoading: _isLoading,
                            icon: Icons.send,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                          ).animate()
                              .fadeIn(delay: 1000.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 700.ms, duration: 800.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                ] else ...[
                  // Email enviado com sucesso
                  MaterialCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green.withValues(alpha: 0.9),
                        ).animate()
                            .scale(duration: 600.ms)
                            .then()
                            ,

                        const SizedBox(height: 24),

                        Text(
                          'Verifique sua caixa de entrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Se você não receber o email em alguns minutos, verifique sua pasta de spam.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: CustomMaterialButton(
                                text: 'Reenviar',
                                onPressed: _handleResendEmail,
                                icon: Icons.refresh,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomMaterialButton(
                                text: 'Voltar',
                                onPressed: _handleBackToLogin,
                                icon: Icons.arrow_back,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                ],

                const SizedBox(height: 32),

                // Instruções adicionais
                if (!_emailSent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Você receberá um email com instruções para criar uma nova senha.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Botão voltar ao login
                  TextButton(
                    onPressed: _handleBackToLogin,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Voltar ao Login',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 1400.ms, duration: 600.ms),
                ],

                // Dicas de segurança
                if (_emailSent) ...[
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.amber.withValues(alpha: 0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dicas de Segurança',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• O link expira em 1 hora\n'
                          '• Não compartilhe o link com ninguém\n'
                          '• Crie uma senha forte com maiúsculas, minúsculas e números',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
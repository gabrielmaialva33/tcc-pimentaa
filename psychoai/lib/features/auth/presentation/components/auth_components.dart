import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Container com efeito glassmorphism personalizado
class CustomGlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomGlassmorphicContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 16,
    this.blur = 20,
    this.opacity = 0.1,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        blur: blur,
        opacity: opacity,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Campo de texto animado com validação
class AnimatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onSuffixTap;
  final bool enabled;
  final int? maxLines;
  final TextCapitalization textCapitalization;

  const AnimatedTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSuffixTap,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validateField(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphicContainer(
          height: widget.maxLines == 1 ? 60 : null,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            textCapitalization: widget.textCapitalization,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: TextStyle(
                color: _isFocused 
                    ? Colors.white 
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: _isFocused ? 12 : 16,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.7),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: _isFocused 
                            ? Colors.white 
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      onPressed: widget.onSuffixTap,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            onChanged: (value) {
              _validateField(value);
              widget.onChanged?.call(value);
            },
          ),
        ).animate(target: _isFocused ? 1 : 0)
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.02, 1.02),
              duration: 200.ms,
              curve: Curves.easeOut,
            )
            .then()
            .shimmer(
              duration: 1000.ms,
              color: Colors.white.withValues(alpha: 0.1),
            ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ).animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.2, end: 0),
        ],
      ],
    );
  }
}

/// Indicador de força da senha
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  int get _strength {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // Comprimento mínimo
    if (password.length >= 8) strength++;
    
    // Contém letra minúscula
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    
    // Contém letra maiúscula
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    
    // Contém número
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    // Contém caractere especial
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  Color get _strengthColor {
    switch (_strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get _strengthText {
    switch (_strength) {
      case 0:
        return '';
      case 1:
        return 'Muito fraca';
      case 2:
        return 'Fraca';
      case 3:
        return 'Média';
      case 4:
        return 'Forte';
      case 5:
        return 'Muito forte';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < 4 ? 2 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: index < _strength 
                              ? _strengthColor 
                              : Colors.transparent,
                        ),
                      ).animate(target: index < _strength ? 1 : 0)
                          .scale(
                            begin: const Offset(0, 1),
                            end: const Offset(1, 1),
                            duration: 200.ms,
                            delay: (index * 50).ms,
                          ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _strengthText,
              style: TextStyle(
                color: _strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ).animate()
                .fadeIn(duration: 300.ms),
          ],
        ),
      ],
    );
  }
}

/// Indicador de progresso por passos
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.blue,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent 
                                    ? Colors.blue 
                                    : Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ).animate(target: isCompleted || isCurrent ? 1 : 0)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                      ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: isCompleted
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ).animate(target: isCompleted ? 1 : 0)
                          .scaleX(
                            begin: 0,
                            end: 1,
                            duration: 500.ms,
                            delay: 200.ms,
                          ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          stepLabels[currentStep],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ).animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

/// Botão glassmórfico animado
class GlassmorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;
  final double height;

  const GlassmorphicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.width,
    this.height = 56,
  });

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null && !widget.isLoading) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: GlassmorphicContainer(
        width: widget.width ?? double.infinity,
        height: widget.height,
        borderRadius: 16,
        opacity: widget.onPressed != null ? 0.2 : 0.1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.backgroundColor ?? Colors.white.withValues(alpha: 0.1),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ).animate(target: _isPressed ? 1 : 0)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: 100.ms,
          ),
    );
  }
}

/// Container com fundo gradiente animado
class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xFF2196F3),
            const Color(0xFF21CBF3),
            const Color(0xFF42A5F5),
          ],
        ),
      ),
      child: child,
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 3000.ms,
          color: Colors.white.withValues(alpha: 0.1),
        );
  }
}
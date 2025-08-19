import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Classe para micro-animações sutis que melhoram a UX
class MicroAnimations {
  
  /// Animação de pulse suave para botões importantes
  static Widget pulseButton({
    required Widget child,
    bool enabled = true,
    Duration duration = const Duration(seconds: 2),
    double intensity = 0.05,
  }) {
    if (!enabled) return child;
    
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(1.0 + intensity, 1.0 + intensity),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: Offset(1.0 + intensity, 1.0 + intensity),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Animação de breathing para exercícios de relaxamento
  static Widget breathingCircle({
    required double size,
    Color? color,
    Duration duration = const Duration(seconds: 4),
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? AppColors.accent.withValues(alpha: 0.3),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.2, 1.2),
      duration: duration,
      curve: Curves.easeInOut,
    )
    .then()
    .scale(
      begin: const Offset(1.2, 1.2),
      end: const Offset(0.8, 0.8),
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  /// Animação de shimmer para loading states
  static Widget shimmerEffect({
    required Widget child,
    bool enabled = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!enabled) return child;
    
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          angle: 45,
        );
  }

  /// Animação de typing para texto sendo "digitado"
  static Widget typingText({
    required String text,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 50),
    Duration delay = Duration.zero,
  }) {
    return Text(text, style: style)
        .animate()
        .fade(delay: delay, duration: const Duration(milliseconds: 300))
        .scale(
          delay: delay,
          begin: const Offset(0.8, 0.8),
          curve: Curves.easeOutBack,
        );
  }

  /// Animação de ondas suaves para background
  static Widget wavyBackground({
    required Widget child,
    Duration duration = const Duration(seconds: 8),
  }) {
    return Stack(
      children: [
        // Onda 1
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.1),
                  AppColors.primaryLight.withValues(alpha: 0.05),
                ],
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .custom(
            duration: duration,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  30 * (0.5 - 0.5 * (1 - value)),
                  20 * (0.5 - 0.5 * (1 - value)),
                ),
                child: child,
              );
            },
          ),
        ),
        // Onda 2
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.08),
                  AppColors.accentLight.withValues(alpha: 0.04),
                ],
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .custom(
            duration: Duration(milliseconds: (duration.inMilliseconds * 1.3).round()),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  -25 * (0.5 - 0.5 * (1 - value)),
                  -15 * (0.5 - 0.5 * (1 - value)),
                ),
                child: child,
              );
            },
          ),
        ),
        child,
      ],
    );
  }

  /// Animação de flutuação suave
  static Widget floatingEffect({
    required Widget child,
    double distance = 10.0,
    Duration duration = const Duration(seconds: 3),
    bool enabled = true,
  }) {
    if (!enabled) return child;
    
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: -distance,
          duration: duration,
          curve: Curves.easeInOut,
        )
        .then()
        .moveY(
          begin: -distance,
          end: 0,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Animação de entrada staggered para listas
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return child
        .animate()
        .fadeIn(
          delay: delay * index,
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          delay: delay * index,
          begin: 30,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// Animação de sucesso com confetti sutil
  static Widget successConfetti({
    required Widget child,
    bool triggered = false,
  }) {
    return Stack(
      children: [
        child,
        if (triggered)
          ...List.generate(8, (index) {
            final angle = (index * 45.0) * (3.14159 / 180);
            return Positioned(
              left: 50,
              top: 50,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: [
                    AppColors.success,
                    AppColors.joy,
                    AppColors.accent,
                    AppColors.primary,
                  ][index % 4],
                  shape: BoxShape.circle,
                ),
              )
              .animate()
              .move(
                begin: Offset.zero,
                end: Offset(
                  50 * (index.isEven ? 1 : -1),
                  -50 - (index * 10),
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
              )
              .fade(
                begin: 1.0,
                end: 0.0,
                duration: const Duration(milliseconds: 800),
              ),
            );
          }),
      ],
    );
  }

  /// Animação de emoção selecionada
  static Widget emotionSelection({
    required Widget child,
    bool isSelected = false,
    Color? selectedColor,
  }) {
    return child
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
        )
        .then()
        .tint(
          color: selectedColor ?? AppColors.primary,
          begin: 0,
          end: isSelected ? 0.3 : 0,
          duration: const Duration(milliseconds: 200),
        );
  }

  /// Animação de loading com pontos
  static Widget loadingDots({
    Color? color,
    double size = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: size * 0.25),
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          delay: Duration(milliseconds: index * 200),
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.5, 0.5),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }),
    );
  }

  /// Animação de card aparecendo
  static Widget cardEntrance({
    required Widget child,
    Duration delay = Duration.zero,
  }) {
    return child
        .animate()
        .fadeIn(
          delay: delay,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        )
        .slideY(
          delay: delay,
          begin: 50,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        )
        .scale(
          delay: delay,
          begin: const Offset(0.9, 0.9),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
        );
  }
}

/// Widget helper para animações condicionais
class ConditionalAnimation extends StatelessWidget {
  final Widget child;
  final bool condition;
  final Widget Function(Widget child) animatedBuilder;
  
  const ConditionalAnimation({
    super.key,
    required this.child,
    required this.condition,
    required this.animatedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? animatedBuilder(child) : child;
  }
}
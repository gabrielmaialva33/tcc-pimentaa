import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget de fundo com gradiente suave e terapêutico
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final bool showPattern;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.backgroundGradient,
      ),
      child: showPattern
          ? Stack(
        children: [
          // Padrão sutil de pontos para textura
          _buildPattern(),
          child,
        ],
      )
          : child,
    );
  }

  Widget _buildPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: DotPatternPainter(),
      ),
    );
  }
}

/// Painter para criar padrão sutil de pontos
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

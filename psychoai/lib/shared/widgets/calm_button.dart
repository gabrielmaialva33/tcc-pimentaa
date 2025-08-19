import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Botão com design calmante e animações suaves
class CalmButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double? width;
  final double? height;

  const CalmButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<CalmButton> createState() => _CalmButtonState();
}

class _CalmButtonState extends State<CalmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppColors.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: widget.elevation ?? 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(16),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor ?? AppColors.onPrimary,
                          ),
                        ),
                      )
                          : DefaultTextStyle(
                        style: TextStyle(
                          color: widget.foregroundColor ?? AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  LinearGradient _getGradient() {
    final baseColor = widget.backgroundColor ?? AppColors.primary;
    return LinearGradient(
      colors: _isPressed
          ? [
        baseColor.withValues(alpha: 0.8),
        baseColor.withValues(alpha: 0.9),
      ]
          : [
        baseColor,
        baseColor.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Variante do CalmButton para botões secundários
class CalmOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double? width;
  final double? height;

  const CalmOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? AppColors.primary,
          width: 1.5,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? AppColors.primary,
                  ),
                ),
              )
                  : DefaultTextStyle(
                style: TextStyle(
                  color: foregroundColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 20, end: 0);
  }
}

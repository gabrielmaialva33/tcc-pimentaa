import 'package:flutter/material.dart';

/// Classe para gerenciar Hero animations customizadas no app
class HeroAnimations {
  // Tags para Hero animations
  static const String logoTag = 'app_logo';
  static const String primaryButtonTag = 'primary_button';
  static const String emotionSelectorTag = 'emotion_selector';
  static const String analysisCardTag = 'analysis_card';
  static const String memoryFieldTag = 'memory_field';
  
  /// Hero animation para transição do logo
  static Widget buildLogoHero({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: Opacity(
                opacity: 1.0 - (animation.value * 0.2),
                child: toHeroContext.widget,
              ),
            );
          },
        );
      },
    );
  }

  /// Hero animation para botões
  static Widget buildButtonHero({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: child,
        ),
      ),
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final tween = ColorTween(
          begin: const Color(0xFF6B5B95),
          end: const Color(0xFF9A8BC4),
        );
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: tween.evaluate(animation),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: tween.evaluate(animation)?.withValues(alpha: 0.3) ?? Colors.transparent,
                    blurRadius: 8 * animation.value,
                    offset: Offset(0, 4 * animation.value),
                  ),
                ],
              ),
              child: toHeroContext.widget,
            );
          },
        );
      },
    );
  }

  /// Hero animation para cards
  static Widget buildCardHero({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: animation.value * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1 * animation.value),
                      blurRadius: 20 * animation.value,
                      offset: Offset(0, 10 * animation.value),
                    ),
                  ],
                ),
                child: toHeroContext.widget,
              ),
            );
          },
        );
      },
    );
  }

  /// Transição customizada entre páginas
  static PageRouteBuilder buildPageRoute({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var offsetAnimation = Tween(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        var fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.3, 1.0, curve: curve),
        ));

        var scaleAnimation = Tween(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Transição com efeito de breathing
  static PageRouteBuilder buildBreathingTransition({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var breathingAnimation = Tween(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutSine,
        ));

        var fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: breathingAnimation.value,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

/// Extensão para facilitar navegação com Hero animations
extension HeroNavigation on BuildContext {
  /// Navega para próxima tela com Hero animation
  Future<T?> pushHeroRoute<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      HeroAnimations.buildPageRoute(page: page),
    );
  }

  /// Navega com transição breathing
  Future<T?> pushBreathingRoute<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      HeroAnimations.buildBreathingTransition(page: page),
    );
  }
}
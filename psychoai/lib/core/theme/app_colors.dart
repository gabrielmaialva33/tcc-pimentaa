import 'package:flutter/material.dart';

/// Paleta de cores terapêutica baseada em princípios psicológicos
/// de calma, segurança e acolhimento
class AppColors {
  // Cores Primárias - Baseadas em tranquilidade e profundidade
  static const Color primary = Color(0xFF6B5B95); // Lavanda profunda
  static const Color primaryLight = Color(0xFF9A8BC4);
  static const Color primaryDark = Color(0xFF4A3F6B);
  
  // Cores Secundárias - Serenidade e confiança
  static const Color secondary = Color(0xFF88B0D3); // Azul serenidade
  static const Color secondaryLight = Color(0xFFB8D0E8);
  static const Color secondaryDark = Color(0xFF5A7FA3);
  
  // Cores de Fundo - Acolhimento e suavidade
  static const Color background = Color(0xFFF7F4F0); // Creme suave
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F2EE);
  
  // Cores de Texto - Legibilidade e hierarquia
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF2D3436);
  static const Color onBackground = Color(0xFF2D3436);
  static const Color onSurface = Color(0xFF2D3436);
  static const Color onSurfaceVariant = Color(0xFF5D5D5D);
  
  // Cores de Acento - Equilíbrio e destaque
  static const Color accent = Color(0xFFA8DADC); // Verde água
  static const Color accentLight = Color(0xFFC7E9EB);
  static const Color accentDark = Color(0xFF7BB0B3);
  
  // Cores de Status - Comunicação emocional
  static const Color success = Color(0xFF81C784); // Verde suave
  static const Color warning = Color(0xFFFFB74D); // Laranja calmante
  static const Color error = Color(0xFFE57373); // Vermelho suave
  static const Color info = Color(0xFF64B5F6); // Azul informativo
  
  // Cores de Emoção - Para seletor de sentimentos
  static const Color joy = Color(0xFFFFD54F); // Amarelo alegria
  static const Color sadness = Color(0xFF81C9E8); // Azul tristeza
  static const Color anger = Color(0xFFFF8A80); // Vermelho raiva
  static const Color fear = Color(0xFFB39DDB); // Roxo medo
  static const Color calm = Color(0xFFA5D6A7); // Verde calma
  static const Color anxiety = Color(0xFFFFCC02); // Amarelo ansiedade
  
  // Gradientes Terapêuticos
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient calmGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const Gradient backgroundGradient = LinearGradient(
    colors: [background, surfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Cores para Dark Mode (modo noturno terapêutico)
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkPrimary = Color(0xFF9A8BC4);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  
  // Opacidades para sobreposições suaves
  static const double overlayLight = 0.1;
  static const double overlayMedium = 0.3;
  static const double overlayStrong = 0.6;
  
  /// Retorna a cor correspondente a uma emoção
  static Color getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'alegria':
      case 'joy':
        return joy;
      case 'tristeza':
      case 'sadness':
        return sadness;
      case 'raiva':
      case 'anger':
        return anger;
      case 'medo':
      case 'fear':
        return fear;
      case 'calma':
      case 'calm':
        return calm;
      case 'ansiedade':
      case 'anxiety':
        return anxiety;
      default:
        return accent;
    }
  }
  
  /// Retorna cor com opacidade baseada na intensidade emocional
  static Color getIntensityColor(Color baseColor, double intensity) {
    // Intensidade de 0.0 a 1.0
    final alpha = (intensity * 255).clamp(50, 255).toInt();
    return baseColor.withAlpha(alpha);
  }
}

/// Extensão para facilitar o uso das cores
extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors();
}
import 'package:flutter/material.dart';

/// Paleta de cores terapêutica redesenhada baseada em neurociência e 
/// psicologia das cores para máximo acolhimento e bem-estar
class AppColors {
  // Cores Primárias - Azul serenidade (reduz cortisol, promove confiança)
  static const Color primary = Color(0xFF4A7C87); // Azul-acinzentado tranquilo
  static const Color primaryLight = Color(0xFF6FA5B3);
  static const Color primaryDark = Color(0xFF2E5A63);

  // Cores Secundárias - Verde-menta suave (equilibrio e renovação)
  static const Color secondary = Color(0xFF7FB069); // Verde-menta terapêutico
  static const Color secondaryLight = Color(0xFFA8C98B);
  static const Color secondaryDark = Color(0xFF5C8347);

  // Cores de Fundo - Tons terrosos acolhedores
  static const Color background = Color(0xFFFAF8F5); // Off-white caloroso
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EDE8); // Areia suave

  // Cores de Texto - Legibilidade otimizada (contraste WCAG AA)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF2C3E35); // Verde-escuro suave
  static const Color onSurface = Color(0xFF2C3E35);
  static const Color onSurfaceVariant = Color(0xFF546B5D); // Verde-médio

  // Cores de Acento - Coral suave (vitalidade sem agressividade)
  static const Color accent = Color(0xFFE09F7D); // Coral terapêutico
  static const Color accentLight = Color(0xFFF2C4A8);
  static const Color accentDark = Color(0xFFBF7A52);

  // Cores de Status - Comunicação emocional suavizada
  static const Color success = Color(0xFF8BC9A3); // Verde esperança
  static const Color warning = Color(0xFFF4B942); // Dourado calmante
  static const Color error = Color(0xFFE88B7A); // Vermelho-coral suave
  static const Color info = Color(0xFF6BA5C7); // Azul-cinza informativo

  // Cores de Emoção - Paleta atualizada para máximo conforto visual
  static const Color joy = Color(0xFFF7DC6F); // Dourado alegria suave
  static const Color sadness = Color(0xFF85C1E9); // Azul-céu melancolia
  static const Color anger = Color(0xFFEC7063); // Vermelho-salmão moderado
  static const Color fear = Color(0xFFBB8FCE); // Lavanda-acinzentado
  static const Color calm = Color(0xFF82E0AA); // Verde-menta calmante
  static const Color anxiety = Color(0xFFF8C471); // Âmbar suave

  // Gradientes Terapêuticos Redesenhados
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A7C87), Color(0xFF6FA5B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.8],
  );

  static const Gradient calmGradient = LinearGradient(
    colors: [Color(0xFF7FB069), Color(0xFFA8C98B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.2, 1.0],
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAF8F5), Color(0xFFF0EDE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.7],
  );

  // Novo gradiente de bem-estar para elementos especiais
  static const Gradient wellnessGradient = LinearGradient(
    colors: [Color(0xFFE09F7D), Color(0xFFF2C4A8), Color(0xFF7FB069)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Cores para Dark Mode (modo noturno terapêutico redesenhado)
  static const Color darkBackground = Color(0xFF1A2025); // Azul-escuro acolhedor
  static const Color darkSurface = Color(0xFF232B33); // Azul-acinzentado
  static const Color darkPrimary = Color(0xFF7FB3C3); // Azul-menta claro
  static const Color darkSecondary = Color(0xFF9BC9A1); // Verde-menta noturno
  static const Color darkAccent = Color(0xFFF2B58A); // Coral suave noturno
  static const Color darkOnSurface = Color(0xFFE8EDF0); // Quase-branco azulado
  static const Color darkOnBackground = Color(0xFFE8EDF0);
  static const Color darkSurfaceVariant = Color(0xFF2A3439); // Azul-escuro-médio

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

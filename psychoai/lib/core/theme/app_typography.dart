import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia otimizada para aplicações terapêuticas
/// Prioriza legibilidade, acessibilidade e conforto visual
class AppTypography {
  /// Fonte principal - Inter (humanista, alta legibilidade)
  static String get primaryFont => 'Inter';

  /// Configuração base da tipografia
  static TextTheme get textTheme =>
      GoogleFonts.interTextTheme().copyWith(
        // Títulos principais - para headers e seções importantes
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),

        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.25,
        ),

        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
        ),

        // Títulos de seção
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
        ),

        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.35,
        ),

        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),

        // Títulos menores - para cards e componentes
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
        ),

        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.45,
        ),

        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          height: 1.5,
        ),

        // Corpo do texto - otimizado para leitura prolongada
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.6, // Altura de linha confortável para leitura
        ),

        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.55,
        ),

        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          height: 1.5,
        ),

        // Labels e botões
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          height: 1.4,
        ),

        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          height: 1.35,
        ),

        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.3,
        ),
      );

  /// Configurações responsivas baseadas no tamanho da tela
  static TextTheme getResponsiveTextTheme(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final scaleFactor = _getScaleFactor(screenWidth);

    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge!.copyWith(
        fontSize: (textTheme.displayLarge!.fontSize! * scaleFactor),
      ),
      displayMedium: textTheme.displayMedium!.copyWith(
        fontSize: (textTheme.displayMedium!.fontSize! * scaleFactor),
      ),
      // ... aplicar para todos os estilos se necessário
    );
  }

  /// Calcula fator de escala baseado na largura da tela
  static double _getScaleFactor(double screenWidth) {
    if (screenWidth < 400) return 0.9; // Telas pequenas
    if (screenWidth > 600) return 1.1; // Tablets/Desktop
    return 1.0; // Telas médias (padrão mobile)
  }
}

/// Estilos específicos para contextos terapêuticos
class TherapeuticStyles {
  /// Estilo para texto de lembranças/narrativas
  static TextStyle get memoryText =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.8,
        // Altura generosa para facilitar leitura
        color: const Color(0xFF2D3436),
      );

  /// Estilo para insights da IA
  static TextStyle get aiInsight =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.6,
        color: const Color(0xFF6B5B95),
        fontStyle: FontStyle.italic,
      );

  /// Estilo para labels de emoções
  static TextStyle get emotionLabel =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.3,
        color: const Color(0xFF5D5D5D),
      );

  /// Estilo para datas e timestamps
  static TextStyle get timestamp =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.3,
        color: const Color(0xFF8D8D8D),
      );

  /// Estilo para placeholders suaves
  static TextStyle get placeholder =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.6,
        color: const Color(0xFFB0B0B0),
        fontStyle: FontStyle.italic,
      );

  /// Estilo para títulos de seções no dashboard
  static TextStyle get dashboardSection =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
        color: const Color(0xFF2D3436),
      );

  /// Estilo para estatísticas/números
  static TextStyle get statistic =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
        color: const Color(0xFF6B5B95),
      );
}

/// Estilos para acessibilidade
class AccessibilityStyles {
  /// Texto grande para usuários com dificuldades visuais
  static TextStyle get largeText =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.8,
      );

  /// Alto contraste para melhor legibilidade
  static TextStyle get highContrast =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.6,
        color: const Color(0xFF000000),
      );
}

/// Extensão para facilitar o uso da tipografia
extension AppTypographyExtension on BuildContext {
  TextTheme get typography => AppTypography.textTheme;

  TherapeuticStyles get therapeuticStyles => TherapeuticStyles();
}

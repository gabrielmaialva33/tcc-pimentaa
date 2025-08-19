import 'package:json_annotation/json_annotation.dart';
import '../prompts/freudian_prompt.dart';

part 'analysis_result.g.dart';

/// Resultado de uma análise psicanalítica
@JsonSerializable()
class AnalysisResult {
  final String id;
  final String memoryText;
  final List<String> emotions;
  final double emotionalIntensity;
  final AnalysisType analysisType;
  final String analysisText;
  final List<String> insights;
  final List<String> screenMemoryIndicators;
  final List<String> defenseMechanisms;
  final List<String> therapeuticSuggestions;
  final DateTime timestamp;
  final String modelUsed;
  final TokenUsage tokenUsage;

  AnalysisResult({
    required this.id,
    required this.memoryText,
    required this.emotions,
    required this.emotionalIntensity,
    required this.analysisType,
    required this.analysisText,
    required this.insights,
    required this.screenMemoryIndicators,
    required this.defenseMechanisms,
    required this.therapeuticSuggestions,
    required this.timestamp,
    required this.modelUsed,
    required this.tokenUsage,
  });

  /// Fábrica para criar do JSON
  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  /// Cria uma cópia com novos valores
  AnalysisResult copyWith({
    String? id,
    String? memoryText,
    List<String>? emotions,
    double? emotionalIntensity,
    AnalysisType? analysisType,
    String? analysisText,
    List<String>? insights,
    List<String>? screenMemoryIndicators,
    List<String>? defenseMechanisms,
    List<String>? therapeuticSuggestions,
    DateTime? timestamp,
    String? modelUsed,
    TokenUsage? tokenUsage,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      memoryText: memoryText ?? this.memoryText,
      emotions: emotions ?? this.emotions,
      emotionalIntensity: emotionalIntensity ?? this.emotionalIntensity,
      analysisType: analysisType ?? this.analysisType,
      analysisText: analysisText ?? this.analysisText,
      insights: insights ?? this.insights,
      screenMemoryIndicators: screenMemoryIndicators ??
          this.screenMemoryIndicators,
      defenseMechanisms: defenseMechanisms ?? this.defenseMechanisms,
      therapeuticSuggestions: therapeuticSuggestions ??
          this.therapeuticSuggestions,
      timestamp: timestamp ?? this.timestamp,
      modelUsed: modelUsed ?? this.modelUsed,
      tokenUsage: tokenUsage ?? this.tokenUsage,
    );
  }

  /// Retorna resumo da análise para exibição
  String get summary {
    final buffer = StringBuffer();

    if (insights.isNotEmpty) {
      buffer.writeln('🔍 Principais Insights:');
      for (final insight in insights.take(3)) {
        buffer.writeln('• $insight');
      }
    }

    if (screenMemoryIndicators.isNotEmpty) {
      buffer.writeln('\n🎭 Indicadores de Lembrança Encobridora:');
      for (final indicator in screenMemoryIndicators.take(2)) {
        buffer.writeln('• $indicator');
      }
    }

    if (defenseMechanisms.isNotEmpty) {
      buffer.writeln(
          '\n🛡️ Mecanismos de Defesa: ${defenseMechanisms.join(', ')}');
    }

    return buffer.toString();
  }

  /// Verifica se há indicadores fortes de lembrança encobridora
  bool get hasStrongScreenMemoryIndicators =>
      screenMemoryIndicators.length >= 2;

  /// Retorna a qualidade da análise baseada em métricas
  AnalysisQuality get quality {
    int score = 0;

    // Pontuação baseada na completude da análise
    if (insights.length >= 3) score += 2;
    if (screenMemoryIndicators.isNotEmpty) score += 1;
    if (defenseMechanisms.isNotEmpty) score += 1;
    if (therapeuticSuggestions.length >= 2) score += 2;
    if (analysisText.length >= 500) score += 1;

    if (score >= 6) return AnalysisQuality.excellent;
    if (score >= 4) return AnalysisQuality.good;
    if (score >= 2) return AnalysisQuality.fair;
    return AnalysisQuality.poor;
  }

  /// Custo estimado da análise em USD
  double get estimatedCost {
    final inputCost = (tokenUsage.promptTokens / 1000) * 0.003;
    final outputCost = (tokenUsage.completionTokens / 1000) * 0.004;
    return inputCost + outputCost;
  }
}

/// Informações sobre uso de tokens
@JsonSerializable()
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageFromJson(json);

  Map<String, dynamic> toJson() => _$TokenUsageToJson(this);
}

/// Resultado de análise de padrões entre múltiplas lembranças
@JsonSerializable()
class PatternAnalysisResult {
  final String id;
  final int analysesCount;
  final String patternsText;
  final DateTime timestamp;
  final List<String> identifiedPatterns;
  final List<String> recommendations;

  PatternAnalysisResult({
    required this.id,
    required this.analysesCount,
    required this.patternsText,
    required this.timestamp,
    this.identifiedPatterns = const [],
    this.recommendations = const [],
  });

  factory PatternAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$PatternAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$PatternAnalysisResultToJson(this);
}

/// Qualidade da análise
enum AnalysisQuality {
  poor('Básica'),
  fair('Adequada'),
  good('Boa'),
  excellent('Excelente');

  const AnalysisQuality(this.displayName);

  final String displayName;
}

/// Estatísticas agregadas de análises
@JsonSerializable()
class AnalysisStatistics {
  final int totalAnalyses;
  final Map<String, int> emotionFrequency;
  final Map<String, int> defenseMechanismFrequency;
  final double averageEmotionalIntensity;
  final int screenMemoryCount;
  final DateTime firstAnalysis;
  final DateTime lastAnalysis;

  AnalysisStatistics({
    required this.totalAnalyses,
    required this.emotionFrequency,
    required this.defenseMechanismFrequency,
    required this.averageEmotionalIntensity,
    required this.screenMemoryCount,
    required this.firstAnalysis,
    required this.lastAnalysis,
  });

  factory AnalysisStatistics.fromAnalyses(List<AnalysisResult> analyses) {
    if (analyses.isEmpty) {
      final now = DateTime.now();
      return AnalysisStatistics(
        totalAnalyses: 0,
        emotionFrequency: {},
        defenseMechanismFrequency: {},
        averageEmotionalIntensity: 0.0,
        screenMemoryCount: 0,
        firstAnalysis: now,
        lastAnalysis: now,
      );
    }

    // Calcular frequência de emoções
    final emotionFreq = <String, int>{};
    for (final analysis in analyses) {
      for (final emotion in analysis.emotions) {
        emotionFreq[emotion] = (emotionFreq[emotion] ?? 0) + 1;
      }
    }

    // Calcular frequência de mecanismos de defesa
    final defenseFreq = <String, int>{};
    for (final analysis in analyses) {
      for (final mechanism in analysis.defenseMechanisms) {
        defenseFreq[mechanism] = (defenseFreq[mechanism] ?? 0) + 1;
      }
    }

    // Calcular intensidade emocional média
    final avgIntensity = analyses
        .map((a) => a.emotionalIntensity)
        .reduce((a, b) => a + b) / analyses.length;

    // Contar lembranças encobridoras
    final screenMemoryCount = analyses
        .where((a) => a.hasStrongScreenMemoryIndicators)
        .length;

    // Encontrar primeiro e último
    analyses.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return AnalysisStatistics(
      totalAnalyses: analyses.length,
      emotionFrequency: emotionFreq,
      defenseMechanismFrequency: defenseFreq,
      averageEmotionalIntensity: avgIntensity,
      screenMemoryCount: screenMemoryCount,
      firstAnalysis: analyses.first.timestamp,
      lastAnalysis: analyses.last.timestamp,
    );
  }

  factory AnalysisStatistics.fromJson(Map<String, dynamic> json) =>
      _$AnalysisStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisStatisticsToJson(this);

  /// Duração total do período de análises
  Duration get analysisSpan => lastAnalysis.difference(firstAnalysis);

  /// Emoção mais frequente
  String? get mostFrequentEmotion {
    if (emotionFrequency.isEmpty) return null;
    return emotionFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Mecanismo de defesa mais comum
  String? get mostCommonDefenseMechanism {
    if (defenseMechanismFrequency.isEmpty) return null;
    return defenseMechanismFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Percentual de lembranças encobridoras
  double get screenMemoryPercentage {
    if (totalAnalyses == 0) return 0.0;
    return (screenMemoryCount / totalAnalyses) * 100;
  }
}

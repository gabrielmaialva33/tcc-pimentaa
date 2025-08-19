import 'package:flutter/foundation.dart';
import '../../core/api/nvidia_client.dart';
import '../../core/api/nvidia_config.dart';
import '../../core/services/ai_provider_service.dart';
import 'prompts/freudian_prompt.dart';
import 'models/analysis_result.dart';

/// Serviço para análise de lembranças usando múltiplos provedores de IA
class AIAnalysisService {
  final NvidiaClient _client;
  final AIProviderService _providerService;

  AIAnalysisService() : 
    _client = NvidiaClient(),
    _providerService = AIProviderService.instance;

  /// Analisa uma lembrança usando IA especializada em psicanálise
  Future<AnalysisResult> analyzeMemory({
    required String memoryText,
    required List<String> emotions,
    required double emotionalIntensity,
    AnalysisType analysisType = AnalysisType.complete,
    String? previousContext,
  }) async {
    try {
      // Validar entrada
      final validation = FreudianPrompts.validateMemoryText(memoryText);
      if (!validation.isValid) {
        throw AnalysisException(
          validation.message ?? 'Texto inválido',
          code: validation.needsProfessionalHelp
              ? 'NEEDS_PROFESSIONAL_HELP'
              : 'INVALID_INPUT',
        );
      }

      // Preparar prompt base
      final basePrompt = FreudianPrompts.fillTemplate(
        analysisType.prompt,
        memoryText: memoryText,
        emotions: emotions,
        intensity: emotionalIntensity,
        previousAnalyses: previousContext,
      );

      // Se é conteúdo sensível, adicionar aviso ao prompt
      String finalPrompt = basePrompt;
      if (validation.isSensitiveContent) {
        finalPrompt = '''
AVISO IMPORTANTE: Este conteúdo envolve temas sensíveis. Forneça uma análise cuidadosa, empática e construtiva, enfatizando a importância do acompanhamento profissional.

$basePrompt
''';
      }

      // Configurar modelo baseado no tipo de análise
      final modelConfig = _getModelConfig(analysisType);

      // Fazer requisição usando o provedor ativo (NVIDIA ou Alibaba)
      final response = await _providerService.generateText(
        prompt: finalPrompt,
        model: modelConfig.model,
        temperature: modelConfig.temperature,
        maxTokens: modelConfig.maxTokens,
        additionalParams: {
          'top_p': 0.9,
          'frequency_penalty': 0.1,
          'presence_penalty': 0.1,
        },
      );

      // Processar resposta
      final analysisText = response.content;
      if (analysisText.isEmpty) {
        throw AnalysisException(
          'Resposta vazia da IA. Tente novamente.',
          code: 'EMPTY_RESPONSE',
        );
      }

      // Criar resultado estruturado
      final result = AnalysisResult(
        id: _generateAnalysisId(),
        memoryText: memoryText,
        emotions: emotions,
        emotionalIntensity: emotionalIntensity,
        analysisType: analysisType,
        analysisText: analysisText,
        insights: _extractInsights(analysisText),
        screenMemoryIndicators: _extractScreenMemoryIndicators(analysisText),
        defenseMechanisms: _extractDefenseMechanisms(analysisText),
        therapeuticSuggestions: _extractTherapeuticSuggestions(analysisText),
        timestamp: DateTime.now(),
        modelUsed: modelConfig.model,
        tokenUsage: TokenUsage(
          promptTokens: response.usage?.promptTokens ?? 0,
          completionTokens: response.usage?.completionTokens ?? 0,
          totalTokens: response.usage?.totalTokens ?? 0,
        ),
      );

      return result;
    } on NvidiaException catch (e) {
      throw AnalysisException(
        _translateNvidiaError(e.message),
        code: e.code,
      );
    } catch (e) {
      debugPrint('Erro na análise: $e');
      throw AnalysisException(
        'Erro inesperado durante a análise. Tente novamente.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Analisa múltiplas lembranças para identificar padrões gerais
  Future<PatternAnalysisResult> analyzePatterns(
      List<AnalysisResult> previousAnalyses,) async {
    if (previousAnalyses.length < 2) {
      throw AnalysisException(
        'São necessárias pelo menos 2 análises para detectar padrões.',
        code: 'INSUFFICIENT_DATA',
      );
    }

    try {
      // Preparar contexto das análises anteriores
      final context = previousAnalyses
          .map((analysis) => '''
Lembrança: ${analysis.memoryText.substring(0, 200)}...
Emoções: ${analysis.emotions.join(', ')}
Insights: ${analysis.insights.take(3).join('; ')}
''')
          .join('\n---\n');

      final prompt = '''
Como especialista em psicanálise, analise os padrões recorrentes nestas ${previousAnalyses
          .length} lembranças:

$context

Identifique:
1. Temas recorrentes
2. Padrões emocionais
3. Mecanismos de defesa frequentes
4. Possível compulsão à repetição
5. Evolução ou estagnação nos padrões
6. Recomendações para desenvolvimento pessoal

Forneça uma análise integrada e construtiva.
''';

      final response = await _client.sendChatCompletion(
        prompt: prompt,
        model: NvidiaConfig.defaultModel,
        temperature: 0.6,
        maxTokens: 1500,
      );

      return PatternAnalysisResult(
        id: _generateAnalysisId(),
        analysesCount: previousAnalyses.length,
        patternsText: response.content,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw AnalysisException(
        'Erro ao analisar padrões: $e',
        code: 'PATTERN_ANALYSIS_ERROR',
      );
    }
  }

  /// Configura modelo baseado no tipo de análise (usando modelos atualizados)
  ModelConfig _getModelConfig(AnalysisType analysisType) {
    switch (analysisType) {
      case AnalysisType.complete:
        return ModelConfig(
          model: NvidiaConfig.defaultModel, // Llama 3.3 70B
          temperature: 0.7,
          maxTokens: 3072,
        );
      case AnalysisType.quickPattern:
        return ModelConfig(
          model: 'meta/llama-3.2-3b-instruct', // Modelo mais rápido e eficiente
          temperature: 0.5,
          maxTokens: 1536,
        );
      case AnalysisType.screenMemory:
        return ModelConfig(
          model: 'google/gemma-2-27b-it', // Especializado em análise de padrões
          temperature: 0.6,
          maxTokens: 2048,
        );
      case AnalysisType.defenseMechanisms:
      case AnalysisType.transference:
        return ModelConfig(
          model: 'mistralai/mixtral-8x22b-instruct',
          // Melhor para análises complexas
          temperature: 0.6,
          maxTokens: 2048,
        );
      case AnalysisType.dreamAnalysis:
        return ModelConfig(
          model: 'nvidia/llama-3.1-nemotron-70b-instruct', // NVIDIA otimizado
          temperature: 0.8,
          maxTokens: 2560,
        );
    }
  }

  /// Extrai insights estruturados do texto de análise
  List<String> _extractInsights(String analysisText) {
    final insights = <String>[];

    // Buscar seções de insights
    final patterns = [
      RegExp(r'##?\s*.*INSIGHTS.*\n(.*?)(?=##|$)', dotAll: true,
          caseSensitive: false),
      RegExp(r'##?\s*.*AUTOCONHECIMENTO.*\n(.*?)(?=##|$)', dotAll: true,
          caseSensitive: false),
      RegExp(r'- ([^-\n]+(?:reflexão|insight|compreensão|padrão)[^-\n]*)',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(analysisText);
      for (final match in matches) {
        final content = match.group(1)?.trim();
        if (content != null && content.isNotEmpty) {
          // Dividir em linhas e filtrar
          final lines = content.split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty && !line.startsWith('#'))
              .take(5);
          insights.addAll(lines);
        }
      }
    }

    return insights.take(8).toList();
  }

  /// Extrai indicadores de lembranças encobridoras
  List<String> _extractScreenMemoryIndicators(String analysisText) {
    final indicators = <String>[];

    final pattern = RegExp(
      r'##?\s*.*(?:ENCOBRIDORA|SCREEN|OCULTA).*\n(.*?)(?=##|$)',
      dotAll: true,
      caseSensitive: false,
    );

    final match = pattern.firstMatch(analysisText);
    if (match != null) {
      final content = match.group(1)?.trim();
      if (content != null) {
        indicators.addAll(
          content.split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty && line.startsWith('-'))
              .map((line) => line.substring(1).trim())
              .take(5),
        );
      }
    }

    return indicators;
  }

  /// Extrai mecanismos de defesa identificados
  List<String> _extractDefenseMechanisms(String analysisText) {
    final mechanisms = <String>[];

    final knownMechanisms = [
      'negação', 'projeção', 'racionalização', 'sublimação', 'repressão',
      'formação reativa', 'isolamento', 'regressão', 'deslocamento'
    ];

    for (final mechanism in knownMechanisms) {
      final pattern = RegExp(
        '$mechanism[^.]*',
        caseSensitive: false,
      );

      if (pattern.hasMatch(analysisText)) {
        mechanisms.add(mechanism);
      }
    }

    return mechanisms;
  }

  /// Extrai sugestões terapêuticas
  List<String> _extractTherapeuticSuggestions(String analysisText) {
    final suggestions = <String>[];

    final pattern = RegExp(
      r'##?\s*.*(?:SUGESTÕES|TERAPÊUTICA|EXPLORAÇÃO).*\n(.*?)(?=##|$)',
      dotAll: true,
      caseSensitive: false,
    );

    final match = pattern.firstMatch(analysisText);
    if (match != null) {
      final content = match.group(1)?.trim();
      if (content != null) {
        suggestions.addAll(
          content.split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty && line.startsWith('-'))
              .map((line) => line.substring(1).trim())
              .take(6),
        );
      }
    }

    return suggestions;
  }

  /// Traduz erros da NVIDIA para mensagens amigáveis
  String _translateNvidiaError(String error) {
    if (error.contains('rate limit') || error.contains('429')) {
      return 'Muitas análises em pouco tempo. Aguarde alguns minutos antes de tentar novamente.';
    }
    if (error.contains('unauthorized') || error.contains('401')) {
      return 'Erro de autenticação com o serviço de IA. Tente novamente mais tarde.';
    }
    if (error.contains('timeout')) {
      return 'A análise está demorando mais que o esperado. Tente novamente.';
    }
    if (error.contains('server error') || error.contains('500')) {
      return 'Serviço de IA temporariamente indisponível. Tente novamente em alguns minutos.';
    }
    return 'Erro ao processar análise. Verifique sua conexão e tente novamente.';
  }

  /// Gera ID único para análise
  String _generateAnalysisId() {
    return 'analysis_${DateTime
        .now()
        .millisecondsSinceEpoch}_${DateTime
        .now()
        .microsecond}';
  }

  /// Verifica saúde da API
  Future<bool> checkApiHealth() => _client.checkApiHealth();

  /// Estima custo de uma análise
  double estimateAnalysisCost({
    required String memoryText,
    required AnalysisType analysisType,
  }) {
    final config = _getModelConfig(analysisType);
    return _client.estimateCost(
      prompt: memoryText,
      maxTokens: config.maxTokens,
      model: config.model,
    );
  }

  /// Limpa recursos
  void dispose() {
    _client.dispose();
  }
}

/// Configuração de modelo
class ModelConfig {
  final String model;
  final double temperature;
  final int maxTokens;

  ModelConfig({
    required this.model,
    required this.temperature,
    required this.maxTokens,
  });
}

/// Exceção específica para análises
class AnalysisException implements Exception {
  final String message;
  final String code;

  AnalysisException(this.message, {required this.code});

  @override
  String toString() => 'AnalysisException($code): $message';
}

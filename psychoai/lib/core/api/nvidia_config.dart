/// Configuração da API NVIDIA para análise psicanalítica
class NvidiaConfig {
  // API Key fornecida
  static const String apiKey = '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';

  // Base URL da NVIDIA API
  static const String baseUrl = 'https://integrate.api.nvidia.com';

  // Endpoints principais
  static const String chatCompletionsEndpoint = '/v1/chat/completions';

  // Modelos recomendados para análise psicanalítica (atualizados 2024)
  static const String defaultModel = 'meta/llama-3.3-70b-instruct';
  static const String fallbackModel = 'nvidia/llama-3.1-nemotron-70b-instruct';

  // Modelos disponíveis com suas especialidades (baseado na API atual)
  static const Map<String, ModelInfo> availableModels = {
    'meta/llama-3.3-70b-instruct': ModelInfo(
      name: 'Llama 3.3 70B',
      description: 'Modelo mais recente para análise profunda e contextual',
      maxTokens: 8192,
      temperature: 0.7,
      specialty: 'Análise psicanalítica avançada com melhor compreensão contextual',
    ),
    'nvidia/llama-3.1-nemotron-70b-instruct': ModelInfo(
      name: 'Nemotron 70B',
      description: 'Modelo NVIDIA otimizado para análise detalhada',
      maxTokens: 8192,
      temperature: 0.6,
      specialty: 'Análise de padrões psicológicos e insights profundos',
    ),
    'meta/llama-3.2-3b-instruct': ModelInfo(
      name: 'Llama 3.2 3B',
      description: 'Modelo compacto e eficiente para análises rápidas',
      maxTokens: 4096,
      temperature: 0.5,
      specialty: 'Detecção básica de emoções e padrões',
    ),
    'mistralai/mixtral-8x22b-instruct': ModelInfo(
      name: 'Mixtral 8x22B',
      description: 'Modelo de última geração para múltiplas perspectivas',
      maxTokens: 8192,
      temperature: 0.6,
      specialty: 'Análise multi-dimensional e identificação de mecanismos de defesa',
    ),
    'google/gemma-2-27b-it': ModelInfo(
      name: 'Gemma 2 27B',
      description: 'Modelo Google para análise equilibrada',
      maxTokens: 4096,
      temperature: 0.6,
      specialty: 'Análise de lembranças encobridoras e padrões emocionais',
    ),
  };

  // Configurações de requisição (otimizadas para Android/móvel)
  static const int timeoutSeconds = 60; // Aumentado para conexões móveis
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(
      seconds: 3); // Aumentado para evitar rate limit

  // Headers padrão
  static Map<String, String> get defaultHeaders =>
      {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'PsychoAI/1.0.0',
      };

  // Configurações de prompt
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 2048;
  static const double defaultTopP = 0.9;
  static const int defaultTopK = 50;

  // Limites de uso
  static const int maxPromptLength = 8000; // caracteres
  static const int maxDailyRequests = 1000;
  static const int rateLimitPerMinute = 60;

  // Configurações de segurança
  static const bool enableContentFiltering = true;
  static const bool logRequests = false; // false em produção por privacidade

  // Tipos de análise disponíveis (com modelos atualizados)
  static const Map<String, NvidiaAnalysisType> analysisTypes = {
    'complete': NvidiaAnalysisType(
      name: 'Análise Completa',
      model: 'meta/llama-3.3-70b-instruct',
      temperature: 0.7,
      maxTokens: 3072,
    ),
    'quick': NvidiaAnalysisType(
      name: 'Análise Rápida',
      model: 'meta/llama-3.2-3b-instruct',
      temperature: 0.5,
      maxTokens: 1536,
    ),
    'pattern': NvidiaAnalysisType(
      name: 'Detecção de Padrões',
      model: 'mistralai/mixtral-8x22b-instruct',
      temperature: 0.6,
      maxTokens: 2048,
    ),
    'screen_memory': NvidiaAnalysisType(
      name: 'Lembranças Encobridoras',
      model: 'google/gemma-2-27b-it',
      temperature: 0.6,
      maxTokens: 2048,
    ),
    'deep_analysis': NvidiaAnalysisType(
      name: 'Análise Profunda',
      model: 'nvidia/llama-3.1-nemotron-70b-instruct',
      temperature: 0.6,
      maxTokens: 3072,
    ),
  };
}

/// Informações sobre um modelo específico
class ModelInfo {
  final String name;
  final String description;
  final int maxTokens;
  final double temperature;
  final String specialty;

  const ModelInfo({
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.temperature,
    required this.specialty,
  });
}

/// Configuração para tipos de análise
class NvidiaAnalysisType {
  final String name;
  final String model;
  final double temperature;
  final int maxTokens;

  const NvidiaAnalysisType({
    required this.name,
    required this.model,
    required this.temperature,
    required this.maxTokens,
  });
}

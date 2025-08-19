/// Configuração da API NVIDIA para análise psicanalítica
class NvidiaConfig {
  // API Key fornecida
  static const String apiKey = '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';
  
  // Base URL da NVIDIA API
  static const String baseUrl = 'https://integrate.api.nvidia.com';
  
  // Endpoints principais
  static const String chatCompletionsEndpoint = '/v1/chat/completions';
  
  // Modelos recomendados para análise psicanalítica
  static const String defaultModel = 'meta/llama-3.1-70b-instruct';
  static const String fallbackModel = 'mistralai/mixtral-8x7b-instruct';
  
  // Modelos disponíveis com suas especialidades
  static const Map<String, ModelInfo> availableModels = {
    'meta/llama-3.1-70b-instruct': ModelInfo(
      name: 'Llama 3.1 70B',
      description: 'Modelo principal para análise profunda e contextual',
      maxTokens: 4096,
      temperature: 0.7,
      specialty: 'Análise psicanalítica detalhada',
    ),
    'mistralai/mixtral-8x7b-instruct': ModelInfo(
      name: 'Mixtral 8x7B',
      description: 'Modelo alternativo para múltiplas perspectivas',
      maxTokens: 4096,
      temperature: 0.6,
      specialty: 'Análise de padrões e insights',
    ),
    'google/gemma-2b-it': ModelInfo(
      name: 'Gemma 2B',
      description: 'Modelo leve para análises rápidas',
      maxTokens: 2048,
      temperature: 0.5,
      specialty: 'Detecção básica de emoções',
    ),
  };
  
  // Configurações de requisição
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Headers padrão
  static Map<String, String> get defaultHeaders => {
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
  
  // Tipos de análise disponíveis
  static const Map<String, AnalysisType> analysisTypes = {
    'complete': AnalysisType(
      name: 'Análise Completa',
      model: 'meta/llama-3.1-70b-instruct',
      temperature: 0.7,
      maxTokens: 2048,
    ),
    'quick': AnalysisType(
      name: 'Análise Rápida',
      model: 'google/gemma-2b-it',
      temperature: 0.5,
      maxTokens: 1024,
    ),
    'pattern': AnalysisType(
      name: 'Detecção de Padrões',
      model: 'mistralai/mixtral-8x7b-instruct',
      temperature: 0.6,
      maxTokens: 1536,
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
class AnalysisType {
  final String name;
  final String model;
  final double temperature;
  final int maxTokens;
  
  const AnalysisType({
    required this.name,
    required this.model,
    required this.temperature,
    required this.maxTokens,
  });
}
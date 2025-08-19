import 'dart:io';

/// Configuração para integração com Alibaba Cloud Model Studio
class AlibabaConfig {
  // API Key fornecida pelo usuário
  static const String apiKey = 'sk-768a92b30ac945518e5e67a96dd3b1b8';
  
  // Base URL da API da Alibaba Cloud Model Studio
  static const String baseUrl = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';
  
  // Modelos disponíveis na Alibaba Cloud
  static const String qwenTurbo = 'qwen-turbo';
  static const String qwenPlus = 'qwen-plus';
  static const String qwenMax = 'qwen-max';
  static const String qwen72BChat = 'qwen-72b-chat';
  
  // Modelo padrão para análise psicanalítica
  static const String defaultModel = qwenPlus;
  
  // Configurações de timeout
  static const int timeoutSeconds = 45;
  static const int maxRetries = 3;
  
  // Headers necessários para a API
  static Map<String, String> get headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'PsychoAI/1.0.0',
  };
  
  // Modelos e suas descrições
  static const Map<String, ModelInfo> models = {
    qwenTurbo: ModelInfo(
      id: qwenTurbo,
      name: 'Qwen Turbo',
      description: 'Modelo rápido e eficiente para análises básicas',
      maxTokens: 8192,
      costPerToken: 0.002,
    ),
    qwenPlus: ModelInfo(
      id: qwenPlus,
      name: 'Qwen Plus',
      description: 'Modelo balanceado para análises psicanalíticas',
      maxTokens: 32768,
      costPerToken: 0.020,
    ),
    qwenMax: ModelInfo(
      id: qwenMax,
      name: 'Qwen Max',
      description: 'Modelo avançado para análises complexas',
      maxTokens: 32768,
      costPerToken: 0.120,
    ),
    qwen72BChat: ModelInfo(
      id: qwen72BChat,
      name: 'Qwen 72B Chat',
      description: 'Modelo grande para análises profundas',
      maxTokens: 32768,
      costPerToken: 0.060,
    ),
  };
  
  // Parâmetros padrão para geração de texto
  static const Map<String, dynamic> defaultParameters = {
    'result_format': 'text',
    'max_tokens': 2048,
    'temperature': 0.7,
    'top_p': 0.9,
    'top_k': 50,
    'repetition_penalty': 1.1,
    'stop': null,
    'seed': null,
    'stream': false,
  };
  
  /// Valida se a configuração está correta
  static bool isConfigured() {
    return apiKey.isNotEmpty && 
           apiKey != 'your_api_key_here' &&
           apiKey.startsWith('sk-');
  }
  
  /// Retorna informações do modelo especificado
  static ModelInfo? getModelInfo(String modelId) {
    return models[modelId];
  }
  
  /// Lista todos os modelos disponíveis
  static List<ModelInfo> getAllModels() {
    return models.values.toList();
  }
}

/// Informações sobre um modelo específico
class ModelInfo {
  final String id;
  final String name;
  final String description;
  final int maxTokens;
  final double costPerToken;
  
  const ModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.costPerToken,
  });
  
  /// Calcula o custo estimado para um número de tokens
  double calculateCost(int tokens) {
    return tokens * costPerToken / 1000; // Custo por 1K tokens
  }
  
  @override
  String toString() => '$name ($id)';
}

/// Exceção específica para erros da API Alibaba
class AlibabaException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  const AlibabaException(
    this.message, {
    this.code,
    this.statusCode,
  });
  
  @override
  String toString() => 'AlibabaException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Status da resposta da API
enum AlibabaResponseStatus {
  success,
  error,
  timeout,
  rateLimited,
  quotaExceeded,
  unauthorized,
}

/// Extensão para converter códigos HTTP em status
extension AlibabaResponseStatusExtension on int {
  AlibabaResponseStatus get alibabaStatus {
    switch (this) {
      case 200:
        return AlibabaResponseStatus.success;
      case 401:
        return AlibabaResponseStatus.unauthorized;
      case 429:
        return AlibabaResponseStatus.rateLimited;
      case 402:
        return AlibabaResponseStatus.quotaExceeded;
      default:
        if (this >= 500) {
          return AlibabaResponseStatus.error;
        }
        return AlibabaResponseStatus.error;
    }
  }
}
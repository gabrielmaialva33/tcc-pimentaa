import '../api/nvidia_client.dart';
import '../api/nvidia_config.dart';
import '../api/alibaba_client.dart';
import '../api/alibaba_config.dart';

/// Enumeração dos provedores de IA disponíveis
enum AIProvider {
  nvidia('NVIDIA', 'Modelos NVIDIA (Llama, Mistral, Nemotron)', true),
  alibaba('Alibaba Cloud', 'Modelos Qwen da Alibaba Cloud', true);
  
  const AIProvider(this.displayName, this.description, this.available);
  
  final String displayName;
  final String description;
  final bool available;
}

/// Resultado unificado das APIs de IA
class UnifiedAIResponse {
  final String id;
  final String text;
  final String model;
  final AIProvider provider;
  final UnifiedTokenUsage usage;
  final DateTime timestamp;
  
  UnifiedAIResponse({
    required this.id,
    required this.text,
    required this.model,
    required this.provider,
    required this.usage,
    required this.timestamp,
  });
}

/// Uso de tokens unificado
class UnifiedTokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  
  UnifiedTokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
}

/// Exceção unificada para provedores de IA
class AIProviderException implements Exception {
  final String message;
  final AIProvider provider;
  final String? code;
  
  AIProviderException(
    this.message,
    this.provider, {
    this.code,
  });
  
  @override
  String toString() => 'AIProviderException(${provider.displayName}): $message';
}

/// Serviço para gerenciar múltiplos provedores de IA
class AIProviderService {
  static AIProviderService? _instance;
  static AIProviderService get instance => _instance ??= AIProviderService._();
  
  AIProviderService._();
  
  // Clientes dos provedores
  NvidiaClient? _nvidiaClient;
  AlibabaClient? _alibabaClient;
  
  // Provedor atualmente ativo
  AIProvider _activeProvider = AIProvider.nvidia;
  
  /// Obtém o provedor ativo atual
  AIProvider get activeProvider => _activeProvider;
  
  /// Lista todos os provedores disponíveis
  List<AIProvider> get availableProviders => 
    AIProvider.values.where((p) => p.available).toList();
  
  /// Define o provedor ativo
  void setActiveProvider(AIProvider provider) {
    if (!provider.available) {
      throw AIProviderException(
        'Provedor ${provider.displayName} não está disponível',
        provider,
      );
    }
    _activeProvider = provider;
  }
  
  /// Obtém informações do provedor ativo
  ProviderInfo getActiveProviderInfo() {
    switch (_activeProvider) {
      case AIProvider.nvidia:
        return ProviderInfo(
          provider: AIProvider.nvidia,
          isConfigured: NvidiaConfig.isConfigured(),
          models: NvidiaConfig.getAllModels().values.toList(),
          defaultModel: NvidiaConfig.defaultModel,
        );
      case AIProvider.alibaba:
        return ProviderInfo(
          provider: AIProvider.alibaba,
          isConfigured: AlibabaConfig.isConfigured(),
          models: AlibabaConfig.getAllModels(),
          defaultModel: AlibabaConfig.defaultModel,
        );
    }
  }
  
  /// Gera texto usando o provedor ativo
  Future<UnifiedAIResponse> generateText({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? additionalParams,
  }) async {
    
    try {
      switch (_activeProvider) {
        case AIProvider.nvidia:
          return await _generateWithNvidia(
            prompt: prompt,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            additionalParams: additionalParams,
          );
        case AIProvider.alibaba:
          return await _generateWithAlibaba(
            prompt: prompt,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            additionalParams: additionalParams,
          );
      }
    } catch (e) {
      
      // Tentar fallback para outro provedor se disponível
      if (availableProviders.length > 1) {
        final fallbackProvider = availableProviders
            .firstWhere((p) => p != _activeProvider);
        
        
        final originalProvider = _activeProvider;
        setActiveProvider(fallbackProvider);
        
        try {
          final result = await generateText(
            prompt: prompt,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            additionalParams: additionalParams,
          );
          
          return result;
        } catch (fallbackError) {
          // Restaurar provedor original
          setActiveProvider(originalProvider);
          throw AIProviderException(
            'Falha em todos os provedores. Último erro: $fallbackError',
            _activeProvider,
          );
        }
      }
      
      throw AIProviderException(
        'Erro no provedor ${_activeProvider.displayName}: $e',
        _activeProvider,
      );
    }
  }
  
  /// Gera texto usando NVIDIA
  Future<UnifiedAIResponse> _generateWithNvidia({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? additionalParams,
  }) async {
    _nvidiaClient ??= NvidiaClient();
    
    final response = await _nvidiaClient!.sendChatCompletion(
      prompt: prompt,
      model: model ?? NvidiaConfig.defaultModel,
      temperature: temperature ?? 0.7,
      maxTokens: maxTokens ?? 2048,
      additionalParams: additionalParams ?? {},
    );
    
    return UnifiedAIResponse(
      id: response.id,
      text: response.content,
      model: response.model,
      provider: AIProvider.nvidia,
      usage: UnifiedTokenUsage(
        promptTokens: response.usage?.promptTokens ?? 0,
        completionTokens: response.usage?.completionTokens ?? 0,
        totalTokens: response.usage?.totalTokens ?? 0,
      ),
      timestamp: DateTime.now(),
    );
  }
  
  /// Gera texto usando Alibaba Cloud
  Future<UnifiedAIResponse> _generateWithAlibaba({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? additionalParams,
  }) async {
    _alibabaClient ??= AlibabaClient();
    
    final params = <String, dynamic>{
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      ...?additionalParams,
    };
    
    final response = await _alibabaClient!.generateText(
      model: model ?? AlibabaConfig.defaultModel,
      prompt: prompt,
      parameters: params,
    );
    
    return UnifiedAIResponse(
      id: response.id,
      text: response.text,
      model: response.model,
      provider: AIProvider.alibaba,
      usage: UnifiedTokenUsage(
        promptTokens: response.usage.promptTokens,
        completionTokens: response.usage.completionTokens,
        totalTokens: response.usage.totalTokens,
      ),
      timestamp: DateTime.now(),
    );
  }
  
  /// Testa conectividade com o provedor ativo
  Future<bool> testConnection() async {
    try {
      switch (_activeProvider) {
        case AIProvider.nvidia:
          _nvidiaClient ??= NvidiaClient();
          return await _nvidiaClient!.checkApiHealth();
        case AIProvider.alibaba:
          _alibabaClient ??= AlibabaClient();
          return await _alibabaClient!.testConnection();
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Testa conectividade com todos os provedores
  Future<Map<AIProvider, bool>> testAllConnections() async {
    final results = <AIProvider, bool>{};
    
    for (final provider in availableProviders) {
      final originalProvider = _activeProvider;
      try {
        setActiveProvider(provider);
        results[provider] = await testConnection();
      } catch (e) {
        results[provider] = false;
      } finally {
        setActiveProvider(originalProvider);
      }
    }
    
    return results;
  }
  
  /// Estima custo de uma operação
  double estimateCost({
    required String prompt,
    int? maxTokens,
    String? model,
  }) {
    switch (_activeProvider) {
      case AIProvider.nvidia:
        _nvidiaClient ??= NvidiaClient();
        return _nvidiaClient!.estimateCost(
          prompt: prompt,
          maxTokens: maxTokens ?? 2048,
          model: model ?? NvidiaConfig.defaultModel,
        );
      case AIProvider.alibaba:
        final modelInfo = AlibabaConfig.getModelInfo(
          model ?? AlibabaConfig.defaultModel,
        );
        final estimatedTokens = (prompt.length / 4).ceil() + (maxTokens ?? 2048);
        return modelInfo?.calculateCost(estimatedTokens) ?? 0.0;
    }
  }
  
  /// Lista modelos disponíveis do provedor ativo
  List<dynamic> getAvailableModels() {
    switch (_activeProvider) {
      case AIProvider.nvidia:
        return NvidiaConfig.getAllModels().values.toList();
      case AIProvider.alibaba:
        return AlibabaConfig.getAllModels();
    }
  }
  
  /// Libera recursos
  void dispose() {
    _nvidiaClient?.dispose();
    _alibabaClient?.dispose();
    _nvidiaClient = null;
    _alibabaClient = null;
  }
}

/// Informações sobre um provedor específico
class ProviderInfo {
  final AIProvider provider;
  final bool isConfigured;
  final List<dynamic> models;
  final String defaultModel;
  
  ProviderInfo({
    required this.provider,
    required this.isConfigured,
    required this.models,
    required this.defaultModel,
  });
  
  @override
  String toString() {
    return 'ProviderInfo('
        'provider: ${provider.displayName}, '
        'configured: $isConfigured, '
        'models: ${models.length}, '
        'default: $defaultModel'
        ')';
  }
}
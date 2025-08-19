import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'nvidia_config.dart';

/// Cliente HTTP para comunicação com a API NVIDIA
class NvidiaClient {
  late final Dio _dio;
  
  NvidiaClient() {
    _dio = Dio(BaseOptions(
      baseUrl: NvidiaConfig.baseUrl,
      connectTimeout: Duration(seconds: NvidiaConfig.timeoutSeconds),
      receiveTimeout: Duration(seconds: NvidiaConfig.timeoutSeconds),
      sendTimeout: Duration(seconds: NvidiaConfig.timeoutSeconds), // Timeout para envio
      headers: NvidiaConfig.defaultHeaders,
    ));
    
    // Interceptors para logging e tratamento de erros
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Não logar o corpo por privacidade
        responseBody: false,
        requestHeader: true,
        responseHeader: false,
        logPrint: (obj) => debugPrint('[NVIDIA API] $obj'),
      ));
    }
    
    // Interceptor para retry automático
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 429) {
            // Rate limit - aguardar e tentar novamente
            await Future.delayed(NvidiaConfig.retryDelay);
            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
            } catch (e) {
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
  
  /// Envia uma requisição de chat completion para análise psicanalítica
  Future<NvidiaResponse> sendChatCompletion({
    required String prompt,
    String model = NvidiaConfig.defaultModel,
    double temperature = NvidiaConfig.defaultTemperature,
    int maxTokens = NvidiaConfig.defaultMaxTokens,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      // Validar tamanho do prompt
      if (prompt.length > NvidiaConfig.maxPromptLength) {
        throw NvidiaException(
          'Prompt muito longo. Máximo: ${NvidiaConfig.maxPromptLength} caracteres',
          code: 'PROMPT_TOO_LONG',
        );
      }
      
      final requestData = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
        'top_p': NvidiaConfig.defaultTopP,
        'stream': false,
        ...?additionalParams,
      };
      
      final response = await _dio.post(
        NvidiaConfig.chatCompletionsEndpoint,
        data: requestData,
      );
      
      return NvidiaResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NvidiaException(
        'Erro inesperado: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }
  
  /// Verifica status da API
  Future<bool> checkApiHealth() async {
    try {
      final response = await sendChatCompletion(
        prompt: 'Test',
        model: 'google/gemma-2b-it', // Modelo mais leve para teste
        maxTokens: 10,
      );
      return response.choices.isNotEmpty;
    } catch (e) {
      debugPrint('API Health Check falhou: $e');
      return false;
    }
  }
  
  /// Lista modelos disponíveis (simulado - NVIDIA não tem endpoint público)
  List<ModelInfo> getAvailableModels() {
    return NvidiaConfig.availableModels.values.toList();
  }
  
  /// Calcula custo estimado de uma requisição
  double estimateCost({
    required String prompt,
    required int maxTokens,
    String model = NvidiaConfig.defaultModel,
  }) {
    // Estimativa básica - ajustar conforme pricing real da NVIDIA
    final inputTokens = (prompt.length / 4).ceil(); // ~4 chars per token
    final outputTokens = maxTokens;
    
    // Preços estimados por 1k tokens (ajustar conforme tabela real)
    final inputCostPer1k = model.contains('70b') ? 0.003 : 0.001;
    final outputCostPer1k = model.contains('70b') ? 0.004 : 0.002;
    
    final inputCost = (inputTokens / 1000) * inputCostPer1k;
    final outputCost = (outputTokens / 1000) * outputCostPer1k;
    
    return inputCost + outputCost;
  }
  
  /// Trata exceções do Dio
  NvidiaException _handleDioException(DioException e) {
    debugPrint('[NVIDIA API ERROR] Tipo: ${e.type}, Mensagem: ${e.message}');
    debugPrint('[NVIDIA API ERROR] Status Code: ${e.response?.statusCode}');
    debugPrint('[NVIDIA API ERROR] Response Data: ${e.response?.data}');
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NvidiaException(
          'Tempo limite de conexão esgotado. Verifique sua conexão com a internet.',
          code: 'CONNECTION_TIMEOUT',
        );
      
      case DioExceptionType.sendTimeout:
        return NvidiaException(
          'Tempo limite para envio de dados esgotado. Tente novamente.',
          code: 'SEND_TIMEOUT',
        );
        
      case DioExceptionType.receiveTimeout:
        return NvidiaException(
          'Tempo limite para receber resposta esgotado. A análise pode estar demorando mais que o esperado.',
          code: 'RECEIVE_TIMEOUT',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['error']?['message'] ?? 
                        'Erro HTTP $statusCode';
        
        switch (statusCode) {
          case 401:
            return NvidiaException(
              'Erro de autenticação com a API NVIDIA. Verifique a configuração.',
              code: 'UNAUTHORIZED',
            );
          case 429:
            return NvidiaException(
              'Muitas requisições. Aguarde alguns minutos antes de tentar novamente.',
              code: 'RATE_LIMIT',
            );
          case 500:
            return NvidiaException(
              'Erro interno do servidor NVIDIA. Tente novamente mais tarde.',
              code: 'SERVER_ERROR',
            );
          case 503:
            return NvidiaException(
              'Serviço NVIDIA temporariamente indisponível. Tente novamente em alguns minutos.',
              code: 'SERVICE_UNAVAILABLE',
            );
          default:
            return NvidiaException(
              'Erro na API: $message',
              code: 'HTTP_ERROR',
            );
        }
      
      case DioExceptionType.cancel:
        return NvidiaException(
          'Análise cancelada pelo usuário.',
          code: 'CANCELLED',
        );
      
      case DioExceptionType.connectionError:
        return NvidiaException(
          'Erro de conexão com a internet. Verifique sua conectividade.',
          code: 'CONNECTION_ERROR',
        );
      
      default:
        return NvidiaException(
          'Erro de rede: ${e.message ?? "Erro desconhecido"}',
          code: 'NETWORK_ERROR',
        );
    }
  }
  
  /// Dispose do cliente
  void dispose() {
    _dio.close();
  }
}

/// Resposta da API NVIDIA
class NvidiaResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;
  final Usage? usage;
  
  NvidiaResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });
  
  factory NvidiaResponse.fromJson(Map<String, dynamic> json) {
    return NvidiaResponse(
      id: json['id'] ?? '',
      object: json['object'] ?? '',
      created: json['created'] ?? 0,
      model: json['model'] ?? '',
      choices: (json['choices'] as List?)
          ?.map((e) => Choice.fromJson(e))
          .toList() ?? [],
      usage: json['usage'] != null ? Usage.fromJson(json['usage']) : null,
    );
  }
  
  /// Retorna o texto da primeira resposta
  String get content => choices.isNotEmpty ? choices.first.message.content : '';
}

/// Choice da resposta
class Choice {
  final int index;
  final Message message;
  final String? finishReason;
  
  Choice({
    required this.index,
    required this.message,
    this.finishReason,
  });
  
  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'] ?? 0,
      message: Message.fromJson(json['message'] ?? {}),
      finishReason: json['finish_reason'],
    );
  }
}

/// Mensagem da resposta
class Message {
  final String role;
  final String content;
  
  Message({
    required this.role,
    required this.content,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// Informações de uso de tokens
class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  
  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
  
  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
    );
  }
}

/// Exceção personalizada para erros da NVIDIA API
class NvidiaException implements Exception {
  final String message;
  final String code;
  
  NvidiaException(this.message, {required this.code});
  
  @override
  String toString() => 'NvidiaException($code): $message';
}
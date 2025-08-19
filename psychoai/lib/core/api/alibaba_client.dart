import 'package:dio/dio.dart';
import 'alibaba_config.dart';

/// Cliente HTTP para integração com Alibaba Cloud Model Studio
class AlibabaClient {
  late final Dio _dio;
  
  AlibabaClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AlibabaConfig.baseUrl,
      connectTimeout: Duration(seconds: AlibabaConfig.timeoutSeconds),
      receiveTimeout: Duration(seconds: AlibabaConfig.timeoutSeconds),
      headers: AlibabaConfig.headers,
      validateStatus: (status) => true, // Permitir todos os status codes
    ));
    
    // Adicionar interceptors para logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
      },
    ));
  }
  
  /// Gera texto usando modelo da Alibaba Cloud
  Future<AlibabaResponse> generateText({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    int maxRetries = 3,
  }) async {
    final requestBody = {
      'model': model,
      'input': {
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      },
      'parameters': {
        ...AlibabaConfig.defaultParameters,
        ...?parameters,
      },
    };
    
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        
        final response = await _dio.post(
          '', // URL relativa (base já definida)
          data: requestBody,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${AlibabaConfig.apiKey}',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        
        if (response.statusCode == 200 && response.data != null) {
          return AlibabaResponse.fromJson(response.data);
        } else {
          
          throw AlibabaException(
            _getErrorMessage(response.data, response.statusCode ?? 0),
            statusCode: response.statusCode,
          );
        }
      } on DioException catch (e) {
        
        if (attempt == maxRetries) {
          throw AlibabaException(
            _getDioErrorMessage(e),
            code: e.type.toString(),
            statusCode: e.response?.statusCode,
          );
        }
        
        // Aguardar antes de tentar novamente
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        
        if (attempt == maxRetries) {
          throw AlibabaException('Erro inesperado: $e');
        }
        
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw AlibabaException('Número máximo de tentativas excedido');
  }
  
  /// Lista modelos disponíveis (placeholder - implementar se API suportar)
  Future<List<ModelInfo>> listModels() async {
    // Por enquanto retorna modelos hardcoded da configuração
    return AlibabaConfig.getAllModels();
  }
  
  /// Testa conectividade com a API
  Future<bool> testConnection() async {
    try {
      // Fazer uma requisição simples para testar
      await generateText(
        model: AlibabaConfig.qwenTurbo,
        prompt: 'Test',
        parameters: {
          'max_tokens': 10,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém informações de uso da API (placeholder)
  Future<AlibabaUsageInfo> getUsageInfo() async {
    // Por enquanto retorna dados mockados
    return AlibabaUsageInfo(
      totalTokens: 0,
      totalRequests: 0,
      remainingQuota: double.infinity,
    );
  }
  
  String _getErrorMessage(dynamic responseData, int statusCode) {
    if (responseData is Map<String, dynamic>) {
      // Tentar extrair mensagem de erro específica da API
      if (responseData['error'] is Map) {
        final error = responseData['error'] as Map<String, dynamic>;
        return error['message'] ?? 'Erro desconhecido da API';
      }
      
      if (responseData['message'] is String) {
        return responseData['message'];
      }
    }
    
    // Mensagens padrão baseadas no status code
    switch (statusCode) {
      case 400:
        return 'Requisição inválida - verifique os parâmetros';
      case 401:
        return 'Chave de API inválida ou expirada';
      case 403:
        return 'Acesso negado - verifique permissões';
      case 429:
        return 'Muitas requisições - tente novamente em alguns momentos';
      case 500:
        return 'Erro interno do servidor da Alibaba Cloud';
      case 502:
        return 'Gateway inválido - tente novamente';
      case 503:
        return 'Serviço temporariamente indisponível';
      default:
        return 'Erro da API (Status: $statusCode)';
    }
  }
  
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Timeout de conexão - verifique sua internet';
      case DioExceptionType.sendTimeout:
        return 'Timeout no envio - requisição muito demorada';
      case DioExceptionType.receiveTimeout:
        return 'Timeout na resposta - servidor não respondeu';
      case DioExceptionType.badResponse:
        return 'Resposta inválida do servidor';
      case DioExceptionType.cancel:
        return 'Requisição cancelada';
      case DioExceptionType.connectionError:
        return 'Erro de conexão - verifique sua internet';
      case DioExceptionType.unknown:
      default:
        return 'Erro de rede: ${e.message}';
    }
  }
  
  void dispose() {
    _dio.close();
  }
}

/// Resposta da API da Alibaba Cloud
class AlibabaResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final AlibabaChoice choice;
  final AlibabaUsage usage;
  
  AlibabaResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choice,
    required this.usage,
  });
  
  factory AlibabaResponse.fromJson(Map<String, dynamic> json) {
    try {
      final output = json['output'] as Map<String, dynamic>;
      final usage = json['usage'] as Map<String, dynamic>;
      
      return AlibabaResponse(
        id: json['request_id'] ?? 'unknown',
        object: 'text_completion',
        created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        model: output['model'] ?? 'unknown',
        choice: AlibabaChoice.fromJson(output),
        usage: AlibabaUsage.fromJson(usage),
      );
    } catch (e) {
      throw AlibabaException('Erro ao processar resposta da API: $e');
    }
  }
  
  /// Obtém o texto gerado
  String get text => choice.message?.content ?? '';
  
  /// Verifica se a geração foi concluída com sucesso
  bool get isSuccess => choice.finishReason == 'stop';
}

/// Escolha/resposta específica do modelo
class AlibabaChoice {
  final String? finishReason;
  final AlibabaMessage? message;
  
  AlibabaChoice({
    this.finishReason,
    this.message,
  });
  
  factory AlibabaChoice.fromJson(Map<String, dynamic> json) {
    return AlibabaChoice(
      finishReason: json['finish_reason'],
      message: json['text'] != null 
        ? AlibabaMessage(
            role: 'assistant',
            content: json['text'],
          )
        : null,
    );
  }
}

/// Mensagem do chat
class AlibabaMessage {
  final String role;
  final String content;
  
  AlibabaMessage({
    required this.role,
    required this.content,
  });
  
  factory AlibabaMessage.fromJson(Map<String, dynamic> json) {
    return AlibabaMessage(
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
    );
  }
}

/// Informações de uso de tokens
class AlibabaUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  
  AlibabaUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
  
  factory AlibabaUsage.fromJson(Map<String, dynamic> json) {
    final inputTokens = json['input_tokens'] ?? 0;
    final outputTokens = json['output_tokens'] ?? 0;
    
    return AlibabaUsage(
      promptTokens: inputTokens,
      completionTokens: outputTokens,
      totalTokens: inputTokens + outputTokens,
    );
  }
}

/// Informações de uso da conta
class AlibabaUsageInfo {
  final int totalTokens;
  final int totalRequests;
  final double remainingQuota;
  
  AlibabaUsageInfo({
    required this.totalTokens,
    required this.totalRequests,
    required this.remainingQuota,
  });
}
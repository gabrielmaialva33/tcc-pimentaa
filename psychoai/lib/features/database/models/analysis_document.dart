import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../analysis/prompts/freudian_prompt.dart';
import '../../analysis/models/analysis_result.dart';
import '../../../core/database/mongodb_client.dart';

part 'analysis_document.g.dart';

/// Documento de análise no MongoDB
@JsonSerializable()
class AnalysisDocument {
  @JsonKey(name: '_id', fromJson: _objectIdFromJson, toJson: _objectIdToJson)
  final ObjectId? id;
  
  @JsonKey(fromJson: _objectIdFromJson, toJson: _objectIdToJson)
  final ObjectId? memoryId;
  
  final String userId;
  final String analysisText;
  final List<String> insights;
  final List<String> screenMemoryIndicators;
  final List<String> defenseMechanisms;
  final List<String> therapeuticSuggestions;
  final String modelUsed;
  final String provider;
  final Map<String, dynamic> tokenUsage;
  final String analysisType;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Metadados adicionais
  final double? confidenceScore;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;
  final String? therapistNotes;
  
  // Status
  final bool isDeleted;
  final bool isSynced;
  final String? deviceId;

  AnalysisDocument({
    this.id,
    required this.memoryId,
    required this.userId,
    required this.analysisText,
    required this.insights,
    required this.screenMemoryIndicators,
    required this.defenseMechanisms,
    required this.therapeuticSuggestions,
    required this.modelUsed,
    required this.provider,
    required this.tokenUsage,
    required this.analysisType,
    required this.createdAt,
    required this.updatedAt,
    this.confidenceScore,
    this.metadata,
    this.tags,
    this.therapistNotes,
    this.isDeleted = false,
    this.isSynced = true,
    this.deviceId,
  });

  /// Cria de um AnalysisResult
  factory AnalysisDocument.fromAnalysisResult({
    required AnalysisResult result,
    required String memoryId,
    required String userId,
    String? deviceId,
  }) {
    final now = DateTime.now().toUtc();
    
    return AnalysisDocument(
      memoryId: MongoDBHelper.stringToObjectId(memoryId),
      userId: userId,
      analysisText: result.analysisText,
      insights: result.insights,
      screenMemoryIndicators: result.screenMemoryIndicators,
      defenseMechanisms: result.defenseMechanisms,
      therapeuticSuggestions: result.therapeuticSuggestions,
      modelUsed: result.modelUsed,
      provider: result.modelUsed.split(':').first, // Extrai o provedor
      tokenUsage: result.tokenUsage.toJson(),
      analysisType: result.analysisType.name,
      createdAt: result.timestamp.toUtc(),
      updatedAt: now,
      deviceId: deviceId,
    );
  }

  /// Converte para AnalysisResult
  AnalysisResult toAnalysisResult({
    required String memoryText,
    required List<String> emotions,
    required double emotionalIntensity,
  }) {
    return AnalysisResult(
      id: idString,
      memoryText: memoryText,
      emotions: emotions,
      emotionalIntensity: emotionalIntensity,
      analysisType: AnalysisType.values.firstWhere(
        (type) => type.name == analysisType,
        orElse: () => AnalysisType.complete,
      ),
      analysisText: analysisText,
      insights: insights,
      screenMemoryIndicators: screenMemoryIndicators,
      defenseMechanisms: defenseMechanisms,
      therapeuticSuggestions: therapeuticSuggestions,
      timestamp: createdAt,
      modelUsed: modelUsed,
      tokenUsage: TokenUsage.fromJson(Map<String, dynamic>.from(tokenUsage)),
    );
  }

  /// Fábrica para criar do JSON
  factory AnalysisDocument.fromJson(Map<String, dynamic> json) =>
      _$AnalysisDocumentFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$AnalysisDocumentToJson(this);

  /// Converte para Map do MongoDB
  Map<String, dynamic> toMongo() {
    final json = toJson();
    
    // Converter datas para UTC
    json['createdAt'] = createdAt.toUtc();
    json['updatedAt'] = updatedAt.toUtc();
    
    // Remover campos nulos
    json.removeWhere((key, value) => value == null);
    
    return json;
  }

  /// Cria do Map do MongoDB
  factory AnalysisDocument.fromMongo(Map<String, dynamic> map) {
    // Garantir que as datas sejam DateTime
    if (map['createdAt'] is! DateTime) {
      map['createdAt'] = DateTime.parse(map['createdAt'].toString()).toUtc();
    }
    if (map['updatedAt'] is! DateTime) {
      map['updatedAt'] = DateTime.parse(map['updatedAt'].toString()).toUtc();
    }
    
    return AnalysisDocument.fromJson(map);
  }

  /// Cria uma cópia com novos valores
  AnalysisDocument copyWith({
    ObjectId? id,
    ObjectId? memoryId,
    String? userId,
    String? analysisText,
    List<String>? insights,
    List<String>? screenMemoryIndicators,
    List<String>? defenseMechanisms,
    List<String>? therapeuticSuggestions,
    String? modelUsed,
    String? provider,
    Map<String, dynamic>? tokenUsage,
    String? analysisType,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? confidenceScore,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? therapistNotes,
    bool? isDeleted,
    bool? isSynced,
    String? deviceId,
  }) {
    return AnalysisDocument(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      userId: userId ?? this.userId,
      analysisText: analysisText ?? this.analysisText,
      insights: insights ?? this.insights,
      screenMemoryIndicators: screenMemoryIndicators ?? this.screenMemoryIndicators,
      defenseMechanisms: defenseMechanisms ?? this.defenseMechanisms,
      therapeuticSuggestions: therapeuticSuggestions ?? this.therapeuticSuggestions,
      modelUsed: modelUsed ?? this.modelUsed,
      provider: provider ?? this.provider,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      analysisType: analysisType ?? this.analysisType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      confidenceScore: confidenceScore ?? this.confidenceScore,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      therapistNotes: therapistNotes ?? this.therapistNotes,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// Retorna ID como string
  String get idString => id?.oid ?? '';

  /// Retorna memoryId como string
  String get memoryIdString => memoryId?.oid ?? '';

  /// Verifica se a análise é válida
  bool get isValid {
    return userId.isNotEmpty &&
           analysisText.isNotEmpty &&
           modelUsed.isNotEmpty &&
           provider.isNotEmpty;
  }

  /// Retorna resumo da análise
  String get summary {
    final buffer = StringBuffer();
    
    if (insights.isNotEmpty) {
      buffer.writeln('🔍 ${insights.length} insights identificados');
    }
    
    if (screenMemoryIndicators.isNotEmpty) {
      buffer.writeln('🎭 ${screenMemoryIndicators.length} indicadores de lembrança encobridora');
    }
    
    if (defenseMechanisms.isNotEmpty) {
      buffer.writeln('🛡️ ${defenseMechanisms.length} mecanismos de defesa');
    }
    
    if (therapeuticSuggestions.isNotEmpty) {
      buffer.writeln('💡 ${therapeuticSuggestions.length} sugestões terapêuticas');
    }
    
    return buffer.toString();
  }

  /// Calcula qualidade da análise
  AnalysisQuality get quality {
    int score = 0;
    
    if (insights.length >= 3) score += 2;
    if (screenMemoryIndicators.isNotEmpty) score += 1;
    if (defenseMechanisms.isNotEmpty) score += 1;
    if (therapeuticSuggestions.length >= 2) score += 2;
    if (analysisText.length >= 500) score += 1;
    if (confidenceScore != null && confidenceScore! >= 0.8) score += 1;
    
    if (score >= 7) return AnalysisQuality.excellent;
    if (score >= 5) return AnalysisQuality.good;
    if (score >= 3) return AnalysisQuality.fair;
    return AnalysisQuality.poor;
  }

  /// Custo estimado da análise
  double get estimatedCost {
    final tokenData = tokenUsage;
    final promptTokens = tokenData['promptTokens'] ?? 0;
    final completionTokens = tokenData['completionTokens'] ?? 0;
    
    final inputCost = (promptTokens / 1000) * 0.003;
    final outputCost = (completionTokens / 1000) * 0.004;
    
    return inputCost + outputCost;
  }

  /// Verifica se tem indicadores fortes de lembrança encobridora
  bool get hasStrongScreenMemoryIndicators => screenMemoryIndicators.length >= 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnalysisDocument(id: $idString, memoryId: $memoryIdString, '
           'userId: $userId, provider: $provider, model: $modelUsed, '
           'quality: $quality, createdAt: $createdAt)';
  }

  // Helpers para conversão de ObjectId
  static ObjectId? _objectIdFromJson(dynamic json) {
    if (json == null) return null;
    if (json is ObjectId) return json;
    if (json is String) return ObjectId.fromHexString(json);
    if (json is Map && json.containsKey('\$oid')) {
      return ObjectId.fromHexString(json['\$oid']);
    }
    return null;
  }

  static dynamic _objectIdToJson(ObjectId? objectId) {
    return objectId?.oid;
  }
}

/// Filtros para busca de análises
class AnalysisFilter {
  final String? userId;
  final String? memoryId;
  final String? provider;
  final String? analysisType;
  final DateTime? startDate;
  final DateTime? endDate;
  final AnalysisQuality? minQuality;
  final List<String>? defenseMechanisms;
  final bool? hasScreenMemoryIndicators;
  final bool? isDeleted;

  const AnalysisFilter({
    this.userId,
    this.memoryId,
    this.provider,
    this.analysisType,
    this.startDate,
    this.endDate,
    this.minQuality,
    this.defenseMechanisms,
    this.hasScreenMemoryIndicators,
    this.isDeleted,
  });

  /// Converte para filtro MongoDB
  Map<String, dynamic> toMongoFilter() {
    final filter = <String, dynamic>{};

    if (userId != null) {
      filter['userId'] = userId;
    }

    if (memoryId != null) {
      filter['memoryId'] = MongoDBHelper.stringToObjectId(memoryId!);
    }

    if (provider != null) {
      filter['provider'] = provider;
    }

    if (analysisType != null) {
      filter['analysisType'] = analysisType;
    }

    if (startDate != null || endDate != null) {
      filter['createdAt'] = <String, dynamic>{};
      if (startDate != null) {
        filter['createdAt']['\$gte'] = startDate!.toUtc();
      }
      if (endDate != null) {
        filter['createdAt']['\$lte'] = endDate!.toUtc();
      }
    }

    if (defenseMechanisms != null && defenseMechanisms!.isNotEmpty) {
      filter['defenseMechanisms'] = {'\$in': defenseMechanisms};
    }

    if (hasScreenMemoryIndicators == true) {
      filter['screenMemoryIndicators'] = {'\$ne': []};
    }

    filter['isDeleted'] = isDeleted ?? false;

    return filter;
  }
}
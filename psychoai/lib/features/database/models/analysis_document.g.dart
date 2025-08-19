// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisDocument _$AnalysisDocumentFromJson(Map<String, dynamic> json) =>
    AnalysisDocument(
      id: AnalysisDocument._objectIdFromJson(json['_id']),
      memoryId: AnalysisDocument._objectIdFromJson(json['memoryId']),
      userId: json['userId'] as String,
      analysisText: json['analysisText'] as String,
      insights:
          (json['insights'] as List<dynamic>).map((e) => e as String).toList(),
      screenMemoryIndicators: (json['screenMemoryIndicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      defenseMechanisms: (json['defenseMechanisms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapeuticSuggestions: (json['therapeuticSuggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      modelUsed: json['modelUsed'] as String,
      provider: json['provider'] as String,
      tokenUsage: json['tokenUsage'] as Map<String, dynamic>,
      analysisType: json['analysisType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      therapistNotes: json['therapistNotes'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$AnalysisDocumentToJson(AnalysisDocument instance) =>
    <String, dynamic>{
      '_id': AnalysisDocument._objectIdToJson(instance.id),
      'memoryId': AnalysisDocument._objectIdToJson(instance.memoryId),
      'userId': instance.userId,
      'analysisText': instance.analysisText,
      'insights': instance.insights,
      'screenMemoryIndicators': instance.screenMemoryIndicators,
      'defenseMechanisms': instance.defenseMechanisms,
      'therapeuticSuggestions': instance.therapeuticSuggestions,
      'modelUsed': instance.modelUsed,
      'provider': instance.provider,
      'tokenUsage': instance.tokenUsage,
      'analysisType': instance.analysisType,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'confidenceScore': instance.confidenceScore,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'therapistNotes': instance.therapistNotes,
      'isDeleted': instance.isDeleted,
      'isSynced': instance.isSynced,
      'deviceId': instance.deviceId,
    };

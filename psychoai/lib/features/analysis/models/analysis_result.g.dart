// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    AnalysisResult(
      id: json['id'] as String,
      memoryText: json['memoryText'] as String,
      emotions:
      (json['emotions'] as List<dynamic>).map((e) => e as String).toList(),
      emotionalIntensity: (json['emotionalIntensity'] as num).toDouble(),
      analysisType: $enumDecode(_$AnalysisTypeEnumMap, json['analysisType']),
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
      timestamp: DateTime.parse(json['timestamp'] as String),
      modelUsed: json['modelUsed'] as String,
      tokenUsage:
      TokenUsage.fromJson(json['tokenUsage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoryText': instance.memoryText,
      'emotions': instance.emotions,
      'emotionalIntensity': instance.emotionalIntensity,
      'analysisType': _$AnalysisTypeEnumMap[instance.analysisType]!,
      'analysisText': instance.analysisText,
      'insights': instance.insights,
      'screenMemoryIndicators': instance.screenMemoryIndicators,
      'defenseMechanisms': instance.defenseMechanisms,
      'therapeuticSuggestions': instance.therapeuticSuggestions,
      'timestamp': instance.timestamp.toIso8601String(),
      'modelUsed': instance.modelUsed,
      'tokenUsage': instance.tokenUsage,
    };

const _$AnalysisTypeEnumMap = {
  AnalysisType.complete: 'complete',
  AnalysisType.quickPattern: 'quickPattern',
  AnalysisType.screenMemory: 'screenMemory',
  AnalysisType.defenseMechanisms: 'defenseMechanisms',
  AnalysisType.transference: 'transference',
  AnalysisType.dreamAnalysis: 'dreamAnalysis',
};

TokenUsage _$TokenUsageFromJson(Map<String, dynamic> json) =>
    TokenUsage(
      promptTokens: (json['promptTokens'] as num).toInt(),
      completionTokens: (json['completionTokens'] as num).toInt(),
      totalTokens: (json['totalTokens'] as num).toInt(),
    );

Map<String, dynamic> _$TokenUsageToJson(TokenUsage instance) =>
    <String, dynamic>{
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
      'totalTokens': instance.totalTokens,
    };

PatternAnalysisResult _$PatternAnalysisResultFromJson(
    Map<String, dynamic> json) =>
    PatternAnalysisResult(
      id: json['id'] as String,
      analysesCount: (json['analysesCount'] as num).toInt(),
      patternsText: json['patternsText'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      identifiedPatterns: (json['identifiedPatterns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          const [],
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          const [],
    );

Map<String, dynamic> _$PatternAnalysisResultToJson(
    PatternAnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'analysesCount': instance.analysesCount,
      'patternsText': instance.patternsText,
      'timestamp': instance.timestamp.toIso8601String(),
      'identifiedPatterns': instance.identifiedPatterns,
      'recommendations': instance.recommendations,
    };

AnalysisStatistics _$AnalysisStatisticsFromJson(Map<String, dynamic> json) =>
    AnalysisStatistics(
      totalAnalyses: (json['totalAnalyses'] as num).toInt(),
      emotionFrequency: Map<String, int>.from(json['emotionFrequency'] as Map),
      defenseMechanismFrequency:
      Map<String, int>.from(json['defenseMechanismFrequency'] as Map),
      averageEmotionalIntensity:
      (json['averageEmotionalIntensity'] as num).toDouble(),
      screenMemoryCount: (json['screenMemoryCount'] as num).toInt(),
      firstAnalysis: DateTime.parse(json['firstAnalysis'] as String),
      lastAnalysis: DateTime.parse(json['lastAnalysis'] as String),
    );

Map<String, dynamic> _$AnalysisStatisticsToJson(AnalysisStatistics instance) =>
    <String, dynamic>{
      'totalAnalyses': instance.totalAnalyses,
      'emotionFrequency': instance.emotionFrequency,
      'defenseMechanismFrequency': instance.defenseMechanismFrequency,
      'averageEmotionalIntensity': instance.averageEmotionalIntensity,
      'screenMemoryCount': instance.screenMemoryCount,
      'firstAnalysis': instance.firstAnalysis.toIso8601String(),
      'lastAnalysis': instance.lastAnalysis.toIso8601String(),
    };

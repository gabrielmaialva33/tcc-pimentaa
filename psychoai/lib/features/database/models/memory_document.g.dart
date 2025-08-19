// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemoryDocument _$MemoryDocumentFromJson(Map<String, dynamic> json) =>
    MemoryDocument(
      id: MemoryDocument._objectIdFromJson(json['_id']),
      userId: json['userId'] as String,
      memoryText: json['memoryText'] as String,
      emotions:
          (json['emotions'] as List<dynamic>).map((e) => e as String).toList(),
      emotionalIntensity: (json['emotionalIntensity'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      location: json['location'] as String?,
      mood: json['mood'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$MemoryDocumentToJson(MemoryDocument instance) =>
    <String, dynamic>{
      '_id': MemoryDocument._objectIdToJson(instance.id),
      'userId': instance.userId,
      'memoryText': instance.memoryText,
      'emotions': instance.emotions,
      'emotionalIntensity': instance.emotionalIntensity,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'location': instance.location,
      'mood': instance.mood,
      'metadata': instance.metadata,
      'isDeleted': instance.isDeleted,
      'isSynced': instance.isSynced,
      'deviceId': instance.deviceId,
    };

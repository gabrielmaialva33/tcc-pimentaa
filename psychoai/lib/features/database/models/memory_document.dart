import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../core/database/mongodb_client.dart';

part 'memory_document.g.dart';

/// Documento de memória no MongoDB
@JsonSerializable()
class MemoryDocument {
  @JsonKey(name: '_id', fromJson: _objectIdFromJson, toJson: _objectIdToJson)
  final ObjectId? id;
  
  final String userId;
  final String memoryText;
  final List<String> emotions;
  final double emotionalIntensity;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Metadados opcionais
  final List<String>? tags;
  final String? location;
  final String? mood;
  final Map<String, dynamic>? metadata;
  
  // Status do documento
  final bool isDeleted;
  final bool isSynced;
  final String? deviceId;

  MemoryDocument({
    this.id,
    required this.userId,
    required this.memoryText,
    required this.emotions,
    required this.emotionalIntensity,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
    this.location,
    this.mood,
    this.metadata,
    this.isDeleted = false,
    this.isSynced = true,
    this.deviceId,
  });

  /// Cria uma nova memória
  factory MemoryDocument.create({
    required String userId,
    required String memoryText,
    required List<String> emotions,
    required double emotionalIntensity,
    List<String>? tags,
    String? location,
    String? mood,
    Map<String, dynamic>? metadata,
    String? deviceId,
  }) {
    final now = DateTime.now().toUtc();
    
    return MemoryDocument(
      userId: userId,
      memoryText: memoryText,
      emotions: emotions,
      emotionalIntensity: emotionalIntensity,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      location: location,
      mood: mood,
      metadata: metadata,
      deviceId: deviceId,
    );
  }

  /// Fábrica para criar do JSON
  factory MemoryDocument.fromJson(Map<String, dynamic> json) =>
      _$MemoryDocumentFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$MemoryDocumentToJson(this);

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
  factory MemoryDocument.fromMongo(Map<String, dynamic> map) {
    // Garantir que as datas sejam DateTime
    if (map['createdAt'] is! DateTime) {
      map['createdAt'] = DateTime.parse(map['createdAt'].toString()).toUtc();
    }
    if (map['updatedAt'] is! DateTime) {
      map['updatedAt'] = DateTime.parse(map['updatedAt'].toString()).toUtc();
    }
    
    return MemoryDocument.fromJson(map);
  }

  /// Cria uma cópia com novos valores
  MemoryDocument copyWith({
    ObjectId? id,
    String? userId,
    String? memoryText,
    List<String>? emotions,
    double? emotionalIntensity,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? location,
    String? mood,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    bool? isSynced,
    String? deviceId,
  }) {
    return MemoryDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memoryText: memoryText ?? this.memoryText,
      emotions: emotions ?? this.emotions,
      emotionalIntensity: emotionalIntensity ?? this.emotionalIntensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      tags: tags ?? this.tags,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// Retorna ID como string
  String get idString => id?.oid ?? '';

  /// Verifica se a memória é válida
  bool get isValid {
    return userId.isNotEmpty &&
           memoryText.isNotEmpty &&
           emotions.isNotEmpty &&
           emotionalIntensity >= 0.0 &&
           emotionalIntensity <= 1.0;
  }

  /// Retorna resumo da memória
  String get summary {
    final preview = memoryText.length > 100 
        ? '${memoryText.substring(0, 100)}...'
        : memoryText;
    
    return preview;
  }

  /// Retorna as emoções como string
  String get emotionsText => emotions.join(', ');

  /// Verifica se contém texto específico
  bool containsText(String query) {
    final lowerQuery = query.toLowerCase();
    return memoryText.toLowerCase().contains(lowerQuery) ||
           emotions.any((emotion) => emotion.toLowerCase().contains(lowerQuery)) ||
           (tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false);
  }

  /// Calcula similaridade com outra memória
  double similarityWith(MemoryDocument other) {
    double score = 0.0;
    
    // Similaridade de emoções
    final commonEmotions = emotions.toSet().intersection(other.emotions.toSet());
    final emotionSimilarity = commonEmotions.length / 
        (emotions.length + other.emotions.length - commonEmotions.length);
    score += emotionSimilarity * 0.4;
    
    // Similaridade de intensidade emocional
    final intensityDiff = (emotionalIntensity - other.emotionalIntensity).abs();
    final intensitySimilarity = 1.0 - intensityDiff;
    score += intensitySimilarity * 0.3;
    
    // Similaridade de texto (simples - contagem de palavras comuns)
    final words1 = memoryText.toLowerCase().split(' ').toSet();
    final words2 = other.memoryText.toLowerCase().split(' ').toSet();
    final commonWords = words1.intersection(words2);
    final textSimilarity = commonWords.length / 
        (words1.length + words2.length - commonWords.length);
    score += textSimilarity * 0.3;
    
    return score.clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MemoryDocument(id: ${idString}, userId: $userId, emotions: $emotions, '
           'intensity: $emotionalIntensity, createdAt: $createdAt)';
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

/// Filtros para busca de memórias
class MemoryFilter {
  final String? userId;
  final List<String>? emotions;
  final double? minIntensity;
  final double? maxIntensity;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? textQuery;
  final List<String>? tags;
  final bool? isDeleted;

  const MemoryFilter({
    this.userId,
    this.emotions,
    this.minIntensity,
    this.maxIntensity,
    this.startDate,
    this.endDate,
    this.textQuery,
    this.tags,
    this.isDeleted,
  });

  /// Converte para filtro MongoDB
  Map<String, dynamic> toMongoFilter() {
    final filter = <String, dynamic>{};

    if (userId != null) {
      filter['userId'] = userId;
    }

    if (emotions != null && emotions!.isNotEmpty) {
      filter['emotions'] = {'\$in': emotions};
    }

    if (minIntensity != null || maxIntensity != null) {
      filter['emotionalIntensity'] = <String, dynamic>{};
      if (minIntensity != null) {
        filter['emotionalIntensity']['\$gte'] = minIntensity;
      }
      if (maxIntensity != null) {
        filter['emotionalIntensity']['\$lte'] = maxIntensity;
      }
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

    if (textQuery != null && textQuery!.isNotEmpty) {
      filter['\$or'] = [
        {'memoryText': {'\$regex': textQuery, '\$options': 'i'}},
        {'emotions': {'\$regex': textQuery, '\$options': 'i'}},
        {'tags': {'\$regex': textQuery, '\$options': 'i'}},
      ];
    }

    if (tags != null && tags!.isNotEmpty) {
      filter['tags'] = {'\$in': tags};
    }

    filter['isDeleted'] = isDeleted ?? false;

    return filter;
  }
}
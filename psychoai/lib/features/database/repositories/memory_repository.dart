import 'package:mongo_dart/mongo_dart.dart';
import '../../../core/database/mongodb_client.dart';
import '../../../core/database/mongodb_config.dart';
import '../models/memory_document.dart';

/// Repositório para operações CRUD de memórias no MongoDB
class MemoryRepository {
  static MemoryRepository? _instance;
  static MemoryRepository get instance => _instance ??= MemoryRepository._();
  
  MemoryRepository._();
  
  final MongoDBClient _client = MongoDBClient.instance;
  
  /// Obtém a coleção de memórias
  DbCollection get _collection => _client.getCollection(MongoDBConfig.memoriesCollection);
  
  /// Cria uma nova memória
  Future<MemoryDocument> create(MemoryDocument memory) async {
    return await _client.executeWithRetry(() async {
      
      if (!memory.isValid) {
        throw MongoDBException('Dados da memória são inválidos');
      }
      
      final data = memory.toMongo();
      final result = await _collection.insertOne(data);
      
      if (result.isSuccess && result.document?['_id'] != null) {
        final createdMemory = memory.copyWith(id: result.document?['_id']);
        return createdMemory;
      } else {
        throw MongoDBException('Falha ao criar memória: ${result.writeError?.errmsg}');
      }
    });
  }
  
  /// Busca memória por ID
  Future<MemoryDocument?> findById(String id) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final memory = MemoryDocument.fromMongo(result);
        return memory;
      } else {
        return null;
      }
    });
  }
  
  /// Busca memórias por usuário com filtros opcionais
  Future<List<MemoryDocument>> findByUser(
    String userId, {
    MemoryFilter? filter,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? sort,
  }) async {
    return await _client.executeWithRetry(() async {
      
      // Combinar filtro de usuário com filtros adicionais
      final mongoFilter = (filter ?? MemoryFilter(userId: userId)).toMongoFilter();
      if (filter?.userId == null) {
        mongoFilter['userId'] = userId;
      }
      
      // Configurar paginação e ordenação
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: sort ?? {'createdAt': -1}, // Mais recentes primeiro
      );
      
      // Use aggregation pipeline for sorting, skipping, and limiting
      final pipeline = <Map<String, dynamic>>[
        {'\$match': mongoFilter}
      ];
      
      if (options['sort'] != null) {
        pipeline.add({'\$sort': options['sort']});
      }
      
      if (options['skip'] != null) {
        pipeline.add({'\$skip': options['skip']});
      }
      
      if (options['limit'] != null) {
        pipeline.add({'\$limit': options['limit']});
      }
      
      final results = await _collection.aggregateToStream(pipeline.cast<Map<String, Object>>()).toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      return memories;
    });
  }
  
  /// Conta memórias do usuário
  Future<int> countByUser(String userId, {MemoryFilter? filter}) async {
    return await _client.executeWithRetry(() async {
      final mongoFilter = (filter ?? MemoryFilter(userId: userId)).toMongoFilter();
      if (filter?.userId == null) {
        mongoFilter['userId'] = userId;
      }
      
      final count = await _collection.count(mongoFilter);
      return count;
    });
  }
  
  /// Busca memórias por texto
  Future<List<MemoryDocument>> searchByText(
    String userId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'isDeleted': false,
        '\$or': [
          {'memoryText': {'\$regex': query, '\$options': 'i'}},
          {'emotions': {'\$regex': query, '\$options': 'i'}},
          {'tags': {'\$regex': query, '\$options': 'i'}},
        ],
      };
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      return memories;
    });
  }
  
  /// Busca memórias por emoção
  Future<List<MemoryDocument>> findByEmotion(
    String userId,
    String emotion, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'emotions': emotion,
        'isDeleted': false,
      };
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      return memories;
    });
  }
  
  /// Busca memórias recentes
  Future<List<MemoryDocument>> findRecent(
    String userId, {
    int limit = 10,
    Duration? within,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'isDeleted': false,
      };
      
      // Adicionar filtro de data se especificado
      if (within != null) {
        final cutoffDate = DateTime.now().toUtc().subtract(within);
        filter['createdAt'] = {'\$gte': cutoffDate};
      }
      
      final results = await _collection.find(filter).toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      return memories;
    });
  }
  
  /// Atualiza uma memória
  Future<MemoryDocument?> update(String id, MemoryDocument memory) async {
    return await _client.executeWithRetry(() async {
      
      if (!memory.isValid) {
        throw MongoDBException('Dados da memória são inválidos');
      }
      
      final filter = MongoDBHelper.idFilter(id);
      final update = {
        '\$set': {
          ...memory.toMongo(),
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.findAndModify(
        query: filter,
        update: update,
        returnNew: true,
      );
      
      if (result != null) {
        final updatedMemory = MemoryDocument.fromMongo(result);
        return updatedMemory;
      } else {
        return null;
      }
    });
  }
  
  /// Marca memória como deletada (soft delete)
  Future<bool> delete(String id) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final update = {
        '\$set': {
          'isDeleted': true,
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
      } else {
      }
      
      return success;
    });
  }
  
  /// Remove permanentemente uma memória (hard delete)
  Future<bool> permanentDelete(String id) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.deleteOne(filter);
      final success = result.isSuccess && result.nRemoved > 0;
      
      if (success) {
      } else {
      }
      
      return success;
    });
  }
  
  /// Restaura uma memória deletada
  Future<bool> restore(String id) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final update = {
        '\$set': {
          'isDeleted': false,
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
      } else {
      }
      
      return success;
    });
  }
  
  /// Obtém estatísticas de memórias do usuário
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await _client.executeWithRetry(() async {
      
      final pipeline = [
        {'\$match': {'userId': userId, 'isDeleted': false}},
        {
          '\$group': {
            '_id': null,
            'totalMemories': {'\$sum': 1},
            'avgIntensity': {'\$avg': '\$emotionalIntensity'},
            'firstMemory': {'\$min': '\$createdAt'},
            'lastMemory': {'\$max': '\$createdAt'},
            'emotions': {'\$push': '\$emotions'},
          }
        },
        {
          '\$project': {
            '_id': 0,
            'totalMemories': 1,
            'avgIntensity': {'\$round': ['\$avgIntensity', 2]},
            'firstMemory': 1,
            'lastMemory': 1,
            'allEmotions': {
              '\$reduce': {
                'input': '\$emotions',
                'initialValue': [],
                'in': {'\$setUnion': ['\$\$value', '\$\$this']}
              }
            }
          }
        }
      ];
      
      final results = await _collection.aggregateToStream(pipeline.cast<Map<String, Object>>()).toList();
      
      if (results.isNotEmpty) {
        final stats = results.first;
        return stats;
      } else {
        return {
          'totalMemories': 0,
          'avgIntensity': 0.0,
          'firstMemory': null,
          'lastMemory': null,
          'allEmotions': [],
        };
      }
    });
  }
  
  /// Busca memórias similares baseadas em emoções e intensidade
  Future<List<MemoryDocument>> findSimilar(
    MemoryDocument memory, {
    int limit = 5,
    double emotionThreshold = 0.3,
    double intensityThreshold = 0.2,
  }) async {
    return await _client.executeWithRetry(() async {
      
      // Buscar memórias com emoções em comum
      final filter = {
        'userId': memory.userId,
        '_id': {'\$ne': memory.id},
        'isDeleted': false,
        'emotions': {'\$in': memory.emotions},
        'emotionalIntensity': {
          '\$gte': memory.emotionalIntensity - intensityThreshold,
          '\$lte': memory.emotionalIntensity + intensityThreshold,
        },
      };
      
      final cursor = _collection.find(filter, FindOptions(
        limit: limit * 2, // Buscar mais para filtrar
        sort: {'createdAt': -1},
      ));
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      // Calcular similaridade e ordenar
      final similarities = memories.map((m) => {
        'memory': m,
        'similarity': m.similarityWith(memory),
      }).toList();
      
      similarities.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));
      
      final similarMemories = similarities
          .where((item) => (item['similarity'] as double) >= emotionThreshold)
          .take(limit)
          .map((item) => item['memory'] as MemoryDocument)
          .toList();
      
      return similarMemories;
    });
  }
  
  /// Executa limpeza de memórias antigas deletadas
  Future<int> cleanupDeletedMemories({
    Duration olderThan = const Duration(days: 30),
  }) async {
    return await _client.executeWithRetry(() async {
      
      final cutoffDate = DateTime.now().toUtc().subtract(olderThan);
      final filter = {
        'isDeleted': true,
        'updatedAt': {'\$lt': cutoffDate},
      };
      
      final result = await _collection.deleteMany(filter);
      final deletedCount = result.nRemoved;
      
      return deletedCount;
    });
  }
}
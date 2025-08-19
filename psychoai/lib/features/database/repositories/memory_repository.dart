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
      print('💾 [MEMORY_REPO] Criando nova memória para usuário: ${memory.userId}');
      
      if (!memory.isValid) {
        throw MongoDBException('Dados da memória são inválidos');
      }
      
      final data = memory.toMongo();
      final result = await _collection.insertOne(data);
      
      if (result.isSuccess && result.insertedId != null) {
        final createdMemory = memory.copyWith(id: result.insertedId);
        print('✅ [MEMORY_REPO] Memória criada com ID: ${createdMemory.idString}');
        return createdMemory;
      } else {
        throw MongoDBException('Falha ao criar memória: ${result.writeError?.errmsg}');
      }
    });
  }
  
  /// Busca memória por ID
  Future<MemoryDocument?> findById(String id) async {
    return await _client.executeWithRetry(() async {
      print('🔍 [MEMORY_REPO] Buscando memória por ID: $id');
      
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final memory = MemoryDocument.fromMongo(result);
        print('✅ [MEMORY_REPO] Memória encontrada: ${memory.idString}');
        return memory;
      } else {
        print('❌ [MEMORY_REPO] Memória não encontrada: $id');
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
      print('🔍 [MEMORY_REPO] Buscando memórias do usuário: $userId (página $page)');
      
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
      
      final cursor = _collection.find(
        mongoFilter,
        skip: options['skip'],
        limit: options['limit'],
      );
      
      if (options['sort'] != null) {
        cursor.sortBy(options['sort']);
      }
      
      final results = await cursor.toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      print('✅ [MEMORY_REPO] Encontradas ${memories.length} memórias');
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
      print('📊 [MEMORY_REPO] Usuário $userId tem $count memórias');
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
      print('🔍 [MEMORY_REPO] Buscando memórias com texto: "$query"');
      
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
      
      final cursor = _collection.find(
        filter,
        skip: options['skip'],
        limit: options['limit'],
      ).sortBy({'createdAt': -1});
      
      final results = await cursor.toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      print('✅ [MEMORY_REPO] Encontradas ${memories.length} memórias com "$query"');
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
      print('🔍 [MEMORY_REPO] Buscando memórias com emoção: $emotion');
      
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
      
      final cursor = _collection.find(
        filter,
        skip: options['skip'],
        limit: options['limit'],
      ).sortBy({'createdAt': -1});
      
      final results = await cursor.toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      print('✅ [MEMORY_REPO] Encontradas ${memories.length} memórias com emoção "$emotion"');
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
      print('🔍 [MEMORY_REPO] Buscando memórias recentes do usuário: $userId');
      
      final filter = {
        'userId': userId,
        'isDeleted': false,
      };
      
      // Adicionar filtro de data se especificado
      if (within != null) {
        final cutoffDate = DateTime.now().toUtc().subtract(within);
        filter['createdAt'] = {'\$gte': cutoffDate};
      }
      
      final cursor = _collection.find(filter, limit: limit)
          .sortBy({'createdAt': -1});
      
      final results = await cursor.toList();
      final memories = results.map((doc) => MemoryDocument.fromMongo(doc)).toList();
      
      print('✅ [MEMORY_REPO] Encontradas ${memories.length} memórias recentes');
      return memories;
    });
  }
  
  /// Atualiza uma memória
  Future<MemoryDocument?> update(String id, MemoryDocument memory) async {
    return await _client.executeWithRetry(() async {
      print('🔄 [MEMORY_REPO] Atualizando memória: $id');
      
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
        print('✅ [MEMORY_REPO] Memória atualizada: ${updatedMemory.idString}');
        return updatedMemory;
      } else {
        print('❌ [MEMORY_REPO] Memória não encontrada para atualizar: $id');
        return null;
      }
    });
  }
  
  /// Marca memória como deletada (soft delete)
  Future<bool> delete(String id) async {
    return await _client.executeWithRetry(() async {
      print('🗑️ [MEMORY_REPO] Deletando memória: $id');
      
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
        print('✅ [MEMORY_REPO] Memória deletada: $id');
      } else {
        print('❌ [MEMORY_REPO] Falha ao deletar memória: $id');
      }
      
      return success;
    });
  }
  
  /// Remove permanentemente uma memória (hard delete)
  Future<bool> permanentDelete(String id) async {
    return await _client.executeWithRetry(() async {
      print('🗑️ [MEMORY_REPO] Removendo permanentemente memória: $id');
      
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.deleteOne(filter);
      final success = result.isSuccess && result.nRemoved > 0;
      
      if (success) {
        print('✅ [MEMORY_REPO] Memória removida permanentemente: $id');
      } else {
        print('❌ [MEMORY_REPO] Falha ao remover memória: $id');
      }
      
      return success;
    });
  }
  
  /// Restaura uma memória deletada
  Future<bool> restore(String id) async {
    return await _client.executeWithRetry(() async {
      print('♻️ [MEMORY_REPO] Restaurando memória: $id');
      
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
        print('✅ [MEMORY_REPO] Memória restaurada: $id');
      } else {
        print('❌ [MEMORY_REPO] Falha ao restaurar memória: $id');
      }
      
      return success;
    });
  }
  
  /// Obtém estatísticas de memórias do usuário
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await _client.executeWithRetry(() async {
      print('📊 [MEMORY_REPO] Obtendo estatísticas do usuário: $userId');
      
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
      
      final results = await _collection.aggregateToStream(pipeline).toList();
      
      if (results.isNotEmpty) {
        final stats = results.first;
        print('✅ [MEMORY_REPO] Estatísticas obtidas para usuário: $userId');
        return stats;
      } else {
        print('❌ [MEMORY_REPO] Nenhuma estatística encontrada para usuário: $userId');
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
      print('🔍 [MEMORY_REPO] Buscando memórias similares');
      
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
      
      final cursor = _collection.find(filter, limit: limit * 2) // Buscar mais para filtrar
          .sortBy({'createdAt': -1});
      
      final results = await cursor.toList();
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
      
      print('✅ [MEMORY_REPO] Encontradas ${similarMemories.length} memórias similares');
      return similarMemories;
    });
  }
  
  /// Executa limpeza de memórias antigas deletadas
  Future<int> cleanupDeletedMemories({
    Duration olderThan = const Duration(days: 30),
  }) async {
    return await _client.executeWithRetry(() async {
      print('🧹 [MEMORY_REPO] Limpando memórias deletadas antigas...');
      
      final cutoffDate = DateTime.now().toUtc().subtract(olderThan);
      final filter = {
        'isDeleted': true,
        'updatedAt': {'\$lt': cutoffDate},
      };
      
      final result = await _collection.deleteMany(filter);
      final deletedCount = result.nRemoved;
      
      print('✅ [MEMORY_REPO] Removidas $deletedCount memórias antigas');
      return deletedCount;
    });
  }
}
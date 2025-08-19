import 'package:mongo_dart/mongo_dart.dart';
import '../../../core/database/mongodb_client.dart';
import '../../../core/database/mongodb_config.dart';
import '../models/analysis_document.dart';
import '../../analysis/models/analysis_result.dart';

/// Repositório para operações CRUD de análises no MongoDB
class AnalysisRepository {
  static AnalysisRepository? _instance;
  static AnalysisRepository get instance => _instance ??= AnalysisRepository._();
  
  AnalysisRepository._();
  
  final MongoDBClient _client = MongoDBClient.instance;
  
  /// Obtém a coleção de análises
  DbCollection get _collection => _client.getCollection(MongoDBConfig.analysesCollection);
  
  /// Cria uma nova análise
  Future<AnalysisDocument> create(AnalysisDocument analysis) async {
    return await _client.executeWithRetry(() async {
      
      if (!analysis.isValid) {
        throw MongoDBException('Dados da análise são inválidos');
      }
      
      final data = analysis.toMongo();
      final result = await _collection.insertOne(data);
      
      if (result.isSuccess && result.document['_id'] != null) {
        final createdAnalysis = analysis.copyWith(id: result.document['_id']);
        return createdAnalysis;
      } else {
        throw MongoDBException('Falha ao criar análise: ${result.writeError?.errmsg}');
      }
    });
  }
  
  /// Cria análise a partir de AnalysisResult
  Future<AnalysisDocument> createFromResult({
    required AnalysisResult result,
    required String memoryId,
    required String userId,
    String? deviceId,
  }) async {
    
    final document = AnalysisDocument.fromAnalysisResult(
      result: result,
      memoryId: memoryId,
      userId: userId,
      deviceId: deviceId,
    );
    
    return await create(document);
  }
  
  /// Busca análise por ID
  Future<AnalysisDocument?> findById(String id) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final analysis = AnalysisDocument.fromMongo(result);
        return analysis;
      } else {
        return null;
      }
    });
  }
  
  /// Busca análise por memória
  Future<AnalysisDocument?> findByMemoryId(String memoryId) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'memoryId': MongoDBHelper.stringToObjectId(memoryId),
        'isDeleted': false,
      };
      
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final analysis = AnalysisDocument.fromMongo(result);
        return analysis;
      } else {
        return null;
      }
    });
  }
  
  /// Busca análises por usuário com filtros opcionais
  Future<List<AnalysisDocument>> findByUser(
    String userId, {
    AnalysisFilter? filter,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? sort,
  }) async {
    return await _client.executeWithRetry(() async {
      
      // Combinar filtro de usuário com filtros adicionais
      final mongoFilter = (filter ?? AnalysisFilter(userId: userId)).toMongoFilter();
      if (filter?.userId == null) {
        mongoFilter['userId'] = userId;
      }
      
      // Configurar paginação e ordenação
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: sort ?? {'createdAt': -1}, // Mais recentes primeiro
      );
      
      final cursor = _collection.find(mongoFilter);
      
      if (options['sort'] != null) {
        cursor.sort(options['sort']);
      }
      
      cursor.skip(options['skip']).limit(options['limit']);
      final analyses = results.map((doc) => AnalysisDocument.fromMongo(doc)).toList();
      
      return analyses;
    });
  }
  
  /// Busca análises por provedor
  Future<List<AnalysisDocument>> findByProvider(
    String userId,
    String provider, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'provider': provider,
        'isDeleted': false,
      };
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final analyses = results.map((doc) => AnalysisDocument.fromMongo(doc)).toList();
      
      return analyses;
    });
  }
  
  /// Busca análises com lembranças encobridoras
  Future<List<AnalysisDocument>> findWithScreenMemories(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'screenMemoryIndicators': {'\$ne': [], '\$exists': true},
        'isDeleted': false,
      };
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final analyses = results.map((doc) => AnalysisDocument.fromMongo(doc)).toList();
      
      return analyses;
    });
  }
  
  /// Busca análises por mecanismo de defesa
  Future<List<AnalysisDocument>> findByDefenseMechanism(
    String userId,
    String mechanism, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.executeWithRetry(() async {
      
      final filter = {
        'userId': userId,
        'defenseMechanisms': mechanism,
        'isDeleted': false,
      };
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final analyses = results.map((doc) => AnalysisDocument.fromMongo(doc)).toList();
      
      return analyses;
    });
  }
  
  /// Busca análises recentes
  Future<List<AnalysisDocument>> findRecent(
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
      final analyses = results.map((doc) => AnalysisDocument.fromMongo(doc)).toList();
      
      return analyses;
    });
  }
  
  /// Conta análises do usuário
  Future<int> countByUser(String userId, {AnalysisFilter? filter}) async {
    return await _client.executeWithRetry(() async {
      final mongoFilter = (filter ?? AnalysisFilter(userId: userId)).toMongoFilter();
      if (filter?.userId == null) {
        mongoFilter['userId'] = userId;
      }
      
      final count = await _collection.count(mongoFilter);
      return count;
    });
  }
  
  /// Atualiza uma análise
  Future<AnalysisDocument?> update(String id, AnalysisDocument analysis) async {
    return await _client.executeWithRetry(() async {
      
      if (!analysis.isValid) {
        throw MongoDBException('Dados da análise são inválidos');
      }
      
      final filter = MongoDBHelper.idFilter(id);
      final update = {
        '\$set': {
          ...analysis.toMongo(),
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.findAndModify(
        query: filter,
        update: update,
        returnNew: true,
      );
      
      if (result != null) {
        final updatedAnalysis = AnalysisDocument.fromMongo(result);
        return updatedAnalysis;
      } else {
        return null;
      }
    });
  }
  
  /// Adiciona nota do terapeuta
  Future<bool> addTherapistNote(String id, String note) async {
    return await _client.executeWithRetry(() async {
      
      final filter = MongoDBHelper.idFilter(id);
      final update = {
        '\$set': {
          'therapistNotes': note,
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
  
  /// Marca análise como deletada (soft delete)
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
  
  /// Obtém estatísticas de análises do usuário
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await _client.executeWithRetry(() async {
      
      final pipeline = [
        {'\$match': {'userId': userId, 'isDeleted': false}},
        {
          '\$group': {
            '_id': null,
            'totalAnalyses': {'\$sum': 1},
            'totalTokens': {'\$sum': '\$tokenUsage.totalTokens'},
            'avgTokens': {'\$avg': '\$tokenUsage.totalTokens'},
            'providers': {'\$addToSet': '\$provider'},
            'models': {'\$addToSet': '\$modelUsed'},
            'firstAnalysis': {'\$min': '\$createdAt'},
            'lastAnalysis': {'\$max': '\$createdAt'},
            'screenMemoryCount': {
              '\$sum': {
                '\$cond': [
                  {'\$gt': [{'\$size': '\$screenMemoryIndicators'}, 0]},
                  1,
                  0
                ]
              }
            },
            'defenseMechanisms': {'\$push': '\$defenseMechanisms'},
          }
        },
        {
          '\$project': {
            '_id': 0,
            'totalAnalyses': 1,
            'totalTokens': 1,
            'avgTokens': {'\$round': ['\$avgTokens', 0]},
            'providers': 1,
            'models': 1,
            'firstAnalysis': 1,
            'lastAnalysis': 1,
            'screenMemoryCount': 1,
            'screenMemoryPercentage': {
              '\$round': [
                {'\$multiply': [
                  {'\$divide': ['\$screenMemoryCount', '\$totalAnalyses']},
                  100
                ]},
                1
              ]
            },
            'allDefenseMechanisms': {
              '\$reduce': {
                'input': '\$defenseMechanisms',
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
        return stats;
      } else {
        return {
          'totalAnalyses': 0,
          'totalTokens': 0,
          'avgTokens': 0,
          'providers': [],
          'models': [],
          'firstAnalysis': null,
          'lastAnalysis': null,
          'screenMemoryCount': 0,
          'screenMemoryPercentage': 0.0,
          'allDefenseMechanisms': [],
        };
      }
    });
  }
  
  /// Obtém estatísticas por provedor
  Future<Map<String, dynamic>> getProviderStats(String userId) async {
    return await _client.executeWithRetry(() async {
      
      final pipeline = [
        {'\$match': {'userId': userId, 'isDeleted': false}},
        {
          '\$group': {
            '_id': '\$provider',
            'count': {'\$sum': 1},
            'totalTokens': {'\$sum': '\$tokenUsage.totalTokens'},
            'avgTokens': {'\$avg': '\$tokenUsage.totalTokens'},
            'models': {'\$addToSet': '\$modelUsed'},
            'lastUsed': {'\$max': '\$createdAt'},
          }
        },
        {
          '\$project': {
            'provider': '\$_id',
            '_id': 0,
            'count': 1,
            'totalTokens': 1,
            'avgTokens': {'\$round': ['\$avgTokens', 0]},
            'models': 1,
            'lastUsed': 1,
          }
        },
        {'\$sort': {'count': -1}}
      ];
      
      final results = await _collection.aggregateToStream(pipeline).toList();
      
      return {
        'providers': results,
        'totalProviders': results.length,
      };
    });
  }
  
  /// Busca padrões de uso temporal
  Future<List<Map<String, dynamic>>> getUsagePatterns(
    String userId, {
    Duration period = const Duration(days: 30),
  }) async {
    return await _client.executeWithRetry(() async {
      
      final startDate = DateTime.now().toUtc().subtract(period);
      
      final pipeline = [
        {
          '\$match': {
            'userId': userId,
            'isDeleted': false,
            'createdAt': {'\$gte': startDate},
          }
        },
        {
          '\$group': {
            '_id': {
              'year': {'\$year': '\$createdAt'},
              'month': {'\$month': '\$createdAt'},
              'day': {'\$dayOfMonth': '\$createdAt'},
            },
            'count': {'\$sum': 1},
            'tokens': {'\$sum': '\$tokenUsage.totalTokens'},
            'providers': {'\$addToSet': '\$provider'},
          }
        },
        {
          '\$project': {
            'date': {
              '\$dateFromParts': {
                'year': '\$_id.year',
                'month': '\$_id.month',
                'day': '\$_id.day',
              }
            },
            '_id': 0,
            'count': 1,
            'tokens': 1,
            'providersCount': {'\$size': '\$providers'},
          }
        },
        {'\$sort': {'date': 1}}
      ];
      
      final results = await _collection.aggregateToStream(pipeline).toList();
      
      return results;
    });
  }
  
  /// Executa limpeza de análises antigas deletadas
  Future<int> cleanupDeletedAnalyses({
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
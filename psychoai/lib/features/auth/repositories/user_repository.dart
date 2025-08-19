import 'package:mongo_dart/mongo_dart.dart';
import '../../../core/database/mongodb_client.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

/// Repositório para operações CRUD de usuários no MongoDB
class UserRepository {
  static UserRepository? _instance;
  static UserRepository get instance => _instance ??= UserRepository._();
  
  UserRepository._();
  
  final MongoDBClient _client = MongoDBClient.instance;
  
  /// Nome da coleção de usuários
  static const String collectionName = 'users';
  
  /// Obtém a coleção de usuários
  DbCollection get _collection => _client.getCollection(collectionName);
  
  /// Cria um novo usuário
  Future<UserProfile> create(UserProfile user) async {
    return await _client.executeWithRetry(() async {
      if (!user.isValid) {
        throw MongoDBException('Dados do usuário são inválidos');
      }
      
      // Verificar se o email já existe
      final existingUser = await findByEmail(user.email);
      if (existingUser != null) {
        throw MongoDBException('Email já está em uso: ${user.email}');
      }
      
      // Verificar se o UID já existe
      final existingByUid = await findByUid(user.uid);
      if (existingByUid != null) {
        throw MongoDBException('UID já está em uso: ${user.uid}');
      }
      
      final data = user.toMongo();
      final result = await _collection.insertOne(data);
      
      if (result.isSuccess && result.document?['_id'] != null) {
        final createdUser = user.copyWith(id: result.document?['_id']);
        return createdUser;
      } else {
        throw MongoDBException('Falha ao criar usuário: ${result.writeError?.errmsg}');
      }
    });
  }
  
  /// Busca usuário por Firebase UID
  Future<UserProfile?> findByUid(String uid) async {
    return await _client.executeWithRetry(() async {
      final filter = {
        'uid': uid,
        'isActive': true,
      };
      
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final user = UserProfile.fromMongo(result);
        return user;
      } else {
        return null;
      }
    });
  }
  
  /// Busca usuário por email
  Future<UserProfile?> findByEmail(String email) async {
    return await _client.executeWithRetry(() async {
      final filter = {
        'email': email.toLowerCase(),
        'isActive': true,
      };
      
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final user = UserProfile.fromMongo(result);
        return user;
      } else {
        return null;
      }
    });
  }
  
  /// Busca usuário por ID
  Future<UserProfile?> findById(String id) async {
    return await _client.executeWithRetry(() async {
      final filter = MongoDBHelper.idFilter(id);
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final user = UserProfile.fromMongo(result);
        return user;
      } else {
        return null;
      }
    });
  }
  
  /// Busca usuários por papel (role)
  Future<List<UserProfile>> findByRole(
    UserRole role, {
    int page = 1,
    int limit = 20,
    bool? isVerified,
  }) async {
    return await _client.executeWithRetry(() async {
      final filter = {
        'role': role.value,
        'isActive': true,
      };
      
      // Filtro adicional para verificação (analistas)
      if (isVerified != null && role.isAnalyst) {
        filter['isProfessionalVerified'] = isVerified;
      }
      
      final options = MongoDBHelper.paginationOptions(
        page: page,
        limit: limit,
        sort: {'createdAt': -1},
      );
      
      final results = await _collection.find(filter).toList();
      final users = results.map((doc) => UserProfile.fromMongo(doc)).toList();
      
      return users;
    });
  }
  
  /// Busca analistas por CRP
  Future<UserProfile?> findByCrp(String crp) async {
    return await _client.executeWithRetry(() async {
      print('🔍 [USER_REPO] Buscando analista por CRP: $crp');
      
      final filter = {
        'crp': crp,
        'role': UserRole.analyst.value,
        'isActive': true,
      };
      
      final result = await _collection.findOne(filter);
      
      if (result != null) {
        final user = UserProfile.fromMongo(result);
        print('✅ [USER_REPO] Analista encontrado: ${user.email}');
        return user;
      } else {
        print('❌ [USER_REPO] Analista não encontrado com CRP: $crp');
        return null;
      }
    });
  }
  
  /// Atualiza um usuário
  Future<UserProfile?> update(String uid, UserProfile user) async {
    return await _client.executeWithRetry(() async {
      print('🔄 [USER_REPO] Atualizando usuário: $uid');
      
      if (!user.isValid) {
        throw MongoDBException('Dados do usuário são inválidos');
      }
      
      final filter = {'uid': uid};
      final update = {
        '\$set': {
          ...user.toMongo(),
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.findAndModify(
        query: filter,
        update: update,
        returnNew: true,
      );
      
      if (result != null) {
        final updatedUser = UserProfile.fromMongo(result);
        print('✅ [USER_REPO] Usuário atualizado: ${updatedUser.email}');
        return updatedUser;
      } else {
        print('❌ [USER_REPO] Usuário não encontrado para atualizar: $uid');
        return null;
      }
    });
  }
  
  /// Atualiza último login
  Future<bool> updateLastLogin(String uid, String? ipAddress) async {
    return await _client.executeWithRetry(() async {
      print('📝 [USER_REPO] Atualizando último login: $uid');
      
      final filter = {'uid': uid};
      final update = {
        '\$set': {
          'lastLoginAt': DateTime.now().toUtc(),
          'lastLoginIp': ipAddress,
          'updatedAt': DateTime.now().toUtc(),
        },
        '\$inc': {
          'loginCount': 1,
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
        print('✅ [USER_REPO] Login atualizado para usuário: $uid');
      } else {
        print('❌ [USER_REPO] Falha ao atualizar login: $uid');
      }
      
      return success;
    });
  }
  
  /// Verifica analista profissionalmente
  Future<bool> verifyAnalyst(String uid, bool isVerified) async {
    return await _client.executeWithRetry(() async {
      print('✅ [USER_REPO] ${isVerified ? 'Verificando' : 'Removendo verificação'} analista: $uid');
      
      final filter = {
        'uid': uid,
        'role': UserRole.analyst.value,
      };
      
      final update = {
        '\$set': {
          'isProfessionalVerified': isVerified,
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
        print('✅ [USER_REPO] Verificação atualizada para analista: $uid');
      } else {
        print('❌ [USER_REPO] Falha ao atualizar verificação: $uid');
      }
      
      return success;
    });
  }
  
  /// Desativa usuário (soft delete)
  Future<bool> deactivate(String uid) async {
    return await _client.executeWithRetry(() async {
      print('🗑️ [USER_REPO] Desativando usuário: $uid');
      
      final filter = {'uid': uid};
      final update = {
        '\$set': {
          'isActive': false,
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
        print('✅ [USER_REPO] Usuário desativado: $uid');
      } else {
        print('❌ [USER_REPO] Falha ao desativar usuário: $uid');
      }
      
      return success;
    });
  }
  
  /// Reativa usuário
  Future<bool> reactivate(String uid) async {
    return await _client.executeWithRetry(() async {
      print('♻️ [USER_REPO] Reativando usuário: $uid');
      
      final filter = {'uid': uid};
      final update = {
        '\$set': {
          'isActive': true,
          'updatedAt': DateTime.now().toUtc(),
        }
      };
      
      final result = await _collection.updateOne(filter, update);
      final success = result.isSuccess && result.nMatched > 0;
      
      if (success) {
        print('✅ [USER_REPO] Usuário reativado: $uid');
      } else {
        print('❌ [USER_REPO] Falha ao reativar usuário: $uid');
      }
      
      return success;
    });
  }
  
  /// Conta usuários por critérios
  Future<Map<String, int>> getUserCounts() async {
    return await _client.executeWithRetry(() async {
      print('📊 [USER_REPO] Obtendo contadores de usuários');
      
      final pipeline = [
        {
          '\$group': {
            '_id': '\$role',
            'total': {'\$sum': 1},
            'active': {
              '\$sum': {
                '\$cond': ['\$isActive', 1, 0]
              }
            },
            'verified': {
              '\$sum': {
                '\$cond': [
                  {
                    '\$and': [
                      {'\$eq': ['\$role', 'analyst']},
                      {'\$eq': ['\$isProfessionalVerified', true]}
                    ]
                  },
                  1,
                  0
                ]
              }
            }
          }
        }
      ];
      
      final results = await _collection.aggregateToStream(pipeline.cast<Map<String, Object>>()).toList();
      
      final counts = <String, int>{
        'totalUsers': 0,
        'totalPatients': 0,
        'totalAnalysts': 0,
        'activeUsers': 0,
        'activePatients': 0,
        'activeAnalysts': 0,
        'verifiedAnalysts': 0,
      };
      
      for (final result in results) {
        final role = result['_id'] as String;
        final total = result['total'] as int;
        final active = result['active'] as int;
        final verified = result['verified'] as int;
        
        counts['totalUsers'] = (counts['totalUsers'] ?? 0) + total;
        counts['activeUsers'] = (counts['activeUsers'] ?? 0) + active;
        
        if (role == 'user') {
          counts['totalPatients'] = total;
          counts['activePatients'] = active;
        } else if (role == 'analyst') {
          counts['totalAnalysts'] = total;
          counts['activeAnalysts'] = active;
          counts['verifiedAnalysts'] = verified;
        }
      }
      
      print('✅ [USER_REPO] Contadores obtidos: $counts');
      return counts;
    });
  }
  
  /// Remove permanentemente um usuário (hard delete)
  Future<bool> permanentDelete(String uid) async {
    return await _client.executeWithRetry(() async {
      print('🗑️ [USER_REPO] Removendo permanentemente usuário: $uid');
      
      final filter = {'uid': uid};
      final result = await _collection.deleteOne(filter);
      final success = result.isSuccess && result.nRemoved > 0;
      
      if (success) {
        print('✅ [USER_REPO] Usuário removido permanentemente: $uid');
      } else {
        print('❌ [USER_REPO] Falha ao remover usuário: $uid');
      }
      
      return success;
    });
  }
}
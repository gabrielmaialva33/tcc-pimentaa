import 'dart:async';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'mongodb_config.dart';

/// Cliente MongoDB singleton para gerenciar conexões
class MongoDBClient {
  static MongoDBClient? _instance;
  static MongoDBClient get instance => _instance ??= MongoDBClient._();
  
  MongoDBClient._();
  
  Db? _database;
  bool _isConnected = false;
  
  /// Obtém a instância do banco de dados
  Db get database {
    if (_database == null || !_isConnected) {
      throw MongoDBException('Database not connected. Call connect() first.');
    }
    return _database!;
  }
  
  /// Status da conexão
  bool get isConnected => _isConnected && _database != null;
  
  /// Conecta ao MongoDB Atlas
  Future<void> connect() async {
    if (_isConnected && _database != null) {
      print('📦 [MONGODB] Já conectado ao banco de dados');
      return;
    }
    
    try {
      print('🔌 [MONGODB] Conectando ao MongoDB Atlas...');
      print('🌐 [MONGODB] Cluster: ${MongoDBConfig.cluster}');
      print('🗄️ [MONGODB] Database: ${MongoDBConfig.database}');
      
      _database = await Db.create(MongoDBConfig.connectionString);
      await _database!.open();
      
      _isConnected = true;
      
      print('✅ [MONGODB] Conexão estabelecida com sucesso!');
      
      // Verificar se as coleções existem e criar índices
      await _ensureCollectionsAndIndexes();
      
    } catch (e, stackTrace) {
      print('❌ [MONGODB] Erro ao conectar: $e');
      print('📋 [MONGODB] Stack trace: $stackTrace');
      
      _isConnected = false;
      _database = null;
      
      throw MongoDBException('Falha ao conectar com MongoDB: $e');
    }
  }
  
  /// Desconecta do banco de dados
  Future<void> disconnect() async {
    if (_database != null && _isConnected) {
      print('🔌 [MONGODB] Desconectando do banco de dados...');
      
      try {
        await _database!.close();
        _isConnected = false;
        _database = null;
        
        print('✅ [MONGODB] Desconectado com sucesso');
      } catch (e) {
        print('⚠️ [MONGODB] Erro ao desconectar: $e');
      }
    }
  }
  
  /// Obtém uma coleção específica
  DbCollection getCollection(String collectionName) {
    if (!_isConnected || _database == null) {
      throw MongoDBException('Database not connected');
    }
    
    return _database!.collection(collectionName);
  }
  
  /// Testa a conectividade
  Future<bool> testConnection() async {
    try {
      if (!_isConnected) {
        await connect();
      }
      
      // Fazer um ping simples
      final result = await _database!.adminDb.runCommand({
        'ping': 1
      });
      
      return result['ok'] == 1;
    } catch (e) {
      print('❌ [MONGODB] Teste de conexão falhou: $e');
      return false;
    }
  }
  
  /// Garante que as coleções e índices existem
  Future<void> _ensureCollectionsAndIndexes() async {
    try {
      print('🔧 [MONGODB] Verificando coleções e índices...');
      
      for (final entry in MongoDBConfig.indexes.entries) {
        final collectionName = entry.key;
        final indexFields = entry.value;
        
        final collection = getCollection(collectionName);
        
        // Criar índices se não existirem
        for (final field in indexFields) {
          try {
            await collection.createIndex(key: field);
            print('📁 [MONGODB] Índice criado: $collectionName.$field');
          } catch (e) {
            // Índice pode já existir
            print('📁 [MONGODB] Índice já existe: $collectionName.$field');
          }
        }
      }
      
      print('✅ [MONGODB] Coleções e índices verificados');
    } catch (e) {
      print('⚠️ [MONGODB] Erro ao criar índices: $e');
    }
  }
  
  /// Executa uma operação com retry automático
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Verificar conexão antes da operação
        if (!_isConnected) {
          await connect();
        }
        
        return await operation();
      } catch (e) {
        print('❌ [MONGODB] Tentativa $attempt/$maxRetries falhou: $e');
        
        if (attempt == maxRetries) {
          throw MongoDBException('Operação falhou após $maxRetries tentativas: $e');
        }
        
        // Aguardar antes de tentar novamente
        await Future.delayed(delay * attempt);
        
        // Tentar reconectar se necessário
        if (e is ConnectionException || e is SocketException) {
          _isConnected = false;
          await disconnect();
        }
      }
    }
    
    throw MongoDBException('Operação falhou');
  }
  
  /// Obtém estatísticas do banco de dados
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      if (!_isConnected) {
        await connect();
      }
      
      final stats = await _database!.adminDb.runCommand({
        'dbStats': 1,
        'scale': 1024 * 1024 // MB
      });
      
      return {
        'database': stats['db'],
        'collections': stats['collections'],
        'objects': stats['objects'],
        'avgObjSize': stats['avgObjSize'],
        'dataSize': '${stats['dataSize']} MB',
        'storageSize': '${stats['storageSize']} MB',
        'indexes': stats['indexes'],
        'indexSize': '${stats['indexSize']} MB',
      };
    } catch (e) {
      throw MongoDBException('Erro ao obter estatísticas: $e');
    }
  }
  
  /// Obtém informações de todas as coleções
  Future<List<Map<String, dynamic>>> getCollectionsInfo() async {
    try {
      if (!_isConnected) {
        await connect();
      }
      
      final collections = <Map<String, dynamic>>[];
      
      for (final collectionName in MongoDBConfig.indexes.keys) {
        try {
          final collection = getCollection(collectionName);
          final count = await collection.count();
          
          collections.add({
            'name': collectionName,
            'count': count,
            'exists': true,
          });
        } catch (e) {
          collections.add({
            'name': collectionName,
            'count': 0,
            'exists': false,
            'error': e.toString(),
          });
        }
      }
      
      return collections;
    } catch (e) {
      throw MongoDBException('Erro ao obter informações das coleções: $e');
    }
  }
  
  /// Limpa recursos
  Future<void> dispose() async {
    await disconnect();
    _instance = null;
  }
}

/// Exceção personalizada para MongoDB
class MongoDBException implements Exception {
  final String message;
  final String? code;
  
  MongoDBException(this.message, {this.code});
  
  @override
  String toString() => 'MongoDBException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Helper para operações comuns
class MongoDBHelper {
  /// Gera ObjectId como string
  static String generateObjectId() => ObjectId().toHexString();
  
  /// Converte string para ObjectId
  static ObjectId stringToObjectId(String id) => ObjectId.fromHexString(id);
  
  /// Converte ObjectId para string
  static String objectIdToString(ObjectId id) => id.toHexString();
  
  /// Cria filtro por ID
  static Map<String, dynamic> idFilter(String id) => {'_id': stringToObjectId(id)};
  
  /// Cria timestamp atual
  static DateTime now() => DateTime.now().toUtc();
  
  /// Limita e pagina resultados
  static Map<String, dynamic> paginationOptions({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? sort,
  }) {
    return {
      'skip': (page - 1) * limit,
      'limit': limit,
      if (sort != null) 'sort': sort,
    };
  }
  
  /// Cria filtro de data
  static Map<String, dynamic> dateRangeFilter({
    String field = 'createdAt',
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filter = <String, dynamic>{};
    
    if (startDate != null || endDate != null) {
      filter[field] = <String, dynamic>{};
      
      if (startDate != null) {
        filter[field]['\$gte'] = startDate.toUtc();
      }
      
      if (endDate != null) {
        filter[field]['\$lte'] = endDate.toUtc();
      }
    }
    
    return filter;
  }
}
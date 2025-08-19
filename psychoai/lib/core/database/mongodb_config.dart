/// Configuração para conexão com MongoDB Atlas
class MongoDBConfig {
  // Credenciais fornecidas pelo usuário
  static const String username = 'psychoai';
  static const String password = '4oZReUeNVBJp1m7s';
  static const String cluster = 'cluster.ivlkp.gcp.mongodb.net';
  static const String appName = 'Cluster';
  
  // Nome do banco de dados
  static const String database = 'psychoai_db';
  
  // Configurações de conexão
  static const int maxPoolSize = 10;
  static const int timeoutSeconds = 30;
  static const bool retryWrites = true;
  static const String writeConcern = 'majority';
  
  /// String de conexão completa do MongoDB Atlas
  static String get connectionString => 
    'mongodb+srv://$username:$password@$cluster/$database?retryWrites=$retryWrites&w=$writeConcern&appName=$appName';
  
  /// String de conexão sem banco específico (para administração)
  static String get adminConnectionString => 
    'mongodb+srv://$username:$password@$cluster/?retryWrites=$retryWrites&w=$writeConcern&appName=$appName';
  
  /// Nomes das coleções
  static const String memoriesCollection = 'memories';
  static const String analysesCollection = 'analyses';
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  static const String patternsCollection = 'patterns';
  static const String statisticsCollection = 'statistics';
  
  /// Configurações de índices para otimização
  static const Map<String, List<String>> indexes = {
    memoriesCollection: ['userId', 'createdAt', 'emotions'],
    analysesCollection: ['memoryId', 'userId', 'createdAt', 'provider'],
    usersCollection: ['deviceId', 'createdAt'],
    sessionsCollection: ['userId', 'startTime'],
    patternsCollection: ['userId', 'analysisDate'],
    statisticsCollection: ['userId', 'period'],
  };
  
  /// Limites de armazenamento
  static const int maxMemoryTextLength = 5000;
  static const int maxAnalysisTextLength = 10000;
  static const int maxInsightsCount = 20;
  static const int maxEmotionsCount = 10;
  
  /// Configurações de cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  /// Configurações de backup
  static const Duration backupInterval = Duration(days: 1);
  static const int maxBackupRetention = 30; // dias
  
  /// Valida se a configuração está correta
  static bool isConfigured() {
    return username.isNotEmpty && 
           password.isNotEmpty && 
           cluster.isNotEmpty &&
           database.isNotEmpty;
  }
  
  /// Retorna configurações de desenvolvimento ou produção
  static Map<String, dynamic> getConnectionOptions() {
    return {
      'maxPoolSize': maxPoolSize,
      'connectTimeoutMS': timeoutSeconds * 1000,
      'socketTimeoutMS': timeoutSeconds * 1000,
      'serverSelectionTimeoutMS': timeoutSeconds * 1000,
      'retryWrites': retryWrites,
      'w': writeConcern,
      'appName': appName,
      'ssl': true,
      'authSource': 'admin',
    };
  }
  
  /// Configurações específicas para diferentes ambientes
  static Map<String, dynamic> getEnvironmentConfig(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
        return {
          'logLevel': 'debug',
          'maxConnections': 5,
          'timeout': 15,
        };
      case 'production':
        return {
          'logLevel': 'error',
          'maxConnections': maxPoolSize,
          'timeout': timeoutSeconds,
        };
      case 'testing':
        return {
          'logLevel': 'info',
          'maxConnections': 3,
          'timeout': 10,
        };
      default:
        return getEnvironmentConfig('production');
    }
  }
}
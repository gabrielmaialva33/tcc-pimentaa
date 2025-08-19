import '../models/user_profile.dart';
import '../models/user_role.dart';

/// Serviço para controle de acesso baseado em papéis (RBAC)
class RoleService {
  static RoleService? _instance;
  static RoleService get instance => _instance ??= RoleService._();
  
  RoleService._();
  
  /// Verifica se o usuário tem um papel específico
  bool hasRole(UserProfile? user, UserRole requiredRole) {
    if (user == null || !user.isActive) return false;
    return user.role == requiredRole;
  }
  
  /// Verifica se o usuário tem uma permissão específica
  bool hasPermission(UserProfile? user, String permission) {
    if (user == null || !user.isActive) return false;
    return user.hasPermission(permission);
  }
  
  /// Verifica se o usuário é um paciente
  bool isPatient(UserProfile? user) {
    return hasRole(user, UserRole.user);
  }
  
  /// Verifica se o usuário é um analista
  bool isAnalyst(UserProfile? user) {
    return hasRole(user, UserRole.analyst);
  }
  
  /// Verifica se o usuário é um analista verificado
  bool isVerifiedAnalyst(UserProfile? user) {
    return user != null && 
           user.isActive && 
           user.role.isAnalyst && 
           user.isVerifiedAnalyst;
  }
  
  /// Verifica se o usuário pode acessar dados de análises
  bool canAccessAnalyses(UserProfile? user) {
    return hasPermission(user, 'view_own_analyses') || 
           hasPermission(user, 'view_all_analyses');
  }
  
  /// Verifica se o usuário pode criar memórias
  bool canCreateMemory(UserProfile? user) {
    return hasPermission(user, 'create_memory');
  }
  
  /// Verifica se o usuário pode ver dados agregados
  bool canViewAggregatedData(UserProfile? user) {
    return hasPermission(user, 'view_aggregated_data');
  }
  
  /// Verifica se o usuário pode gerar relatórios
  bool canGenerateReports(UserProfile? user) {
    return hasPermission(user, 'generate_reports');
  }
  
  /// Verifica se o usuário pode gerenciar pacientes
  bool canManagePatients(UserProfile? user) {
    return hasPermission(user, 'manage_patients');
  }
  
  /// Verifica se o usuário pode exportar dados
  bool canExportData(UserProfile? user) {
    return hasPermission(user, 'export_data');
  }
  
  /// Verifica se o usuário pode fazer anotações profissionais
  bool canMakeProfessionalAnnotations(UserProfile? user) {
    return hasPermission(user, 'professional_annotations');
  }
  
  /// Verifica se o usuário pode editar o próprio perfil
  bool canEditProfile(UserProfile? user) {
    return hasPermission(user, 'edit_profile');
  }
  
  /// Verifica se o usuário pode deletar os próprios dados
  bool canDeleteOwnData(UserProfile? user) {
    return hasPermission(user, 'delete_own_data');
  }
  
  /// Obtém as funcionalidades disponíveis para o usuário
  List<String> getAvailableFeatures(UserProfile? user) {
    if (user == null || !user.isActive) return [];
    
    final features = <String>[];
    
    // Funcionalidades básicas para todos os usuários
    if (canEditProfile(user)) {
      features.add('edit_profile');
    }
    
    if (canDeleteOwnData(user)) {
      features.add('delete_data');
    }
    
    // Funcionalidades específicas para pacientes
    if (isPatient(user)) {
      if (canCreateMemory(user)) {
        features.add('create_memory');
      }
      
      if (canAccessAnalyses(user)) {
        features.add('view_analyses');
      }
      
      features.addAll([
        'personal_dashboard',
        'emotion_tracking',
        'progress_view',
      ]);
    }
    
    // Funcionalidades específicas para analistas
    if (isAnalyst(user)) {
      if (canViewAggregatedData(user)) {
        features.add('aggregated_data');
      }
      
      if (canGenerateReports(user)) {
        features.add('generate_reports');
      }
      
      if (canManagePatients(user)) {
        features.add('manage_patients');
      }
      
      if (canExportData(user)) {
        features.add('export_data');
      }
      
      if (canMakeProfessionalAnnotations(user)) {
        features.add('professional_annotations');
      }
      
      features.addAll([
        'professional_dashboard',
        'patient_analytics',
        'pattern_analysis',
        'statistical_reports',
      ]);
      
      // Funcionalidades extras para analistas verificados
      if (isVerifiedAnalyst(user)) {
        features.addAll([
          'full_patient_access',
          'research_tools',
          'collaboration_features',
        ]);
      }
    }
    
    return features;
  }
  
  /// Obtém as rotas disponíveis para o usuário
  List<String> getAvailableRoutes(UserProfile? user) {
    if (user == null || !user.isActive) {
      return ['/login', '/register', '/forgot-password'];
    }
    
    final routes = <String>['/profile', '/settings'];
    
    if (isPatient(user)) {
      routes.addAll([
        '/dashboard',
        '/memory/create',
        '/memory/history',
        '/analyses/personal',
      ]);
    }
    
    if (isAnalyst(user)) {
      routes.addAll([
        '/dashboard/professional',
        '/patients',
        '/analytics',
        '/reports',
      ]);
      
      if (isVerifiedAnalyst(user)) {
        routes.addAll([
          '/research',
          '/collaboration',
          '/supervision',
        ]);
      }
    }
    
    return routes;
  }
  
  /// Verifica se o usuário pode acessar uma rota específica
  bool canAccessRoute(UserProfile? user, String route) {
    final availableRoutes = getAvailableRoutes(user);
    return availableRoutes.contains(route);
  }
  
  /// Obtém a rota inicial baseada no papel do usuário
  String getInitialRoute(UserProfile? user) {
    if (user == null || !user.isActive) {
      return '/login';
    }
    
    if (isPatient(user)) {
      return '/dashboard';
    }
    
    if (isAnalyst(user)) {
      return '/dashboard/professional';
    }
    
    return '/dashboard';
  }
  
  /// Obtém mensagens de acesso negado personalizadas
  String getAccessDeniedMessage(UserProfile? user, String feature) {
    if (user == null) {
      return 'Você precisa fazer login para acessar esta funcionalidade.';
    }
    
    if (!user.isActive) {
      return 'Sua conta está desativada. Entre em contato com o suporte.';
    }
    
    if (user.role.isAnalyst && !user.isVerifiedAnalyst) {
      return 'Sua conta de analista ainda não foi verificada. '
             'Aguarde a aprovação ou entre em contato com o suporte.';
    }
    
    switch (feature) {
      case 'create_memory':
        return 'Apenas pacientes podem criar memórias.';
      case 'view_all_analyses':
        return 'Apenas analistas verificados podem ver todas as análises.';
      case 'generate_reports':
        return 'Apenas analistas podem gerar relatórios.';
      case 'manage_patients':
        return 'Apenas analistas podem gerenciar pacientes.';
      case 'export_data':
        return 'Apenas analistas podem exportar dados.';
      case 'professional_annotations':
        return 'Apenas analistas podem fazer anotações profissionais.';
      default:
        return 'Você não tem permissão para acessar esta funcionalidade.';
    }
  }
  
  /// Filtra dados baseado no papel do usuário
  Map<String, dynamic> filterDataByRole(
    UserProfile? user, 
    Map<String, dynamic> data
  ) {
    if (user == null || !user.isActive) {
      return {};
    }
    
    final filteredData = Map<String, dynamic>.from(data);
    
    // Para pacientes, remover dados sensíveis
    if (isPatient(user)) {
      filteredData.removeWhere((key, value) => 
        key.contains('professional') || 
        key.contains('admin') ||
        key.contains('system')
      );
    }
    
    // Para analistas não verificados, limitar acesso
    if (isAnalyst(user) && !isVerifiedAnalyst(user)) {
      filteredData.removeWhere((key, value) => 
        key.contains('full_access') || 
        key.contains('unrestricted')
      );
    }
    
    return filteredData;
  }
  
  /// Obtém configurações de UI baseadas no papel
  Map<String, dynamic> getUIConfiguration(UserProfile? user) {
    final defaultConfig = {
      'theme': 'light',
      'showAdvancedFeatures': false,
      'enableProfessionalMode': false,
      'restrictedMode': true,
    };
    
    if (user == null || !user.isActive) {
      return defaultConfig;
    }
    
    if (isPatient(user)) {
      return {
        ...defaultConfig,
        'theme': user.getPreference('theme', 'calming'),
        'showEmotionTools': true,
        'showPersonalAnalytics': true,
        'enableNotifications': user.getPreference('notifications', true),
      };
    }
    
    if (isAnalyst(user)) {
      return {
        ...defaultConfig,
        'theme': user.getPreference('theme', 'professional'),
        'showAdvancedFeatures': true,
        'enableProfessionalMode': true,
        'restrictedMode': false,
        'showStatistics': true,
        'showReports': isVerifiedAnalyst(user),
        'enableDataExport': isVerifiedAnalyst(user),
        'dashboardView': user.getPreference('dashboard_view', 'detailed'),
      };
    }
    
    return defaultConfig;
  }
}
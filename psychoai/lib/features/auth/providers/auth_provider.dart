import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../services/firebase_auth_service.dart';
import '../services/role_service.dart';

/// Provider para gerenciamento de estado de autenticação
class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final RoleService _roleService = RoleService.instance;
  
  AuthState _state = const AuthState.uninitialized();
  
  /// Estado atual de autenticação
  AuthState get state => _state;
  
  /// Usuário atual
  UserProfile? get currentUser => _state.user;
  
  /// Verifica se está autenticado
  bool get isAuthenticated => _state.isAuthenticated;
  
  /// Verifica se está carregando
  bool get isLoading => _state.isLoading;
  
  /// Verifica se tem erro
  bool get hasError => _state.hasError;
  
  /// Mensagem de erro atual
  String? get errorMessage => _state.errorMessage;
  
  /// Verifica se é paciente
  bool get isPatient => _roleService.isPatient(currentUser);
  
  /// Verifica se é analista
  bool get isAnalyst => _roleService.isAnalyst(currentUser);
  
  /// Verifica se é analista verificado
  bool get isVerifiedAnalyst => _roleService.isVerifiedAnalyst(currentUser);
  
  AuthProvider() {
    _initializeAuth();
  }
  
  /// Inicializa o monitoramento de autenticação
  void _initializeAuth() {
    debugPrint('🔧 [AUTH_PROVIDER] Inicializando monitoramento de autenticação');
    
    _authService.authStateChanges.listen((firebaseUser) async {
      await _handleAuthStateChange(firebaseUser);
    });
  }
  
  /// Manipula mudanças no estado de autenticação do Firebase
  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        debugPrint('🚪 [AUTH_PROVIDER] Usuário deslogado');
        _updateState(const AuthState.unauthenticated());
        return;
      }
      
      debugPrint('👤 [AUTH_PROVIDER] Usuário detectado: ${firebaseUser.email}');
      _updateState(const AuthState.loading());
      
      // Buscar perfil completo no MongoDB
      final userProfile = await _authService.getCurrentUserProfile();
      
      if (userProfile == null) {
        debugPrint('❌ [AUTH_PROVIDER] Perfil não encontrado para: ${firebaseUser.uid}');
        await _authService.signOut();
        _updateState(const AuthState.error('Perfil de usuário não encontrado'));
        return;
      }
      
      if (!userProfile.isActive) {
        debugPrint('❌ [AUTH_PROVIDER] Conta desativada: ${userProfile.email}');
        await _authService.signOut();
        _updateState(const AuthState.error('Conta desativada'));
        return;
      }
      
      debugPrint('✅ [AUTH_PROVIDER] Usuário autenticado: ${userProfile.formattedDisplayName}');
      _updateState(AuthState.authenticated(userProfile));
      
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro na mudança de estado: $e');
      _updateState(AuthState.error('Erro de autenticação: $e'));
    }
  }
  
  /// Atualiza o estado e notifica ouvintes
  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
  
  /// Faz login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [AUTH_PROVIDER] Iniciando login');
      _updateState(const AuthState.loading());
      
      final userProfile = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      _updateState(AuthState.authenticated(userProfile));
      debugPrint('✅ [AUTH_PROVIDER] Login realizado com sucesso');
      return true;
      
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro de autenticação: ${e.message}');
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro inesperado no login: $e');
      _updateState(const AuthState.error('Erro inesperado. Tente novamente.'));
      return false;
    }
  }
  
  /// Registra novo paciente
  Future<bool> registerPatient({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      debugPrint('📝 [AUTH_PROVIDER] Iniciando registro de paciente');
      _updateState(const AuthState.loading());
      
      final userProfile = await _authService.registerPatient(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
        preferences: preferences,
      );
      
      _updateState(AuthState.authenticated(userProfile));
      debugPrint('✅ [AUTH_PROVIDER] Paciente registrado com sucesso');
      return true;
      
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro no registro: ${e.message}');
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro inesperado no registro: $e');
      _updateState(const AuthState.error('Erro inesperado. Tente novamente.'));
      return false;
    }
  }
  
  /// Registra novo analista
  Future<bool> registerAnalyst({
    required String email,
    required String password,
    required String displayName,
    required String crp,
    required String specialty,
    String? professionalBio,
    List<String>? certifications,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      debugPrint('📝 [AUTH_PROVIDER] Iniciando registro de analista');
      _updateState(const AuthState.loading());
      
      final userProfile = await _authService.registerAnalyst(
        email: email,
        password: password,
        displayName: displayName,
        crp: crp,
        specialty: specialty,
        professionalBio: professionalBio,
        certifications: certifications,
        phone: phone,
        preferences: preferences,
      );
      
      _updateState(AuthState.authenticated(userProfile));
      debugPrint('✅ [AUTH_PROVIDER] Analista registrado com sucesso');
      return true;
      
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro no registro de analista: ${e.message}');
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro inesperado no registro: $e');
      _updateState(const AuthState.error('Erro inesperado. Tente novamente.'));
      return false;
    }
  }
  
  /// Faz logout
  Future<void> signOut() async {
    try {
      debugPrint('🚪 [AUTH_PROVIDER] Iniciando logout');
      _updateState(const AuthState.loading());
      
      await _authService.signOut();
      
      _updateState(const AuthState.unauthenticated());
      debugPrint('✅ [AUTH_PROVIDER] Logout realizado com sucesso');
      
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro no logout: $e');
      _updateState(const AuthState.error('Erro ao fazer logout'));
    }
  }
  
  /// Envia email de redefinição de senha
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 [AUTH_PROVIDER] Enviando email de redefinição');
      
      await _authService.sendPasswordResetEmail(email);
      
      debugPrint('✅ [AUTH_PROVIDER] Email de redefinição enviado');
      return true;
      
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro ao enviar email: ${e.message}');
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro inesperado: $e');
      _updateState(const AuthState.error('Erro inesperado. Tente novamente.'));
      return false;
    }
  }
  
  /// Reenvia email de verificação
  Future<bool> sendEmailVerification() async {
    try {
      debugPrint('📧 [AUTH_PROVIDER] Reenviando email de verificação');
      
      await _authService.sendEmailVerification();
      
      debugPrint('✅ [AUTH_PROVIDER] Email de verificação reenviado');
      return true;
      
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro ao reenviar: ${e.message}');
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro inesperado: $e');
      _updateState(const AuthState.error('Erro inesperado. Tente novamente.'));
      return false;
    }
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    if (_state.hasError) {
      _updateState(const AuthState.unauthenticated());
    }
  }
  
  /// Recarrega perfil do usuário
  Future<void> reloadUserProfile() async {
    try {
      if (!isAuthenticated) return;
      
      debugPrint('🔄 [AUTH_PROVIDER] Recarregando perfil do usuário');
      
      final userProfile = await _authService.getCurrentUserProfile();
      if (userProfile != null) {
        _updateState(AuthState.authenticated(userProfile));
        debugPrint('✅ [AUTH_PROVIDER] Perfil recarregado');
      }
      
    } catch (e) {
      debugPrint('❌ [AUTH_PROVIDER] Erro ao recarregar perfil: $e');
    }
  }
  
  /// Verifica se tem uma permissão específica
  bool hasPermission(String permission) {
    return _roleService.hasPermission(currentUser, permission);
  }
  
  /// Verifica se tem um papel específico
  bool hasRole(UserRole role) {
    return _roleService.hasRole(currentUser, role);
  }
  
  /// Obtém funcionalidades disponíveis
  List<String> getAvailableFeatures() {
    return _roleService.getAvailableFeatures(currentUser);
  }
  
  /// Obtém rotas disponíveis
  List<String> getAvailableRoutes() {
    return _roleService.getAvailableRoutes(currentUser);
  }
  
  /// Verifica se pode acessar uma rota
  bool canAccessRoute(String route) {
    return _roleService.canAccessRoute(currentUser, route);
  }
  
  /// Obtém rota inicial baseada no papel
  String getInitialRoute() {
    return _roleService.getInitialRoute(currentUser);
  }
  
  /// Obtém mensagem de acesso negado
  String getAccessDeniedMessage(String feature) {
    return _roleService.getAccessDeniedMessage(currentUser, feature);
  }
  
  /// Obtém configurações de UI baseadas no papel
  Map<String, dynamic> getUIConfiguration() {
    return _roleService.getUIConfiguration(currentUser);
  }
  
  /// Filtra dados baseado no papel
  Map<String, dynamic> filterDataByRole(Map<String, dynamic> data) {
    return _roleService.filterDataByRole(currentUser, data);
  }
  
  @override
  void dispose() {
    debugPrint('🔧 [AUTH_PROVIDER] Disposing');
    super.dispose();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../repositories/user_repository.dart';
import '../../../core/database/mongodb_client.dart';

/// Serviço de autenticação que combina Firebase Auth com MongoDB
class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  static FirebaseAuthService get instance => _instance ??= FirebaseAuthService._();
  
  FirebaseAuthService._();
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository.instance;
  final MongoDBClient _mongoClient = MongoDBClient.instance;
  
  /// Stream de mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  /// Usuário atual do Firebase
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
  
  /// Verifica se o usuário está logado
  bool get isAuthenticated => currentFirebaseUser != null;
  
  /// Obtém o perfil completo do usuário atual
  Future<UserProfile?> getCurrentUserProfile() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;
    
    try {
      await _mongoClient.connect();
      return await _userRepository.findByUid(firebaseUser.uid);
    } catch (e) {
      debugPrint('Erro ao obter perfil do usuário: $e');
      return null;
    }
  }
  
  /// Faz login com email e senha
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [AUTH] Fazendo login: $email');
      
      // Login no Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Falha na autenticação');
      }
      
      // Buscar perfil no MongoDB
      await _mongoClient.connect();
      final userProfile = await _userRepository.findByUid(credential.user!.uid);
      
      if (userProfile == null) {
        throw AuthException('Perfil de usuário não encontrado');
      }
      
      if (!userProfile.isActive) {
        await _firebaseAuth.signOut();
        throw AuthException('Conta desativada. Entre em contato com o suporte.');
      }
      
      // Atualizar último login
      await _userRepository.updateLastLogin(userProfile.uid, null);
      
      debugPrint('✅ [AUTH] Login realizado com sucesso: ${userProfile.email}');
      return userProfile;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro Firebase: ${e.code} - ${e.message}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Registra novo paciente
  Future<UserProfile> registerPatient({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      debugPrint('📝 [AUTH] Registrando paciente: $email');
      
      // Criar usuário no Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Falha ao criar conta');
      }
      
      // Atualizar perfil do Firebase
      await credential.user!.updateDisplayName(displayName);
      
      // Criar perfil no MongoDB
      await _mongoClient.connect();
      final userProfile = UserProfile.patient(
        uid: credential.user!.uid,
        email: email.toLowerCase().trim(),
        displayName: displayName.trim(),
        phone: phone?.trim(),
        preferences: preferences,
      );
      
      final createdProfile = await _userRepository.create(userProfile);
      
      // Enviar email de verificação
      await credential.user!.sendEmailVerification();
      
      debugPrint('✅ [AUTH] Paciente registrado com sucesso: ${createdProfile.email}');
      return createdProfile;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro Firebase no registro: ${e.code} - ${e.message}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral no registro: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Registra novo analista
  Future<UserProfile> registerAnalyst({
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
      debugPrint('📝 [AUTH] Registrando analista: $email');
      
      // Verificar se CRP já está em uso
      await _mongoClient.connect();
      final existingAnalyst = await _userRepository.findByCrp(crp.trim());
      if (existingAnalyst != null) {
        throw AuthException('CRP já cadastrado no sistema');
      }
      
      // Criar usuário no Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Falha ao criar conta');
      }
      
      // Atualizar perfil do Firebase
      await credential.user!.updateDisplayName(displayName);
      
      // Criar perfil no MongoDB
      final userProfile = UserProfile.analyst(
        uid: credential.user!.uid,
        email: email.toLowerCase().trim(),
        displayName: displayName.trim(),
        crp: crp.trim(),
        specialty: specialty.trim(),
        professionalBio: professionalBio?.trim(),
        certifications: certifications,
        phone: phone?.trim(),
        preferences: preferences,
      );
      
      final createdProfile = await _userRepository.create(userProfile);
      
      // Enviar email de verificação
      await credential.user!.sendEmailVerification();
      
      debugPrint('✅ [AUTH] Analista registrado com sucesso: ${createdProfile.email}');
      debugPrint('⏳ [AUTH] Aguardando verificação profissional do CRP: $crp');
      
      return createdProfile;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro Firebase no registro de analista: ${e.code} - ${e.message}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral no registro de analista: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Faz logout
  Future<void> signOut() async {
    try {
      debugPrint('🚪 [AUTH] Fazendo logout');
      await _firebaseAuth.signOut();
      debugPrint('✅ [AUTH] Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ [AUTH] Erro no logout: $e');
      throw AuthException('Erro ao fazer logout');
    }
  }
  
  /// Envia email de redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 [AUTH] Enviando email de redefinição: $email');
      
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.toLowerCase().trim(),
      );
      
      debugPrint('✅ [AUTH] Email de redefinição enviado para: $email');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro ao enviar email de redefinição: ${e.code}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral no reset de senha: $e');
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Reenvia email de verificação
  Future<void> sendEmailVerification() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw AuthException('Usuário não autenticado');
      }
      
      if (user.emailVerified) {
        throw AuthException('Email já verificado');
      }
      
      debugPrint('📧 [AUTH] Reenviando email de verificação: ${user.email}');
      await user.sendEmailVerification();
      debugPrint('✅ [AUTH] Email de verificação reenviado');
      
    } catch (e) {
      debugPrint('❌ [AUTH] Erro ao reenviar verificação: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Erro ao reenviar email de verificação');
    }
  }
  
  /// Atualiza senha do usuário
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw AuthException('Usuário não autenticado');
      }
      
      debugPrint('🔑 [AUTH] Atualizando senha do usuário: ${user.email}');
      await user.updatePassword(newPassword);
      debugPrint('✅ [AUTH] Senha atualizada com sucesso');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro ao atualizar senha: ${e.code}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral na atualização de senha: $e');
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Deleta conta do usuário
  Future<void> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw AuthException('Usuário não autenticado');
      }
      
      final uid = user.uid;
      debugPrint('🗑️ [AUTH] Deletando conta: ${user.email}');
      
      // Desativar no MongoDB primeiro
      await _mongoClient.connect();
      await _userRepository.deactivate(uid);
      
      // Deletar do Firebase
      await user.delete();
      
      debugPrint('✅ [AUTH] Conta deletada com sucesso: $uid');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro ao deletar conta: ${e.code}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral na deleção: $e');
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Reautentica usuário para operações sensíveis
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentFirebaseUser;
      if (user == null || user.email == null) {
        throw AuthException('Usuário não autenticado');
      }
      
      debugPrint('🔐 [AUTH] Reautenticando usuário: ${user.email}');
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      debugPrint('✅ [AUTH] Reautenticação realizada com sucesso');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AUTH] Erro na reautenticação: ${e.code}');
      throw AuthException(_translateFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ [AUTH] Erro geral na reautenticação: $e');
      throw AuthException('Erro interno. Tente novamente.');
    }
  }
  
  /// Traduz códigos de erro do Firebase para mensagens amigáveis
  String _translateFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email não encontrado. Verifique o endereço digitado.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato.';
      case 'user-disabled':
        return 'Conta desabilitada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'email-already-in-use':
        return 'Email já está em uso. Tente fazer login ou use outro email.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'requires-recent-login':
        return 'Operação sensível. Faça login novamente.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique email e senha.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}

/// Exceção personalizada para autenticação
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}
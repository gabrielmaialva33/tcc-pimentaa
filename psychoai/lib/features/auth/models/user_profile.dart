import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../core/database/mongodb_client.dart';
import 'user_role.dart';

part 'user_profile.g.dart';

/// Modelo de perfil de usuário que combina Firebase Auth com dados MongoDB
@JsonSerializable()
class UserProfile {
  @JsonKey(name: '_id', fromJson: _objectIdFromJson, toJson: _objectIdToJson)
  final ObjectId? id;
  
  final String uid;              // Firebase UID
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isEmailVerified;
  
  // Campos específicos para analistas
  final String? crp;             // Registro profissional CRP
  final String? specialty;       // Especialização
  final bool? isProfessionalVerified; // Verificação do CRP
  final String? professionalBio; // Biografia profissional
  final List<String>? certifications; // Certificações
  
  // Campos opcionais para todos os usuários
  final String? phone;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;
  
  // Campos de auditoria
  final DateTime? lastLoginAt;
  final String? lastLoginIp;
  final int loginCount;

  const UserProfile({
    this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isEmailVerified = false,
    this.crp,
    this.specialty,
    this.isProfessionalVerified,
    this.professionalBio,
    this.certifications,
    this.phone,
    this.profileImageUrl,
    this.preferences,
    this.metadata,
    this.lastLoginAt,
    this.lastLoginIp,
    this.loginCount = 0,
  });

  /// Factory para criar perfil de paciente
  factory UserProfile.patient({
    required String uid,
    required String email,
    required String displayName,
    String? phone,
    Map<String, dynamic>? preferences,
  }) {
    final now = DateTime.now().toUtc();
    
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      role: UserRole.user,
      createdAt: now,
      updatedAt: now,
      phone: phone,
      preferences: preferences ?? {
        'notifications': true,
        'theme': 'system',
        'language': 'pt-BR',
      },
    );
  }

  /// Factory para criar perfil de analista
  factory UserProfile.analyst({
    required String uid,
    required String email,
    required String displayName,
    required String crp,
    required String specialty,
    String? professionalBio,
    List<String>? certifications,
    String? phone,
    Map<String, dynamic>? preferences,
  }) {
    final now = DateTime.now().toUtc();
    
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      role: UserRole.analyst,
      createdAt: now,
      updatedAt: now,
      crp: crp,
      specialty: specialty,
      isProfessionalVerified: false, // Verificação pendente
      professionalBio: professionalBio,
      certifications: certifications,
      phone: phone,
      preferences: preferences ?? {
        'notifications': true,
        'theme': 'professional',
        'language': 'pt-BR',
        'dashboard_view': 'detailed',
        'report_frequency': 'weekly',
      },
    );
  }

  /// Fábrica para criar do JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Converte para Map do MongoDB
  Map<String, dynamic> toMongo() {
    final json = toJson();
    
    // Converter datas para UTC
    json['createdAt'] = createdAt.toUtc();
    json['updatedAt'] = updatedAt.toUtc();
    if (lastLoginAt != null) {
      json['lastLoginAt'] = lastLoginAt!.toUtc();
    }
    
    // Converter role para string
    json['role'] = role.value;
    
    // Remover campos nulos
    json.removeWhere((key, value) => value == null);
    
    return json;
  }

  /// Cria do Map do MongoDB
  factory UserProfile.fromMongo(Map<String, dynamic> map) {
    // Garantir que as datas sejam DateTime
    if (map['createdAt'] is! DateTime) {
      map['createdAt'] = DateTime.parse(map['createdAt'].toString()).toUtc();
    }
    if (map['updatedAt'] is! DateTime) {
      map['updatedAt'] = DateTime.parse(map['updatedAt'].toString()).toUtc();
    }
    if (map['lastLoginAt'] != null && map['lastLoginAt'] is! DateTime) {
      map['lastLoginAt'] = DateTime.parse(map['lastLoginAt'].toString()).toUtc();
    }
    
    // Converter role de string para enum
    if (map['role'] is String) {
      map['role'] = UserRole.fromString(map['role']);
    }
    
    return UserProfile.fromJson(map);
  }

  /// Cria uma cópia com novos valores
  UserProfile copyWith({
    ObjectId? id,
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    String? crp,
    String? specialty,
    bool? isProfessionalVerified,
    String? professionalBio,
    List<String>? certifications,
    String? phone,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
    DateTime? lastLoginAt,
    String? lastLoginIp,
    int? loginCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      crp: crp ?? this.crp,
      specialty: specialty ?? this.specialty,
      isProfessionalVerified: isProfessionalVerified ?? this.isProfessionalVerified,
      professionalBio: professionalBio ?? this.professionalBio,
      certifications: certifications ?? this.certifications,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      loginCount: loginCount ?? this.loginCount,
    );
  }

  /// Retorna ID como string
  String get idString => id?.oid ?? '';

  /// Verifica se o perfil é válido
  bool get isValid {
    if (uid.isEmpty || email.isEmpty || displayName.isEmpty) {
      return false;
    }
    
    // Validações específicas para analistas
    if (role.isAnalyst) {
      return crp != null && crp!.isNotEmpty && 
             specialty != null && specialty!.isNotEmpty;
    }
    
    return true;
  }

  /// Verifica se o analista está verificado
  bool get isVerifiedAnalyst {
    return role.isAnalyst && 
           isProfessionalVerified == true && 
           isActive;
  }

  /// Obtém nome para exibição formatado
  String get formattedDisplayName {
    if (role.isAnalyst && isProfessionalVerified == true) {
      return 'Dr(a). $displayName';
    }
    return displayName;
  }

  /// Obtém informações profissionais resumidas
  String? get professionalSummary {
    if (role.isUser) return null;
    
    final parts = <String>[];
    if (crp != null) parts.add('CRP: $crp');
    if (specialty != null) parts.add(specialty!);
    
    return parts.isEmpty ? null : parts.join(' • ');
  }

  /// Verifica se tem uma permissão específica
  bool hasPermission(String permission) {
    return role.hasPermission(permission);
  }

  /// Obtém preferência específica
  T? getPreference<T>(String key, [T? defaultValue]) {
    if (preferences == null) return defaultValue;
    return preferences![key] as T? ?? defaultValue;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, '
           'role: ${role.displayName}, isActive: $isActive, '
           'isVerified: ${role.isAnalyst ? isProfessionalVerified : isEmailVerified})';
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

/// Estado de autenticação do usuário
enum AuthStatus {
  uninitialized,
  unauthenticated,
  authenticated,
  loading,
  error,
}

/// Estado de autenticação completo
class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.uninitialized() : this(status: AuthStatus.uninitialized);
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  
  const AuthState.authenticated(UserProfile user) : this(
    status: AuthStatus.authenticated,
    user: user,
  );
  
  const AuthState.error(String message) : this(
    status: AuthStatus.error,
    errorMessage: message,
  );

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  @override
  String toString() => 'AuthState(status: $status, user: ${user?.uid})';
}
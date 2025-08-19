/// Enum para definir os papéis de usuário no sistema
enum UserRole {
  user('user', 'Paciente', 'Usuário que utiliza o sistema para análise pessoal'),
  analyst('analyst', 'Psicanalista', 'Profissional que tem acesso às análises agregadas');

  const UserRole(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  /// Converte string para UserRole
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }

  /// Verifica se é um role de analista
  bool get isAnalyst => this == UserRole.analyst;

  /// Verifica se é um role de usuário
  bool get isUser => this == UserRole.user;

  /// Obtém o ícone associado ao role
  String get icon {
    switch (this) {
      case UserRole.user:
        return '👤';
      case UserRole.analyst:
        return '🔬';
    }
  }

  /// Obtém a cor primária associada ao role
  int get primaryColor {
    switch (this) {
      case UserRole.user:
        return 0xFF2196F3; // Azul Material
      case UserRole.analyst:
        return 0xFF4CAF50; // Verde Material
    }
  }

  /// Lista de permissões do role
  List<String> get permissions {
    switch (this) {
      case UserRole.user:
        return [
          'create_memory',
          'view_own_analyses',
          'edit_profile',
          'delete_own_data'
        ];
      case UserRole.analyst:
        return [
          'view_all_analyses',
          'view_aggregated_data',
          'generate_reports',
          'view_patterns',
          'manage_patients',
          'export_data',
          'professional_annotations'
        ];
    }
  }

  /// Verifica se o role tem uma permissão específica
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  @override
  String toString() => value;
}
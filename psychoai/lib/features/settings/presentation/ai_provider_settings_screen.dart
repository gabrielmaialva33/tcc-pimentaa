import 'package:flutter/material.dart';
import '../../../core/services/ai_provider_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/calm_button.dart';
import '../../../shared/animations/micro_animations.dart';

/// Tela para configuração dos provedores de IA
class AIProviderSettingsScreen extends StatefulWidget {
  const AIProviderSettingsScreen({super.key});

  @override
  State<AIProviderSettingsScreen> createState() => _AIProviderSettingsScreenState();
}

class _AIProviderSettingsScreenState extends State<AIProviderSettingsScreen> {
  final AIProviderService _providerService = AIProviderService.instance;
  late AIProvider _selectedProvider;
  bool _isTestingConnection = false;
  Map<AIProvider, bool> _connectionResults = {};

  @override
  void initState() {
    super.initState();
    _selectedProvider = _providerService.activeProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar customizada
              _buildCustomAppBar(),
              
              // Conteúdo principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações do provedor ativo
                      _buildActiveProviderCard(),
                      
                      const SizedBox(height: 32),
                      
                      // Lista de provedores
                      _buildProvidersSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Teste de conectividade
                      _buildConnectionTestSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Estatísticas de uso
                      _buildUsageStatsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onBackground,
          ),
          const SizedBox(width: 12),
          Text(
            'Provedores de IA',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProviderCard() {
    final providerInfo = _providerService.getActiveProviderInfo();
    
    return MicroAnimations.cardEntrance(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provedor Ativo',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        providerInfo.provider.displayName,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: providerInfo.isConfigured 
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    providerInfo.isConfigured ? 'Configurado' : 'Não Configurado',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: providerInfo.isConfigured 
                        ? AppColors.success 
                        : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              providerInfo.provider.description,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Icon(
                  Icons.model_training_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${providerInfo.models.length} modelos disponíveis',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Padrão: ${providerInfo.defaultModel}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provedores Disponíveis',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ...AIProvider.values.where((p) => p.available).map((provider) {
          final isSelected = provider == _selectedProvider;
          final isActive = provider == _providerService.activeProvider;
          
          return MicroAnimations.staggeredListItem(
            index: provider.index,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectProvider(provider),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? AppColors.primary 
                          : AppColors.onSurface.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getProviderColor(provider).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getProviderIcon(provider),
                            color: _getProviderColor(provider),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    provider.displayName,
                                    style: AppTypography.textTheme.titleMedium?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, 
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'ATIVO',
                                        style: AppTypography.textTheme.bodySmall?.copyWith(
                                          color: AppColors.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.description,
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        
        const SizedBox(height: 20),
        
        SizedBox(
          width: double.infinity,
          child: CalmButton(
            onPressed: _selectedProvider != _providerService.activeProvider 
              ? _applyProviderChange 
              : null,
            child: Text(
              _selectedProvider != _providerService.activeProvider
                ? 'Aplicar Mudança'
                : 'Provedor Ativo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teste de Conectividade',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              if (_connectionResults.isNotEmpty) ...[
                ..._connectionResults.entries.map((entry) {
                  final provider = entry.key;
                  final isConnected = entry.value;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getProviderIcon(provider),
                          color: _getProviderColor(provider),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          provider.displayName,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isConnected ? Icons.check_circle : Icons.error,
                          color: isConnected ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isConnected ? 'Conectado' : 'Falhou',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: isConnected ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                child: CalmButton(
                  onPressed: _isTestingConnection ? null : _testAllConnections,
                  isLoading: _isTestingConnection,
                  child: Text(
                    _isTestingConnection 
                      ? 'Testando...' 
                      : 'Testar Todas as Conexões',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas de Uso',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildStatItem(
                icon: Icons.analytics_outlined,
                label: 'Total de Análises',
                value: '42', // TODO: Implementar contagem real
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.token_outlined,
                label: 'Tokens Consumidos',
                value: '15.3K', // TODO: Implementar contagem real
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.access_time_outlined,
                label: 'Tempo Médio de Resposta',
                value: '2.1s', // TODO: Implementar métrica real
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.nvidia:
        return const Color(0xFF76B900); // Verde NVIDIA
      case AIProvider.alibaba:
        return const Color(0xFFFF6A00); // Laranja Alibaba
    }
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.nvidia:
        return Icons.memory; // Chip/GPU
      case AIProvider.alibaba:
        return Icons.cloud; // Cloud
    }
  }

  void _selectProvider(AIProvider provider) {
    setState(() {
      _selectedProvider = provider;
    });
  }

  void _applyProviderChange() {
    try {
      _providerService.setActiveProvider(_selectedProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Provedor alterado para ${_selectedProvider.displayName}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar provedor: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _testAllConnections() async {
    setState(() {
      _isTestingConnection = true;
      _connectionResults.clear();
    });

    try {
      final results = await _providerService.testAllConnections();
      setState(() {
        _connectionResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao testar conexões: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }
}
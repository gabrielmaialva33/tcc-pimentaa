import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/calm_button.dart';
import 'widgets/emotion_selector.dart';
import 'widgets/memory_text_field.dart';
import '../../analysis/ai_analysis_service.dart';
import '../../analysis/models/analysis_result.dart';
import '../../analysis/prompts/freudian_prompt.dart';

/// Tela principal para registro de lembranças
class MemoryInputScreen extends StatefulWidget {
  const MemoryInputScreen({super.key});

  @override
  State<MemoryInputScreen> createState() => _MemoryInputScreenState();
}

class _MemoryInputScreenState extends State<MemoryInputScreen> {
  final TextEditingController _memoryController = TextEditingController();
  final FocusNode _memoryFocusNode = FocusNode();
  final AIAnalysisService _analysisService = AIAnalysisService();
  
  List<String> _selectedEmotions = [];
  double _emotionalIntensity = 0.5;
  bool _isAnalyzing = false;
  AnalysisResult? _lastAnalysisResult;
  
  // Lista de emoções disponíveis
  final List<EmotionItem> _emotions = [
    EmotionItem('Alegria', '😊', AppColors.joy),
    EmotionItem('Tristeza', '😢', AppColors.sadness),
    EmotionItem('Raiva', '😠', AppColors.anger),
    EmotionItem('Medo', '😰', AppColors.fear),
    EmotionItem('Calma', '😌', AppColors.calm),
    EmotionItem('Ansiedade', '😟', AppColors.anxiety),
    EmotionItem('Nostalgia', '🥺', AppColors.secondary),
    EmotionItem('Confusão', '😕', AppColors.onSurfaceVariant),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar customizada
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Suas Lembranças',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    onPressed: _showInfo,
                    icon: const Icon(Icons.info_outline),
                    color: AppColors.onBackground,
                  ),
                ],
              ),
              
              // Conteúdo principal
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Instrução principal
                    _buildInstructionCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Campo de texto para a lembrança
                    _buildMemorySection(),
                    
                    const SizedBox(height: 32),
                    
                    // Seletor de emoções
                    _buildEmotionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Slider de intensidade emocional
                    _buildIntensitySection(),
                    
                    const SizedBox(height: 40),
                    
                    // Botão de análise
                    _buildAnalyzeButton(),
                    
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Livre Associação',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Escreva qualquer lembrança que venha à sua mente, sem censura. Pode ser algo recente ou distante, significativo ou aparentemente trivial.',
            style: TherapeuticStyles.aiInsight.copyWith(
              fontStyle: FontStyle.normal,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💡 Dica: Não se preocupe com gramática ou organização. O importante é expressar seus pensamentos livremente.',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 30, end: 0);
  }

  Widget _buildMemorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua Lembrança',
          style: TherapeuticStyles.dashboardSection,
        ),
        const SizedBox(height: 16),
        MemoryTextField(
          controller: _memoryController,
          focusNode: _memoryFocusNode,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 30, end: 0);
  }

  Widget _buildEmotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como você se sente sobre essa lembrança?',
          style: TherapeuticStyles.dashboardSection,
        ),
        const SizedBox(height: 16),
        EmotionSelector(
          emotions: _emotions,
          selectedEmotions: _selectedEmotions,
          onEmotionsChanged: (emotions) {
            setState(() {
              _selectedEmotions = emotions;
            });
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 30, end: 0);
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Intensidade Emocional',
              style: TherapeuticStyles.dashboardSection,
            ),
            Text(
              '${(_emotionalIntensity * 10).round()}/10',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _emotionalIntensity,
            onChanged: (value) {
              setState(() {
                _emotionalIntensity = value;
              });
            },
            divisions: 10,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leve',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Intensa',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 30, end: 0);
  }

  Widget _buildAnalyzeButton() {
    final memoryText = _memoryController.text.trim();
    final canAnalyze = memoryText.length >= 10; // Reduzido de 20 para 10 caracteres
    
    return CalmButton(
      onPressed: canAnalyze ? _analyzeMemory : null,
      isLoading: _isAnalyzing,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            'Analisar com IA',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 30, end: 0);
  }

  void _analyzeMemory() async {
    final memoryText = _memoryController.text.trim();
    
    print('🔍 [DEBUG] Iniciando análise da lembrança...');
    print('📝 [DEBUG] Texto da lembrança: "${memoryText.substring(0, memoryText.length > 50 ? 50 : memoryText.length)}..."');
    print('😊 [DEBUG] Emoções selecionadas: $_selectedEmotions');
    print('📊 [DEBUG] Intensidade emocional: $_emotionalIntensity');
    print('🎯 [DEBUG] Tipo de análise: ${AnalysisType.complete}');
    
    if (!mounted) {
      print('❌ [DEBUG] Widget não montado, cancelando análise');
      return;
    }
    
    // Validação adicional
    if (memoryText.length < 10) {
      print('❌ [DEBUG] Texto muito curto: ${memoryText.length} caracteres');
      _showErrorDialog(Exception('Texto muito curto para análise. Mínimo: 10 caracteres.'));
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      print('🚀 [DEBUG] Chamando AIAnalysisService...');
      print('🔗 [DEBUG] URL da API: ${_analysisService.toString()}');
      
      // Validar primeiro para mostrar avisos se necessário
      final validation = FreudianPrompts.validateMemoryText(memoryText);
      if (validation.isSensitiveContent && validation.message != null) {
        // Mostrar aviso sobre conteúdo sensível antes de continuar
        final shouldContinue = await _showSensitiveContentWarning(validation.message!);
        if (!shouldContinue) {
          setState(() {
            _isAnalyzing = false;
          });
          return;
        }
      }
      
      // Fazer análise real com NVIDIA API
      final result = await _analysisService.analyzeMemory(
        memoryText: memoryText,
        emotions: _selectedEmotions,
        emotionalIntensity: _emotionalIntensity,
        analysisType: AnalysisType.complete,
      );
      
      if (!mounted) {
        print('❌ [DEBUG] Widget desmontado durante a análise');
        return;
      }
      
      print('✅ [DEBUG] Análise concluída com sucesso!');
      print('🔢 [DEBUG] Tokens usados: ${result.tokenUsage.totalTokens}');
      print('🤖 [DEBUG] Modelo usado: ${result.modelUsed}');
      print('📄 [DEBUG] Tamanho da análise: ${result.analysisText.length} caracteres');
      
      setState(() {
        _isAnalyzing = false;
        _lastAnalysisResult = result;
      });
      
      // Mostrar resultado da análise
      _showAnalysisResult();
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Erro na análise: $e');
      print('📋 [DEBUG] Stack trace: $stackTrace');
      
      if (!mounted) {
        print('❌ [DEBUG] Widget desmontado durante tratamento de erro');
        return;
      }
      
      setState(() {
        _isAnalyzing = false;
      });
      
      // Mostrar erro
      _showErrorDialog(e);
    }
  }

  void _showAnalysisResult() {
    print('📱 Mostrando modal de resultado...');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalysisModal(),
    );
  }
  
  Future<bool> _showSensitiveContentWarning(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_outlined, color: AppColors.warning ?? Colors.orange),
            const SizedBox(width: 8),
            const Text('Conteúdo Sensível'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'Deseja continuar com a análise?',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorDialog(Object error) {
    String errorMessage = 'Não foi possível analisar a lembrança no momento. Tente novamente mais tarde.';
    
    if (error is AnalysisException) {
      errorMessage = error.message;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Erro na Análise'),
          ],
        ),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Análise Psicanalítica',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Conteúdo da análise real da API
          Expanded(
            child: SingleChildScrollView(
              child: _lastAnalysisResult != null 
                ? _buildRealAnalysisContent(_lastAnalysisResult!)
                : _buildLoadingContent(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botão para fechar
          SizedBox(
            width: double.infinity,
            child: CalmButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealAnalysisContent(AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Análise principal da IA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Análise da IA (${result.modelUsed})',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.analysisText,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        
        if (result.insights.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAnalysisSection(
            '🔍 Principais Insights',
            result.insights,
          ),
        ],
        
        if (result.screenMemoryIndicators.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAnalysisSection(
            '🎭 Indicadores de Lembrança Encobridora',
            result.screenMemoryIndicators,
          ),
        ],
        
        if (result.defenseMechanisms.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAnalysisSection(
            '🛡️ Mecanismos de Defesa Identificados',
            result.defenseMechanisms,
          ),
        ],
        
        if (result.therapeuticSuggestions.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAnalysisSection(
            '💡 Sugestões para Exploração Terapêutica',
            result.therapeuticSuggestions,
          ),
        ],
        
        const SizedBox(height: 20),
        
        // Informações técnicas
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tokens usados: ${result.tokenUsage.totalTokens}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Tipo: ${result.analysisType.displayName}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Nota importante
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nota Importante',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Esta análise é uma ferramenta de apoio ao processo terapêutico. '
                'Sempre discuta os insights com seu psicanalista para uma '
                'compreensão mais profunda.',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Analisando sua lembrança...',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Sobre o PsychoAI'),
          ],
        ),
        content: Text(
          'Este app utiliza princípios da psicanálise freudiana para analisar suas lembranças. '
          'A IA identifica possíveis "lembranças encobridoras" e padrões psicológicos para '
          'auxiliar no processo de autoconhecimento.',
          style: AppTypography.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memoryController.dispose();
    _memoryFocusNode.dispose();
    _analysisService.dispose();
    super.dispose();
  }
}
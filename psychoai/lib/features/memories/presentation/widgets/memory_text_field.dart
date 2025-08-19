import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Campo de texto especializado para registro de lembranças
/// Simula um "divã digital" para livre associação
class MemoryTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final String? hintText;

  const MemoryTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.minLines = 8,
    this.maxLines = 20,
    this.hintText,
  });

  @override
  State<MemoryTextField> createState() => _MemoryTextFieldState();
}

class _MemoryTextFieldState extends State<MemoryTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  bool _isFocused = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
    _characterCount = widget.controller.text.length;
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    setState(() {
      _characterCount = widget.controller.text.length;
    });
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _borderColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _borderColorAnimation.value!,
                  width: _isFocused ? 2 : 1,
                ),
                color: AppColors.surface,
                boxShadow: _isFocused
                    ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com ícone e orientação
                    if (_isFocused || widget.controller.text.isEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Escreva livremente...',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Campo de texto principal
                    TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      style: TherapeuticStyles.memoryText,
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? _getRandomHint(),
                        hintStyle: TherapeuticStyles.placeholder,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      minLines: widget.minLines,
                      maxLines: widget.maxLines,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Footer com informações e contador
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Dicas de uso
            if (_isFocused && _characterCount < 50) ...[
              Expanded(
                child: Text(
                  '💡 Não se preocupe com gramática. Apenas expresse seus pensamentos.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 10, end: 0),
              ),
            ] else
              if (_characterCount >= 50) ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ótimo! Continue expressando seus pensamentos.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            // Contador de caracteres
            _buildCharacterCounter(),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacterCounter() {
    Color counterColor;
    if (_characterCount < 20) {
      counterColor = AppColors.onSurfaceVariant;
    } else if (_characterCount < 100) {
      counterColor = AppColors.warning;
    } else {
      counterColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: counterColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_characterCount chars',
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: counterColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getRandomHint() {
    final hints = [
      'Uma lembrança que me vem à mente é...',
      'Lembro-me de quando...',
      'Algo que sempre me marca é...',
      'Tenho uma vaga lembrança de...',
      'Uma situação que me afetou foi...',
      'Costumo pensar sobre...',
      'Uma experiência marcante foi...',
      'Algo que me incomoda é...',
      'Me lembro claramente de...',
      'Sempre que penso nisso...',
    ];

    return hints[(DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000) % hints.length];
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    _animationController.dispose();
    super.dispose();
  }
}

/// Widget para mostrar estatísticas do texto
class MemoryStats extends StatelessWidget {
  final String text;

  const MemoryStats({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats(text);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Palavras',
            stats.wordCount.toString(),
            Icons.text_fields_outlined,
          ),
          _buildStatItem(
            'Frases',
            stats.sentenceCount.toString(),
            Icons.format_list_numbered_outlined,
          ),
          _buildStatItem(
            'Tempo',
            '${stats.estimatedReadingTime}min',
            Icons.schedule_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TherapeuticStyles.statistic.copyWith(
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  TextStats _calculateStats(String text) {
    if (text
        .trim()
        .isEmpty) {
      return TextStats(wordCount: 0, sentenceCount: 0, estimatedReadingTime: 0);
    }

    // Contar palavras
    final words = text.trim().split(RegExp(r'\s+'));
    final wordCount = words
        .where((word) => word.isNotEmpty)
        .length;

    // Contar frases (aproximadamente)
    final sentences = text.split(RegExp(r'[.!?]+'));
    final sentenceCount = sentences
        .where((s) =>
    s
        .trim()
        .isNotEmpty)
        .length;

    // Tempo estimado de leitura (200 palavras por minuto)
    final estimatedReadingTime = (wordCount / 200).ceil();

    return TextStats(
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      estimatedReadingTime: estimatedReadingTime,
    );
  }
}

/// Classe para estatísticas do texto
class TextStats {
  final int wordCount;
  final int sentenceCount;
  final int estimatedReadingTime;

  TextStats({
    required this.wordCount,
    required this.sentenceCount,
    required this.estimatedReadingTime,
  });
}

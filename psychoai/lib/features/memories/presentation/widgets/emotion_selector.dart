import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget para seleção de emoções associadas à lembrança
class EmotionSelector extends StatelessWidget {
  final List<EmotionItem> emotions;
  final List<String> selectedEmotions;
  final ValueChanged<List<String>> onEmotionsChanged;
  final int maxSelections;

  const EmotionSelector({
    super.key,
    required this.emotions,
    required this.selectedEmotions,
    required this.onEmotionsChanged,
    this.maxSelections = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedEmotions.isNotEmpty) ...[
          Text(
            'Selecionadas (${selectedEmotions.length}/$maxSelections):',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emotions.asMap().entries.map((entry) {
            final index = entry.key;
            final emotion = entry.value;
            final isSelected = selectedEmotions.contains(emotion.name);
            
            return _buildEmotionChip(emotion, isSelected, index);
          }).toList(),
        ),
        
        if (selectedEmotions.length >= maxSelections) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Máximo de $maxSelections emoções. Desmarque uma para selecionar outra.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmotionChip(EmotionItem emotion, bool isSelected, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emotion.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              emotion.name,
              style: AppTypography.TherapeuticStyles.emotionLabel.copyWith(
                color: isSelected 
                    ? AppColors.onPrimary 
                    : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          _handleEmotionSelection(emotion.name, selected);
        },
        backgroundColor: emotion.color.withOpacity(0.1),
        selectedColor: emotion.color.withOpacity(0.8),
        checkmarkColor: AppColors.onPrimary,
        side: BorderSide(
          color: emotion.color.withOpacity(isSelected ? 0.8 : 0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: emotion.color.withOpacity(0.3),
      )
          .animate()
          .fadeIn(delay: (index * 100).ms, duration: 400.ms)
          .slideX(begin: -20, end: 0),
    );
  }

  void _handleEmotionSelection(String emotionName, bool selected) {
    List<String> newSelection = List.from(selectedEmotions);
    
    if (selected) {
      if (newSelection.length < maxSelections) {
        newSelection.add(emotionName);
      }
    } else {
      newSelection.remove(emotionName);
    }
    
    onEmotionsChanged(newSelection);
  }
}

/// Modelo para representar uma emoção
class EmotionItem {
  final String name;
  final String emoji;
  final Color color;

  EmotionItem(this.name, this.emoji, this.color);
}

/// Widget para mostrar as emoções selecionadas em formato compacto
class SelectedEmotionsDisplay extends StatelessWidget {
  final List<String> selectedEmotions;
  final List<EmotionItem> allEmotions;
  final VoidCallback? onTap;

  const SelectedEmotionsDisplay({
    super.key,
    required this.selectedEmotions,
    required this.allEmotions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedEmotions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.onSurfaceVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Toque para selecionar emoções',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                children: selectedEmotions.map((emotionName) {
                  final emotion = allEmotions.firstWhere(
                    (e) => e.name == emotionName,
                    orElse: () => EmotionItem(emotionName, '❓', AppColors.accent),
                  );
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: emotion.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emotion.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          emotion.name,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: emotion.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
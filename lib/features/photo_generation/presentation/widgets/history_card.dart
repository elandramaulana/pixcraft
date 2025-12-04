import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_history_model.dart';
import 'package:pixcraft/features/photo_generation/presentation/screens/generation_detail_screen.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../core/constants/layout_constants.dart';

class HistoryCard extends StatelessWidget {
  final GenerationHistoryModel generation;

  const HistoryCard({super.key, required this.generation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GenerationDetailScreen(generation: generation),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Grid Preview
            _buildImageGrid(),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(LayoutConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge & Date
                  Row(
                    children: [
                      _buildStatusBadge(),
                      const Spacer(),
                      Text(
                        _formatDate(generation.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: LayoutConstants.spacing8),

                  // Variation Count
                  Text(
                    '${generation.generatedImages.length} variations generated',
                    style: AppTextStyles.bodyMedium,
                  ),

                  // Variation Types
                  if (generation.variationTypes.isNotEmpty) ...[
                    const SizedBox(height: LayoutConstants.spacing8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: generation.variationTypes
                          .take(3)
                          .map((type) => _buildTypeChip(type))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (generation.generatedImages.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(LayoutConstants.radiusMedium),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'No images',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayImages = generation.generatedImages.take(4).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(LayoutConstants.radiusMedium),
      ),
      child: SizedBox(
        height: 200,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: displayImages.length,
          itemBuilder: (context, index) {
            return Image.network(
              displayImages[index].imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.background,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (generation.status) {
      case 'completed':
        color = AppColors.success;
        text = 'Completed';
        icon = Icons.check_circle_rounded;
        break;
      case 'processing':
        color = AppColors.warning;
        text = 'Processing';
        icon = Icons.hourglass_bottom_rounded;
        break;
      case 'failed':
        color = AppColors.error;
        text = 'Failed';
        icon = Icons.error_rounded;
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        type,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

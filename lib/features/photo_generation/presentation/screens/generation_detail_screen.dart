import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_history_model.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../core/constants/layout_constants.dart';
import '../providers/generation_history_provider.dart';
import '../widgets/image_preview.dart';
import '../widgets/generated_image_grid.dart';

class GenerationDetailScreen extends ConsumerWidget {
  final GenerationHistoryModel generation;

  const GenerationDetailScreen({super.key, required this.generation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Actions
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
                const SizedBox(width: 8),
              ],
              title: Text(
                'Generation Details',
                style: AppTextStyles.titleLarge,
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(LayoutConstants.paddingHorizontal),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Status & Date Info
                  _buildInfoCard(),

                  const SizedBox(height: LayoutConstants.spacing24),

                  // Original Image
                  Text(
                    'Original Photo',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spacing12),
                  ImagePreview(
                    imageUrl: generation.originalImage.url,
                    height: 250,
                  ),

                  const SizedBox(height: LayoutConstants.spacing32),

                  // Generated Images
                  if (generation.hasGeneratedImages) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Generated', style: AppTextStyles.titleLarge),
                        Text(
                          '${generation.generatedImages.length} variations',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: LayoutConstants.spacing16),
                    GeneratedImagesGrid(images: generation.generatedImages),
                  ] else ...[
                    _buildNoImagesState(),
                  ],

                  const SizedBox(height: LayoutConstants.spacing32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(LayoutConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            children: [
              Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
              const SizedBox(width: 8),
              Text(
                'Status: ${generation.status.toUpperCase()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: LayoutConstants.spacing12),

          // Creation Date
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Created',
            DateFormat('MMM d, yyyy • HH:mm').format(generation.createdAt),
          ),

          if (generation.completedAt != null) ...[
            const SizedBox(height: LayoutConstants.spacing8),
            _buildInfoRow(
              Icons.check_circle_outline_rounded,
              'Completed',
              DateFormat('MMM d, yyyy • HH:mm').format(generation.completedAt!),
            ),
          ],

          // Variation Types
          if (generation.variationTypes.isNotEmpty) ...[
            const SizedBox(height: LayoutConstants.spacing12),
            const Divider(),
            const SizedBox(height: LayoutConstants.spacing12),
            Text(
              'Variation Types',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: LayoutConstants.spacing8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: generation.variationTypes
                  .map((type) => _buildTypeChip(type))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        type,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoImagesState() {
    return Container(
      padding: const EdgeInsets.all(LayoutConstants.spacing32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        border: Border.all(color: AppColors.primary),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: LayoutConstants.spacing16),
            Text(
              'No generated images',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (generation.status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (generation.status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'processing':
        return Icons.hourglass_bottom_rounded;
      case 'failed':
        return Icons.error_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Generation'),
        content: const Text(
          'Are you sure you want to delete this generation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final deleteAction = ref.read(deleteGenerationProvider);
      final success = await deleteAction(generation.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generation deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete generation'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import 'package:pixcraft/core/extensions/context_extension.dart';
import 'package:pixcraft/features/photo_generation/presentation/widgets/generated_image_grid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/photo_generation_state.dart';
import '../providers/photo_generation_provider.dart';
import '../widgets/empty_state_section.dart';
import '../widgets/generation_button.dart';
import '../widgets/generation_loading.dart';
import '../widgets/generation_error.dart';
import '../widgets/image_preview.dart';
import '../widgets/upload_section.dart';

class PhotoGenerationScreen extends ConsumerWidget {
  const PhotoGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoGenerationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  expandedHeight: 80,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: LayoutConstants.paddingHorizontal,
                      vertical: 16,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Pixcraft',
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          'AI-Powered Photo Magic',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(
                    LayoutConstants.paddingHorizontal,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _buildContent(context, ref, state),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (state.isLoading)
              GenerationLoading(
                progress: state.progress,
                message: state.currentStep,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PhotoGenerationState state,
  ) {
    // Error State
    if (state.isError) {
      return GenerationError(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: () => ref.read(photoGenerationProvider.notifier).retry(),
      );
    }

    // Completed State - Show Results
    if (state.isCompleted && state.hasGeneratedImages) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Image Preview
          if (state.uploadedImageUrl != null) ...[
            Text(
              'Original Photo',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: LayoutConstants.spacing12),
            ImagePreview(imageUrl: state.uploadedImageUrl!, height: 200),
            const SizedBox(height: LayoutConstants.spacing32),
          ],

          // Generated Images Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI Generated', style: AppTextStyles.titleLarge),
              Text(
                '${state.generatedImages.length} variations',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: LayoutConstants.spacing16),

          GeneratedImagesGrid(images: state.generatedImages),

          const SizedBox(height: LayoutConstants.spacing32),

          // Generate New Button
          GenerationButton(
            text: 'Generate New',
            icon: Icons.refresh_rounded,
            onPressed: () {
              ref.read(photoGenerationProvider.notifier).reset();
            },
            type: GenerationButtonType.secondary,
          ),

          const SizedBox(height: LayoutConstants.spacing24),
        ],
      );
    }

    // Preview State - Show selected image with generate button
    if (state.hasSelectedImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Photo',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: LayoutConstants.spacing12),

          ImagePreview(
            imageFile: state.selectedImage,
            height: context.screenHeight * 0.5,
            onRemove: () {
              ref.read(photoGenerationProvider.notifier).setSelectedImage(null);
            },
          ),

          const SizedBox(height: LayoutConstants.spacing32),

          // Generate Button
          GenerationButton(
            text: 'Generate AI Variations',
            icon: Icons.auto_awesome_rounded,
            onPressed: () {
              ref.read(photoGenerationProvider.notifier).uploadAndGenerate();
            },
          ),

          const SizedBox(height: LayoutConstants.spacing16),

          // Info Text
          Container(
            padding: const EdgeInsets.all(LayoutConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: LayoutConstants.spacing12),
                Expanded(
                  child: Text(
                    'We\'ll create 4 amazing variations in different scenes!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Empty State - No image selected
    return Column(
      children: [
        const SizedBox(height: LayoutConstants.spacing24),
        const EmptyStateSection(),
        const SizedBox(height: LayoutConstants.spacing32),
        const UploadSection(),
      ],
    );
  }
}

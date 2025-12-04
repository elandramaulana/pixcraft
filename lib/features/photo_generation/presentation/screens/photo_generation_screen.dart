import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/core/extensions/context_extension.dart';
import 'package:pixcraft/features/photo_generation/presentation/widgets/generated_image_grid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/photo_generation_state.dart';
import '../providers/photo_generation_provider.dart';
import '../widgets/generation_loading.dart';
import '../widgets/generation_error.dart';
import '../widgets/image_preview.dart';
import '../widgets/upload_section.dart';
import 'generation_history_screen.dart';

class PhotoGenerationScreen extends ConsumerWidget {
  const PhotoGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoGenerationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern Minimal App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // App Title
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Pixcraft',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'AI Photo Studio',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            // History Button
                            _buildHistoryButton(context),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _buildContent(context, ref, state),
                  ),
                ),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),

          // Loading Overlay
          if (state.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: GenerationLoading(
                    progress: state.progress,
                    message: state.currentStep,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GenerationHistoryScreen()),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.history_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PhotoGenerationState state,
  ) {
    if (state.isError) {
      return _buildErrorState(ref, state);
    }

    if (state.isCompleted && state.hasGeneratedImages) {
      return _buildCompletedState(context, ref, state);
    }

    if (state.hasSelectedImage) {
      return _buildPreviewState(context, ref, state);
    }

    return _buildEmptyState(context);
  }

  Widget _buildErrorState(WidgetRef ref, PhotoGenerationState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: GenerationError(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: () => ref.read(photoGenerationProvider.notifier).retry(),
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    WidgetRef ref,
    PhotoGenerationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original Image
        if (state.uploadedImageUrl != null) ...[
          _buildLabel('Original'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ImagePreview(imageUrl: state.uploadedImageUrl!, height: 200),
          ),
          const SizedBox(height: 32),
        ],

        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Generated',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${state.generatedImages.length} variations',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Generated Images Grid
        GeneratedImagesGrid(images: state.generatedImages),

        const SizedBox(height: 24),

        // Action Buttons
        _buildActionButton(
          onTap: () => ref.read(photoGenerationProvider.notifier).reset(),
          icon: Icons.refresh_rounded,
          label: 'Generate New',
          isPrimary: true,
        ),

        const SizedBox(height: 12),

        _buildActionButton(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GenerationHistoryScreen(),
              ),
            );
          },
          icon: Icons.grid_view_rounded,
          label: 'View All History',
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildPreviewState(
    BuildContext context,
    WidgetRef ref,
    PhotoGenerationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Ready to Generate'),
        const SizedBox(height: 12),

        // Image Preview
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ImagePreview(
            imageFile: state.selectedImage,
            height: context.screenHeight * 0.48,
            onRemove: () {
              ref.read(photoGenerationProvider.notifier).setSelectedImage(null);
            },
          ),
        ),

        const SizedBox(height: 24),

        // Info Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'We\'ll create 4 stunning variations',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Generate Button
        _buildActionButton(
          onTap: () {
            ref.read(photoGenerationProvider.notifier).uploadAndGenerate();
          },
          icon: Icons.auto_awesome_rounded,
          label: 'Generate AI Variations',
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const SizedBox(height: 28),
        const UploadSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.85),
                    ],
                  )
                : null,
            color: isPrimary ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

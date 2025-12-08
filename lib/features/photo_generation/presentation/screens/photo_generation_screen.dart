import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/core/extensions/context_extension.dart';
import 'package:pixcraft/features/photo_generation/presentation/providers/image_picker_provider.dart';
import 'package:pixcraft/features/photo_generation/presentation/widgets/generated_image_grid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/photo_generation_state.dart';
import '../providers/photo_generation_provider.dart';
import '../widgets/generation_loading.dart';
import '../widgets/generation_error.dart';
import '../widgets/image_preview.dart';
import '../widgets/scene_selector.dart';
import 'generation_history_screen.dart';

class PhotoGenerationScreen extends ConsumerStatefulWidget {
  const PhotoGenerationScreen({super.key});

  @override
  ConsumerState<PhotoGenerationScreen> createState() =>
      _PhotoGenerationScreenState();
}

class _PhotoGenerationScreenState extends ConsumerState<PhotoGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoGenerationProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.primary.withOpacity(0.02),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Elegant Header
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: _buildHeader(context),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                  sliver: SliverToBoxAdapter(
                    child: _buildContent(context, ref, state),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay with Glassmorphism
          if (state.isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pixcraft',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI Photo Studio',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: Icons.history_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const GenerationHistoryScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0.0, 0.05),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
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
      return _buildSceneSelectionState(context, ref, state);
    }

    return _buildEmptyState(context, ref);
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
        if (state.uploadedImageUrl != null) ...[
          _buildSectionTitle('Original Photo'),
          const SizedBox(height: 12),
          Hero(
            tag: 'original_image',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ImagePreview(
                imageUrl: state.uploadedImageUrl!,
                height: 200,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        _buildResultsHeader(state.generatedImages.length),
        const SizedBox(height: 16),

        GeneratedImagesGrid(images: state.generatedImages),
        const SizedBox(height: 32),

        _buildPrimaryButton(
          label: 'Create Another',
          icon: Icons.add_photo_alternate_rounded,
          onTap: () => ref.read(photoGenerationProvider.notifier).reset(),
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          label: 'View History',
          icon: Icons.history_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GenerationHistoryScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSceneSelectionState(
    BuildContext context,
    WidgetRef ref,
    PhotoGenerationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Your Photo'),
        const SizedBox(height: 12),
        Hero(
          tag: 'selected_image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ImagePreview(
              imageFile: state.selectedImage,
              height: context.screenHeight * 0.35,
              onRemove: () {
                ref
                    .read(photoGenerationProvider.notifier)
                    .setSelectedImage(null);
              },
            ),
          ),
        ),
        const SizedBox(height: 32),

        _buildSectionTitle('Choose Your Scene'),
        const SizedBox(height: 16),

        SceneSelector(
          selectedScene: state.selectedScene,
          onSceneSelected: (scene) {
            ref.read(photoGenerationProvider.notifier).setSelectedScene(scene);
          },
        ),

        const SizedBox(height: 24),

        if (state.selectedScene != null) ...[
          _buildInfoCard(
            'We\'ll create 4 unique variations of your chosen scene',
            Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            label: 'Generate Photos',
            icon: Icons.auto_awesome_rounded,
            onTap: () {
              ref.read(photoGenerationProvider.notifier).uploadAndGenerate();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildUploadCard(context, ref),
        const SizedBox(height: 24),
        _buildFeatureHighlights(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generated',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count stunning variations',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.info, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
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
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            height: 58,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Creating',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your photo to begin',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildUploadOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    await ref
                        .read(imagePickerProvider.notifier)
                        .pickImageFromGallery();
                    final image = ref.read(imagePickerProvider);
                    if (image != null) {
                      ref
                          .read(photoGenerationProvider.notifier)
                          .setSelectedImage(image);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUploadOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    await ref
                        .read(imagePickerProvider.notifier)
                        .pickImageFromCamera();
                    final image = ref.read(imagePickerProvider);
                    if (image != null) {
                      ref
                          .read(photoGenerationProvider.notifier)
                          .setSelectedImage(image);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {'icon': Icons.auto_awesome, 'text': 'AI Powered'},
      {'icon': Icons.flash_on, 'text': 'Instant'},
      {'icon': Icons.hd, 'text': 'HD Quality'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feature['icon'] as IconData,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                feature['text'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

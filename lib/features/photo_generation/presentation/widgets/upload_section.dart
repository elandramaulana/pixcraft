import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../providers/image_picker_provider.dart';
import '../providers/photo_generation_provider.dart';

class UploadSection extends ConsumerWidget {
  const UploadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(LayoutConstants.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(5),
            AppColors.primary.withAlpha(2),
          ],
        ),
        borderRadius: BorderRadius.circular(LayoutConstants.radiusXLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: LayoutConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Your Image',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how you want to add your photo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: LayoutConstants.spacing24),

          // Upload Options
          Row(
            children: [
              // Gallery Card
              Expanded(
                child: _ModernUploadCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  description: 'Choose from photos',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 1.8),
                    ],
                  ),
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

              const SizedBox(width: LayoutConstants.spacing16),

              // Camera Card
              Expanded(
                child: _ModernUploadCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  description: 'Take a photo',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 1.8),
                    ],
                  ),
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

          const SizedBox(height: LayoutConstants.spacing16),

          // Info Text
          Container(
            padding: const EdgeInsets.all(LayoutConstants.spacing12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(1),
              borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Supported formats: JPG, PNG • Max size: 10MB',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernUploadCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernUploadCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModernUploadCard> createState() => _ModernUploadCardState();
}

class _ModernUploadCardState extends State<_ModernUploadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withAlpha(2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.spacing16,
                  vertical: LayoutConstants.spacing20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: LayoutConstants.spacing12),
                    Text(
                      widget.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

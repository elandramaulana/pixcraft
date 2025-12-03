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
    return Column(
      children: [
        // Gallery Button
        _UploadButton(
          icon: Icons.photo_library_rounded,
          label: 'Choose from Gallery',
          onTap: () async {
            await ref.read(imagePickerProvider.notifier).pickImageFromGallery();
            final image = ref.read(imagePickerProvider);
            if (image != null) {
              ref
                  .read(photoGenerationProvider.notifier)
                  .setSelectedImage(image);
            }
          },
        ),

        const SizedBox(height: LayoutConstants.spacing16),

        // Camera Button
        _UploadButton(
          icon: Icons.camera_alt_rounded,
          label: 'Take a Photo',
          onTap: () async {
            await ref.read(imagePickerProvider.notifier).pickImageFromCamera();
            final image = ref.read(imagePickerProvider);
            if (image != null) {
              ref
                  .read(photoGenerationProvider.notifier)
                  .setSelectedImage(image);
            }
          },
          isPrimary: false,
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.spacing24,
            vertical: LayoutConstants.spacing20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: LayoutConstants.spacing12),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

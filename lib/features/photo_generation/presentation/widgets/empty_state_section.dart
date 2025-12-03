import 'package:flutter/material.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';

class EmptyStateSection extends StatelessWidget {
  const EmptyStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LayoutConstants.spacing40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusXLarge),
        border: Border.all(color: AppColors.surfaceVariant, width: 2),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: LayoutConstants.spacing24),

          // Title
          Text(
            'Create AI Photo Magic',
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: LayoutConstants.spacing8),

          // Subtitle
          Text(
            'Upload a photo and watch AI transform it into\namazing Instagram-worthy scenes',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: LayoutConstants.spacing24),

          // Features
          _buildFeature(icon: Icons.beach_access_rounded, text: 'Beach Scenes'),
          const SizedBox(height: LayoutConstants.spacing12),
          _buildFeature(
            icon: Icons.location_city_rounded,
            text: 'City Adventures',
          ),
          const SizedBox(height: LayoutConstants.spacing12),
          _buildFeature(icon: Icons.terrain_rounded, text: 'Mountain Views'),
          const SizedBox(height: LayoutConstants.spacing12),
          _buildFeature(icon: Icons.coffee_rounded, text: 'Cafe Moments'),
        ],
      ),
    );
  }

  Widget _buildFeature({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: LayoutConstants.spacing8),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

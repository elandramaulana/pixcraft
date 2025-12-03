import 'package:flutter/material.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../app/theme/app_colors.dart';
import '../constants/layout_constants.dart';
import 'app_button.dart';

class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppError({super.key, required this.message, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: LayoutConstants.spacing24),
            Text('Oops!', style: AppTextStyles.titleLarge),
            const SizedBox(height: LayoutConstants.spacing8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: LayoutConstants.spacing32),
              AppButton(
                text: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';

enum GenerationButtonType { primary, secondary }

class GenerationButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GenerationButtonType type;
  final bool isLoading;

  const GenerationButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.type = GenerationButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == GenerationButtonType.primary;

    return Material(
      color: isPrimary ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
      elevation: 0,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
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
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary ? Colors.white : AppColors.primary,
                    ),
                  ),
                )
              else ...[
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isPrimary ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: LayoutConstants.spacing12),
                ],
                Text(
                  text,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

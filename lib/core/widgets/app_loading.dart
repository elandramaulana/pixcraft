import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../app/theme/app_colors.dart';
import '../constants/layout_constants.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double? progress;

  const AppLoading({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null) ...[
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SpinKitPulse(color: AppColors.primary, size: 60.0),
          ],
          if (message != null) ...[
            const SizedBox(height: LayoutConstants.spacing24),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Full Screen Loading Overlay
class AppLoadingOverlay extends StatelessWidget {
  final String? message;
  final double? progress;

  const AppLoadingOverlay({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlay,
      child: AppLoading(message: message, progress: progress),
    );
  }
}

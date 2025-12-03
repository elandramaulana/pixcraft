import 'package:flutter/material.dart';
import '../../../../core/widgets/app_error.dart';

class GenerationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const GenerationError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppError(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off_rounded,
    );
  }
}

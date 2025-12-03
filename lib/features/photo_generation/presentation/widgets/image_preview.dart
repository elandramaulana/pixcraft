import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final double? height;
  final VoidCallback? onRemove;

  const ImagePreview({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.height,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          if (imageFile != null)
            Image.file(imageFile!, fit: BoxFit.cover)
          else if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const ShimmerLoading(),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
            ),

          // Gradient Overlay (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),

          // Remove Button
          if (onRemove != null)
            Positioned(
              top: LayoutConstants.spacing12,
              right: LayoutConstants.spacing12,
              child: Material(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                elevation: 4,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

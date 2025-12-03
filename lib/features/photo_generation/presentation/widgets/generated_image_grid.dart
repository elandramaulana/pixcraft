import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import 'package:pixcraft/core/extensions/context_extension.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/generated_image_model.dart';
import '../providers/download_provider.dart';

class GeneratedImagesGrid extends StatelessWidget {
  final List<GeneratedImageModel> images;

  const GeneratedImagesGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        crossAxisSpacing: LayoutConstants.gridSpacing,
        mainAxisSpacing: LayoutConstants.gridSpacing,
        childAspectRatio: LayoutConstants.gridChildAspectRatio,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GeneratedImageCard(image: images[index]);
      },
    );
  }
}

class GeneratedImageCard extends ConsumerWidget {
  final GeneratedImageModel image;

  const GeneratedImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDownloading = ref.watch(
      downloadProvider.select((state) => state[image.imageUrl] ?? false),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerLoading(),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Download Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: InkWell(
                      onTap: isDownloading
                          ? null
                          : () async {
                              final success = await ref
                                  .read(downloadProvider.notifier)
                                  .downloadImage(
                                    imageUrl: image.imageUrl,
                                    fileName:
                                        '${image.type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                  );

                              if (context.mounted) {
                                context.showSnackBar(
                                  success
                                      ? 'Image saved to gallery!'
                                      : 'Failed to save image',
                                  isError: !success,
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.download_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ),
                ),

                // Type Label
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      backgroundBlendMode: BlendMode.color,
                    ),
                    child: Text(
                      image.type.variationLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

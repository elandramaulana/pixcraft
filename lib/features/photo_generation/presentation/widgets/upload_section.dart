import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../providers/image_picker_provider.dart';
import '../providers/photo_generation_provider.dart';

class UploadSection extends ConsumerStatefulWidget {
  const UploadSection({super.key});

  @override
  ConsumerState<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends ConsumerState<UploadSection>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Section with Floating Animation
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.02),
                  Colors.purple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Animated Icon with Pulse
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              Colors.purple.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.primary, Colors.purple.withOpacity(0.8)],
                  ).createShader(bounds),
                  child: const Text(
                    'Create Magic',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Upload your photo to start the transformation',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Upload Options with Modern Cards - Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isDesktop = constraints.maxWidth >= 1024;

            if (isDesktop) {
              // Desktop: 2 cards side by side with max width
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModernUploadCard(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          description: 'Choose from library',
                          primaryColor: AppColors.primary,
                          secondaryColor: Colors.purple,
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ModernUploadCard(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          description: 'Take new photo',
                          primaryColor: Colors.blue,
                          secondaryColor: Colors.cyan,
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
                ),
              );
            }

            // Mobile & Tablet: Side by side
            return Row(
              children: [
                Expanded(
                  child: _ModernUploadCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    description: 'Choose from library',
                    primaryColor: AppColors.primary,
                    secondaryColor: Colors.purple,
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
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: _ModernUploadCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    description: 'Take new photo',
                    primaryColor: Colors.blue,
                    secondaryColor: Colors.cyan,
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
            );
          },
        ),

        const SizedBox(height: 20),

        // Features Info
        _buildFeatureChips(),

        const SizedBox(height: 16),

        // Format Info with Modern Style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'JPG, PNG • Up to 10MB',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChips() {
    final features = [
      {'icon': Icons.auto_awesome, 'text': 'AI Powered'},
      {'icon': Icons.flash_on, 'text': 'Instant'},
      {'icon': Icons.hd, 'text': 'HD Quality'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((feature) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
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
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                feature['text'] as String,
                style: TextStyle(
                  fontSize: 12,
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

class _ModernUploadCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _ModernUploadCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_ModernUploadCard> createState() => _ModernUploadCardState();
}

class _ModernUploadCardState extends State<_ModernUploadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 100), widget.onTap);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isPressed
                      ? widget.primaryColor.withOpacity(0.3)
                      : widget.primaryColor.withOpacity(0.15),
                  width: _isPressed ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 20 + _elevationAnimation.value,
                    offset: Offset(0, 4 + _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Gradient Background
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.primaryColor.withOpacity(0.15),
                              widget.secondaryColor.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.primaryColor.withOpacity(0.15),
                                    widget.secondaryColor.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.label,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

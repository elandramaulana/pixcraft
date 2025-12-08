import 'package:flutter/material.dart';
import 'package:pixcraft/features/photo_generation/data/models/scene_config.dart';
import '../../../../app/theme/app_colors.dart';

class SceneSelector extends StatefulWidget {
  final String? selectedScene;
  final Function(String) onSceneSelected;

  const SceneSelector({
    super.key,
    required this.selectedScene,
    required this.onSceneSelected,
  });

  @override
  State<SceneSelector> createState() => _SceneSelectorState();
}

class _SceneSelectorState extends State<SceneSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = SceneConfig.all
        .map(
          (config) => _SceneData(
            id: config.id,
            emoji: config.emoji,
            name: config.name,
            description: config.description,
            gradient: config.gradientColors,
          ),
        )
        .toList();

    // Get screen width untuk menentukan responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.3 : 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: scenes.length,
          itemBuilder: (context, index) {
            final scene = scenes[index];
            final isSelected = widget.selectedScene == scene.id;

            return _SceneCard(
              scene: scene,
              isSelected: isSelected,
              onTap: () {
                widget.onSceneSelected(scene.id);
                _controller.forward(from: 0);
              },
            );
          },
        );
      },
    );
  }
}

class _SceneData {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final List<Color> gradient;

  _SceneData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.gradient,
  });
}

class _SceneCard extends StatefulWidget {
  final _SceneData scene;
  final bool isSelected;
  final VoidCallback onTap;

  const _SceneCard({
    required this.scene,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<_SceneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
        Future.delayed(const Duration(milliseconds: 100), widget.onTap);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isSelected
                      ? widget.scene.gradient
                      : [
                          widget.scene.gradient[0].withOpacity(0.1),
                          widget.scene.gradient[1].withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.3)
                      : widget.scene.gradient[0].withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1.5,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.scene.gradient[0].withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Content dengan Flexible layout
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive font sizes
                          final emojiSize = constraints.maxWidth > 120
                              ? 28.0
                              : 24.0;
                          final nameSize = constraints.maxWidth > 120
                              ? 14.0
                              : 12.0;
                          final descSize = constraints.maxWidth > 120
                              ? 11.0
                              : 10.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Emoji
                              Text(
                                widget.scene.emoji,
                                style: TextStyle(fontSize: emojiSize),
                              ),
                              SizedBox(
                                height: constraints.maxHeight > 80 ? 8 : 4,
                              ),
                              // Name dengan overflow handling
                              Flexible(
                                child: Text(
                                  widget.scene.name,
                                  style: TextStyle(
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Description dengan overflow handling
                              Flexible(
                                child: Text(
                                  widget.scene.description,
                                  style: TextStyle(
                                    fontSize: descSize,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.9)
                                        : AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Check mark
                    if (widget.isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
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

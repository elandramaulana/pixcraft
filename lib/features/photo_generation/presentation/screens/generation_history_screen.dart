import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
import 'package:pixcraft/features/photo_generation/presentation/screens/photo_generation_screen.dart';
import 'package:pixcraft/features/photo_generation/presentation/widgets/history_card.dart';
import 'package:pixcraft/features/photo_generation/presentation/widgets/history_empty_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../providers/generation_history_provider.dart';

class GenerationHistoryScreen extends ConsumerWidget {
  const GenerationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(generationHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildbackButton(context),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.7),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Pixcraft',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI Photo Studio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Content
            historyAsync.when(
              data: (generations) {
                if (generations.isEmpty) {
                  return const SliverFillRemaining(child: HistoryEmptyState());
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(
                    LayoutConstants.paddingHorizontal,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final generation = generations[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: LayoutConstants.spacing16,
                        ),
                        child: HistoryCard(generation: generation),
                      );
                    }, childCount: generations.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: LayoutConstants.spacing16),
                      Text(
                        'Failed to load history',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: LayoutConstants.spacing8),
                      Text(
                        error.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildbackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PhotoGenerationScreen()),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}

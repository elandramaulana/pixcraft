import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/app/theme/app_text_style.dart';
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
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              expandedHeight: 80,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingHorizontal,
                  vertical: 16,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Generation History',
                      style: AppTextStyles.displayMedium.copyWith(fontSize: 24),
                    ),
                    Text(
                      'Your AI creations',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
}

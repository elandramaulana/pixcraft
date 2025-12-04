import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/features/photo_generation/data/datasources/datasource_provider.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_history_model.dart';
import 'package:pixcraft/services/firebase/firebase_provider.dart';
import '../../data/repositories/generation_history_repository.dart';

// Repository Provider
final generationHistoryRepositoryProvider =
    Provider<GenerationHistoryRepository>((ref) {
      final firestoreDatasource = ref.watch(firestoreDatasourceProvider);
      return GenerationHistoryRepositoryImpl(firestoreDatasource);
    });

// History Stream Provider
final generationHistoryProvider =
    StreamProvider.autoDispose<List<GenerationHistoryModel>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      final repository = ref.watch(generationHistoryRepositoryProvider);

      if (userId == null) {
        return Stream.value([]);
      }

      return repository.getUserHistory(userId);
    });

// Completed History Provider
final completedHistoryProvider =
    StreamProvider.autoDispose<List<GenerationHistoryModel>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      final repository = ref.watch(generationHistoryRepositoryProvider);

      if (userId == null) {
        return Stream.value([]);
      }

      return repository.getCompletedHistory(userId);
    });

// Single Generation Provider
final singleGenerationProvider = FutureProvider.autoDispose
    .family<GenerationHistoryModel?, String>((ref, generationId) async {
      final repository = ref.watch(generationHistoryRepositoryProvider);
      return await repository.getGenerationById(generationId);
    });

// Delete Generation Action
final deleteGenerationProvider =
    Provider.autoDispose<Future<bool> Function(String)>((ref) {
      final repository = ref.watch(generationHistoryRepositoryProvider);

      return (String generationId) async {
        try {
          await repository.deleteGeneration(generationId);
          return true;
        } catch (e) {
          return false;
        }
      };
    });

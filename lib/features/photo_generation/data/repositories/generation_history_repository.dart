import 'package:pixcraft/features/photo_generation/data/models/generated_history_model.dart';
import '../../../../core/utils/logger.dart';
import '../datasources/firestore_datasource.dart';

abstract class GenerationHistoryRepository {
  Stream<List<GenerationHistoryModel>> getUserHistory(String userId);
  Stream<List<GenerationHistoryModel>> getCompletedHistory(String userId);
  Future<GenerationHistoryModel?> getGenerationById(String generationId);
  Future<void> deleteGeneration(String generationId);
}

class GenerationHistoryRepositoryImpl implements GenerationHistoryRepository {
  final FirestoreDatasource _firestoreDatasource;

  GenerationHistoryRepositoryImpl(this._firestoreDatasource);

  @override
  Stream<List<GenerationHistoryModel>> getUserHistory(String userId) {
    try {
      Logger.info('Repository: Getting user history for user $userId');
      return _firestoreDatasource.getUserGenerationHistory(userId);
    } catch (e) {
      Logger.error('Repository: Get user history failed', e);
      rethrow;
    }
  }

  @override
  Stream<List<GenerationHistoryModel>> getCompletedHistory(String userId) {
    try {
      Logger.info('Repository: Getting completed history for user $userId');
      return _firestoreDatasource.getUserCompletedGenerations(userId);
    } catch (e) {
      Logger.error('Repository: Get completed history failed', e);
      rethrow;
    }
  }

  @override
  Future<GenerationHistoryModel?> getGenerationById(String generationId) async {
    try {
      Logger.info('Repository: Getting generation by ID $generationId');
      final generation = await _firestoreDatasource.getGenerationById(
        generationId,
      );

      if (generation == null) {
        Logger.warning(
          'Repository: Generation not found with ID $generationId',
        );
      }

      return generation;
    } catch (e) {
      Logger.error('Repository: Get generation by ID failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteGeneration(String generationId) async {
    try {
      Logger.info('Repository: Deleting generation $generationId');
      await _firestoreDatasource.deleteGeneration(generationId);
      Logger.info('Repository: Generation deleted successfully');
    } catch (e) {
      Logger.error('Repository: Delete generation failed', e);
      rethrow;
    }
  }
}

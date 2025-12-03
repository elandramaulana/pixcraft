import '../../../../core/utils/logger.dart';
import '../../data/models/generation_response_model.dart';
import '../../data/repositories/photo_repository.dart';

class GenerateImagesUseCase {
  final PhotoRepository _repository;

  GenerateImagesUseCase(this._repository);

  Future<GenerationResponseModel> execute({
    required String imageUrl,
    required String userId,
    List<String>? variations,
  }) async {
    try {
      // Validate input
      if (imageUrl.isEmpty) {
        throw Exception('Image URL is required');
      }

      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      Logger.info('UseCase: Starting photo generation');

      // Generate via repository
      final response = await _repository.generatePhotoVariations(
        imageUrl: imageUrl,
        userId: userId,
        variations: variations,
      );

      Logger.info('UseCase: Photo generation completed');
      return response;
    } catch (e) {
      Logger.error('UseCase: Generate images failed', e);
      rethrow;
    }
  }
}

import 'package:pixcraft/features/photo_generation/data/models/generation_response_model.dart';
import 'package:pixcraft/features/photo_generation/data/repositories/photo_repository.dart';
import '../../../../core/utils/logger.dart';

class GenerateImagesUseCase {
  final PhotoRepository _repository;

  GenerateImagesUseCase(this._repository);

  Future<GeneratePhotoResponse> execute({
    required String imageUrl,
    required String userId,
    required String selectedScene,
  }) async {
    try {
      Logger.info('Calling generatePhotoVariations function');
      Logger.info('Scene: $selectedScene');

      final response = await _repository.generatePhotoVariations(
        imageUrl: imageUrl,
        userId: userId,
        selectedScene: selectedScene,
      );

      Logger.info('Function response received');
      return response;
    } catch (e) {
      Logger.error('GenerateImagesUseCase error', e);
      rethrow;
    }
  }
}

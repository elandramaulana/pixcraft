import 'dart:io';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/upload_response_model.dart';
import '../../data/repositories/photo_repository.dart';

class UploadImageUseCase {
  final PhotoRepository _repository;

  UploadImageUseCase(this._repository);

  Future<UploadResponseModel> execute({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Validate image file
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Validate file size
      if (!ImageUtils.isValidImageSize(imageFile)) {
        final size = ImageUtils.formatFileSize(imageFile.lengthSync());
        throw Exception('Image is too large ($size). Maximum size is 10MB.');
      }

      // Validate file type
      if (!ImageUtils.isImageFile(imageFile.path)) {
        throw Exception('Invalid image format. Please select a valid image.');
      }

      Logger.info('UseCase: Starting image upload');

      // Upload via repository
      final response = await _repository.uploadImage(
        imageFile: imageFile,
        userId: userId,
      );

      Logger.info('UseCase: Image upload completed');
      return response;
    } catch (e) {
      Logger.error('UseCase: Upload image failed', e);
      rethrow;
    }
  }
}

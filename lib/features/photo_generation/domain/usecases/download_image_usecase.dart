import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../../../../core/utils/logger.dart';
import '../../data/repositories/photo_repository.dart';

class DownloadImageUseCase {
  final PhotoRepository _repository;

  DownloadImageUseCase(this._repository);

  Future<bool> execute({
    required String imageUrl,
    required String fileName,
  }) async {
    try {
      Logger.info('UseCase: Downloading image $fileName');

      // Download image via repository
      final file = await _repository.downloadImage(imageUrl, fileName);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveFile(
        file.path,
        name: fileName,
      );

      // Clean up temp file
      if (await file.exists()) {
        await file.delete();
      }

      final success = result['isSuccess'] == true;

      if (success) {
        Logger.info('UseCase: Image saved to gallery successfully');
      } else {
        Logger.error('UseCase: Failed to save image to gallery');
      }

      return success;
    } catch (e) {
      Logger.error('UseCase: Download image failed', e);
      rethrow;
    }
  }
}

import 'dart:io';
import '../constants/app_constants.dart';

class ImageUtils {
  static bool isValidImageSize(File file) {
    final sizeInBytes = file.lengthSync();
    return sizeInBytes <= AppConstants.maxImageSizeBytes;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'heic', 'heif'].contains(extension);
  }
}

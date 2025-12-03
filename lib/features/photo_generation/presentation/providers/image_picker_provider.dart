import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod/legacy.dart';
import '../../../../core/utils/logger.dart';

class ImagePickerNotifier extends StateNotifier<File?> {
  final ImagePicker _picker = ImagePicker();

  ImagePickerNotifier() : super(null);

  Future<void> pickImageFromGallery() async {
    try {
      Logger.info('Picking image from gallery');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        state = File(image.path);
        Logger.info('Image picked: ${image.path}');
      }
    } catch (e) {
      Logger.error('Pick image from gallery failed', e);
      state = null;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      Logger.info('Capturing image from camera');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        state = File(image.path);
        Logger.info('Image captured: ${image.path}');
      }
    } catch (e) {
      Logger.error('Capture image from camera failed', e);
      state = null;
    }
  }

  void clearImage() {
    state = null;
    Logger.info('Image cleared');
  }
}

final imagePickerProvider = StateNotifierProvider<ImagePickerNotifier, File?>((
  ref,
) {
  return ImagePickerNotifier();
});

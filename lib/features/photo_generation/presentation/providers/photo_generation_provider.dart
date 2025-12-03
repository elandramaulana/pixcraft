import 'dart:io';
import 'package:pixcraft/core/utils/error_handle.dart';
import 'package:pixcraft/features/photo_generation/domain/usecases/usecase_provider.dart';
import 'package:pixcraft/services/firebase/firebase_provider.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/photo_generation_state.dart';

class PhotoGenerationNotifier extends StateNotifier<PhotoGenerationState> {
  final Ref ref;

  PhotoGenerationNotifier(this.ref) : super(const PhotoGenerationState());

  // Set selected image
  void setSelectedImage(File? image) {
    if (image == null) {
      state = state.reset();
    } else {
      state = state.copyWith(
        selectedImage: image,
        status: PhotoGenerationStatus.idle,
      );
    }
  }

  // Upload and generate workflow
  Future<void> uploadAndGenerate() async {
    if (state.selectedImage == null) {
      Logger.error('No image selected');
      return;
    }

    try {
      // Get user ID
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Logger.info('Starting upload and generation workflow');

      // Step 1: Upload image (0-30%)
      state = state.copyWith(
        status: PhotoGenerationStatus.uploadingImage,
        progress: 0.0,
        currentStep: 'Uploading your photo...',
        errorMessage: null,
      );

      final uploadUseCase = ref.read(uploadImageUseCaseProvider);
      final uploadResponse = await uploadUseCase.execute(
        imageFile: state.selectedImage!,
        userId: userId,
      );

      state = state.copyWith(
        uploadedImageUrl: uploadResponse.imageUrl,
        progress: 0.3,
      );

      Logger.info('Image uploaded: ${uploadResponse.imageUrl}');

      // Step 2: Generate variations (30-100%)
      state = state.copyWith(
        status: PhotoGenerationStatus.generatingVariations,
        currentStep: 'Creating AI magic...',
        progress: 0.3,
      );

      final generateUseCase = ref.read(generateImagesUseCaseProvider);

      // Simulate progress updates for better UX
      _updateProgressPeriodically();

      final generationResponse = await generateUseCase.execute(
        imageUrl: uploadResponse.imageUrl,
        userId: userId,
      );

      Logger.info('Generation completed: ${generationResponse.generationId}');

      // Step 3: Completed
      state = state.copyWith(
        status: PhotoGenerationStatus.completed,
        generatedImages: generationResponse.variations ?? [],
        progress: 1.0,
        currentStep: 'All done!',
      );

      Logger.info('Workflow completed successfully');
    } catch (e) {
      Logger.error('Upload and generate failed', e);

      state = state.copyWith(
        status: PhotoGenerationStatus.error,
        errorMessage: ErrorHandler.getErrorMessage(e),
        progress: 0.0,
        currentStep: null,
      );
    }
  }

  void _updateProgressPeriodically() {
    final steps = [
      (0.4, 'Generating beach scene...'),
      (0.55, 'Generating city scene...'),
      (0.70, 'Generating mountain scene...'),
      (0.85, 'Generating cafe scene...'),
      (0.95, 'Finishing up...'),
    ];

    for (var i = 0; i < steps.length; i++) {
      Future.delayed(Duration(seconds: 10 + (i * 8)), () {
        if (state.status == PhotoGenerationStatus.generatingVariations) {
          state = state.copyWith(
            progress: steps[i].$1,
            currentStep: steps[i].$2,
          );
        }
      });
    }
  }

  // Reset to start new generation
  void reset() {
    state = const PhotoGenerationState();
    Logger.info('State reset');
  }

  // Retry after error
  Future<void> retry() async {
    await uploadAndGenerate();
  }
}

final photoGenerationProvider =
    StateNotifierProvider<PhotoGenerationNotifier, PhotoGenerationState>((ref) {
      return PhotoGenerationNotifier(ref);
    });

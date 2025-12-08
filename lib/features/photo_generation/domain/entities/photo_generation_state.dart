import 'dart:io';
import '../../data/models/generated_image_model.dart';

enum PhotoGenerationStatus {
  idle,
  uploadingImage,
  generatingVariations,
  completed,
  error,
}

class PhotoGenerationState {
  final PhotoGenerationStatus status;
  final File? selectedImage;
  final String? selectedScene; // NEW: Selected scene ID
  final String? uploadedImageUrl;
  final List<GeneratedImageModel> generatedImages;
  final String? errorMessage;
  final double progress;
  final String? currentStep;

  const PhotoGenerationState({
    this.status = PhotoGenerationStatus.idle,
    this.selectedImage,
    this.selectedScene,
    this.uploadedImageUrl,
    this.generatedImages = const [],
    this.errorMessage,
    this.progress = 0.0,
    this.currentStep,
  });

  bool get isIdle => status == PhotoGenerationStatus.idle;
  bool get isUploading => status == PhotoGenerationStatus.uploadingImage;
  bool get isGenerating => status == PhotoGenerationStatus.generatingVariations;
  bool get isLoading => isUploading || isGenerating;
  bool get isCompleted => status == PhotoGenerationStatus.completed;
  bool get isError => status == PhotoGenerationStatus.error;
  bool get hasSelectedImage => selectedImage != null;
  bool get hasUploadedImage => uploadedImageUrl != null;
  bool get hasGeneratedImages => generatedImages.isNotEmpty;
  bool get canGenerate =>
      hasSelectedImage &&
      selectedScene != null; // NEW: Check if ready to generate

  PhotoGenerationState copyWith({
    PhotoGenerationStatus? status,
    File? selectedImage,
    String? selectedScene,
    String? uploadedImageUrl,
    List<GeneratedImageModel>? generatedImages,
    String? errorMessage,
    double? progress,
    String? currentStep,
  }) {
    return PhotoGenerationState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedScene: selectedScene ?? this.selectedScene,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      generatedImages: generatedImages ?? this.generatedImages,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
      currentStep: currentStep,
    );
  }

  PhotoGenerationState reset() {
    return const PhotoGenerationState();
  }
}

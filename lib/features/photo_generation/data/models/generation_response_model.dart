import 'generated_image_model.dart';

class GenerationResponseModel {
  final bool success;
  final String generationId;
  final String message;
  final List<GeneratedImageModel>? variations;
  final String? error;

  GenerationResponseModel({
    required this.success,
    required this.generationId,
    required this.message,
    this.variations,
    this.error,
  });

  factory GenerationResponseModel.fromJson(Map<String, dynamic> json) {
    return GenerationResponseModel(
      success: json['success'] ?? false,
      generationId: json['generationId'] ?? '',
      message: json['message'] ?? '',
      variations: json['variations'] != null
          ? (json['variations'] as List)
                .map((v) => GeneratedImageModel.fromJson(v))
                .toList()
          : null,
      error: json['error'],
    );
  }
}

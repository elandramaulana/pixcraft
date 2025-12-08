// generation_response_model.dart
import 'package:pixcraft/core/utils/logger.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_image_model.dart';

class GeneratePhotoResponse {
  final bool success;
  final String? generationId;
  final String? message;
  final String? selectedScene;
  final List<GeneratedImageModel>? variations;

  GeneratePhotoResponse({
    required this.success,
    this.generationId,
    this.message,
    this.selectedScene,
    this.variations,
  });

  factory GeneratePhotoResponse.fromJson(Map<String, dynamic> json) {
    try {
      return GeneratePhotoResponse(
        success: json['success'] as bool? ?? false,
        generationId: json['generationId'] as String?,
        message: json['message'] as String?,
        selectedScene: json['selectedScene'] as String?,
        variations: _parseVariations(json['variations']),
      );
    } catch (e) {
      Logger.error('Failed to parse GeneratePhotoResponse', e);
      Logger.error('JSON data: $json');
      rethrow;
    }
  }

  static List<GeneratedImageModel>? _parseVariations(dynamic variationsData) {
    if (variationsData == null) return null;

    if (variationsData is! List) {
      Logger.error('Variations is not a list: ${variationsData.runtimeType}');
      return null;
    }

    try {
      return variationsData
          .map((v) {
            if (v is Map<String, dynamic>) {
              return GeneratedImageModel.fromJson(v);
            } else if (v is Map) {
              // Convert Map to Map<String, dynamic>
              final converted = Map<String, dynamic>.from(v);
              return GeneratedImageModel.fromJson(converted);
            } else {
              Logger.error('Invalid variation item type: ${v.runtimeType}');
              return null;
            }
          })
          .whereType<GeneratedImageModel>() // Filter out nulls
          .toList();
    } catch (e) {
      Logger.error('Failed to parse variations', e);
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'generationId': generationId,
      'message': message,
      'selectedScene': selectedScene,
      'variations': variations?.map((v) => v.toJson()).toList(),
    };
  }
}

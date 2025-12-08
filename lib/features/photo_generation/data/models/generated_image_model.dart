// generated_image_model.dart
import 'package:pixcraft/core/utils/logger.dart';

class GeneratedImageModel {
  final String imageUrl;
  final String type;
  final String prompt;
  final String storagePath;
  final String? scene;
  final int? variationNumber;

  GeneratedImageModel({
    required this.imageUrl,
    required this.type,
    required this.prompt,
    required this.storagePath,
    this.scene,
    this.variationNumber,
  });

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    try {
      return GeneratedImageModel(
        imageUrl: json['imageUrl'] as String? ?? '',
        type: json['type'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
        storagePath: json['storagePath'] as String? ?? '',
        scene: json['scene'] as String?,
        variationNumber: json['variationNumber'] as int?,
      );
    } catch (e) {
      Logger.error('Failed to parse GeneratedImageModel', e);
      Logger.error('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'type': type,
      'prompt': prompt,
      'storagePath': storagePath,
      if (scene != null) 'scene': scene,
      if (variationNumber != null) 'variationNumber': variationNumber,
    };
  }

  String get displayName {
    if (variationNumber != null) {
      return 'Variation $variationNumber';
    }

    return type
        .replaceAll('_v1', '')
        .replaceAll('_v2', '')
        .replaceAll('_v3', '')
        .replaceAll('_v4', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

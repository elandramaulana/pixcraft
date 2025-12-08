// upload_response_model.dart
import 'package:pixcraft/core/utils/logger.dart';

class UploadResponseModel {
  final bool success;
  final String imageUrl;
  final String storagePath;
  final String? documentId;
  final String? error;

  UploadResponseModel({
    required this.success,
    required this.imageUrl,
    required this.storagePath,
    this.documentId,
    this.error,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return UploadResponseModel(
        success: json['success'] as bool? ?? false,
        imageUrl: json['imageUrl'] as String? ?? '',
        storagePath: json['storagePath'] as String? ?? '',
        documentId: json['documentId'] as String?,
        error: json['error'] as String?,
      );
    } catch (e) {
      Logger.error('Failed to parse UploadResponseModel', e);
      Logger.error('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      if (documentId != null) 'documentId': documentId,
      if (error != null) 'error': error,
    };
  }
}

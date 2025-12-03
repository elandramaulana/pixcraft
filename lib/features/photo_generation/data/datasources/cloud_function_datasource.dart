import 'dart:io';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/generation_request_model.dart';
import '../models/generation_response_model.dart';
import '../models/upload_response_model.dart';

class CloudFunctionDatasource {
  final FirebaseFunctions _functions;

  CloudFunctionDatasource(this._functions);

  // Upload image to storage via Cloud Function
  Future<UploadResponseModel> uploadImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      Logger.info('Uploading image via Cloud Function...');

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileName = imageFile.path.split('/').last;

      // Call Cloud Function
      final callable = _functions.httpsCallable(
        FirebaseConstants.uploadImageFunction,
      );

      final result = await callable.call({
        'imageBase64': base64Image,
        'userId': userId,
        'fileName': fileName,
      });

      Logger.info('Upload response received');

      // Safe type casting
      final data = _castToStringDynamicMap(result.data);
      final response = UploadResponseModel.fromJson(data);

      if (!response.success) {
        throw Exception(response.error ?? 'Upload failed');
      }

      return response;
    } catch (e) {
      Logger.error('Upload image failed', e);
      rethrow;
    }
  }

  // Generate photo variations via Cloud Function
  Future<GenerationResponseModel> generatePhotoVariations({
    required GenerationRequestModel request,
  }) async {
    try {
      Logger.info('Generating photo variations via Cloud Function...');
      Logger.info('Request data: ${request.toJson()}');

      // Call Cloud Function
      final callable = _functions.httpsCallable(
        FirebaseConstants.generatePhotosFunction,
      );

      final result = await callable.call(request.toJson());

      Logger.info('Generation response received');
      Logger.info('Response data type: ${result.data.runtimeType}');

      // Safe type casting with detailed error handling
      final data = _castToStringDynamicMap(result.data);
      Logger.info('Casted data: $data');

      final response = GenerationResponseModel.fromJson(data);

      if (!response.success) {
        throw Exception(response.error ?? 'Generation failed');
      }

      return response;
    } catch (e, stackTrace) {
      Logger.error('Generate photos failed', e);
      Logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Safely casts a dynamic map to Map<String, dynamic>
  /// Handles nested maps recursively
  Map<String, dynamic> _castToStringDynamicMap(dynamic data) {
    if (data == null) {
      throw Exception('Cloud Function returned null data');
    }

    if (data is! Map) {
      throw Exception(
        'Cloud Function returned non-map data: ${data.runtimeType}',
      );
    }

    // Recursively convert all keys to String and handle nested maps
    return data.map<String, dynamic>((key, value) {
      final stringKey = key.toString();
      final dynamic convertedValue;

      if (value is Map) {
        // Recursively convert nested maps
        convertedValue = _castToStringDynamicMap(value);
      } else if (value is List) {
        // Handle lists that might contain maps
        convertedValue = value.map((item) {
          if (item is Map) {
            return _castToStringDynamicMap(item);
          }
          return item;
        }).toList();
      } else {
        convertedValue = value;
      }

      return MapEntry(stringKey, convertedValue);
    });
  }
}

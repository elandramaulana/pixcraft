import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/generation_request_model.dart';
import '../models/generation_response_model.dart';
import '../models/upload_response_model.dart';
import '../../../../core/utils/logger.dart';

abstract class CloudFunctionDatasource {
  Future<GeneratePhotoResponse> generatePhotoVariations({
    required GenerationRequestModel request,
  });

  Future<UploadResponseModel> uploadImage({
    required File imageFile,
    required String userId,
  });
}

class CloudFunctionDatasourceImpl implements CloudFunctionDatasource {
  final FirebaseFunctions _functions;

  CloudFunctionDatasourceImpl(this._functions);

  @override
  Future<GeneratePhotoResponse> generatePhotoVariations({
    required GenerationRequestModel request,
  }) async {
    try {
      Logger.info('Datasource: Calling generatePhotoVariations');
      Logger.info('Scene: ${request.selectedScene}');
      Logger.info('Request data: ${request.toJson()}');

      final callable = _functions.httpsCallable(
        'generatePhotoVariations',
        options: HttpsCallableOptions(
          timeout: const Duration(minutes: 6), // ⭐ 6 minutes timeout
        ),
      );

      Logger.info('Datasource: Making callable function call...');
      final result = await callable.call(request.toJson());

      Logger.info('Datasource: Generation response received');
      Logger.info('Response data type: ${result.data.runtimeType}');
      Logger.info('Response data: ${result.data}');

      // ⭐ FIX: Proper type conversion
      final Map<String, dynamic> responseData;

      if (result.data is Map) {
        // Convert Map<Object?, Object?> to Map<String, dynamic>
        responseData = _convertToStringMap(result.data as Map);
        Logger.info('Datasource: Converted response to Map<String, dynamic>');
      } else {
        Logger.error(
          'Datasource: Unexpected response type: ${result.data.runtimeType}',
        );
        throw Exception('Invalid response format from Cloud Function');
      }

      Logger.info('Datasource: Parsing response...');
      final response = GeneratePhotoResponse.fromJson(responseData);
      Logger.info('Datasource: Response parsed successfully');
      Logger.info('Generated ${response.variations?.length ?? 0} variations');

      return response;
    } on FirebaseFunctionsException catch (e) {
      Logger.error('Datasource: FirebaseFunctionsException', e);
      Logger.error('Code: ${e.code}');
      Logger.error('Message: ${e.message}');
      Logger.error('Details: ${e.details}');

      // Handle specific error codes
      if (e.code == 'deadline-exceeded') {
        throw Exception(
          'Generation is taking longer than expected. Please try again or choose a different scene.',
        );
      } else if (e.code == 'unauthenticated') {
        throw Exception('Authentication failed. Please sign in again.');
      } else if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Please check your account.');
      }

      throw Exception('Generation failed: ${e.message ?? e.code}');
    } catch (e, stackTrace) {
      Logger.error('Datasource: Generation failed', e);
      Logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<UploadResponseModel> uploadImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      Logger.info('Datasource: Uploading image');
      Logger.info('File path: ${imageFile.path}');
      Logger.info('User ID: $userId');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileName = imageFile.path.split('/').last;

      Logger.info('Image encoded, size: ${bytes.length} bytes');

      final callable = _functions.httpsCallable(
        'uploadImage',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 90)),
      );

      final result = await callable.call({
        'imageBase64': base64Image,
        'userId': userId,
        'fileName': fileName,
      });

      Logger.info('Datasource: Image uploaded successfully');
      Logger.info('Response data type: ${result.data.runtimeType}');

      // ⭐ FIX: Proper type conversion
      final Map<String, dynamic> responseData;

      if (result.data is Map) {
        responseData = _convertToStringMap(result.data as Map);
      } else {
        throw Exception('Invalid response format from Cloud Function');
      }

      final response = UploadResponseModel.fromJson(responseData);
      Logger.info('Upload response parsed: ${response.imageUrl}');

      return response;
    } on FirebaseFunctionsException catch (e) {
      Logger.error('Datasource: Upload failed', e);
      Logger.error('Code: ${e.code}');
      Logger.error('Message: ${e.message}');

      if (e.code == 'unauthenticated') {
        throw Exception('Authentication failed. Please sign in again.');
      } else if (e.code == 'invalid-argument') {
        throw Exception('Invalid image file. Please select a valid image.');
      }

      throw Exception('Upload failed: ${e.message ?? e.code}');
    } catch (e, stackTrace) {
      Logger.error('Datasource: Unexpected upload error', e);
      Logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ⭐ HELPER: Convert Map<Object?, Object?> to Map<String, dynamic>
  Map<String, dynamic> _convertToStringMap(Map<dynamic, dynamic> map) {
    final result = <String, dynamic>{};

    map.forEach((key, value) {
      final stringKey = key.toString();

      if (value is Map) {
        // Recursively convert nested maps
        result[stringKey] = _convertToStringMap(value as Map);
      } else if (value is List) {
        // Convert lists that might contain maps
        result[stringKey] = _convertList(value);
      } else {
        result[stringKey] = value;
      }
    });

    return result;
  }

  // ⭐ HELPER: Convert lists that might contain maps
  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToStringMap(item as Map);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }
}

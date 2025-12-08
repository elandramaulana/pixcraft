import 'dart:io';
import '../../../../core/utils/logger.dart';
import '../datasources/cloud_function_datasource.dart';
import '../datasources/firebase_storage_datasource.dart';
import '../datasources/firestore_datasource.dart';
import '../models/generation_request_model.dart';
import '../models/generation_response_model.dart';
import '../models/photo_model.dart';
import '../models/upload_response_model.dart';
import 'photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final CloudFunctionDatasource _cloudFunctionDatasource;
  final FirestoreDatasource _firestoreDatasource;
  final FirebaseStorageDatasource _storageDatasource;

  PhotoRepositoryImpl({
    required CloudFunctionDatasource cloudFunctionDatasource,
    required FirestoreDatasource firestoreDatasource,
    required FirebaseStorageDatasource storageDatasource,
  }) : _cloudFunctionDatasource = cloudFunctionDatasource,
       _firestoreDatasource = firestoreDatasource,
       _storageDatasource = storageDatasource;

  @override
  Future<UploadResponseModel> uploadImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      Logger.info('Repository: Uploading image for user $userId');

      final response = await _cloudFunctionDatasource.uploadImage(
        imageFile: imageFile,
        userId: userId,
      );

      Logger.info('Repository: Image uploaded successfully');
      return response;
    } catch (e) {
      Logger.error('Repository: Upload image failed', e);
      rethrow;
    }
  }

  @override
  Future<GeneratePhotoResponse> generatePhotoVariations({
    required String imageUrl,
    required String userId,
    List<String>? variations,
    required String selectedScene,
  }) async {
    try {
      Logger.info('Repository: Generating photo variations for user $userId');

      final request = GenerationRequestModel(
        imageUrl: imageUrl,
        userId: userId,
        selectedScene: selectedScene,
      );

      final response = await _cloudFunctionDatasource.generatePhotoVariations(
        request: request,
      );

      Logger.info('Repository: Photo variations generated successfully');
      return response;
    } catch (e) {
      Logger.error('Repository: Generate photo variations failed', e);
      rethrow;
    }
  }

  @override
  Stream<List<PhotoModel>> getUserImages(String userId) {
    try {
      Logger.info('Repository: Getting images for user $userId');
      return _firestoreDatasource.getUserImages(userId);
    } catch (e) {
      Logger.error('Repository: Get user images failed', e);
      rethrow;
    }
  }

  @override
  Future<List<PhotoModel>> getImagesByGenerationId(String generationId) async {
    try {
      Logger.info('Repository: Getting images for generation $generationId');
      return await _firestoreDatasource.getImagesByGenerationId(generationId);
    } catch (e) {
      Logger.error('Repository: Get images by generation ID failed', e);
      rethrow;
    }
  }

  @override
  Future<File> downloadImage(String imageUrl, String fileName) async {
    try {
      Logger.info('Repository: Downloading image $fileName');
      return await _storageDatasource.downloadImage(imageUrl, fileName);
    } catch (e) {
      Logger.error('Repository: Download image failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String storagePath) async {
    try {
      Logger.info('Repository: Deleting image $storagePath');
      await _storageDatasource.deleteImage(storagePath);
    } catch (e) {
      Logger.error('Repository: Delete image failed', e);
      rethrow;
    }
  }
}

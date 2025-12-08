import 'dart:io';
import '../models/generation_request_model.dart';
import '../models/generation_response_model.dart';
import '../models/photo_model.dart';
import '../models/upload_response_model.dart';

abstract class PhotoRepository {
  // Upload original image
  Future<UploadResponseModel> uploadImage({
    required File imageFile,
    required String userId,
  });

  // Generate photo variations
  Future<GeneratePhotoResponse> generatePhotoVariations({
    required String imageUrl,
    required String userId,
    List<String>? variations,
    required String selectedScene,
  });

  // Get user's images stream
  Stream<List<PhotoModel>> getUserImages(String userId);

  // Get images by generation ID
  Future<List<PhotoModel>> getImagesByGenerationId(String generationId);

  // Download image
  Future<File> downloadImage(String imageUrl, String fileName);

  // Delete image
  Future<void> deleteImage(String storagePath);
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/logger.dart';

class FirebaseStorageDatasource {
  final FirebaseStorage _storage;

  FirebaseStorageDatasource(this._storage);

  // Download image to device
  Future<File> downloadImage(String imageUrl, String fileName) async {
    try {
      Logger.info('Downloading image: $fileName');

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      // Download image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Logger.info('Image downloaded successfully: $filePath');
        return file;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Download image failed', e);
      rethrow;
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String storagePath) async {
    try {
      Logger.info('Deleting image: $storagePath');

      final ref = _storage.ref().child(storagePath);
      await ref.delete();

      Logger.info('Image deleted successfully');
    } catch (e) {
      Logger.error('Delete image failed', e);
      rethrow;
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      Logger.error('Get download URL failed', e);
      rethrow;
    }
  }
}

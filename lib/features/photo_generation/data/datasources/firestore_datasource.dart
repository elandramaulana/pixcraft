import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/photo_model.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource(this._firestore);

  // Get user's images
  Stream<List<PhotoModel>> getUserImages(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.imagesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return PhotoModel.fromFirestore(doc);
            }).toList();
          });
    } catch (e) {
      Logger.error('Get user images failed', e);
      rethrow;
    }
  }

  // Get images by generation ID
  Future<List<PhotoModel>> getImagesByGenerationId(String generationId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.imagesCollection)
          .where('generationId', isEqualTo: generationId)
          .where('type', isEqualTo: 'generated')
          .get();

      return snapshot.docs.map((doc) {
        return PhotoModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      Logger.error('Get images by generation ID failed', e);
      rethrow;
    }
  }

  // Get generation status
  Stream<DocumentSnapshot> getGenerationStatus(String generationId) {
    try {
      return _firestore
          .collection(FirebaseConstants.generationsCollection)
          .doc(generationId)
          .snapshots();
    } catch (e) {
      Logger.error('Get generation status failed', e);
      rethrow;
    }
  }

  // Save image metadata (usually done by Cloud Function, but can be used for local tracking)
  Future<void> saveImageMetadata(PhotoModel photo) async {
    try {
      await _firestore
          .collection(FirebaseConstants.imagesCollection)
          .add(photo.toFirestore());

      Logger.info('Image metadata saved');
    } catch (e) {
      Logger.error('Save image metadata failed', e);
      rethrow;
    }
  }
}

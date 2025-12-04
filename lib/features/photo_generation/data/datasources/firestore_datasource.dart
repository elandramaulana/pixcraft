import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_history_model.dart';
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

  // Save image metadata
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

  // ==================== NEW: Generation History Methods ====================

  /// Get user's generation history (stream)
  Stream<List<GenerationHistoryModel>> getUserGenerationHistory(String userId) {
    try {
      Logger.info('Fetching generation history for user: $userId');

      return _firestore
          .collection('user_generations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            Logger.info('Received ${snapshot.docs.length} generations');

            return snapshot.docs.map((doc) {
              return GenerationHistoryModel.fromFirestore(doc);
            }).toList();
          });
    } catch (e) {
      Logger.error('Get user generation history failed', e);
      rethrow;
    }
  }

  /// Get user's completed generations only
  Stream<List<GenerationHistoryModel>> getUserCompletedGenerations(
    String userId,
  ) {
    try {
      return _firestore
          .collection('user_generations')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return GenerationHistoryModel.fromFirestore(doc);
            }).toList();
          });
    } catch (e) {
      Logger.error('Get user completed generations failed', e);
      rethrow;
    }
  }

  /// Get single generation by ID
  Future<GenerationHistoryModel?> getGenerationById(String generationId) async {
    try {
      final doc = await _firestore
          .collection('user_generations')
          .doc(generationId)
          .get();

      if (doc.exists) {
        return GenerationHistoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Logger.error('Get generation by ID failed', e);
      rethrow;
    }
  }

  /// Delete generation (including all generated images)
  Future<void> deleteGeneration(String generationId) async {
    try {
      await _firestore
          .collection('user_generations')
          .doc(generationId)
          .delete();

      Logger.info('Generation deleted: $generationId');
    } catch (e) {
      Logger.error('Delete generation failed', e);
      rethrow;
    }
  }
}

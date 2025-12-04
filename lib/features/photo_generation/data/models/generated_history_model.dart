import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixcraft/features/photo_generation/data/models/generated_image_model.dart';

class GenerationHistoryModel {
  final String id;
  final String userId;
  final OriginalImageData originalImage;
  final List<GeneratedImageModel>
  generatedImages; // Ubah dari GeneratedImageData
  final String status;
  final List<String> variationTypes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  GenerationHistoryModel({
    required this.id,
    required this.userId,
    required this.originalImage,
    required this.generatedImages,
    required this.status,
    required this.variationTypes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory GenerationHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GenerationHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      originalImage: OriginalImageData.fromMap(data['originalImage'] ?? {}),
      generatedImages:
          (data['generatedImages'] as List<dynamic>?)
              ?.map(
                (e) => GeneratedImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      status: data['status'] ?? 'unknown',
      variationTypes: List<String>.from(data['variationTypes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';
  bool get hasGeneratedImages => generatedImages.isNotEmpty;
}

class OriginalImageData {
  final String url;
  final String storagePath;
  final String fileName;

  OriginalImageData({
    required this.url,
    required this.storagePath,
    required this.fileName,
  });

  factory OriginalImageData.fromMap(Map<String, dynamic> map) {
    return OriginalImageData(
      url: map['url'] ?? '',
      storagePath: map['storagePath'] ?? '',
      fileName: map['fileName'] ?? '',
    );
  }
}

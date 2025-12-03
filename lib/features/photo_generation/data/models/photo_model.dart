import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String storagePath;
  final String fileName;
  final DateTime uploadedAt;
  final String type; // 'original' or 'generated'
  final String? variationType; // 'beach', 'city', etc.
  final String? generationId;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.storagePath,
    required this.fileName,
    required this.uploadedAt,
    required this.type,
    this.variationType,
    this.generationId,
  });

  // From Firestore
  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
      fileName: data['fileName'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      type: data['type'] ?? 'original',
      variationType: data['variationType'],
      generationId: data['generationId'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'fileName': fileName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'type': type,
      if (variationType != null) 'variationType': variationType,
      if (generationId != null) 'generationId': generationId,
    };
  }

  PhotoModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? storagePath,
    String? fileName,
    DateTime? uploadedAt,
    String? type,
    String? variationType,
    String? generationId,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      type: type ?? this.type,
      variationType: variationType ?? this.variationType,
      generationId: generationId ?? this.generationId,
    );
  }
}

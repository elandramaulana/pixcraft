class UploadResponseModel {
  final bool success;
  final String imageUrl;
  final String storagePath;
  final String? error;

  UploadResponseModel({
    required this.success,
    required this.imageUrl,
    required this.storagePath,
    this.error,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadResponseModel(
      success: json['success'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
      storagePath: json['storagePath'] ?? '',
      error: json['error'],
    );
  }
}

class GenerationRequestModel {
  final String imageUrl;
  final String userId;
  final String selectedScene; // ✅ TAMBAHKAN INI - WAJIB!

  GenerationRequestModel({
    required this.imageUrl,
    required this.userId,
    required this.selectedScene, // ✅ WAJIB
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'userId': userId,
      'selectedScene': selectedScene, // ✅ KIRIM INI
    };
  }
}

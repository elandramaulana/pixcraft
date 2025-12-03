class GenerationRequestModel {
  final String imageUrl;
  final String userId;
  final List<String>? variations;

  GenerationRequestModel({
    required this.imageUrl,
    required this.userId,
    this.variations,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'userId': userId,
      if (variations != null) 'variations': variations,
    };
  }
}

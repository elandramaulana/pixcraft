class GeneratedImageModel {
  final String type;
  final String imageUrl;
  final String storageRef;
  final String prompt;

  GeneratedImageModel({
    required this.type,
    required this.imageUrl,
    required this.storageRef,
    required this.prompt,
  });

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedImageModel(
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      storageRef: json['storageRef'] ?? '',
      prompt: json['prompt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imageUrl': imageUrl,
      'storageRef': storageRef,
      'prompt': prompt,
    };
  }
}

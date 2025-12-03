class AppConstants {
  // App Info
  static const String appName = 'Pixcraft';
  static const String appTagline = 'AI-Powered Photo Magic';

  // Image Constraints
  static const int maxImageSizeMB = 10;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  // Generation
  static const int defaultVariationsCount = 4;
  static const List<String> defaultVariations = [
    'beach',
    'city',
    'mountain',
    'cafe',
  ];

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

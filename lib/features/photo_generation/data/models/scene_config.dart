import 'package:flutter/material.dart';

class SceneConfig {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<Color> gradientColors;

  const SceneConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.gradientColors,
  });

  static const luxury_car = SceneConfig(
    id: 'luxury_car',
    name: 'Luxury Car',
    emoji: '🚗',
    description: 'Sports car interior',
    gradientColors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  );

  static const cafe = SceneConfig(
    id: 'cafe',
    name: 'Cozy Cafe',
    emoji: '☕',
    description: 'Modern coffee shop',
    gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  static const travel = SceneConfig(
    id: 'travel',
    name: 'Travel',
    emoji: '✈️',
    description: 'Iconic landmarks',
    gradientColors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  );

  static const beach = SceneConfig(
    id: 'beach',
    name: 'Beach',
    emoji: '🏖️',
    description: 'Tropical paradise',
    gradientColors: [Color(0xFF14B8A6), Color(0xFF10B981)],
  );

  static const mountain = SceneConfig(
    id: 'mountain',
    name: 'Mountain',
    emoji: '🏔️',
    description: 'Alpine adventure',
    gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const city = SceneConfig(
    id: 'city',
    name: 'Urban Life',
    emoji: '🌆',
    description: 'City streets',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );

  static const office = SceneConfig(
    id: 'office',
    name: 'Professional',
    emoji: '💼',
    description: 'Modern office',
    gradientColors: [Color(0xFF64748B), Color(0xFF475569)],
  );

  static const party = SceneConfig(
    id: 'party',
    name: 'Party Night',
    emoji: '🎉',
    description: 'Glamorous venue',
    gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  );

  // List of all available scenes
  static const List<SceneConfig> all = [
    luxury_car,
    cafe,
    travel,
    beach,
    mountain,
    city,
    office,
    party,
  ];

  // Get scene by ID
  static SceneConfig? getById(String id) {
    try {
      return all.firstWhere((scene) => scene.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get scene name by ID
  static String getNameById(String id) {
    return getById(id)?.name ?? id;
  }
}

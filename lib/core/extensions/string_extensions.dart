extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get variationEmoji {
    switch (toLowerCase()) {
      case 'beach':
        return '🏖️';
      case 'city':
        return '🏙️';
      case 'mountain':
        return '⛰️';
      case 'cafe':
        return '☕';
      case 'desert':
        return '🏜️';
      case 'forest':
        return '🌲';
      default:
        return '✨';
    }
  }

  String get variationLabel {
    return '$variationEmoji ${capitalize()}';
  }
}

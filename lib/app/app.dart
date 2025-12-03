import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixcraft/services/firebase/firebase_provider.dart';
import '../features/photo_generation/presentation/screens/photo_generation_screen.dart';
import 'theme/app_theme.dart';

class PixcraftApp extends ConsumerStatefulWidget {
  const PixcraftApp({super.key});

  @override
  ConsumerState<PixcraftApp> createState() => _PixcraftAppState();
}

class _PixcraftAppState extends ConsumerState<PixcraftApp> {
  @override
  void initState() {
    super.initState();
    // Ensure user is authenticated on app start
    _ensureAuthenticated();
  }

  Future<void> _ensureAuthenticated() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.ensureAuthenticated();
    } catch (e) {
      debugPrint('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixcraft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PhotoGenerationScreen(),
    );
  }
}

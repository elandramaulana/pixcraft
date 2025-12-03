import 'package:firebase_core/firebase_core.dart';
import '../../core/utils/logger.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.info('Firebase initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Firebase', e);
      rethrow;
    }
  }
}

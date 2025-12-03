import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      Logger.info('Signing in anonymously...');
      final userCredential = await _auth.signInAnonymously();
      Logger.info('Anonymous sign-in successful: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      Logger.error('Anonymous sign-in failed', e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Logger.info('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', e);
      rethrow;
    }
  }

  // Ensure user is authenticated
  Future<String> ensureAuthenticated() async {
    if (currentUser != null) {
      return currentUserId!;
    }

    final userCredential = await signInAnonymously();
    return userCredential.user!.uid;
  }
}

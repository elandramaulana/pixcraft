import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'unauthenticated':
          return 'Please sign in to continue';
        case 'permission-denied':
          return 'You don\'t have permission to perform this action';
        case 'invalid-argument':
          return 'Invalid input. Please check your data';
        case 'deadline-exceeded':
          return 'Request timeout. Please try again';
        case 'not-found':
          return 'Resource not found';
        default:
          return error.message ?? 'Something went wrong';
      }
    }

    if (error is FirebaseAuthException) {
      return error.message ?? 'Authentication error';
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network';
    }

    return error.toString();
  }

  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        (error is FirebaseFunctionsException && error.code == 'unavailable');
  }
}

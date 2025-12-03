import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, [String tag = 'APP']) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void error(String message, [dynamic error, String tag = 'ERROR']) {
    if (kDebugMode) {
      print('[$tag] $message');
      if (error != null) print('Error details: $error');
    }
  }

  static void info(String message) => log(message, 'INFO');
  static void debug(String message) => log(message, 'DEBUG');
  static void warning(String message) => log(message, 'WARNING');
}

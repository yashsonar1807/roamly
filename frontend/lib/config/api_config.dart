import 'package:flutter/foundation.dart';

class ApiConfig {
  // 10.226.3.48 is your computer's local Wi-Fi IP address.
  // This allows a physical phone on the same Wi-Fi to connect to the backend!
  // If you are using an Android Emulator on your PC, you can change this to '10.0.2.2'
  // Windows Firewall blocks Wi-Fi access. We must use adb reverse.
  static const String host = '127.0.0.1';
  static const String port = '5000';
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api/v1';
    } else {
      return 'http://$host:$port/api/v1';
    }
  }

  static String get baseDomain {
    if (kIsWeb) {
      return 'localhost:$port';
    } else {
      return '$host:$port';
    }
  }
}

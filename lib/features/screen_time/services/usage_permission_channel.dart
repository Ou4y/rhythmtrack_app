import 'package:flutter/services.dart';

class UsagePermissionChannel {
  static const MethodChannel _channel =
      MethodChannel("com.rhythmtrack/usage");

  static Future<void> openUsageSettings() async {
    await _channel.invokeMethod("openUsageSettings");
  }
    static Future<bool> isPermissionGranted() async {
    try {
      final bool result =
          await _channel.invokeMethod("checkPermissionStatus");
      return result;
    } catch (e) {
      return false;
    }
  }
}
import 'package:flutter/services.dart';
import '../models/installed_app.dart';

class InstalledAppsService {
  static const MethodChannel _channel =
      MethodChannel("com.rhythmtrack/usage");

  static Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic> raw =
          await _channel.invokeMethod<List<dynamic>>("getInstalledApps") ?? [];

      return raw.map((item) {
        final map = Map<String, dynamic>.from(item);
        return InstalledApp.fromMap(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
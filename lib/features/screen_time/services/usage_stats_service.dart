import 'package:flutter/services.dart';
import '../models/app_usage.dart';

class UsageStatsService {
  static const MethodChannel _channel =
      MethodChannel("com.rhythmtrack/usage");

  /// Fetch today's usage per app from native Android.
  static Future<List<AppUsage>> getTodayUsage() async {
    try {
      final List<dynamic> rawList =
          await _channel.invokeMethod<List<dynamic>>("getUsageToday") ?? [];

      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return AppUsage.fromMap(map);
      }).toList();
    } catch (e) {
      // In case of any issue, return empty list
      return [];
    }
  }
}
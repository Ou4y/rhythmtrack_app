import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init(BuildContext context) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _notifications.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.local(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      ).add(const Duration(days: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails('daily_channel', 'Daily Notifications'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleAllReminders() async {
    // Good morning at 7:30 AM
    await scheduleDailyNotification(
      id: 1,
      title: 'Good Morning!',
      body: 'Start your day with a smile!',
      hour: 7,
      minute: 30,
    );
    // Drink water at 11:00 AM
    await scheduleDailyNotification(
      id: 2,
      title: 'Drink Water',
      body: 'Stay hydrated! Time for a glass of water.',
      hour: 11,
      minute: 0,
    );
    // Time to read at 2:00 PM
    await scheduleDailyNotification(
      id: 3,
      title: 'Time to Read',
      body: 'Take a break and read something inspiring.',
      hour: 14,
      minute: 0,
    );
    // Stretch at 4:30 PM
    await scheduleDailyNotification(
      id: 4,
      title: 'Stretch!',
      body: 'Take a moment to stretch your body.',
      hour: 16,
      minute: 30,
    );
    // Good night at 10:30 PM
    await scheduleDailyNotification(
      id: 5,
      title: 'Good Night!',
      body: 'Wind down and get ready for sleep.',
      hour: 22,
      minute: 30,
    );
  }
}

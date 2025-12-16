/* ReminderService is a stub that defines the interface used by the UI.
  It does not use flutter_local_notifications by request but leaves
  scheduling/cancel methods that the UI can call. You can later plug in
  flutter_local_notifications implementation here. */

class ReminderService {
  // Schedule a daily reminder at the given time string ("HH:mm") for habitId.
  Future<void> scheduleDaily(int habitId, String time, String title, String body) async {
    // no-op for now. Implement using flutter_local_notifications or another package.
    return Future.value();
  }

  Future<void> cancel(int habitId) async {
    // no-op
    return Future.value();
  }

  Future<void> update(int habitId, String time, String title, String body) async {
    // no-op
    return Future.value();
  }
}

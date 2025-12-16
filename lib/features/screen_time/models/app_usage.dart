class AppUsage {
  final String packageName;
  final String appName;
  final int totalTimeMs;

  AppUsage({
    required this.packageName,
    required this.appName,
    required this.totalTimeMs,
  });

  int get totalMinutes => (totalTimeMs / 60000).round();

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String? ?? map['packageName'] as String,
      totalTimeMs: map['totalTimeMs'] as int,
    );
  }
}
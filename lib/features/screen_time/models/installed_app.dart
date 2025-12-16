class InstalledApp {
  final String packageName;
  final String appName;
  final String iconBase64;

  InstalledApp({
    required this.packageName,
    required this.appName,
    required this.iconBase64,
  });

  factory InstalledApp.fromMap(Map<String, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'],
      appName: map['appName'],
      iconBase64: map['iconBase64'],
    );
  }
}
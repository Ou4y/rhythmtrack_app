class AppLimit {
  final String packageName;
  final String appName;
  final String iconBase64;
  final int limitMinutes;

  AppLimit({
    required this.packageName,
    required this.appName,
    required this.iconBase64,
    required this.limitMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'iconBase64': iconBase64,
      'limitMinutes': limitMinutes,
    };
  }

  factory AppLimit.fromMap(Map<String, dynamic> map) {
    return AppLimit(
      packageName: map['packageName'],
      appName: map['appName'],
      iconBase64: map['iconBase64'],
      limitMinutes: map['limitMinutes'],
    );
  }
}
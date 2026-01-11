class AppLimit {
  final String packageName;
  final String appName;
  final String iconBase64;
  final int limitMinutes;

  const AppLimit({
    required this.packageName,
    required this.appName,
    required this.iconBase64,
    required this.limitMinutes,
  });

  // ───────────────────────
  // COPY (UI / UX updates)
  // ───────────────────────
  AppLimit copyWith({
    String? packageName,
    String? appName,
    String? iconBase64,
    int? limitMinutes,
  }) {
    return AppLimit(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconBase64: iconBase64 ?? this.iconBase64,
      limitMinutes: limitMinutes ?? this.limitMinutes,
    );
  }

  // ───────────────────────
  // SQLITE SERIALIZATION
  // ───────────────────────
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
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      iconBase64: (map['iconBase64'] ?? '') as String,
      limitMinutes: map['limitMinutes'] as int,
    );
  }
}
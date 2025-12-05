import 'package:flutter/material.dart';
import 'features/screen_time/screens/screen_time_dashboard.dart';
import 'features/screen_time/screens/permission_explainer_screen.dart';
import 'features/screen_time/services/usage_permission_Channel.dart';

void main() {
  runApp(const RhythmTrackApp());
}

class RhythmTrackApp extends StatefulWidget {
  const RhythmTrackApp({super.key});

  @override
  State<RhythmTrackApp> createState() => _RhythmTrackAppState();
}

class _RhythmTrackAppState extends State<RhythmTrackApp> with WidgetsBindingObserver {
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called whenever the app resumes from background or settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission(); // re-check when user returns from settings
    }
  }

  Future<void> _checkPermission() async {
    final granted = await UsagePermissionChannel.isPermissionGranted();
    setState(() {
      _permissionGranted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionGranted == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _permissionGranted!
          ? const ScreenTimeDashboard()
          : const PermissionExplainerScreen(),
    );
  }
}
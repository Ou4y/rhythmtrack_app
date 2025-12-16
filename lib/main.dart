import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/screens/welcome_screen.dart';
import 'features/screen_time/screens/screen_time_dashboard.dart';
import 'features/screen_time/screens/permission_explainer_screen.dart';
import 'features/screen_time/services/usage_permission_Channel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvdtympbnmpywfgkyzbe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12ZHR5bXBibm1weXdmZ2t5emJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4OTI5MDAsImV4cCI6MjA3OTQ2ODkwMH0.sPrm9gASoUJiSXKZ3B8wV0uKA2EJ00JyNKsAlppK3dw',
  );

  runApp(const RhythmTrackApp());
}

class RhythmTrackApp extends StatefulWidget {
  const RhythmTrackApp({super.key});

  @override
  State<RhythmTrackApp> createState() => _RhythmTrackAppState();
}

class _RhythmTrackAppState extends State<RhythmTrackApp>
    with WidgetsBindingObserver {
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
   
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
    final user = Supabase.instance.client.auth.currentUser;

    
    if (user == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(),
      );
    }

    
    if (_permissionGranted == null) {
       _checkPermission();
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
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

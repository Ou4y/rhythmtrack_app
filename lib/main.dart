import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'auth/screens/welcome_screen.dart';

// Habit feature screens
import 'features/habits/screens/home_screen.dart';
import 'features/habits/screens/add_habit_screen.dart';
import 'features/habits/screens/edit_habit_screen.dart';
import 'features/habits/screens/habit_details_screen.dart';

// Screen Time feature screens & services
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

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
      _checkPermission();
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

    // 🔴 NOT LOGGED IN
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
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: Colors.blue),
      ),
      home: _permissionGranted!
          ? const HomeScreen()
          : const PermissionExplainerScreen(),
      routes: {
        // Habit feature routes
        '/add': (_) => const AddHabitScreen(),
        '/edit': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as int?;
          return EditHabitScreen(habitId: id ?? 0);
        },
        '/details': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as int?;
          return HabitDetailsScreen(habitId: id ?? 0);
        },

        // Screen Time routes
        '/screen_time_dashboard': (_) => const ScreenTimeDashboard(),
      },
    );
  }
}
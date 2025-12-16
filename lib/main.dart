import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Habit feature screens
import 'features/habits/screens/home_screen.dart';
import 'features/habits/screens/add_habit_screen.dart';
import 'features/habits/screens/edit_habit_screen.dart';
import 'features/habits/screens/habit_details_screen.dart';



// Screen Time feature screens & services
import 'features/screen_time/screens/screen_time_dashboard.dart';
import 'features/screen_time/screens/permission_explainer_screen.dart';
import 'features/screen_time/services/usage_permission_Channel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }
  //test commit
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
      home: _permissionGranted! ? const HomeScreen() : const PermissionExplainerScreen(),
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

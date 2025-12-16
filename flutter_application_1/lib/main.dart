import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature/habits/screens/home_screen.dart';
import 'feature/habits/screens/add_habit_screen.dart';
import 'feature/habits/screens/edit_habit_screen.dart';
import 'feature/habits/screens/habit_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, 
    statusBarIconBrightness: Brightness.light, 
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeScreen(),
      routes: {
        '/add': (_) => const AddHabitScreen(),
        '/edit': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as int?;
          return EditHabitScreen(habitId: id ?? 0);
        },
        '/details': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as int?;
          return HabitDetailsScreen(habitId: id ?? 0);
        },
      },
    );
  }
}

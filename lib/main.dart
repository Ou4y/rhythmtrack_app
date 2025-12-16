import 'package:flutter/material.dart';

// 1. ADD THIS IMPORT (The path matches your folder structure in the screenshot)
import 'features/auth/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Optional: removes the red ribbon
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 2. CHANGE THIS LINE
      home: const WelcomeScreen(), 
    );
  }
}
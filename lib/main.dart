import 'package:flutter/material.dart';
import 'auth/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvdtympbnmpywfgkyzbe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12ZHR5bXBibm1weXdmZ2t5emJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4OTI5MDAsImV4cCI6MjA3OTQ2ODkwMH0.sPrm9gASoUJiSXKZ3B8wV0uKA2EJ00JyNKsAlppK3dw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

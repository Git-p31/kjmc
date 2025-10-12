// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qyzrclsczvcuhwecbogi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5enJjbHNjenZjdWh3ZWNib2dpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NzE5MzAsImV4cCI6MjA3NTQ0NzkzMH0._TY27k5k3OSwaZ63BqBGYHv5dlSpZuBCxwQIulGhZlE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stuttgart Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const AuthOrDashboard(),
    );
  }
}

class AuthOrDashboard extends StatelessWidget {
  const AuthOrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return client.auth.currentUser == null
        ? const AuthScreen()
        : const DashboardScreen();
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://qyzrclsczvcuhwecbogi.supabase.co', // ✅ Убраны лишние пробелы
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5enJjbHNjenZjdWh3ZWNib2dpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NzE5MzAsImV4cCI6MjA3NTQ0NzkzMH0._TY27k5k3OSwaZ63BqBGYHv5dlSpZuBCxwQIulGhZlE',
    );
    if (kDebugMode) print('✅ Supabase initialized');
  } catch (e) {
    if (kDebugMode) print('❌ Supabase init error: $e');
  }

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

class AuthOrDashboard extends StatefulWidget {
  const AuthOrDashboard({super.key});
  @override
  State<AuthOrDashboard> createState() => _AuthOrDashboardState();
}

class _AuthOrDashboardState extends State<AuthOrDashboard> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    // Подписываемся на изменения сессии
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final bool isLoggedIn = session != null;

      if (mounted) {
        setState(() {
          _loading = false;
          _loggedIn = isLoggedIn;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _loggedIn ? const DashboardScreen() : const AuthScreen();
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Импортируем оба экрана
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://qyzrclsczvcuhwecbogi.supabase.co', // Убраны лишние пробелы
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5enJjbHNjenZjdWh3ZWNib2dpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NzE5MzAsImV4cCI6MjA3NTQ0NzkzMH0._TY27k5k3OSwaZ63BqBGYHv5dlSpZuBCxwQIulGhZlE',
    );
    if (kDebugMode) {
      print('✅ Supabase инициализирован успешно');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Ошибка инициализации Supabase: $e');
    }
    // Можно показать пользователю сообщение об ошибке
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
      home: const AuthOrDashboard(), // ✅ Проверяем статус и показываем нужный экран
    );
  }
}

// ✅ Новый класс для проверки статуса авторизации
class AuthOrDashboard extends StatefulWidget {
  const AuthOrDashboard({super.key});

  @override
  State<AuthOrDashboard> createState() => _AuthOrDashboardState();
}

class _AuthOrDashboardState extends State<AuthOrDashboard> {
  bool _isCheckingAuth = true;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthStatus();
  }

  Future<void> _checkInitialAuthStatus() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
        _isUserLoggedIn = user != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Возвращаем нужный экран в зависимости от статуса
    return _isUserLoggedIn ? const DashboardScreen() : const AuthScreen();
  }
}
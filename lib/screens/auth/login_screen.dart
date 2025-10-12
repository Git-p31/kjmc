// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:kjmc/supabase_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _message;

  void _showMessage(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _message = null);
    });
  }

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage('Введите email и пароль');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.signUpOrSignIn(
          emailController.text, passwordController.text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      _showMessage('Ошибка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
          {required String label,
          required TextEditingController controller,
          bool obscure = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFF007AFF)),
            ),
          ),
        ),
      );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(text),
        ),
      );

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) =>
      TextButton(
        onPressed: _isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: SizedBox(
              width: 380,
              child: Card(
                color: Colors.grey.shade900.withValues(alpha: 0.95),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Stuttgart Network',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(label: 'Email', controller: emailController),
                      _buildTextField(
                          label: 'Пароль',
                          controller: passwordController,
                          obscure: true),
                      const SizedBox(height: 20),
                      _buildButton('Войти', _login),
                      const SizedBox(height: 8),
                      _buildSecondaryButton('Нет аккаунта? Регистрация', () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      }),
                      if (_message != null)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _message!.contains('успешно')
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _message!.contains('успешно')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

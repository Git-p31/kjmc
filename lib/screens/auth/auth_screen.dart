// lib/screens/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:kjmc/supabase_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _step = 1;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController serviceRoleController = TextEditingController();

  bool _isLoading = false;
  String? _message;

  void _showMessage(String msg, {bool success = false}) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _clearStepFields(int step) {
    switch (step) {
      case 1:
        emailController.clear();
        passwordController.clear();
        break;
      case 2:
        firstNameController.clear();
        lastNameController.clear();
        phoneController.clear();
        break;
      case 3:
        serviceController.clear();
        serviceRoleController.clear();
        break;
    }
  }

  Future<void> _nextStep1() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage('Введите email и пароль');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signUpOrSignIn(
          emailController.text, passwordController.text);
      if (!mounted) return;
      _clearStepFields(2);
      setState(() => _step = 2);
    } catch (e) {
      _showMessage('Ошибка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep2() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showMessage('Заполните все поля');
      return;
    }
    _clearStepFields(3);
    setState(() => _step = 3);
  }

  Future<void> _completeRegistration() async {
    if (serviceController.text.isEmpty || serviceRoleController.text.isEmpty) {
      _showMessage('Заполните все поля');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'email': emailController.text,
        'full_name':
            '${firstNameController.text} ${lastNameController.text}',
        'phone': phoneController.text,
        'service': serviceController.text,
        'service_role': serviceRoleController.text,
        'role': 'user',
      }, onConflict: 'id');

      _showMessage('Регистрация завершена!', success: true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
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

  Widget _buildDot(bool active) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? const Color(0xFF007AFF)
              : Colors.white.withValues(alpha: 0.2),
        ),
      );

  Widget _buildStep1() => Column(
        children: [
          const Text('Регистрация',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _buildTextField(label: 'Email', controller: emailController),
          _buildTextField(
              label: 'Пароль', controller: passwordController, obscure: true),
          const SizedBox(height: 10),
          _buildButton('Продолжить', _nextStep1),
          const SizedBox(height: 8),
          _buildSecondaryButton('Уже есть аккаунт? Войти', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }),
        ],
      );

  Widget _buildStep2() => Column(
        children: [
          const Text('Личная информация',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _buildTextField(label: 'Имя', controller: firstNameController),
          _buildTextField(label: 'Фамилия', controller: lastNameController),
          _buildTextField(label: 'Телефон', controller: phoneController),
          const SizedBox(height: 10),
          _buildButton('Далее', _nextStep2),
          const SizedBox(height: 8),
          _buildSecondaryButton('Назад', () {
            _clearStepFields(1);
            setState(() => _step = 1);
          }),
        ],
      );

  Widget _buildStep3() => Column(
        children: [
          const Text('Служение',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _buildTextField(label: 'Служение', controller: serviceController),
          _buildTextField(
              label: 'Роль в служении', controller: serviceRoleController),
          const SizedBox(height: 10),
          _buildButton('Завершить регистрацию', _completeRegistration),
          const SizedBox(height: 8),
          _buildSecondaryButton('Назад', () {
            _clearStepFields(2);
            setState(() => _step = 2);
          }),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)])),
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
                      const Text('Stuttgart Network',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007AFF))),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(3, (i) => _buildDot(i + 1 == _step)),
                      ),
                      LinearProgressIndicator(
                        value: _step / 3,
                        color: const Color(0xFF007AFF),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 20),
                      if (_step == 1) _buildStep1(),
                      if (_step == 2) _buildStep2(),
                      if (_step == 3) _buildStep3(),
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
                      const SizedBox(height: 20),
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

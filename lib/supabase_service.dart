import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  /// Регистрация или вход
  static Future<void> signUpOrSignIn(String email, String password) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Если пользователь уже зарегистрирован — пробуем войти
      if (res.user == null) {
        // signUp не создал нового пользователя
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      // Обработка ошибок аутентификации
      if (e.message.contains('User already registered')) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Получить профиль по ID
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Map<String, dynamic>.from(res);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Получить список людей (CRM)
  static Future<List<dynamic>> getPeople() async {
    try {
      final res = await supabase.from('people').select();
      return List<dynamic>.from(res);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Выйти из аккаунта
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

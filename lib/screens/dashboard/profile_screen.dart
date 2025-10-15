// lib/screens/dashboard/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kjmc/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        _profile = await SupabaseService.getProfile(userId);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль'), backgroundColor: Colors.grey[900]),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль'), backgroundColor: Colors.grey[900]),
        body: const Center(child: Text('Профиль не найден')),
      );
    }

    final fullName = _profile!['full_name'] ?? '—';
    final email = _profile!['email'] ?? '—';
    final service = _profile!['service'] ?? '—';
    final role = _profile!['service_role'] ?? '—';
    final phone = _profile!['phone'] ?? '—';
    final userRole = _profile!['role'] ?? 'user';
    final registrationDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

    // Данные для карточек
    final infoList = [
      {'title': 'Email', 'value': email, 'icon': Icons.email, 'color': Colors.blue},
      {'title': 'Роль', 'value': userRole, 'icon': Icons.person, 'color': Colors.purple},
      {'title': 'Служение', 'value': service, 'icon': Icons.work, 'color': Colors.orange},
      {'title': 'Роль в служении', 'value': role, 'icon': Icons.group_work, 'color': Colors.yellow.shade700},
      {'title': 'Телефон', 'value': phone, 'icon': Icons.phone, 'color': Colors.teal},
      {'title': 'Статус', 'value': 'Активен', 'icon': Icons.check_circle, 'color': Colors.green},
      {'title': 'Дата регистрации', 'value': registrationDate, 'icon': Icons.calendar_today, 'color': Colors.grey},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Аватар и имя сверху
            Card(
              color: Colors.grey.shade900.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF007AFF),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Сетка карточек снизу
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: EdgeInsets.zero, // Убираем внутренний отступ
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3, // 2 на мобильном, 3 на планшете/web
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4, // Ширина:Высота карточки
                  ),
                  itemCount: infoList.length,
                  itemBuilder: (context, index) {
                    final item = infoList[index];
                    return _buildInfoCard(item['title']!, item['value']!, item['icon']!, item['color']!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Карточка информации
  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                // ✅ Помещаем текст в Expanded, чтобы он сжимался
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Обрезаем, если не помещается
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // Обрезаем, если не помещается
            ),
          ],
        ),
      ),
    );
  }
}
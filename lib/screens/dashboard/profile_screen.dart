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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_profile == null) return const Center(child: Text('Профиль не найден'));

    final fullName = _profile!['full_name'] ?? '—';
    final email = _profile!['email'] ?? '—';
    final service = _profile!['service'] ?? '—';
    final role = _profile!['service_role'] ?? '—';
    final phone = _profile!['phone'] ?? '—';
    final userRole = _profile!['role'] ?? 'user';
    final registrationDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

    final infoList = [
      {'title': 'Email', 'value': email, 'color': Colors.blue},
      {'title': 'Роль', 'value': userRole, 'color': Colors.purple},
      {'title': 'Служение', 'value': service, 'color': Colors.orange},
      {'title': 'Роль в служении', 'value': role, 'color': Colors.yellow.shade700},
      {'title': 'Телефон', 'value': phone, 'color': Colors.teal},
      {'title': 'Статус', 'value': 'Активен', 'color': Colors.green},
      {'title': 'Дата регистрации', 'value': registrationDate, 'color': Colors.grey},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth > 800 ? 800 : constraints.maxWidth;
            final double cardWidth = (maxWidth - 40) / 2; // два ряда с промежутком 20px

            return Card(
              color: Colors.grey.shade900.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF007AFF),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(fullName,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: infoList
                          .map((item) => SizedBox(
                                width: cardWidth,
                                child: _infoCard(
                                    item['title']!, item['value']!, item['color']!),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
}

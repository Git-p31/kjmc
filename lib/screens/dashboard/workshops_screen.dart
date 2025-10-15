// lib/screens/workshops/workshops_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kjmc/supabase_service.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  List<Map<String, dynamic>>? _workshops;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Получаем профиль пользователя
        final profile = await SupabaseService.getProfile(userId);
        final userRole = profile['role'] ?? 'user';

        // Проверяем, имеет ли пользователь доступ к списку воркшопов
        if (userRole == 'admin' || userRole == 'moder') {
          // Загружаем воркшопы из БД
          final res = await Supabase.instance.client
              .from('workshops')
              .select('*')
              .eq('is_active', true) // Только активные
              .order('start_date', ascending: true);

          if (mounted) {
            setState(() {
              _workshops = List<Map<String, dynamic>>.from(res);
              _isLoading = false;
            });
          }
        } else {
          // Для user — не загружаем, просто убираем загрузку
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading workshops: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null && _workshops != null) {
      // Роль уже загружена, если список воркшопов != null
      // userRole = 'admin'; // или 'moder' — мы знаем, что пользователь админ/модер
    } else if (userId != null && _workshops == null && !_isLoading) {
      // Пытаемся получить роль из кэша или локально
      // В реальном приложении можно хранить роль в `auth.user().user_metadata`
      // или кэшировать её при входе
      // Пока получим снова, чтобы определить роль
      _loadUserRole();
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Воркшопы'), backgroundColor: Colors.grey[900]),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Если у пользователя роль admin или moder — показываем список
    if (_workshops != null) {
      return _buildWorkshopsList();
    }

    // Иначе — заглушка для user
    return _buildPlaceholder();
  }

  Future<void> _loadUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final profile = await SupabaseService.getProfile(userId);
        final userRole = profile['role'] ?? 'user';
        if (userRole == 'admin' || userRole == 'moder') {
          // Перезагружаем воркшопы, если роль подходит
          _loadWorkshops();
        }
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Widget _buildWorkshopsList() {
    if (_workshops!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Воркшопы'), backgroundColor: Colors.grey[900]),
        body: const Center(
          child: Text('Нет доступных воркшопов', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Воркшопы'),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2, // 1 колонка на мобиле
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6, // Ширина:Высота карточки
            ),
            itemCount: _workshops!.length,
            itemBuilder: (context, index) {
              final workshop = _workshops![index];
              return _buildWorkshopCard(workshop);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(Map<String, dynamic> workshop) {
    final title = workshop['title'] ?? 'Без названия';
    final description = workshop['description'] ?? 'Нет описания';
    final image = workshop['image_url'] ?? 'https://via.placeholder.com/300x200?text=Workshop';
    final topics = List<String>.from(workshop['topics'] ?? []);
    final participants = workshop['participants'] ?? 0;
    final maxParticipants = workshop['max_participants'] ?? 0;
    final startDate = workshop['start_date'] != null
        ? DateTime.parse(workshop['start_date']).toString().split(' ')[0]
        : 'Не указано';
    final location = workshop['location'] ?? 'Не указано';

    return Card(
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Описание
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Темы
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: topics
                      .map((topic) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              topic,
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Участники и дата
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '$participants / $maxParticipants',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      startDate,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Локация
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Воркшопы'),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.grey.shade900.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspaces,
                      size: 80,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Воркшопы',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Раздел в разработке',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Здесь скоро появится информация о воркшопах, мероприятиях и обучающих сессиях.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
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
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await SupabaseService.getProfile(userId);
      final userRole = profile['role'] ?? 'user';

      final res = await Supabase.instance.client
          .from('workshops')
          .select('*')
          .eq('is_active', true)
          .order('start_date', ascending: true);

      if (mounted) {
        setState(() {
          _userRole = userRole;
          _workshops = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading workshops: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinWorkshop(Map<String, dynamic> workshop) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final workshopId = workshop['id'];
    final currentParticipants = workshop['participants'] ?? 0;
    final maxParticipants = workshop['max_participants'] ?? 0;

    if (currentParticipants >= maxParticipants) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('К сожалению, места закончились.')),
        );
      }
      return;
    }

    try {
      await Supabase.instance.client
          .from('workshops')
          .update({'participants': currentParticipants + 1})
          .eq('id', workshopId);

      final profile = await SupabaseService.getProfile(userId);
      final List<dynamic> joinedWorkshops = List.from(profile['joined_workshops'] ?? []);
      if (!joinedWorkshops.contains(workshopId)) {
        joinedWorkshops.add(workshopId);
        await Supabase.instance.client
            .from('profiles')
            .update({'joined_workshops': joinedWorkshops})
            .eq('id', userId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Вы зарегистрированы на: ${workshop['title']}')),
        );
        setState(() {
          workshop['participants'] = currentParticipants + 1;
        });
      }
    } catch (e) {
      debugPrint('Error joining workshop: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка регистрации')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Воркшопы'), backgroundColor: Colors.grey[900]),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _buildWorkshopsList();
  }

  Widget _buildWorkshopsList() {
    if (_workshops == null || _workshops!.isEmpty) {
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
      floatingActionButton: (_userRole == 'admin' || _userRole == 'moder')
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Создание воркшопа (в разработке)')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
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
    final image = workshop['image_url'] ?? 'https://placehold.co/300x200?text=Workshop';
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey.shade700,
                child: const Icon(Icons.image_not_supported, color: Colors.white54),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: topics
                          .map((topic) => Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(topic,
                                    style: const TextStyle(
                                        fontSize: 9, color: Colors.white)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 2),
                        Text('$participants / $maxParticipants',
                            style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        const Spacer(),
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 2),
                        Text(startDate,
                            style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 2),
                        Text(location,
                            style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _userRole == 'admin' || _userRole == 'moder'
                          ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Редактирование воркшопа (в разработке)')),
                            )
                          : () => _joinWorkshop(workshop),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _userRole == 'admin' || _userRole == 'moder'
                            ? Colors.orange
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: Text(
                        _userRole == 'admin' || _userRole == 'moder'
                            ? 'Ред'
                            : 'Уч',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

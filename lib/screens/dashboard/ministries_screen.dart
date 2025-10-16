// lib/screens/dashboard/ministries_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ministry_detail_screen.dart';

class MinistriesScreen extends StatefulWidget {
  const MinistriesScreen({super.key});

  @override
  State<MinistriesScreen> createState() => _MinistriesScreenState();
}

class _MinistriesScreenState extends State<MinistriesScreen> {
  late Future<List<Map<String, dynamic>>> _ministriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshMinistries();
  }

  Future<List<Map<String, dynamic>>> _fetchMinistries() async {
    // Не используем profiles!inner — требует FK в БД. Вместо этого подгрузим профили отдельно
    final ministriesRes = await Supabase.instance.client
        .from('ministries')
        .select('''
          id,
          name,
          description,
          ministry_members (
            user_id
          )
        ''')
        .order('name', ascending: true);

    final profilesRes = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name');

    try {
      final ministriesList = List<Map<String, dynamic>>.from(ministriesRes);
      final profilesList = List<Map<String, dynamic>>.from(profilesRes);

      // Сформируем map id -> full_name
      final profileById = <String, String>{};
      for (final p in profilesList) {
        final pid = p['id']?.toString();
        final fname = p['full_name']?.toString() ?? '';
        if (pid != null) profileById[pid] = fname;
      }

      // Встроим поле profiles: { full_name } внутрь каждой записи ministry_members
      for (final m in ministriesList) {
        final members = (m['ministry_members'] as List<dynamic>?) ?? [];
        final transformed = members.map<Map<String, dynamic>>((mm) {
          final uid = mm['user_id']?.toString();
          return {
            'user_id': uid,
            'profiles': {'full_name': uid != null ? (profileById[uid] ?? '') : ''}
          };
        }).toList();
        m['ministry_members'] = transformed;
      }

      return ministriesList;
    } catch (e) {
      throw Exception('Failed to parse ministries response: $e');
    }
  }

  void _refreshMinistries() {
    setState(() {
      _ministriesFuture = _fetchMinistries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Служения'),
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ministriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshMinistries,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final ministries = snapshot.data ?? [];

          if (ministries.isEmpty) {
            return const Center(
              child: Text(
                'Нет служений',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshMinistries(),
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: ministries.length,
              itemBuilder: (context, index) {
                final ministry = ministries[index];
                final id = ministry['id'] as String; // ✅ Получаем ID
                final name = ministry['name'] as String? ?? 'Без названия';
                final description = ministry['description'] as String? ?? '';
                final members = (ministry['ministry_members'] as List?)
                        ?.map((m) => m['profiles']['full_name'] as String?)
                        .whereType<String>()
                        .toList() ??
                    [];

                final memberCount = members.length;

                // Формируем строку с именами (макс. 3)
                String membersPreview = '';
                if (members.isNotEmpty) {
                  final displayNames = members.take(3).toList();
                  membersPreview = displayNames.join(', ');
                  if (memberCount > 3) {
                    membersPreview += ' и ещё ${memberCount - 3}';
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MinistryDetailScreen(
                          ministryId: id,
                          name: name,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Иконка по первой букве
                          CircleAvatar(
                            radius: 24.0,
                            backgroundColor: const Color(0xFFFF6B6B),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Участники
                          if (memberCount > 0)
                            Text(
                              '👥 $memberCount чел.',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          if (membersPreview.isNotEmpty)
                            Text(
                              membersPreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // =============== Диалог создания служения ===============
  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedLeaderId;

    Future<List<Map<String, dynamic>>> fetchAllProfiles() async {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .order('full_name');
      try {
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        throw Exception('Failed to parse profiles response: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Создать новое служение'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Название'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchAllProfiles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Ошибка: ${snapshot.error}');
                      }
                      final profiles = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        initialValue: selectedLeaderId,
                        hint: const Text('Выберите лидера'),
                        items: profiles.map((profile) {
                          return DropdownMenuItem(
                            value: profile['id'] as String,
                            child: Text(profile['full_name'] as String? ?? 'Без имени'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedLeaderId = value),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                        onPressed: nameController.text.isEmpty || selectedLeaderId == null
                    ? null
                    : () async {
                        try {
                          // Вставляем новое служение и получаем созданную запись
                          final inserted = await Supabase.instance.client
                              .from('ministries')
                              .insert({
                            'name': nameController.text,
                            'description': descriptionController.text,
                          }).select('id').single();

                          // inserted может быть Map или List; обработаем оба варианта
                          String ministryId;
                          if (inserted is Iterable && (inserted as Iterable).isNotEmpty) {
                            final first = (inserted as Iterable).first;
                            ministryId = first['id'].toString();
                          } else {
                            final maybeId = (inserted as Map)['id'];
                            if (maybeId != null) {
                              ministryId = maybeId.toString();
                            } else {
                              throw Exception('Не удалось получить id созданного служения');
                            }
                          }

                          // Добавляем лидера
                          await Supabase.instance.client.from('ministry_members').insert({
                            'ministry_id': ministryId,
                            'user_id': selectedLeaderId,
                            'role_in_ministry': 'leader',
                          });

                          if (context.mounted) Navigator.pop(context);
                          _refreshMinistries(); // Обновляем список
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      },
                child: const Text('Создать'),
              ),
            ],
          );
        },
      ),
    );
  }
}
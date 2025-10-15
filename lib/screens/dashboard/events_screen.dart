// lib/screens/dashboard/events_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final supabase = Supabase.instance.client;
  String? role;
  List<dynamic> events = [];
  late final Stream<List<Map<String, dynamic>>> _eventsStream;
  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadEvents();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    final res = await supabase.from('profiles').select('role').eq('id', uid).maybeSingle();
    if (!mounted) return;
    setState(() {
      role = res?['role'] ?? 'user';
    });
  }

  Future<void> _loadEvents() async {
    final res = await supabase.from('events').select().order('starts_at');
    if (!mounted) return;
    setState(() {
      events = res;
    });
  }

  void _subscribeToEvents() {
    // Новый метод: stream() возвращает Stream<List<Map<String, dynamic>>>
    _eventsStream = supabase.from('events').stream(primaryKey: ['id']);
    _subscription = _eventsStream.listen((data) {
      if (!mounted) return;
      setState(() {
        events = data;
      });
    });
  }

  void _showEventDialog(DateTime date, List<dynamic> dayEvents) {
    final canEdit = role == 'admin' || role == 'moder';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('События ${DateFormat('dd.MM.yyyy').format(date)}'),
        content: SizedBox(
          width: 400,
          child: dayEvents.isEmpty
              ? const Text('Нет событий')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: dayEvents.length,
                  itemBuilder: (ctx, i) {
                    final e = dayEvents[i];
                    final start = DateTime.parse(e['starts_at']);
                    final end = e['ends_at'] != null ? DateTime.parse(e['ends_at']) : null;

                    return ListTile(
                      title: Text(e['title'] ?? ''),
                      subtitle: Text(
                        '${DateFormat.Hm().format(start)}'
                        '${end != null ? ' – ${DateFormat.Hm().format(end)}' : ''}',
                      ),
                      onTap: canEdit ? () => _showEditEventDialog(date, e) : null,
                    );
                  },
                ),
        ),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: () => _showEditEventDialog(date, null),
              child: const Text('Добавить событие'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(DateTime date, Map<String, dynamic>? existing) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    TimeOfDay? startTime = existing?['starts_at'] != null
        ? TimeOfDay.fromDateTime(DateTime.parse(existing!['starts_at']))
        : null;
    TimeOfDay? endTime = existing?['ends_at'] != null
        ? TimeOfDay.fromDateTime(DateTime.parse(existing!['ends_at']))
        : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Новое событие' : 'Редактировать событие'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        if (!mounted) return;
                        setState(() => startTime = picked);
                      }
                    },
                    child: Text(startTime == null
                        ? 'Начало'
                        : 'Начало: ${startTime!.format(ctx)}'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        if (!mounted) return;
                        setState(() => endTime = picked);
                      }
                    },
                    child: Text(endTime == null
                        ? 'Конец'
                        : 'Конец: ${endTime!.format(ctx)}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final start = DateTime(
                date.year,
                date.month,
                date.day,
                startTime?.hour ?? 0,
                startTime?.minute ?? 0,
              );
              final end = DateTime(
                date.year,
                date.month,
                date.day,
                endTime?.hour ?? 0,
                endTime?.minute ?? 0,
              );

              if (existing == null) {
                await supabase.from('events').insert({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'starts_at': start.toIso8601String(),
                  'ends_at': end.toIso8601String(),
                });
              } else {
                await supabase.from('events').update({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'starts_at': start.toIso8601String(),
                  'ends_at': end.toIso8601String(),
                }).eq('id', existing['id']);
              }

              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
        ),
        itemCount: daysInMonth,
        itemBuilder: (context, day) {
          final date = DateTime(year, month, day + 1);
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          final dayEvents = events.where((e) {
            final startsAt = DateTime.parse(e['starts_at']);
            return startsAt.day == date.day &&
                startsAt.month == date.month &&
                startsAt.year == date.year;
          }).toList();

          return GestureDetector(
            onTap: () => _showEventDialog(date, dayEvents),
            child: Container(
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF007AFF)
                    : dayEvents.isNotEmpty
                        ? Colors.green.withAlpha((0.5 * 255).toInt())
                        : Colors.white10,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  '${day + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

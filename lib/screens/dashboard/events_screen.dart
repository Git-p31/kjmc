// lib/screens/dashboard/events_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Supabase.instance.client.from('events').select().order('starts_at'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('События не найдены'));
        }

        final now = DateTime.now();
        final year = now.year;
        final month = now.month;
        final daysInMonth = DateTime(year, month + 1, 0).day;

        return Padding(
          padding: const EdgeInsets.all(40.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, day) {
              final date = DateTime(year, month, day + 1);
              final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

              final dayEvents = snapshot.data!.where((e) {
                final startsAt = DateTime.parse(e['starts_at']);
                return startsAt.day == date.day &&
                    startsAt.month == date.month &&
                    startsAt.year == date.year;
              }).toList();

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('События на ${DateFormat('dd.MM.yyyy').format(date)}'),
                      content: dayEvents.isEmpty
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
                                    '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'
                                    ' – ${end != null ? '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}' : ''}',
                                  ),
                                  trailing: e['photo_url'] != null
                                      ? Image.network(e['photo_url'], width: 40.0)
                                      : null,
                                );
                              },
                            ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Закрыть'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF007AFF)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${day + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (dayEvents.isNotEmpty)
                          Text(
                            '${dayEvents.length} событие${dayEvents.length > 1 ? "я" : ""}',
                            style: const TextStyle(color: Colors.green),
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
    );
  }
}

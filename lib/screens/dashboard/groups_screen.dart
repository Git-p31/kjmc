// lib/screens/dashboard/groups_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Supabase.instance.client.from('groups').select(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет групп'));
        }

        final data = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(40.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final group = data[index];
            final name = group['name'] ?? '';
            final description = group['description'] ?? '';

            return Card(
              color: Colors.white.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: const Color(0xFFFF6B6B),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4.0),
                    Text(description, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

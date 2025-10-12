// lib/screens/dashboard/crm_screen.dart
import 'package:flutter/material.dart';
import 'package:kjmc/supabase_service.dart';

class CrmScreen extends StatelessWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: SupabaseService.getPeople(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет контактов'));
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
            final person = data[index];
            final firstName = person['first_name'] ?? '';
            final lastName = person['last_name'] ?? '';
            final email = person['email'] ?? '';
            final phone = person['phone'] ?? '';

            return Card(
              color: Colors.white.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: const Color(0xFF23A6D5),
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text('$firstName $lastName', overflow: TextOverflow.ellipsis),
                    Text(email, overflow: TextOverflow.ellipsis),
                    Text(phone, overflow: TextOverflow.ellipsis),
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

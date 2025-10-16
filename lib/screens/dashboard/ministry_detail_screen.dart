import 'package:flutter/material.dart';

class MinistryDetailScreen extends StatelessWidget {
  final String ministryId;
  final String name;

  const MinistryDetailScreen({super.key, required this.ministryId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name), backgroundColor: Colors.grey.shade900),
      body: Center(
        child: Text('Детали служения: $name (id: $ministryId)', style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
    );
  }
}

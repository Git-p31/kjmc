// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'crm_screen.dart';
import 'events_screen.dart';
import 'groups_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProfileScreen(),
    CrmScreen(),
    EventsScreen(),
    GroupsScreen(),
  ];

  final List<String> _titles = const [
    'Профиль',
    'CRM',
    'События',
    'Группы',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.grey.shade900,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey.shade900,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF007AFF)),
                child: Center(
                  child: Text(
                    'Меню',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Профиль', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.white),
                title: const Text('CRM', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: Colors.white),
                title: const Text('События', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentIndex = 2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.layers, color: Colors.white),
                title: const Text('Группы', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentIndex = 3);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}


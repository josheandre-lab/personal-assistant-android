import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/helpers.dart';
import 'today_screen.dart';
import 'notes_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    TodayScreen(),
    NotesScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];
  
  final List<String> _titles = const [
    'Bugün',
    'Notlarım',
    'Hatırlatmalar',
    'Ayarlar',
  ];
  
  final List<IconData> _icons = const [
    Icons.today_outlined,
    Icons.note_outlined,
    Icons.alarm_outlined,
    Icons.settings_outlined,
  ];
  
  final List<IconData> _selectedIcons = const [
    Icons.today,
    Icons.note,
    Icons.alarm,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(_icons[0]),
            selectedIcon: Icon(_selectedIcons[0]),
            label: _titles[0],
          ),
          NavigationDestination(
            icon: Icon(_icons[1]),
            selectedIcon: Icon(_selectedIcons[1]),
            label: _titles[1],
          ),
          NavigationDestination(
            icon: Icon(_icons[2]),
            selectedIcon: Icon(_selectedIcons[2]),
            label: _titles[2],
          ),
          NavigationDestination(
            icon: Icon(_icons[3]),
            selectedIcon: Icon(_selectedIcons[3]),
            label: _titles[3],
          ),
        ],
      ),
    );
  }
}

// lib/ui/main_scaffold.dart
import 'package:absen/features/dashboard/dashboard_screen.dart';
import 'package:absen/features/history/history_screen.dart';
import 'package:absen/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  int _selectedIndex = 0;

  // create the pages once so their state is preserved
  final List<Widget> _pages = const [
    DashboardScreen(key: PageStorageKey('dashboard')),
    HistoryScreen(key: PageStorageKey('history')),
    ProfileScreen(key: PageStorageKey('profile')),
  ];

  // optional page storage bucket if you want scroll position preserved globally
  final PageStorageBucket _bucket = PageStorageBucket();

  void _onTap(int idx) {
    if (_selectedIndex == idx) {
      // tapped same tab — optionally pop to first route or scroll to top
      return;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar bisa berubah per tab — jika mau, handle conditional AppBar here
      // appBar: AppBar(
      //   title: Text(
      //     _selectedIndex == 0
      //         ? 'Dashboard'
      //         // : _selectedIndex == 1
      //         // ? 'Attendance'
      //         : 'Profile',
      //   ),
      //   backgroundColor: const Color(0xFF4A60F0), // primary
      // ),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: const Color(0xFF0EA5E9), // sky-500
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

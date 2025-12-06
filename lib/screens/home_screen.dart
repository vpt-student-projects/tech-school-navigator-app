import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'floors_screen.dart';
import 'news_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  bool _roleLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      final res = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = (res['role'] as String?) ?? 'user';

      if (mounted) {
        setState(() {
          _isAdmin = role == 'admin';
          _roleLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _roleLoaded = true;
        });
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const FloorsScreen(),
      const NewsScreen(embedded: true),
    ];

    final titles = <String>[
      'Карта',
      'Новости',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          if (_roleLoaded && _isAdmin)
            IconButton(
              tooltip: 'Админ-панель',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Новости',
          ),
        ],
      ),
    );
  }
}

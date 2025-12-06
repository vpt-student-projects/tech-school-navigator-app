import 'package:flutter/material.dart';
import '../services/floor_repo.dart';
import '../models/floor.dart';
import 'map_screen.dart';

class FloorsScreen extends StatefulWidget {
  const FloorsScreen({super.key});

  @override
  State<FloorsScreen> createState() => _FloorsScreenState();
}

class _FloorsScreenState extends State<FloorsScreen> {
  final _repo = FloorRepo();
  late Future<List<Floor>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchFloors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Выбор этажа',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Floor>>(
                future: _future,
                builder: (c, s) {
                  if (s.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (s.hasError) {
                    return Center(child: Text('Ошибка: ${s.error}'));
                  }
                  final floors = s.data ?? [];

                  if (floors.isEmpty) {
                    return const Center(
                      child: Text('Этажи не найдены'),
                    );
                  }

                  return ListView.builder(
                    itemCount: floors.length,
                    itemBuilder: (_, i) {
                      final f = floors[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          title: Text(
                            f.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(floorId: f.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

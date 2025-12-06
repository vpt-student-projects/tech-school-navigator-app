import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/users/users_bloc.dart';
import '../blocs/users/users_event.dart';
import '../blocs/users/users_state.dart';
import '../models/user_profile.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersBloc()..add(const UsersLoadRequested()),
      child: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Админ панель'),
            ),
            body: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state is UsersInitial || state is UsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UsersFailure) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                } else if (state is UsersLoaded) {
                  return _UsersList(users: state.users);
                } else {
                  return const SizedBox.shrink(); // запасной вариант
                }
              },
            ),

          );
        },
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  final List<UserProfile> users;

  const _UsersList({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Пользователей пока нет'));
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final u = users[index];

        final subtitleParts = <String>[];
        if (u.groups != null && u.groups!.isNotEmpty) {
          subtitleParts.add('Группа: ${u.groups}');
        }
        subtitleParts.add('Роль: ${u.role}');

        return ListTile(
          title: Text(u.fullName ?? u.email),
          subtitle: Text(subtitleParts.join(' · ')),
          onTap: () => _showEditDialog(context, u),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              context.read<UsersBloc>().add(
                    UserRoleChanged(id: u.id, role: value),
                  );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'user',
                child: Text('Сделать пользователем'),
              ),
              PopupMenuItem(
                value: 'admin',
                child: Text('Сделать админом'),
              ),
              PopupMenuItem(
                value: 'blocked',
                child: Text('Заблокировать'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, UserProfile user) {
    final nameCtrl = TextEditingController(text: user.fullName ?? '');
    final groupCtrl = TextEditingController(text: user.groups ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Редактировать пользователя'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: groupCtrl,
                decoration: const InputDecoration(labelText: 'Группа'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<UsersBloc>().add(
                      UserProfileUpdated(
                        id: user.id,
                        fullName: nameCtrl.text.trim(),
                        group: groupCtrl.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

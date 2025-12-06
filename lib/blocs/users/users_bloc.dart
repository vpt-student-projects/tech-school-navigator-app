import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_profile.dart';
import '../../services/users_service.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersService service;

  UsersBloc({UsersService? service})
      : service = service ?? UsersService(),
        super(UsersInitial()) {
    on<UsersLoadRequested>(_onLoad);
    on<UserProfileUpdated>(_onProfileUpdated);
    on<UserRoleChanged>(_onRoleChanged);
  }

  Future<void> _onLoad(
    UsersLoadRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final users = await service.fetchUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersFailure(e.toString()));
    }
  }

  Future<void> _onProfileUpdated(
    UserProfileUpdated event,
    Emitter<UsersState> emit,
  ) async {
    final current = state;
    if (current is! UsersLoaded) return;

    try {
      final updated = await service.updateProfile(
        id: event.id,
        fullName: event.fullName,
        group: event.group,
      );

      final newList = current.users
          .map((u) => u.id == updated.id ? updated : u)
          .toList();
      emit(UsersLoaded(newList));
    } catch (e) {
      emit(UsersFailure(e.toString()));
      // после ошибки можно перезагрузить список:
      add(const UsersLoadRequested());
    }
  }

  Future<void> _onRoleChanged(
    UserRoleChanged event,
    Emitter<UsersState> emit,
  ) async {
    final current = state;
    if (current is! UsersLoaded) return;

    try {
      UserProfile updated;
      if (event.role == 'admin') {
        updated = await service.makeAdmin(event.id);
      } else if (event.role == 'blocked') {
        updated = await service.blockUser(event.id);
      } else {
        updated = await service.updateProfile(id: event.id, role: 'user');
      }

      final newList = current.users
          .map((u) => u.id == updated.id ? updated : u)
          .toList();
      emit(UsersLoaded(newList));
    } catch (e) {
      emit(UsersFailure(e.toString()));
      add(const UsersLoadRequested());
    }
  }
}

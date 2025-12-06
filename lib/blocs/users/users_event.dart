import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class UsersLoadRequested extends UsersEvent {
  const UsersLoadRequested();
}

class UserProfileUpdated extends UsersEvent {
  final String id;
  final String? fullName;
  final String? group;

  const UserProfileUpdated({
    required this.id,
    this.fullName,
    this.group,
  });

  @override
  List<Object?> get props => [id, fullName, group];
}

class UserRoleChanged extends UsersEvent {
  final String id;
  final String role; // user / admin / blocked

  const UserRoleChanged({
    required this.id,
    required this.role,
  });

  @override
  List<Object?> get props => [id, role];
}

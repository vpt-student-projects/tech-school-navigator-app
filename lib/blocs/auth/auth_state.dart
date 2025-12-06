import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../models/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserProfile? profile; // можно будет подгружать профиль из таблицы profiles

  const AuthAuthenticated(this.user, {this.profile});

  @override
  List<Object?> get props => [user, profile];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

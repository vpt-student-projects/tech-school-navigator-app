import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UsersService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<UserProfile>> fetchUsers() async {
    final res = await _db
        .from('profiles')
        .select()
        .order('created_at', ascending: true);

    final list = List<Map<String, dynamic>>.from(res);
    return list.map(UserProfile.fromJson).toList();
  }

  Future<UserProfile> updateProfile({
    required String id,
    String? fullName,
    String? group,
    String? role,
  }) async {
    final updateData = <String, dynamic>{};
    if (fullName != null) updateData['full_name'] = fullName;
    if (group != null) updateData['groups'] = group;
    if (role != null) updateData['role'] = role;

    final res = await _db
        .from('profiles')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return UserProfile.fromJson(Map<String, dynamic>.from(res));
  }

  /// "Блокировка" — просто ставим роль blocked.
  Future<UserProfile> blockUser(String id) {
    return updateProfile(id: id, role: 'blocked');
  }

  /// Разблокировать — вернуть в user
  Future<UserProfile> unblockUser(String id) {
    return updateProfile(id: id, role: 'user');
  }

  /// Сделать админом
  Future<UserProfile> makeAdmin(String id) {
    return updateProfile(id: id, role: 'admin');
  }
}

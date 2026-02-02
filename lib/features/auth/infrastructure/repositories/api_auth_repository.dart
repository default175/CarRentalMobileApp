import 'dart:async';

import '../../../../core/services/local_app_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/app_role.dart';
import '../../../../shared/models/app_user.dart';
import '../../domain/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._storage)
      : _currentUser = _storage.sessionUser;

  final ApiClient _client;
  final LocalAppStorage _storage;

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final user = _mapUser(response.data ?? const {});
    _currentUser = user;
    await _storage.saveSessionUser(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'license_number': licenseNumber?.trim(),
      },
    );

    final user = _mapUser(response.data ?? const {});
    _currentUser = user;
    await _storage.saveSessionUser(user);
    return user;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      '/api/users/${user.id}',
      data: {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.name,
        'license_number': user.licenseNumber,
        'photo_url': user.photoUrl,
      },
    );

    final updated = _mapUser(response.data ?? const {});
    _currentUser = updated;
    await _storage.saveSessionUser(updated);
    return updated;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _storage.saveSessionUser(null);
  }

  AppUser _mapUser(Map<String, dynamic> raw) {
    return AppUser(
      id: raw['id'] as String,
      name: raw['name'] as String,
      email: raw['email'] as String,
      phone: raw['phone'] as String,
      role: (raw['role'] as String) == AppRole.admin.name
          ? AppRole.admin
          : AppRole.user,
      licenseNumber: raw['license_number'] as String?,
      photoUrl: raw['photo_url'] as String?,
      createdAt: raw['created_at'] == null
          ? null
          : DateTime.parse(raw['created_at'] as String),
      isBlocked: raw['blocked'] as bool? ?? false,
    );
  }
}

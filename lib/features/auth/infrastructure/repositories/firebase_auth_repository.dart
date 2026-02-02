import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../shared/models/app_role.dart';
import '../../../../shared/models/app_user.dart';
import '../../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }

      return _mapUser(user);
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a user.');
    }

    return _mapUser(user);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a user.');
    }

    if (name.trim().isNotEmpty) {
      await user.updateDisplayName(name.trim());
    }

    await user.reload();
    return _mapUser(_auth.currentUser ?? user);
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    final current = _auth.currentUser;
    if (current == null) {
      throw StateError('No authenticated Firebase user.');
    }

    await current.updateDisplayName(user.name);
    await current.updatePhotoURL(user.photoUrl);
    if (current.email != user.email && user.email.isNotEmpty) {
      await current.verifyBeforeUpdateEmail(user.email);
    }
    await current.reload();
    return _mapUser(_auth.currentUser ?? current);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  AppUser _mapUser(fb.User user) {
    final normalizedEmail = (user.email ?? '').toLowerCase();
    final isAdmin = normalizedEmail == 'admin@demo.app' ||
        normalizedEmail.endsWith('@admin.carrental.app');

    return AppUser(
      id: user.uid,
      name: user.displayName ?? normalizedEmail.ifEmpty('Firebase User'),
      email: normalizedEmail,
      phone: user.phoneNumber ?? '',
      role: isAdmin ? AppRole.admin : AppRole.user,
      photoUrl: user.photoURL,
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

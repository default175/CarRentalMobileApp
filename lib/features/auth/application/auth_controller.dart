import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../../shared/models/app_role.dart';
import '../../../shared/models/app_user.dart';
import '../domain/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _authSubscription = _repository.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;

  AppUser? get currentUser => _repository.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _repository.signIn(email: email, password: password);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  }) async {
    await _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      licenseNumber: licenseNumber,
    );
    notifyListeners();
  }

  Future<void> updateProfile(AppUser user) async {
    await _repository.updateProfile(user);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    notifyListeners();
  }

  AppRole get currentRole => currentUser?.role ?? AppRole.user;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

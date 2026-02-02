import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_app_storage.dart';
import '../../../../shared/demo/demo_data_store.dart';
import '../../../../shared/models/app_user.dart';
import '../../domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._store, this._storage)
      : _currentUser = _restoreCurrentUser(_store, _storage);

  final DemoDataStore _store;
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
    if (email.isEmpty || password.isEmpty) {
      throw StateError('Email and password are required.');
    }

    final normalized = email.trim().toLowerCase();
    _currentUser =
        _store.findUserByEmail(normalized) ??
            _store.findUserByEmail(AppConstants.demoUserEmail);
    await _storage.saveSessionUser(_currentUser);

    return _currentUser!;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty) {
      throw StateError('All registration fields are required.');
    }

    if (_store.findUserByEmail(email.trim().toLowerCase()) != null) {
      throw StateError('User with this email already exists.');
    }

    _currentUser = _store.registerUser(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      licenseNumber: licenseNumber?.trim(),
    );
    await _storage.saveSessionUser(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    _store.saveUser(user);
    _currentUser = user;
    await _storage.saveSessionUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _storage.saveSessionUser(null);
  }

  static AppUser? _restoreCurrentUser(
    DemoDataStore store,
    LocalAppStorage storage,
  ) {
    final saved = storage.sessionUser;
    if (saved == null) {
      return null;
    }

    final persisted = store.findUserById(saved.id) ?? saved;
    if (persisted != saved) {
      return persisted;
    }

    store.saveUser(saved);
    return saved;
  }
}

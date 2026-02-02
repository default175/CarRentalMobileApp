import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/app_user.dart';
import '../../domain/auth_repository.dart';

class HybridAuthRepository implements AuthRepository {
  HybridAuthRepository({
    required AuthRepository firebaseRepository,
    required AuthRepository fallbackRepository,
  })  : _firebaseRepository = firebaseRepository,
        _fallbackRepository = fallbackRepository;

  final AuthRepository _firebaseRepository;
  final AuthRepository _fallbackRepository;

  @override
  AppUser? get currentUser =>
      _firebaseRepository.currentUser ?? _fallbackRepository.currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield currentUser;
    yield* _firebaseRepository.authStateChanges();
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();

    if (_isDemoAccount(normalized)) {
      return _fallbackRepository.signIn(email: normalized, password: password);
    }

    return _firebaseRepository.signIn(email: normalized, password: password);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  }) async {
    if (_isDemoAccount(email.trim().toLowerCase())) {
      return _fallbackRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        licenseNumber: licenseNumber,
      );
    }

    return _firebaseRepository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      licenseNumber: licenseNumber,
    );
  }

  @override
  Future<AppUser> updateProfile(AppUser user) {
    if (_isDemoAccount(user.email.toLowerCase())) {
      return _fallbackRepository.updateProfile(user);
    }

    return _firebaseRepository.updateProfile(user);
  }

  @override
  Future<void> signOut() async {
    await _firebaseRepository.signOut();
    await _fallbackRepository.signOut();
  }

  bool _isDemoAccount(String email) {
    return email == AppConstants.demoUserEmail ||
        email == AppConstants.demoAdminEmail;
  }
}

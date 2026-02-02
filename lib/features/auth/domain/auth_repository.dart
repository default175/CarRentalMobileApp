import '../../../shared/models/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? licenseNumber,
  });

  Future<AppUser> updateProfile(AppUser user);

  Future<void> signOut();
}

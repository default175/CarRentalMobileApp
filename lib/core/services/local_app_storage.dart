import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/app_user.dart';

class LocalAppStorage {
  LocalAppStorage._();

  static final LocalAppStorage instance = LocalAppStorage._();

  static const _sessionUserKey = 'session_user';
  static const _persistedUsersKey = 'persisted_users';
  static const _locationOnboardingSeenKey = 'location_onboarding_seen';

  SharedPreferencesAsync? _prefs;

  bool _initialized = false;
  AppUser? _sessionUser;
  bool _locationOnboardingSeen = false;
  List<AppUser> _persistedUsers = const [];

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _prefs = SharedPreferencesAsync();

    final sessionRaw = await _prefs!.getString(_sessionUserKey);
    final usersRaw = await _prefs!.getString(_persistedUsersKey);
    _locationOnboardingSeen =
        await _prefs!.getBool(_locationOnboardingSeenKey) ?? false;

    if (sessionRaw != null && sessionRaw.isNotEmpty) {
      _sessionUser = AppUser.fromJsonString(sessionRaw);
    }

    if (usersRaw != null && usersRaw.isNotEmpty) {
      final decoded = jsonDecode(usersRaw) as List<dynamic>;
      _persistedUsers = decoded
          .map((item) => AppUser.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    }

    _initialized = true;
  }

  AppUser? get sessionUser => _sessionUser;

  List<AppUser> get persistedUsers => List<AppUser>.from(_persistedUsers);

  bool get locationOnboardingSeen => _locationOnboardingSeen;

  Future<void> saveSessionUser(AppUser? user) async {
    _sessionUser = user;
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    if (user == null) {
      await prefs.remove(_sessionUserKey);
      return;
    }

    await prefs.setString(_sessionUserKey, user.toJsonString());
  }

  Future<void> saveUsers(List<AppUser> users) async {
    _persistedUsers = List<AppUser>.from(users);
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    await prefs.setString(
      _persistedUsersKey,
      jsonEncode(_persistedUsers.map((user) => user.toJson()).toList()),
    );
  }

  Future<void> markLocationOnboardingSeen() async {
    _locationOnboardingSeen = true;
    await _prefs?.setBool(_locationOnboardingSeenKey, true);
  }

  void debugSeed({
    AppUser? sessionUser,
    List<AppUser>? persistedUsers,
    bool? locationOnboardingSeen,
  }) {
    _sessionUser = sessionUser;
    _persistedUsers = persistedUsers ?? _persistedUsers;
    _locationOnboardingSeen = locationOnboardingSeen ?? _locationOnboardingSeen;
    _initialized = true;
  }
}

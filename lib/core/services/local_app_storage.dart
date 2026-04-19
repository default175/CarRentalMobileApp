import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/app_user.dart';
import '../../shared/models/payment_method_option.dart';

class LocalAppStorage {
  LocalAppStorage._();

  static final LocalAppStorage instance = LocalAppStorage._();

  static const _sessionUserKey = 'session_user';
  static const _persistedUsersKey = 'persisted_users';
  static const _locationOnboardingSeenKey = 'location_onboarding_seen';
  static const _apiBaseUrlOverrideKey = 'api_base_url_override';
  static const _backendApiEnabledOverrideKey = 'backend_api_enabled_override';
  static const _viewedNotificationIdsKey = 'viewed_notification_ids';
  static const _themeModeKey = 'theme_mode';
  static const _paymentMethodsKey = 'payment_methods';
  static const _selectedPaymentMethodKey = 'selected_payment_method';
  static const _favoriteCarIdsKey = 'favorite_car_ids';
  static const _pushNotificationsEnabledKey = 'push_notifications_enabled';

  SharedPreferencesAsync? _prefs;

  bool _initialized = false;
  AppUser? _sessionUser;
  bool _locationOnboardingSeen = false;
  String? _apiBaseUrlOverride;
  bool? _backendApiEnabledOverride;
  Set<String> _viewedNotificationIds = <String>{};
  String _themeModeName = 'light';
  List<PaymentMethodOption> _paymentMethods = PaymentMethodOption.defaults;
  String _selectedPaymentMethodId = 'card-4242';
  List<AppUser> _persistedUsers = const [];
  Set<String> _favoriteCarIds = <String>{};
  bool _pushNotificationsEnabled = true;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _prefs = SharedPreferencesAsync();

    final sessionRaw = await _prefs!.getString(_sessionUserKey);
    final usersRaw = await _prefs!.getString(_persistedUsersKey);
    _locationOnboardingSeen =
        await _prefs!.getBool(_locationOnboardingSeenKey) ?? false;
    _apiBaseUrlOverride = await _prefs!.getString(_apiBaseUrlOverrideKey);
    _backendApiEnabledOverride =
        await _prefs!.getBool(_backendApiEnabledOverrideKey);
    final viewedRaw = await _prefs!.getString(_viewedNotificationIdsKey);
    if (viewedRaw != null && viewedRaw.isNotEmpty) {
      _viewedNotificationIds =
          (jsonDecode(viewedRaw) as List<dynamic>).cast<String>().toSet();
    }
    _themeModeName = await _prefs!.getString(_themeModeKey) ?? 'light';
    _selectedPaymentMethodId =
        await _prefs!.getString(_selectedPaymentMethodKey) ?? 'card-4242';
    _pushNotificationsEnabled =
        await _prefs!.getBool(_pushNotificationsEnabledKey) ?? true;
    final paymentMethodsRaw = await _prefs!.getString(_paymentMethodsKey);
    if (paymentMethodsRaw != null && paymentMethodsRaw.isNotEmpty) {
      _paymentMethods = (jsonDecode(paymentMethodsRaw) as List<dynamic>)
          .map((item) => PaymentMethodOption.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    }
    final favoriteCarIdsRaw = await _prefs!.getString(_favoriteCarIdsKey);
    if (favoriteCarIdsRaw != null && favoriteCarIdsRaw.isNotEmpty) {
      _favoriteCarIds = (jsonDecode(favoriteCarIdsRaw) as List<dynamic>)
          .cast<String>()
          .toSet();
    }

    if (sessionRaw != null && sessionRaw.isNotEmpty) {
      _sessionUser = AppUser.fromJsonString(sessionRaw);
    }

    if (usersRaw != null && usersRaw.isNotEmpty) {
      final decoded = jsonDecode(usersRaw) as List<dynamic>;
      _persistedUsers = decoded
          .map((item) =>
              AppUser.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    }

    _initialized = true;
  }

  AppUser? get sessionUser => _sessionUser;

  List<AppUser> get persistedUsers => List<AppUser>.from(_persistedUsers);

  bool get locationOnboardingSeen => _locationOnboardingSeen;

  String? get apiBaseUrlOverride => _apiBaseUrlOverride;

  bool? get backendApiEnabledOverride => _backendApiEnabledOverride;

  Set<String> get viewedNotificationIds =>
      Set<String>.from(_viewedNotificationIds);

  String get themeModeName => _themeModeName;

  List<PaymentMethodOption> get paymentMethods =>
      List<PaymentMethodOption>.from(_paymentMethods);

  String get selectedPaymentMethodId => _selectedPaymentMethodId;

  Set<String> get favoriteCarIds => Set<String>.from(_favoriteCarIds);

  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

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

  Future<void> saveApiConnectionSettings({
    required String baseUrl,
    required bool enabled,
  }) async {
    _apiBaseUrlOverride = baseUrl;
    _backendApiEnabledOverride = enabled;
    await _prefs?.setString(_apiBaseUrlOverrideKey, baseUrl);
    await _prefs?.setBool(_backendApiEnabledOverrideKey, enabled);
  }

  Future<void> clearApiConnectionSettings() async {
    _apiBaseUrlOverride = null;
    _backendApiEnabledOverride = null;
    await _prefs?.remove(_apiBaseUrlOverrideKey);
    await _prefs?.remove(_backendApiEnabledOverrideKey);
  }

  Future<void> saveViewedNotificationIds(Set<String> ids) async {
    _viewedNotificationIds = Set<String>.from(ids);
    await _prefs?.setString(
      _viewedNotificationIdsKey,
      jsonEncode(_viewedNotificationIds.toList(growable: false)),
    );
  }

  Future<void> saveThemeModeName(String modeName) async {
    _themeModeName = modeName;
    await _prefs?.setString(_themeModeKey, modeName);
  }

  Future<void> savePaymentMethods(List<PaymentMethodOption> methods) async {
    _paymentMethods = List<PaymentMethodOption>.from(methods);
    await _prefs?.setString(
      _paymentMethodsKey,
      jsonEncode(_paymentMethods.map((method) => method.toJson()).toList()),
    );
  }

  Future<void> saveSelectedPaymentMethodId(String id) async {
    _selectedPaymentMethodId = id;
    await _prefs?.setString(_selectedPaymentMethodKey, id);
  }

  Future<void> saveFavoriteCarIds(Set<String> ids) async {
    _favoriteCarIds = Set<String>.from(ids);
    await _prefs?.setString(
      _favoriteCarIdsKey,
      jsonEncode(_favoriteCarIds.toList(growable: false)),
    );
  }

  Future<void> savePushNotificationsEnabled(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    await _prefs?.setBool(_pushNotificationsEnabledKey, enabled);
  }

  void debugSeed({
    AppUser? sessionUser,
    List<AppUser>? persistedUsers,
    bool? locationOnboardingSeen,
    String? apiBaseUrlOverride,
    bool? backendApiEnabledOverride,
    Set<String>? viewedNotificationIds,
    String? themeModeName,
    List<PaymentMethodOption>? paymentMethods,
    String? selectedPaymentMethodId,
    Set<String>? favoriteCarIds,
    bool? pushNotificationsEnabled,
  }) {
    _sessionUser = sessionUser;
    _persistedUsers = persistedUsers ?? _persistedUsers;
    _locationOnboardingSeen = locationOnboardingSeen ?? _locationOnboardingSeen;
    _apiBaseUrlOverride = apiBaseUrlOverride ?? _apiBaseUrlOverride;
    _backendApiEnabledOverride =
        backendApiEnabledOverride ?? _backendApiEnabledOverride;
    _viewedNotificationIds = viewedNotificationIds ?? _viewedNotificationIds;
    _themeModeName = themeModeName ?? _themeModeName;
    _paymentMethods = paymentMethods ?? _paymentMethods;
    _selectedPaymentMethodId =
        selectedPaymentMethodId ?? _selectedPaymentMethodId;
    _favoriteCarIds = favoriteCarIds ?? _favoriteCarIds;
    _pushNotificationsEnabled =
        pushNotificationsEnabled ?? _pushNotificationsEnabled;
    _initialized = true;
  }
}

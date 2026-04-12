import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../location/location_access_controller.dart';
import '../location/location_access_state.dart';
import '../network/api_connection_controller.dart';
import '../network/api_connection_settings.dart';
import '../../features/admin/domain/admin_repository.dart';
import '../../features/admin/infrastructure/repositories/api_admin_repository.dart';
import '../../features/admin/infrastructure/repositories/fake_admin_repository.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/infrastructure/repositories/api_auth_repository.dart';
import '../../features/auth/infrastructure/repositories/fake_auth_repository.dart';
import '../../features/auth/infrastructure/repositories/firebase_auth_repository.dart';
import '../../features/auth/infrastructure/repositories/hybrid_auth_repository.dart';
import '../../features/bookings/application/bookings_controller.dart';
import '../../features/bookings/domain/bookings_repository.dart';
import '../../features/bookings/infrastructure/repositories/api_bookings_repository.dart';
import '../../features/bookings/infrastructure/repositories/fake_bookings_repository.dart';
import '../../features/cars/domain/cars_repository.dart';
import '../../features/cars/infrastructure/repositories/api_cars_repository.dart';
import '../../features/cars/infrastructure/repositories/fake_cars_repository.dart';
import '../../features/notifications/domain/notifications_repository.dart';
import '../../features/notifications/infrastructure/repositories/api_notifications_repository.dart';
import '../../features/notifications/infrastructure/repositories/fake_notifications_repository.dart';
import '../../features/tracking/domain/tracking_repository.dart';
import '../../features/tracking/infrastructure/repositories/api_tracking_repository.dart';
import '../../features/tracking/infrastructure/repositories/fake_tracking_repository.dart';
import '../../features/tracking/infrastructure/repositories/firebase_tracking_repository.dart';
import '../network/api_client.dart';
import '../config/app_config.dart';
import '../routing/app_router.dart';
import '../services/local_app_storage.dart';
import '../services/push_notifications_service.dart';
import '../theme/theme_mode_controller.dart';
import '../../shared/demo/demo_data_store.dart';
import '../../shared/models/app_notification.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/car.dart';
import '../../shared/models/car_review.dart';
import '../../shared/models/payment_method_option.dart';
import '../../shared/models/tracking_snapshot.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(demoDataStoreProvider);
  final storage = ref.watch(localAppStorageProvider);
  final apiSettings = ref.watch(apiConnectionSettingsProvider);
  if (apiSettings.shouldUseBackend) {
    return ApiAuthRepository(ref.watch(apiClientProvider), storage);
  }

  if (!AppConfig.runtime.shouldUseFakeRepositories) {
    return HybridAuthRepository(
      firebaseRepository: FirebaseAuthRepository(fb.FirebaseAuth.instance),
      fallbackRepository: FakeAuthRepository(store, storage),
    );
  }

  return FakeAuthRepository(store, storage);
});

final localAppStorageProvider = Provider<LocalAppStorage>((ref) {
  return LocalAppStorage.instance;
});

final demoDataStoreProvider = Provider<DemoDataStore>((ref) {
  return DemoDataStore(ref.watch(localAppStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(apiConnectionSettingsProvider);
  return ApiClient(baseUrl: settings.baseUrl);
});

final apiConnectionSettingsProvider =
    StateNotifierProvider<ApiConnectionController, ApiConnectionSettings>(
        (ref) {
  return ApiConnectionController(ref.watch(localAppStorageProvider));
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

final carsRepositoryProvider = Provider<CarsRepository>((ref) {
  if (ref.watch(apiConnectionSettingsProvider).shouldUseBackend) {
    return ApiCarsRepository(ref.watch(apiClientProvider));
  }

  return FakeCarsRepository(ref.watch(demoDataStoreProvider));
});

final carsProvider = FutureProvider<List<Car>>((ref) {
  return ref.watch(carsRepositoryProvider).fetchCars();
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  if (ref.watch(apiConnectionSettingsProvider).shouldUseBackend) {
    return ApiBookingsRepository(ref.watch(apiClientProvider));
  }

  return FakeBookingsRepository(ref.watch(demoDataStoreProvider));
});

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, AsyncValue<List<Booking>>>((ref) {
  return BookingsController(ref.watch(bookingsRepositoryProvider));
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  if (ref.watch(apiConnectionSettingsProvider).shouldUseBackend) {
    return ApiTrackingRepository(ref.watch(apiClientProvider));
  }

  if (AppConfig.runtime.isRealtimeDatabaseConfigured) {
    return FirebaseTrackingRepository(FirebaseDatabase.instance);
  }

  return FakeTrackingRepository();
});

final trackingStreamProvider =
    StreamProvider.family<TrackingSnapshot, String>((ref, carId) {
  return ref.watch(trackingRepositoryProvider).watchCar(carId);
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  if (ref.watch(apiConnectionSettingsProvider).shouldUseBackend) {
    return ApiNotificationsRepository(ref.watch(apiClientProvider));
  }

  return FakeNotificationsRepository(ref.watch(demoDataStoreProvider));
});

final notificationsRefreshTickProvider = StreamProvider<int>((ref) async* {
  yield 0;
  await for (final tick
      in Stream<int>.periodic(const Duration(seconds: 30), (v) => v + 1)) {
    yield tick;
  }
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  ref.watch(notificationsRefreshTickProvider);
  final expiresAt = DateTime.now().subtract(const Duration(days: 30));
  return ref.watch(notificationsRepositoryProvider).fetchNotifications().then(
    (items) {
      final visible = items
          .where((item) => item.createdAt.isAfter(expiresAt))
          .toList(growable: false);
      final viewed = ref.read(viewedNotificationIdsProvider);
      final pushEnabled = ref.watch(pushNotificationsEnabledProvider);
      PushNotificationsService.instance
          ?.setLocalNotificationsEnabled(pushEnabled);
      if (pushEnabled) {
        for (final item in visible) {
          if (!viewed.contains(item.id)) {
            PushNotificationsService.instance?.showLocalNotification(
              notificationId: item.id,
              title: item.title,
              body: item.message,
            );
          }
        }
      }
      return visible;
    },
  );
});

final viewedNotificationIdsProvider = StateProvider<Set<String>>((ref) {
  return ref.watch(localAppStorageProvider).viewedNotificationIds;
});

final hiddenNotificationIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final viewed = ref.watch(viewedNotificationIdsProvider);
  final notifications = ref.watch(notificationsProvider);

  return notifications.maybeWhen(
    data: (items) => items.where((item) => !viewed.contains(item.id)).length,
    orElse: () => 0,
  );
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  if (ref.watch(apiConnectionSettingsProvider).shouldUseBackend) {
    return ApiAdminRepository(ref.watch(apiClientProvider));
  }

  return FakeAdminRepository(ref.watch(demoDataStoreProvider));
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(localAppStorageProvider));
});

final locationAccessControllerProvider =
    StateNotifierProvider<LocationAccessController, LocationAccessState>((ref) {
  return LocationAccessController(ref.watch(localAppStorageProvider));
});

final selectedCarProvider = StateProvider<String?>((ref) => null);

final favoriteCarIdsProvider = StateProvider<Set<String>>((ref) {
  return ref.watch(localAppStorageProvider).favoriteCarIds;
});

final pushNotificationsEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(localAppStorageProvider).pushNotificationsEnabled;
});

final paymentMethodsProvider = StateProvider<List<PaymentMethodOption>>((ref) {
  return ref.watch(localAppStorageProvider).paymentMethods;
});

final selectedPaymentMethodProvider = StateProvider<String>((ref) {
  return ref.watch(localAppStorageProvider).selectedPaymentMethodId;
});

final carReviewsProvider = StateProvider<List<CarReview>>((ref) {
  return [
    CarReview(
      id: 'review-1',
      userId: 'user-1',
      userName: 'Aruzhan S.',
      carId: 'car-1',
      carName: 'Tesla Model 3',
      rating: 5,
      comment: 'Clean car, fast pickup and accurate range estimate.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});

final carByIdProvider = FutureProvider.family<Car?, String>((ref, carId) {
  return ref.watch(carsRepositoryProvider).getCarById(carId);
});

final adminOverviewProvider = FutureProvider<AdminOverview>((ref) {
  return ref.watch(adminRepositoryProvider).fetchOverview();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);
  return buildRouter(authController);
});

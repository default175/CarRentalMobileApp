import 'package:geolocator/geolocator.dart';

import '../../shared/models/geo_point.dart';

class LocationAccessState {
  const LocationAccessState({
    required this.onboardingSeen,
    required this.requestInProgress,
    required this.serviceEnabled,
    required this.permission,
    this.currentLocation,
    this.errorMessage,
  });

  final bool onboardingSeen;
  final bool requestInProgress;
  final bool serviceEnabled;
  final LocationPermission permission;
  final GeoPoint? currentLocation;
  final String? errorMessage;

  bool get shouldShowOnboarding => !onboardingSeen;

  bool get hasPermission =>
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;

  bool get canUseLocation => hasPermission && currentLocation != null;

  LocationAccessState copyWith({
    bool? onboardingSeen,
    bool? requestInProgress,
    bool? serviceEnabled,
    LocationPermission? permission,
    GeoPoint? currentLocation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationAccessState(
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      requestInProgress: requestInProgress ?? this.requestInProgress,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      permission: permission ?? this.permission,
      currentLocation: currentLocation ?? this.currentLocation,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const initial = LocationAccessState(
    onboardingSeen: false,
    requestInProgress: false,
    serviceEnabled: false,
    permission: LocationPermission.unableToDetermine,
  );
}

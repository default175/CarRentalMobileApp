import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../shared/models/geo_point.dart';
import '../services/local_app_storage.dart';
import 'location_access_state.dart';

class LocationAccessController extends StateNotifier<LocationAccessState> {
  LocationAccessController(this._storage)
      : super(
          LocationAccessState.initial.copyWith(
            onboardingSeen: _storage.locationOnboardingSeen,
          ),
        ) {
    _loadCurrentState();
  }

  final LocalAppStorage _storage;

  Future<void> _loadCurrentState() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      state = state.copyWith(
        serviceEnabled: serviceEnabled,
        permission: permission,
        clearError: true,
      );

      if (_canReadLocation(permission, serviceEnabled)) {
        await refreshLocation();
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: '$error',
        requestInProgress: false,
      );
    }
  }

  Future<void> requestAccess() async {
    try {
      state = state.copyWith(requestInProgress: true, clearError: true);
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();

      if (!serviceEnabled) {
        await _storage.markLocationOnboardingSeen();
        state = state.copyWith(
          onboardingSeen: true,
          requestInProgress: false,
          serviceEnabled: false,
          permission: permission,
          errorMessage: 'Location services are disabled on this device.',
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      await _storage.markLocationOnboardingSeen();
      state = state.copyWith(
        onboardingSeen: true,
        serviceEnabled: serviceEnabled,
        permission: permission,
        requestInProgress: false,
        clearError: true,
      );

      if (_canReadLocation(permission, serviceEnabled)) {
        await refreshLocation();
        return;
      }

      state = state.copyWith(
        errorMessage:
            'Location access was not granted. The map will work in limited mode until permission is enabled.',
      );
    } catch (error) {
      await _storage.markLocationOnboardingSeen();
      state = state.copyWith(
        onboardingSeen: true,
        requestInProgress: false,
        errorMessage: '$error',
      );
      return;
    }
  }

  Future<void> continueWithoutLocation() async {
    await _storage.markLocationOnboardingSeen();
    state = state.copyWith(onboardingSeen: true, clearError: true);
  }

  Future<void> refreshLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      state = state.copyWith(
        currentLocation: GeoPoint(lat: position.latitude, lng: position.longitude),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: '$error');
    }
  }

  bool _canReadLocation(LocationPermission permission, bool serviceEnabled) {
    return serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever &&
        permission != LocationPermission.unableToDetermine;
  }
}

import 'package:alchemy/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as location_backend;
import 'package:alchemy/data/location.dart';

class LocationService {
  static final LocationService instance = LocationService();

  bool get isInitialized => _isInitialized;

  final location_backend.Location _location = location_backend.Location();
  bool _isEnabled = false;
  bool _isInitialized = false;
  location_backend.PermissionStatus? _permissionStatus;

  Future<void> initialize() async {
    if (_isInitialized) throw StateError('already initialized');
    _isInitialized = true;

    _isEnabled = await _location.serviceEnabled();
    if (!_isEnabled) {
      _isEnabled = await _location.requestService();
      if (!_isEnabled) throw LocationServiceUnavailableException();
    }

    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == location_backend.PermissionStatus.deniedForever) {
      throw LocationServicePermissionException();
    }

    if (_permissionStatus == location_backend.PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != location_backend.PermissionStatus.granted) {
        throw LocationServicePermissionException();
      }
    }
  }

  Future<Location> getLocation() async {
    _checkInit();

    if (kDebugMode) {
      // Location doesn't work on iOS simulators, and
      // is a bit of a pain to set up in Android emulators.
      // So, if we're in debug mode, just return a preset location.
      return Location(49.94081, -119.39454);
    }

    final location = await _location.getLocation().timeout(
        const Duration(minutes: 1),
        onTimeout: () => throw LocationServiceTimeoutException());

    Logger.debug(runtimeType, location.toString());
    if (location.latitude == null || location.longitude == null) {
      throw LocationServiceInvalidException('latitude/longitude');
    }

    return Location(location.latitude!, location.longitude!);
  }

  Future<String?> getLocationName(Location location) async {
    final placemark = await getPlacemark(location);
    return placemark?.locality;
  }

  Future<geocoding.Placemark?> getPlacemark(Location location) async {
    _checkInit();

    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
          location.latitude, location.longitude);
      if (placemarks.isEmpty) return null;
      return placemarks[0];
    } on PlatformException catch (e) {
      Logger.warnException(runtimeType, e);
      return null;
    } on Exception catch (e) {
      throw LocationServiceGeocodingException(e);
    }
  }

  Future<void> requestPermission() async {
    if (!_isInitialized) throw StateError('not initialized');

    if (!_isEnabled) _isEnabled = await _location.requestService();
    if (!_isEnabled) throw LocationServiceUnavailableException();

    if (_permissionStatus != location_backend.PermissionStatus.granted) {
      _permissionStatus = await _location.requestPermission();
    }

    if (_permissionStatus != location_backend.PermissionStatus.granted) {
      throw LocationServicePermissionException();
    }
  }

  void _checkInit() {
    if (!_isInitialized) throw StateError('not initialized');
    if (!_isEnabled) throw LocationServiceUnavailableException();
    if (_permissionStatus != location_backend.PermissionStatus.granted) {
      throw LocationServicePermissionException();
    }
  }
}

abstract class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() {
    return 'Location Service Exception: $message';
  }
}

class LocationServiceGeocodingException extends LocationServiceException {
  LocationServiceGeocodingException(Exception inner) : super(inner.toString());
}

class LocationServiceInvalidException extends LocationServiceException {
  LocationServiceInvalidException(String property)
      : super('location had invalid $property');
}

class LocationServicePermissionException extends LocationServiceException {
  LocationServicePermissionException()
      : super('location service permission was denied');
}

class LocationServiceTimeoutException extends LocationServiceException {
  LocationServiceTimeoutException() : super('location service timed out');
}

class LocationServiceUnavailableException extends LocationServiceException {
  LocationServiceUnavailableException()
      : super('location service is unavailable');
}

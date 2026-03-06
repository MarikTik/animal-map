import 'package:permission_handler/permission_handler.dart';

/// Abstract interface for location permission operations.
///
/// Enables dependency inversion so that callers depend on an abstraction
/// rather than a concrete permission library. This makes the service
/// injectable and mockable in tests.
abstract class LocationPermissionService {
  /// Checks whether location permission is currently granted.
  Future<bool> isGranted();

  /// Requests location permission from the user.
  ///
  /// Returns `true` if permission was granted (or was already granted),
  /// `false` otherwise.
  Future<bool> request();

  /// Returns the current [PermissionStatus] for location.
  Future<PermissionStatus> status();
}

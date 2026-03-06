import 'package:permission_handler/permission_handler.dart';

import 'package:animal_map/services/location_permission_service.dart';

/// A fake implementation of [LocationPermissionService] for testing.
///
/// Allows tests to control permission state without touching the
/// real Android/iOS permission system.
class FakeLocationPermissionService implements LocationPermissionService {
  PermissionStatus _status;

  FakeLocationPermissionService({
    PermissionStatus initialStatus = PermissionStatus.denied,
  }) : _status = initialStatus;

  /// The status that [request] will transition to when called.
  PermissionStatus statusAfterRequest = PermissionStatus.granted;

  /// How many times [request] has been called.
  int requestCallCount = 0;

  @override
  Future<bool> isGranted() async {
    return _status.isGranted;
  }

  @override
  Future<bool> request() async {
    requestCallCount++;
    _status = statusAfterRequest;
    return _status.isGranted;
  }

  @override
  Future<PermissionStatus> status() async {
    return _status;
  }
}

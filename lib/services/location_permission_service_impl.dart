import 'package:permission_handler/permission_handler.dart';

import 'location_permission_service.dart';

/// Concrete implementation of [LocationPermissionService] using
/// the `permission_handler` package.
///
/// This is the production implementation that interacts with the
/// real Android/iOS permission system.
class LocationPermissionServiceImpl implements LocationPermissionService {
  @override
  Future<bool> isGranted() async {
    final currentStatus = await Permission.location.status;
    return currentStatus.isGranted;
  }

  @override
  Future<bool> request() async {
    final currentStatus = await Permission.location.request();
    return currentStatus.isGranted;
  }

  @override
  Future<PermissionStatus> status() {
    return Permission.location.status;
  }
}

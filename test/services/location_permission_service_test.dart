import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import '../fakes/fake_location_permission_service.dart';

void main() {
  group('LocationPermissionService (via Fake)', () {
    late FakeLocationPermissionService service;

    setUp(() {
      service = FakeLocationPermissionService();
    });

    test('isGranted returns false when permission is denied', () async {
      expect(await service.isGranted(), isFalse);
    });

    test('isGranted returns true when permission is granted', () async {
      service = FakeLocationPermissionService(
        initialStatus: PermissionStatus.granted,
      );

      expect(await service.isGranted(), isTrue);
    });

    test('status returns the current permission status', () async {
      expect(await service.status(), PermissionStatus.denied);

      service = FakeLocationPermissionService(
        initialStatus: PermissionStatus.permanentlyDenied,
      );
      expect(await service.status(), PermissionStatus.permanentlyDenied);
    });

    test('request transitions to granted and returns true', () async {
      expect(await service.isGranted(), isFalse);

      final result = await service.request();

      expect(result, isTrue);
      expect(await service.isGranted(), isTrue);
      expect(service.requestCallCount, 1);
    });

    test('request transitions to denied when configured', () async {
      service.statusAfterRequest = PermissionStatus.denied;

      final result = await service.request();

      expect(result, isFalse);
      expect(await service.isGranted(), isFalse);
      expect(service.requestCallCount, 1);
    });

    test('request transitions to permanentlyDenied when configured', () async {
      service.statusAfterRequest = PermissionStatus.permanentlyDenied;

      final result = await service.request();

      expect(result, isFalse);
      expect(await service.status(), PermissionStatus.permanentlyDenied);
    });

    test('multiple requests increment call count', () async {
      await service.request();
      await service.request();
      await service.request();

      expect(service.requestCallCount, 3);
    });

    test('request does not change status if already granted', () async {
      service = FakeLocationPermissionService(
        initialStatus: PermissionStatus.granted,
      );

      final result = await service.request();

      expect(result, isTrue);
      expect(await service.isGranted(), isTrue);
    });
  });
}

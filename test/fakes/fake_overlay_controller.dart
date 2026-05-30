import 'package:animal_map/services/overlay_controller.dart';

class FakeOverlayController implements OverlayController {
  bool permissionGranted = true;
  bool requestReturns = true;

  bool shown = false;
  bool hidden = false;
  int requestCount = 0;
  final List<Map<String, dynamic>> sent = [];

  @override
  Future<bool> isPermissionGranted() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    permissionGranted = requestReturns;
    return requestReturns;
  }

  @override
  Future<void> show() async => shown = true;

  @override
  Future<void> hide() async => hidden = true;

  @override
  Future<void> send(Map<String, dynamic> data) async => sent.add(data);
}

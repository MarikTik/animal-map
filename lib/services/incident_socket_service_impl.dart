import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/incident.dart';
import 'incident_message_decoder.dart';
import 'incident_socket_service.dart';

/// Production [IncidentSocketService] backed by [WebSocketChannel].
///
/// Owns connection lifecycle and delegates message parsing to an
/// injected [IncidentMessageDecoder] so the parsing path can be
/// tested directly without standing up a socket.
///
/// Exposes [incidents] as a **broadcast** stream so multiple consumers
/// (the marker sink, debug logging, …) can listen independently, and
/// supports [inject] for pushing synthetic incidents through the same
/// pipeline during demos.
class IncidentSocketServiceImpl implements IncidentSocketService {
  IncidentSocketServiceImpl({
    Uri? uri,
    IncidentMessageDecoder decoder = const IncidentMessageDecoder(),
  })  : _uri = uri ?? Uri.parse('wss://smart-wild.onrender.com/handshake'),
        _decoder = decoder;

  final Uri _uri;
  final IncidentMessageDecoder _decoder;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;

  final StreamController<Incident> _controller =
      StreamController<Incident>.broadcast();

  @override
  Stream<Incident> get incidents => _controller.stream;

  @override
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(_uri);
    await _channel!.ready;

    // Forward decoded socket messages into the broadcast controller. A bad
    // message is logged and skipped rather than tearing down the stream.
    _channelSub = _channel!.stream.listen(
      (message) {
        try {
          _controller.add(_decoder.decode(message as String));
        } catch (e) {
          // ignore: avoid_print
          print('Incident decode error: $e');
        }
      },
      onError: _controller.addError,
    );
  }

  /// Pushes a synthetic [incident] through the same broadcast stream as
  /// real socket traffic. Intended for demos and manual testing.
  void inject(Incident incident) => _controller.add(incident);

  @override
  Future<void> close() async {
    await _channelSub?.cancel();
    _channelSub = null;
    await _channel?.sink.close();
    _channel = null;
    await _controller.close();
  }
}

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/incident.dart';
import 'incident_message_decoder.dart';
import 'incident_socket_service.dart';

/// Production [IncidentSocketService] backed by [WebSocketChannel].
///
/// Owns connection lifecycle and delegates message parsing to an
/// injected [IncidentMessageDecoder] so the parsing path can be
/// tested directly without standing up a socket.
class IncidentSocketServiceImpl implements IncidentSocketService {
  IncidentSocketServiceImpl({
    Uri? uri,
    IncidentMessageDecoder decoder = const IncidentMessageDecoder(),
  })  : _uri = uri ?? Uri.parse('wss://smart-wild.onrender.com/handshake'),
        _decoder = decoder;

  final Uri _uri;
  final IncidentMessageDecoder _decoder;
  WebSocketChannel? _channel;

  @override
  Stream<Incident> get incidents =>
      _channel?.stream.map((message) => _decoder.decode(message as String)) ??
      const Stream<Incident>.empty();

  @override
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(_uri);
    await _channel!.ready;
  }

  @override
  Future<void> close() async {
    await _channel?.sink.close();
    _channel = null;
  }
}

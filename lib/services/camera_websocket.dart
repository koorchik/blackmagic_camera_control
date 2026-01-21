import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/camera_state.dart';
import '../utils/constants.dart';

/// WebSocket client for real-time camera state updates
class CameraWebSocket {
  CameraWebSocket({
    required this.host,
    this.port = ApiEndpoints.defaultPort,
  });

  final String host;
  final int port;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;

  final _lensController = StreamController<LensState>.broadcast();
  final _videoController = StreamController<VideoState>.broadcast();
  final _transportController = StreamController<TransportState>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of lens state updates
  Stream<LensState> get lensUpdates => _lensController.stream;

  /// Stream of video state updates
  Stream<VideoState> get videoUpdates => _videoController.stream;

  /// Stream of transport state updates
  Stream<TransportState> get transportUpdates => _transportController.stream;

  /// Stream of connection state changes
  Stream<bool> get connectionUpdates => _connectionController.stream;

  /// Connect to the camera WebSocket
  Future<void> connect() async {
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final wsUrl = ApiEndpoints.webSocket(host, port);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      await _channel!.ready;
      _connectionController.add(true);

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
    } catch (e) {
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final payload = data['data'] as Map<String, dynamic>?;

      if (payload == null) return;

      switch (type) {
        case 'lens/focus':
          _lensController.add(LensState(
            focus: (payload['focus'] as num?)?.toDouble() ?? 0.5,
          ));
          break;
        case 'lens/iris':
          _lensController.add(LensState(
            iris: (payload['apertureNormalised'] as num?)?.toDouble() ?? 0.0,
          ));
          break;
        case 'lens/zoom':
          _lensController.add(LensState(
            zoom: (payload['normalised'] as num?)?.toDouble() ?? 0.0,
          ));
          break;
        case 'video/iso':
          _videoController.add(VideoState(
            iso: payload['iso'] as int? ?? 800,
          ));
          break;
        case 'video/shutter':
          _videoController.add(VideoState(
            shutterSpeed: payload['shutterSpeed'] as int? ?? 50,
          ));
          break;
        case 'video/whiteBalance':
          _videoController.add(VideoState(
            whiteBalance: payload['whiteBalance'] as int? ?? 5600,
          ));
          break;
        case 'transports/0/record':
          _transportController.add(TransportState(
            isRecording: payload['recording'] as bool? ?? false,
          ));
          break;
        case 'transports/0/timecode':
          _transportController.add(TransportState(
            timecode: payload['timecode'] as String? ?? '00:00:00:00',
          ));
          break;
      }
    } catch (e) {
      // Ignore malformed messages
    }
  }

  void _handleError(Object error) {
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Durations.websocketReconnect, () {
      if (_shouldReconnect) {
        _connect();
      }
    });
  }

  /// Disconnect from the camera WebSocket
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }

  /// Dispose of resources
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _lensController.close();
    _videoController.close();
    _transportController.close();
    _connectionController.close();
  }
}

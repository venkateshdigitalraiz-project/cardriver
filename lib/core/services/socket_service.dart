import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../network/api_endpoints.dart';
import '../storage/local_storage_service.dart';

/// Manages the Socket.IO connection lifecycle for the driver user.
///
/// Features:
/// - Singleton pattern — one socket for the entire app session.
/// - Connects with JWT auth token from [LocalStorageService].
/// - Configurable automatic reconnection with exponential back-off capped at 5s.
/// - Broadcasts connection status via [onConnected] stream.
/// - Safe [disconnectFully] tears down the socket and all handlers cleanly.
class SocketService {
  // ──────────────────────────────────────────────
  //  Singleton
  // ──────────────────────────────────────────────
  static final SocketService _instance = SocketService._internal();
  SocketService._internal();
  factory SocketService() => _instance;

  // ──────────────────────────────────────────────
  //  Internal state
  // ──────────────────────────────────────────────
  io.Socket? _socket;
  final LocalStorageService _storageService = LocalStorageService();

  // ──────────────────────────────────────────────
  //  Public streams
  // ──────────────────────────────────────────────

  /// Fires every time the socket successfully connects or reconnects.
  final _connectedController = StreamController<void>.broadcast();
  Stream<void> get onConnected => _connectedController.stream;

  /// Fires every time the socket disconnects (any reason).
  final _disconnectedController = StreamController<String>.broadcast();
  Stream<String> get onDisconnected => _disconnectedController.stream;

  /// Fires every time a new ride is available from the server ('ride:new_available').
  final _rideNewAvailableController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get onRideNewAvailable => _rideNewAvailableController.stream;

  // ──────────────────────────────────────────────
  //  Accessors
  // ──────────────────────────────────────────────

  /// The underlying socket instance (null if never connected).
  io.Socket? get socket => _socket;

  /// Whether the socket is currently connected.
  bool get isConnected => _socket?.connected ?? false;

  // ──────────────────────────────────────────────
  //  Public API
  // ──────────────────────────────────────────────

  /// Connects the socket using the stored driver token.
  ///
  /// Reads the token from [LocalStorageService]. If no token is found,
  /// the connection is skipped gracefully.
  ///
  /// Calling [connect] while already connected is safe — it disconnects the
  /// old socket first so the new token is always used.
  Future<void> connect() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      log('⚠️ [SocketService] No token found — skipping socket connection.');
      return;
    }
    _connectWithToken(token);
  }

  /// Connects using an explicit [token] (e.g., right after OTP verification
  /// before the token is persisted in storage).
  void connectWithToken(String token) {
    if (token.isEmpty) {
      log('⚠️ [SocketService] Empty token — skipping socket connection.');
      return;
    }
    _connectWithToken(token);
  }

  /// Ensures the socket is connected, trying to reconnect once if not.
  ///
  /// Returns `true` if connected within ~3 s, `false` otherwise.
  Future<bool> ensureConnected() async {
    if (isConnected) return true;
    await connect();
    // Wait up to 3 s for the connection to be established.
    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (isConnected) return true;
    }
    return false;
  }

  /// Emits an event on the socket (no-op if not connected).
  void emit(String event, dynamic data) {
    if (!isConnected) {
      log('⚠️ [SocketService] emit("$event") skipped — not connected.');
      return;
    }
    _socket!.emit(event, data);
  }

  /// Subscribes [handler] to a named socket event.
  void on(String event, void Function(dynamic) handler) =>
      _socket?.on(event, handler);

  /// Subscribes a handler to all incoming socket events.
  void onAny(void Function(String event, dynamic data) handler) {
    _socket?.onAny((event, data) => handler(event.toString(), data));
  }

  /// Removes a specific [handler] (or all handlers) for a named socket event.
  void off(String event, [void Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  /// Disables listening to any incoming event.
  void offAny([void Function(String event, dynamic data)? handler]) {
    _socket?.offAny();
  }

  /// Disconnects the socket cleanly, frees all resources, and sets the
  /// internal reference to `null`.
  void disconnectFully() {
    if (_socket != null) {
      log('🔌 [SocketService] Disconnecting socket fully.');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  /// Closes all broadcast stream controllers. Call only when the service
  /// itself is being destroyed (e.g., during app shutdown).
  void dispose() {
    disconnectFully();
    _connectedController.close();
    _disconnectedController.close();
    _rideNewAvailableController.close();
  }

  // ──────────────────────────────────────────────
  //  Internal helpers
  // ──────────────────────────────────────────────

  void _connectWithToken(String token) {
    try {
      // If already connected, preserve existing socket connection
      if (_socket != null && _socket!.connected) {
        log('⚡ [SocketService] Socket already connected — preserving session.');
        return;
      }

      // Tear down any existing inactive socket before creating a new one.
      if (_socket != null) {
        log('🔄 [SocketService] Re-connecting with updated token.');
        disconnectFully();
      }

      log('🔌 [SocketService] Initiating socket connection…');

      _socket = io.io(
        ApiEndpoints.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .setQuery({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            // Force a brand-new socket instance every time.
            .enableForceNew()
            // Auto-reconnect configuration.
            .enableReconnection()
            .setReconnectionDelay(1000) // first retry after 1 s
            .setReconnectionDelayMax(5000) // cap at 5 s
            .setReconnectionAttempts(999999) // retry indefinitely
            .enableAutoConnect()
            .build(),
      );

      _socket!.connect();
      _registerBaseListeners(token);
    } catch (e, stack) {
      log('❌ [SocketService] Error initiating socket connection: $e\n$stack');
    }
  }

  void _registerBaseListeners(String token) {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      log('✅ [SocketService] Connected  — id: ${_socket?.id}');
      try {
        _socket!.emit('join:available_rides');
        _socket!.emit('driver:online', {'token': token});
        _socket!.emit('driver_online', {'token': token});
        _socket!.emit('join_driver', {'token': token});
        _socket!.emit('register', {'role': 'driver', 'token': token});
      } catch (_) {}
      _connectedController.add(null);
    });

    // Listen for new available rides broadcast from the backend
    _socket!.on('ride:new_available', (data) {
      log(
        '🚗 [SocketService] Event "ride:new_available" received from server: $data',
      );
      _rideNewAvailableController.add(data);
    });

    _socket!.onDisconnect((reason) {
      final msg = reason?.toString() ?? 'unknown';
      log('❌ [SocketService] Disconnected — reason: $msg');
      _disconnectedController.add(msg);
    });

    _socket!.onConnectError((error) {
      log('❗ [SocketService] Connection error: $error');
    });

    _socket!.onReconnect((attempt) {
      log('🔄 [SocketService] Reconnected after attempt $attempt');
      try {
        _socket!.emit('join:available_rides');
      } catch (_) {}
      _connectedController.add(null);
    });

    _socket!.onReconnectAttempt((attempt) {
      log('🔁 [SocketService] Reconnect attempt #$attempt…');
    });

    _socket!.onReconnectError((error) {
      log('❗ [SocketService] Reconnect error: $error');
    });

    _socket!.onReconnectFailed((_) {
      log('💀 [SocketService] All reconnect attempts exhausted.');
    });
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionProvider extends ChangeNotifier {
  static const Duration sessionDuration = Duration(minutes: 10);

  Timer? _sessionTimer;
  Timer? _tickTimer;
  Duration _remaining = sessionDuration;

  // Seguros extra
  bool _isDisposed = false;
  bool _expired = false;
  VoidCallback? _onExpire;

  Duration get remaining => _remaining;
  bool get isExpired => _expired;

  String get remainingFormatted {
    final total = _remaining.inSeconds.clamp(0, 359999);
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startSession(VoidCallback onExpire) {
    _onExpire = onExpire;
    _expired = false;
    _remaining = sessionDuration;

    _cancelTimers();

    // Expiración dura (respaldo)
    _sessionTimer = Timer(sessionDuration, _fireExpire);

    // Tick visual
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_isDisposed || _expired) return;

      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
      }

      // Evita negativos
      if (_remaining < Duration.zero) _remaining = Duration.zero;

      _notifySafe();

      // Si llegó a cero, cancelamos tick y disparamos expire (una sola vez)
      if (_remaining == Duration.zero) {
        t.cancel();
        _fireExpire();
      }
    });
  }

  // Reutiliza el último onExpire si no lo pasas
  void resetSession([VoidCallback? onExpire]) {
    startSession(onExpire ?? _onExpire ?? () {});
  }

  void cancelSession() => _cancelTimers();

  // ----------------- privados -----------------

  void _fireExpire() {
    if (_isDisposed || _expired) return;
    _expired = true;
    _cancelTimers();
    try {
      _onExpire?.call();
    } catch (_) {
      // swallow
    }
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _tickTimer?.cancel();
    _sessionTimer = null;
    _tickTimer = null;
  }

  void _notifySafe() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }
}

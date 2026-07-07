import 'types/types.dart';

/// Counterpart: swisseph::Ephemeris
final class Ephemeris {
  bool _closed = false;

  /// Counterpart: swisseph::Ephemeris::new
  Ephemeris(EphemerisConfig config) {
    // TODO: marshal config, call swisseph_new, store handle
    _use(config);
  }

  void _checkOpen() {
    if (_closed) {
      throw StateError('Ephemeris has been closed');
    }
  }

  /// Counterpart: swisseph::Ephemeris::calc_ut
  CalcResult calcUt(JdUt1 jd, Body body, CalcFlags flags) {
    _checkOpen();
    // TODO: marshal, call, unmarshal, throw
    _use(jd);
    _use(body);
    _use(flags);
    throw UnimplementedError('calcUt not yet implemented');
  }

  /// Release the native handle. Idempotent; use-after-close throws
  /// [StateError]. A [NativeFinalizer] backstop ensures cleanup if this
  /// method is never called.
  void close() {
    if (_closed) return;
    _closed = true;
    // TODO: call swisseph_free
  }

  /// Counterpart: swisseph::Ephemeris (share via Arc clone)
  ///
  /// Returns a token sendable to another isolate. Native-only.
  Object share() {
    _checkOpen();
    // TODO: call swisseph_share, return SendPort-compatible token
    throw UnimplementedError('share not yet implemented');
  }
}

/// Counterpart: swisseph::swisseph_version
String get engineVersion {
  // TODO: call swisseph_version, convert Pointer<Utf8> to String
  throw UnimplementedError('engineVersion not yet implemented');
}

void _use(Object? _) {}

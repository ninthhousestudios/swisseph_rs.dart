import 'dart:ffi';

import 'marshal/marshal.dart' as marshal;
import 'types/types.dart';

/// Counterpart: swisseph::Ephemeris
final class Ephemeris implements Finalizable {
  final Pointer<Void> _handle;
  bool _closed = false;

  static final _finalizer = NativeFinalizer(marshal.swissephFreeFnPtr);

  /// Counterpart: swisseph::Ephemeris::new
  Ephemeris(EphemerisConfig config) : _handle = marshal.createHandle(config) {
    _finalizer.attach(this, _handle, detach: this);
  }

  void _checkOpen() {
    if (_closed) {
      throw StateError('Ephemeris has been closed');
    }
  }

  /// Counterpart: swisseph::Ephemeris::calc_ut
  CalcResult calcUt(JdUt1 jd, Body body, CalcFlags flags) {
    _checkOpen();
    return marshal.calcUt(_handle, jd.value, body.rawValue, flags.value);
  }

  /// Release the native handle. Idempotent; use-after-close throws
  /// [StateError]. A [NativeFinalizer] backstop ensures cleanup if this
  /// method is never called.
  void close() {
    if (_closed) return;
    _closed = true;
    _finalizer.detach(this);
    marshal.freeHandle(_handle);
  }

  /// Counterpart: swisseph::Ephemeris (share via Arc clone)
  ///
  /// Returns a token sendable to another isolate. Native-only.
  Object share() {
    _checkOpen();
    throw UnimplementedError('share not yet implemented');
  }
}

/// Counterpart: swisseph::swisseph_version
String get engineVersion => marshal.engineVersion();

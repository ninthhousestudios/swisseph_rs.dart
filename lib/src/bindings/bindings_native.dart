import 'dart:ffi';

typedef _SwissephVersionC = Pointer<Char> Function();
typedef _SwissephVersionDart = Pointer<Char> Function();

typedef _SwissephNewC =
    Pointer<Void> Function(Pointer<Void> config, Pointer<Char> errBuf);
typedef _SwissephNewDart =
    Pointer<Void> Function(Pointer<Void> config, Pointer<Char> errBuf);

typedef _SwissephFreeC = Void Function(Pointer<Void> handle);
typedef _SwissephFreeDart = void Function(Pointer<Void> handle);

typedef _SwissephShareC = Pointer<Void> Function(Pointer<Void> handle);
typedef _SwissephShareDart = Pointer<Void> Function(Pointer<Void> handle);

/// Native FFI bindings to swisseph-ffi. Declarations only — no logic.
final class SwissephBindings {
  final DynamicLibrary _lib;

  SwissephBindings(this._lib);

  late final swissephVersion = _lib
      .lookupFunction<_SwissephVersionC, _SwissephVersionDart>(
        'swisseph_version',
      );

  late final swissephNew = _lib.lookupFunction<_SwissephNewC, _SwissephNewDart>(
    'swisseph_new',
  );

  late final swissephFree = _lib
      .lookupFunction<_SwissephFreeC, _SwissephFreeDart>('swisseph_free');

  late final swissephShare = _lib
      .lookupFunction<_SwissephShareC, _SwissephShareDart>('swisseph_share');
}

/// Load the native swisseph_rs library.
SwissephBindings loadBindings() {
  final lib = DynamicLibrary.open('swisseph_rs.so');
  return SwissephBindings(lib);
}

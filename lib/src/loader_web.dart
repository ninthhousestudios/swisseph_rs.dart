import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:wasm_ffi/ffi.dart';

import 'wasm_state.dart' as wasm;

const _ephePath = '/ephe';
bool _dirCreated = false;

/// Counterpart: (systematic divergence: web loader seam)
///
/// Load the swisseph_ffi WASM module. Must be called before constructing
/// [Ephemeris] or calling any API function on web.
///
/// [modulePath] is the URL to the swisseph_ffi.js Emscripten glue file
/// served from your web app's assets. Defaults to `'swisseph_ffi'`.
///
/// This function is single-flight and idempotent: concurrent or repeated
/// calls with the same [modulePath] return the same future. Calling with a
/// different path after initialization has started throws [StateError].
Future<void> initializeWasm([String? modulePath]) {
  final path = modulePath ?? 'swisseph_ffi';
  if (wasm.initFuture != null) {
    if (wasm.initModulePath != path) {
      throw StateError(
        'initializeWasm already called with "${wasm.initModulePath}"; '
        'cannot re-initialize with "$path".',
      );
    }
    return wasm.initFuture!;
  }
  wasm.initModulePath = path;
  wasm.initFuture = _doInit(path);
  return wasm.initFuture!;
}

Future<void> _doInit(String path) async {
  wasm.wasmLibrary = await DynamicLibrary.open(
    path,
    moduleName: 'SwissEphRs',
    useAsGlobal: GlobalMemory.yes,
  );
  wasm.wasmInitialized = true;
}

/// Counterpart: (systematic divergence: web loader seam)
///
/// Stage an ephemeris file (.se1) into Emscripten's MEMFS virtual filesystem.
/// After staging all needed files, construct [Ephemeris] with
/// `EphemerisConfig(ephemerisSource: EphemerisSource.swiss, ephePath: '/ephe')`.
void loadEpheFile(String filename, Uint8List bytes) {
  if (filename.isEmpty ||
      filename.contains('/') ||
      filename.contains(r'\') ||
      filename == '.' ||
      filename == '..' ||
      filename.contains('\x00')) {
    throw ArgumentError.value(filename, 'filename', 'must be a bare filename');
  }
  wasm.ensureInitialized();
  final fs = wasm.getEmscriptenFS();
  if (!_dirCreated) {
    try {
      fs.callMethod('mkdir'.toJS, _ephePath.toJS);
    } catch (_) {}
    _dirCreated = true;
  }
  fs.callMethod('writeFile'.toJS, '$_ephePath/$filename'.toJS, bytes.toJS);
}

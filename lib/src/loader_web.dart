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
Future<void> initializeWasm([String? modulePath]) async {
  wasm.wasmLibrary = await DynamicLibrary.open(
    modulePath ?? 'swisseph_ffi',
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

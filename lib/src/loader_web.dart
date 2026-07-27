// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:wasm_ffi/ffi.dart';
import 'package:web/web.dart' as web;

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
  // Load the Emscripten glue script and wrap the factory to capture the
  // module instance. wasm_ffi's EmscriptenModule wraps the raw JS module
  // with no public accessor, but getEmscriptenFS() needs it for MEMFS.
  // Pre-loading + wrapping before DynamicLibrary.open ensures the captured
  // module is stored in __swissephRsModule. DynamicLibrary.open's
  // importLibrary call will detect the script as already loaded and skip it.
  await _loadAndWrapFactory(path);

  wasm.wasmLibrary = await DynamicLibrary.open(
    path,
    moduleName: 'SwissEphRs',
    useAsGlobal: GlobalMemory.yes,
  );
  wasm.wasmInitialized = true;
}

@JS('eval')
external void _jsEval(String code);

Future<void> _loadAndWrapFactory(String path) async {
  // wasm_ffi's DynamicLibrary.open resolves an extensionless modulePath to
  // "<path>.js". Mirror that here so the pre-load requests the same URL --
  // otherwise this fetches a 404 and wasm_ffi's isImported() dedup (which
  // matches on script src) fails to see the pre-loaded tag.
  //
  // Test the extension on the parsed URI's last path segment, not the raw
  // string: modulePath is a URL, so a cache-busted "swisseph_ffi.js?v=1"
  // does not end in ".js" and must not have another ".js" appended.
  // wasm_ffi derives its extension the same way (uri.pathSegments.last).
  final segments = Uri.parse(path).pathSegments;
  final lastSegment = segments.isEmpty ? '' : segments.last;
  final src = lastSegment.endsWith('.js') || lastSegment.endsWith('.wasm')
      ? path
      : '$path.js';
  final script = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..src = src
    ..async = true;
  web.document.head!.appendChild(script);
  // A script that fails to fetch fires onError and never onLoad, so awaiting
  // onLoad alone turns any bad modulePath into a silent forever-hang.
  final loaded = Completer<void>();
  unawaited(
    script.onLoad.first.then((_) {
      if (!loaded.isCompleted) loaded.complete();
    }),
  );
  unawaited(
    script.onError.first.then((_) {
      if (!loaded.isCompleted) {
        loaded.completeError(
          StateError('Failed to load WASM glue script from "$src".'),
        );
      }
    }),
  );
  await loaded.future;
  _jsEval(
    'var __origSwissEphRs = globalThis.SwissEphRs;'
    'globalThis.SwissEphRs = function(a) {'
    '  return __origSwissEphRs(a).then(function(m) {'
    '    globalThis.__swissephRsModule = m;'
    '    return m;'
    '  });'
    '};',
  );
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

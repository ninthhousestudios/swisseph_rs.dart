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

/// How long to wait for the glue `<script>` tag to fire load or error.
///
/// A server that accepts the connection and then never responds -- a stalled
/// proxy, a hung CDN edge, a captive portal black-holing the request -- fires
/// neither event, so an unbounded wait is a silent forever-hang. This bounds
/// it.
///
/// 30s is chosen against what this timeout actually covers: the Emscripten
/// glue only (~68KB), not the ~857KB sibling `.wasm`, which is fetched later
/// inside [DynamicLibrary.open]. 68KB clears 30s on any connection above
/// ~20kbit/s, i.e. everything short of a link already too dead to run the
/// module. Anything shorter starts failing legitimate cold-mobile loads;
/// anything longer is indistinguishable from the hang it exists to prevent.
const _glueLoadTimeout = Duration(seconds: 30);

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
///
/// A *failed* initialization is not sticky: the single-flight latch is
/// released, so the call may be retried (with the same or a different
/// [modulePath]). Loading the glue script can fail transiently -- the
/// [TimeoutException] raised when the script neither loads nor errors within
/// 30 seconds is exactly such a case -- and a permanently poisoned latch
/// would make one bad network moment terminal for the isolate.
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
  wasm.initFuture = _doInit(path).onError<Object>((error, stack) {
    wasm.initFuture = null;
    wasm.initModulePath = null;
    Error.throwWithStackTrace(error, stack);
  });
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
  // Neither event fires if the server accepts the connection and then goes
  // quiet, so bound the wait. The fetch is not cancellable -- a <script> load
  // has no abort -- so this reports the failure rather than stopping it, and
  // drops the tag from the DOM: a retry appends a fresh one, and a stale tag
  // left behind would also confuse wasm_ffi's isImported() src-matching dedup
  // into skipping the real load.
  await loaded.future.timeout(
    _glueLoadTimeout,
    onTimeout: () {
      script.remove();
      throw TimeoutException(
        'Timed out loading WASM glue script from "$src"; the server accepted '
        'the request but never completed it.',
        _glueLoadTimeout,
      );
    },
  );
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

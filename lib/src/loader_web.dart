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

/// How long to wait for [DynamicLibrary.open] to instantiate the module.
///
/// [_glueLoadTimeout] bounds only the `<script>` tag. Everything expensive
/// happens after it, inside `DynamicLibrary.open`, on awaits with no timeout
/// of their own:
///
///  * a `http.head` probe for `<path>.js` / `<path>.wasm`, taken whenever
///    modulePath carries no extension -- which is the documented default;
///  * the Emscripten factory call, which fetches the ~857KB `.wasm` and
///    instantiates it.
///
/// The same stalled server that black-holes the glue URL black-holes these,
/// so bounding the script tag alone narrows the hang rather than closing it.
///
/// 60s is not proportional to the 12.5x larger payload, deliberately. What
/// this bounds is a stall (unbounded), not slowness, so the budget only has
/// to sit above any plausibly-legitimate load: 857KB lands inside 60s on
/// anything above ~120kbit/s, and below that the module is too slow to be
/// usable at all. Erring generous is cheap now that a failed init is
/// retryable.
const _moduleInstantiateTimeout = Duration(seconds: 60);

/// Attempt counter, bumped once per [initializeWasm] attempt.
///
/// Only the current attempt is allowed to publish its module. See the factory
/// wrapper in [_loadAndWrapFactory] for why an abandoned attempt must be
/// parked rather than left to finish.
int _initGeneration = 0;

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
  final generation = ++_initGeneration;
  final resolved = await _loadAndWrapFactory(path, generation);

  // Hand wasm_ffi the same absolute URL the tag carries, not the caller's
  // path. Its isImported() dedup compares an element's resolved .src against
  // the string it is given with endsWith, so any path the browser resolves --
  // anything relative, "../" above all -- fails to match, and it injects a
  // second glue tag. See _loadAndWrapFactory for why that is fatal. Passing
  // the resolved URL also carries an explicit extension, which skips
  // wasm_ffi's http.head probe for "<path>.js" / "<path>.wasm" -- one more
  // unbounded await removed from this path.
  wasm.wasmLibrary =
      await DynamicLibrary.open(
        resolved,
        moduleName: 'SwissEphRs',
        useAsGlobal: GlobalMemory.yes,
      ).timeout(
        _moduleInstantiateTimeout,
        onTimeout: () => throw TimeoutException(
          'Timed out instantiating the WASM module from "$path"; the glue '
          'script loaded but the module never finished initializing (the '
          'sibling .wasm fetch is the usual culprit).',
          _moduleInstantiateTimeout,
        ),
      );

  // The factory wrapper stores the module here, and only for the current
  // generation. Missing means something re-defined globalThis.SwissEphRs
  // between the wrap and the factory call -- most plausibly a late-arriving
  // duplicate glue <script> from an earlier attempt, which re-runs
  // `var SwissEphRs = ...` and strips the wrapper off. Fail here, naming it,
  // rather than at the first getEmscriptenFS() with "module not available".
  if (!globalContext.has('__swissephRsModule')) {
    throw StateError(
      'WASM module loaded but was not captured from "$path"; the glue script '
      'appears to have been re-executed and replaced the factory wrapper.',
    );
  }
  wasm.wasmInitialized = true;
}

@JS('eval')
external void _jsEval(String code);

/// Loads the glue script and wraps the Emscripten factory, returning the
/// absolute URL the tag was given.
Future<String> _loadAndWrapFactory(String path, int generation) async {
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
  final withExtension =
      lastSegment.endsWith('.js') || lastSegment.endsWith('.wasm')
      ? path
      : '$path.js';
  // Resolve against the document URL up front. A script element's .src getter
  // always reports the resolved absolute URL, and wasm_ffi's dedup matches on
  // that string, so keeping the caller's relative form here is what lets a
  // duplicate tag through.
  final src = Uri.base.resolve(withExtension).toString();
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
  // Wrap the Emscripten factory so the module instance is captured into
  // globalThis.__swissephRsModule -- wasm_ffi's EmscriptenModule holds it with
  // no public accessor, and getEmscriptenFS() needs it for MEMFS.
  //
  // Two details exist for the sake of a *second* attempt, which the retry
  // semantics of initializeWasm() now make reachable:
  //
  //  * `orig` is closed over by an IIFE rather than parked in a global. A
  //    global would be re-assigned by the next attempt while the previous
  //    attempt's wrapper still reads it by name -- so attempt 1's wrapper
  //    would end up calling attempt 2's factory.
  //  * a stale attempt's promise is parked, never resolved. Timing out
  //    DynamicLibrary.open does not cancel it: the abandoned open() is still
  //    parked on this promise, and if it ever resolved it would run the rest
  //    of open() and publish the *orphan's* Memory.global and
  //    WasmTable.global over a successful retry's. Half the pointer
  //    arithmetic would then resolve against one heap and half against
  //    another -- silent memory corruption, strictly worse than the hang this
  //    timeout replaces. Parking leaks one JS continuation per failed
  //    attempt, which is the cheaper side of that trade.
  _jsEval(
    '(function() {'
    '  var orig = globalThis.SwissEphRs;'
    '  var gen = $generation;'
    '  globalThis.__swissephRsGen = gen;'
    '  globalThis.SwissEphRs = function(a) {'
    '    return orig(a).then(function(m) {'
    '      if (globalThis.__swissephRsGen !== gen) {'
    '        return new Promise(function() {});'
    '      }'
    '      globalThis.__swissephRsModule = m;'
    '      return m;'
    '    });'
    '  };'
    '})();',
  );
  return src;
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

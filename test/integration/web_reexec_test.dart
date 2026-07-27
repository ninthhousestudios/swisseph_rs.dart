// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

// Regression test for swisseph-rs-dart/52.
//
// getEmscriptenFS() -- and therefore loadEpheFile() and the whole Swiss-file
// web path -- depends on a wrapper around the Emscripten factory that captures
// the module into globalThis.__swissephRsModule. The loader used to install
// that wrapper by assigning over globalThis.SwissEphRs once, after its own
// glue tag loaded. That assignment survives exactly until the glue executes
// again: the glue's top-level `var SwissEphRs = ...` re-assigns, and the
// wrapper is gone.
//
// Which happened routinely. wasm_ffi's isImported() dedup compares a script
// element's *resolved* .src against the string it was handed with endsWith, so
// any relative modulePath containing "../" fails to match, and wasm_ffi
// injects a second glue tag. A host page loading the glue itself does it too.
//
// The fix makes the capture an accessor on globalThis, so every assignment
// re-arms it. This test asserts that property directly: re-execute the glue,
// then check the factory still captures. Test one below is the negative
// control -- it fails against the assignment-based loader.
//
// Own file: initializeWasm() is single-flight per isolate, and this test
// deliberately dirties the global glue state.

String _glueSrc() {
  final scripts = web.document.querySelectorAll('script[src]');
  for (var i = 0; i < scripts.length; i++) {
    final src = (scripts.item(i)! as web.HTMLScriptElement).src;
    if (src.contains('swisseph_ffi')) return src;
  }
  fail('no glue script tag found');
}

Future<void> _reexecuteGlue() async {
  final script = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..src = _glueSrc()
    ..async = true;
  final loaded = Completer<void>();
  unawaited(
    script.onLoad.first.then((_) {
      if (!loaded.isCompleted) loaded.complete();
    }),
  );
  unawaited(
    script.onError.first.then((_) {
      if (!loaded.isCompleted) {
        loaded.completeError(StateError('glue re-execution failed to load'));
      }
    }),
  );
  web.document.head!.appendChild(script);
  await loaded.future.timeout(const Duration(seconds: 30));
}

void main() {
  setUpAll(() async {
    await initializeWasm('../../wasm/swisseph_ffi');
  });

  test('the factory still captures after the glue re-executes', () async {
    final original = globalContext.getProperty<JSAny?>(
      '__swissephRsModule'.toJS,
    );
    expect(original, isNotNull, reason: 'initializeWasm() must have captured');

    await _reexecuteGlue();

    // Clear the capture, then drive the factory the way wasm_ffi does. If the
    // re-executed glue replaced the wrapper with the raw factory, nothing
    // re-publishes and __swissephRsModule stays null.
    globalContext.setProperty('__swissephRsModule'.toJS, null);
    try {
      final factory = globalContext.getProperty<JSFunction>('SwissEphRs'.toJS);
      await (factory.callAsFunction(null, JSObject())! as JSPromise<JSObject>)
          .toDart;
      expect(
        globalContext.getProperty<JSAny?>('__swissephRsModule'.toJS),
        isNotNull,
        reason:
            'the glue re-executed and un-wrapped the factory, so nothing '
            'captures the module and getEmscriptenFS() is dead',
      );
    } finally {
      // Hand MEMFS back the module the rest of the suite was built against.
      globalContext.setProperty('__swissephRsModule'.toJS, original);
    }
  });

  test('loadEpheFile still works after the glue re-executes', () {
    // The consequence the wrapper exists for, asserted end to end.
    loadEpheFile('reexec_probe.se1', Uint8List.fromList([1, 2, 3]));
  });
}

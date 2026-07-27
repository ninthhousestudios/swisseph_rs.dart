@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

void main() {
  test('probe2', () async {
    try {
      await initializeWasm('../../wasm/swisseph_ffi.js?v=1');
    } catch (e) {
      print('ERR: $e');
    }
    print('gen: ${globalContext.getProperty('__swissephRsGen'.toJS)}');
    print('mod: ${globalContext.has('__swissephRsModule')}');
    print('SwissEphRs: ${globalContext.getProperty('SwissEphRs'.toJS)}');
    final scripts = (globalContext.getProperty('document'.toJS)! as JSObject);
    print(
      'scriptcount: ${(scripts.callMethod('querySelectorAll'.toJS, 'script[src]'.toJS) as JSObject).getProperty('length'.toJS)}',
    );
  });
}

library;

/// Web FFI bindings to swisseph-ffi (wasm). Stub — not yet implemented.
///
/// This file is selected by the conditional import in bindings.dart when
/// running on web platforms. The full wasm_ffi integration is a later task.

final class SwissephBindings {
  SwissephBindings._();
}

SwissephBindings loadBindings() =>
    throw UnsupportedError('swisseph_rs web bindings not yet implemented');

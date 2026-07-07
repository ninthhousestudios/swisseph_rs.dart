library;

/// Web FFI bindings to swisseph-ffi (wasm). Stub — not yet implemented.
///
/// This file is selected by the conditional import in bindings.dart when
/// running on web platforms. The full wasm_ffi integration is a later task.

Never _unsupported() =>
    throw UnsupportedError('swisseph_rs web bindings not yet implemented');

void swissephVersion() => _unsupported();
void swissephConfigDefault(dynamic config) => _unsupported();
int swissephNew(dynamic config, dynamic out, dynamic errBuf, int errCap) =>
    _unsupported();
void swissephFree(dynamic handle) => _unsupported();
int swissephShare(dynamic handle, dynamic out, dynamic errBuf, int errCap) =>
    _unsupported();
int swissephCalcUt(
  dynamic handle,
  double tjdUt,
  int ipl,
  int iflag,
  dynamic geopos,
  dynamic sidMode,
  dynamic xx,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

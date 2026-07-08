import 'dart:typed_data';

/// Counterpart: (systematic divergence: web loader seam)
Never initializeWasm([String? modulePath]) =>
    throw UnsupportedError('initializeWasm is web-only');

/// Counterpart: (systematic divergence: web loader seam)
Never loadEpheFile(String filename, Uint8List bytes) => throw UnsupportedError(
  'loadEpheFile is web-only; pass ephePath in EphemerisConfig instead',
);

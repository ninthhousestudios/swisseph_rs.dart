import '../types/types.dart';

/// Construct a typed [SweException] from an FFI error code and message.
SweException exceptionFromCode(int code, String message) => switch (code) {
  -1 => FileNotFoundException(message),
  -2 => CircumpolarBodyException(message),
  -3 => BeyondEphemerisLimitsException(message),
  -4 => InvalidBodyException(message),
  -99 => EnginePanicException(message),
  _ => UnknownSweException(code, message),
};

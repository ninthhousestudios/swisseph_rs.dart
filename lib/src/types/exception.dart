/// Counterpart: swisseph::Error
sealed class SweException implements Exception {
  final String message;
  const SweException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Counterpart: swisseph::Error::BeyondEphemerisLimits
final class BeyondEphemerisLimitsException extends SweException {
  const BeyondEphemerisLimitsException(super.message);
}

/// Counterpart: swisseph::Error::FileNotFound
final class FileNotFoundException extends SweException {
  const FileNotFoundException(super.message);
}

/// Counterpart: swisseph::Error::InvalidBody
final class InvalidBodyException extends SweException {
  const InvalidBodyException(super.message);
}

/// Counterpart: swisseph::Error::CircumpolarBody
final class CircumpolarBodyException extends SweException {
  const CircumpolarBodyException(super.message);
}

/// Counterpart: swisseph::Error::Panic
final class EnginePanicException extends SweException {
  const EnginePanicException(super.message);
}

/// Counterpart: swisseph::Error (unknown code fallback)
final class UnknownSweException extends SweException {
  final int code;
  const UnknownSweException(this.code, super.message);
}

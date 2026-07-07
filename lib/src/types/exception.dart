/// Counterpart: swisseph::Error
sealed class SweException implements Exception {
  final String message;
  const SweException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Counterpart: swisseph::Error::InvalidBody
final class InvalidBodyException extends SweException {
  const InvalidBodyException(super.message);
}

/// Counterpart: swisseph::Error::UnsupportedFlags
final class UnsupportedFlagsException extends SweException {
  const UnsupportedFlagsException(super.message);
}

/// Counterpart: swisseph::Error::InvalidHouseSystem
final class InvalidHouseSystemException extends SweException {
  const InvalidHouseSystemException(super.message);
}

/// Counterpart: swisseph::Error::InvalidSiderealMode
final class InvalidSiderealModeException extends SweException {
  const InvalidSiderealModeException(super.message);
}

/// Counterpart: swisseph::Error::InvalidCalendarType
final class InvalidCalendarTypeException extends SweException {
  const InvalidCalendarTypeException(super.message);
}

/// Counterpart: swisseph::Error::InvalidDate
final class InvalidDateException extends SweException {
  const InvalidDateException(super.message);
}

/// Counterpart: swisseph::Error::EphemerisNotAvailable
final class EphemerisNotAvailableException extends SweException {
  const EphemerisNotAvailableException(super.message);
}

/// Counterpart: swisseph::Error::BeyondEphemerisLimits
final class BeyondEphemerisLimitsException extends SweException {
  const BeyondEphemerisLimitsException(super.message);
}

/// Counterpart: swisseph::Error::FileNotFound
final class FileNotFoundException extends SweException {
  const FileNotFoundException(super.message);
}

/// Counterpart: swisseph::Error::FileFormat
final class FileFormatException extends SweException {
  const FileFormatException(super.message);
}

/// Counterpart: swisseph::Error::CircumpolarBody
final class CircumpolarBodyException extends SweException {
  const CircumpolarBodyException(super.message);
}

/// Counterpart: swisseph::Error::InvalidTime
final class InvalidTimeException extends SweException {
  const InvalidTimeException(super.message);
}

/// Counterpart: swisseph::Error::InvalidLeapSecond
final class InvalidLeapSecondException extends SweException {
  const InvalidLeapSecondException(super.message);
}

/// Counterpart: swisseph::Error::UnsupportedEphemeris
final class UnsupportedEphemerisException extends SweException {
  const UnsupportedEphemerisException(super.message);
}

/// Counterpart: swisseph::Error::SiderealModeRequiresFixedStars
final class SiderealModeRequiresFixedStarsException extends SweException {
  const SiderealModeRequiresFixedStarsException(super.message);
}

/// Counterpart: swisseph::Error::CError
final class CErrorException extends SweException {
  const CErrorException(super.message);
}

/// Counterpart: swisseph::Error::Panic
final class EnginePanicException extends SweException {
  const EnginePanicException(super.message);
}

/// SweErrorCode::InvalidArg (FFI-layer validation)
final class InvalidArgException extends SweException {
  const InvalidArgException(super.message);
}

/// SweErrorCode::Internal (FFI-layer internal error)
final class InternalException extends SweException {
  const InternalException(super.message);
}

/// Counterpart: swisseph::Error (unknown code fallback)
final class UnknownSweException extends SweException {
  final int code;
  const UnknownSweException(this.code, super.message);
}

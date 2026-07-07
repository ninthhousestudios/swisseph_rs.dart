import 'flags.dart';
import 'julian_day.dart';

/// Counterpart: swisseph::CalcResult
final class CalcResult {
  /// Longitude or right ascension (depends on flags).
  final double longitude;

  /// Latitude or declination.
  final double latitude;

  /// Distance (AU or km depends on body).
  final double distance;

  /// Speed in longitude (degrees/day).
  final double longitudeSpeed;

  /// Speed in latitude.
  final double latitudeSpeed;

  /// Speed in distance.
  final double distanceSpeed;

  /// Counterpart: swisseph::CalcResult::flags_used
  final CalcFlags flagsUsed;

  const CalcResult({
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.longitudeSpeed,
    required this.latitudeSpeed,
    required this.distanceSpeed,
    required this.flagsUsed,
  });
}

/// Counterpart: swisseph::types::UtcComponents
final class UtcComponents {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final double second;

  const UtcComponents({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });
}

/// Counterpart: swisseph::types::UtcToJd
final class UtcToJd {
  final JdTt tt;
  final JdUt1 ut1;

  const UtcToJd({required this.tt, required this.ut1});
}

/// Counterpart: swisseph::types::DegreeParts
final class DegreeParts {
  final int degrees;
  final int minutes;
  final int seconds;
  final double secondFraction;
  final int sign;

  const DegreeParts({
    required this.degrees,
    required this.minutes,
    required this.seconds,
    required this.secondFraction,
    required this.sign,
  });
}

import 'flags.dart';

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

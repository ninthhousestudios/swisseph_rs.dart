import 'body.dart';

/// Counterpart: swisseph::config::EphemerisConfig
final class EphemerisConfig {
  /// Counterpart: swisseph::config::EphemerisConfig::ephe_path
  final String? ephePath;

  /// Counterpart: swisseph::config::EphemerisConfig::asteroids
  final List<AsteroidId> asteroids;

  /// Counterpart: swisseph::config::EphemerisConfig::topographic
  final TopoPosition? topographic;

  /// Counterpart: swisseph::config::EphemerisConfig::sidereal_mode
  final SiderealMode? siderealMode;

  const EphemerisConfig({
    this.ephePath,
    this.asteroids = const [],
    this.topographic,
    this.siderealMode,
  });
}

/// Counterpart: swisseph::config::TopoPosition
final class TopoPosition {
  final double longitude;
  final double latitude;
  final double altitude;

  const TopoPosition({
    required this.longitude,
    required this.latitude,
    required this.altitude,
  });
}

/// Counterpart: swisseph::types::SiderealMode
final class SiderealMode {
  final int mode;
  final double t0;
  final double ayanT0;

  const SiderealMode({required this.mode, this.t0 = 0, this.ayanT0 = 0});
}

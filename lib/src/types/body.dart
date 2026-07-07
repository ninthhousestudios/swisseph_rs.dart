/// Counterpart: swisseph::types::Body
sealed class Body {
  const Body();

  /// Counterpart: swisseph::types::Body::Sun (variant)
  static const Body sun = _Planet(0);

  /// Counterpart: swisseph::types::Body::Moon (variant)
  static const Body moon = _Planet(1);

  /// Counterpart: swisseph::types::Body::Mercury (variant)
  static const Body mercury = _Planet(2);

  /// Counterpart: swisseph::types::Body::Venus (variant)
  static const Body venus = _Planet(3);

  /// Counterpart: swisseph::types::Body::Mars (variant)
  static const Body mars = _Planet(4);

  /// Counterpart: swisseph::types::Body::Jupiter (variant)
  static const Body jupiter = _Planet(5);

  /// Counterpart: swisseph::types::Body::Saturn (variant)
  static const Body saturn = _Planet(6);

  /// Counterpart: swisseph::types::Body::Uranus (variant)
  static const Body uranus = _Planet(7);

  /// Counterpart: swisseph::types::Body::Neptune (variant)
  static const Body neptune = _Planet(8);

  /// Counterpart: swisseph::types::Body::Pluto (variant)
  static const Body pluto = _Planet(9);

  /// Counterpart: swisseph::types::Body::MeanNode (variant)
  static const Body meanNode = _Planet(10);

  /// Counterpart: swisseph::types::Body::TrueNode (variant)
  static const Body trueNode = _Planet(11);

  /// Counterpart: swisseph::types::Body::MeanApogee (variant)
  static const Body meanApogee = _Planet(12);

  /// Counterpart: swisseph::types::Body::OscuApogee (variant)
  static const Body oscuApogee = _Planet(13);

  /// Counterpart: swisseph::types::Body::Earth (variant)
  static const Body earth = _Planet(14);

  /// Counterpart: swisseph::types::Body::Chiron (variant)
  static const Body chiron = _Planet(15);

  /// The raw integer body code for FFI marshalling.
  int get rawValue;

  /// Counterpart: swisseph::types::Body::Asteroid (variant)
  const factory Body.asteroid(AsteroidId id) = _Asteroid;

  /// Counterpart: swisseph::types::Body::Fictitious (variant)
  const factory Body.fictitious(int id) = _Fictitious;

  /// Counterpart: swisseph::types::Body::PlanetMoon (variant)
  const factory Body.planetMoon(int id) = _PlanetMoon;
}

final class _Planet extends Body {
  @override
  final int rawValue;
  const _Planet(this.rawValue);
}

final class _Asteroid extends Body {
  final AsteroidId id;
  const _Asteroid(this.id);

  @override
  int get rawValue => 10000 + id.number;
}

final class _Fictitious extends Body {
  final int id;
  const _Fictitious(this.id);

  @override
  int get rawValue => 40 + id;
}

final class _PlanetMoon extends Body {
  final int id;
  const _PlanetMoon(this.id);

  @override
  int get rawValue => 9000 + id;
}

/// Counterpart: swisseph::types::AsteroidId
extension type const AsteroidId(int number) {
  /// Counterpart: swisseph::types::AsteroidId::new
  const AsteroidId.fromNumber(int n) : number = n;
}

/// Counterpart: swisseph::flags::CalcFlags
extension type const CalcFlags(int value) {
  /// Counterpart: swisseph::flags::CalcFlags::new
  const CalcFlags.fromValue(int v) : value = v;

  /// Counterpart: swisseph::flags::CalcFlags::empty
  static const CalcFlags none = CalcFlags(0);

  /// Counterpart: swisseph::flags::CalcFlags::SPEED
  static const CalcFlags speed = CalcFlags(256);

  /// Counterpart: swisseph::flags::CalcFlags::EQUATORIAL
  static const CalcFlags equatorial = CalcFlags(2048);

  /// Counterpart: swisseph::flags::CalcFlags::JPLEPH
  static const CalcFlags jplEph = CalcFlags(1);

  /// Counterpart: swisseph::flags::CalcFlags::SWIEPH
  static const CalcFlags swiEph = CalcFlags(2);

  /// Counterpart: swisseph::flags::CalcFlags::MOSEPH
  static const CalcFlags mosEph = CalcFlags(4);

  CalcFlags operator |(CalcFlags other) => CalcFlags(value | other.value);
  CalcFlags operator &(CalcFlags other) => CalcFlags(value & other.value);

  bool contains(CalcFlags flag) => value & flag.value == flag.value;
}

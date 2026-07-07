enum OracleKind { direct, composite, engineTrusted }

class OracleEntry {
  final OracleKind kind;
  final String? reason;

  const OracleEntry.direct() : kind = OracleKind.direct, reason = null;

  const OracleEntry.composite() : kind = OracleKind.composite, reason = null;

  const OracleEntry.engineTrusted(String this.reason)
    : kind = OracleKind.engineTrusted;
}

const oracleMap = <String, OracleEntry>{
  'Ephemeris.new': OracleEntry.direct(),
  'Ephemeris.calcUt': OracleEntry.direct(),
  'Ephemeris.calcUtWithConfig': OracleEntry.composite(),
  'Ephemeris.calc': OracleEntry.direct(),
  'Ephemeris.calcWithConfig': OracleEntry.composite(),
  'Ephemeris.calcPctr': OracleEntry.engineTrusted(
    'requires Swiss/JPL ephemeris files; rejection tested on Moshier',
  ),
  'Ephemeris.close': OracleEntry.engineTrusted(
    'lifecycle; no oracle equivalent',
  ),
  'Ephemeris.share': OracleEntry.engineTrusted(
    'unimplemented; pending upstream FFI',
  ),
  'Ephemeris.deltaT': OracleEntry.direct(),
  'Ephemeris.timeEqu': OracleEntry.direct(),
  'Ephemeris.lmtToLat': OracleEntry.direct(),
  'Ephemeris.latToLmt': OracleEntry.direct(),
  'Ephemeris.getPlanetName': OracleEntry.direct(),
  'Ephemeris.utcToJd': OracleEntry.direct(),
  'Ephemeris.jdetToUtc': OracleEntry.direct(),
  'Ephemeris.jdut1ToUtc': OracleEntry.direct(),
  'engineVersion': OracleEntry.engineTrusted(
    'reports Rust engine version; no oracle comparison',
  ),
  'exceptionFromCode': OracleEntry.engineTrusted(
    'error-code dispatch; tested by unit tests',
  ),
  'julday': OracleEntry.direct(),
  'revjul': OracleEntry.direct(),
  'dateConversion': OracleEntry.direct(),
  'dayOfWeek': OracleEntry.direct(),
  'utcTimeZone': OracleEntry.direct(),
  'splitDegrees': OracleEntry.direct(),
  'normalizeDegrees': OracleEntry.engineTrusted(
    'pure math (x % 360); oracle uses identical algorithm',
  ),
  'Ephemeris.houses': OracleEntry.direct(),
  'Ephemeris.housesEx2': OracleEntry.direct(),
  'Ephemeris.gauquelinSector': OracleEntry.direct(),
  'Ephemeris.getAyanamsaEx': OracleEntry.composite(),
  'Ephemeris.getAyanamsaExWithConfig': OracleEntry.composite(),
  'Ephemeris.getAyanamsaUt': OracleEntry.composite(),
  'Ephemeris.getAyanamsa': OracleEntry.composite(),
  'housesArmc': OracleEntry.direct(),
  'housePos': OracleEntry.direct(),
  'houseName': OracleEntry.direct(),
  'getAyanamsaName': OracleEntry.direct(),
};

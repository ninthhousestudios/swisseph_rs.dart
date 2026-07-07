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
  'engineVersion': OracleEntry.engineTrusted(
    'reports Rust engine version; no oracle comparison',
  ),
  'exceptionFromCode': OracleEntry.engineTrusted(
    'error-code dispatch; tested by unit tests',
  ),
};

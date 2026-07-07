library;

/// Web FFI bindings to swisseph-ffi (wasm). Stub — not yet implemented.
///
/// This file is selected by the conditional import in bindings.dart when
/// running on web platforms. The full wasm_ffi integration is a later task.

Never _unsupported() =>
    throw UnsupportedError('swisseph_rs web bindings not yet implemented');

void swissephVersion() => _unsupported();
void swissephConfigDefault(dynamic config) => _unsupported();
int swissephNew(dynamic config, dynamic out, dynamic errBuf, int errCap) =>
    _unsupported();
void swissephFree(dynamic handle) => _unsupported();
int swissephShare(dynamic handle, dynamic out, dynamic errBuf, int errCap) =>
    _unsupported();
int swissephCalcUt(
  dynamic handle,
  double tjdUt,
  int ipl,
  int iflag,
  dynamic geopos,
  dynamic sidMode,
  dynamic xx,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephCalc(
  dynamic handle,
  double tjdEt,
  int ipl,
  int iflag,
  dynamic geopos,
  dynamic sidMode,
  dynamic xx,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephCalcPctr(
  dynamic handle,
  double tjdEt,
  int ipl,
  int iplctr,
  int iflag,
  dynamic xx,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

double swissephJulday(
  int year,
  int month,
  int day,
  double hour,
  int gregflag,
) => _unsupported();

void swissephRevjul(
  double jd,
  int gregflag,
  dynamic year,
  dynamic month,
  dynamic day,
  dynamic hour,
) => _unsupported();

int swissephDateConversion(
  int year,
  int month,
  int day,
  double hour,
  int cal,
  dynamic tjd,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephDayOfWeek(double jd) => _unsupported();

void swissephUtcTimeZone(
  int iyear,
  int imonth,
  int iday,
  int ihour,
  int imin,
  double dsec,
  double dTimezone,
  dynamic oyear,
  dynamic omonth,
  dynamic oday,
  dynamic ohour,
  dynamic omin,
  dynamic osec,
) => _unsupported();

int swissephUtcToJd(
  dynamic handle,
  int year,
  int month,
  int day,
  int hour,
  int min,
  double sec,
  int gregflag,
  dynamic dret,
  dynamic errBuf,
  int errCap,
) => _unsupported();

void swissephJdetToUtc(
  dynamic handle,
  double tjdEt,
  int gregflag,
  dynamic year,
  dynamic month,
  dynamic day,
  dynamic hour,
  dynamic min,
  dynamic sec,
) => _unsupported();

void swissephJdut1ToUtc(
  dynamic handle,
  double tjdUt,
  int gregflag,
  dynamic year,
  dynamic month,
  dynamic day,
  dynamic hour,
  dynamic min,
  dynamic sec,
) => _unsupported();

double swissephDeltat(dynamic handle, double tjdUt) => _unsupported();

int swissephTimeEqu(
  dynamic handle,
  double tjdUt,
  dynamic e,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLmtToLat(
  dynamic handle,
  double tjdLmt,
  double geolon,
  dynamic tjdLat,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLatToLmt(
  dynamic handle,
  double tjdLat,
  double geolon,
  dynamic tjdLmt,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephGetPlanetName(
  dynamic handle,
  int ipl,
  dynamic buf,
  int cap,
  dynamic errBuf,
  int errCap,
) => _unsupported();

void swissephSplitDeg(
  double ddeg,
  int roundflag,
  dynamic deg,
  dynamic min,
  dynamic sec,
  dynamic secfr,
  dynamic sign,
) => _unsupported();

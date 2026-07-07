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

// Houses & Gauquelin

int swissephHousesEx2(
  dynamic handle,
  double tjdUt,
  int iflag,
  double geolat,
  double geolon,
  int hsys,
  dynamic cusps,
  dynamic ascmc,
  dynamic cuspSpeed,
  dynamic ascmcSpeed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephHousesArmcEx2(
  double armc,
  double geolat,
  double eps,
  int hsys,
  dynamic sundec,
  dynamic cusps,
  dynamic ascmc,
  dynamic cuspSpeed,
  dynamic ascmcSpeed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephHousePos(
  double armc,
  double geolat,
  double eps,
  int hsys,
  dynamic xpin,
  dynamic sundec,
  dynamic hpos,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephHouseName(
  int hsys,
  dynamic buf,
  int cap,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephGauquelinSector(
  dynamic handle,
  double tjdUt,
  int ipl,
  dynamic starname,
  int iflag,
  int imeth,
  dynamic geopos,
  double atpress,
  double attemp,
  dynamic dgsect,
  dynamic errBuf,
  int errCap,
) => _unsupported();

// Ayanamsa

int swissephGetAyanamsaEx(
  dynamic handle,
  double tjdEt,
  int iflag,
  dynamic sidMode,
  dynamic daya,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephGetAyanamsaExUt(
  dynamic handle,
  double tjdUt,
  int iflag,
  dynamic sidMode,
  dynamic daya,
  dynamic flagsUsed,
  dynamic errBuf,
  int errCap,
) => _unsupported();

double swissephGetAyanamsa(dynamic handle, double tjdEt, dynamic sidMode) =>
    _unsupported();

double swissephGetAyanamsaUt(dynamic handle, double tjdUt, dynamic sidMode) =>
    _unsupported();

int swissephGetAyanamsaName(
  int sidModeRaw,
  dynamic buf,
  int cap,
  dynamic errBuf,
  int errCap,
) => _unsupported();

// Eclipses & occultations

int swissephSolEclipseWhere(
  dynamic handle,
  double tjdUt,
  int ifl,
  dynamic geopos,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephSolEclipseHow(
  dynamic handle,
  double tjdUt,
  int ifl,
  dynamic geopos,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephSolEclipseWhenGlob(
  dynamic handle,
  double tjdStart,
  int ifl,
  int ifltype,
  int backward,
  dynamic tret,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephSolEclipseWhenLoc(
  dynamic handle,
  double tjdStart,
  int ifl,
  dynamic geopos,
  int backward,
  dynamic tret,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunEclipseHow(
  dynamic handle,
  double tjdUt,
  int ifl,
  dynamic geopos,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunEclipseWhen(
  dynamic handle,
  double tjdStart,
  int ifl,
  int ifltype,
  int backward,
  dynamic tret,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunEclipseWhenLoc(
  dynamic handle,
  double tjdStart,
  int ifl,
  dynamic geopos,
  int backward,
  dynamic tret,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunOccultWhere(
  dynamic handle,
  double tjdUt,
  int ipl,
  dynamic starname,
  int ifl,
  dynamic geopos,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunOccultWhenGlob(
  dynamic handle,
  double tjdStart,
  int ipl,
  dynamic starname,
  int ifl,
  int ifltype,
  int backward,
  dynamic tret,
  dynamic errBuf,
  int errCap,
) => _unsupported();

int swissephLunOccultWhenLoc(
  dynamic handle,
  double tjdStart,
  int ipl,
  dynamic starname,
  int ifl,
  dynamic geopos,
  int backward,
  dynamic tret,
  dynamic attr,
  dynamic errBuf,
  int errCap,
) => _unsupported();

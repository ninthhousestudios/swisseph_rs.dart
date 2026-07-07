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

/// Counterpart: swisseph::houses::AscMc
final class AscMc {
  final double ascendant;
  final double mc;
  final double armc;
  final double vertex;
  final double equatorialAscendant;
  final double coascendantKoch;
  final double coascendantMunkasey;
  final double polarAscendant;

  const AscMc({
    required this.ascendant,
    required this.mc,
    required this.armc,
    required this.vertex,
    required this.equatorialAscendant,
    required this.coascendantKoch,
    required this.coascendantMunkasey,
    required this.polarAscendant,
  });
}

/// Counterpart: swisseph::houses::HouseResult
final class HouseResult {
  /// Cusp longitudes. Index 0 is unused; cusps are at indices 1..12
  /// (or 1..36 for Gauquelin sectors).
  final List<double> cusps;

  /// Cusp speeds in degrees/day, same indexing as [cusps].
  final List<double> cuspSpeeds;

  /// Angular points (Ascendant, MC, ARMC, Vertex, etc.).
  final AscMc ascmc;

  /// Angular-point speeds in degrees/day.
  final AscMc ascmcSpeeds;

  const HouseResult({
    required this.cusps,
    required this.cuspSpeeds,
    required this.ascmc,
    required this.ascmcSpeeds,
  });
}

// ---------------------------------------------------------------------------
// Eclipse & occultation result types
// ---------------------------------------------------------------------------

/// Counterpart: swisseph::eclipse::EclipseHow
final class EclipseHow {
  final double magnitude;
  final double diameterRatio;
  final double obscuration;
  final double coreDiameterKm;
  final double azimuth;
  final double trueAltitude;
  final double apparentAltitude;
  final double elongation;
  final double nasaMagnitude;
  final double sarosSeries;
  final double sarosMember;
  final EclipseFlags flags;

  const EclipseHow({
    required this.magnitude,
    required this.diameterRatio,
    required this.obscuration,
    required this.coreDiameterKm,
    required this.azimuth,
    required this.trueAltitude,
    required this.apparentAltitude,
    required this.elongation,
    required this.nasaMagnitude,
    required this.sarosSeries,
    required this.sarosMember,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::EclipseWhere
final class EclipseWhere {
  final double centralLongitude;
  final double centralLatitude;
  final double coreDiameterKm;
  final double penumbraDiameterKm;
  final double shadowAxisDistanceKm;
  final double umbraDiameterFundamentalKm;
  final double penumbraDiameterFundamentalKm;
  final double cosUmbraHalfAngle;
  final double cosPenumbraHalfAngle;
  final EclipseFlags flags;

  const EclipseWhere({
    required this.centralLongitude,
    required this.centralLatitude,
    required this.coreDiameterKm,
    required this.penumbraDiameterKm,
    required this.shadowAxisDistanceKm,
    required this.umbraDiameterFundamentalKm,
    required this.penumbraDiameterFundamentalKm,
    required this.cosUmbraHalfAngle,
    required this.cosPenumbraHalfAngle,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::SolarEclipseGlobal
final class SolarEclipseGlobal {
  final double timeMaximum;
  final double timeRaConjunction;
  final double timeBegin;
  final double timeEnd;
  final double timeTotalityBegin;
  final double timeTotalityEnd;
  final double timeCenterlineBegin;
  final double timeCenterlineEnd;
  final EclipseFlags flags;

  const SolarEclipseGlobal({
    required this.timeMaximum,
    required this.timeRaConjunction,
    required this.timeBegin,
    required this.timeEnd,
    required this.timeTotalityBegin,
    required this.timeTotalityEnd,
    required this.timeCenterlineBegin,
    required this.timeCenterlineEnd,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::SolarEclipseLocal
final class SolarEclipseLocal {
  final double timeMaximum;
  final double timeFirstContact;
  final double timeSecondContact;
  final double timeThirdContact;
  final double timeFourthContact;
  final double timeSunrise;
  final double timeSunset;
  final EclipseHow attr;
  final EclipseFlags flags;

  const SolarEclipseLocal({
    required this.timeMaximum,
    required this.timeFirstContact,
    required this.timeSecondContact,
    required this.timeThirdContact,
    required this.timeFourthContact,
    required this.timeSunrise,
    required this.timeSunset,
    required this.attr,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::LunarEclipseHow
final class LunarEclipseHow {
  final double umbralMagnitude;
  final double penumbralMagnitude;
  final double azimuth;
  final double trueAltitude;
  final double apparentAltitude;
  final double distanceFromOpposition;
  final double sarosSeries;
  final double sarosMember;
  final EclipseFlags flags;

  const LunarEclipseHow({
    required this.umbralMagnitude,
    required this.penumbralMagnitude,
    required this.azimuth,
    required this.trueAltitude,
    required this.apparentAltitude,
    required this.distanceFromOpposition,
    required this.sarosSeries,
    required this.sarosMember,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::LunarEclipseGlobal
final class LunarEclipseGlobal {
  final double timeMaximum;
  final double timePartialBegin;
  final double timePartialEnd;
  final double timeTotalityBegin;
  final double timeTotalityEnd;
  final double timePenumbralBegin;
  final double timePenumbralEnd;
  final EclipseFlags flags;

  const LunarEclipseGlobal({
    required this.timeMaximum,
    required this.timePartialBegin,
    required this.timePartialEnd,
    required this.timeTotalityBegin,
    required this.timeTotalityEnd,
    required this.timePenumbralBegin,
    required this.timePenumbralEnd,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::LunarEclipseLocal
final class LunarEclipseLocal {
  final double timeMaximum;
  final double timePartialBegin;
  final double timePartialEnd;
  final double timeTotalityBegin;
  final double timeTotalityEnd;
  final double timePenumbralBegin;
  final double timePenumbralEnd;
  final double timeMoonrise;
  final double timeMoonset;
  final LunarEclipseHow attr;
  final EclipseFlags flags;

  const LunarEclipseLocal({
    required this.timeMaximum,
    required this.timePartialBegin,
    required this.timePartialEnd,
    required this.timeTotalityBegin,
    required this.timeTotalityEnd,
    required this.timePenumbralBegin,
    required this.timePenumbralEnd,
    required this.timeMoonrise,
    required this.timeMoonset,
    required this.attr,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::OccultGlobal
final class OccultGlobal {
  final double timeMaximum;
  final double timeRaConjunction;
  final double timeBegin;
  final double timeEnd;
  final double timeTotalityBegin;
  final double timeTotalityEnd;
  final double timeCenterlineBegin;
  final double timeCenterlineEnd;
  final EclipseFlags flags;

  const OccultGlobal({
    required this.timeMaximum,
    required this.timeRaConjunction,
    required this.timeBegin,
    required this.timeEnd,
    required this.timeTotalityBegin,
    required this.timeTotalityEnd,
    required this.timeCenterlineBegin,
    required this.timeCenterlineEnd,
    required this.flags,
  });
}

/// Counterpart: swisseph::eclipse::OccultLocal
final class OccultLocal {
  final double timeMaximum;
  final double timeFirstContact;
  final double timeSecondContact;
  final double timeThirdContact;
  final double timeFourthContact;
  final double timeRise;
  final double timeSet;
  final EclipseHow attr;
  final EclipseFlags flags;

  const OccultLocal({
    required this.timeMaximum,
    required this.timeFirstContact,
    required this.timeSecondContact,
    required this.timeThirdContact,
    required this.timeFourthContact,
    required this.timeRise,
    required this.timeSet,
    required this.attr,
    required this.flags,
  });
}

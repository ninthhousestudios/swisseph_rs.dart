import 'package:swisseph/swisseph.dart' as swe;
import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

import 'src/agreement.dart';
import 'src/oracle.dart';

// Search-class tolerance for iterative eclipse event-finding (≈0.09 s).
const _searchTolerance = 1e-6;

void main() {
  late Ephemeris eph;
  late Oracle oracle;

  // J2000 epoch as JD UT — search start for finding eclipses.
  const j2000Ut = JdUt1(2451545.0);

  // Berlin: 52.52°N, 13.41°E
  const berlinLat = 52.52;
  const berlinLon = 13.41;

  setUpAll(() {
    eph = Ephemeris(const EphemerisConfig());
    oracle = Oracle();
  });

  tearDownAll(() {
    eph.close();
    oracle.close();
  });

  // -----------------------------------------------------------------------
  // Solar eclipses (task /30)
  // -----------------------------------------------------------------------

  group('solEclipseWhenGlob', () {
    test('forward search finds matching eclipse', () {
      final actual = eph.solEclipseWhenGlob(j2000Ut, CalcFlags.none);
      final expected = oracle.solEclipseWhenGlob(j2000Ut.value, 0);

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeRaConjunction',
        actual.timeRaConjunction,
        expected.localNoon,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeBegin',
        actual.timeBegin,
        expected.begin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeEnd',
        actual.timeEnd,
        expected.end,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeTotalityBegin',
        actual.timeTotalityBegin,
        expected.totalityBegin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeTotalityEnd',
        actual.timeTotalityEnd,
        expected.totalityEnd,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeCenterlineBegin',
        actual.timeCenterlineBegin,
        expected.centerLineBegin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeCenterlineEnd',
        actual.timeCenterlineEnd,
        expected.centerLineEnd,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });

    test('backward search', () {
      final actual = eph.solEclipseWhenGlob(
        j2000Ut,
        CalcFlags.none,
        backward: true,
      );
      final expected = oracle.solEclipseWhenGlob(
        j2000Ut.value,
        0,
        backward: true,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });

    test('filtered by eclipse type', () {
      final actual = eph.solEclipseWhenGlob(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.total,
      );
      final expected = oracle.solEclipseWhenGlob(
        j2000Ut.value,
        0,
        eclType: swe.seEclTotal,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.contains(EclipseFlags.total), isTrue);
      expect(actual.flags.value, equals(expected.returnFlag));
    });
  });

  group('solEclipseWhenLoc', () {
    test('forward search at Berlin', () {
      final actual = eph.solEclipseWhenLoc(
        j2000Ut,
        CalcFlags.none,
        geolon: berlinLon,
        geolat: berlinLat,
      );
      final expected = oracle.solEclipseWhenLoc(
        j2000Ut.value,
        0,
        geolon: berlinLon,
        geolat: berlinLat,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeFirstContact',
        actual.timeFirstContact,
        expected.firstContact,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeFourthContact',
        actual.timeFourthContact,
        expected.fourthContact,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));

      // Embedded EclipseHow attributes.
      expectAgreement(
        'attr.magnitude',
        actual.attr.magnitude,
        expected.magnitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'attr.obscuration',
        actual.attr.obscuration,
        expected.obscuration,
        AgreementClass.positional,
      );
    });
  });

  group('solEclipseWhere', () {
    test('geography at time of global eclipse', () {
      final glob = eph.solEclipseWhenGlob(j2000Ut, CalcFlags.none);
      final actual = eph.solEclipseWhere(
        JdUt1(glob.timeMaximum),
        CalcFlags.none,
      );
      final expected = oracle.solEclipseWhere(glob.timeMaximum, 0);

      expectAgreement(
        'centralLongitude',
        actual.centralLongitude,
        expected.geolon,
        AgreementClass.positional,
      );
      expectAgreement(
        'centralLatitude',
        actual.centralLatitude,
        expected.geolat,
        AgreementClass.positional,
      );
      expect(actual.flags.value, equals(expected.returnFlag));

      expect(actual.coreDiameterKm.isFinite, isTrue);
      expect(actual.penumbraDiameterKm.isFinite, isTrue);
      expect(actual.shadowAxisDistanceKm.isFinite, isTrue);
    });
  });

  group('solEclipseHow', () {
    test('attributes at eclipse location and time', () {
      final glob = eph.solEclipseWhenGlob(j2000Ut, CalcFlags.none);
      final where = eph.solEclipseWhere(
        JdUt1(glob.timeMaximum),
        CalcFlags.none,
      );

      final actual = eph.solEclipseHow(
        JdUt1(glob.timeMaximum),
        CalcFlags.none,
        geolon: where.centralLongitude,
        geolat: where.centralLatitude,
      );
      final expected = oracle.solEclipseHow(
        glob.timeMaximum,
        0,
        geolon: where.centralLongitude,
        geolat: where.centralLatitude,
      );

      expectAgreement(
        'magnitude',
        actual.magnitude,
        expected.magnitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'diameterRatio',
        actual.diameterRatio,
        expected.diameterRatio,
        AgreementClass.positional,
      );
      expectAgreement(
        'obscuration',
        actual.obscuration,
        expected.obscuration,
        AgreementClass.positional,
      );
      expectAgreement(
        'azimuth',
        actual.azimuth,
        expected.sunAzimuth,
        AgreementClass.positional,
      );
      expectAgreement(
        'trueAltitude',
        actual.trueAltitude,
        expected.sunTrueAltitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'nasaMagnitude',
        actual.nasaMagnitude,
        expected.magnitudeNasa,
        AgreementClass.positional,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });
  });

  // -----------------------------------------------------------------------
  // Lunar eclipses (task /31)
  // -----------------------------------------------------------------------

  group('lunEclipseWhen', () {
    test('forward search finds matching eclipse', () {
      final actual = eph.lunEclipseWhen(j2000Ut, CalcFlags.none);
      final expected = oracle.lunEclipseWhen(j2000Ut.value, 0);

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timePenumbralBegin',
        actual.timePenumbralBegin,
        expected.penumbralBegin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timePenumbralEnd',
        actual.timePenumbralEnd,
        expected.penumbralEnd,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });

    test('backward search', () {
      final actual = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        backward: true,
      );
      final expected = oracle.lunEclipseWhen(j2000Ut.value, 0, backward: true);

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });

    test('filtered by total', () {
      final actual = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.total,
      );
      final expected = oracle.lunEclipseWhen(
        j2000Ut.value,
        0,
        eclType: swe.seEclTotal,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.contains(EclipseFlags.total), isTrue);
    });

    test('filtered by penumbral', () {
      final actual = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.penumbral,
      );
      final expected = oracle.lunEclipseWhen(
        j2000Ut.value,
        0,
        eclType: swe.seEclPenumbral,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.contains(EclipseFlags.penumbral), isTrue);
    });
  });

  group('lunEclipseWhenLoc', () {
    test('forward search at Berlin', () {
      final actual = eph.lunEclipseWhenLoc(
        j2000Ut,
        CalcFlags.none,
        geolon: berlinLon,
        geolat: berlinLat,
      );
      final expected = oracle.lunEclipseWhenLoc(
        j2000Ut.value,
        0,
        geolon: berlinLon,
        geolat: berlinLat,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timePenumbralBegin',
        actual.timePenumbralBegin,
        expected.penumbralBegin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timePenumbralEnd',
        actual.timePenumbralEnd,
        expected.penumbralEnd,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));

      expectAgreement(
        'attr.umbralMagnitude',
        actual.attr.umbralMagnitude,
        expected.umbralMagnitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'attr.penumbralMagnitude',
        actual.attr.penumbralMagnitude,
        expected.penumbralMagnitude,
        AgreementClass.positional,
      );
    });
  });

  group('lunEclipseHow', () {
    test('attributes at eclipse time and location', () {
      final glob = eph.lunEclipseWhen(j2000Ut, CalcFlags.none);

      final actual = eph.lunEclipseHow(
        JdUt1(glob.timeMaximum),
        CalcFlags.none,
        geolon: berlinLon,
        geolat: berlinLat,
      );
      final expected = oracle.lunEclipseHow(
        glob.timeMaximum,
        0,
        geolon: berlinLon,
        geolat: berlinLat,
      );

      expectAgreement(
        'umbralMagnitude',
        actual.umbralMagnitude,
        expected.umbralMagnitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'penumbralMagnitude',
        actual.penumbralMagnitude,
        expected.penumbralMagnitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'azimuth',
        actual.azimuth,
        expected.moonAzimuth,
        AgreementClass.positional,
      );
      expectAgreement(
        'trueAltitude',
        actual.trueAltitude,
        expected.moonTrueAltitude,
        AgreementClass.positional,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });
  });

  // -----------------------------------------------------------------------
  // Occultations (task /31)
  // -----------------------------------------------------------------------

  group('lunOccultWhenGlob', () {
    test('Venus occultation forward search', () {
      final actual = eph.lunOccultWhenGlob(j2000Ut, Body.venus, CalcFlags.none);
      final expected = oracle.lunOccultWhenGlob(
        j2000Ut.value,
        Body.venus.rawValue,
        0,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeBegin',
        actual.timeBegin,
        expected.begin,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeEnd',
        actual.timeEnd,
        expected.end,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });

    test('backward search', () {
      final actual = eph.lunOccultWhenGlob(
        j2000Ut,
        Body.venus,
        CalcFlags.none,
        backward: true,
      );
      final expected = oracle.lunOccultWhenGlob(
        j2000Ut.value,
        Body.venus.rawValue,
        0,
        backward: true,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));
    });
  });

  group('lunOccultWhenLoc', () {
    test('Venus occultation at Berlin', () {
      final actual = eph.lunOccultWhenLoc(
        j2000Ut,
        Body.venus,
        CalcFlags.none,
        geolon: berlinLon,
        geolat: berlinLat,
      );
      final expected = oracle.lunOccultWhenLoc(
        j2000Ut.value,
        Body.venus.rawValue,
        0,
        geolon: berlinLon,
        geolat: berlinLat,
      );

      expectAgreement(
        'timeMaximum',
        actual.timeMaximum,
        expected.maxEclipse,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'timeFirstContact',
        actual.timeFirstContact,
        expected.firstContact,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expect(actual.flags.value, equals(expected.returnFlag));

      expectAgreement(
        'attr.magnitude',
        actual.attr.magnitude,
        expected.magnitude,
        AgreementClass.positional,
      );
    });
  });

  group('lunOccultWhere', () {
    test('geography at time of Venus occultation', () {
      final glob = eph.lunOccultWhenGlob(j2000Ut, Body.venus, CalcFlags.none);
      final actual = eph.lunOccultWhere(
        JdUt1(glob.timeMaximum),
        Body.venus,
        CalcFlags.none,
      );
      final expected = oracle.lunOccultWhere(
        glob.timeMaximum,
        Body.venus.rawValue,
        0,
      );

      expectAgreement(
        'centralLongitude',
        actual.centralLongitude,
        expected.geolon,
        AgreementClass.positional,
      );
      expectAgreement(
        'centralLatitude',
        actual.centralLatitude,
        expected.geolat,
        AgreementClass.positional,
      );
      expect(actual.flags.value, equals(expected.returnFlag));

      expect(actual.coreDiameterKm.isFinite, isTrue);
      expect(actual.penumbraDiameterKm.isFinite, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // Totality checks
  // -----------------------------------------------------------------------

  group('eclipse type bitmask semantics', () {
    test('solar: total eclipse has TOTAL + CENTRAL flags', () {
      final total = eph.solEclipseWhenGlob(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.total,
      );
      expect(total.flags.contains(EclipseFlags.total), isTrue);
    });

    test('solar: annular eclipse has ANNULAR flag', () {
      final annular = eph.solEclipseWhenGlob(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.annular,
      );
      expect(annular.flags.contains(EclipseFlags.annular), isTrue);
    });

    test('solar: partial eclipse has PARTIAL flag', () {
      final partial = eph.solEclipseWhenGlob(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.partial,
      );
      expect(partial.flags.contains(EclipseFlags.partial), isTrue);
    });

    test('lunar: total eclipse has TOTAL flag', () {
      final total = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.total,
      );
      expect(total.flags.contains(EclipseFlags.total), isTrue);
    });

    test('lunar: partial eclipse has PARTIAL flag', () {
      final partial = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.partial,
      );
      expect(partial.flags.contains(EclipseFlags.partial), isTrue);
    });

    test('lunar: penumbral eclipse has PENUMBRAL flag', () {
      final penumbral = eph.lunEclipseWhen(
        j2000Ut,
        CalcFlags.none,
        eclType: EclipseFlags.penumbral,
      );
      expect(penumbral.flags.contains(EclipseFlags.penumbral), isTrue);
    });
  });
}

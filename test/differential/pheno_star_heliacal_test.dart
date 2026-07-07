import 'dart:io' show Platform;

import 'package:swisseph/swisseph.dart' as swe;
import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

import 'src/agreement.dart';
import 'src/oracle.dart';

const _searchTolerance = 1e-6;

void main() {
  late Ephemeris eph;
  late Oracle oracle;

  const j2000Ut = JdUt1(2451545.0);
  const j2000Et = JdTt(2451545.0);

  setUpAll(() {
    eph = Ephemeris(const EphemerisConfig());
    oracle = Oracle();
  });

  tearDownAll(() {
    eph.close();
    oracle.close();
  });

  // -----------------------------------------------------------------------
  // Phenomena (task /33)
  // -----------------------------------------------------------------------

  group('phenoUt', () {
    test('Venus phenomena', () {
      final actual = eph.phenoUt(j2000Ut, Body.venus, CalcFlags.none);
      final expected = oracle.phenoUt(j2000Ut.value, Body.venus.rawValue, 0);
      expectAgreement(
        'phaseAngle',
        actual.phaseAngle,
        expected.phaseAngle,
        AgreementClass.positional,
      );
      expectAgreement(
        'phase',
        actual.phase,
        expected.phase,
        AgreementClass.positional,
      );
      expectAgreement(
        'elongation',
        actual.elongation,
        expected.elongation,
        AgreementClass.positional,
      );
      expectAgreement(
        'apparentDiameter',
        actual.apparentDiameter,
        expected.apparentDiameter,
        AgreementClass.positional,
      );
      expectAgreement(
        'apparentMagnitude',
        actual.apparentMagnitude,
        expected.apparentMagnitude,
        AgreementClass.positional,
      );
    });

    test('Mars phenomena', () {
      final actual = eph.phenoUt(j2000Ut, Body.mars, CalcFlags.none);
      final expected = oracle.phenoUt(j2000Ut.value, Body.mars.rawValue, 0);
      expectAgreement(
        'phaseAngle',
        actual.phaseAngle,
        expected.phaseAngle,
        AgreementClass.positional,
      );
      expectAgreement(
        'elongation',
        actual.elongation,
        expected.elongation,
        AgreementClass.positional,
      );
    });
  });

  group('pheno (ET)', () {
    test('Jupiter phenomena', () {
      final actual = eph.pheno(j2000Et, Body.jupiter, CalcFlags.none);
      final expected = oracle.pheno(j2000Et.value, Body.jupiter.rawValue, 0);
      expectAgreement(
        'phaseAngle',
        actual.phaseAngle,
        expected.phaseAngle,
        AgreementClass.positional,
      );
      expectAgreement(
        'phase',
        actual.phase,
        expected.phase,
        AgreementClass.positional,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Nodes & apsides (task /33)
  // -----------------------------------------------------------------------

  group('nodApsUt', () {
    test('Mars mean nodes & apsides', () {
      final actual = eph.nodApsUt(
        j2000Ut,
        Body.mars,
        CalcFlags.none,
        NodApsMethod.mean,
      );
      final expected = oracle.nodApsUt(j2000Ut.value, Body.mars.rawValue, 0, 1);
      expectAgreement(
        'ascending lon',
        actual.ascending[0],
        expected.ascending.longitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'descending lon',
        actual.descending[0],
        expected.descending.longitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'perihelion lon',
        actual.perihelion[0],
        expected.perihelion.longitude,
        AgreementClass.positional,
      );
      expectAgreement(
        'aphelion lon',
        actual.aphelion[0],
        expected.aphelion.longitude,
        AgreementClass.positional,
      );
    });
  });

  group('nodAps (ET)', () {
    test('Jupiter osculating nodes', () {
      final actual = eph.nodAps(
        j2000Et,
        Body.jupiter,
        CalcFlags.none,
        NodApsMethod.oscu,
      );
      final expected = oracle.nodAps(
        j2000Et.value,
        Body.jupiter.rawValue,
        0,
        2,
      );
      // Moshier osculating node precision: ~5e-5° (documented artifact)
      expectAgreement(
        'ascending lon',
        actual.ascending[0],
        expected.ascending.longitude,
        AgreementClass.boundary,
        tolerance: 5e-5,
        boundaryArtifact: 'Moshier osculating node',
      );
    });
  });

  // -----------------------------------------------------------------------
  // Orbital elements (task /33)
  // -----------------------------------------------------------------------

  group('getOrbitalElements', () {
    test('Mars orbital elements', () {
      final actual = eph.getOrbitalElements(j2000Et, Body.mars, CalcFlags.none);
      final expected = oracle.getOrbitalElements(
        j2000Et.value,
        Body.mars.rawValue,
        0,
      );
      expectAgreement(
        'semiMajorAxis',
        actual.semiMajorAxis,
        expected.semimajorAxis,
        AgreementClass.positional,
      );
      expectAgreement(
        'eccentricity',
        actual.eccentricity,
        expected.eccentricity,
        AgreementClass.positional,
      );
      expectAgreement(
        'inclination',
        actual.inclination,
        expected.inclination,
        AgreementClass.positional,
      );
      expectAgreement(
        'siderealPeriod',
        actual.siderealPeriod,
        expected.siderealPeriodYears,
        AgreementClass.positional,
      );
      expectAgreement(
        'meanDailyMotion',
        actual.meanDailyMotion,
        expected.meanDailyMotion,
        AgreementClass.positional,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Orbit distances (task /33)
  // -----------------------------------------------------------------------

  group('orbitMaxMinTrueDistance', () {
    test('Mars distances', () {
      final actual = eph.orbitMaxMinTrueDistance(
        j2000Et,
        Body.mars,
        CalcFlags.none,
      );
      final expected = oracle.orbitMaxMinTrueDistance(
        j2000Et.value,
        Body.mars.rawValue,
        0,
      );
      expectAgreement(
        'max',
        actual.max,
        expected.maxDist,
        AgreementClass.positional,
      );
      expectAgreement(
        'min',
        actual.min,
        expected.minDist,
        AgreementClass.positional,
      );
      expectAgreement(
        'true',
        actual.trueDist,
        expected.trueDist,
        AgreementClass.positional,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Fixed stars (task /33) — requires sefstars.txt via SWE_EPHE_PATH
  // -----------------------------------------------------------------------

  final ephePath = Platform.environment['SWE_EPHE_PATH'];

  group(
    'fixstar2Ut',
    skip: ephePath == null ? 'SWE_EPHE_PATH not set' : null,
    () {
      late Ephemeris starEph;
      late Oracle starOracle;

      setUpAll(() {
        starEph = Ephemeris(EphemerisConfig(ephePath: ephePath));
        starOracle = Oracle(ephePath: ephePath);
      });

      tearDownAll(() {
        starEph.close();
        starOracle.close();
      });

      test('Sirius position', () {
        final actual = starEph.fixstar2Ut('Sirius', j2000Ut, CalcFlags.none);
        final expected = starOracle.fixstar2Ut('Sirius', j2000Ut.value, 0);
        // Moshier precession differences: ~3e-6°
        expectAgreement(
          'longitude',
          actual.longitude,
          expected.longitude,
          AgreementClass.boundary,
          tolerance: 5e-6,
          boundaryArtifact: 'Moshier star precession',
        );
        expectAgreement(
          'latitude',
          actual.latitude,
          expected.latitude,
          AgreementClass.boundary,
          tolerance: 5e-6,
          boundaryArtifact: 'Moshier star precession',
        );
        // Star parallax → distance conversion differs between engines
        expectAgreement(
          'distance',
          actual.distance,
          expected.distance,
          AgreementClass.boundary,
          tolerance: 1e-3,
          boundaryArtifact: 'Moshier star parallax distance',
        );
        expect(actual.starName, isNotEmpty);
      });
    },
  );

  group(
    'fixstar2 (ET)',
    skip: ephePath == null ? 'SWE_EPHE_PATH not set' : null,
    () {
      late Ephemeris starEph;
      late Oracle starOracle;

      setUpAll(() {
        starEph = Ephemeris(EphemerisConfig(ephePath: ephePath));
        starOracle = Oracle(ephePath: ephePath);
      });

      tearDownAll(() {
        starEph.close();
        starOracle.close();
      });

      test('Aldebaran position', () {
        final actual = starEph.fixstar2('Aldebaran', j2000Et, CalcFlags.none);
        final expected = starOracle.fixstar2('Aldebaran', j2000Et.value, 0);
        expectAgreement(
          'longitude',
          actual.longitude,
          expected.longitude,
          AgreementClass.boundary,
          tolerance: 5e-6,
          boundaryArtifact: 'Moshier star precession',
        );
        expectAgreement(
          'latitude',
          actual.latitude,
          expected.latitude,
          AgreementClass.boundary,
          tolerance: 5e-6,
          boundaryArtifact: 'Moshier star precession',
        );
      });
    },
  );

  group(
    'fixstar2Mag',
    skip: ephePath == null ? 'SWE_EPHE_PATH not set' : null,
    () {
      late Ephemeris starEph;
      late Oracle starOracle;

      setUpAll(() {
        starEph = Ephemeris(EphemerisConfig(ephePath: ephePath));
        starOracle = Oracle(ephePath: ephePath);
      });

      tearDownAll(() {
        starEph.close();
        starOracle.close();
      });

      test('Sirius magnitude', () {
        final result = starEph.fixstar2Mag('Sirius');
        final expected = starOracle.fixstar2Mag('Sirius');
        expectAgreement(
          'magnitude',
          result.magnitude,
          expected,
          AgreementClass.bitwise,
        );
        expect(result.starName, contains('Sirius'));
      });
    },
  );

  // -----------------------------------------------------------------------
  // Heliacal (task /33)
  // -----------------------------------------------------------------------

  group('heliacalUt', () {
    test('Venus morning first', () {
      const atmo = swe.AtmoConditions(
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      const observer = swe.ObserverConditions();
      final actual = eph.heliacalUt(
        j2000Ut,
        'Venus',
        HeliacalEventType.morningFirst,
        CalcFlags.none,
        HeliacalFlags.none,
        geolon: 13.41,
        geolat: 52.52,
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      final expected = oracle.heliacalUt(
        j2000Ut.value,
        geolon: 13.41,
        geolat: 52.52,
        atmo: atmo,
        observer: observer,
        objectName: 'Venus',
        typeEvent: HeliacalEventType.morningFirst.value,
      );
      expectAgreement(
        'startVisible',
        actual.startVisible,
        expected.startVisible,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'bestVisible',
        actual.optimumVisibility,
        expected.bestVisible,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
      expectAgreement(
        'endVisible',
        actual.endVisible,
        expected.endVisible,
        AgreementClass.search,
        tolerance: _searchTolerance,
      );
    });
  });

  group('visLimitMag', () {
    test('Venus visibility limit', () {
      const atmo = swe.AtmoConditions(
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      const observer = swe.ObserverConditions();
      // Use a JD when Venus is above the horizon in Berlin evening
      const jd = JdUt1(2451550.0);
      final actual = eph.visLimitMag(
        jd,
        'Venus',
        CalcFlags.none,
        HeliacalFlags.none,
        geolon: 13.41,
        geolat: 52.52,
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      final expected = oracle.visLimitMag(
        jd.value,
        geolon: 13.41,
        geolat: 52.52,
        atmo: atmo,
        observer: observer,
        objectName: 'Venus',
      );
      // Moshier-derived visibility model: ~3e-6 precision
      expectAgreement(
        'limitMagnitude',
        actual.limitingMagnitude,
        expected.limitMagnitude,
        AgreementClass.boundary,
        tolerance: 5e-6,
        boundaryArtifact: 'Moshier visibility model',
      );
      expectAgreement(
        'objectAltitude',
        actual.altitudeObject,
        expected.objectAltitude,
        AgreementClass.boundary,
        tolerance: 5e-6,
        boundaryArtifact: 'Moshier visibility model',
      );
      expectAgreement(
        'objectMagnitude',
        actual.magnitudeObject,
        expected.objectMagnitude,
        AgreementClass.boundary,
        tolerance: 5e-6,
        boundaryArtifact: 'Moshier visibility model',
      );
    });
  });

  group('heliacalAngle', () {
    test('angle computation', () {
      const atmo = swe.AtmoConditions(
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      const observer = swe.ObserverConditions();
      const jd = JdUt1(2451545.0);
      final actual = eph.heliacalAngle(
        jd,
        HeliacalFlags.none,
        geolon: 13.41,
        geolat: 52.52,
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
        mag: -4.0,
        aziObj: 90,
        aziSun: 90,
        aziMoon: 270,
        altMoon: -10,
      );
      final expected = oracle.heliacalAngle(
        jd.value,
        geolon: 13.41,
        geolat: 52.52,
        atmo: atmo,
        observer: observer,
        helflag: 0,
        mag: -4.0,
        aziObj: 90,
        aziSun: 90,
        aziMoon: 270,
        altMoon: -10,
      );
      expectAgreement(
        'optimalAltitude',
        actual.optimalAltitude,
        expected.optimalAngle,
        AgreementClass.positional,
      );
      expectAgreement(
        'arcusVisionis',
        actual.arcusVisionis,
        expected.arcusVisionis,
        AgreementClass.positional,
      );
      expectAgreement(
        'sunAltitudeDiff',
        actual.sunAltitudeDiff,
        expected.residual,
        AgreementClass.positional,
      );
    });
  });

  group('topoArcusVisionis', () {
    test('arcus visionis computation', () {
      const atmo = swe.AtmoConditions(
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
      );
      const observer = swe.ObserverConditions();
      const jd = JdUt1(2451545.0);
      final actual = eph.topoArcusVisionis(
        jd,
        HeliacalFlags.none,
        geolon: 13.41,
        geolat: 52.52,
        pressure: 1013.25,
        temperature: 15,
        humidity: 40,
        extinction: 0.25,
        mag: -4.0,
        aziObj: 90,
        altObj: 5,
        aziSun: 90,
        aziMoon: 270,
        altMoon: -10,
      );
      final expected = oracle.topoArcusVisionis(
        jd.value,
        geolon: 13.41,
        geolat: 52.52,
        atmo: atmo,
        observer: observer,
        helflag: 0,
        mag: -4.0,
        aziObj: 90,
        altObj: 5,
        aziSun: 90,
        aziMoon: 270,
        altMoon: -10,
      );
      expectAgreement(
        'arcusVisionis',
        actual,
        expected,
        AgreementClass.positional,
      );
    });
  });
}

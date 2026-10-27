import 'package:flutter_test/flutter_test.dart';
import 'package:railway_rail_wear_calculator/main.dart';

void main() {
  group('NR4 rule of nine', () {
    test('step 14 gives 2 mm lateral head loss', () {
      expect(lateralHeadLossFromNr4Step(14), 2.0);
    });
    test('new rail step 18 gives zero lateral head loss', () {
      expect(lateralHeadLossFromNr4Step(18), 0.0);
    });
    test('step 0 gives 9 mm lateral head loss', () {
      expect(lateralHeadLossFromNr4Step(0), 9.0);
    });
  });

  group('GCRT5021 9-metre fishplate minimum', () {
    test('60E1 plain-line within 9m: 158 + 2 = 160', () {
      final min = minimumDepthForFishplateLocation(
        baseMinimum: 158.0,
        lateralHeadLoss: lateralHeadLossFromNr4Step(14),
        withinNineMetresOfFishplate: true,
      );
      expect(min, 160.0);
      expect((163.0 - min).floor(), 3);
    });
    test('60E1 plain-line beyond 9m: base 158, depth margin 5', () {
      final min = minimumDepthForFishplateLocation(
        baseMinimum: 158.0,
        lateralHeadLoss: lateralHeadLossFromNr4Step(14),
        withinNineMetresOfFishplate: false,
      );
      expect(min, 158.0);
      expect((163.0 - min).floor(), 5);
    });
    test('113A within 9m includes the additional lateral loss', () {
      final min = minimumDepthForFishplateLocation(
        baseMinimum: 145.0,
        lateralHeadLoss: 4.0,
        withinNineMetresOfFishplate: true,
      );
      expect(min, 149.0);
    });
    test('under 1 mm remaining rounds down to zero', () {
      final min = minimumDepthForFishplateLocation(
        baseMinimum: 158.0,
        lateralHeadLoss: 2.0,
        withinNineMetresOfFishplate: true,
      );
      expect((160.99 - min).floor(), 0);
      expect((161.0 - min).floor(), 1);
    });
  });
}

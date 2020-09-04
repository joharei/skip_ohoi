import 'package:flutter_test/flutter_test.dart';
import 'package:skip_ohoi/features/map/degrees_tween.dart';

void main() {
  test('Degrees are correct from 355 to 5', () {
    final tween = DegreesTween(begin: 355, end: 5);
    final steps = [356, 357, 358, 359, 0, 1, 2, 3, 4, 5];
    for (var i = 0; i < 10; i++) {
      expect(tween.lerp((i + 1) / 10.0), equals(steps[i]));
    }
  });

  test('Degrees are correct from 5 to 355', () {
    final tween = DegreesTween(begin: 5, end: 355);
    final steps = [4, 3, 2, 1, 0, 359, 358, 357, 356, 355];
    for (var i = 0; i < 10; i++) {
      expect(tween.lerp((i + 1) / 10.0), equals(steps[i]));
    }
  });
}

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class DegreesTween extends Tween<double> {
  DegreesTween({@required double begin, @required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    final diff = end - begin;
    return (begin +
            (diff.abs() > 180 ? (360 - diff.abs()) * diff.sign * -1 : diff) *
                t) %
        360;
  }
}

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class LatLngTween extends Tween<LatLng> {
  LatLngTween({@required LatLng begin, @required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
        begin.latitude + (end.latitude - begin.latitude) * t,
        begin.longitude + (end.longitude - begin.longitude) * t,
      );
}

extension LocationDataExtensions on LocationData {
  LatLng get latLng => LatLng(latitude, longitude);
}

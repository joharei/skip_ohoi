import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';

void animatedMarkerMove(
  TickerProvider vsync,
  LatLng currentLocation,
  LatLng destLocation,
  Function(LatLng newLocation) updateMarker,
) {
  // Create some tweens. These serve to split up the transition from one location to another.
  // In our case, we want to split the transition be<tween> our current map center and the destination.
  final _latTween = Tween<double>(
      begin: currentLocation.latitude, end: destLocation.latitude);
  final _lngTween = Tween<double>(
      begin: currentLocation.longitude, end: destLocation.longitude);

  // Create a animation controller that has a duration and a TickerProvider.
  var controller = AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: vsync);
  // The animation determines what path the animation will take. You can try different Curves values, although I found
  // fastOutSlowIn to be my favorite.
  Animation<double> animation =
      CurvedAnimation(parent: controller, curve: Curves.linear);

  controller.addListener(() {
    updateMarker(
        LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)));
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      controller.dispose();
    } else if (status == AnimationStatus.dismissed) {
      controller.dispose();
    }
  });

  controller.forward();
}

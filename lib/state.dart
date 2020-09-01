import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

final mapTypeState = RM.inject(() => MapType.SJOKARTRASTER);

final locationState = RM.injectStream(
  // ignore: top_level_function_literal_block
  () => Location().onLocationChanged.asyncMap((locationData) async {
    if (locationData.speed < 1) {
      final compassHeading = await FlutterCompass.events.first;
      return LocationData.fromMap({
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'accuracy': locationData.accuracy,
        'altitude': locationData.altitude,
        'speed': locationData.speed,
        'speed_accuracy': locationData.speedAccuracy,
        'heading': compassHeading ?? 0,
        'time': locationData.time,
      });
    }
    return locationData;
  }),
  onInitialized: (_) =>
      Location().changeSettings(accuracy: LocationAccuracy.high, interval: 500),
);

class Zoom {}

final zoomToLocationState = RM.inject(() => Zoom());

final mapLockedState = RM.inject(() => false);

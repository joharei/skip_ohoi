import 'package:connectivity/connectivity.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/service.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final mapTypeState = RM.inject(() => MapType.SJOKARTRASTER);

final encTokensState = RM.injectComputed<EncTokens>(
  computeAsync: (s) => encTokensRefresher(mapTypeState.state),
  asyncDependsOn: [mapTypeState],
);

final locationState = RM.injectStream<LocationData>(
  () => Rx.concat([
    Stream.fromFutures([
      Location().changeSettings(accuracy: LocationAccuracy.high, interval: 500),
      Location().requestPermission(),
    ]).map((_) => null),
    Location().onLocationChanged.asyncMap((locationData) async {
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
  ]),
);

class Zoom {}

final zoomToLocationState = RM.inject(() => Zoom());

final mapLockedState = RM.inject(() => false);

final isOnlineState = RM.injectStream<bool>(
  () => Connectivity()
      .onConnectivityChanged
      .map((event) => event != ConnectivityResult.none),
  initialValue: true,
);

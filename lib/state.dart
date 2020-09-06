import 'dart:developer' as developer;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skip_ohoi/secrets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

final mapTypeState = RM.inject(() => MapType.SJOKARTRASTER);

class EncTokens {
  final String ticket;
  final String gkt;

  EncTokens(this.ticket, this.gkt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncTokens &&
          runtimeType == other.runtimeType &&
          ticket == other.ticket &&
          gkt == other.gkt;

  @override
  int get hashCode => ticket.hashCode ^ gkt.hashCode;
}

final encTokensState = RM.injectComputed<EncTokens>(
  computeAsync: (s) => mapTypeState.state != MapType.ENC
      ? Stream.value(null)
      : Stream.periodic(Duration(seconds: 15))
          .startWith(null)
          .asyncMap(
            (_) => Future.wait([
              http.get(gateKeeperTicketUrl),
              http.get(gateKeeperTokenUrl),
            ]).then(
              (responses) {
                String value(String body) =>
                    RegExp(r'^"(.*)"\W$').firstMatch(body).group(1);
                return EncTokens(
                    value(responses[0].body), value(responses[1].body));
              },
            ),
          )
          .handleError((error) {
          developer.log('Failed to fetch ENC secrets', error: error);
        }),
  asyncDependsOn: [mapTypeState],
);

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

import 'package:location/location.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

final mapTypeState = RM.inject(() => MapType.SJOKARTRASTER);

final locationState = RM.injectStream(
  () => Location().onLocationChanged,
  onInitialized: (_) =>
      Location().changeSettings(accuracy: LocationAccuracy.high, interval: 500),
);

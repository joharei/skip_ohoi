import 'package:states_rebuilder/states_rebuilder.dart';

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

final mapTypeState = RM.inject(() => MapType.SJOKARTRASTER);

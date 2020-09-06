import 'package:flutter_map/plugin_api.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final chooseDownloadArea = RM.inject(() => true);

final chosenDownloadBounds = RM.inject<Bounds>(() => null);

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_layer.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_options.dart';

class AreaPickerPlugin extends MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    return AreaPickerLayer(options, mapState, stream);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaPickerLayerOptions;
  }
}

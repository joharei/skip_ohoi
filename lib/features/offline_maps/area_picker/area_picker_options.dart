import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

class AreaPickerLayerOptions extends LayerOptions {
  final Function(LatLngBounds state) onAreaChanged;
  final Color color;
  final EdgeInsets insets;

  AreaPickerLayerOptions({
    @required this.onAreaChanged,
    this.color = Colors.blue,
    this.insets = const EdgeInsets.all(0),
  });
}

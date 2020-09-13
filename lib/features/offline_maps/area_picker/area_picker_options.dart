import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

class AreaPickerLayerOptions extends LayerOptions {
  final Function(AreaPickerState state) onAreaChanged;
  final Color color;
  final EdgeInsets insets;

  AreaPickerLayerOptions({
    @required this.onAreaChanged,
    this.color = Colors.blue,
    this.insets = const EdgeInsets.all(0),
  });
}

class AreaPickerState {
  AreaPickerState(
    this.bounds,
  );

  final LatLngBounds bounds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaPickerState &&
          runtimeType == other.runtimeType &&
          bounds == other.bounds;

  @override
  int get hashCode => bounds.hashCode;
}

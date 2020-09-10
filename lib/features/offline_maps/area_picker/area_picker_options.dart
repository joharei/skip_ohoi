import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

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
    this.xPos,
    this.yPos,
    this.width,
    this.height,
    this.zoom,
    this.mapCenter,
    this.bounds,
  );

  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final double zoom;
  final LatLng mapCenter;
  final LatLngBounds bounds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaPickerState &&
          runtimeType == other.runtimeType &&
          xPos == other.xPos &&
          yPos == other.yPos &&
          width == other.width &&
          height == other.height &&
          zoom == other.zoom &&
          mapCenter == other.mapCenter &&
          bounds == other.bounds;

  @override
  int get hashCode =>
      xPos.hashCode ^
      yPos.hashCode ^
      width.hashCode ^
      height.hashCode ^
      zoom.hashCode ^
      mapCenter.hashCode ^
      bounds.hashCode;
}

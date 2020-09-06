import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

import 'area_picker_options.dart';

class AreaPickerLayer extends StatefulWidget {
  final AreaPickerLayerOptions options;
  final MapState map;
  final Stream<void> stream;

  AreaPickerLayer(this.options, this.map, this.stream);

  @override
  _AreaPickerLayerState createState() => _AreaPickerLayerState();
}

class _AreaPickerLayerState extends State<AreaPickerLayer> {
  StreamSubscription _onMovedSub;

  final _areaKey = GlobalKey();

  @override
  initState() {
    super.initState();

    final setBounds = () {
      RenderBox box = _areaKey.currentContext.findRenderObject();
      var topLeft = box.localToGlobal(Offset.zero);
      var bounds = _pxBoundsToTileRange(
          _getBounds(topLeft.dx, topLeft.dy, box.size.width, box.size.height));
      widget.options.onBoundsChanged(bounds);
    };
    _onMovedSub = widget.map.onMoved.listen((_) {
      setBounds();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setBounds();
    });
  }

  @override
  void dispose() {
    _onMovedSub?.cancel();
    super.dispose();
  }

  Bounds _pxBoundsToTileRange(Bounds bounds) {
    var tileSize = CustomPoint(256.0, 256.0);
    return Bounds(
      bounds.min.unscaleBy(tileSize).floor(),
      bounds.max.unscaleBy(tileSize).ceil() - CustomPoint(1, 1),
    );
  }

  Bounds _getBounds(double xPos, double yPos, double width, double height) {
    var sX = xPos + width;
    var sY = yPos + height;

    final offsetNo = Offset(xPos, yPos);
    final offsetSs = Offset(sX, sY);

    var nO = _offsetToPoint2(offsetNo);
    var sE = _offsetToPoint2(offsetSs);

    return Bounds(nO, sE);
  }

  Point _offsetToPoint2(Offset offset) {
    // Get the widget's offset
    var renderObject = context.findRenderObject() as RenderBox;
    var width = renderObject.size.width;
    var height = renderObject.size.height;

    // convert the point to global coordinates
    var localPoint = _offsetToPoint(offset);
    var localPointCenterDistance =
        CustomPoint((width / 2) - localPoint.x, (height / 2) - localPoint.y);
    var mapCenter = widget.map.project(widget.map.center);
    var point = mapCenter - localPointCenterDistance;
    return point;
  }

  CustomPoint _offsetToPoint(Offset offset) {
    return CustomPoint(offset.dx, offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.options.color.withOpacity(.3),
            width:
                widget.options.insets.top + MediaQuery.of(context).padding.top,
          ),
          right: BorderSide(
            color: widget.options.color.withOpacity(.3),
            width: widget.options.insets.right +
                MediaQuery.of(context).padding.right,
          ),
          bottom: BorderSide(
            color: widget.options.color.withOpacity(.3),
            width: widget.options.insets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
          left: BorderSide(
            color: widget.options.color.withOpacity(.3),
            width: widget.options.insets.left +
                MediaQuery.of(context).padding.left,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: widget.options.color, width: 4),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(key: _areaKey);
          },
        ),
      ),
    );
  }
}

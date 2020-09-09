import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      widget.options.onAreaChanged(AreaPickerState(
        topLeft.dx,
        topLeft.dy,
        box.size.width,
        box.size.height,
        widget.map.zoom,
        widget.map.center,
      ));
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

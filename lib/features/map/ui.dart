import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:skip_ohoi/features/map/latlng_tools.dart';
import 'package:skip_ohoi/features/map/map_container.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final _layerRebuilder = StreamController<Null>.broadcast();
  final _markers = <Marker>[];
  DateTime timeStamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observeMany: [
        () => mapTypeState.getRM,
        () => locationState.getRM,
      ],
      onSetState: (context, model) {
        if (model is ReactiveModel<MapType>) {
          _layerRebuilder.add(null);
        }
      },
      builder: (context, _) {
        final getMap = (LatLng location) {
          return MapContainer(
            layerRebuilderStream: _layerRebuilder.stream,
            location: location,
            markers: _markers,
          );
        };
        return locationState.state == null
            ? getMap(null)
            : TweenAnimationBuilder(
                tween: LatLngTween(
                  begin: locationState.state.latLng,
                  end: locationState.state.latLng,
                ),
                duration: Duration(milliseconds: 1000),
                builder: (context, location, _) {
                  return getMap(location);
                },
              );
      },
    );
  }

  @override
  void dispose() {
    _layerRebuilder.close();
    super.dispose();
  }
}

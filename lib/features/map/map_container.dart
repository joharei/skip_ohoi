import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong/latlong.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/map/animated_map_move.dart';
import 'package:skip_ohoi/features/map/degrees_tween.dart';
import 'package:skip_ohoi/features/map/latlng_tools.dart';
import 'package:skip_ohoi/features/map/scalebar/scale_bar_plugin.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_options.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_plugin.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

const _myLocationSize = 40.0;

class MapContainer extends StatefulWidget {
  final Stream layerRebuilderStream;
  final List<Marker> markers;
  final LatLng location;

  const MapContainer({
    Key key,
    @required this.layerRebuilderStream,
    @required this.markers,
    @required this.location,
  }) : super(key: key);

  @override
  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer>
    with TickerProviderStateMixin {
  final _mapController = MapController();

  StreamSubscription _mapEventsSub;
  Disposer _zoomButtonDisposer;
  Disposer _locationDisposer;
  Function _mapLockAnimationCanceller;
  bool _gestureInProgress = false;

  @override
  void initState() {
    super.initState();

    _mapEventsSub = _mapController.mapEventStream
        .where((event) => !(event is MapEventMove))
        .listen((event) {
      _gestureInProgress = event is MapEventMoveStart;
      if (_gestureInProgress) {
        _mapLockAnimationCanceller?.call();
        _mapLockAnimationCanceller = null;
      }
    });

    _zoomButtonDisposer = zoomToLocationState.getRM.listenToRM((rm) {
      if (locationState.state != null) {
        _mapLockAnimationCanceller?.call();
        _mapLockAnimationCanceller = null;
        animatedMapMove(
          _mapController,
          this,
          locationState.state.latLng,
          16,
        );
      }
    });

    _locationDisposer = locationState.getRM.listenToRM((rm) {
      if (mapLockedState.state && rm.state != null && !_gestureInProgress) {
        _mapLockAnimationCanceller?.call();

        if (widget.location != null &&
            !_mapController.bounds.contains(widget.location)) {
          mapLockedState.setState((s) => false);
          return;
        }

        _mapLockAnimationCanceller = animatedMapMove(
          _mapController,
          this,
          Distance().offset(
            rm.state.latLng,
            Distance().distance(widget.location, _mapController.center),
            Distance().bearing(widget.location, _mapController.center),
          ),
          _mapController.zoom,
          millis: 1000,
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _mapEventsSub.cancel();
    _zoomButtonDisposer();
    _locationDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observeMany: [
        () => mapLockedState.getRM,
        () => encTokensState.getRM,
        () => chooseDownloadArea.getRM,
        () => offlineTilesState.getRM,
      ],
      builder: (context, _) {
        return FlutterMap(
          options: MapOptions(
            center: LatLng(59.002671, 5.754133),
            zoom: 10.0,
            maxZoom: 18,
            plugins: [ScaleLayerPlugin(), AreaPickerPlugin()],
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            onPositionChanged: (position, _) {
              if (widget.location != null &&
                  !position.bounds.contains(widget.location)) {
                mapLockedState.setState((s) => false);
              }
            },
          ),
          mapController: _mapController,
          layers: [
            if (offlineTilesState.state != null &&
                offlineTilesState.state.filesDownloaded != null &&
                offlineTilesState.state.filesDownloaded ==
                    offlineTilesState.state.total)
              TileLayerOptions(
                urlTemplate: '${offlineTilesState.state.path}/{z}/{x}/{y}.png',
                maxZoom: offlineTilesState.state.maxZoom,
                minZoom: offlineTilesState.state.minZoom,
                tileProvider: FileTileProvider(),
                errorTileCallback: (tile, error) {
                  developer.log(
                    'Failed to load offline tile: ${tile.toString()}',
                    error: error,
                  );
                },
                rebuild: widget.layerRebuilderStream,
              ),
            if (isOnlineState.state)
              if (mapTypeState.state == MapType.ENC &&
                  encTokensState.state != null)
                MapType.ENC.options(
                  rebuild: widget.layerRebuilderStream,
                  encTicket: encTokensState.state.ticket,
                  encGkt: encTokensState.state.gkt,
                )
              else if (mapTypeState.state != MapType.ENC)
                mapTypeState.state
                    .options(rebuild: widget.layerRebuilderStream),
            if (widget.location != null)
              CircleLayerOptions(
                circles: [
                  CircleMarker(
                    point: widget.location,
                    color: navyBlue.withOpacity(0.1),
                    borderStrokeWidth: 1,
                    borderColor: navyBlue.withOpacity(0.2),
                    useRadiusInMeter: true,
                    radius: locationState.state.accuracy,
                  ),
                ],
                rebuild: widget.layerRebuilderStream,
              ),
            MarkerLayerOptions(
              markers: [
                ...widget.markers,
                if (widget.location != null)
                  Marker(
                    point: widget.location,
                    height: _myLocationSize,
                    width: _myLocationSize,
                    anchorPos: AnchorPos.align(AnchorAlign.center),
                    builder: (context) {
                      return TweenAnimationBuilder(
                        tween: DegreesTween(
                          begin: locationState.state.heading,
                          end: locationState.state.heading,
                        ),
                        duration: Duration(milliseconds: 1000),
                        child: SvgPicture.asset('images/boat.svg'),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: vector_math.radians(value),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
              ],
              rebuild: widget.layerRebuilderStream,
            ),
            if (chooseDownloadArea.state)
              AreaPickerLayerOptions(
                onAreaChanged: (state) {
                  areaPickerState.setState((s) => state);
                },
                color: navyBlue,
                insets:
                    EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48),
              ),
          ],
          nonRotatedLayers: [
            ScaleLayerPluginOption(
              lineColor: navyBlue,
              lineWidth: 2,
              textStyle: TextStyle(color: navyBlue, fontSize: 12),
              padding: EdgeInsets.only(
                left: 16,
                bottom: chooseDownloadArea.state
                    ? 35
                    : MediaQuery.of(context).padding.bottom + 35,
              ),
              alignment: Alignment.bottomLeft,
            ),
          ],
        );
      },
    );
  }
}

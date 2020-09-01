import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/map/animated_map_move.dart';
import 'package:skip_ohoi/features/map/animated_marker_move.dart';
import 'package:skip_ohoi/features/map/degrees_tween.dart';
import 'package:skip_ohoi/features/map/scalebar/scale_bar_plugin.dart';
import 'package:skip_ohoi/secrets.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with TickerProviderStateMixin {
  static const _myLocationSize = 40.0;
  final _layerRebuilder = StreamController<Null>.broadcast();
  final _mapController = MapController();
  final _markers = <Marker>[];
  String ticket = '';
  String gkt = '';
  DateTime timeStamp = DateTime.now();
  LatLng _location;
  Disposer _sub;

  @override
  void initState() {
    super.initState();

    _sub = locationState.getRM.listenToRM((model) {
      if (_location == null) {
        setState(() {
          _location = LatLng(
            locationState.state.latitude,
            locationState.state.longitude,
          );
        });
      } else {
        animatedMarkerMove(
          this,
          _location,
          LatLng(
            locationState.state.latitude,
            locationState.state.longitude,
          ),
          (newLocation) {
            setState(() {
              _location = newLocation;
            });
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshEncTokens();
    return StateBuilder(
      observeMany: [
        () => mapTypeState.getRM,
        () => locationState.getRM,
        () => zoomToLocationState.getRM,
      ],
      onSetState: (context, model) {
        if (model is ReactiveModel<MapType>) {
          _layerRebuilder.add(null);
        } else if (model is ReactiveModel<Zoom> && _location != null) {
          animatedMapMove(
            _mapController,
            this,
            LatLng(_location.latitude, _location.longitude),
            16,
          );
        }
      },
      builder: (context, _) {
        return FlutterMap(
          options: MapOptions(
            center: LatLng(59.002671, 5.754133),
            zoom: 10.0,
            maxZoom: mapTypeState.state == MapType.SJOKARTRASTER ? 19 : 18,
            plugins: [ScaleLayerPlugin()],
          ),
          mapController: _mapController,
          layers: [
            if (mapTypeState.state == MapType.ENC &&
                ticket.isNotEmpty &&
                gkt.isNotEmpty)
              TileLayerOptions(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl:
                      'https://wms.geonorge.no/skwms1/wms.ecc_enc?ticket={ticket}&gkt={gkt}',
                  layers: ['cells'],
                  styles: ['style-id-260'],
                ),
                additionalOptions: {
                  'ticket': ticket,
                  'gkt': gkt,
                },
                errorTileCallback: (tile, error) {
                  refreshEncTokens();
                },
                rebuild: _layerRebuilder.stream,
              ),
            if (mapTypeState.state == MapType.SJOKARTRASTER)
              TileLayerOptions(
                urlTemplate:
                    'https://opencache{s}.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=sjokartraster&zoom={z}&x={x}&y={y}',
                subdomains: ['', '2', '3'],
                rebuild: _layerRebuilder.stream,
              ),
            if (mapTypeState.state == MapType.ENIRO)
              TileLayerOptions(
                urlTemplate:
                    'http://map0{s}.eniro.no/geowebcache/service/tms1.0.0/nautical/{z}/{x}/{y}.png',
                subdomains: ['1', '2', '3', '4'],
                tms: true,
                rebuild: _layerRebuilder.stream,
              ),
            CircleLayerOptions(
              circles: [
                if (_location != null)
                  CircleMarker(
                    point: _location,
                    color: navyBlue.withOpacity(0.1),
                    borderStrokeWidth: 1,
                    borderColor: navyBlue.withOpacity(0.2),
                    useRadiusInMeter: true,
                    radius: locationState.state.accuracy,
                  ),
              ],
              rebuild: _layerRebuilder.stream,
            ),
            MarkerLayerOptions(
              markers: [
                ..._markers,
                if (_location != null)
                  Marker(
                    point: _location,
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
              rebuild: _layerRebuilder.stream,
            ),
            ScaleLayerPluginOption(
              lineColor: navyBlue,
              lineWidth: 2,
              textStyle: TextStyle(color: navyBlue, fontSize: 12),
              padding: EdgeInsets.only(
                left: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 38,
              ),
              alignment: Alignment.bottomLeft,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _layerRebuilder.close();
    _sub();
    super.dispose();
  }

  void refreshEncTokens() {
    if (mapTypeState.state != MapType.ENC ||
        ticket.isNotEmpty &&
            gkt.isNotEmpty &&
            timeStamp.add(Duration(seconds: 15)).isAfter(DateTime.now())) {
      return;
    }
    timeStamp = DateTime.now();
    Future.wait([http.get(gateKeeperTicketUrl), http.get(gateKeeperTokenUrl)])
        .then((responses) {
      String value(String body) =>
          RegExp(r'^"(.*)"\W$').firstMatch(body).group(1);
      setState(() {
        ticket = value(responses[0].body);
        gkt = value(responses[1].body);
      });
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/map/animated_map_move.dart';
import 'package:skip_ohoi/map/animated_marker_move.dart';
import 'package:skip_ohoi/secrets.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

class Map extends StatefulWidget {
  const Map({
    Key key,
    @required this.mapType,
  }) : super(key: key);

  final MapType mapType;

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
  double _heading = 0;
  double _accuracy = 0;
  StreamSubscription<LocationData> _sub;

  @override
  void initState() {
    super.initState();

    Location().changeSettings(accuracy: LocationAccuracy.high, interval: 500);
    _sub = Location().onLocationChanged.listen((ld) {
      _heading = ld.heading;
      _accuracy = ld.accuracy;
      if (_location == null) {
        setState(() {
          _location = LatLng(ld.latitude, ld.longitude);
        });
        return;
      }
      animatedMarkerMove(this, _location, LatLng(ld.latitude, ld.longitude),
          (newLocation) {
        setState(() {
          _location = newLocation;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshEncTokens();
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(59.002671, 5.754133),
            zoom: 10.0,
            maxZoom: widget.mapType == MapType.SJOKARTRASTER ? 19 : 18,
          ),
          mapController: _mapController,
          layers: [
            if (widget.mapType == MapType.ENC &&
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
            if (widget.mapType == MapType.SJOKARTRASTER)
              TileLayerOptions(
                urlTemplate:
                    'https://opencache{s}.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=sjokartraster&zoom={z}&x={x}&y={y}',
                subdomains: ['', '2', '3'],
                rebuild: _layerRebuilder.stream,
              ),
            if (widget.mapType == MapType.ENIRO)
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
                    radius: _accuracy,
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
                        tween: Tween(begin: _heading, end: _heading),
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
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              right: 16.0,
            ),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.location_searching),
              onPressed: () {
                if (_location != null) {
                  animatedMapMove(
                    _mapController,
                    this,
                    LatLng(_location.latitude, _location.longitude),
                    16,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _layerRebuilder.close();
    _sub.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(Map oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapType != widget.mapType) {
      _layerRebuilder.add(null);
    }
  }

  void refreshEncTokens() {
    if (widget.mapType != MapType.ENC ||
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

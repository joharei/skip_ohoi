import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:skip_ohoi/map/animated_map_move.dart';
import 'package:skip_ohoi/map/animated_marker_move.dart';
import 'package:skip_ohoi/secrets.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

const _resolutions = <double>[
  21664,
  10832,
  5416,
  2708,
  1354,
  677,
  338.5,
  169.25,
  84.625,
  42.3125,
  21.15625,
  10.578125,
  5.2890625,
  2.64453125,
  1.322265625,
  0.6611328125,
  0.33056640625,
  0.165283203125
];
final _maxZoom = (_resolutions.length - 1).toDouble();

final _epsg25833CRS = Proj4Crs.fromFactory(
  code: 'EPSG:25833',
  proj4Projection: proj4.Projection.add('EPSG:25833',
      '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'),
  resolutions: _resolutions,
);

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
  String ticket = '';
  String gkt = '';
  DateTime timeStamp = DateTime.now();
  LatLng _location;
  double _heading = 0;
  final _layerRebuilder = StreamController<Null>();
  final _mapController = MapController();
  final _markers = <Marker>[];
  StreamSubscription<LocationData> _sub;

  @override
  void initState() {
    super.initState();

    _sub = Location.instance.onLocationChanged.listen((ld) {
      _heading = ld.heading;
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
            crs: widget.mapType == MapType.ENC ? _epsg25833CRS : Epsg3857(),
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
                  crs: _epsg25833CRS,
                ),
                additionalOptions: {
                  'ticket': ticket,
                  'gkt': gkt,
                },
                maxZoom: _maxZoom,
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
                maxZoom: 19,
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
            MarkerLayerOptions(markers: [
              ..._markers,
              Marker(
                point: _location,
                height: 60,
                anchorPos: AnchorPos.exactly(Anchor(8.97, 50)),
                builder: (context) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    transform: Matrix4.rotationZ(vector_math.radians(_heading)),
                    child: SvgPicture.asset('images/boat.svg'),
                  );
                },
              ),
            ]),
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
                onPressed: () => {
                      Location.instance.getLocation().then((ld) {
                        animatedMapMove(
                          _mapController,
                          this,
                          LatLng(ld.latitude, ld.longitude),
                          14,
                        );
                      })
                    }),
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
    setState(() {
      timeStamp = DateTime.now();
    });
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

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:skip_ohoi/secrets.dart';

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

class _MapState extends State<Map> {
  String ticket = '';
  String gkt = '';
  DateTime timeStamp = DateTime.now();
  final StreamController<Null> layerRebuilder = StreamController();

  @override
  Widget build(BuildContext context) {
    developer.log(widget.mapType.toString());
    refreshEncTokens();
    return FlutterMap(
      options: MapOptions(
        center: LatLng(59.002671, 5.754133),
        zoom: 10.0,
        crs: widget.mapType == MapType.ENC ? _epsg25833CRS : Epsg3857(),
      ),
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
            rebuild: layerRebuilder.stream,
          ),
        if (widget.mapType == MapType.SJOKARTRASTER)
          TileLayerOptions(
            urlTemplate:
                'https://opencache{s}.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=sjokartraster&zoom={z}&x={x}&y={y}',
            subdomains: ['', '2', '3'],
            maxZoom: 19,
            rebuild: layerRebuilder.stream,
          ),
        if (widget.mapType == MapType.ENIRO)
          TileLayerOptions(
            urlTemplate:
                'http://map0{s}.eniro.no/geowebcache/service/tms1.0.0/nautical/{z}/{x}/{y}.png',
            subdomains: ['1', '2', '3', '4'],
            tms: true,
            rebuild: layerRebuilder.stream,
          ),
      ],
    );
  }

  @override
  void dispose() {
    layerRebuilder.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(Map oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapType != widget.mapType) {
      layerRebuilder.add(null);
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
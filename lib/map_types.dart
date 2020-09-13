import 'dart:developer' as developer;

import 'package:flutter_map/flutter_map.dart';

enum MapType {
  ENC,
  SJOKARTRASTER,
  ENIRO,
}

extension MapTypeExtension on MapType {
  // ignore: missing_return
  TileLayerOptions options({Stream rebuild, String encTicket, String encGkt}) {
    switch (this) {
      case MapType.ENC:
        return TileLayerOptions(
          wmsOptions: WMSTileLayerOptions(
            baseUrl:
                'https://wms.geonorge.no/skwms1/wms.ecc_enc?ticket={ticket}&gkt={gkt}',
            layers: ['cells'],
            styles: ['style-id-260'],
          ),
          additionalOptions: {
            'ticket': encTicket,
            'gkt': encGkt,
          },
          errorTileCallback: (tile, error) {
            developer.log(
              'Failed to load WMS tile: ${tile.toString()}',
              error: error,
            );
          },
          rebuild: rebuild,
        );
      case MapType.SJOKARTRASTER:
        return TileLayerOptions(
          urlTemplate:
              'https://opencache{s}.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=sjokartraster&zoom={z}&x={x}&y={y}',
          subdomains: ['', '2', '3'],
          rebuild: rebuild,
        );
      case MapType.ENIRO:
        return TileLayerOptions(
          urlTemplate:
              'http://map0{s}.eniro.no/geowebcache/service/tms1.0.0/nautical/{z}/{x}/{y}.png',
          subdomains: ['1', '2', '3', '4'],
          tms: true,
          rebuild: rebuild,
        );
    }
  }

  // ignore: missing_return
  String get imageAsset {
    switch (this) {
      case MapType.ENC:
        return 'images/preview_enc.png';
      case MapType.SJOKARTRASTER:
        return 'images/preview_sjokartraster.png';
      case MapType.ENIRO:
        return 'images/preview_eniro.png';
    }
  }

  // ignore: missing_return
  String get text {
    switch (this) {
      case MapType.ENC:
        return 'Elektronisk';
      case MapType.SJOKARTRASTER:
        return 'Raster';
      case MapType.ENIRO:
        return 'Eniro';
    }
  }

  // ignore: missing_return
  String get key {
    switch (this) {
      case MapType.ENC:
        return 'enc';
      case MapType.SJOKARTRASTER:
        return 'sjokartraster';
      case MapType.ENIRO:
        return 'eniro';
    }
  }
}

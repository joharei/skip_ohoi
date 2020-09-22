import 'package:flt_worker/flt_worker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:skip_ohoi/features/offline_maps/tile_downloader.dart';
import 'package:skip_ohoi/map_types.dart';

Future<void> worker(WorkPayload payload) {
  if (payload.tags.contains('app.reitan.skipOhoi.tileDownloader')) {
    return downloadMapArea(
      MapTypeExtension.parse(payload.input['mapTypeKey']),
      LatLngBounds(
        LatLng(
            payload.input['bounds']['north'], payload.input['bounds']['west']),
        LatLng(
            payload.input['bounds']['south'], payload.input['bounds']['east']),
      ),
      payload.input['minZoom'],
      payload.input['maxZoom'],
    );
  } else {
    return Future.value();
  }
}

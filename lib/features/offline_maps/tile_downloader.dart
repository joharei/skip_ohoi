import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_options.dart';

Bounds _pxBoundsToTileRange(Bounds bounds) {
  var tileSize = CustomPoint(256.0, 256.0);
  return Bounds(
    bounds.min.unscaleBy(tileSize).floor(),
    bounds.max.unscaleBy(tileSize).ceil() - CustomPoint(1, 1),
  );
}

double _clampZoom(double zoom) {
  // todo
  return zoom;
}

bool _isValidTile(Bounds globalTileRange, Coords coords) {
  final crs = Epsg3857();
  if (!crs.infinite) {
    if ((crs.wrapLng == null &&
            (coords.x < globalTileRange.min.x ||
                coords.x > globalTileRange.max.x)) ||
        (crs.wrapLat == null &&
            (coords.y < globalTileRange.min.y ||
                coords.y > globalTileRange.max.y))) {
      return false;
    }
  }
  return true;
}

double _getZoomScale(double toZoom, double fromZoom) {
  var crs = const Epsg3857();

  return crs.scale(toZoom) / crs.scale(fromZoom);
}

Bounds _getBounds(
  double xPos,
  double yPos,
  double width,
  double height,
  double zoom,
  double originalZoom,
  LatLng center,
) {
  var sX = xPos + width;
  var sY = yPos + height;

  final offsetNo = Offset(xPos, yPos);
  final offsetSs = Offset(sX, sY);

  var nO = _offsetToPoint2(offsetNo, width, height, center, zoom);
  var sE = _offsetToPoint2(offsetSs, width, height, center, zoom);

  var scale = _getZoomScale(zoom, originalZoom);

  return Bounds(nO * scale, sE * scale);
}

Future<void> _downloadFile(String url, String filename, String dir) async {
  var req = await http.Client().get(Uri.parse(url));
  var file = File('$dir/$filename');
  await file.writeAsBytes(req.bodyBytes);
}

List<Coords> _generateVirtualGrids(
  TileLayerOptions options,
  double zoom,
  AreaPickerState area,
) {
  final tileZoom = _clampZoom(zoom.roundToDouble());
  Bounds<num> globalTileRange;
  final crs = Epsg3857();
  final bounds = crs.getProjectedBounds(tileZoom);
  if (bounds != null) {
    globalTileRange = _pxBoundsToTileRange(bounds);
  }

  var pixelBounds = _getBounds(
    area.xPos,
    area.yPos,
    area.width,
    area.height,
    zoom,
    area.zoom,
    area.mapCenter,
  );

  var tileRange = _pxBoundsToTileRange(pixelBounds);

  var queue = <Coords>[];

  for (var j = tileRange.min.y; j <= tileRange.max.y; j++) {
    for (var i = tileRange.min.x; i <= tileRange.max.x; i++) {
      var coords = Coords(i.toDouble(), j.toDouble());
      coords.z = tileZoom;

      if (!_isValidTile(globalTileRange, coords)) {
        continue;
      }
      queue.add(coords);
    }
  }

  return queue;
}

Future<void> _downloadTiles(
  TileLayerOptions options,
  List<Coords> queue,
  String dir,
) async {
  final tasks = queue.map((coords) async {
    String url = options.tileProvider.getTileUrl(coords, options);
    developer.log('Downloading: $url');
    final dirName =
        '$dir/offline_map/${coords.z.round().toString()}/${coords.x.round().toString()}';
    await Directory(dirName).create(recursive: true);
    await _downloadFile(url, '${coords.y.round().toString()}.png', dirName);
  });
  await Future.wait(tasks);
}

Point _offsetToPoint2(
  Offset offset,
  double width,
  double height,
  LatLng center,
  double originalZoom,
) {
  // convert the point to global coordinates
  var localPoint = _offsetToPoint(offset);
  var localPointCenterDistance =
      CustomPoint((width / 2) - localPoint.x, (height / 2) - localPoint.y);
  var mapCenter = Epsg3857().latLngToPoint(center, originalZoom);
  var point = mapCenter - localPointCenterDistance;
  return point;
}

CustomPoint _offsetToPoint(Offset offset) {
  return CustomPoint(offset.dx, offset.dy);
}

Stream<int> downloadMapArea(
  TileLayerOptions options,
  AreaPickerState area,
  double minZoom,
  double maxZoom,
) async* {
  developer.log('Requesting permission', name: 'tile_downloader');
  if (await Permission.storage.request().isGranted) {
    var dir = (await getApplicationDocumentsDirectory()).path;

    yield 0;
    developer.log('Starting');

    for (var i = minZoom; i <= maxZoom; i++) {
      final queue = _generateVirtualGrids(options, i, area);
      developer.log('Got ${queue.length} virtual grids');
      if (queue.isNotEmpty) {
        await _downloadTiles(options, queue, dir);
      }

      final zoomLevels = maxZoom - minZoom + 1;
      final currentZoomLevel = i - minZoom + 1;

      double currentPercent = (100.0 / zoomLevels) * currentZoomLevel;

      yield currentPercent.round();
      developer.log('Progress: ${currentPercent.round()}%');
    }
  }
}

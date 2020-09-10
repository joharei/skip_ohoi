import 'dart:math' as math;

import 'package:latlong/latlong.dart';

/// TileID represents id of the tile in (x, y, z) format.
class TileID {
  final int x;
  final int y;
  final int z;

  TileID(this.x, this.y, this.z);

  @override
  String toString() {
    return 'TileID{x: $x, y: $y, z: $z}';
  }
}

/// Gets the tile containing a longitude and latitude.
TileID _tile(LatLng latLng, int zoom) {
  final lat = latLng.latitude * (math.pi / 180.0);
  final n = math.pow(2.0, zoom);
  final tileX = ((latLng.longitude + 180.0) / 360.0 * n).floor();
  final tileY =
      ((1.0 - math.log(math.tan(lat) + (1.0 / math.cos(lat))) / math.pi) /
              2.0 *
              n)
          .floor();
  return TileID(tileX, tileY, zoom);
}

/// Gets the tiles intersecting a geographic bounding box.
List<TileID> tiles(
  double west,
  double south,
  double east,
  double north,
  List<int> zooms,
) {
  List<List<double>> bboxes;
  if (west > east) {
    final bboxWest = [-180.0, south, east, north];
    final bboxEast = [west, south, 180.0, north];
    bboxes = [bboxWest, bboxEast];
  } else {
    bboxes = [
      [west, south, east, north]
    ];
  }

  final tiles = <TileID>[];
  for (var bbox in bboxes) {
    final west = math.max(-180.0, bbox[0]);
    final south = math.max(-85.051129, bbox[1]);
    final east = math.min(180.0, bbox[2]);
    final north = math.min(85.051129, bbox[3]);

    for (var zoom in zooms) {
      final lowerLeft = _tile(LatLng(south, west), zoom);
      final upperRight = _tile(LatLng(north, east), zoom);

      final lowerLeftX = math.max(0, lowerLeft.x);
      final upperRightY = math.max(0, upperRight.y);

      for (var i = lowerLeftX;
          i < (math.min(upperRight.x + 1.0, math.pow(2.0, zoom))).toInt();
          i++) {
        for (var j = upperRightY;
            j < (math.min(lowerLeft.y + 1.0, math.pow(2.0, zoom))).toInt();
            j++) {
          tiles.add(TileID(i, j, zoom));
        }
      }
    }
  }
  return tiles;
}

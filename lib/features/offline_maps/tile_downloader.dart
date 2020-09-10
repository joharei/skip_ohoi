import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_options.dart';
import 'package:skip_ohoi/features/offline_maps/mercantile.dart';

Future<void> _downloadFile(String url, String filename, String dir) async {
  // TODO: ensure ENC tiles are downloaded correctly
  var req = await http.Client().get(Uri.parse(url));
  var file = File('$dir/$filename');
  await file.writeAsBytes(req.bodyBytes);
}

Stream<List<T>> _chunk<T>(List<T> list, int chunkSize) async* {
  final len = list.length;
  for (var i = 0; i < len; i += chunkSize) {
    final size = i + chunkSize;
    yield list.sublist(i, size > len ? len : size);
  }
}

Stream<Null> _downloadTiles(
  TileLayerOptions options,
  List<Coords<double>> queue,
  String dir,
) {
  return _chunk(queue, 5).asyncExpand(
    (taskChunk) => Stream.fromIterable(taskChunk).asyncMap(
      (coords) async {
        String url = options.tileProvider.getTileUrl(coords, options);
        final dirName =
            '$dir/offline_map/${coords.z.round().toString()}/${coords.x.round().toString()}';
        await Directory(dirName).create(recursive: true);
        await _downloadFile(url, '${coords.y.round().toString()}.png', dirName);
      },
    ),
  );
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

    final zooms = List.generate(
      (maxZoom - minZoom + 1).toInt(),
      (index) => minZoom.toInt() + index,
    );
    final tileIds = tiles(
      area.bounds.west,
      area.bounds.south,
      area.bounds.east,
      area.bounds.north,
      zooms,
    );

    // TODO: skip files that are already downloaded
    final total = tileIds.length;
    developer.log('Downloading $total tiles to directory: $dir');
    var progress = 0;
    yield* _downloadTiles(
      options,
      tileIds
          .map((tileId) => Coords(tileId.x.toDouble(), tileId.y.toDouble())
            ..z = tileId.z.toDouble())
          .toList(),
      dir,
    ).map((_) => (++progress / total.toDouble() * 100).round());
  }
}

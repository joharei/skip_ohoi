import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skip_ohoi/features/offline_maps/mercantile.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/service.dart';
import 'package:tuple/tuple.dart';

Future<void> _downloadFile(String url, String filename, String dir) async {
  var req = await http.Client().get(Uri.parse(url));

  if (req.statusCode != 200 || req.body.contains('<?xml')) {
    developer.log('Unexpected XML response', error: req.body);
    throw 'Unexpected XML response';
  }

  await Directory(dir).create(recursive: true);
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

Stream _downloadTiles(
  MapType mapType,
  List<Coords<double>> queue,
  String dir,
) async* {
  final firstTokens = await encTokensRefresher(mapType).first;
  final tokensRefresher = encTokensRefresher(mapType)
      .asBroadcastStream(onCancel: (subscription) => subscription.cancel());
  yield* _chunk(queue, 5).asyncExpand(
    (taskChunk) => Stream.fromIterable(taskChunk)
        .withLatestFrom(tokensRefresher.startWith(firstTokens),
            (coords, EncTokens tokens) => Tuple2(coords, tokens))
        .asyncExpand(
          (tuple) => Rx.retry(
            () {
              final options = mapType.options(
                encTicket: tuple.item2?.ticket,
                encGkt: tuple.item2?.gkt,
              );
              String url =
                  options.tileProvider.getTileUrl(tuple.item1, options);
              final dirName =
                  '$dir/${tuple.item1.z.round().toString()}/${tuple.item1.x.round().toString()}';
              return Stream.fromFuture(
                _downloadFile(
                  url,
                  '${tuple.item1.y.round().toString()}.png',
                  dirName,
                ),
              );
            },
          ),
        ),
  );
}

Future<void> downloadMapArea(
  MapType mapType,
  LatLngBounds bounds,
  double minZoom,
  double maxZoom,
) async {
  try {
    final dir =
        '${(await getApplicationSupportDirectory()).path}/offline_maps/${mapType.key}';
    final directory = Directory(dir);
    await directory.create(recursive: true);

    developer.log('Starting');
    await _postStatus(mapType, dir, minZoom, maxZoom, bounds);

    final zooms = List.generate(
      (maxZoom - minZoom + 1).toInt(),
      (index) => minZoom.toInt() + index,
    );
    final tileIds = tiles(
      bounds.west,
      bounds.south,
      bounds.east,
      bounds.north,
      zooms,
    );

    final existingFiles = await directory
        .list(recursive: true)
        .whereType<File>()
        .map((file) => file.path)
        .toList();
    final missingTiles = tileIds.where((tile) =>
        !existingFiles.contains('$dir/${tile.z}/${tile.x}/${tile.y}.png'));

    final total = tileIds.length;
    developer.log(
        'Downloading ${missingTiles.length} out of $total tiles to directory: $dir');
    var progress = total - missingTiles.length;
    await _downloadTiles(
      mapType,
      missingTiles
          .map((tileId) => Coords(tileId.x.toDouble(), tileId.y.toDouble())
            ..z = tileId.z.toDouble())
          .toList(),
      dir,
    ).asyncMap((_) async {
      progress++;

      await _postStatus(
        mapType,
        dir,
        minZoom,
        maxZoom,
        bounds,
        total: total,
        progress: progress,
      );
    }).drain();
  } finally {
    FlutterLocalNotificationsPlugin().cancel(0);
  }
}

Future _postStatus(
  MapType mapType,
  String dir,
  double minZoom,
  double maxZoom,
  LatLngBounds bounds, {
  int total,
  int progress,
}) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'progress',
    'Nedlasting',
    'Viser status på nedlasting av kart',
    channelShowBadge: false,
    priority: Priority.Low,
    importance: Importance.Low,
    onlyAlertOnce: true,
    ongoing: true,
    showProgress: progress != null,
    maxProgress: total,
    progress: progress,
    styleInformation: progress != null
        ? BigTextStyleInformation(
            '${mapType.text}: $progress av $total fliser lastet ned',
            summaryText:
                '${(progress / total.toDouble() * 100).toStringAsFixed(0)} %',
          )
        : null,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics,
    iOSPlatformChannelSpecifics,
  );
  await FlutterLocalNotificationsPlugin().show(
    0,
    'Laster ned kart',
    progress == null
        ? 'Starter…'
        : '${mapType.text}: ${(progress / total.toDouble() * 100).toStringAsFixed(0)} %',
    platformChannelSpecifics,
  );

  await File('$dir/download_status.json').writeAsString(jsonEncode({
    'filesDownloaded': progress,
    'total': total,
    'minZoom': minZoom,
    'maxZoom': maxZoom,
    'bounds': {
      'west': bounds.west,
      'south': bounds.south,
      'east': bounds.east,
      'north': bounds.north,
    },
  }));
}

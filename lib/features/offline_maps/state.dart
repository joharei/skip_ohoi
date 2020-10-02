import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:path/path.dart' as pathPackage;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:watcher/watcher.dart';

final chooseDownloadArea = RM.inject(() => false);

final areaPickerState = RM.inject<LatLngBounds>(() => null);

final downloadsStatusState = RM.injectStream<List<DownloadStatus>>(() async* {
  Future<int> dirStat(Directory dir) => dir
      .list(recursive: true)
      .whereType<File>()
      .asyncMap((file) => file.length())
      .reduce((previous, element) => previous + element);

  final dir = '${(await getApplicationSupportDirectory()).path}/offline_maps';
  yield* DirectoryWatcher(dir)
      .events
      .startWith(null)
      .asyncMap((_) => Directory(dir)
          .list(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('download_status.json'))
          .doOnData((event) {
            developer.log(event.path);
          })
          .map((file) => (Platform.isAndroid
                      ? PollingFileWatcher(file.path)
                      : FileWatcher(file.path))
                  .events
                  .startWith(null)
                  .asyncMap((_) async {
                final status = DownloadStatus.fromJson(
                  jsonDecode(await file.readAsString()),
                  file.parent.path,
                );
                if (status.filesDownloaded == status.total) {
                  return status.copyWith(size: await dirStat(file.parent));
                }
                return status;
              }))
          .toList())
      .switchMap((statusWatchers) => Rx.combineLatestList(statusWatchers));
});

final offlineTilesState = RM.injectComputed<DownloadStatus>(
  compute: (_) {
    return downloadsStatusState.state?.firstWhere(
      (element) => element.mapType.key == mapTypeState.state.key,
      orElse: () => null,
    );
  },
);

class DownloadStatus {
  final int filesDownloaded;
  final int total;
  final double minZoom;
  final double maxZoom;
  final LatLngBounds bounds;
  final MapType mapType;
  final String path;
  final int directorySizeInBytes;

  DownloadStatus(
    this.filesDownloaded,
    this.total,
    this.minZoom,
    this.maxZoom,
    this.bounds,
    this.mapType,
    this.path,
    this.directorySizeInBytes,
  );

  factory DownloadStatus.fromJson(
    Map json,
    String path,
  ) =>
      DownloadStatus(
        json['filesDownloaded'],
        json['total'],
        json['minZoom'],
        json['maxZoom'],
        LatLngBounds(
          LatLng(json['bounds']['north'], json['bounds']['west']),
          LatLng(json['bounds']['south'], json['bounds']['east']),
        ),
        MapTypeExtension.parse(pathPackage.basename(path)),
        path,
        null,
      );

  DownloadStatus copyWith({int size}) => DownloadStatus(
        filesDownloaded,
        total,
        minZoom,
        maxZoom,
        bounds,
        mapType,
        path,
        size ?? directorySizeInBytes,
      );

  bool get active => filesDownloaded == null || filesDownloaded != total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatus &&
          runtimeType == other.runtimeType &&
          filesDownloaded == other.filesDownloaded &&
          total == other.total &&
          minZoom == other.minZoom &&
          maxZoom == other.maxZoom &&
          bounds == other.bounds &&
          mapType == other.mapType &&
          path == other.path &&
          directorySizeInBytes == other.directorySizeInBytes;

  @override
  int get hashCode =>
      filesDownloaded.hashCode ^
      total.hashCode ^
      minZoom.hashCode ^
      maxZoom.hashCode ^
      bounds.hashCode ^
      mapType.hashCode ^
      path.hashCode ^
      directorySizeInBytes.hashCode;

  @override
  String toString() {
    return 'DownloadStatus{filesDownloaded: $filesDownloaded, total: $total, minZoom: $minZoom, maxZoom: $maxZoom, bounds: $bounds, mapType: $mapType, path: $path, directorySizeInBytes: $directorySizeInBytes}';
  }
}

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skip_ohoi/features/offline_maps/area_picker/area_picker_options.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final chooseDownloadArea = RM.inject(() => false);

final areaPickerState = RM.inject<AreaPickerState>(() => null);

final applicationDirectoryState = RM.injectFuture(() async =>
    await Permission.storage.isGranted
        ? (await getApplicationDocumentsDirectory()).path
        : null);

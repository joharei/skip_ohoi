import 'package:flt_worker/flt_worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class ChooseDownloadOptions extends StatefulWidget {
  @override
  _ChooseDownloadOptionsState createState() => _ChooseDownloadOptionsState();
}

class _ChooseDownloadOptionsState extends State<ChooseDownloadOptions> {
  RangeValues _rangeValues = RangeValues(0, 19);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ZOOM-NIVÅER: ${_rangeValues.start.toStringAsFixed(0)}-${_rangeValues.end.toStringAsFixed(0)}',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontSize: 12, letterSpacing: 1.3),
            ),
            RangeSlider(
              values: _rangeValues,
              min: 0,
              max: 19,
              divisions: 19,
              labels: RangeLabels(
                _rangeValues.start.toStringAsFixed(0),
                _rangeValues.end.toStringAsFixed(0),
              ),
              onChanged: (value) {
                setState(() {
                  _rangeValues = value;
                });
              },
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chooseDownloadArea.setState((s) => false);
                      },
                      child: Text('LUKK'),
                    ),
                  ),
                  VerticalDivider(
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(
                    child: StateBuilder(
                      observeMany: [
                        () => mapTypeState.getRM,
                        () => areaPickerState.getRM,
                      ],
                      builder: (context, model) {
                        return FlatButton(
                          onPressed: () async {
                            await FlutterLocalNotificationsPlugin()
                                .resolvePlatformSpecificImplementation<
                                    IOSFlutterLocalNotificationsPlugin>()
                                ?.requestPermissions(
                                  alert: true,
                                  badge: true,
                                  sound: true,
                                );

                            await cancelWork(
                                'app.reitan.skipOhoi.tileDownloader');
                            enqueueWorkIntent(WorkIntent(
                              identifier: 'app.reitan.skipOhoi.tileDownloader',
                              input: {
                                'mapTypeKey': mapTypeState.state.key,
                                'minZoom': _rangeValues.start,
                                'maxZoom': _rangeValues.end,
                                'bounds': {
                                  'west': areaPickerState.state.west,
                                  'south': areaPickerState.state.south,
                                  'east': areaPickerState.state.east,
                                  'north': areaPickerState.state.north,
                                },
                              },
                              constraints: WorkConstraints(
                                networkType: NetworkType.unmetered,
                                storageNotLow: true,
                                batteryNotLow: true,
                              ),
                            ));
                            Navigator.pop(context);
                            chooseDownloadArea.setState((s) => false);
                          },
                          textColor: Theme.of(context).primaryColor,
                          child: Text('LAST NED'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';
import 'package:skip_ohoi/features/offline_maps/tile_downloader.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';

class ChooseDownloadOptions extends StatefulWidget {
  @override
  _ChooseDownloadOptionsState createState() => _ChooseDownloadOptionsState();
}

class _ChooseDownloadOptionsState extends State<ChooseDownloadOptions> {
  String _name = '';
  RangeValues _rangeValues = RangeValues(0, 19);
  StreamSubscription _sub;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8)
            .add(MediaQuery.of(context).viewInsets),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Navn*',
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'ZOOM-NIVÅER',
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
                // activeColor: Theme.of(context).primaryColor,
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
                      child: FlatButton(
                        onPressed: _name.isEmpty
                            ? null
                            : () {
                                developer.log('Starting download...');
                                _sub?.cancel();
                                _sub = downloadMapArea(
                                  mapTypeState.state.options(),
                                  areaPickerState.state,
                                  _rangeValues.start,
                                  _rangeValues.end,
                                ).listen((event) {
                                  developer.log('Got progress event: $event');
                                });
                              },
                        textColor: Theme.of(context).primaryColor,
                        child: Text('LAST NED'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

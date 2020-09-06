import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';

class ChooseDownloadOptions extends StatefulWidget {
  @override
  _ChooseDownloadOptionsState createState() => _ChooseDownloadOptionsState();
}

class _ChooseDownloadOptionsState extends State<ChooseDownloadOptions> {
  String _name = '';
  RangeValues _rangeValues = RangeValues(0, 19);

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
                        onPressed: _name.isEmpty ? null : () {},
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
}

import 'package:flutter/material.dart';
import 'package:international_system_of_units/international_system_of_units.dart';
import 'package:skip_ohoi/features/menu/ui.dart';
import 'package:skip_ohoi/state.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Menu();
                    });
                  },
                );
              },
            )
          ],
        ),
        locationState.rebuilder(() {
          return Row(
            children: [
              Spacer(),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      'Fart (knop)',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      locationState.state == null
                          ? ''
                          : locationState.state.speed.toKnot.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
              // TODO
              // Text('Trip'),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text('COG', style: Theme.of(context).textTheme.subtitle1),
                    Text(
                      locationState.state == null
                          ? ''
                          : '${locationState.state.heading.toStringAsFixed(0)}°',
                      style: Theme.of(context).textTheme.headline4,
                    )
                  ],
                ),
              ),
              Spacer(),
            ],
          );
        }),
      ],
    );
  }
}

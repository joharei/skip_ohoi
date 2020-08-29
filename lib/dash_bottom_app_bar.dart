import 'package:flutter/material.dart';
import 'package:skip_ohoi/map/map.dart';
import 'package:skip_ohoi/menu.dart';

class DashBottomAppBar extends StatelessWidget {
  final MapType mapType;
  final Function onChangeMapType;

  const DashBottomAppBar({
    Key key,
    this.mapType,
    this.onChangeMapType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Column(
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
                        return Menu(
                          activeMapType: mapType,
                          onChangeMapType: onChangeMapType,
                        );
                      });
                    },
                  );
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Fart'),
              Text('Trip'),
              Text('COG'),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/menu/ui.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Fart'),
            Text('Trip'),
            Text('COG'),
          ],
        )
      ],
    );
  }
}

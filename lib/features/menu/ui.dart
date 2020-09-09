import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/offline_maps/ui.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/state.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 239,
      padding: EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 24,
              height: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                    right: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'KARTTYPE',
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontSize: 12, letterSpacing: 1.3),
          ),
          SizedBox(height: 16),
          mapTypeState.rebuilder(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MapType.values.map((mapType) {
                final active = mapType == mapTypeState.state;
                return InkResponse(
                  radius: 70,
                  onTap: () => mapTypeState.setState((state) => mapType),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: active ? 2 : 1,
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(mapType.imageAsset),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        mapType.text,
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: active
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text('Offline kart'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfflineMaps()),
              );
            },
          ),
        ],
      ),
    );
  }
}

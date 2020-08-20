import 'package:flutter/material.dart';
import 'package:skip_ohoi/map.dart';

const _mapTypes = [
  {
    'mapType': MapType.ENC,
    'image': 'images/preview_enc.png',
    'text': 'Elektronisk',
  },
  {
    'mapType': MapType.SJOKARTRASTER,
    'image': 'images/preview_sjokartraster.png',
    'text': 'Raster',
  },
  {
    'mapType': MapType.ENIRO,
    'image': 'images/preview_eniro.png',
    'text': 'Eniro',
  }
];

class Menu extends StatelessWidget {
  Menu({
    Key key,
    @required this.activeMapType,
    @required this.onChangeMapType,
  });

  final MapType activeMapType;
  final Function(MapType) onChangeMapType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KARTTYPE',
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontSize: 12, letterSpacing: 1.3),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _mapTypes.map((mapType) {
              final active = mapType['mapType'] == activeMapType;
              return InkResponse(
                radius: 70,
                onTap: () => onChangeMapType(mapType['mapType']),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: active
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(mapType['image']),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      mapType['text'],
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color:
                                active ? Theme.of(context).primaryColor : null,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skip_ohoi/state.dart';

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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 200,
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
                children: _mapTypes.map((mapType) {
                  final active = mapType['mapType'] == mapTypeState.state;
                  return InkResponse(
                    radius: 70,
                    onTap: () =>
                        mapTypeState.setState((state) => mapType['mapType']),
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
                              image: AssetImage(mapType['image']),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          mapType['text'],
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
          ],
        ),
      ),
    );
  }
}

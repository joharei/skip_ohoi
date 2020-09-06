import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';

class OfflineMaps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Offline kart',
                style: Theme.of(context).appBarTheme.textTheme.headline6,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text('Kart 1'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Last ned nytt område',
        onPressed: () {
          chooseDownloadArea.setState((s) => true);
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
      ),
    );
  }
}

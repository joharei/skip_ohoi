import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:skip_ohoi/features/offline_maps/state.dart';
import 'package:skip_ohoi/features/offline_maps/tile_downloader.dart'
    as TileDownloader;
import 'package:skip_ohoi/map_types.dart';

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
          downloadsStatusState.rebuilder(
            () => downloadsStatusState.state == null
                ? SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'Trykk på "+"-knappen for å laste ned et område'),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final state = downloadsStatusState.state[index];
                        return ExpansionTile(
                          title: Text(state.mapType.text),
                          leading: Container(
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage(state.mapType.imageAsset),
                            ),
                            padding: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .dividerColor, // border color
                              shape: BoxShape.circle,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.filesDownloaded == null)
                                Text('Starter nedlasting…')
                              else if (!state.active)
                                Text(
                                    'Tilgjengelig offline: ${filesize(state.directorySizeInBytes)}')
                              else
                                Text(
                                    '${state.filesDownloaded} av ${state.total} fliser (${(state.filesDownloaded / state.total.toDouble() * 100).toStringAsFixed(0)} %) lastet ned'),
                              SizedBox(height: 8),
                              if (state.filesDownloaded != null &&
                                  state.filesDownloaded != state.total)
                                TweenAnimationBuilder(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: state.filesDownloaded /
                                        state.total.toDouble(),
                                  ),
                                  curve: Curves.easeInOut,
                                  duration: Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.2),
                                    );
                                  },
                                ),
                            ],
                          ),
                          initiallyExpanded:
                              downloadsStatusState.state.length == 1,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (state.active)
                                    Tooltip(
                                      message: 'Avbryt nedlasting',
                                      child: IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () async {
                                          await TileDownloader.cancelDownload(
                                              state);
                                        },
                                      ),
                                    ),
                                  Tooltip(
                                    message: 'Slett',
                                    child: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await TileDownloader.cancelDownload(
                                            state);
                                        await TileDownloader.deleteDownload(
                                            state.mapType);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                      childCount: downloadsStatusState.state.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Last ned nytt område',
        onPressed: () {
          chooseDownloadArea.setState((s) => true);
          Navigator.pushNamed(context, '/');
        },
      ),
    );
  }
}

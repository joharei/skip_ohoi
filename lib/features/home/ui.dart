import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/dashboard/ui.dart';
import 'package:skip_ohoi/features/map/ui.dart';
import 'package:skip_ohoi/state.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).backgroundColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: navyBlue,
              body: Center(
                child: Text(
                  'Splitte mine bramseil!',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: nyanza),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              body: MapPage(),
              extendBody: true,
              bottomNavigationBar: BottomAppBar(
                child: Dashboard(),
                shape: CircularNotchedRectangle(),
              ),
              floatingActionButton: Container(
                margin: const EdgeInsets.only(bottom: 56),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mapLockedState.rebuilder(() {
                      return FloatingActionButton(
                        heroTag: null,
                        child: const Icon(Icons.vpn_lock),
                        foregroundColor: mapLockedState.state
                            ? Theme.of(context).primaryColor
                            : null,
                        onPressed: () {
                          mapLockedState.setState((s) => !s);
                        },
                        mini: true,
                      );
                    }),
                    SizedBox(height: 8),
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: nyanza,
                      child: const Icon(Icons.location_searching),
                      onPressed: () {
                        zoomToLocationState.setState((s) => Zoom());
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endDocked,
            );
          }
          return Scaffold(
            backgroundColor: navyBlue,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

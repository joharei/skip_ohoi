import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/map/map.dart';
import 'package:skip_ohoi/menu.dart';

void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await Crashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: navyBlue,
        iconTheme: IconThemeData(color: richBlack),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: richBlack,
              displayColor: richBlack,
            ),
        accentColor: coquelicot,
        buttonColor: nyanza,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: nyanza,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var mapType = MapType.ENC;
  final _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            resizeToAvoidBottomInset: false,
            body: Stack(children: [
              Map(mapType: mapType),
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.menu, color: Colors.black87),
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
                              onChangeMapType: (mapType) {
                                setState(() {
                                  this.mapType = mapType;
                                });
                                this.setState(() {
                                  this.mapType = mapType;
                                });
                              },
                            );
                          });
                        },
                      );
                    },
                    mini: true,
                  ),
                ),
              )
            ]),
          );
        }
        return Scaffold(
          backgroundColor: navyBlue,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

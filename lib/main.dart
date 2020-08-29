import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/dash_bottom_app_bar.dart';
import 'package:skip_ohoi/map/map.dart';

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
        backgroundColor: nyanza,
        scaffoldBackgroundColor: nyanza,
        canvasColor: nyanza,
        bottomAppBarColor: nyanza,
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
  var mapType = MapType.SJOKARTRASTER;
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
              body: Map(mapType: mapType),
              bottomNavigationBar: DashBottomAppBar(
                mapType: mapType,
                onChangeMapType: (mapType) {
                  setState(() {
                    this.mapType = mapType;
                  });
                  this.setState(() {
                    this.mapType = mapType;
                  });
                },
              ),
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

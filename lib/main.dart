import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/home/ui.dart';
import 'package:skip_ohoi/state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
    return Injector(
      inject: [Inject(() => MapType.SJOKARTRASTER)],
      builder: (context) {
        return MaterialApp(
          title: 'Skip ohoi!',
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
      },
    );
  }
}

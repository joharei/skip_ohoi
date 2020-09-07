import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/home/ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          foregroundColor: richBlack,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flt_worker/flt_worker.dart';
import 'package:flutter/material.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/home/ui.dart';
import 'package:skip_ohoi/worker.dart';

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
    initializeWorker(worker);
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
        colorScheme: ColorScheme.light(
          primary: navyBlue,
          onPrimary: nyanza,
          secondary: coquelicot,
          onSecondary: nyanza,
          background: nyanza,
          onBackground: richBlack,
          surface: nyanza,
          onSurface: richBlack,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: navyBlue,
          foregroundColor: nyanza,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            ...Theme.of(context).pageTransitionsTheme.builders,
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          color: nyanza,
          brightness: Brightness.light,
          textTheme: Typography.material2018()
              .black
              .merge(Typography.englishLike2018)
              .apply(
                bodyColor: richBlack,
                displayColor: richBlack,
              ),
          iconTheme: const IconThemeData(color: richBlack),
          actionsIconTheme: const IconThemeData(color: richBlack),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

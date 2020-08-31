import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/features/dash_bottom_app_bar/ui.dart';
import 'package:skip_ohoi/features/map/ui.dart';

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
              body: Map(),
              bottomNavigationBar: DashBottomAppBar(),
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

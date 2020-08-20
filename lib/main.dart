import 'package:flutter/material.dart';
import 'package:skip_ohoi/colors.dart';
import 'package:skip_ohoi/map.dart';
import 'package:skip_ohoi/menu.dart';

void main() {
  runApp(MyApp());
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var mapType = MapType.ENC;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        BorderRadius.vertical(top: Radius.circular(16)),
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
}

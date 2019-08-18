import 'dart:async';
import 'dart:collection';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/global.dart' as global;
import '../ui/category_card.dart';

class CategoriesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesPageState();
  }
}

class CategoriesPageState extends State<CategoriesPage> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String errorMessage;
  
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.seafoamGreen,
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
        )
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              new Builder(builder: (BuildContext context) { return new CategoryCard(["test"]); }),
              new Builder(builder: (BuildContext context) { return new CategoryCard(["test2"]); }) 
            ],
          )
        ]
      )
    );
  }
}